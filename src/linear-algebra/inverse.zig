const std = @import("std"); 

const Error = @import("errors.zig").Error; 
const at = @import("at.zig").at; 


pub fn inverse(comptime T: type, A: []T, shape: []const usize, P: []usize, IA: []T) Error!void {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;
    if (P.len != shape[0] + 1) return Error.Shape;
    if (A.len != IA.len) return Error.Shape;


    var IA_ii_jj_ptr: *T = undefined; 
    var IA_kk_jj_ptr: *T = undefined;
    var A_ii_kk_ptr: *T = undefined; 
    var A_ii_ii_ptr: *T = undefined; 
    const N = shape[0]; 

    for (0..N) |jj| {
        for (0..N) |ii| {
            
            IA_ii_jj_ptr= try at(T, IA, shape, &[_]usize{ii, jj}); 
            if (P[ii] == jj) {
                IA_ii_jj_ptr.* = 1; 
            } else {
                IA_ii_jj_ptr.* = 0; 
            }

            for (0..ii) |kk| {
                A_ii_kk_ptr = try at(T, A, shape, &[_]usize{ii, kk}); 
                IA_kk_jj_ptr = try at(T, IA, shape, &[_]usize{kk, jj});

                IA_ii_jj_ptr.* -= A_ii_kk_ptr.* * IA_kk_jj_ptr.*; 
            }
        }


        var ii: usize = N; 
        while (ii > 0) {
            ii -= 1; 

            IA_ii_jj_ptr = try at(T, IA, shape, &[_]usize{ii, jj}); 
            A_ii_ii_ptr = try at(T, A, shape, &[_]usize{ii, ii}); 

            for (ii+1..N) |kk| {
                A_ii_kk_ptr = try at(T, A, shape, &[_]usize{ii, kk}); 
                IA_kk_jj_ptr = try at(T, IA, shape, &[_]usize{kk, jj});

                IA_ii_jj_ptr.* -= A_ii_kk_ptr.* * IA_kk_jj_ptr.*; 
            }

            IA_ii_jj_ptr.* /= A_ii_ii_ptr.*;   
        }
    }
}



test "inverse 2x2" {
    const decompose = @import("decompose.zig").decompose; 
    
    var A = [_]f64{3, 5, 7, 9}; 
    const shape = [_]usize{2,2}; 
    var P = [_]usize{0} ** (shape[0]+1); 
    const tol: f64 = 0.01; 

    try decompose(f64, &A, &shape, &P, tol); 

    var IA = [_]f64{0} ** A.len; 
    try inverse(f64, &A, &shape, &P, &IA); 

    const expected = [_]f64{-9.0/8.0, 5.0/8.0, 7.0/8.0, -3.0/8.0}; 

    for (0..4) |ii| {
        try std.testing.expect(std.math.approxEqAbs(f64, expected[ii], IA[ii], 1e-6));  
    }

}



test "inverse 3x3" {
    const decompose = @import("decompose.zig").decompose; 

    var A = [_]f64{1,6,7,6,8,10,3,5,0}; 
    const shape = [_]usize{3,3}; 
    var P = [_]usize{0} ** (shape[0] + 1); 
    const tol: f64 = 0.01; 

    try decompose(f64, &A, &shape, &P, tol); 

    var IA = [_]f64{0} ** A.len; 
    try inverse(f64, &A, &shape, &P, &IA); 

    const expected = [_]f64{-25.0/86.0, 35.0/172.0, 1.0/43.0, 15.0/86.0, -21.0/172.0, 8.0/43.0, 3.0/86.0, 13.0/172.0, -7.0/43.0 };

    for (0..9) |ii| {
        try std.testing.expect(std.math.approxEqAbs(f64, expected[ii], IA[ii], 1e-6)); 
    }


}
