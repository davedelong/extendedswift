//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/15/23.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ExtendedMacrosImplPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObfuscateMacro.self,
        DiagnosticMacro.self,
    ]
}
