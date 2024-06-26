const std = @import("std");
const ASTNode = @import("parser.zig").ASTNode;

pub const Interpreter = struct {
    ast: ASTNode,

    pub fn init(ast: ASTNode) Interpreter {
        return Interpreter{
            .ast = ast,
        };
    }

    pub fn evaluate(self: *Interpreter) !i64 {
        std.debug.print("Evaluating AST\n", .{});
        return self.evaluate_node(&self.ast);
    }

    fn evaluate_node(self: *Interpreter, node: *ASTNode) !i64 {
        std.debug.print("Evaluating node type: {}\n", .{node.node_type});
        switch (node.node_type) {
            ASTNode.NodeType.Number => {
                if (node.node != .Number) {
                    std.debug.print("Invalid node type for Number: {}\n", .{node.node});
                    return error.InvalidNodeType;
                }
                std.debug.print("Number: {}\n", .{node.node.Number});
                return node.node.Number;
            },
            ASTNode.NodeType.Add,
            ASTNode.NodeType.Subtract,
            ASTNode.NodeType.Multiply,
            ASTNode.NodeType.Divide => {
                if (node.node != .BinaryOp) {
                    std.debug.print("Invalid node type for BinaryOp: {}\n", .{node.node});
                    return error.InvalidNodeType;
                }
                const left = try self.evaluate_node(node.node.BinaryOp.left);
                const right = try self.evaluate_node(node.node.BinaryOp.right);
                std.debug.print("{}: {} and {}\n", .{node.node_type, left, right});
                switch (node.node_type) {
                    ASTNode.NodeType.Add => return left + right,
                    ASTNode.NodeType.Subtract => return left - right,
                    ASTNode.NodeType.Multiply => return left * right,
                    ASTNode.NodeType.Divide => return @divTrunc(left, right),
                    else => unreachable, // Handle unexpected values
                }
            },
        }
    }
};
