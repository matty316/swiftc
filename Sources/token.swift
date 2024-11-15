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
    case semicolon
}
