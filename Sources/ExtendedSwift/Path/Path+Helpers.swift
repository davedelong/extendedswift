//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension PathComponent {
    
    internal static func reduce(_ components: Array<PathComponent>, allowRelative: Bool) -> Array<PathComponent> {
        var newComponents = Array<PathComponent>()
        for c in components {
            switch c {
                case .this:
                    continue
                case .up:
                    if newComponents.last?.itemString != nil {
                        // remove the last item
                        newComponents.removeLast()
                    } else if allowRelative == true {
                        newComponents.append(c)
                    }
                case .item(let s, let e):
                    if s == PathSeparator && e == nil {
                        continue
                    } else if s.hasPrefix("~") && e == nil {
                        newComponents.removeAll()
                        let expanded = Path(fileSystemPath: s)
                        newComponents.append(contentsOf: expanded.components)
                    } else {
                        newComponents.append(c)
                    }
            }
        }
        return newComponents
    }
    
}
