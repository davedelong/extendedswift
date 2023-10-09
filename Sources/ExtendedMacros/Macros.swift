//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/15/23.
//

import Foundation

@freestanding(expression)
public macro obfuscate(_ string: String) -> String = #externalMacro(module: "ExtendedMacrosImpl", type: "ObfuscateMacro")

@freestanding(declaration)
public macro todo(_ string: String) = #externalMacro(module: "ExtendedMacrosImpl", type: "DiagnosticMacro")

@freestanding(declaration)
public macro info(_ string: String) = #externalMacro(module: "ExtendedMacrosImpl", type: "DiagnosticMacro")

@freestanding(declaration)
public macro note(_ string: String) = #externalMacro(module: "ExtendedMacrosImpl", type: "DiagnosticMacro")
