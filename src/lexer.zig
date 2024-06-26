const std = @import("std");

pub const Token = union(enum) {
    Plus,
    Minus,
    Star,
    Slash,
    Number: i64,
    EOF,
};

pub const Lexer = struct {
    input: []const u8,
    pos: usize,

    pub fn init(input: []const u8) Lexer {
        return Lexer{ .input = input, .pos = 0 };
    }

    fn is_digit(c: u8) bool {
        return c >= '0' and c <= '9';
    }

    fn next_char(self: *Lexer) ?u8 {
        if (self.pos >= self.input.len) return null;
        const ch = self.input[self.pos];
        self.pos += 1;
        return ch;
    }

    fn peek_char(self: *Lexer) ?u8 {
        if (self.pos >= self.input.len) return null;
        return self.input[self.pos];
    }

    pub fn tokenize(self: *Lexer) ![]Token {
        var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
        defer tokens.deinit();

        while (true) {
            const ch = self.next_char();
            if (ch == null) break;

            switch (ch.?) {
                '+' => try tokens.append(Token.Plus),
                '-' => try tokens.append(Token.Minus),
                '*' => try tokens.append(Token.Star),
                '/' => try tokens.append(Token.Slash),
                '0'...'9' => {
                    var number: i64 = ch.? - '0';
                    while (true) {
                        const next = self.peek_char();
                        if (next == null or !is_digit(next.?)) break;
                        self.pos += 1;
                        number = number * 10 + (next.? - '0');
                    }
                    try tokens.append(Token{ .Number = number });
                },
                else => continue,
            }
        }
        try tokens.append(Token.EOF);
        return tokens.toOwnedSlice();
    }
};
