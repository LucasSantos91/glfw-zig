const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const glfw_dep = b.dependency("glfw", .{});

    const translate_glfw = b.addTranslateC(.{
        .root_source_file = b.path("src/glfw_zig.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    translate_glfw.addIncludePath(glfw_dep.path("include"));

    const glfw = translate_glfw.addModule("glfw-zig");

    glfw.addIncludePath(glfw_dep.path("include"));
    glfw.addIncludePath(glfw_dep.path("src"));
    glfw.addCSourceFiles(.{
        .root = glfw_dep.path("src"),
        .files = common_c_sources,
        .flags = c_flags,
        .language = .c,
    });

    switch (target.result.os.tag) {
        .windows => addWindowsSources(glfw, glfw_dep),
        .macos => addMacosSources(glfw, glfw_dep),
        .linux => addLinuxX11Sources(glfw, glfw_dep),
        else => @panic("glfw-zig currently supports Windows, macOS, and Linux/X11 targets"),
    }

    const tests = b.addTest(.{
        .root_module = glfw,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Build and run glfw-zig tests");
    test_step.dependOn(&run_tests.step);
}

const c_flags = &.{
    "-std=c99",
};

const common_c_sources = &.{
    "context.c",
    "init.c",
    "input.c",
    "monitor.c",
    "platform.c",
    "vulkan.c",
    "window.c",
    "egl_context.c",
    "osmesa_context.c",
    "null_init.c",
    "null_monitor.c",
    "null_window.c",
    "null_joystick.c",
};

fn addWindowsSources(glfw: *std.Build.Module, glfw_dep: *std.Build.Dependency) void {
    glfw.addCMacro("_GLFW_WIN32", "1");
    glfw.addCMacro("UNICODE", "1");
    glfw.addCMacro("_UNICODE", "1");
    glfw.addCMacro("_CRT_SECURE_NO_WARNINGS", "1");
    glfw.addCSourceFiles(.{
        .root = glfw_dep.path("src"),
        .files = &.{
            "win32_time.c",
            "win32_thread.c",
            "win32_module.c",
            "win32_init.c",
            "win32_joystick.c",
            "win32_monitor.c",
            "win32_window.c",
            "wgl_context.c",
        },
        .flags = c_flags,
        .language = .c,
    });

    glfw.linkSystemLibrary("gdi32", .{});
}

fn addMacosSources(glfw: *std.Build.Module, glfw_dep: *std.Build.Dependency) void {
    glfw.addCMacro("_GLFW_COCOA", "1");
    glfw.addCSourceFiles(.{
        .root = glfw_dep.path("src"),
        .files = &.{
            "macos_time.c",
            "posix_module.c",
            "posix_thread.c",
        },
        .flags = c_flags,
        .language = .c,
    });
    glfw.addCSourceFiles(.{
        .root = glfw_dep.path("src"),
        .files = &.{
            "cocoa_init.m",
            "cocoa_joystick.m",
            "cocoa_monitor.m",
            "cocoa_window.m",
            "nsgl_context.m",
        },
        .language = .objective_c,
    });

    glfw.linkFramework("Cocoa", .{});
    glfw.linkFramework("IOKit", .{});
    glfw.linkFramework("QuartzCore", .{});
    glfw.linkFramework("CoreFoundation", .{});
}

fn addLinuxX11Sources(glfw: *std.Build.Module, glfw_dep: *std.Build.Dependency) void {
    glfw.addCMacro("_GLFW_X11", "1");
    glfw.addCMacro("_DEFAULT_SOURCE", "1");
    glfw.addCSourceFiles(.{
        .root = glfw_dep.path("src"),
        .files = &.{
            "posix_time.c",
            "posix_thread.c",
            "posix_module.c",
            "x11_init.c",
            "x11_monitor.c",
            "x11_window.c",
            "xkb_unicode.c",
            "glx_context.c",
            "linux_joystick.c",
            "posix_poll.c",
        },
        .flags = c_flags,
        .language = .c,
    });

    glfw.linkSystemLibrary("pthread", .{});
    glfw.linkSystemLibrary("rt", .{});
    glfw.linkSystemLibrary("m", .{});
    glfw.linkSystemLibrary("dl", .{});
}
