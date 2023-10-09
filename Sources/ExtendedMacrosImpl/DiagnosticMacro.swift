//
//  File.swift
//  
//
//  Created by Dave DeLong on 10/9/23.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import MacroToolkit

struct DiagnosticMacro: DeclarationMacro {
    
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let macroName: TokenSyntax = node.macro
        
        guard case .identifier(let name) = macroName.tokenKind else {
            throw MacroError("Invalid macro syntax")
        }
        
        let prefix: String
        let severity: DiagnosticSeverity
        if name == "todo" {
            prefix = "TODO"
            severity = .warning
        } else if name == "info" {
            prefix = "INFO"
            severity = .warning
        } else if name == "note" {
            prefix = "NOTE"
            severity = .warning
        } else {
            throw MacroError("Invalid macro name: '\(name)'")
        }
        
        return try self.diagnostic(of: severity, prefix: prefix, for: node, in: context)
    }
    
    private static func diagnostic(of severity: DiagnosticSeverity,
                                   prefix: String,
                                   for node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
                                   in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [DeclSyntax] {
        
        guard node.argumentList.count == 1 else {
            throw MacroError("Expecting 1 argument, but got \(node.argumentList.count)")
        }
        
        let stringArg = node.argumentList.first!
        
        guard let string = Expr(stringArg.expression).asStringLiteral?.value else {
            throw MacroError("Argument is not a string literal")
        }
        
        var idBits = [prefix.lowercased()]
        if let loc = context.location(of: node) {
            idBits.append(loc.file.description)
            idBits.append(loc.line.description)
            idBits.append(loc.column.description)
        }
        let id = idBits.joined(separator: "-")
        let message = SimpleDiagnosticMessage(message: "\(prefix): \(string)",
                                              diagnosticID: .init(domain: "ExtendedSwift", id: id),
                                              severity: severity)
        
        let diag = Diagnostic(node: node, position: nil, message: message)
        context.diagnose(diag)
        return ["()"]
    }
}

