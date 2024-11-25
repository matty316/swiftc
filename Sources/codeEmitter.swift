//
//  codeEmitter.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

enum CodeEmitterError: Error {
    case invalidInstruction
}

class CodeEmitter {
    let program: AsmProgram
    var code = ""
    
    init(program: AsmProgram) {
        self.program = program
    }
    
    func emit() throws {
        let function = program.function
        code.append("\t.globl\t_\(function.name)\n_\(function.name):\n\tpushq\t%rbp\n\tmovq\t%rsp, %rbp\n")
        for instruction in function.instructions {
            switch instruction {
            case let mov as Mov:
                code.append("\tmovl\t\(emitOperand(mov.src)), \(emitOperand(mov.dst))\n")
            case let unary as AsmUnary:
                code.append("\t\(unary.op.type == .minus ? "negl" : "notl")\t\(emitOperand(unary.operand))\n")
            case let allocate as AllocateStack:
                code.append("\tsubq\t$\(allocate.size), %rsp\n")
            case is Ret:
                code.append("\tmovq\t%rbp, %rsp\n\tpopq\t%rbp\n\tret\n")
            case let binary as AsmBinary:
                let op: String
                switch binary.op.type {
                case .plus: op = "addl"
                case .minus: op = "subl"
                case .star: op = "imull"
                case .and: op = "andl"
                case .or: op = "orl"
                case .xor: op = "xorl"
                case .leftShift: op = "shll"
                case .rightShift: op = "shrl"
                default: throw CodeEmitterError.invalidInstruction
                }
                code.append("\t\(op)\t\(emitOperand(binary.operand1)), \(emitOperand(binary.operand2))\n")
            case let div as iDiv:
                code.append("\tidivl\t\(emitOperand(div.operand))\n")
            case is Cdq:
                code.append("\tcdq\n")
            default: break
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
