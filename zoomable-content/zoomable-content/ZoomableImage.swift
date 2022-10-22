//
//  ZoomableImage.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

struct ZoomableImage: View {
    private let image: Image

    init(@ViewBuilder _ image: () -> Image) {
        self.image = image()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                background(proxy: proxy)
                image(proxy: proxy)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func background(proxy: GeometryProxy) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .offset(x: 0)
            .clipped()
            .blur(radius: 50)
    }

    @ViewBuilder
    private func image(proxy: GeometryProxy) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: proxy.size.width, alignment: .center)
    }
}

struct ZoomableImage_Previews: PreviewProvider {
    static var previews: some View {
        ZoomableImage {
            Image("iphones")
        }
        .ignoresSafeArea()
    }
}
