//
//  codeGenerator.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

enum CodeGerneratorError: Error {
    case general
}

class CodeGernerator {
    let program: Program
    
    init(program: Program) {
        self.program = program
    }
    
    func generate() throws -> AsmProgram {
        return AsmProgram(function: try genFunction())
    }
    
    func genFunction() throws -> AsmFunction {
        let function = program.function
        return AsmFunction(name: function.name, instructions: try genInstructions(function: function))
    }
    
    func genInstructions(function: Function) throws -> [Instruction] {
        guard let returnStmt = function.stmt as? Return else {
            throw CodeGerneratorError.general
        }
        
        return [Mov(dest: Register(), src: try genImm(returnStmt: returnStmt)), Ret()]
    }
    
    func genImm(returnStmt: Return) throws -> Imm {
        guard let expr = returnStmt.expr as? Integer else {
            throw CodeGerneratorError.general
        }
        
        let imm = Imm(value: expr.value)
        return imm
    }
}
