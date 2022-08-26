//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Playback states.
public enum PlaybackState: Equatable {
    /// The player is idle.
    case idle
    /// The player is currently playing content.
    case playing
    /// The player has been paused.
    case paused
    /// The player ended playback of an item.
    case ended
    /// The player encountered an error.
    case failed(error: Error)

    static func publisher(for player: AVPlayer) -> AnyPublisher<PlaybackState, Never> {
        Publishers.CombineLatest(
            ItemState.publisher(for: player),
            ratePublisher(for: player)
        )
        .map { state(for: $0, rate: $1) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    static func ratePublisher(for player: AVPlayer) -> AnyPublisher<Float, Never> {
        player.publisher(for: \.rate)
            .eraseToAnyPublisher()
    }

    private static func state(for itemState: ItemState, rate: Float) -> PlaybackState {
        switch itemState {
        case .readyToPlay:
            return (rate == 0) ? .paused : .playing
        case let .failed(error: error):
            return .failed(error: error)
        case .ended:
            return .ended
        case .unknown:
            return .idle
        }
    }

    // Ignore differences between errors (different errors should never occur in practice for the same session anyway).
    public static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended), (.failed, .failed):
            return true
        default:
            return false
        }
    }
}