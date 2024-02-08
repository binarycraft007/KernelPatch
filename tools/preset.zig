const KP_MAGIC = "KP1158";
const MAGIC_LEN = 0x8;
const KP_HEADER_SIZE = 0x40;
const SUPER_KEY_LEN = 0x40;
const HDR_BACKUP_SIZE = 0x8;
const COMPILE_TIME_LEN = 0x18;
const MAP_MAX_SIZE = 0xa00;
const HOOK_ALLOC_SIZE = 1 << 20;
const MEMORY_ROX_SIZE = 2 << 20;
const MEMORY_RW_SIZE = 2 << 20;
const MAP_ALIGN = 0x10;

const CONFIG_DEBUG = 0x1;
const CONFIG_ANDROID = 0x2;

const MAP_SYMBOL_NUM = 5;
const MAP_SYMBOL_SIZE = MAP_SYMBOL_NUM * 8;

const PATCH_SYMBOL_LEN = 512;

const PATCH_EXTRA_ITEM_LEN = 64;

pub fn version(major: usize, minor: usize, patch: usize) usize {
    return (major << 16) + (minor << 8) + patch;
}
