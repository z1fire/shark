const std = @import("std");
const Token = @import("lexer.zig").Token;

pub const ASTNode = struct {
    pub const NodeType = enum {
        Number,
        Add,
        Subtract,
        Multiply,
        Divide,
    };

    pub const Node = union(enum) {
        Number: i64,
        BinaryOp: struct {
            left: *ASTNode,
            right: *ASTNode,
        },
    };

    node_type: NodeType,
    node: Node,

    pub fn number(value: i64) ASTNode {
        return ASTNode{
            .node_type = .Number,
            .node = .{ .Number = value },
        };
    }

    pub fn binary_op(node_type: NodeType, left: *ASTNode, right: *ASTNode) ASTNode {
        return ASTNode{
            .node_type = node_type,
            .node = .{ .BinaryOp = .{ .left = left, .right = right } },
        };
    }
};

pub const Parser = struct {
    tokens: []Token,
    pos: usize,

    pub fn init(tokens: []Token) Parser {
        return Parser{
            .tokens = tokens,
            .pos = 0,
        };
    }

    fn next_token(self: *Parser) Token {
        if (self.pos >= self.tokens.len) return Token.EOF;
        const token = self.tokens[self.pos];
        self.pos += 1;
        return token;
    }

    fn peek_token(self: *Parser) Token {
        if (self.pos >= self.tokens.len) return Token.EOF;
        return self.tokens[self.pos];
    }

    pub fn parse(self: *Parser) !ASTNode {
        return self.parse_expression();
    }

    fn parse_expression(self: *Parser) !ASTNode {
        var left = try self.parse_term();
        while (true) {
            const token = self.peek_token();
            switch (token) {
                Token.Plus => {
                    _ = self.next_token();
                    var right = try self.parse_term();
                    left = self.create_binary_op_node(ASTNode.NodeType.Add, &left, &right);
                },
                Token.Minus => {
                    _ = self.next_token();
                    var right = try self.parse_term();
                    left = self.create_binary_op_node(ASTNode.NodeType.Subtract, &left, &right);
                },
                else => break,
            }
        }
        return left;
    }

    fn parse_term(self: *Parser) !ASTNode {
        var left = try self.parse_factor();
        while (true) {
            const token = self.peek_token();
            switch (token) {
                Token.Star => {
                    _ = self.next_token();
                    var right = try self.parse_factor();
                    left = self.create_binary_op_node(ASTNode.NodeType.Multiply, &left, &right);
                },
                Token.Slash => {
                    _ = self.next_token();
                    var right = try self.parse_factor();
                    left = self.create_binary_op_node(ASTNode.NodeType.Divide, &left, &right);
                },
                else => break,
            }
        }
        return left;
    }

    fn parse_factor(self: *Parser) !ASTNode {
        const token = self.next_token();
        switch (token) {
            Token.Number => {
                std.debug.print("Creating number node: {}\n", .{token.Number});
                return ASTNode.number(token.Number);
            },
            else => return error.InvalidToken,
        }
    }

    fn create_binary_op_node(self: *Parser, node_type: ASTNode.NodeType, left: *ASTNode, right: *ASTNode) ASTNode {
        _ = self; // autofix
        const left_ptr: *ASTNode = std.heap.page_allocator.create(ASTNode) catch unreachable;
        left_ptr.* = left.*;
        const right_ptr: *ASTNode = std.heap.page_allocator.create(ASTNode) catch unreachable;
        right_ptr.* = right.*;
        std.debug.print("Creating {} node: {} and {}\n", .{node_type, left_ptr, right_ptr});
        return ASTNode.binary_op(node_type, left_ptr, right_ptr);
    }
};
