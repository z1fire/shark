const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;
const Interpreter = @import("interpreter.zig").Interpreter;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (true) {
        try stdout.print("> ", .{}); // Prompt for input

        const line = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
        if (line == null or line.?.len == 0) break;
        defer allocator.free(line.?);

        var lexer = Lexer.init(line.?);
        const tokens = try lexer.tokenize();

        var parser = Parser.init(tokens);
        const ast = try parser.parse();

        var interpreter = Interpreter.init(ast);
        const result = try interpreter.evaluate();
        
        try stdout.print("{d}\n", .{result});
    }
}
