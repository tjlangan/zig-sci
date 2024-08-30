const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").LinalgError;
const shape2cap = @import("shape2cap.zig").shape2cap;
const sub2ind = @import("sub2ind.zig").sub2ind;
const fill = @import("fill.zig").fill;

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        shape: []usize,
        data: []T,

        pub fn init(allocator: Allocator, shape: []const usize) Error!Self {
            const shape_copy = allocator.alloc(usize, shape.len) catch return Error.Allocation;
            @memcpy(shape_copy, shape);

            return Self{
                .shape = shape_copy,
                .data = allocator.alloc(T, shape[0] * shape[1]) catch {
                    allocator.free(shape_copy);
                    return Error.Allocation;
                },
            };
        }

        pub fn deinit(self: Self, allocator: Allocator) void {
            allocator.free(self.shape);
            allocator.free(self.data);
        }

        pub fn from(allocator: Allocator, data: []const T, shape: []const usize) Error!Self {
            // make prod and sum of slice a function
            const cap = shape2cap(shape);

            if (cap != data.len) {
                return Error.Shape;
            }

            const shape_copy = allocator.alloc(usize, shape.len) catch return Error.Allocation;
            @memcpy(shape_copy, shape);

            const data_copy = allocator.alloc(T, data.len) catch {
                allocator.free(shape_copy);
                return Error.Allocation;
            };
            @memcpy(data_copy, data);

            return Self{
                .shape = shape_copy,
                .data = data_copy,
            };
        }

        pub fn zeros(allocator: Allocator, shape: []const usize) Error!Self {
            const matrix = try init(allocator, shape);

            fill(T, matrix.data, 0);

            return matrix;
        }

        pub fn ones(allocator: Allocator, shape: []const usize) Error!Self {
            const matrix = try init(allocator, shape);

            fill(T, matrix.data, 1);

            return matrix;
        }

        pub fn eye(allocator: Allocator, n: usize) Error!Self {
            const matrix = try zeros(allocator, &.{ n, n });

            for (0..n) |ii| {
                const ind = try sub2ind(matrix.shape, &.{ ii, ii });

                matrix.data[ind] = 1;
            }

            return matrix;
        }
    };
}

test "init" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };

    const mat = try Matrix(u32).init(allocator, &shape);
    defer mat.deinit(allocator);

    try std.testing.expectEqual(2, mat.shape.len);
    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);
}

test "from" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };
    const data: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };

    const mat = try Matrix(u32).from(allocator, &data, &shape);
    defer mat.deinit(allocator);

    try std.testing.expectEqual(2, mat.shape.len);
    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);

    try std.testing.expectEqual(6, mat.data.len);
    try std.testing.expectEqual(1, mat.data[0]);
    try std.testing.expectEqual(2, mat.data[1]);
    try std.testing.expectEqual(3, mat.data[2]);
    try std.testing.expectEqual(4, mat.data[3]);
    try std.testing.expectEqual(5, mat.data[4]);
    try std.testing.expectEqual(6, mat.data[5]);
}

test "zeros" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };

    const mat = try Matrix(u32).zeros(allocator, &shape);
    defer mat.deinit(allocator);

    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);

    for (mat.data) |elem| {
        try std.testing.expectEqual(0, elem);
    }
}

test "ones" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };

    const mat = try Matrix(u32).ones(allocator, &shape);
    defer mat.deinit(allocator);

    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);

    for (mat.data) |elem| {
        try std.testing.expectEqual(1, elem);
    }
}

test "eye" {
    const allocator = std.testing.allocator;

    const mat = try Matrix(u32).eye(allocator, 3);
    defer mat.deinit(allocator);

    try std.testing.expectEqual(3, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);

    try std.testing.expectEqual(1, mat.data[0]);
    try std.testing.expectEqual(0, mat.data[1]);
    try std.testing.expectEqual(0, mat.data[2]);

    try std.testing.expectEqual(0, mat.data[3]);
    try std.testing.expectEqual(1, mat.data[4]);
    try std.testing.expectEqual(0, mat.data[5]);

    try std.testing.expectEqual(0, mat.data[6]);
    try std.testing.expectEqual(0, mat.data[7]);
    try std.testing.expectEqual(1, mat.data[8]);
}
