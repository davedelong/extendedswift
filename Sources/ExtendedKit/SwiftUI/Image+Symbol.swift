//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/5/23.
//

import Foundation
import SwiftUI

extension Symbol: View {
    
    public var body: some View {
        Image(symbol: self)
    }
    
}

extension Image {
    
    public init(symbol: Symbol) {
        switch symbol.sourceProvider() {
            case .systemName(let sf):
                self.init(systemName: sf)
            case .named(let name, let bundle):
                self.init(name, bundle: bundle)
            case .image(let img):
                self.init(platformImage: img)
            case .imageView(let imgView):
                self = imgView
        }
    }
    
    public init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
    
}
