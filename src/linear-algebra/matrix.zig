const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").Error;

const _at = @import("at.zig").at; 
const decompose = @import("decompose.zig").decompose; 
const determinant = @import("determinant.zig").determinant;
const fill = @import("fill.zig").fill;
const inverse = @import("inverse.zig").inverse; 
const matrixMult = @import("matrixMult.zig").matrixMult; 
const shape2cap = @import("shape2cap.zig").shape2cap;
const sub2idx = @import("sub2idx.zig").sub2idx;

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        shape: []usize,
        data: []T,
        allocator: Allocator, 

        pub fn init(allocator: Allocator, shape: []const usize) Error!Self {
            const shape_copy = allocator.alloc(usize, shape.len) catch return Error.Allocation;
            @memcpy(shape_copy, shape);

            return Self{
                .shape = shape_copy,
                .data = allocator.alloc(T, shape[0] * shape[1]) catch {
                    allocator.free(shape_copy);
                    return Error.Allocation;
                },
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.shape);
            self.allocator.free(self.data);
        }

        pub fn from(allocator: Allocator, data: []const T, shape: []const usize) Error!Self {
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
                .allocator = allocator, 
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
                const idx = try sub2idx(matrix.shape, &.{ ii, ii });

                matrix.data[idx] = 1;
            }

            return matrix;
        }

        pub fn at(self: Self, subs: []const usize) Error!*T {
            return _at(T, self.data, self.shape, subs); 
        }

        pub fn det(self: Self) Error!T {
            const cap = shape2cap(self.shape); 

            const A = self.allocator.alloc(T, cap) catch return Error.Allocation; 
            defer self.allocator.free(A); 
            @memcpy(A, self.data); 

            const P = self.allocator.alloc(usize, self.shape[0] + 1) catch return Error.Allocation; 
            defer self.allocator.free(P); 

            const tol: f64 = 1e-3; 

            try decompose(T, A, self.shape, P, tol); 
            const val = try determinant(T, A, self.shape, P); 

            return val; 
        }

        pub fn inv(self: Self) Error!Self {
            const cap = shape2cap(self.shape); 

            const A = self.allocator.alloc(T, cap) catch return Error.Allocation; 
            defer self.allocator.free(A); 
            @memcpy(A, self.data); 

            const P = self.allocator.alloc(usize, self.shape[0] + 1) catch return Error.Allocation; 
            defer self.allocator.free(P); 

            const tol: f64 = 1e-3; 

            try decompose(T, A, self.shape, P, tol); 

            const IA = self.allocator.alloc(T, cap) catch return Error.Allocation; 
            defer self.allocator.free(IA); 
            try inverse(T, A, self.shape, P, IA); 

            return Self.from(self.allocator, IA, self.shape); 

        }

        pub fn mult(self: Self, other: Self) Error!Self {
            const new_data = try matrixMult(T, self.allocator, self.data, self.shape, other.data, other.shape); 
            defer self.allocator.free(new_data); 
            
            const new_mat = try Self.from(self.allocator, new_data, &[_]usize{self.shape[0], other.shape[1]}); 

            return new_mat; 
        }


        // NEED TO IMPLEMENT
        // matrix mult
        // scalar add
        // scalar subt
        // scalar mult
        // scalar div
        // sum 
        // prod
        // solve
    };
}

test "init" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };

    const mat = try Matrix(u32).init(allocator, &shape);
    defer mat.deinit();

    try std.testing.expectEqual(2, mat.shape.len);
    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);
}

test "from" {
    const allocator = std.testing.allocator;

    const shape: [2]usize = [_]usize{ 2, 3 };
    const data: [6]u32 = [_]u32{ 1, 2, 3, 4, 5, 6 };

    const mat = try Matrix(u32).from(allocator, &data, &shape);
    defer mat.deinit();

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
    defer mat.deinit();

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
    defer mat.deinit();

    try std.testing.expectEqual(2, mat.shape[0]);
    try std.testing.expectEqual(3, mat.shape[1]);

    for (mat.data) |elem| {
        try std.testing.expectEqual(1, elem);
    }
}

test "eye" {
    const allocator = std.testing.allocator;

    const mat = try Matrix(u32).eye(allocator, 3);
    defer mat.deinit();

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

test "at" {
    const allocator = std.testing.allocator; 

    const mat = try Matrix(u32).eye(allocator, 2); 
    defer mat.deinit(); 

    var ptr: *u32 = undefined; 

    ptr = try mat.at(&[_]usize{0, 0}); 
    try std.testing.expectEqual(mat.data[0], ptr.*); 

    ptr = try mat.at(&[_]usize{0, 1}); 
    try std.testing.expectEqual(mat.data[1], ptr.*); 

    ptr = try mat.at(&[_]usize{1,0}); 
    try std.testing.expectEqual(mat.data[2], ptr.*); 

    ptr = try mat.at(&[_]usize{1,1}); 
    try std.testing.expectEqual(mat.data[3], ptr.*); 
}

test "determinant" {
    const allocator = std.testing.allocator; 

    const data = [_]f64{3, 8, 4, 6}; 

    const mat = try Matrix(f64).from(allocator, &data, &[_]usize{2,2}); 
    defer mat.deinit(); 

    const det = try mat.det(); 

    try std.testing.expectEqual(-14, det); 
}

test "inverse" {
    const allocator = std.testing.allocator; 

    const data = [_]f64{3, 8, 4, 6}; 

    const mat = try Matrix(f64).from(allocator, &data, &[_]usize{2,2}); 
    defer mat.deinit(); 

    const imat = try mat.inv(); 
    defer imat.deinit(); 

    try std.testing.expect(std.math.approxEqAbs(f64, -3.0/7.0, imat.data[0], 1e-6)); 
    try std.testing.expect(std.math.approxEqAbs(f64, 4.0/7.0, imat.data[1], 1e-6)); 
    try std.testing.expect(std.math.approxEqAbs(f64, 2.0/7.0, imat.data[2], 1e-6)); 
    try std.testing.expect(std.math.approxEqAbs(f64, -3.0/14.0, imat.data[3], 1e-6)); 
}

test "matrix mult" {
    const allocator = std.testing.allocator; 

    const A = try Matrix(f64).from(allocator, &[_]f64{1,2,3,4,5,6}, &[_]usize{2,3}); 
    defer A.deinit(); 

    const B = try Matrix(f64).from(allocator, &[_]f64{7,8,9,10,11,12}, &[_]usize{3,2}); 
    defer B.deinit(); 

    const C = try A.mult(B); 
    defer C.deinit(); 

    try std.testing.expectEqual(2, C.shape[0]);
    try std.testing.expectEqual(2, C.shape[1]); 
    try std.testing.expectEqual(4, C.data.len); 

    try std.testing.expectEqual(58, C.data[0]);
    try std.testing.expectEqual(64, C.data[1]);
    try std.testing.expectEqual(139, C.data[2]);
    try std.testing.expectEqual(154, C.data[3]);
}
