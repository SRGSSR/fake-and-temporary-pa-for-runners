//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble

final class CommandersActStreamingAnalyticsLiveTests: CommandersActTestCase {
    func testInitialPosition() {
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            _ = CommandersActStreamingAnalytics(streamType: .live) { .empty }
        }
    }

    func testPositionAfterPause() {
        let analytics = CommandersActStreamingAnalytics(streamType: .live) { .empty }
        wait(for: .seconds(3))
        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics.notify(.pause)
        }
    }

    func testPositionWhenDestroyedAfterPlay() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) { .empty }
        _ = analytics
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(1))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedDuringBuffering() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) { .empty }

        analytics?.notify(isBuffering: true)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }

    func testPositionWhenDestroyedAfterPause() {
        var analytics: CommandersActStreamingAnalytics? = .init(streamType: .live) { .empty }

        wait(for: .seconds(3))
        analytics?.notify(.pause)
        wait(for: .seconds(1))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(3))
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            analytics = nil
        }
    }
}