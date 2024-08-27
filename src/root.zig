//pub const matrix = @import("linalg/matrix.zig").Matrix;
pub const errors = @import("linalg/errors.zig").LinalgError;

pub const sub2ind = @import("linalg/sub2ind.zig").sub2ind;
pub const shape2cap = @import("linalg/shape2cap.zig").shape2cap;
pub const mult = @import("linalg/mult.zig").mult;
pub const at = @import("linalg/at.zig").at;

test {
    @import("std").testing.refAllDeclsRecursive(@This());
}
