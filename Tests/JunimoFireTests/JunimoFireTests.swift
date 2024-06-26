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
        
        var request = URLRequest(url: URL(string: "https://667c2cf33c30891b865ba28e.mockapi.io/users")!)
        request.httpMethod = "GET"
        
        let result = try await mySession
            .request(request: request)
            .responseDecodable(type: [UserDTO].self)
        
        print(result)
    }
}
