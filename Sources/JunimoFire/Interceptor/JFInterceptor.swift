//
//  JFInterceptor.swift
//  
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public protocol JFRequestInterceptor: JFRequestAdpater & JFRequestRetrier {
    
    var adapters: [JFRequestAdpater] { get set }
    var retriers: [JFRequestRetrier] { get set }
}
public extension JFRequestInterceptor { var label: String { "Unknown" } }


public class JFInterceptor: JFRequestInterceptor {
    
    public var adapters: [JFRequestAdpater]
    public var retriers: [JFRequestRetrier]
    
    public init(adapters: [JFRequestAdpater]=[], retriers: [JFRequestRetrier]=[]) {
        self.adapters = adapters
        self.retriers = retriers
    }
    
    public func adapt(session: URLSession, request: URLRequest) async throws -> URLRequest {
        
        var adaptedRequest = request
        
        for adapter in adapters {
          
            do {
                adaptedRequest = try await adapter.adapt(session: session, request: adaptedRequest)
            } catch {
                
                throw JFRequestError.adpationFailed(adaptionLabel: adapter.label)
            }
        }

        return adaptedRequest
    }
    
    public func retry(validationInfo: ValidationInfo, request: URLRequest, response: URLResponse, data: Data?) async throws -> RetryCondition {
        
        let condition: RetryCondition = .finish
        
        for retrier in retriers {
            
            let condition = try await retrier.retry(validationInfo: validationInfo, request: request, response: response, data: data)
            
            switch condition {
            case .finish, .retryImediately, .retryWithDelay:
                return condition
            case .doNotRetry:
                continue
            }
        }
        
        return condition
    }
}

public extension JFInterceptor {
    
    static func interceptor(adaper: JFAdpater, retrier: JFRetrier) -> JFInterceptor {
        .init(adapters: [adaper], retriers: [retrier])
    }
}
