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
    let program: TackyProgram
    var pseudoRegs = [String: Stack]()
    var stackAddr = 4
    
    init(program: TackyProgram) {
        self.program = program
    }
    
    func generate() throws -> AsmProgram {
        let pseudoProgram = AsmProgram(function: try genFunction())
        let invalidProgram = try replacePseudoregisters(pseudoProgram)
        let valid = try genValidProgram(invalidProgram)
        return valid
    }
    
    func replacePseudoregisters(_ pseudoProgram: AsmProgram) throws -> AsmProgram {
        let function = pseudoProgram.function
        let instructions = function.instructions.map { instruction -> Instruction in
            if let mov  = instruction as? Mov {
                let dst = mov.dst
                let src = mov.src
                return Mov(src: convertPsuedoReg(src), dst: convertPsuedoReg(dst))
            } else if let unary = instruction as? AsmUnary {
                let dst = unary.operand
                return AsmUnary(op: unary.op, operand: convertPsuedoReg(dst))
            } else if let binary = instruction as? AsmBinary {
                let src1 = binary.operand1
                let src2 = binary.operand2
                return AsmBinary(op: binary.op, operand1: convertPsuedoReg(src1), operand2: convertPsuedoReg(src2))
            } else if let div = instruction as? iDiv {
                let src = div.operand
                return iDiv(operand: convertPsuedoReg(src))
            }
            return instruction
        }
        return AsmProgram(function: AsmFunction(name: function.name, instructions: instructions))
    }
    
    func genValidProgram(_ invalidProgram: AsmProgram) throws -> AsmProgram {
        let function = invalidProgram.function
        var instructions = function.instructions
        instructions.insert(AllocateStack(size: stackAddr - 4), at: 0)
        let updatedInstructions = instructions.flatMap { instruction -> [Instruction] in
            if let mov = instruction as? Mov {
                return convertMov(mov)
            } else if let div = instruction as? iDiv {
                var updated = [Instruction]()
                updated.append(Mov(src: div.operand, dst: Register(reg: .R10)))
                updated.append(iDiv(operand: Register(reg: .R10)))
                return updated
            } else if let binary = instruction as? AsmBinary {
                return convertBinary(binary)
            } else {
                return [instruction]
            }
        }
        return AsmProgram(function: AsmFunction(name: function.name, instructions: updatedInstructions))
    }
    
    func genFunction() throws -> AsmFunction {
        let function = program.function
        return AsmFunction(name: function.name, instructions: try genInstructions(function: function))
    }
    
    func genInstructions(function: TackyFunction) throws -> [Instruction] {
        var instructions = [Instruction]()
        for instruction in function.instructions {
            if let returnStmt = instruction as? TackyReturn {
                instructions.append(Mov(src: try genOperand(returnStmt.value), dst: Register(reg: .AX)))
                instructions.append(Ret())
            } else if let instruction = instruction as? TackyUnary, instruction.op.type == .minus || instruction.op.type == .tilde {
                instructions.append(Mov(src: try genOperand(instruction.src), dst: try genOperand(instruction.dst)))
                instructions.append(AsmUnary(op: instruction.op, operand: try genOperand(instruction.dst)))
            } else if let instruction = instruction as? TackyBinary {
                instructions.append(contentsOf: try genBinary(binary: instruction))
            } else {
                throw CodeGerneratorError.general
            }
        }
        
        return instructions
    }
    
    func genOperand(_ val: TackyValue) throws -> Operand {
        if let tackyVar = val as? TackyVar {
            return Pseudo(indentifier: tackyVar.name)
        } else if let tackyConstant = val as? TackyConstant {
            return Imm(value: tackyConstant.value)
        }
        throw CodeGerneratorError.general
    }
    
    func convertPsuedoReg(_ reg: Operand) -> Operand {
        guard let pseudo = reg as? Pseudo else {
            return reg
        }
        
        let name = pseudo.indentifier
        if let stack = pseudoRegs[name] {
            return stack
        } else {
            let stack = Stack(Address: -stackAddr)
            pseudoRegs[name] = stack
            stackAddr += 4
            return stack
        }
    }
    
    func convertMov(_ mov: Mov) -> [Mov] {
        if mov.src is Stack && mov.dst is Stack {
            let mov1 = Mov(src: mov.src, dst: Register(reg: .R10))
            let mov2 = Mov(src: Register(reg: .R10), dst: mov.dst)
            return [mov1, mov2]
        }
        return [mov]
    }
    
    func convertBinary(_ binary: AsmBinary) -> [Instruction] {
        var instructions = [Instruction]()
        switch binary.op.type {
        case .star:
            if binary.operand2 is Stack {
                instructions.append(Mov(src: binary.operand2, dst: Register(reg: .R11)))
                instructions.append(AsmBinary(op: binary.op, operand1: binary.operand1, operand2: Register(reg: .R11)))
                instructions.append(Mov(src: Register(reg: .R11), dst: binary.operand2))
            }
        default:
            if binary.operand1 is Stack && binary.operand2 is Stack {
                instructions.append(Mov(src: binary.operand1, dst: Register(reg: .R10)))
                instructions.append(AsmBinary(op: binary.op, operand1: Register(reg: .R10), operand2: binary.operand2))
            } else {
                return [binary]
            }
        }
        return instructions
    }
    
    func genBinary(binary: TackyBinary) throws -> [Instruction] {
        var instructions = [Instruction]()
        switch binary.op.type {
        case .slash, .percent:
                let src1 = try genOperand(binary.src1)
                let src2 = try genOperand(binary.src2)
                let dst = try genOperand(binary.dst)
                instructions.append(Mov(src: src1, dst: Register(reg: .AX)))
                instructions.append(Cdq())
                instructions.append(iDiv(operand: src2))
                instructions.append(Mov(src: Register(reg: binary.op.type == .slash ? .AX : .DX), dst: dst))
        case .plus, .minus, .star, .and, .or, .xor:
            instructions.append(Mov(src: try genOperand(binary.src1), dst: try genOperand(binary.dst)))
            instructions.append(AsmBinary(op: binary.op,
                                          operand1: try genOperand(binary.src2),
                                          operand2: try genOperand(binary.dst)))
        case .leftShift, .rightShift:
            instructions.append(Mov(src: try genOperand(binary.src1), dst: try genOperand(binary.dst)))
            instructions.append(AsmBinary(op: binary.op,
                                          operand1: try genOperand(binary.src2),
                                          operand2: try genOperand(binary.dst)))
        default: throw CodeGerneratorError.general
        }
        
        return instructions
    }
}
