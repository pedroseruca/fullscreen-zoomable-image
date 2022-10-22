//
//  ZoomableImage.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

public struct ZoomableImage: View {
    private let image: Image

    @State private var offset: CGPoint = .zero
    @State private var scale: CGFloat = .zero
    @State private var scalePosition: CGPoint = .zero

    public init(@ViewBuilder _ image: () -> Image) {
        self.image = image()
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                background(size: proxy.size)
                image(size: proxy.size)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func background(size: CGSize) -> some View {
        let offsetX = (offset.x + scalePosition.x) / 1.5
        let blurRadius: CGFloat = 50
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: size.width + blurRadius,
                height: size.height + blurRadius * 2)
            .offset(x: offsetX)
            .clipped()
            .blur(radius: blurRadius / 2)
            .padding(.horizontal, -blurRadius / 2)
            .padding(.vertical, -blurRadius)
            .overlay {
                Rectangle()
                    .fill(.black)
                    .opacity(0.2)
                    .ignoresSafeArea()
            }
    }

    @ViewBuilder
    private func image(size: CGSize) -> some View {
        PinchZoomContext(
            offset: $offset,
            scale: $scale,
            scalePosition: $scalePosition
        ) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: size.width, alignment: .center)
        }
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
