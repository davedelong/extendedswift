//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

#if !os(macOS)

import SwiftUI
import UIKit

public struct InterfaceOrientationContainer<Content: View>: View {
    
    private let content: Content
    
    public init(@ViewBuilder view: () -> Content) {
        self.content = view()
    }
    
    public var body: some View {
        _InterfaceOrientationContainer(content: content)
    }
    
}

private struct _InterfaceOrientationContainer<Content: View>: UIViewControllerRepresentable {
    
    let content: Content
    
    func makeUIViewController(context: Context) -> UIInterfaceHostingController<Content> {
        return UIInterfaceHostingController(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIInterfaceHostingController<Content>, context: Context) {
        
    }
}


#endif
