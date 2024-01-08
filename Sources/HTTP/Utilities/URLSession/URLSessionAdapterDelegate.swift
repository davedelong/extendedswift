import Foundation

internal class URLSessionAdapterDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    let queue: OperationQueue
    weak var adapter: URLSessionAdapter?
    
    override init() {
        self.queue = OperationQueue()
        super.init()
        
        self.queue.name = "\(type(of: self))"
        self.queue.maxConcurrentOperationCount = 1
    }
    
    // MARK: - URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        guard let adapter else {
            return nil
        }
        
        return await adapter.task(task, willPerformHTTPRedirection: response, newRequest: request)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let adapter else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        return await adapter.task(task, didReceive: challenge)
    }
    
    func urlSession(_ session: URLSession, needNewBodyStreamForTask task: URLSessionTask) async -> InputStream? {
        guard let adapter else {
            return nil
        }
        
        return await adapter.task(needsNewBodyStream: task)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        adapter?.task(task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        adapter?.task(task, didCompleteWithError: error)
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        guard let adapter else {
            return .cancel
        }
        
        return await adapter.task(dataTask, didReceive: response)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        adapter?.task(dataTask, didReceive: data)
    }
}
