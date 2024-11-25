//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Foundation
import Nimble
import PillarboxCircumspect
import PillarboxStreams
import XCTest

final class ErrorTests: XCTestCase {
    func testTruth() {
        expect(true).to(beTrue())
    }
}
