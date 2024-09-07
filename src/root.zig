const std = @import("std");

pub const linalg = @import("linalg/linalg.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}
