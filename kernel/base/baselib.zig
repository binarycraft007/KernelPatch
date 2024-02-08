const std = @import("std");

export fn toupper(c: u8) u8 {
    return std.ascii.toUpper(c);
}
