//
//  tackyAst.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

struct TackyProgram {
    let function: TackyFunction
}

struct TackyFunction {
    let name: String
    let instructions: [TackyInstruction]
}

protocol TackyInstruction {}

struct TackyReturn: TackyInstruction {
    let value: TackyValue
}

struct TackyUnary: TackyInstruction {
    let op: Token
    let src: TackyValue
    let dst: TackyValue
}

struct TackyBinary: TackyInstruction {
    let op: Token
    let src1: TackyValue
    let src2: TackyValue
    let dst: TackyValue
}

protocol TackyValue {}

struct TackyConstant: TackyValue {
    let value: Int
}

struct TackyVar: TackyValue {
    let name: String
}
