//
//  PinchZoomContext.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

struct PinchZoomContext<Content>: View where Content: View {
    private var content: Content

    @Binding private var offset: CGPoint
    @Binding private var scale: CGFloat
    @Binding private var scalePosition: CGPoint

    init(offset: Binding<CGPoint>,
         scale: Binding<CGFloat>,
         scalePosition: Binding<CGPoint>,
         @ViewBuilder _ content: () -> Content
    ) {
        _offset = offset
        _scale = scale
        _scalePosition = scalePosition
        self.content = content()
    }

    var body: some View {
        content
            .offset(x: offset.x, y: offset.y)
            .overlay {
                GeometryReader { proxy in
                    ZoomGesture(
                        size: proxy.size,
                        offset: $offset,
                        scale: $scale,
                        scalePosition: $scalePosition
                    )
                }
            }
            .scaleEffect(
                1 + limitScale,
                anchor: .init(
                    x: scalePosition.x,
                    y: scalePosition.y
                )
            )
            .onChange(of: scale) { newValue in
                if newValue == -1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        scale = .zero
                    }
                }
            }
    }

    private var limitScale: CGFloat {
        if scale < 0 {
            return 0
        }
        if scale > 4 {
            return 4
        }
        return scale
    }
}
