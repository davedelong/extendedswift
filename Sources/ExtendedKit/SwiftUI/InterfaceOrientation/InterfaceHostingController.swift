//
//  File.swift
//  
//
//  Created by Dave DeLong on 11/9/23.
//

#if !os(macOS)

import SwiftUI
import UIKit

public class UIInterfaceHostingController<Root: View>: UIHostingController<_UIHostedView<Root>> {
    
    public init(rootView: Root) {
        let box = Box<UIInterfaceHostingController<Root>>()
        super.init(rootView: _UIHostedView(rootView: rootView, controllerReference: box))
        
        box.value = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    internal var _preferredInterfaceOrientation: UIInterfaceOrientation = Keys.PreferredInterfaceOrientation.defaultValue
    
    internal var _supportedInterfaceOrientations: UIInterfaceOrientationMask = Keys.SupportedInterfaceOrientations.defaultValue {
        didSet { self.setNeedsUpdateOfSupportedInterfaceOrientations() }
    }
    
    internal var _prefersHomeIndicatorAutoHidden = Keys.PrefersHomeIndicatorAutoHidden.defaultValue {
        didSet { self.setNeedsUpdateOfHomeIndicatorAutoHidden() }
    }
    
    internal var _preferredStatusBarStyle = Keys.PreferredStatusBarStyle.defaultValue {
        didSet { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    internal var _prefersStatusBarHidden = Keys.PrefersStatusBarHidden.defaultValue {
        didSet { self.setNeedsStatusBarAppearanceUpdate() }
    }
    
    // MARK: - Overrides
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { _preferredInterfaceOrientation }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { _supportedInterfaceOrientations }
    
    public override var prefersHomeIndicatorAutoHidden: Bool { _prefersHomeIndicatorAutoHidden }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle { _preferredStatusBarStyle }
    
    public override var prefersStatusBarHidden: Bool { _prefersStatusBarHidden }
    
}

private class Box<Value: AnyObject> {
    weak var value: Value?
}

public struct _UIHostedView<Content: View>: View {
    
    let rootView: Content
    fileprivate let controllerReference: Box<UIInterfaceHostingController<Content>>
    
    public var body: some View {
        rootView
            .onPreferenceChange(Keys.PreferredInterfaceOrientation.self, perform: { value in
                controllerReference.value?._preferredInterfaceOrientation = value
            })
            .onPreferenceChange(Keys.SupportedInterfaceOrientations.self, perform: { value in
                controllerReference.value?._supportedInterfaceOrientations = value
            })
            .onPreferenceChange(Keys.PrefersHomeIndicatorAutoHidden.self, perform: { value in
                controllerReference.value?._prefersHomeIndicatorAutoHidden = value
            })
            .onPreferenceChange(Keys.PrefersStatusBarHidden.self, perform: { value in
                controllerReference.value?._prefersStatusBarHidden = value
            })
            .environment(\.interfaceHostPresent, true)
    }
    
}

private struct _UIInterfaceHostPresentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var interfaceHostPresent: Bool {
        get { self[_UIInterfaceHostPresentKey.self] }
        set { self[_UIInterfaceHostPresentKey.self] = newValue }
    }
}

#endif
