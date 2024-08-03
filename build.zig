const std = @import("std");
const statically = @import("src/lib.zig");

pub const Mode = statically.Mode;
pub const Context = statically.Context;
pub const License = statically.License;
pub const Serialized = statically.Serialized;
pub const Deserialized = statically.Deserialized;

pub fn build(_: *std.Build) void {}
