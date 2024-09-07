const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").Error;
const sub2idx = @import("sub2idx.zig").sub2idx;

pub fn matrixMult(comptime T: type, allocator: Allocator, A: []const T, shapeA: []const usize, B: []const T, shapeB: []const usize) Error![]T {
    // TODO: Implement n dimension matrix multiplication. currently only supports 2D
    if (shapeA.len != 2 or shapeB.len != 2) return Error.Unimplemented;

    if (shapeA[1] != shapeB[0]) return Error.Shape;

    const n = shapeA[0];
    const m = shapeA[1];
    const p = shapeB[1];

    var C = allocator.alloc(T, n * p) catch {
        return Error.Allocation;
    };

    const shapeC = [_]usize{ n, p };

    for (0..n) |ii| {
        for (0..p) |jj| {
            var sum: T = 0;
            for (0..m) |kk| {
                const subA = [_]usize{ ii, kk };
                const subB = [_]usize{ kk, jj };

                const idxA = try sub2idx(shapeA, &subA);
                const idxB = try sub2idx(shapeB, &subB);

                sum += A[idxA] * B[idxB];
            }

            const subC = [_]usize{ ii, jj };
            const idxC = try sub2idx(&shapeC, &subC);

            C[idxC] = sum;
        }
    }

    return C;
}

test "2x3 * 3x2" {
    // A =  | 1,  2,  3|
    //      | 4,  5,  6|
    //
    // B =  | 7,  8|
    //      | 9, 10|
    //      |11, 12|
    //
    // C =  | 58,  64|
    //      |139, 154|

    const A = [_]u32{ 1, 2, 3, 4, 5, 6 };
    const shapeA = [_]usize{ 2, 3 };

    const B = [_]u32{ 7, 8, 9, 10, 11, 12 };
    const shapeB = [_]usize{ 3, 2 };

    const C = try matrixMult(u32, std.testing.allocator, &A, &shapeA, &B, &shapeB);
    defer std.testing.allocator.free(C);

    try std.testing.expectEqual(4, C.len);

    try std.testing.expectEqual(58, C[0]);
    try std.testing.expectEqual(64, C[1]);
    try std.testing.expectEqual(139, C[2]);
    try std.testing.expectEqual(154, C[3]);
}

test "1x3 * 3x1" {
    // A =  |1, 2, 3|
    //
    // B =  |4|
    //      |5|
    //      |6|
    //
    // C =  |32|

    const A = [_]u32{ 1, 2, 3 };
    const shapeA = [_]usize{ 1, 3 };

    const B = [_]u32{ 4, 5, 6 };
    const shapeB = [_]usize{ 3, 1 };

    const C = try matrixMult(u32, std.testing.allocator, &A, &shapeA, &B, &shapeB);
    defer std.testing.allocator.free(C);

    try std.testing.expectEqual(1, C.len);
    try std.testing.expectEqual(32, C[0]);
}

test "3x1 * 1x3" {
    // A =  |1|
    //      |2|
    //      |3|
    //
    // B = |4, 5, 6|
    //
    // C =  |  4,  5,  6|
    //      |  8, 10, 12|
    //      | 12, 15, 18|

    const A = [_]u32{ 1, 2, 3 };
    const shapeA = [_]usize{ 3, 1 };

    const B = [_]u32{ 4, 5, 6 };
    const shapeB = [_]usize{ 1, 3 };

    const C = try matrixMult(u32, std.testing.allocator, &A, &shapeA, &B, &shapeB);
    defer std.testing.allocator.free(C);

    try std.testing.expectEqual(9, C.len);

    try std.testing.expectEqual(4, C[0]);
    try std.testing.expectEqual(5, C[1]);
    try std.testing.expectEqual(6, C[2]);
    try std.testing.expectEqual(8, C[3]);
    try std.testing.expectEqual(10, C[4]);
    try std.testing.expectEqual(12, C[5]);
    try std.testing.expectEqual(12, C[6]);
    try std.testing.expectEqual(15, C[7]);
    try std.testing.expectEqual(18, C[8]);
}

test "errors" {
    // test with dims greater than 2
    var C = matrixMult(u32, std.testing.allocator, &.{1}, &.{ 1, 1, 1 }, &.{1}, &.{ 1, 1, 1 });
    try std.testing.expectError(Error.Unimplemented, C);

    // test if dimension are correct for multiplication
    C = matrixMult(u32, std.testing.allocator, &.{ 1, 2, 3, 4, 5, 6 }, &.{ 3, 2 }, &.{ 1, 2, 3, 4, 5, 6 }, &.{ 3, 2 });
    try std.testing.expectError(Error.Shape, C);
}
