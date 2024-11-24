const std = @import("std");
const Allocator = std.mem.Allocator;

// LU

const Error = @import("errors.zig").Error;
const sub2idx = @import("sub2idx.zig").sub2idx;
const at =  @import("at.zig").at; 

pub fn decompose(comptime T: type, allocator: Allocator, M: []T, shape: []const usize, tol: f64) Error![]usize {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;

    const N = shape[0];
    const P = allocator.alloc(usize, N) catch return Error.Allocation;


    for (0..N) |ii| {
        P[ii] = ii;
    }

    for (0..N) |ii| {
        var abs_M: T = 0;
        var max_M: T = 0;
        var idx_max: usize = ii;

        for (ii..N) |kk| {
            const idx = try sub2idx(shape, &.{ kk, ii });
            abs_M = @abs(M[idx]);

            if (abs_M > max_M) {
                max_M = abs_M;
                idx_max = kk;
            }
        }

        const max_M_f64: f64 = switch (@typeInfo(T)) {
            .Float => @floatCast(max_M),
            .Int => @floatFromInt(max_M),
            else => return Error.Unimplemented,
        };

        if (max_M_f64 < tol) return Error.Degenerate;

        if (idx_max != ii) {
            const tmp: usize = P[ii];
            P[ii] = idx_max;
            P[idx_max] = tmp;

            //const row_start = []usize{ ii, 0 };
            //const row_end = []usize{ ii, shape[1] - 1 };

            //const row_start_idx = try sub2idx(shape, row_start);
            //const row_end_idx = try sub2idx(shape, row_end);

            //_ = row_start_idx;
            //_ = row_end_idx;

            const row_a = [_]usize{ ii, 0 };
            const row_b = [_]usize{ idx_max, 0 };

            const row_a_idx = try sub2idx(shape, &row_a);
            const row_b_idx = try sub2idx(shape, &row_b);

            for (0..shape[1]) |offset| {
                const tmp2: T = M[row_a_idx + offset];
                M[row_a_idx + offset] = M[row_b_idx + offset];
                M[row_b_idx + offset] = tmp2;
            }

            P[N] += 1; 
        }

        for (ii+1..N) |jj| {
            const sub_jj_ii = [_]usize{ jj, ii}; 
            const sub_ii_ii = [_]usize{ ii, ii}; 

            const M_jj_ii_ptr = try at(T, M, shape, &sub_jj_ii); 
            const M_ii_ii_ptr = try at(T, M, shape, &sub_ii_ii); 

            M_jj_ii_ptr.* /= M_ii_ii_ptr.*; 

            for (ii+1..N) |kk| {
                const sub_jj_kk = [_]usize{ jj, kk}; 
                const sub_ii_kk = [_]usize{ ii, kk}; 

                const M_jj_kk_ptr = try at(T, M, shape, &sub_jj_kk); 
                const M_ii_kk_ptr = try at(T, M, shape, &sub_ii_kk); 

                M_jj_kk_ptr.* -= M_jj_ii_ptr.* * M_ii_kk_ptr.*; 
            }
        }
    }

    return P; 
}


test "1.1" {
    const allocator = std.testing.allocator;

    var data = [_]f64{4, 3, 6, 3}; 
    const shape = [_]usize{2,2};
    const tol: f64 = 0.01; 

    const P = try decompose(f64, allocator, &data, &shape, tol); 
    defer allocator.free(P); 

    for (0..data.len) |ii| {
        std.debug.print("{}\n", .{data[ii]});    
    }

}
