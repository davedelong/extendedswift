import Foundation

extension AsyncStream {
    
    internal init<S: Sequence>(sequence: S) where S.Element == Element {
        self.init { continuation in
            for element in sequence {
                continuation.yield(element)
            }
            continuation.finish()
        }
    }
    
}
