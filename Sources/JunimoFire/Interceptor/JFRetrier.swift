//
//  JFRetrier.swift
//
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public enum RetryCondition {
    
    case retryImediately(request: URLRequest)
    case retryWithDelay(request: URLRequest, seconds: Int)
    case doNotRetry
    case finish
}

public typealias JFRetryHandler = (ValidationInfo, URLRequest, URLResponse, Data?) async throws -> RetryCondition

public protocol JFRequestRetrier {
    
    var label: String { get }
    
    func retry(validationInfo: ValidationInfo, request: URLRequest, response: URLResponse, data: Data?) async throws -> RetryCondition
}

public class JFRetrier: JFRequestRetrier {
    
    public let label: String
    
    let retryHandler: JFRetryHandler
    
    public init(
        label: String,
        retryHandler: @escaping JFRetryHandler) {
        
        self.label = label
        self.retryHandler = retryHandler
    }
    
    public func retry(validationInfo: ValidationInfo, request: URLRequest, response: URLResponse, data: Data?) async throws -> RetryCondition {
        try await retryHandler(validationInfo, request, response, data)
    }
}
