//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

#if !os(macOS)
import SwiftUI
import UIKit

enum Keys {
    
    struct PreferredInterfaceOrientation: PreferenceKey {
        static var defaultValue: UIInterfaceOrientation = .portrait
        static func reduce(value: inout UIInterfaceOrientation, nextValue: () -> UIInterfaceOrientation) {
            value = nextValue()
        }
    }
    
    struct SupportedInterfaceOrientations: PreferenceKey {
        static var defaultValue: UIInterfaceOrientationMask = .allButUpsideDown
        static func reduce(value: inout UIInterfaceOrientationMask, nextValue: () -> UIInterfaceOrientationMask) {
            value = nextValue()
        }
    }
    
    struct PrefersHomeIndicatorAutoHidden: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct PrefersStatusBarHidden: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct PreferredStatusBarStyle: PreferenceKey {
        static var defaultValue: UIStatusBarStyle = .default
        static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
            value = nextValue()
        }
    }
}

#endif
