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
    
    private var adapters: [JFRequestAdpater]
    private var retriers: [JFRequestRetrier]
    
    private var vaildators: [JFValidation] = []
    
    public init(
        configuration: URLSessionConfiguration,
        sessionDelegate: URLSessionDelegate = JuniosSessionDelegate(),
        adapters: [JFRequestAdpater] = [],
        retriers: [JFRequestRetrier] = [],
        validators: [JFValidation] = []
    ) {
            
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        self.session = URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: queue)
        self.sessionDelegate = sessionDelegate
        self.adapters = adapters
        self.retriers = retriers
        self.vaildators = validators
        }
    }

// MARK: - data request
public extension JuniosSession {
    
    func request(request: URLRequest, interceptor: JFRequestInterceptor? = nil) async -> JFDataRequest {
        
        // 세션 어뎁터&리트라이어 적용
        let willAddintercepator = interceptor ?? JFInterceptor()
        
        willAddintercepator.adapters.append(contentsOf: adapters)
        willAddintercepator.retriers.append(contentsOf: retriers)
        
        let dataRequest = JFDataRequest(
            request: request,
            interceptor: willAddintercepator,
            session: session
        )
        
        // Validation설정
        for validator in vaildators {
            _ = await dataRequest.validate(validator: validator)
        }
        
        return dataRequest
    }
}

