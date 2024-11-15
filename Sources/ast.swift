//
//  ast.swift
//  swiftc
//
//  Created by Matthew Reed on 11/15/24.
//

protocol Stmt {}
protocol Expr {}

struct Program {
    let function: Function
}

struct Function: Stmt {
    let ident: Ident
    let stmt: Stmt
}

struct Return: Stmt {
    let expr: Expr
}

struct Ident: Expr {
    let name: String
}

struct Integer: Expr {
    let value: Int
}
