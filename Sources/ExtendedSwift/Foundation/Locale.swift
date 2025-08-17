//
//  Locale.swift
//  ExtendedSwift
//
//  Created by Dave DeLong on 8/17/25.
//

import Foundation

extension Locale.Region {
    
    /// Return the approximate emoji for a region
    ///
    /// This may not return a specific flag emoji, but may return a globe or question mark emoji
    public var flagEmoji: String {
        if self == .unknown { return "❓" }
        
        // this is based on the BCP47 (region) identifier being the same as the ISO3166 (country) identifier
        // obviously this is not exactly correct, but I don't see anything in Locale for 3166 identifiers
        
        let lower = identifier.lowercased()
        if let override = flagOverrides[lower] { return override }
        
        let scalars = lower.utf8.compactMap {
            // a is 0x0061
            // REG A is 0x1F1E6
            // the difference between them is 0x1F185
            return UnicodeScalar(Int($0) + 0x1F185)
        }
        guard scalars.count == 2 else { return "❓" }
        return String(String.UnicodeScalarView(scalars))
    }
    
}

private let flagOverrides = [
    "001": "🌐", // world
    "142": "🌏", // Asia
    "150": "🌍", // Europe
    "002": "🌍", // Africa
    "019": "🌎", // Americas
    "009": "🌏", // Oceania
    "143": "🌏", // Central Asia
    "151": "🌍", // Eastern Europe
    "154": "🌍", // Northern Europe
    "155": "🌍", // Western Europe
    "015": "🌍", // Northern Africa
    "013": "🌎", // Central America
    "005": "🌎", // South America
    "014": "🌍", // Eastern Africa
    "017": "🌍", // Middle Africa
    "018": "🌍", // Southern Africa
    "021": "🌎", // Northern America
    "061": "🌏", // Polynesia
    "029": "🌎", // Caribbean
    "030": "🌏", // Eastern Asia
    "034": "🌏", // Southern Asia
    "035": "🌏", // Southeast Asia
    "039": "🌍", // Southern Europe
    "053": "🌏", // Australasia
    "054": "🌏", // Melanesia
    "057": "🌏", // Micronesian Region
    "145": "🌍", // Western Asia
    "011": "🌍", // Western Africa,
    "qo": "🌏", // Outlying Oceania
    "uk": "🇬🇧", // United Kingdom
]
