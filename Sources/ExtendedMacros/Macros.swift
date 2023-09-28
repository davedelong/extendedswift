//
//  File.swift
//  
//
//  Created by Dave DeLong on 9/15/23.
//

import Foundation

@freestanding(expression)
public macro obfuscate(_ string: String) -> String = #externalMacro(module: "ExtendedMacrosImpl", type: "ObfuscateMacro")

