import XCTest
@testable import JunimoFire

class TestsessionDelegate: NSObject, URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

final class JunimoFireTests: XCTestCase {
    func testExample() async throws {
        
        struct UserDTO: Decodable {
            
            let name: String
            let age: String
            let id: String
        }
        
        let adapter = JFAdpater(label: "") { session, request in
            
            var modifierd = request
            
            modifierd.setValue("Bearer accesstoken", forHTTPHeaderField: "Authorization")
            
            return modifierd
        }
        
        let retrier = JFRetrier(label: "") { info, request, response, data in
            
            print(info)
            
            return .retryWithDelay(request: request, seconds: 5)
        }
        
        let interceptor = JFInterceptor.interceptor(adaper: adapter, retrier: retrier)
         
        let mySession = JuniosSession(
            configuration: .default,
            adapters: [adapter],
            retriers: [retrier],
            validators: [
                { data, response in
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        print(httpResponse.statusCode)
                    }
                    
    //                return .failure(info: .init(idenifier: 1, reason: "test reason"))
                    return .success
                }
            ]
        )
        
        var request = URLRequest(url: URL(string: "https://666129ed63e6a0189fe8b1c9.mockapi.io/users")!)
        request.httpMethod = "GET"
        
        let result = try await mySession
            .request(request: request)
            .responseDecodable(type: [UserDTO].self)
        
        print(result)
    }
}
