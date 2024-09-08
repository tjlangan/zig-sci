const std = @import("std");

pub fn fill(comptime T: type, items: []T, value: T) void {
    @memset(items, value);
}

test "fill" {
    const A = try std.testing.allocator.alloc(u32, 5);
    defer std.testing.allocator.free(A);

    fill(u32, A, 27);
    for (A) |elem| {
        try std.testing.expectEqual(27, elem);
    }
}
