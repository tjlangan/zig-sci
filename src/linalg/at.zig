const std = @import("std");

const Error = @import("errors.zig").LinalgError;
const sub2ind = @import("sub2ind.zig").sub2ind;

pub fn at(comptime T: type, items: []T, shape: []const usize, subs: []const usize) Error!*T {
    const index = try sub2ind(shape, subs);
    return &items[index];
}

test "1x6" {
    var x: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };
    const shape: []const usize = &[_]usize{ 1, 6 };
    var subs: []const usize = &[_]usize{ 0, 0 };

    const elem = try at(u32, x[0..], shape, subs);

    try std.testing.expectEqual(1, elem.*);
    try std.testing.expectEqual(1, shape[0]);
    try std.testing.expectEqual(6, shape[1]);
    try std.testing.expectEqual(0, subs[0]);
    try std.testing.expectEqual(0, subs[1]);

    subs = &[_]usize{ 1, 0 };
    var err = at(u32, x[0..], shape, subs);

    try std.testing.expectError(Error.OutOfBounds, err);
    try std.testing.expectEqual(1, shape[0]);
    try std.testing.expectEqual(6, shape[1]);
    try std.testing.expectEqual(1, subs[0]);
    try std.testing.expectEqual(0, subs[1]);

    subs = &[_]usize{ 0, 0, 0 };
    err = at(u32, x[0..], shape, subs);

    try std.testing.expectError(Error.Shape, err);
    try std.testing.expectEqual(1, shape[0]);
    try std.testing.expectEqual(6, shape[1]);
    try std.testing.expectEqual(0, subs[0]);
    try std.testing.expectEqual(0, subs[1]);
    try std.testing.expectEqual(0, subs[2]);
}

test "struct" {
    const S = struct {
        shape: []const usize,
        data: []u32,
    };

    var x = [_]u32{ 1, 2, 3, 4, 5, 6 };
    const s = S{ .shape = &[_]usize{ 2, 3 }, .data = x[0..] };

    var subs: []const usize = &[_]usize{ 0, 0 };
    var elem = try at(u32, s.data, s.shape, subs);

    try std.testing.expectEqual(1, elem.*);
    try std.testing.expectEqual(2, s.shape[0]);
    try std.testing.expectEqual(3, s.shape[1]);

    subs = &[_]usize{ 1, 1 };
    elem = try at(u32, s.data, s.shape, subs);

    try std.testing.expectEqual(5, elem.*);
    try std.testing.expectEqual(2, s.shape[0]);
    try std.testing.expectEqual(3, s.shape[1]);

    const y: []u32 = try std.testing.allocator.alloc(u32, 6);
    defer std.testing.allocator.free(y);

    @memcpy(y, &x);

    const t = S{ .shape = &[_]usize{ 2, 3 }, .data = y };

    subs = &[_]usize{ 0, 0 };
    elem = try at(u32, t.data, t.shape, subs);

    try std.testing.expectEqual(1, elem.*);
    try std.testing.expectEqual(2, t.shape[0]);
    try std.testing.expectEqual(3, t.shape[1]);

    subs = &[_]usize{ 1, 1 };
    elem = try at(u32, t.data, t.shape, subs);

    try std.testing.expectEqual(5, elem.*);
    try std.testing.expectEqual(2, t.shape[0]);
    try std.testing.expectEqual(3, t.shape[1]);
}
