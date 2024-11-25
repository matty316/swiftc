//
//  token.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

struct Token {
    let type: TokenType
    let lexeme: String
    let line: Int
}

enum TokenType: String {
    case semicolon, ident, tilde, minus, plus, star, slash, percent, minusMinus, constant, intKeyword, voidKeyword, returnKeyword, leftParen, rightParen, leftBrace, rightBrace, eof, and, or, xor, leftShift, rightShift, lessThan, greaterThan
}
