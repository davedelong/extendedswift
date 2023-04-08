//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import SwiftUI

extension View {
    
    public func enabled(_ isEnabled: Bool) -> some View {
        disabled(!isEnabled)
    }
    
}

