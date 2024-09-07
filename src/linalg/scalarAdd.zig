const std = @import("std");

const Error = @import("errors.zig").Error;

pub fn scalarAdd(comptime T: type, items: []T, value: T, shape: ?[]const usize, dim: ?usize) Error!void {
    _ = shape;
    _ = dim;

    for (items) |*elem| {
        elem.* += value;
    }
}

test "scalarAdd" {
    var nums: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };

    try scalarAdd(u32, &nums, 10, null, null);

    try std.testing.expectEqual(11, nums[0]);
    try std.testing.expectEqual(12, nums[1]);
    try std.testing.expectEqual(13, nums[2]);
    try std.testing.expectEqual(14, nums[3]);
    try std.testing.expectEqual(15, nums[4]);
    try std.testing.expectEqual(16, nums[5]);

    var nums2 = try std.testing.allocator.alloc(u32, 6);
    defer std.testing.allocator.free(nums2);

    nums2[0] = 100;
    nums2[1] = 200;
    nums2[2] = 300;
    nums2[3] = 400;
    nums2[4] = 500;
    nums2[5] = 600;

    try scalarAdd(u32, nums2, 10, null, null);

    try std.testing.expectEqual(110, nums2[0]);
    try std.testing.expectEqual(210, nums2[1]);
    try std.testing.expectEqual(310, nums2[2]);
    try std.testing.expectEqual(410, nums2[3]);
    try std.testing.expectEqual(510, nums2[4]);
    try std.testing.expectEqual(610, nums2[5]);
}
