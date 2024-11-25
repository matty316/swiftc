//
//  Test.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

import Testing
@testable import swiftc

struct Test {

    @Test func parseBinary() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let source = """
int main(void) {
    return 1 - 2 - 3;
}
"""
        let lexer = Lexer(source: source)
        try lexer.scan()
        let tokens = lexer.tokens
        let parser = Parser(tokens: tokens)
        let program = try parser.parse()
        let stmt = program.function.stmt as! Return
        let expr = stmt.expr as! Binary
        let right = expr.right as! Integer
        #expect(right.value == 3)
        let left = expr.left as! Binary
        let leftLeft = left.left as! Integer
        let leftRigth = left.right as! Integer
        #expect(leftLeft.value == 1)
        #expect(leftRigth.value == 2)
    }

}
