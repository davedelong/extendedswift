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
    
    public func frame(_ rect: CGRect) -> some View {
        self.frame(width: rect.size.width, height: rect.height)
            .position(rect.center)
    }
    
    public func frame(size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    public func padding(leading: CGFloat) -> some View {
        self.padding(.leading, leading)
    }
    
    public func padding(trailing: CGFloat) -> some View {
        self.padding(.trailing, trailing)
    }
    
    public func padding(top: CGFloat) -> some View {
        self.padding(.top, top)
    }
    
    public func padding(bottom: CGFloat) -> some View {
        self.padding(.bottom, bottom)
    }
    
    public func padding(horizontal: CGFloat) -> some View {
        self.padding(.horizontal, horizontal)
    }
    
    public func padding(vertical: CGFloat) -> some View {
        self.padding(.vertical, vertical)
    }
    
    public func padding(horizontal: CGFloat, vertical: CGFloat) -> some View {
        self.padding(EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }
    
    public func frame(size: CGSize, alignment: Alignment) -> some View {
        self.frame(width: size.width, height: size.height, alignment: alignment)
    }
    
    public func alignment(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    public func whenAligned(to verticalAlignment: VerticalAlignment, use guide: VerticalAlignment, offset: CGFloat = 0) -> some View {
        self.alignmentGuide(verticalAlignment, computeValue: { $0[guide] + offset })
    }
    
    public func whenAligned(to horizontalAlignment: HorizontalAlignment, use guide: HorizontalAlignment, offset: CGFloat = 0) -> some View {
        self.alignmentGuide(horizontalAlignment, computeValue: { $0[guide] + offset })
    }
    
    public func whenAligned(to alignment: Alignment, use guide: Alignment, offset: CGSize = .zero) -> some View {
        self.alignmentGuide(alignment.horizontal, computeValue: { $0[guide.horizontal] + offset.width })
            .alignmentGuide(alignment.vertical, computeValue: { $0[guide.vertical] + offset.height })
    }
}

extension View {
    
    public func readFrame(in coordinateSpace: CoordinateSpace = .local, onChange: @escaping (CGRect) -> Void) -> some View {
        let deduper = Deduper<CGRect>(action: onChange)
        return self.overlay(GeometryReader { proxy in
            Color.clear.id(UUID()).onAppear { deduper.report(proxy.frame(in: coordinateSpace)) }
        })
    }
    
    public func readOrigin(in coordinateSpace: CoordinateSpace = .local, onChange: @escaping (CGPoint) -> Void) -> some View {
        return self.readFrame(in: coordinateSpace, onChange: { onChange($0.origin) })
    }
    
    public func readPosition(in coordinateSpace: CoordinateSpace = .local, onChange: @escaping (CGPoint) -> Void) -> some View {
        return self.readFrame(in: coordinateSpace, onChange: { onChange($0.center) })
    }
    
    public func readFrame(_ binding: Binding<CGRect>, in coordinateSpace: CoordinateSpace = .local) -> some View {
        self.readFrame(in: coordinateSpace, onChange: { binding.wrappedValue = $0 })
    }
    
    public func readOrigin(_ binding: Binding<CGPoint>, in coordinateSpace: CoordinateSpace = .local) -> some View {
        self.readFrame(in: coordinateSpace, onChange: { binding.wrappedValue = $0.origin })
    }
    
    public func readPosition(_ binding: Binding<CGPoint>, in coordinateSpace: CoordinateSpace = .local) -> some View {
        self.readFrame(in: coordinateSpace, onChange: { binding.wrappedValue = $0.center })
    }
    
    public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.onGeometryChange(for: CGSize.self, of: \.size, action: onChange)
    }
    
    public func readSize(_ binding: Binding<CGSize>) -> some View {
        self.readSize(onChange: { binding.wrappedValue = $0 })
    }
    
}

private class Deduper<T: Equatable> {
    private var previous: T?
    private var action: (T) -> Void
    
    init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    func report(_ value: T) -> Void {
        guard value != previous else { return }
        previous = value
        action(value)
    }
}
