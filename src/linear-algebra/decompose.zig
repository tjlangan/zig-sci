// https://en.wikipedia.org/wiki/LU_decomposition

const std = @import("std");

const Error = @import("errors.zig").Error;
const sub2idx = @import("sub2idx.zig").sub2idx;
const at =  @import("at.zig").at; 

pub fn decompose(comptime T: type, A: []T, shape: []const usize, P: []usize, tol: f64) Error!void {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;
    if (P.len != shape[0] + 1) return Error.Shape; 

    const N = shape[0];
    
    var absA: T = undefined; 
    var maxA: T = undefined;
    var imax: usize = undefined;

    var tmp_val: T = undefined; 
    var tmp_idx: usize = undefined; 
    var ptr: *T = undefined; 

    for (0..N+1) |ii| {
        P[ii] = ii;
    }

    for (0..N) |ii| {
        maxA = 0;
        imax = ii; 

        for (ii..N) |kk| {
            ptr = try at(T, A, shape, &[_]usize{kk, ii}); 
            absA = @abs(ptr.*); 

            if (absA > maxA) {
                maxA = absA;
                imax = kk;
            }
        }

        const maxA_f64: f64 = switch (@typeInfo(T)) {
            .Float => @floatCast(maxA),
            .Int => @floatFromInt(maxA),
            else => return Error.Unimplemented,
        };

        if (maxA_f64 < tol) return Error.Degenerate;

        if (imax != ii) {
            tmp_idx = P[ii];
            P[ii] = P[imax];
            P[imax] = tmp_idx; 

            for (0..N) |col| {
                const ii_ptr = try at(T, A, shape, &[_]usize{ii, col});
                const imax_ptr: *T = try at(T, A, shape, &[_]usize{imax, col}); 
                
                tmp_val = ii_ptr.*; 
                ii_ptr.* = imax_ptr.*; 
                imax_ptr.* = tmp_val;  
            }

            P[N] += 1; 
        }

        for (ii+1..N) |jj| {
            const A_jj_ii_ptr = try at(T, A, shape, &[_]usize{jj, ii}); 
            const A_ii_ii_ptr = try at(T, A, shape, &[_]usize{ii, ii}); 

            A_jj_ii_ptr.* /= A_ii_ii_ptr.*; 

            for (ii+1..N) |kk| {
                const A_jj_kk_ptr = try at(T, A, shape, &[_]usize{jj, kk}); 
                const A_ii_kk_ptr = try at(T, A, shape, &[_]usize{ii, kk}); 

                A_jj_kk_ptr.* -= A_jj_ii_ptr.* * A_ii_kk_ptr.*; 
            }
        }
    }
}


test "1.1" {

    var A = [_]f64{4, 3, 6, 3}; 
    const shape = [_]usize{2,2};
    var P = [_]usize{0} ** 3; 
    const tol: f64 = 0.01; 

    try decompose(f64, &A, &shape, &P, tol); 

    
    //for (0..data.len) |ii| {
    //    std.debug.print("{}\n", .{data[ii]});    
    //}

    //std.debug.print("\n", .{}); 

    //for (0..P.len) |ii| {
    //    std.debug.print("{}\n", .{P[ii]}); 
    //}

}
