import Foundation

internal class URLSessionAdapter {
    
    private let session: URLSession
    private let delegate: URLSessionAdapterDelegate
    
    init(configuration: URLSessionConfiguration) {
        let delegate = URLSessionAdapterDelegate()
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegate.queue)
        
        self.session = session
        self.delegate = delegate
        
        delegate.adapter = self
    }
    
    func execute(_ request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        if let urlRequest = request.convertToURLRequest() {
            return await self.execute(urlRequest, httpRequest: request, token: token)
        } else {
            let err = HTTPError(code: .invalidRequest,
                                request: request,
                                message: "Could not convert HTTPRequest to URLRequest")
            return HTTPResult.failure(err)
        }
    }
    
    // this value is only accessed on the delegate's queue
    private let stateLock = NSLock()
    private var states = [Int: URLSessionTaskState]()
    
    private func withState<T>(_ perform: (inout Dictionary<Int, URLSessionTaskState>) -> T) -> T {
        return stateLock.withLock {
            return perform(&states)
        }
    }
    
    private func execute(_ urlRequest: URLRequest, httpRequest: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        return await withUnsafeContinuation { continuation in
            delegate.queue.addOperation {
                let dataTask = self.session.dataTask(with: urlRequest)
                let state = URLSessionTaskState(httpRequest: httpRequest,
                                                token: token,
                                                dataTask: dataTask,
                                                continuation: continuation)
                
                self.withState {
                    $0[dataTask.taskIdentifier] = state
                }
                dataTask.resume()
                
                // if the token gets cancelled, the URLSessionDataTask does too
                // if the token has already been cancelled, the data task will cancel immediately
                token.addCancellationHandler { dataTask.cancel() }
            }
        }
    }
    
    // URLSession___Delegate shims
    
    func task(_ task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        
        let originalRequest = withState { $0[task.taskIdentifier]?.httpRequest }
        
        guard let originalRequest else {
            return nil
        }
        
        guard let handler = originalRequest[option: \.redirectionHandler] else {
            return request
        }
        
        let httpResponse = HTTPResponse(request: originalRequest, response: response)
        let proposed = HTTPRequest(request: request)
        
        let actual = await handler.handleRedirection(for: originalRequest,
                                                     response: httpResponse,
                                                     proposedRedirection: proposed)
        
        return actual?.convertToURLRequest()
    }
    
    func task(_ task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        
        let originalRequest = withState { $0[task.taskIdentifier]?.httpRequest }
        
        guard let originalRequest else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        guard let handler = originalRequest[option: \.authenticationChallengeHandler] else {
            return (.performDefaultHandling, nil)
        }
        
        let response = await handler.evaluate(challenge, for: originalRequest)
        return (response.disposition, response.credential)        
    }
    
    func task(needsNewBodyStream task: URLSessionTask) async -> InputStream? {
        let body = withState { $0[task.taskIdentifier]?.httpRequest.body }
        guard let body else { return nil }
        
        print("TODO: create a new input stream for this body", body)
        return nil
    }
    
    func task(_ task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
    }
    
    func task(_ task: URLSessionTask, didCompleteWithError error: Error?) {
        let state = withState { $0.removeValue(forKey: task.taskIdentifier) }
        guard let state else {
            return
        }
        
        let result: HTTPResult
        
        if let error {
            let err = HTTPError(error: error, request: state.httpRequest, response: state.response)
            result = .failure(err)
        } else if var response = state.response {
            if let data = state.data {
                response.body = DataBody(data)
            }
            result = .success(response)
        } else {
            let err = HTTPError(code: .internal,
                                request: state.httpRequest,
                                message: "Task completed, but there was no response")
            result = .failure(err)
        }
        state.continuation.resume(returning: result)
    }
    
    // MARK: - URLSessionDataDelegate
    
    func task(_ dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .cancel
        }
        
        return withState { states in
            guard let request = states[dataTask.taskIdentifier]?.httpRequest else {
                return .cancel
            }
            
            let response = HTTPResponse(request: request, response: httpResponse)
            
            states[dataTask.taskIdentifier]?.response = response
            
            return .allow
        }
    }
    
    func task(_ dataTask: URLSessionDataTask, didReceive data: Data) {
        withState { states in
            guard states[dataTask.taskIdentifier] != nil else {
                return
            }
            
            if states[dataTask.taskIdentifier]?.data == nil {
                states[dataTask.taskIdentifier]?.data = data
            } else {
                states[dataTask.taskIdentifier]?.data?.append(data)
            }
        }
    }
}
