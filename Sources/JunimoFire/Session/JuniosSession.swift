//
//  File.swift
//  
//
//  Created by 최준영 on 6/16/24.
//

import Foundation

public class JuniosSession {
    
    static let `default` = JuniosSession(configuration: .default)
    
    let session: URLSession
    let sessionDelegate: URLSessionDelegate
    
    public init(
        configuration: URLSessionConfiguration,
        sessionDelegate: URLSessionDelegate = JuniosSessionDelegate()) {
            
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        self.session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: queue)
        self.sessionDelegate = sessionDelegate
    }
    
}


// MARK: - data request
public extension JuniosSession {
    
    func request(request: URLRequest, interceptor: JFRequestInterceptor?) -> JFDataRequest {
        
        let dataRequest = JFDataRequest(
            request: request,
            interceptor: interceptor,
            session: session
        )
        
        return dataRequest
    }
}

