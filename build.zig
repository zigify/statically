const std = @import("std");

var statically: bool = false;
var statically_deps: bool = false;

pub const Mode = enum(usize) {
    Shared = 0,
    Static = 1,
};

fn enumToBool(_enum: anytype) bool {
    return @intFromEnum(_enum) != 0;
}

pub fn setMode(mode: Mode) void {
    statically = enumToBool(mode);
}

pub fn setChildrenMode(mode: Mode) void {
    statically_deps = enumToBool(mode);
}

pub fn option(b: *std.Build) bool {
    statically = b.option(bool, "statically", "statically compile this dependency (and all deps)") orelse false;
    statically_deps = b.option(bool, "statically_deps", "compile deps differently") orelse statically;
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
    return dependencyWithOptions(b, name, target, optimize, .{ .mode = if (statically) Mode.Static else Mode.Shared });
}

pub const DependencyOptions = struct {
    mode: ?Mode = null,
    deps_mode: ?Mode = null,
};

pub fn dependencyWithOptions(b: *std.Build, name: []const u8, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, options: DependencyOptions) *std.Build.Dependency {
    var statically_status = statically;
    if (options.mode) |mode| {
        statically_status = enumToBool(mode);
    }

    var statically_deps_status = statically_deps;
    if (options.deps_mode) |mode| {
        statically_deps_status = enumToBool(mode);
    }

    return b.dependency(name, .{
        .target = target,
        .optimize = optimize,
        .statically = statically_status,
        .statically_deps = statically_deps_status,
    });
}

pub fn build(b: *std.Build) void {
    _ = option(b);
    _ = log("statically");
}
