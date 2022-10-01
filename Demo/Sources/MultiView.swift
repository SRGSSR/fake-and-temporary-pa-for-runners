//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player
import SwiftUI
import UserInterface

// MARK: View

struct MultiView: View {
    @StateObject private var topPlayer = Player()
    @StateObject private var bottomPlayer = Player()

    var body: some View {
        VStack {
            Group {
                PlaybackView(player: topPlayer)
                PlaybackView(player: bottomPlayer)
            }
            .background(.black)
        }
        .onAppear {
            Self.play(
                url: Stream.appleBasic_16_9,
                in: topPlayer
            )
            Self.play(
                url: Stream.appleAdvanced_16_9_HEVC_h264,
                in: bottomPlayer
            )
        }
    }

    private static func play(url: URL, in player: Player) {
        player.append(AVPlayerItem(url: url))
        player.play()
    }
}

// MARK: Preview

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MultiView()
    }
}