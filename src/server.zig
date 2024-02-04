//	SERVER.ZIG
//	----------
//	Copyright (c) Vaughan Kitchen
//	Released under the ISC license (https://opensource.org/licenses/ISC)

const std = @import("std");
const native_endian = @import("builtin").target.cpu.arch.endian();

const socket_name = "/tmp/cocomel.sock";

const index =
    \\<!DOCTYPE html>
    \\<html>
    \\<head>
    \\<meta charset="utf-8">
    \\<link rel="stylesheet" type="text/css" href="/static/main.css">
    \\<title>Potato Castles</title>
    \\</head>
    \\<body>
    \\<div class="home-hero">
    \\	<h1 class="logo">Potato Castles</h1>
    \\	<form action="/search" method="get">
    \\		<input class="search-input" type="text" name="q" placeholder="What would you like to cook tonight?"><!--
    \\		--><input class="search-submit" type="submit" value="Search">
    \\	</form>
    \\</div>
    \\</body>
    \\</html>
;

const css =
    \\*, *:before, *:after {
    \\	box-sizing: border-box;
    \\}
    \\
    \\body {
    \\	font-family: arial, sans-serif;
    \\	background-color: #f1f2f3;
    \\	margin: 0;
    \\	padding: 20px;
    \\}
    \\
    \\.home-hero {
    \\	position: absolute;
    \\	top: 33%;
    \\	left: 50%;
    \\	transform: translate(-50%, -50%);
    \\	width: 400px
    \\}
    \\
    \\.home-hero .logo {
    \\	color: #000;
    \\	font-size: 48px;
    \\	margin: 0;
    \\	padding: 0;
    \\	text-align: center;
    \\	width: 100%;
    \\}
    \\
    \\.home-hero form {
    \\}
    \\
    \\.home-hero .search-input:focus {
    \\	outline: none;
    \\}
    \\
    \\.home-hero .search-input::placeholder {
    \\	color: #aaa;
    \\	opacity: 1;
    \\}
    \\
    \\.home-hero .search-input {
    \\	color: #fff;
    \\	background-color: #000;
    \\	border: none;
    \\	padding: 0 60px 0 4px;
    \\	height: 24px;
    \\	margin: 0;
    \\	width: 100%;
    \\}
    \\
    \\.home-hero .search-submit {
    \\	background-color: #f00;
    \\	border: none;
    \\	color: #fff;
    \\	padding: 0;
    \\	height: 24px;
    \\	margin: 0 0 0 -60px;
    \\	width: 60px;
    \\	cursor: pointer;
    \\}
    \\
    \\/* search.html */
    \\
    \\.header {
    \\	margin: 0 10px;
    \\	padding: 10px 2px;
    \\	border-bottom: 1px solid #aaa;
    \\}
    \\
    \\.header-insert {
    \\	position: relative;
    \\}
    \\
    \\.header .logo {
    \\	color: #000;
    \\	font-size: 32px;
    \\	display: inline;
    \\	padding: 0;
    \\	margin: 0;
    \\}
    \\
    \\.header .logo a {
    \\	color: black;
    \\	text-decoration: none;
    \\}
    \\
    \\.header form {
    \\	display: inline-block;
    \\	padding: 0;
    \\	margin: 0 0 0 10px;
    \\}
    \\
    \\.header .search-input:focus {
    \\	outline: none;
    \\}
    \\
    \\.header .search-input::placeholder {
    \\	color: #aaa;
    \\	opacity: 1;
    \\}
    \\
    \\.header .search-input {
    \\	color: #fff;
    \\	background-color: #000;
    \\	border: none;
    \\	padding: 0 60px 0 4px;
    \\	height: 24px;
    \\	margin: 0;
    \\	width: 400px;
    \\}
    \\
    \\.header .search-submit {
    \\	background-color: #f00;
    \\	border: none;
    \\	color: #fff;
    \\	padding: 0;
    \\	height: 24px;
    \\	margin: 0 0 0 -60px;
    \\	width: 60px;
    \\	cursor: pointer;
    \\}
    \\
    \\.main-content {
    \\	max-width: 800px;
    \\	margin: 0 16px 16px 60px;
    \\}
    \\
    \\.results-list {
    \\	list-style: none;
    \\	margin: 0;
    \\	padding: 0;
    \\}
    \\
    \\.search-result {
    \\	margin: 16px 0;
    \\	padding: 0;
    \\}
    \\
    \\.result-title:hover {
    \\	text-decoration: underline;
    \\}
    \\
    \\.result-title {
    \\	font-size: 18px;
    \\	text-decoration: none;
    \\	color: #000;
    \\}
    \\
    \\.result-link {
    \\	font-size: 14px;
    \\	margin: 4px 0;
    \\	color: #666;
    \\}
    \\
    \\.result-excerpt {
    \\	font-size: 16px;
    \\	color: #444;
    \\}
    \\
    \\.next-page:hover {
    \\	text-decoration: underline;
    \\}
    \\
    \\.next-page {
    \\	font-size: 16px;
    \\	color: #444;
    \\	text-decoration: none;
    \\}
    \\
    \\li {
    \\	list-style: none;
    \\	margin-bottom: 30px;
    \\	max-width: 800px;
    \\}
    \\
    \\h4 {
    \\	margin: 10px 0;
    \\}
    \\
    \\li p {
    \\	margin-top: 10px;
    \\}
;

fn read16(buf: []const u8, offset: usize) u16 {
    return std.mem.bytesToValue(u16, buf[offset .. offset + @sizeOf(u16)][0..2]);
}

