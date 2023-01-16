//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import OrderedCollections
import Player

final class PlaylistViewModel: ObservableObject {
    static let standardTemplates = [
        URLTemplate.onDemandVideoHLS,
        URLTemplate.shortOnDemandVideoHLS,
        URLTemplate.onDemandVideoMP4,
        URLTemplate.liveVideoHLS,
        URLTemplate.dvrVideoHLS,
        URLTemplate.liveTimestampVideoHLS,
        URLTemplate.onDemandAudioMP3,
        URLTemplate.liveAudioMP3,
        URNTemplate.onDemandHorizontalVideo,
        URNTemplate.onDemandSquareVideo,
        URNTemplate.onDemandVerticalVideo,
        URNTemplate.liveVideo,
        URNTemplate.dvrVideo,
        URNTemplate.dvrAudio,
        URNTemplate.onDemandAudio,
        URLTemplate.appleBasic_4_3_HLS,
        URLTemplate.appleBasic_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_TS_HLS,
        URLTemplate.appleAdvanced_16_9_fMP4_HLS,
        URLTemplate.appleAdvanced_16_9_HEVC_h264_HLS,
        URNTemplate.tokenProtectedVideo,
        URNTemplate.superfluouslyTokenProtectedVideo,
        URNTemplate.drmProtectedVideo,
        URNTemplate.expired,
        URNTemplate.unknown
    ]

    @Published var currentMedia: Media? {
        didSet {
            guard let currentMedia, let index = items.keys.firstIndex(of: currentMedia) else { return }
            try? player.setCurrentIndex(index)
        }
    }

    @Published private var items = OrderedDictionary<Media, PlayerItem>() {
        didSet {
            player.items = items.values.elements
        }
    }

    let player = Player(configuration: .standard)

    var medias: [Media] {
        get {
            Array(items.keys)
        }
        set {
            items = Self.updated(initialItems: items, with: newValue)
        }
    }

    var otherStandardTemplates: [Template] {
        Array(OrderedSet(Self.standardTemplates).subtracting(OrderedSet(templates)))
    }

    var templates: [Template] = [] {
        didSet {
            medias = Template.medias(from: templates)
        }
    }

    var isEmpty: Bool {
        medias.isEmpty
    }

    var canReload: Bool {
        !templates.isEmpty
    }

    init() {
        configureCurrentItemPublisher()
    }

    private static func updated(
        initialItems: OrderedDictionary<Media, PlayerItem>,
        with medias: [Media]
    ) -> OrderedDictionary<Media, PlayerItem> {
        var items = initialItems
        let changes = medias.difference(from: initialItems.keys).inferringMoves()
        changes.forEach { change in
            switch change {
            case let .insert(offset: offset, element: element, associatedWith: associatedWith):
                if let associatedWith {
                    let previousPlayerItem = initialItems.elements[associatedWith].value
                    items.updateValue(previousPlayerItem, forKey: element, insertingAt: offset)
                }
                else {
                    items.updateValue(element.playerItem(), forKey: element, insertingAt: offset)
                }
            case let .remove(offset: offset, element: _, associatedWith: _):
                items.remove(at: offset)
            }
        }
        return items
    }

    func add(from templates: [Template]) {
        medias += Template.medias(from: templates)
    }

    func canReturnToPreviousItem() -> Bool {
        player.canReturnToPreviousItem()
    }

    func returnToPreviousItem() {
        player.returnToPreviousItem()
    }

    func shuffle() {
        items.shuffle()
    }

    func reload() {
        medias = Template.medias(from: templates)
    }

    func trash() {
        medias = []
    }

    func canAdvanceToNextItem() -> Bool {
        player.canAdvanceToNextItem()
    }

    func advanceToNextItem() {
        player.advanceToNextItem()
    }

    private func configureCurrentItemPublisher() {
        Publishers.CombineLatest(player.$currentIndex, $items)
            .map { index, items in
                guard let index, index < items.count else { return nil }
                return items.keys[index]
            }
            .assign(to: &$currentMedia)
    }
}