const std = @import("std");
const assert = std.debug.assert;
const Mode = @import("lib.zig").Mode;
const Serialized = @import("lib.zig").Serialized;
const Deserialized = @import("lib.zig").Deserialized(Context);
const log = std.log.scoped(.@"statically/context");

pub const Context = struct {
    allocator: std.mem.Allocator,
    /// This is the name of the Package. This is the same one you
    /// use when referencing this in the overrides.
    name: []const u8,
    /// This is the standard build mode for this and dependencies.
    mode: Mode,
    /// This is a list of overrides for dependencies.
    overrides: std.StringHashMap(Mode),
    /// Has this Context been hooked yet?
    hooked: bool = false,

    pub fn init(allocator: std.mem.Allocator, name: []const u8, mode: Mode) Context {
        // Can't include these in your package name.
        assert(std.mem.indexOfScalar(u8, name, ';') == null);
        assert(std.mem.indexOfScalar(u8, name, '=') == null);

        return Context{
            .allocator = allocator,
            .name = name,
            .mode = mode,
            .overrides = std.StringHashMap(Mode).init(allocator),
            .hooked = false,
        };
    }

    /// This will hook the Zig Build System, prioritizing the Context from the parent
    /// if there is one.
    pub fn hook(self: *Context, b: *std.Build) !void {
        self.mode = b.option(Mode, "statically", "Enable Statically Compilation") orelse self.mode;
        const parent_passed_str = b.option([]const u8, "statically_context", "Pass in Statically Context");

        if (parent_passed_str) |parent_str| {
            const parent_deserialized = try Context.deserialize(self.allocator, parent_str);
            var parent_context = parent_deserialized.data;
            defer parent_context.deinit();

            log.debug("current: {s} | inheriting parent context: {s}", .{ self.name, parent_context.name });

            var iter = parent_context.overrides.iterator();
            while (iter.next()) |entry| {
                // Add the parent overrides.
                try self.overrides.put(entry.key_ptr.*, entry.value_ptr.*);
            }
        }

        self.hooked = true;
        self.print();
    }

    pub fn deinit(self: *Context) void {
        self.overrides.deinit();
    }

    /// You can only add overrides before you hook the build system.
    /// This is to ensure proper behavior with parent contexts.
    pub fn addOverride(self: *Context, name: []const u8, mode: Mode) !void {
        assert(self.hooked == false);
        try self.overrides.put(name, mode);
    }

    fn print(self: Context) void {
        const mode: Mode = blk: {
            if (self.overrides.get(self.name)) |mode| {
                break :blk mode;
            } else {
                break :blk self.mode;
            }
        };

        const value = if (mode.toBool()) "static" else "shared";
        log.debug("{s}: {s}", .{ self.name, value });
    }

    pub fn library(self: *Context, b: *std.Build, options: anytype) *std.Build.Step.Compile {
        assert(self.hooked);

        // Prioritize overrides.
        const mode: Mode = blk: {
            if (self.overrides.get(self.name)) |mode| {
                break :blk mode;
            } else {
                break :blk self.mode;
            }
        };

        return switch (mode.toBool()) {
            true => b.addStaticLibrary(options),
            false => b.addSharedLibrary(options),
        };
    }

    pub fn dependency(
        self: *Context,
        b: *std.Build,
        name: []const u8,
        target: std.Build.ResolvedTarget,
        optimize: std.builtin.OptimizeMode,
    ) *std.Build.Dependency {
        assert(self.hooked);
        const data = self.serialize() catch @panic("Unable to serialize!");
        const context = data.data;

        return b.dependency(name, .{
            .target = target,
            .optimize = optimize,
            .statically = self.mode,
            .statically_context = context,
        });
    }

    pub fn serialize(self: *Context) !Serialized {
        var buffer = [_]u8{undefined} ** 128;
        var string = std.ArrayList(u8).init(self.allocator);
        defer string.deinit();

        try string.appendSlice(self.name);
        try string.append(';');

        try string.appendSlice(try std.fmt.bufPrint(
            buffer[0..],
            "{d};",
            .{@intFromEnum(self.mode)},
        ));

        var iter = self.overrides.iterator();
        while (iter.next()) |entry| {
            const slice = try std.fmt.bufPrint(buffer[0..], "{s}={d};", .{
                entry.key_ptr.*,
                @intFromEnum(entry.value_ptr.*),
            });

            try string.appendSlice(slice);
        }

        return Serialized.init(
            self.allocator,
            try self.allocator.dupe(u8, string.items),
        );
    }

    pub fn deserialize(allocator: std.mem.Allocator, data: []const u8) !Deserialized {
        assert(data.len > 0);
        var iter = std.mem.tokenizeScalar(u8, data, ';');

        const name: []const u8 = blk: {
            if (iter.next()) |name_str| {
                break :blk name_str;
            } else {
                return error.PoorlyFormedData;
            }
        };

        const mode: Mode = blk: {
            if (iter.next()) |mode_str| {
                const mode: u8 = try std.fmt.parseInt(u8, mode_str, 10);
                break :blk @enumFromInt(mode);
            } else {
                return error.PoorlyFormedData;
            }
        };

        var context = Context.init(allocator, name, mode);
        errdefer context.deinit();

        while (iter.next()) |entry| {
            var other = std.mem.tokenizeScalar(u8, entry, '=');
            if (other.next()) |key| {
                if (other.next()) |value_str| {
                    const value: u8 = try std.fmt.parseInt(u8, value_str, 10);
                    try context.overrides.put(key, @enumFromInt(value));
                } else {
                    return error.PoorlyFormedData;
                }
            } else {
                return error.PoorlyFormedData;
            }
        }

        return Deserialized.init(context);
    }
};

const testing = std.testing;

test "Context Serialization (Empty Overrides)" {
    var context: Context = Context.init(testing.allocator, "libtrial", .Static);
    defer context.deinit();

    const serialized = try context.serialize();
    defer serialized.deinit();

    try testing.expectEqualStrings("libtrial;1;", serialized.data);
}

test "Context Serialization & Deserialization" {
    var context: Context = Context.init(testing.allocator, "libtrial", .Shared);
    defer context.deinit();

    try context.addOverride("libusb", .Static);
    try context.addOverride("libtest", .Shared);
    try context.addOverride("libstatic", .Static);
    try context.addOverride("libshared", .Shared);
    try context.addOverride("libyaml", .Static);

    const serialized = try context.serialize();
    defer serialized.deinit();

    const deserialized = try Context.deserialize(testing.allocator, serialized.data);
    var new_context: Context = deserialized.data;
    defer new_context.deinit();

    try testing.expectEqualStrings(context.name, new_context.name);
    try testing.expectEqual(context.mode, new_context.mode);
    try testing.expectEqual(context.overrides.count(), new_context.overrides.count());

    var iter = context.overrides.iterator();
    while (iter.next()) |entry| {
        if (new_context.overrides.getEntry(entry.key_ptr.*)) |new_entry| {
            try testing.expectEqual(entry.value_ptr.*, new_entry.value_ptr.*);
        } else {
            return error.MissingEntry;
        }
    }
}
