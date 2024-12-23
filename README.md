# zig-sci

Zig is al library for scientific / engineering based computing. 
Inspiration for this library is from SciPy,Numpy, and MATLAB 

Personally not a fan of a matrix as an array of pointers to arrays, so my implementation is a single contiguous array with an associated "shape" attribute. Shape is a usize array stating the length of that dimension. For example a 2x3 matrix would have a shape of {2,3}. Matrix is stored in row major order. 

Also prefer that functions have no knowledge of custom types, but that custom types can provide abstraction and convenience over functions. 

I will work on documentation eventially... 

## Installation
Probably easiest to just clone the repo

in your build.zig.zon
```zig
.dependencies = {
    .zig_sci = .{
        "/path_to_local_copy", 
    }, 
}
```
in you build.zig
```zig
const zig_sci_dependency = b.dependency("zig_sci", .{
    .target = target; 
    .optimize = optimize
});

exe.root_module.addImport("zig-sci", zig_sci_dependency.module("zig-sci")); 
```
## Usage
Example to find the inverse of a matrix 
```zig 
const zs = @import("zig-sci"); 
const Matrix = zs.linearAlgebra.Matrix; 

var gpa = std.heap.GeneralPurposeAllocator(.{}){}; 
const allocator = gpa.allocator(); 

const data = [_]f64{1,2,3,4}; 
const shape = [_]usize(2,2}; 
const A = try Matrix(f64).from(allocator, &data, &shape); 
defer A.deinit(); 

const IA = try A.inv(); 
defer IA.deinit(); 
```

## Contributing

Read the ideas.txt for roadmap of future features to be added. Any and all suggestions welcome!

(any ideas on error handling or plotting would be much appreciated (really trying to avoid reinventing matplotlib))


## License

[The Unlicense](https://unlicense.org/)
