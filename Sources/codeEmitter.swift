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
        code.append("\t.globl\t_\(function.name)\n_\(function.name):\n\tpushq\t%rbp\n\tmovq\t%rsp, %rbp\n")
        for instruction in function.instructions {
            if let mov = instruction as? Mov {
                code.append("\tmovl\t\(emitOperand(mov.src)), \(emitOperand(mov.dest))\n")
            } else if let _ = instruction as? Ret {
                code.append("\tmovq\t%rbp, %rsp\n\tpopq\t%rbp\n\tret\n")
            } else if let unary = instruction as? AsmUnary {
                code.append("\t\(unary.op.type == .minus ? "negl" : "notl")\t\(emitOperand(unary.operand))\n")
            } else if let allocate = instruction as? AllocateStack {
                code.append("\tsubq\t$\(allocate.size), %rsp\n")
            }
        }
    }
    
    func emitOperand(_ operand: Operand) -> String {
        if let reg = operand as? Register {
            return "%\(reg.reg.rawValue)"
        } else if let imm = operand as? Imm {
            return "$\(imm.value)"
        } else if let stack = operand as? Stack {
            return "\(stack.Address)(%rbp)"
        }
        return ""
    }
}
