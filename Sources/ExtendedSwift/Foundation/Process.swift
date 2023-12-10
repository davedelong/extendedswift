//
//  File.swift
//  
//
//  Created by Dave DeLong on 4/3/23.
//

import Foundation

#if !os(iOS)

public struct ProcessOutput {
    public let exitCode: Int
    public let reason: Process.TerminationReason
    public let standardOutput: Data
    public let standardError: Data
}

public struct ProcessIO: Sendable {
    
    internal enum Source {
        case pipe(Pipe)
        case fh(FileHandle)
        
        fileprivate var processHandle: Any {
            switch self {
                case .pipe(let p): return p
                case .fh(let h): return h
            }
        }
    }
    
    public static func pipedIO() -> ProcessIO {
        let i = Pipe()
        let o = Pipe()
        let e = Pipe()
        
        return .init(inputSource: .pipe(i), outputSource: .pipe(o), errorSource: .pipe(e))
    }
    
    internal let inputSource: Source
    internal let outputSource: Source
    internal let errorSource: Source
    
    func waitForCompletion() { }
    
}

extension Process {
    
    public static func execute(_ command: Path, arguments: Array<String> = [], environment: Dictionary<String, String>? = nil, cwd: URL? = nil) async throws -> ProcessOutput {
        return try await execute(command.fileURL, arguments: arguments, environment: environment, cwd: cwd)
    }
    
    public static func execute(_ command: URL, arguments: Array<String> = [], environment: Dictionary<String, String>? = nil, cwd: URL? = nil, io: ProcessIO? = nil) async throws -> ProcessOutput {
        let p = Process()
        p.executableURL = command
        p.arguments = arguments
        if let environment { p.environment = environment }
        if let cwd { p.currentDirectoryURL = cwd }
        p.qualityOfService = .userInitiated
        
        let processIO = io ?? .pipedIO()
        
        return try await withUnsafeThrowingContinuation { c in
            p.standardInput = processIO.inputSource.processHandle
            p.standardOutput = processIO.outputSource.processHandle
            p.standardError = processIO.errorSource.processHandle
            
            let aggregator = _ProcessIO()
            p.standardOutput = aggregator.outputPipe
            p.standardError = aggregator.errorPipe
            
            p.terminationHandler = { proc in
                let status = proc.terminationStatus
                let reason = proc.terminationReason
                
                processIO.waitForCompletion()
                
                aggregator.withStdoutAndStderr { stdout, stderr in
                    let output = ProcessOutput(exitCode: Int(status),
                                               reason: reason,
                                               standardOutput: stdout,
                                               standardError: stderr)
                    
                    c.resume(returning: output)
                }
            }
            
            do {
                try p.run()
            } catch {
                c.resume(throwing: error)
            }
        }
    }
    
}

private class _ProcessIO {
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    private let queue = DispatchQueue(label: "ProcessIO", qos: .userInitiated)
    private(set) var outputData = Data()
    private(set) var errorData = Data()
    
    init() {
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] h in
            self?.queue.async { self?.outputData.append(h.availableData) }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] h in
            self?.queue.async { self?.errorData.append(h.availableData) }
        }
    }
    
    func withStdoutAndStderr(_ task: @escaping (Data, Data) -> Void) {
        self.queue.async {
            task(self.outputData, self.errorData)
        }
    }
    
}

#endif
