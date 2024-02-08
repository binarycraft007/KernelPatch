const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const android = b.option(bool, "android", "build for android") orelse false;

    const kpimg = b.addExecutable(.{
        .name = "kpimg",
        .root_source_file = .{ .path = "kernel/base/baselib.zig" },
        .target = b.resolveTargetQuery(.{
            .os_tag = .freestanding,
            .cpu_arch = .aarch64,
            .abi = .none,
        }),
        .optimize = optimize,
    });
    kpimg.pie = false;
    kpimg.root_module.c_std = .C11;
    kpimg.entry = .{ .symbol_name = "setup_entry" };
    kpimg.link_gc_sections = true;
    kpimg.setLinkerScript(.{ .path = "kernel/kpimg.lds" });
    kpimg.addCSourceFiles(.{
        .files = &kernel_src,
        .flags = &.{},
    });
    inline for (kernel_src_asm) |asm_src| {
        kpimg.addAssemblyFile(.{ .path = asm_src });
    }
    if (android) {
        kpimg.defineCMacro("ANDROID", null);
        kpimg.addCSourceFiles(.{
            .files = &kernel_src_android,
            .flags = &.{},
        });
    }
    if (optimize == .Debug) {
        kpimg.defineCMacro("DEBUG", null);
    }
    kpimg.addIncludePath(.{ .path = "kernel" });
    kpimg.addIncludePath(.{ .path = "kernel/linux" });
    kpimg.addIncludePath(.{ .path = "kernel/include" });
    kpimg.addIncludePath(.{ .path = "kernel/patch/include" });
    kpimg.addIncludePath(.{ .path = "kernel/linux/include" });
    kpimg.addIncludePath(.{ .path = "kernel/linux/arch/arm64/include" });
    kpimg.addIncludePath(.{ .path = "kernel/linux/tools/arch/arm64/include" });

    const tools = b.addExecutable(.{
        .name = "kptools",
        .root_source_file = .{ .path = "tools/kptools.zig" },
        .target = target,
        .optimize = optimize,
    });
    tools.linkLibC();
    tools.root_module.c_std = .C11;
    tools.addCSourceFiles(.{
        .files = &tools_src,
        .flags = &.{},
    });
    tools.addIncludePath(.{ .path = "tools" });
    tools.addIncludePath(.{ .path = "kernel/include" });
    tools.root_module.addAnonymousImport("kpimg", .{
        .root_source_file = kpimg.addObjCopy(.{ .format = .bin }).getOutput(),
    });
    b.installArtifact(tools);
}

const kernel_src = [_][]const u8{
    "kernel/base/baselib.c",
    "kernel/base/symbol.c",
    "kernel/base/log.c",
    "kernel/base/hook.c",
    "kernel/base/tlsf.c",
    "kernel/base/start.c",
    "kernel/base/setup.c",
    "kernel/base/hmem.c",
    "kernel/base/predata.c",
    "kernel/base/map.c",
    "kernel/base/fphook.c",
    "kernel/patch/ksyms/misc.c",
    "kernel/patch/ksyms/task_cred.c",
    "kernel/patch/ksyms/libs.c",
    "kernel/patch/ksyms/suffix_sym.c",
    "kernel/patch/module/insn.c",
    "kernel/patch/module/relo.c",
    "kernel/patch/module/module.c",
    "kernel/patch/common/syscall.c",
    "kernel/patch/common/secpass.c",
    "kernel/patch/common/selinuxhook.c",
    "kernel/patch/common/taskob.c",
    "kernel/patch/common/accctl.c",
    "kernel/patch/common/utils.c",
    "kernel/patch/common/extrainit.c",
    "kernel/patch/common/hotpatch.c",
    "kernel/patch/common/supercall.c",
    "kernel/patch/patch.c",
};

const kernel_src_android = [_][]const u8{
    "kernel/patch/android/sucompat.c",
    "kernel/patch/android/kpuserd.c",
    "kernel/patch/android/supercall.c",
};

const kernel_src_asm = [_][]const u8{
    "kernel/base/cache.S",
    "kernel/base/map1.S",
    "kernel/base/setup1.S",
};

const tools_src = [_][]const u8{
    "tools/common.c",
    "tools/image.c",
    "tools/insn.c",
    "tools/kallsym.c",
    "tools/kpm.c",
    "tools/order.c",
    "tools/patch.c",
    "tools/symbol.c",
};
