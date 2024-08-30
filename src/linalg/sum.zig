const std = @import("std");

const Error = @import("errors.zig").LinalgError;

pub fn sum(comptime T: type, items: []const T, shape: ?[]const usize, dim: ?usize) Error!T {
    // TODO: add ability to sum along a givin dimension
    _ = shape;
    _ = dim;

    var s: T = 0;
    for (items) |elem| {
        s += elem;
    }

    return s;
}

test "1" {
    const nums: [10]u32 = [_]u32{ 1, 9, 2, 8, 3, 7, 4, 6, 5, 5 }; // 50

    const result = sum(u32, &nums, null, null);

    try std.testing.expectEqual(50, result);
}
