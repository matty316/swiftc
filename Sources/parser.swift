//
//  parser.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

enum ParserError: Error {
    case invalidToken(Token)
}

class Parser {
    let tokens: [Token]
    var position = 0
    var peek: Token { tokens[position] }
    var prev: Token { tokens[position - 1] }
    var isAtEnd: Bool { position >= tokens.count }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> Program {
        let function = try parseFunction()
        try consume(tokenType: .eof)
        
        return Program(function: function)
    }
    
    func parseFunction() throws -> Function {
        try consume(tokenType: .intKeyword)
        let ident = try parseIdentifier()
        try consume(tokenType: .leftParen)
        try consume(tokenType: .voidKeyword)
        try consume(tokenType: .rightParen)
        try consume(tokenType: .leftBrace)
        let stmt = try parseStatement()
        try consume(tokenType: .rightBrace)
        
        return Function(name: ident.name, stmt: stmt)
    }
    
    func parseIdentifier() throws -> Ident {
        let token = try consume(tokenType: .ident)
        return Ident(name: token.lexeme)
    }
    
    func parseStatement() throws -> Stmt {
        try consume(tokenType: .returnKeyword)
        let expr = try parseExpression(0)
        try consume(tokenType: .semicolon)
        
        return Return(expr: expr)
    }
    
    func parseExpression(_ minPrecedence: Int) throws -> Expr {
        var left = try parseFactor()
        var next = peek
        while isBinaryToken(next.type) && precedence(next.type) >= minPrecedence {
            advance()
            let op = prev
            let right = try parseExpression(precedence(next.type) + 1)
            left = Binary(op: op, left: left, right: right)
            next = peek
        }
        return left
    }

    func isBinaryToken(_ t: TokenType) -> Bool {
        t == .plus ||
        t == .minus ||
        t == .star ||
        t == .slash ||
        t == .percent ||
        t == .and ||
        t == .xor ||
        t == .or ||
        t == .leftShift ||
        t == .rightShift
    }
    
    func precedence(_ t: TokenType) -> Int {
        switch t {
        case .star, .slash, .percent: 50
        case .plus, .minus: 45
        case .leftShift, .rightShift: 40
        case .and: 30
        case .xor: 25
        case .or: 20
        default: 0
        }
    }
    
    func parseFactor() throws -> Expr {
        if match(tokenTypes: [.tilde, .minus]) {
            let op = prev
            let right = try parseFactor()
            return Unary(op: op, right: right)
        }
        return try parsePrimary()
    }
    
    func parsePrimary() throws -> Expr {
        if match(tokenTypes: [.constant]) {
            let constant = prev
            guard let integer = Int(constant.lexeme) else {
                throw ParserError.invalidToken(prev)
            }
            return Integer(value: integer)
        } else if match(tokenTypes: [.leftParen]) {
            let inner = try parseExpression(0)
            try consume(tokenType: .rightParen)
            return inner
        }
        throw ParserError.invalidToken(peek)
    }
    
    @discardableResult
    func advance() -> Token {
        if !isAtEnd { position += 1 }
        return prev
    }
    
    func check(tokenType: TokenType) -> Bool {
        if isAtEnd { return false }
        return peek.type == tokenType
    }
    
    func match(tokenTypes: [TokenType]) -> Bool {
        for tokenType in tokenTypes {
            if check(tokenType: tokenType) {
                advance()
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func consume(tokenType: TokenType) throws -> Token {
        if check(tokenType: tokenType) {
            return advance()
        }
        throw ParserError.invalidToken(peek)
    }
}
