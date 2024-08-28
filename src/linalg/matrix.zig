const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").LinalgError;

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
            var prod: usize = 1;
            for (shape) |len| {
                prod *= len;
            }
            if (prod != data.len) {
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
