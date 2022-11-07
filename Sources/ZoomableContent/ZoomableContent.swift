//
//  ZoomableImage.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

public struct ZoomableContent<Content>: View where Content: View {
    @Environment(\.safeAreaInsets)
    private var safeAreaInsets
    @Binding
    private var isVisible: Bool
    @State
    private var offset: CGPoint = .zero
    @State
    private var backgroundOpacity: CGFloat = 1
    @State
    private var scale: CGFloat = .zero
    @State
    private var scalePosition: CGPoint = .zero
    private let image: Content

    public init(isVisible: Binding<Bool>, @ViewBuilder _ image: () -> Content) {
        self.image = image()
        _isVisible = isVisible
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                background(size: proxy.size)
                closeButton
                image(size: proxy.size)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func background(size: CGSize) -> some View {
        let offsetX = (offset.x + scalePosition.x) / 1.5
        let blurRadius: CGFloat = 50
        image
            .aspectRatio(contentMode: .fill)
            .frame(
                width: size.width + blurRadius * 2,
                height: size.height + blurRadius * 2 + safeAreaInsets.top)
            .offset(x: offsetX)
            .clipped()
            .blur(radius: blurRadius / 2)
            .overlay {
                Rectangle()
                    .fill(.black)
                    .opacity(0.2)
                    .ignoresSafeArea()
            }
            .padding(.horizontal, -blurRadius)
            .padding(.vertical, -blurRadius)
            .opacity(backgroundOpacity)
            .onTapGesture {
                withAnimation {
                    isVisible = false
                }
            }
    }

    @ViewBuilder
    private var closeButton: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .renderingMode(.template)
                        .tint(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                }
                .padding(.top, safeAreaInsets.top)
                .padding(16)
                Spacer()
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func image(size: CGSize) -> some View {
        PinchZoomContext(
            offset: $offset,
            backgroundOpacity: $backgroundOpacity,
            scale: $scale,
            scalePosition: $scalePosition,
            isVisible: $isVisible,
            totalHeight: size.height
        ) {
            image
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: size.width, alignment: .center)
        }
    }
}
