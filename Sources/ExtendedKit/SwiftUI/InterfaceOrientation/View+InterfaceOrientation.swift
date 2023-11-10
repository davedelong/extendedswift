//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

#if !os(macOS)

import SwiftUI
import Logging

extension View {
    
    public func preferredInterfaceOrientationForPresentation(_ value: InterfaceOrientation?) -> some View {
        self.modifier(InterfaceViewModifier(key: Keys.PreferredInterfaceOrientation.self,
                                            value: value?.uiInterfaceOrientation))
    }
    
    public func supportedInterfaceOrientations(_ value: Array<InterfaceOrientation>?) -> some View {
        return self.modifier(InterfaceViewModifier(key: Keys.SupportedInterfaceOrientations.self,
                                                   value: value?.uiInterfaceOrientationmask))
    }
    
    public func prefersHomeIndicatorAutoHidden(_ value: Bool?) -> some View {
        self.modifier(InterfaceViewModifier(key: Keys.PrefersHomeIndicatorAutoHidden.self, 
                                            value: value))
    }
    
    public func preferredStatusBarStyle(_ value: ColorScheme?) -> some View {
        self.modifier(InterfaceViewModifier(key: Keys.PreferredStatusBarStyle.self,
                                            value: value?.uiStatusBarStyle))
    }
    
    public func prefersStatusBarHidden(_ value: Bool?) -> some View {
        self.modifier(InterfaceViewModifier(key: Keys.PrefersStatusBarHidden.self, 
                                            value: value))
    }
    
}

extension InterfaceOrientation {
    
    internal var uiInterfaceOrientation: UIInterfaceOrientation {
        switch self {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: return .portrait
        }
    }
    
    internal var uiInterfaceOrientationMask: UIInterfaceOrientationMask {
        switch self {
            case .portrait: return .portrait
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: return []
        }
    }
    
}

extension Array where Element == InterfaceOrientation {
    
    internal var uiInterfaceOrientationmask: UIInterfaceOrientationMask {
        return self.reduce(into: UIInterfaceOrientationMask(),
                           { $0.formUnion($1.uiInterfaceOrientationMask) })
    }
    
}

extension ColorScheme {
    
    internal var uiStatusBarStyle: UIStatusBarStyle {
        switch self {
            case .light: return .lightContent
            case .dark: return .darkContent
            default: return .default
        }
    }
    
}

private struct InterfaceViewModifier<Key: PreferenceKey>: ViewModifier {
    
    @Environment(\.interfaceHostPresent) var hasHost
    let value: Key.Value?
    
    init(key: Key.Type = Key.self, value: Key.Value?) {
        self.value = value
    }
    
    func body(content: Content) -> some View {
        if hasHost == false {
            Logger.runtimeWarning("Attempting to modify interface key but no host is present.")
        }
        
        return content
            .preference(key: Key.self, value: value ?? Key.defaultValue)
    }
    
}


#endif
