const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").LinalgError;

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        shape: []const usize,
        data: []T,

        fn init(allocator: Allocator, shape: []const usize) Error!Self {
            return Self{
                .shape = shape,
                .data = try allocator.alloc(T, 1),
            };
        }

        fn deinit(self: Self, allocator: Allocator) void {
            allocator.free(self);
        }
    };
}
