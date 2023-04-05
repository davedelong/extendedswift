//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/4/23.
//

import Foundation

#if os(macOS)
import AppKit

public typealias PlatformImage = NSImage

#else
import UIKit

public typealias PlatformImage = UIImage

#endif
