//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/8/23.
//

import Foundation

#if os(macOS)

import OpenDirectory

extension Process {
    
    public static func which(_ command: String, shell: URL? = nil, PATH: String? = nil) async throws -> URL? {
        guard command.contains(where: \.isWhitespace) == false else {
            throw NSError(domain: "NSTask", code: -1, userInfo: [
                "invalidCommand": command
            ])
        }
        
        if let existing = whichLock.withLock({ whichLookup[command] }) {
            return existing
        }
        
        let resolvedShell = shell ?? Self.userShell
        var environment = ProcessInfo.processInfo.environment
        if let PATH { environment["PATH"] = PATH }
        
        let output = try await Process.execute(resolvedShell, arguments: ["--login", "-c", "which \(command)"], environment: environment)
        
        if output.exitCode == 0, let path = String(bytes: output.standardOutput, encoding: .utf8) {
            let trimmed = path.trimmed()
            if trimmed.isEmpty || trimmed.hasPrefix("/") == false { return nil }
            
            let url = URL(filePath: trimmed)
            
            whichLock.withLock({
                whichLookup[command] = url
            })
            
            return url
        }
        
        throw NSError(domain: "NSTask", code: output.exitCode, userInfo: [
            "command": command,
            "standardError": String(bytes: output.standardError, encoding: .utf8) ?? "",
            "standardOutput": String(bytes: output.standardOutput, encoding: .utf8) ?? "",
        ])
    }
    
    private static let userShell: URL = {
        // see if it's in the environment
        if let path = ProcessInfo.processInfo.environment["SHELL"] {
            return URL(filePath: path)
        }
        
        let user = getuid()
        
        // try pulling the shell from OpenDirectory
        if let shellURL = try? odShell(for: user) {
            return shellURL
        }
        
        // getpwuid has a pw_shell
        if let info = getpwuid(user), let shell = String(cString: info.pointee.pw_shell, encoding: .utf8) {
            return URL(filePath: shell)
        }
        
        // default back to zsh
        return URL(filePath: "/bin/zsh")
    }()
    
    private static let whichLock = NSLock()
    private static var whichLookup = Dictionary<String, URL>()
    
}

private func odShell(for user: uid_t) throws -> URL? {
    let session = ODSession.default()
    let root = try ODNode(session: session, name: "/Local/Default")
    let query = try ODQuery(node: root,
                            forRecordTypes: kODRecordTypeUsers,
                            attribute: kODAttributeTypeUniqueID,
                            matchType: ODMatchType(kODMatchEqualTo),
                            queryValues: "\(user)",
                            returnAttributes: [kODAttributeTypeUserShell],
                            maximumResults: 1)
    
    let results = try query.resultsAllowingPartial(false)

    guard let result = results.first else { return nil }
    guard let record = result as? ODRecord else { return nil }
    
    let shells = try record.values(forAttribute: kODAttributeTypeUserShell)
    
    guard let shell = shells.first as? String else { return nil }
    return URL(filePath: shell)
}

#endif
