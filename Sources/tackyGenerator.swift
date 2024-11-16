//
//  tackyGenerator.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

enum TackyError: Error {
    case invalidStatement
}

class TackyGenerator {
    let program: Program
    var instructions = [TackyInstruction]()
    var count = 0
    
    init(program: Program) {
        self.program = program
    }
    
    func emit() throws -> TackyProgram {
        return TackyProgram(function: try parseFunction())
    }
    
    func parseFunction() throws -> TackyFunction {
        let function = program.function
        return TackyFunction(name: function.name, instructions: try parseInstructions())
    }
    
    func parseInstructions() throws -> [TackyInstruction] {
        if let stmt = program.function.stmt as? Return {
            instructions.append(TackyReturn(value: try parseVal(expr: stmt.expr)))
        }
        
        return instructions
    }
    
    func parseVal(expr: Expr) throws -> TackyValue {
        if let constant = expr as? Integer {
            return TackyConstant(value: constant.value)
        } else if let unary = expr as? Unary {
            let src = try parseVal(expr: unary.right)
            let dst_name = makeTemp()
            let dst = TackyVar(name: dst_name)
            let op = unary.op
            instructions.append(TackyUnary(op: op, src: src, dest: dst))
            return dst
        }
        throw TackyError.invalidStatement
    }
    
    func makeTemp() -> String {
        let name = "Var.Temp\(count)"
        count += 1
        return name
    }
}
