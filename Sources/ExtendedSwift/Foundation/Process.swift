//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

#if !os(iOS)

#warning("TODO: better process IO")

public struct ProcessOutput {
    public let exitCode: Int
    public let reason: Process.TerminationReason
    public let standardOutput: Path
    public let standardError: Path
}

extension Process {
    
    public static func execute(_ command: Path, arguments: Array<String> = [], environment: Dictionary<String, String>? = nil, cwd: URL? = nil) async throws -> ProcessOutput {
        return try await execute(command.fileURL, arguments: arguments, environment: environment, cwd: cwd)
    }
    
    public static func execute(_ command: URL, arguments: Array<String> = [], environment: Dictionary<String, String>? = nil, cwd: URL? = nil) async throws -> ProcessOutput {
        let p = Process()
        p.executableURL = command
        p.arguments = arguments
        if let environment { p.environment = environment }
        if let cwd { p.currentDirectoryURL = cwd }
        p.qualityOfService = .userInitiated
        
        return try await withUnsafeThrowingContinuation { c in
            do {
                let name = command.lastPathComponent + "-" + UUID.timestampedUUID.uuidString
                
                let aggregator = try ProcessIO(name: name)
                p.standardOutput = aggregator.outputHandle
                p.standardError = aggregator.errorHandle
                
                p.terminationHandler = { proc in
                    let status = proc.terminationStatus
                    let reason = proc.terminationReason
                    
                    let output = ProcessOutput(exitCode: Int(status),
                                               reason: reason,
                                               standardOutput: aggregator.outputPath,
                                               standardError: aggregator.errorPath)
                    
                    c.resume(returning: output)
                }
            
                try p.run()
            } catch {
                c.resume(throwing: error)
            }
        }
    }
    
}

private class ProcessIO {
    let outputPath: Path
    let errorPath: Path
    
    let outputHandle: FileHandle
    let errorHandle: FileHandle
    
    init(name: String) throws {
        self.outputPath = Path.temporaryDirectory.appending(component: "tmp-\(name).out")
        self.errorPath = Path.temporaryDirectory.appending(component: "tmp-\(name).err")
        
        FileManager.default.createFile(atPath: outputPath)
        FileManager.default.createFile(atPath: errorPath)
        
        self.outputHandle = try FileHandle(forUpdating: outputPath)
        self.errorHandle = try FileHandle(forUpdating: errorPath)
    }
}

#endif
