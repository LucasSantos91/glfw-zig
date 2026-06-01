GLFW packaged for zig.

Add to your `build.zig.zon` and obtain the module like so:

```zig
const glfw_zig = b.dependency("glfw-zig", .{
    .target = target,
    .optimize = optimize,
});
const glfw_module = glfw_zig.module("glfw-zig");
```

In your source codes, access the module as:

```zig
const glfw = @import("glfw-zig");

// Example usage
std.debug.assert(glfw.glfwInit() == glfw.GLFW_TRUE);
```

As shown in the example, all functions and macros from glfw are included exactly as in the C version.
