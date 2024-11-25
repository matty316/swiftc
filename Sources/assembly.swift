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
    let src: Operand
    let dst: Operand
}

struct Ret: Instruction {}

protocol Operand {}

struct Imm: Operand {
    let value: Int
}

struct Register: Operand {
    var reg: Reg
}

enum Reg: String {
    case AX = "eax"
    case DX = "edx"
    case R10 = "r10d"
    case R11 = "r11d"
    
    var extended: String {
        switch self {
        case .AX: "rax"
        case .DX: "rdx"
        case .R10: ""
        case .R11: ""
        }
    }
}

struct AsmUnary: Instruction {
    let op: Token
    let operand: Operand
}

struct AsmBinary: Instruction {
    let op: Token
    let operand1: Operand
    let operand2: Operand
}

struct iDiv: Instruction {
    let operand: Operand
}

struct Cdq: Instruction {}

struct AllocateStack: Instruction {
    let size: Int
}

struct Stack: Operand {
    let Address: Int
}

struct Pseudo: Operand {
    let indentifier: String
}
