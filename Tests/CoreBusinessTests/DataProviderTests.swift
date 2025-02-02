//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness

import PillarboxCircumspect
import XCTest

final class DataProviderTests: XCTestCase {
    func testExistingMediaMetadata() {
        expectSuccess(
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:6820736")
        )
    }

    func testNonExistingMediaMetadata() {
        expectFailure(
            DataError.http(withStatusCode: 404),
            from: DataProvider().mediaCompositionPublisher(forUrn: "urn:rts:video:unknown")
        )
    }
}
