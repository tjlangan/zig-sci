const std = @import("std");

const Error = @import("errors.zig").Error;
const at = @import("at.zig").at;
const decompose = @import("decompose.zig").decompose;

pub fn determinant(comptime T: type, A: []T, shape: []const usize, P: []usize) Error!T {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;
    if (P.len != shape[0] + 1) return Error.Shape;

    var ptr: *T = undefined;
    var det: T = undefined;
    const N = shape[0];

    ptr = try at(T, A, shape, &[_]usize{ 0, 0 });
    det = ptr.*;

    for (1..N) |ii| {
        ptr = try at(T, A, shape, &[_]usize{ ii, ii });
        det *= ptr.*;
    }

    if ((P[N] - N) % 2 == 0) {
        return det;
    } else {
        return -1 * det;
    }
}

test "decompose 2x2" {
    var A = [_]f64{ 4, 3, 6, 3 };
    const shape = [_]usize{ 2, 2 };
    var P = [_]usize{0} ** 3;
    const tol: f64 = 0.01;

    try decompose(f64, &A, &shape, &P, tol);
    const det = try determinant(f64, &A, &shape, &P);

    try std.testing.expectEqual(-6, det);
}

test "decompose 3x3" {
    var A = [_]f64{ 1, 2, 3, 3, 2, 1, 2, 1, 3 };
    const shape = [_]usize{ 3, 3 };
    var P = [_]usize{0} ** 4;
    const tol: f64 = 0.01;

    try decompose(f64, &A, &shape, &P, tol);
    const det = try determinant(f64, &A, &shape, &P);

    try std.testing.expectEqual(-12, det);
}
