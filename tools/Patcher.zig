pub fn patch(kpimg: []const u8) !void {
    const preset = try getPreset(kpimg);
    _ = preset;
}

fn getPreset(kpimg: []const u8) !c.preset_t {
    if (std.mem.indexOf(u8, kpimg, c.KP_MAGIC)) |i| {
        const buffer = kpimg[i .. i + @sizeOf(c.preset_t)];
        var stream = std.io.fixedBufferStream(buffer);
        return stream.reader().readStruct(c.preset_t);
    }
    return error.NoKernelPatchMagic;
}

const std = @import("std");
const c = @cImport({
    @cInclude("preset.h");
});
const assert = std.debug.assert;
const Patcher = @This();
