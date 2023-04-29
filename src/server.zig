//	SERVER.ZIG
//	----------
//	Copyright (c) Vaughan Kitchen
//	Released under the ISC license (https://opensource.org/licenses/ISC)

const std = @import("std");

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

const search =
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

fn handle_404(res: *std.http.Server.Response) !void {
    try res.headers.append("content-type", "text/plain; charset=utf-8");
    res.transfer_encoding = .{ .content_length = 3 };
    try res.do();
    try res.writer().writeAll("404");
    try res.finish();
}

fn handle_search(res: *std.http.Server.Response) !void {
    std.debug.print("{} {s}\n", .{ res.request.method, res.request.target });

    var param_q = std.mem.indexOf(u8, res.request.target, "?q=");
    var param_page = std.mem.indexOf(u8, res.request.target, "&page=");

    if (param_q == null)
        return handle_404(res);

    var q: []const u8 = undefined;
    if (param_page) |page_| {
        q = res.request.target[param_q.? + 3 .. page_];
    } else {
        q = res.request.target[param_q.? + 3 ..];
    }

    var page: u16 = 1;
    if (param_page) |page_| {
        page = try std.fmt.parseUnsigned(u16, res.request.target[page_ + 6 ..], 10);
    }

    std.debug.print("Query {s} page {d}\n", .{ q, page });

    try res.headers.append("content-type", "text/html; charset=utf-8");
    res.transfer_encoding = .{ .content_length = search.len };
    try res.do();
    try res.writer().writeAll(search);
    try res.finish();
}

fn handler(res: *std.http.Server.Response) !void {
    while (true) {
        defer res.reset();

        try res.wait();

        try res.headers.append("connection", "close");

        if (std.mem.eql(u8, res.request.target, "/")) {
            try res.headers.append("content-type", "text/html; charset=utf-8");
            res.transfer_encoding = .{ .content_length = index.len };
            try res.do();
            try res.writer().writeAll(index);
            try res.finish();
        } else if (std.mem.startsWith(u8, res.request.target, "/search")) {
            try handle_search(res);
        } else if (std.mem.eql(u8, res.request.target, "/static/main.css")) {
            try res.headers.append("content-type", "text/css; charset=utf-8");
            res.transfer_encoding = .{ .content_length = css.len };
            try res.do();
            try res.writer().writeAll(css);
            try res.finish();
        } else {
            try res.headers.append("content-type", "text/plain; charset=utf-8");
            res.transfer_encoding = .{ .content_length = 3 };
            try res.do();
            try res.writer().writeAll("404");
            try res.finish();
        }

        if (res.connection.conn.closing)
            break;
    }
}

pub fn main() !void {
    var server = std.http.Server.init(std.heap.page_allocator, .{ .reuse_address = true });
    defer server.deinit();

    try server.listen(try std.net.Address.parseIp("127.0.0.1", 8080));

    while (true) {
        const res = try server.accept(.{ .dynamic = 8192 });

        const thread = try std.Thread.spawn(.{}, handler, .{res});
        thread.detach();
    }
}
