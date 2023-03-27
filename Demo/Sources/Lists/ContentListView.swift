//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

// Behavior: h-exp, v-exp
private struct LoadedView: View {
    @ObservedObject var model: ContentListViewModel
    let contents: [ContentListViewModel.Content]
    @State private var isPresented = false

    var body: some View {
        List(contents, id: \.self) { content in
            ContentCell(content: content)
                .onAppear {
                    if let index = contents.firstIndex(of: content), contents.count - index < kPageSize {
                        model.loadMore()
                    }
                }
        }
        .toolbar(content: toolbar)
        .sheet(isPresented: $isPresented, content: playlist)
        .refreshable { await model.refresh() }
    }

    private func openPlaylist() {
        isPresented.toggle()
    }

    private func templates() -> [Template] {
        contents.compactMap { content -> Template? in
            guard case let .media(media) = content else { return nil }
            return Template(title: media.title, description: MediaDescription.subtitle(for: media), type: .urn(media.urn))
        }
    }

    @ViewBuilder
    private func playlist() -> some View {
        PlaylistView(templates: Array(templates().prefix(20)))
    }

    @ViewBuilder
    private func toolbar() -> some View {
        Button(action: openPlaylist) {
            Image(systemName: "rectangle.stack.badge.play")
        }
        .opacity(templates().isEmpty ? 0 : 1)
    }
}

// Behavior: h-hug, v-exp
private struct ContentCell: View {
    let content: ContentListViewModel.Content

    var body: some View {
        switch content {
        case let .topic(topic):
            NavigationLink(topic.title) {
                ContentListView(configuration: .init(kind: .latestMediasForTopic(topic), vendor: topic.vendor))
            }
#if os(iOS)
            .swipeActions { CopyButton(text: topic.urn) }
#endif
        case let .media(media):
            let title = MediaDescription.title(for: media)
            Cell(title: title, subtitle: MediaDescription.subtitle(for: media), style: MediaDescription.style(for: media)) {
                PlayerView(media: Media(title: title, type: .urn(media.urn)))
            }
#if os(iOS)
            .swipeActions { CopyButton(text: media.urn) }
#endif
        case let .show(show):
            NavigationLink(show.title) {
                ContentListView(configuration: .init(kind: .latestMediasForShow(show), vendor: show.vendor))
            }
#if os(iOS)
            .swipeActions { CopyButton(text: show.urn) }
#endif
        }
    }
}

// Behavior: h-exp, v-exp
struct ContentListView: View {
    let configuration: ContentListViewModel.Configuration
    @StateObject private var model = ContentListViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .loaded(contents: contents) where contents.isEmpty:
                RefreshableMessageView(model: model, message: "No content.", icon: .empty)
            case let .loaded(contents: contents):
                LoadedView(model: model, contents: contents)
            case let .failed(error):
                RefreshableMessageView(model: model, message: error.localizedDescription, icon: .error)
            }
        }
        .animation(.linear, value: model.state)
        .onAppear { model.configuration = configuration }
        .navigationTitle(configuration.kind.name)
    }
}

struct ContentListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentListView(configuration: .init(kind: .tvLatestMedias, vendor: .RTS))
        }
    }
}