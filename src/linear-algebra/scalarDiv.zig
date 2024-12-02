const std = @import("std");

pub fn scalarDiv(comptime T: type, items: []T, value: T) void {
    for (items) |*elem| {
        elem.* /= value;
    }
}

test "scalarMult" {
    var nums: [6]u32 = [_]u32{ 6, 12, 18, 24, 30, 36 };

    scalarDiv(u32, &nums, 6);

    try std.testing.expectEqual(1, nums[0]);
    try std.testing.expectEqual(2, nums[1]);
    try std.testing.expectEqual(3, nums[2]);
    try std.testing.expectEqual(4, nums[3]);
    try std.testing.expectEqual(5, nums[4]);
    try std.testing.expectEqual(6, nums[5]);
}
