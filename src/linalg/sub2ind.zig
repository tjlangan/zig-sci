const std = @import("std");

const Error = @import("errors.zig").LinalgError;

pub fn sub2ind(shape: []const usize, subscripts: []const usize) Error!usize {
    if (shape.len != subscripts.len) return Error.Shape;

    var index: usize = 0;
    var stride: usize = 1;

    for (0..subscripts.len) |ii| {
        if (subscripts[ii] >= shape[ii]) {
            return Error.OutOfBounds;
        }

        index += subscripts[subscripts.len - 1 - ii] * stride;
        stride *= shape[shape.len - 1 - ii];
    }

    return index;
}

test "2x3" {
    // |1, 2, 3|
    // |4, 5, 6|
    //
    const x = [_]u32{ 1, 2, 3, 4, 5, 6 };
    const shape = [_]usize{ 2, 3 };

    // [0,0] = x[0] = 1
    var subscripts = [_]usize{ 0, 0 };
    var index: usize = try sub2ind(&shape, &subscripts);
    try std.testing.expectEqual(0, index);
    try std.testing.expectEqual(1, x[index]);
    try std.testing.expectEqual(2, shape[0]);
    try std.testing.expectEqual(3, shape[1]);
    try std.testing.expectEqual(0, subscripts[0]);
    try std.testing.expectEqual(0, subscripts[1]);

    // [1,2] = x[5] = 6
    subscripts = [_]usize{ 1, 2 };
    index = try sub2ind(&shape, &subscripts);
    try std.testing.expectEqual(5, index);
    try std.testing.expectEqual(6, x[index]);
    try std.testing.expectEqual(2, shape[0]);
    try std.testing.expectEqual(3, shape[1]);
    try std.testing.expectEqual(1, subscripts[0]);
    try std.testing.expectEqual(2, subscripts[1]);
}

test "2x3x4" {
    // page 0   | 1,  2,  3,  4|
    //          | 5,  6,  7,  8|
    //          | 9, 10, 11, 12|
    //
    // page 1   |13, 14, 15, 16|
    //          |17, 18, 19, 20|
    //          |21, 22, 23, 24|

    const x = [_]u32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 };
    const shape = [_]usize{ 2, 3, 4 };

    var subscripts = [_]usize{ 0, 0, 0 };
    var index: usize = try sub2ind(&shape, &subscripts);
    try std.testing.expectEqual(0, index);
    try std.testing.expectEqual(1, x[index]);
    try std.testing.expectEqual(2, shape[0]);
    try std.testing.expectEqual(3, shape[1]);
    try std.testing.expectEqual(4, shape[2]);
    try std.testing.expectEqual(0, subscripts[0]);
    try std.testing.expectEqual(0, subscripts[1]);
    try std.testing.expectEqual(0, subscripts[2]);

    subscripts = [_]usize{ 1, 2, 3 };
    index = try sub2ind(&shape, &subscripts);
    try std.testing.expectEqual(23, index);
    try std.testing.expectEqual(24, x[index]);
    try std.testing.expectEqual(2, shape[0]);
    try std.testing.expectEqual(3, shape[1]);
    try std.testing.expectEqual(4, shape[2]);
    try std.testing.expectEqual(1, subscripts[0]);
    try std.testing.expectEqual(2, subscripts[1]);
    try std.testing.expectEqual(3, subscripts[2]);

    subscripts = [_]usize{ 1, 1, 0 };
    index = try sub2ind(&shape, &subscripts);
    try std.testing.expectEqual(16, index);
    try std.testing.expectEqual(17, x[index]);
    try std.testing.expectEqual(2, shape[0]);
    try std.testing.expectEqual(3, shape[1]);
    try std.testing.expectEqual(4, shape[2]);
    try std.testing.expectEqual(1, subscripts[0]);
    try std.testing.expectEqual(1, subscripts[1]);
    try std.testing.expectEqual(0, subscripts[2]);
}

test "1x6" {
    const x = [_]u32{ 1, 2, 3, 4, 5, 6 };
    const shape = [_]usize{ 1, 6 };

    const subs = [_]usize{ 0, 3 };
    const index: usize = try sub2ind(&shape, &subs);
    try std.testing.expectEqual(3, index);
    try std.testing.expectEqual(4, x[index]);
    try std.testing.expectEqual(1, shape[0]);
    try std.testing.expectEqual(6, shape[1]);
    try std.testing.expectEqual(0, subs[0]);
    try std.testing.expectEqual(3, subs[1]);
}

test "2x2" {
    const x = [_]u32{ 2, 4, 6, 8 };
    const shape = [_]usize{ 2, 2 };

    const index: usize = try sub2ind(&shape, &.{ 0, 0 });
    try std.testing.expectEqual(0, index);
    try std.testing.expectEqual(2, x[index]);
}

test "errors" {
    // test dims and inds mismatch length
    var result = sub2ind(&.{ 0, 0 }, &.{ 0, 0, 0 });
    try std.testing.expectError(Error.Shape, result);

    result = sub2ind(&.{ 2, 3 }, &.{ 2, 3 });
    try std.testing.expectError(Error.OutOfBounds, result);
}
