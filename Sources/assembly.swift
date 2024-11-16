//
//  assembly.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

struct AsmProgram {
    let function: AsmFunction
}

struct AsmFunction {
    let name: String
    let instructions: [Instruction]
}

protocol Instruction {}

struct Mov: Instruction {
    let dest: Operand
    let src: Operand
}

struct Ret: Instruction {}

protocol Operand {}

struct Imm: Operand {
    let value: Int
}

struct Register: Operand {}
