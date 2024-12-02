const std = @import("std");

pub fn scalarMult(comptime T: type, items: []T, value: T) void {
    for (items) |*elem| {
        elem.* *= value;
    }
}

test "scalarMult" {
    var nums: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };

    scalarMult(u32, &nums, 6);

    try std.testing.expectEqual(6, nums[0]);
    try std.testing.expectEqual(12, nums[1]);
    try std.testing.expectEqual(18, nums[2]);
    try std.testing.expectEqual(24, nums[3]);
    try std.testing.expectEqual(30, nums[4]);
    try std.testing.expectEqual(36, nums[5]);
}
