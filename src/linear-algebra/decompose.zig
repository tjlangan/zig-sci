const std = @import("std");
const Allocator = std.mem.Allocator;

const Error = @import("errors.zig").Error;
const sub2idx = @import("sub2idx.zig").sub2idx;

pub fn decompose(comptime T: type, allocator: Allocator, M: []T, shape: []const usize, tol: ?f64) Error![]T {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;

    const N = shape[0];
    const P = allocator.alloc(usize, N) catch return Error.Allocation;

    for (0..N) |ii| {
        P[ii] = ii;

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

            const row_start = []usize{ ii, 0 };
            const row_end = []usize{ ii, shape[1] - 1 };

            const row_start_idx = try sub2idx(shape, row_start);
            const row_end_idx = try sub2idx(shape, row_end);

            _ = row_start_idx;
            _ = row_end_idx;
        }
    }
}
