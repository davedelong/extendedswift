//
//  File.swift
//
//
//  Created by Dave DeLong on 12/13/23.
//

import SwiftUI

extension View {
    
    public func alert<V, Message: View, Actions: View>(_ titleKey: LocalizedStringKey, item: Binding<V?>, @ViewBuilder message: (V) -> Message, @ViewBuilder actions: (V) -> Actions) -> some View {
        self.alert(titleKey, isPresented: item.isNotNull(), actions: {
            if let value = item.wrappedValue {
                actions(item.wrappedValue!)
            }
        }, message: {
            if let value = item.wrappedValue {
                message(item.wrappedValue!)
            }
        })
    }
    
}
