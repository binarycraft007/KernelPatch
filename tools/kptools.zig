const std = @import("std");
const io = std.io;
const c = @cImport({
    @cInclude("../version");
    @cInclude("preset.h");
    @cInclude("image.h");
    @cInclude("order.h");
    @cInclude("kallsym.h");
    @cInclude("patch.h");
    @cInclude("common.h");
    @cInclude("kpm.h");
});
const clap = @import("clap");
const android = @import("android");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help                   Print this message.
        \\-v, --version                Print version number
        \\-p, --patch                  Patch or Update patch kernel image.
        \\-s, --skey <str>             Specify superkey.
        \\-o, --out <str>              Patched image path.
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = arena.allocator(),
    }) catch |err| {
        // Report useful error and exit
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    var skey: ?[]const u8 = null;
    var out: ?[]const u8 = null;

    if (res.args.help != 0) {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
    if (res.args.version != 0) {
        std.debug.print("{x}\n", .{c.get_kpimg_version(null)});
        return;
    }
    if (res.args.patch == 0) {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
    if (res.args.skey) |skey_const| {
        skey = skey_const;
    } else {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
    if (res.args.out) |out_const| {
        out = out_const;
    } else {
        return clap.help(std.io.getStdErr().writer(), clap.Help, &params, .{});
    }
}
