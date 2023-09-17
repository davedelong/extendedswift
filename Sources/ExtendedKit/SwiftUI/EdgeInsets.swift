//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/7/23.
//

import SwiftUI

extension EdgeInsets {
    
    public static var zero: EdgeInsets { EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0) }
    
    public init(horizontal: CGFloat) {
        self.init(horizontal: horizontal, vertical: 0)
    }
    
    public init(vertical: CGFloat) {
        self.init(horizontal: 0, vertical: vertical)
    }
    
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
    
}