fn handle_404(res: *std.http.Server.Response) !void {
    try res.headers.append("content-type", "text/plain; charset=utf-8");
    res.transfer_encoding = .{ .content_length = 3 };
    try res.writer().writeAll("404");
    try res.finish();
}

fn handle_search(res: *std.http.Server.Response) !void {
    // Parse params
    const param_query = std.mem.indexOf(u8, res.request.target, "?q=");
    const param_page = std.mem.indexOf(u8, res.request.target, "&page=");

    if (param_query == null)
        return handle_404(res);

    var query: []const u8 = undefined;
    if (param_page) |page_| {
        query = res.request.target[param_query.? + 3 .. page_];
    } else {
        query = res.request.target[param_query.? + 3 ..];
    }

    var page: u16 = 1;
    if (param_page) |page_| {
        page = try std.fmt.parseUnsigned(u16, res.request.target[page_ + 6 ..], 10);
    }

    // Search
    var timer = try std.time.Timer.start();

    var stream = try std.net.connectUnixSocket(socket_name);

    // Build query
    var search_req_bufferer = std.io.bufferedWriter(stream.writer());
    var search_req = search_req_bufferer.writer();

    try search_req.writeByte(0); // version
    try search_req.writeByte(1); // method
    try search_req.writeInt(u16, 10, native_endian); // res len
    try search_req.writeInt(u16, 10 * (page - 1), native_endian); // res offset
    try search_req.writeInt(u16, @truncate(query.len), native_endian); // query len
    try search_req.writeAll(query); // query

    try search_req_bufferer.flush();

    var results_buffer: [16384]u8 = undefined;

    var total_read: usize = 0;
    while (true) {
        const bytes_read = try stream.read(results_buffer[total_read..]);
        if (bytes_read == 0)
            break;
        total_read += bytes_read;
    }

    stream.close();

    const search_time = timer.read();

    // Write results
    try res.headers.append("content-type", "text/html; charset=utf-8");
    res.transfer_encoding = .chunked;

    // skip method and version
    const total_results = read16(&results_buffer, 2);
    const no_results = read16(&results_buffer, 4);

    try res.writer().print(
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
        \\<form class='site-search' action='/search' method='get'>
        \\<input class='search-input' type='text' name='q' placeholder='Search recipes...'><!--
        \\--><input class='search-submit' type='submit' value='Search'>
        \\</form>
        \\<h4>Approx {d} results in {d:.3} seconds</h4>
        \\</div>
        \\<p>Page {d}</p>
    , .{ total_results, @as(f64, @floatFromInt(search_time)) / 1e9, page });

    try res.writer().print("<ul>\n", .{});
    var offset: usize = 6;

    var i: usize = 0;
    while (i < no_results) : (i += 1) {
        try res.writer().print("<li>\n", .{});
        const name_len = read16(&results_buffer, offset);
        offset += 2;
        const name = results_buffer[offset .. offset + name_len];
        try res.writer().print("<a href='http://{s}'>{s}</a>\n", .{ name, name });
        offset += name_len;
        const title_len = read16(&results_buffer, offset);
        offset += 2;
        if (title_len > 0) {
            const title = results_buffer[offset .. offset + title_len];
            try res.writer().print("<h4>{s}</h4>\n", .{title});
            offset += title_len;
        }
        const snippet_len = read16(&results_buffer, offset);
        offset += 2;
        try res.writer().print("<p>{s}</p>\n\n", .{results_buffer[offset .. offset + snippet_len]});
        offset += snippet_len;
        try res.writer().print("</li>\n", .{});
    }
    try res.writer().print("</ul>\n", .{});
    if (no_results == 10)
        try res.writer().print("<a href='?q={s}&page={d}'>Next Page</a>\n", .{ query, page + 1 });
    try res.writer().print("</body>\n", .{});
    try res.writer().print("</html>\n", .{});

    try res.finish();
}

fn handler(res: *std.http.Server.Response) !void {
    defer res.deinit();
    defer _ = res.reset();

    try res.wait();

    try res.headers.append("connection", "close");

    if (std.mem.eql(u8, res.request.target, "/")) {
        try res.headers.append("content-type", "text/html; charset=utf-8");
        res.transfer_encoding = .{ .content_length = index.len };
        try res.writer().writeAll(index);
        try res.finish();
    } else if (std.mem.startsWith(u8, res.request.target, "/search")) {
        try handle_search(res);
    } else if (std.mem.eql(u8, res.request.target, "/static/main.css")) {
        try res.headers.append("content-type", "text/css; charset=utf-8");
        res.transfer_encoding = .{ .content_length = css.len };
        try res.writer().writeAll(css);
        try res.finish();
    } else {
        try res.headers.append("content-type", "text/plain; charset=utf-8");
        res.transfer_encoding = .{ .content_length = 3 };
        try res.writer().writeAll("404");
        try res.finish();
    }
}

pub fn main() !void {
    var buffer_headers: [8192]u8 = undefined;
    var buffer_requests: [16384]u8 = undefined;

    var allocator = std.heap.FixedBufferAllocator.init(&buffer_requests);

    var server = std.http.Server.init(.{ .reuse_address = true });
    defer server.deinit();

    try server.listen(try std.net.Address.parseIp("127.0.0.1", 8080));

    while (true) {
        var res = server.accept(.{ .allocator = allocator.allocator(), .header_strategy = .{ .static = &buffer_headers } }) catch {
            allocator.reset();
            continue;
        };
        try handler(&res);
        allocator.reset();
    }
}
