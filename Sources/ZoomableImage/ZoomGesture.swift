//
//  ZoomGesture.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

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

    func updateUIView(_ uiView: UIView, context: Context) {}

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
