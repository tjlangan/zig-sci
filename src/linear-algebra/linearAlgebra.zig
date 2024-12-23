const std = @import("std");

// Enums
pub const Error = @import("errors.zig").Error;

// Data Types
pub const Matrix = @import("matrix.zig").Matrix;

// Functions
pub const at = @import("at.zig").at;
pub const decompose = @import("decompose.zig").decompose;
pub const determinant = @import("determinant.zig").determinant; 
pub const fill = @import("fill.zig").fill;
pub const inverse = @import("inverse.zig").inverse; 
pub const matrixMult = @import("matrixMult.zig").matrixMult;
pub const prod = @import("prod.zig").prod;
pub const scalarAdd = @import("scalarAdd.zig").scalarAdd;
pub const scalarDiv = @import("scalarDiv.zig").scalarDiv;
pub const scalarMult = @import("scalarMult.zig").scalarMult;
pub const scalarSubt = @import("scalarSubt.zig").scalarSubt;
pub const shape2cap = @import("shape2cap.zig").shape2cap;
pub const solve = @import("solve.zig").solve; 
pub const sub2idx = @import("sub2idx.zig").sub2idx;
pub const sum = @import("sum.zig").sum;

test {
    std.testing.refAllDeclsRecursive(@This());
}
