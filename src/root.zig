const std = @import("std");

pub const linearAlgebra = @import("linear-algebra/linearAlgebra.zig");

test {
    std.testing.refAllDeclsRecursive(@This());
}
