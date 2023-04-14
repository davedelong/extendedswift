//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit

public typealias PlatformImage = NSImage
public typealias PlatformView = NSView
public typealias PlatformViewRepresentable = NSViewRepresentable

#else
import UIKit

public typealias PlatformImage = UIImage
public typealias PlatformView = UIView
public typealias PlatformViewRepresentable = UIViewRepresentable

#endif
