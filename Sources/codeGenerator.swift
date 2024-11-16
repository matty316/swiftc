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
        return try genValidProgram(invalidProgram)
    }
    
    func replacePseudoregisters(_ pseudoProgram: AsmProgram) throws -> AsmProgram {
        let function = pseudoProgram.function
        let instructions = try function.instructions.map { instruction -> Instruction in
            if let mov  = instruction as? Mov {
                let dest = mov.dest
                let src = mov.src
                
                return Mov(dest: convertPsuedoReg(dest), src: convertPsuedoReg(src))
            } else if let unary = instruction as? AsmUnary {
                let dest = unary.operand
                return AsmUnary(op: unary.op, operand: convertPsuedoReg(dest))
            } else if let ret = instruction as? Ret {
                return ret
            }
            throw CodeGerneratorError.general
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
                instructions.append(Mov(dest: Register(reg: .AX), src: try genOperand(returnStmt.value)))
                instructions.append(Ret())
            } else if let instruction = instruction as? TackyUnary {
                instructions.append(Mov(dest: try genOperand(instruction.dest), src: try genOperand(instruction.src)))
                instructions.append(AsmUnary(op: instruction.op, operand: try genOperand(instruction.dest)))
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
        if mov.src is Stack && mov.dest is Stack {
            let mov1 = Mov(dest: Register(reg: .R10), src: mov.src)
            let mov2 = Mov(dest: mov.dest, src: Register(reg: .R10))
            return [mov1, mov2]
        }
        return [mov]
    }
}
