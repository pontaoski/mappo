import XCTest
import class Foundation.Bundle
import MappoCore

final class MappoTests: XCTestCase {
    func testExample() throws {
        if let roles = Role.generateRoles(partySize: 5) {
            print(roles)
        } else {
            print("failed :(")
        }
    }
}
