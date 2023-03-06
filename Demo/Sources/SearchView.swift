//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel
import SwiftUI

struct SearchView: View {
    @StateObject private var model = SearchViewModel()

    var body: some View {
        ZStack {
            switch model.state {
            case .empty:
                MessageView(message: "Enter something to search.", icon: .search)
            case .loading:
                ProgressView()
            case let .loaded(medias: medias):
                loadedView(medias)
            case let .failed(error):
                RefreshableMessageView(model: model, message: error.localizedDescription, icon: .error)
            }
        }
        .animation(.linear(duration: 0.2), value: model.state)
        .navigationTitle("Search")
        .searchable(text: $model.text)
#if os(iOS)
        .searchScopes($model.vendor) {
            ForEach([SRGVendor.SRF, .RTS, .RSI, .RTR, .SWI], id: \.self) { vendor in
                Text(vendor.name).tag(vendor)
            }
        }
#endif
    }

    @ViewBuilder
    private func loadedView(_ medias: [SRGMedia]) -> some View {
        if !medias.isEmpty {
            List(medias, id: \.urn) { media in
                let title = MediaDescription.title(for: media)
                Cell(title: title, subtitle: MediaDescription.subtitle(for: media), style: MediaDescription.style(for: media)) {
                    PlayerView(media: Media(title: media.title, type: .urn(media.urn)))
                }
                .onAppear {
                    if let index = medias.firstIndex(of: media), medias.count - index < kPageSize {
                        model.loadMore()
                    }
                }
#if os(iOS)
                .swipeActions { CopyButton(text: media.urn) }
#endif
            }
            .scrollDismissesKeyboard(.immediately)
            .refreshable { await model.refresh() }
        }
        else {
            RefreshableMessageView(model: model, message: "No results.", icon: .empty)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
        }
    }
}