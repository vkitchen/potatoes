const Builder = @import("std").build.Builder;
const Mode = @import("std").builtin.Mode;
const CrossTarget = @import("std").zig.CrossTarget;

pub fn build(b: *Builder) !void {
    const search = b.addExecutable(.{
        .name = "potatoes",
        .root_source_file = .{ .path = "src/server.zig" },
        .optimize = Mode.ReleaseSafe,
    });
    b.installArtifact(search);

    const search_linux = b.addExecutable(.{
        .name = "potatoes-linux",
        .root_source_file = .{ .path = "src/server.zig" },
        .target = try CrossTarget.parse(.{ .arch_os_abi = "x86_64-linux-musl" }),
        .optimize = Mode.ReleaseFast,
    });
    b.installArtifact(search_linux);
}
