//
//  DataRequest.swift
//
//
//  Created by 최준영 on 6/16/24.
//

import Foundation

public class JFDataRequest {
    
    var interceptor: JFRequestInterceptor?
    unowned var session: URLSession
    
    /// JFDataRequest에서 사용되는 요청배열입니다.
    var requests: MutableProperty<[URLRequest]>
    
    /// 응답검증에 사용되는 검증자 배열입니다.
    var validators: MutableProperty<[JFValidation]> = .init(value: [])
    
    func currentRequest() async -> URLRequest { await requests.value.last! }
    func initialRequest() async -> URLRequest { await requests.value.first! }
    
    init(
        request: URLRequest,
        interceptor: JFRequestInterceptor? = nil,
        session: URLSession) {
            
        self.interceptor = interceptor
        self.session = session
        self.requests = MutableProperty(value: [request])
    }
    
    /// JFDataRequest가 보유하고 있는 URLRequest를 업데이트 합니다.
    public func requestIsUpdated(request: URLRequest) async {
        await requests.write { requests in
            var newRequest = requests
            newRequest.append(request)
            return newRequest
        }
    }
    
    /// Request에 Validation을 추가합니다.
    public func validate(validator: @escaping JFValidation) async -> Self {
        
        await validators.write { validators in
            var newValidators = validators
            newValidators.append(validator)
            return newValidators
        }
        
        return self
    }
    
    /// 요청을 시작합니다.
    public func response() async throws -> Data {
        
        // Adaption
        try await adapt()
        
        // Request
        let (data, _) = try await perform()
        
        return data
    }
    
    public func responseDecodable<T: Decodable>(type: T.Type) async throws -> T {
        
        let data = try await response()
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw JFRequestError.decodingFailed
        }
    }
    
    private func adapter() -> JFRequestAdpater? { interceptor }
    private func retrier() -> JFRequestRetrier? { interceptor }
    
    private func adapt() async throws {
        
        let urlRequest = await self.currentRequest()
        
        guard let adapter = adapter() else { return }
        
        let adaptedRequest = try await adapter.adapt(session: session, request: urlRequest)
        await self.requestIsUpdated(request: adaptedRequest)
    }
    
    private func perform() async throws -> (Data, URLResponse) {

        let (data, response) = try await session.data(for: currentRequest())
        
        let validationInfo = try await startValidation(data: data, response: response)
        
        if let validationInfo {
            
            return try await retry(validationInfo: validationInfo, response: response, data: data)
        }
        
        return (data, response)
    }
    
    private func startValidation(data: Data, response: URLResponse) async throws -> ValidationInfo? {
        
        let validators = await validators.value
        
        for validator in validators {
            
            if case .failure(let info) = validator(data, response) { return info }
        }
        return nil
    }
    
    private func retry(validationInfo: ValidationInfo, response: URLResponse, data: Data) async throws -> (Data, URLResponse) {
        
        guard let retrier = retrier() else { return (data, response) }
        
        let retryCondition = try await retrier.retry(validationInfo: validationInfo, request: currentRequest(), response: response, data: data)
        
        switch retryCondition {
        case .retryImediately(let request):
            await self.requestIsUpdated(request: request)
            return try await perform()
        case .retryWithDelay(let request, let delayAmount):
            await self.requestIsUpdated(request: request)
            try await Task.sleep(nanoseconds: UInt64(delayAmount * 1_000_000_000))
            return try await perform()
        case .finish, .doNotRetry:
            return (data, response)
        }
    }
}
