//
//  File.swift
//  
//
//  Created by Dave DeLong on 12/19/23.
//

import SwiftUI

public struct PartialCapsule: Shape {
    
    public var edges: HorizontalEdge.Set
    
    public init(_ edges: HorizontalEdge.Set = .all) {
        self.edges = edges
    }
    
    public func path(in rect: CGRect) -> SwiftUI.Path {
        var p = Path()
        
        let radius = rect.size.height / 2.0
        
        if edges.contains(.leading) {
            p.move(to: CGPoint(x: radius, y: 0))
        } else {
            p.move(to: CGPoint(x: 0, y: 0))
        }
        
        if edges.contains(.trailing) {
            p.addLine(to: CGPoint(x: rect.size.width - radius, y: 0))
            p.addArc(center: CGPoint(x: rect.size.width - radius, y: rect.size.height / 2), radius: radius, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
        } else {
            p.addLine(to: CGPoint(x: rect.size.width, y: 0))
            p.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        }
        
        if edges.contains(.leading) {
            p.addLine(to: CGPoint(x: radius, y: rect.size.height))
            p.addArc(center: CGPoint(x: radius, y: rect.size.height / 2), radius: radius, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: true)
        } else {
            p.addLine(to: CGPoint(x: 0, y: rect.size.height))
            p.addLine(to: CGPoint(x: 0, y: 0))
        }
        
        p.closeSubpath()
        
        return p
    }
    
}
