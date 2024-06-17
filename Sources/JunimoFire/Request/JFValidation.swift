//
//  JFValidation.swift
//
//
//  Created by 최준영 on 6/17/24.
//

import Foundation

public typealias JFValidation = (Data?, URLResponse) -> JFValidationResult

public struct ValidationInfo {
    let idenifier: Int
    let reason: String
}

public enum JFValidationResult {
    case success
    case failure(info: ValidationInfo)
}
