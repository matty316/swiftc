//
//  codeEmitter.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

class CodeEmitter {
    let program: AsmProgram
    var code = ""
    
    init(program: AsmProgram) {
        self.program = program
    }
    
    func emit() {
        let function = program.function
        code.append("\t.globl _\(function.name)\n_\(function.name):\n")
        for instruction in function.instructions {
            if let mov = instruction as? Mov {
                code.append("\tmovl \(emitOperand(mov.src)), \(emitOperand(mov.dest))\n")
            } else if let _ = instruction as? Ret {
                code.append("\tret\n")
            }
        }
    }
    
    func emitOperand(_ operand: Operand) -> String {
        if let _ = operand as? Register {
            return "%eax"
        } else if let imm = operand as? Imm {
            return "$\(imm.value)"
        }
        return ""
    }
}
