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
            _ = try lexer()
        } else if parse {
            let tokens = try lexer()
            _ = try parser(tokens: tokens)
        } else if codegen {
            let tokens = try lexer()
            let program = try parser(tokens: tokens)
            _ = try gen(program: program)
        } else {
            let tokens = try lexer()
            let program = try parser(tokens: tokens)
            let asm = try gen(program: program)
            try emit(asm: asm)
        }
        assemble()
    }
    
    func lexer() throws -> [Token] {
        let processed = input.replacingOccurrences(of: ".c", with: ".i")
        let url = URL(filePath: processed)
        let source = try String(contentsOf: url, encoding: .ascii)
        let lexer = Lexer(source: source)
        try lexer.scan()
        return lexer.tokens
    }
    
    func parser(tokens: [Token]) throws -> Program {
        let parser = Parser(tokens: tokens)
        return try parser.parse()
    }
    
    func gen(program: Program) throws -> AsmProgram {
        let codeGenerator = CodeGernerator(program: program)
        return try codeGenerator.generate()
    }
    
    func emit(asm: AsmProgram) throws {
        let codeEmitter = CodeEmitter(program: asm)
        codeEmitter.emit()
        let output = input.replacingOccurrences(of: ".c", with: ".s")
        try codeEmitter.code.write(toFile: output, atomically: true, encoding: .ascii)
    }
    
    func preprocess() {
        let output = input.replacingOccurrences(of: ".c", with: ".i")
        print(shell("clang -E -P \(input) -o \(output)"))
    }
    
    func assemble() {
        let assembly = input.replacingOccurrences(of: ".c", with: ".s")
        let output = input.replacingOccurrences(of: ".c", with: "")
        print(shell("clang \(assembly) -o \(output)"))
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

