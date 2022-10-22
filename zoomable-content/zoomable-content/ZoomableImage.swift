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
            .pinchZoom()
    }
}

extension View {
    func pinchZoom() -> some View {
        PinchZoomContext { self }
    }
}

struct PinchZoomContext<Content>: View where Content: View {
    private var content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    @State var offset: CGPoint = .zero
    @State var scale: CGFloat = .zero
    @State var scalePosition: CGPoint = .zero

    var body: some View {
        content
            .offset(x: offset.x, y: offset.y)
            .overlay {
                GeometryReader { proxy in
                    let size = proxy.size

                    ZoomGesture(
                        size: size,
                        offset: $offset,
                        scale: $scale,
                        scalePosition: $scalePosition
                    )
                }
            }
            .scaleEffect(
                1 + (scale < 0 ? 0 : scale),
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
}

struct ZoomGesture: UIViewRepresentable {
    var size: CGSize
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    @Binding var scalePosition: CGPoint

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePinch(sender:))
        )

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePan(sender:))
        )

        panGesture.delegate = context.coordinator

        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ZoomGesture

        init(parent: ZoomGesture) {
            self.parent = parent
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        @objc
        func handlePan(sender: UIPanGestureRecognizer) {
            sender.maximumNumberOfTouches = 2

            switch sender.state {
            case .began,
                 .changed:
                if let view = sender.view {
                    let translation = sender.translation(in: view)
                    parent.offset = translation
                }
            case .cancelled,
                 .ended,
                 .failed,
                 .possible:
                withAnimation {
                    parent.offset = .zero
                    parent.scalePosition = .zero
                }
            @unknown default:
                break
            }
        }

        @objc
        func handlePinch(sender: UIPinchGestureRecognizer) {
            switch sender.state {
            case .began,
                 .changed:
                parent.scale = sender.scale - 1

                let relativeScalePositionX = sender.location(in: sender.view).x / (sender.view?.frame.size.width ?? 1)

                let relativeScalePositionY = sender.location(in: sender.view).y / (sender.view?.frame.size.height ?? 1)

                let scalePosition = CGPoint(
                    x: relativeScalePositionX,
                    y: relativeScalePositionY
                )

                parent.scalePosition = parent.scalePosition == .zero ? scalePosition : parent.scalePosition

            case .cancelled,
                 .ended,
                 .failed,
                 .possible:
                withAnimation(.easeInOut(duration: 0.35)) {
                    parent.scale = -1
                    parent.scalePosition = .zero
                }
            @unknown default:
                break
            }
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
