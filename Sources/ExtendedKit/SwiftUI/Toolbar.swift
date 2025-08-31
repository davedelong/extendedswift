//
//  Toolbar.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/31/25.
//

import SwiftUI

extension View {
    
    public func toolbarItem<V: View>(placement: ToolbarItemPlacement, @ViewBuilder content: () -> V) -> some View {
        self.toolbar {
            ToolbarItem(placement: placement, content: content)
        }
    }
    
}
