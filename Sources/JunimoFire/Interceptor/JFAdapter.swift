//
//  JFAdapter.swift
//  
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public protocol JFRequestAdpater {
    
    var label: String { get }
    
    func adapt(session: URLSession, request: URLRequest) async throws -> URLRequest
}

public typealias JFAdpaterHandler = (URLSession, URLRequest) async throws -> URLRequest

public class JFAdpater: JFRequestAdpater {
    
    public let label: String
    let adapterHanler: JFAdpaterHandler
    
    public init(label: String, _ adapterHanler: @escaping JFAdpaterHandler) {
        self.label = label
        self.adapterHanler = adapterHanler
    }
    
    public func adapt(session: URLSession, request: URLRequest) async throws -> URLRequest {
        try await adapterHanler(session, request)
    }
}
