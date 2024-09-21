const std = @import("std");

pub fn main() void {
    std.debug.print("It's working\n", .{});
}

test "should pass" {
    try std.testing.expect(true);
}

test "should fail" {
    try std.testing.expect(false);
}
