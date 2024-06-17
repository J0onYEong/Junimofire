//
//  JFError.swift
//
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public enum JFRequestError: Error {
    
    /// URLRequest Generation Error
    case urlRequestGenerationFailed
    
    /// Adaption failure
    case adpationFailed(adaptionLabel: String)

    /// Retry failure
    case retryFailed(retrierLabel: String)
    
    /// Decoding failed
    case decodingFailed
}
