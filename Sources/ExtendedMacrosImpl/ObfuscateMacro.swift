//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/27/23.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MacroToolkit

struct ObfuscateMacro: ExpressionMacro {
    
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        
        guard node.argumentList.count == 1 else {
            throw MacroError("Expecting 1 argument, but got \(node.argumentList.count)")
        }
        
        let stringArg = node.argumentList.first!
        
        print(stringArg)
        
        guard let string = Expr(stringArg.expression).asStringLiteral?.value else {
            throw MacroError("Argument is not a string literal")
        }
        
        print(string)
        
        let encodedString = Data(string.utf8).base64EncodedString()
        
        return "String(base64String: \"\(raw: encodedString)\")!"
    }
    
}
