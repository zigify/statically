const std = @import("std");

pub const Serialized = struct {
    allocator: std.mem.Allocator,
    data: []const u8,

    pub fn init(allocator: std.mem.Allocator, data: []const u8) Serialized {
        return Serialized{ .allocator = allocator, .data = data };
    }

    pub fn deinit(self: Serialized) void {
        self.allocator.free(self.data);
    }
};

pub fn Deserialized(comptime T: type) type {
    return struct {
        const Self = @This();
        data: T,

        pub fn init(data: T) Self {
            return Self{ .data = data };
        }
    };
}
