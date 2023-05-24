//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/1/23.
//

import Foundation

extension String {
    
    public func decodingHTMLEntities() -> String {
        var mutable = self
        let allMatches = (try? EntityRegex.allMatches(in: self)) ?? []
        
        for match in allMatches.reversed() {
            
            if let numericEntity = match.output.2 {
                if let int = Int(numericEntity), let scalar = Unicode.Scalar(int) {
                    mutable = mutable.replacingCharacters(in: match.range, with: String(scalar))
                }
            } else if let hexEntity = match.output.3 {
                if let int = Int(hexEntity, radix: 16), let scalar = Unicode.Scalar(int) {
                    mutable = mutable.replacingCharacters(in: match.range, with: String(scalar))
                }
            } else if let namedEntity = match.output.4 {
                let name = EntityName(rawValue: String(namedEntity))
                if let replacement = EntityLookup[name] {
                    mutable = mutable.replacingCharacters(in: match.range, with: replacement.rawValue)
                }
            }
            
        }
        
        return mutable
    }
    
    public struct HTMLEncodingOptions: OptionSet {
        public static let preferNamedEntities = HTMLEncodingOptions(rawValue: 1 << 0)
        public static let useHexEntities = HTMLEncodingOptions(rawValue: 1 << 1)
        public static let useUppercaseHex = HTMLEncodingOptions(rawValue: 1 << 2)
        public static let padNumericEntitiesToFourDigits = HTMLEncodingOptions(rawValue: 1 << 3)
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    public func encodingHTMLEntities(options: HTMLEncodingOptions = []) -> String {
        var scalars = Array<Unicode.Scalar>()
        
        for scalar in self.unicodeScalars {
            let value = scalar.value
            
            if options.contains(.preferNamedEntities), let name = EntityLookup[EntityReplacement(rawValue: String(scalar))] {
                scalars.append(contentsOf: "&\(name.rawValue);".unicodeScalars)
            } else if value >= 128 {
                var format = "&#"
                if options.contains(.useHexEntities) {
                    format.append("x%")
                    if options.contains(.padNumericEntitiesToFourDigits) {
                        format.append("04")
                    }
                    format.append(options.contains(.useUppercaseHex) ? "X" : "x")
                } else {
                    format.append("%")
                    if options.contains(.padNumericEntitiesToFourDigits) {
                        format.append("04")
                    }
                    format.append("d")
                }
                format.append(";")
                let s = String(format: format, value)
                scalars.append(contentsOf: s.unicodeScalars)
            } else {
                scalars.append(scalar)
            }
        }
        
        return String(String.UnicodeScalarView(scalars))
    }
    
}

fileprivate struct EntityName: Newtype, Hashable {
    let rawValue: String
}

fileprivate struct EntityReplacement: Newtype, Hashable {
    let rawValue: String
}

fileprivate let EntityLookup: Bimap<EntityName, EntityReplacement> = {
    guard let path = Bundle.module.absolutePath(forResource: "entities", withExtension: "json") else {
        print("Could not locate entities.json")
        return [:]
    }
    guard let data = try? Data(contentsOf: path) else {
        print("Could not load entities.json")
        return [:]
    }
    let decoder = JSONDecoder()
    guard let entities = try? decoder.decode([String: NamedEntity].self, from: data) else {
        print("Could not parse entities.json")
        return [:]
    }
    
    // Technically, some entities allow for a missing ; after the name, such as &AMP
    // This deliberately ignores those
    var bimap = Bimap<EntityName, EntityReplacement>()
    for (name, entity) in entities {
        let cleaned = name.removingPrefix("&").removingSuffix(";")
        bimap[EntityName(rawValue: cleaned)] = EntityReplacement(rawValue: entity.characters)
    }
    
    return bimap
}()

fileprivate struct NamedEntity: Decodable {
    let codepoints: Array<Int>
    let characters: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.anyKeyedContainer()
        self.codepoints = try container["codepoints"]
        self.characters = try container["characters"]
    }
}

fileprivate let EntityRegex = /&(#(\d+)|#x([:xdigit:]+)|([^&#;]+));/
