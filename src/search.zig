//	SEARCH.ZIG
//	----------
//	Copyright (c) Vaughan Kitchen
//	Released under the ISC license (https://opensource.org/licenses/ISC)

const std = @import("std");
const str = @import("str.zig");

const socket_name = "/tmp/cocomel.sock";

fn read16(buf: []const u8, offset: usize) u16 {
    return std.mem.bytesToValue(u16, buf[offset .. offset + @sizeOf(u16)][0..2]);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var q = std.os.getenv("QUERY_STRING");
    if (q == null) return;
    var loc = std.mem.indexOf(u8, q.?, "&");
    var page: []const u8 = "";
    var page_no: u16 = 0;
    var query: []u8 = "";
    if (loc != null) {
        query = try str.dup(allocator, q.?[2..loc.?]);
        page = q.?[loc.? + 6 ..];
        page_no = try std.fmt.parseUnsigned(u16, page, 10) - 1;
    } else {
        query = try str.dup(allocator, q.?[2..]);
    }
    var raw_query = try str.dup(allocator, query);

    var buf: [1000]u8 = undefined;
    buf[0] = 0; // version
    buf[1] = 1; // method
    buf[2] = 10; // len low
    buf[3] = 0; // len high
    buf[4] = 10 * @truncate(u8, page_no); // offset low
    buf[5] = 0; // offset high
    const len = @truncate(u16, query.len);
    const lenp = std.mem.asBytes(&len);
    std.mem.copy(u8, buf[6..], lenp);
    std.mem.copy(u8, buf[8..], query);

    var results_buffer: [16384]u8 = undefined;

    var timer = try std.time.Timer.start();

    var stream = try std.net.connectUnixSocket(socket_name);

    _ = try stream.write(buf[0 .. 8 + query.len]);

    var total_read: usize = 0;
    while (true) {
        var bytes_read = try stream.read(results_buffer[total_read..]);
        if (bytes_read == 0)
            break;
        total_read += bytes_read;
    }

    stream.close();

    const search_time = timer.read();

    // skip method and version
    const total_results = read16(&results_buffer, 2);
    const no_results = read16(&results_buffer, 4);

    try stdout.print("Content-type: text/html; charset=utf-8\n\n", .{});

    try stdout.print(
        \\<!DOCTYPE html>
        \\<html>
        \\<head>
        \\<meta charset='utf-8'>
        \\<link rel='stylesheet' type='text/css' href='/static/main.css'>
        \\<title>search results - Potato Castles</title>
        \\</head>
        \\<body>
        \\<div class='header'>
        \\<h1 class='logo'><a href='/'>Potato Castles</a></h1>
        \\<form class='site-search' action='/cgi-bin/search-recipes' method='get'>
        \\<input class='search-input' type='text' name='q' placeholder='Search recipes...'><!--
        \\--><input class='search-submit' type='submit' value='Search'>
        \\</form>
        \\<h4>Approx {d} results in {d:.3} seconds</h4>
        \\</div>
        \\<p>Page {d}</p>
    , .{ total_results, @intToFloat(f64, search_time) / 1e9, page_no + 1 });

    try stdout.print("<ul>\n", .{});
    var offset: usize = 6;

    var i: usize = 0;
    while (i < no_results) : (i += 1) {
        try stdout.print("<li>\n", .{});
        const name_len = read16(&results_buffer, offset);
        offset += 2;
        const name = results_buffer[offset .. offset + name_len];
        try stdout.print("<a href='http://{s}'>{s}</a>\n", .{ name, name });
        offset += name_len;
        offset += 2; // skip docno
        const snippet_len = read16(&results_buffer, offset);
        offset += 2;
        try stdout.print("<p>{s}</p>\n\n", .{results_buffer[offset .. offset + snippet_len]});
        offset += snippet_len;
        try stdout.print("</li>\n", .{});
    }
    try stdout.print("</ul>\n", .{});
    try stdout.print("<a href='?q={s}&page={d}'>Next Page</a>\n", .{ raw_query, page_no + 2 });
    try stdout.print("</body>\n", .{});
    try stdout.print("</html>\n", .{});
}
