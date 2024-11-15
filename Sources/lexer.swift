//
//  lexer.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

import Foundation

enum LexerError: Error {
    case invalidCharacter
}

class Lexer {
    let source: String
    var position: String.Index
    var start: String.Index
    var line = 1
    var peek: Character { source[position] }
    var isAtEnd: Bool { position == source.endIndex }
    var tokens = [Token]()
    var keywords: [String: TokenType] = [
        "int": .intKeyword,
        "return": .returnKeyword,
        "void": .voidKeyword
    ]
    
    init(source: String) {
        self.source = source
        self.position = source.startIndex
        self.start = source.startIndex
    }
    
    func scan() throws {
        while !isAtEnd {
            start = position
            let c = advance()
            
            switch c {
            case "(": addToken(tokenType: .leftParen)
            case ")": addToken(tokenType: .rightParen)
            case "{": addToken(tokenType: .leftBrace)
            case "}": addToken(tokenType: .rightBrace)
            case ";": addToken(tokenType: .semicolon)
            case " ", "\t", "\r": break
            case "\n": line += 1
            default:
                if c.isLetter || c == "_" {
                    ident()
                } else if c.isNumber {
                    try number()
                } else {
                    throw LexerError.invalidCharacter
                }
            }
        }
        addToken(tokenType: .eof)
    }
    
    func addToken(tokenType: TokenType) {
        let token = Token(type: tokenType, lexeme: tokenType.rawValue, line: line)
        tokens.append(token)
    }
    
    
    @discardableResult
    func advance() -> Character {
        if isAtEnd { return "\0" }
        let c = source[position]
        position = source.index(after: position)
        return c
    }
    
    func ident() {
        while peek.isLetter || peek.isNumber || peek == "_" {
            advance()
        }
        
        let ident = String(source[start..<position])
        if let keyword = keywords[ident] {
            let token = Token(type: keyword, lexeme: ident, line: line)
            tokens.append(token)
        } else {
            let token = Token(type: .ident, lexeme: ident, line: line)
            tokens.append(token)
        }
    }
    
    func number() throws {
        while peek.isNumber {
            advance()
        }
        
        if peek.isLetter {
            throw LexerError.invalidCharacter
        }
        
        let number = String(source[start..<position])
        let token = Token(type: .constant, lexeme: number, line: line)
        tokens.append(token)
    }
}
