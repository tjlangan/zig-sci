const std = @import("std");

const Error = @import("errors.zig").Error;

pub fn prod(comptime T: type, items: []const T, shape: ?[]const usize, dim: ?usize) Error!T {
    // TODO: add ability to get product along a givin dimension
    _ = shape;
    _ = dim;

    var p: T = 1;
    for (items) |elem| {
        p *= elem;
    }

    return p;
}

test "1" {
    const nums: [10]u32 = [_]u32{ 1, 9, 2, 8, 3, 7, 4, 6, 5, 5 }; // 1814400

    const result = prod(u32, &nums, null, null);

    try std.testing.expectEqual(1814400, result);
}
