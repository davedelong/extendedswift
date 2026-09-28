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
        static let defaultValue: UIInterfaceOrientation = .portrait
        static func reduce(value: inout UIInterfaceOrientation, nextValue: () -> UIInterfaceOrientation) {
            value = nextValue()
        }
    }
    
    struct SupportedInterfaceOrientations: PreferenceKey {
        static let defaultValue: UIInterfaceOrientationMask = .allButUpsideDown
        static func reduce(value: inout UIInterfaceOrientationMask, nextValue: () -> UIInterfaceOrientationMask) {
            value = nextValue()
        }
    }
    
    struct PrefersHomeIndicatorAutoHidden: PreferenceKey {
        static let defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct PrefersStatusBarHidden: PreferenceKey {
        static let defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
    
    struct PreferredStatusBarStyle: PreferenceKey {
        static let defaultValue: UIStatusBarStyle = .default
        static func reduce(value: inout UIStatusBarStyle, nextValue: () -> UIStatusBarStyle) {
            value = nextValue()
        }
    }
}

#endif
