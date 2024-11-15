//
//  swiftc.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

import ArgumentParser
import Foundation

@main
struct swiftc: ParsableCommand {
    @Argument var input: String
    @Flag var lex = false
    @Flag var parse = false
    @Flag var codegen = false
    
    func run() throws {
        preprocess()
        if lex {
            let tokens = try lexer()
        } else if parse {
            let tokens = try lexer()
            parser()
        } else if codegen {
            let tokens = try lexer()
            parser()
            emit()
        } else {
            let tokens = try lexer()
            parser()
            emit()
        }
        assemble()
    }
    
    func lexer() throws -> [Token] {
        let processed = input.replacingOccurrences(of: ".c", with: ".i")
        let url = URL(filePath: processed)
        let source = try String(contentsOf: url, encoding: .ascii)
        let lexer = Lexer(source: source)
        return try lexer.scan()
    }
    
    func parser() {
        
    }
    
    func emit() {
        
    }
    
    func preprocess() {
        let output = input.replacingOccurrences(of: ".c", with: ".i")
        shell("clang -E -P \(input) -o \(output)")
    }
    
    func assemble() {
        let assembly = input.replacingOccurrences(of: ".c", with: ".s")
        let output = input.replacingOccurrences(of: ".c", with: "")
        shell("clang \(assembly) -o \(output)")
    }
    
    @discardableResult
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}

