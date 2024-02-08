const std = @import("std");
const Pacther = @import("Patcher.zig");
const kpimg = @embedFile("kpimg");

pub fn main() !void {
    try Pacther.patch(kpimg);
}
