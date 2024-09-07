const std = @import("std");

const Error = @import("errors.zig").Error;

pub fn scalarMult(comptime T: type, items: []T, value: T, shape: ?[]const usize, dim: ?usize) Error!void {
    _ = shape;
    _ = dim;

    for (items) |*elem| {
        elem.* *= value;
    }
}

test "scalarMult" {
    var nums: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };

    try scalarMult(u32, &nums, 6, null, null);

    try std.testing.expectEqual(6, nums[0]);
    try std.testing.expectEqual(12, nums[1]);
    try std.testing.expectEqual(18, nums[2]);
    try std.testing.expectEqual(24, nums[3]);
    try std.testing.expectEqual(30, nums[4]);
    try std.testing.expectEqual(36, nums[5]);
}
