const std = @import("std");

const prod = @import("prod.zig").prod;

pub fn shape2cap(shape: []const usize) usize {
    if (shape.len == 0) {
        return 0;
    }

    return prod(usize, shape, null, null) catch {
        return 0;
    };
}

test "shape2capacity" {
    var cap = shape2cap(&.{ 3, 3 });
    try std.testing.expectEqual(9, cap);

    cap = shape2cap(&.{});
    try std.testing.expectEqual(0, cap);

    cap = shape2cap(&.{1});
    try std.testing.expectEqual(cap, 1);

    cap = shape2cap(&.{ 1, 2, 3, 4, 5 });
    try std.testing.expectEqual(120, cap);
}
