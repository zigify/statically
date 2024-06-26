const std = @import("std");

var statically: bool = false;

pub fn set(state: bool) void {
    statically = state;
}

pub fn option(b: *std.Build) bool {
    statically = b.option(bool, "statically", "statically compile this dependency (and all children)") orelse false;
    return statically;
}

pub fn log(name: []const u8) void {
    const value = if (statically) "static" else "shared";
    std.debug.print("{s}: {s}\n", .{ name, value });
}

pub fn library(b: *std.Build, options_static: std.Build.StaticLibraryOptions, options_shared: std.Build.SharedLibraryOptions) *std.Build.Step.Compile {
    return switch (statically) {
        true => b.addStaticLibrary(options_static),
        false => b.addSharedLibrary(options_shared),
    };
}

pub fn dependency(b: *std.Build, name: []const u8, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Dependency {
    return b.dependency(name, .{
        .target = target,
        .optimize = optimize,
        .statically = statically,
    });
}

pub fn build(b: *std.Build) void {
    _ = option(b);
    _ = log("statically");
}