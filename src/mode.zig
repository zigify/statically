pub const Mode = enum(u8) {
    Shared = 0,
    Static = 1,

    pub fn toBool(self: Mode) bool {
        return @intFromEnum(self) == 1;
    }
};
