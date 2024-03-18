// Copyright (C) 2024 ryu. All rights reserved. MIT license.
const std = @import("std");
const mem = std.mem;
const testing = std.testing;

pub const Glob = struct {
    glob: []const u8,
    len: usize,
    fn init(glob: []const u8) Glob {
        return Glob{ .glob = glob, .len = glob.len };
    }
    fn match(self: Glob, string: []const u8) bool {
        var globIndex: usize = 0;
        var stringIndex: usize = 0;
        while (globIndex < self.len and stringIndex < string.len) {
            if (self.glob[globIndex] == '*') {
                if (globIndex + 1 < self.len and self.glob[globIndex + 1] == string[stringIndex]) {
                    globIndex += 2;
                }
                stringIndex += 1;
            } else if (self.glob[globIndex] == '?') {
                globIndex += 1;
                stringIndex += 1;
            } else if (self.glob[globIndex] == string[stringIndex]) {
                globIndex += 1;
                stringIndex += 1;
            } else {
                return false;
            }
        }
        return (globIndex == self.len and stringIndex == string.len) or (globIndex < self.len and self.glob[globIndex] == '*');
    }
};

test "glob match" {
    const g = Glob.init("ziglob");
    try testing.expect(g.match("ziglob"));
    try testing.expect(!g.match("ziglobyesterday"));
}

test "glob match with *" {
    const g = Glob.init("zig*");
    try testing.expect(g.match("zig"));
    try testing.expect(g.match("ziglob"));
    try testing.expect(!g.match("yesterdayziglob"));
}

test "glob match with * and more at the start" {
    const g = Glob.init("zig*lob");
    try testing.expect(g.match("ziglob"));
    try testing.expect(g.match("zigtommorowlob"));
    try testing.expect(!g.match("ziglobyesterday"));
}

test "glob match with * and more at the end" {
    const g = Glob.init("*ziglob");
    try testing.expect(g.match("ziglob"));
    try testing.expect(g.match("tommorowziglob"));
    try testing.expect(!g.match("ziglobyesterday"));
}

test "glob match with ?" {
    const g = Glob.init("zig?lob");
    try testing.expect(g.match("zigalob"));
    try testing.expect(g.match("zigblob"));
    try testing.expect(!g.match("ziglob"));
    try testing.expect(!g.match("ziglobyesterday"));
}

test "glob match with ? and more" {
    const g = Glob.init("zig??lob");
    try testing.expect(g.match("zig12lob"));
    try testing.expect(!g.match("zig1lob"));
}
