//
//  JuniosSessionDelegate.swift
//
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public class JuniosSessionDelegate: NSObject {
    
    public override init() {
        super.init()
    }
    
}

extension JuniosSessionDelegate: URLSessionTaskDelegate {
    
//    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//    
//        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//    }
}
