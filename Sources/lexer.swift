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
    var peek: Character { source[position] }
    var isAtEnd: Bool { position == source.endIndex }
    
    init(source: String) {
        self.source = source
        self.position = source.startIndex
        self.start = source.startIndex
    }
    
    func scan() throws -> [Token] {
        let tokens = [Token]()
        
        while !isAtEnd {
            start = position
            let c = advance()
            
            switch c {
            default: throw LexerError.invalidCharacter
            }
        }
        
        return tokens
    }
    
    func advance() -> Character {
        if isAtEnd { return "\0" }
        let c = source[position]
        position = source.index(after: position)
        return c
    }
}
