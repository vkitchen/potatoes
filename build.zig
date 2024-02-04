const std = @import("std");

pub fn build(b: *std.Build) !void {
    const potatoes = b.addExecutable(.{
        .name = "potatoes",
        .root_source_file = .{ .path = "src/server.zig" },
        .target = b.host,
        .optimize = .ReleaseFast,
    });
    b.installArtifact(potatoes);
}
