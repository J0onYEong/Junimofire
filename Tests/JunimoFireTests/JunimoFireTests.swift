import XCTest
@testable import JunimoFire

final class JunimoFireTests: XCTestCase {
    func testExample() throws {
        
        let exp1 = expectation(description: "Hello word")
        JF
            .request("https://666129ed63e6a0189fe8b1c9.mockapi.io/users")
            .response { _ in
                
                print("Hello world")
                exp1.fulfill()
            }
        
        waitForExpectations(timeout: 5)
    }
}
