const Builder = @import("std").build.Builder;
const Mode = @import("std").builtin.Mode;
const CrossTarget = @import("std").zig.CrossTarget;

pub fn build(b: *Builder) !void {
    const search = b.addExecutable("search-recipes", "src/search.zig");
    search.setTarget(try CrossTarget.parse(.{ .arch_os_abi = "x86_64-linux-musl" }));
    search.setBuildMode(Mode.ReleaseFast);
    search.install();
}
