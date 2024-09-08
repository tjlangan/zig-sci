const std = @import("std");

const Error = @import("errors.zig").Error;

pub fn scalarSubt(comptime T: type, items: []T, value: T, shape: ?[]const usize, dim: ?usize) Error!void {
    _ = shape;
    _ = dim;

    for (items) |*elem| {
        elem.* -= value;
    }
}

test "scalarAdd" {
    var nums: [6]u32 = [_]u32{ 11, 12, 13, 14, 15, 16 };

    try scalarSubt(u32, &nums, 10, null, null);

    try std.testing.expectEqual(1, nums[0]);
    try std.testing.expectEqual(2, nums[1]);
    try std.testing.expectEqual(3, nums[2]);
    try std.testing.expectEqual(4, nums[3]);
    try std.testing.expectEqual(5, nums[4]);
    try std.testing.expectEqual(6, nums[5]);

    var nums2 = try std.testing.allocator.alloc(u32, 6);
    defer std.testing.allocator.free(nums2);

    nums2[0] = 110;
    nums2[1] = 210;
    nums2[2] = 310;
    nums2[3] = 410;
    nums2[4] = 510;
    nums2[5] = 610;

    try scalarSubt(u32, nums2, 10, null, null);

    try std.testing.expectEqual(100, nums2[0]);
    try std.testing.expectEqual(200, nums2[1]);
    try std.testing.expectEqual(300, nums2[2]);
    try std.testing.expectEqual(400, nums2[3]);
    try std.testing.expectEqual(500, nums2[4]);
    try std.testing.expectEqual(600, nums2[5]);
}
