const std = @import("std"); 

const Error = @import("errors.zig").Error; 
const at = @import("at.zig").at; 


pub fn solve(comptime T: type, A: []T, shape: []const usize, P: []usize, b: []T, x: []T) Error!void {
    if (shape.len != 2) return Error.Shape;
    if (shape[0] != shape[1]) return Error.NotSquare;
    if (P.len != shape[0] + 1) return Error.Shape;
    if (b.len != x.len) return Error.Shape; 
    if (b.len != shape[0]) return Error.Shape; 

    const N = shape[0]; 

    var ptr: *T = undefined; 

    for (0..N) |ii| {
        x[ii] = b[P[ii]]; 

        for (0..ii) |kk| {
            ptr = try at(T, A, shape, &[_]usize{ii, kk}); 

            x[ii] -= ptr.* * x[kk]; 
        }
    }

    var ii: usize = N; 
    while (ii > 0) {
        ii -= 1; 

        for (ii+1..N) |kk| {
            ptr = try at(T, A, shape, &[_]usize{ii, kk}); 

            x[ii] -= ptr.* * x[kk]; 
        }

        ptr = try at(T, A, shape, &[_]usize{ii, ii}); 

        x[ii] /= ptr.*; 
    }
    
}

test "solve 2x2" {
    const decompose = @import("decompose.zig").decompose; 
    
    var A = [_]f64{1, 1, 2, 1}; 
    const shape = [_]usize{2,2}; 
    var P = [_]usize{0} ** (shape[0] + 1); 

    try decompose(f64, &A, &shape, &P, 1e-3); 

    var b = [_]f64{0, 1}; 
    var x = [_]f64{0} ** shape[0]; 

    try solve(f64, &A, &shape, &P, &b, &x); 

    const expected = [_]f64{1, -1}; 

    for (0..2) |ii| {
        try std.testing.expect(std.math.approxEqAbs(f64, expected[ii], x[ii], 1e-6)); 
    }

}


test "solve 3x3" {
    const decompose = @import("decompose.zig").decompose; 
    
    var A = [_]f64{-1, -11, -3, 1, 1, 0, 2, 5, 1}; 
    const shape = [_]usize{3,3}; 
    var P = [_]usize{0} ** (shape[0] + 1); 

    try decompose(f64, &A, &shape, &P, 1e-3);

    var b = [_]f64{-37, -1, 10}; 
    var x = [_]f64{0} ** shape[0]; 

    try solve(f64, &A, &shape, &P, &b, &x); 

    const expected = [_]f64{-3, 2, 6}; 

    for (0..3) |ii| {
        try std.testing.expect(std.math.approxEqAbs(f64, expected[ii], x[ii], 1e-6)); 
    }


}
