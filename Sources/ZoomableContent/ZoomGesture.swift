//
//  ZoomGesture.swift
//  zoomable-content
//
//  Created by Pedro Seruca on 22/10/2022.
//

import SwiftUI

struct ZoomGesture: UIViewRepresentable {
    var size: CGSize
    var totalHeight: CGFloat

    @Binding var offset: CGPoint
    @Binding var backgroundOpacity: CGFloat
    @Binding var scale: CGFloat
    @Binding var scalePosition: CGPoint
    @Binding var isVisible: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self,
            totalHeight: totalHeight,
            isVisible: $isVisible
        )
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
        var totalHeight: CGFloat
        @Binding var isVisible: Bool

        init(
            parent: ZoomGesture,
            totalHeight: CGFloat,
            isVisible: Binding<Bool>) {
            self.parent = parent
            self.totalHeight = totalHeight
            _isVisible = isVisible
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

                    let backgroundOpacity = relativeTranslation(translationY: translation.y) / 1.6
                    parent.backgroundOpacity = max(1 - backgroundOpacity, 0)
                }
            case .cancelled,
                 .ended,
                 .failed,
                 .possible:

                let velocity = sender.velocity(in: sender.view)
                let target = sender.translation(in: sender.view).target(initialVelocity: velocity)

                if relativeTranslation(translationY: target.y) > 1 {
                    withAnimation(.linear(duration: 0.3)) {
                        parent.offset = target
                    }

                    Task {
                        try await Task.sleep(nanoseconds: 300_000_000)
                        await MainActor.run {
                            withAnimation {
                                isVisible = false
                            }
                        }
                    }
                } else {
                    withAnimation {
                        parent.offset = .zero
                        parent.scalePosition = .zero
                        parent.backgroundOpacity = 1
                    }
                }

            @unknown default:
                break
            }
        }

        func relativeTranslation(translationY: Double) -> CGFloat {
            let minimumDistance = totalHeight / 2
            return abs(translationY) / minimumDistance
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

private extension CGPoint {
    func target(initialVelocity: CGPoint, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGPoint {
        let x = self.x + self.x.target(initialVelocity: initialVelocity.x, decelerationRate: decelerationRate)
        let y = self.y + self.y.target(initialVelocity: initialVelocity.y, decelerationRate: decelerationRate)
        return CGPoint(x: x, y: y)
    }
}

private extension CGFloat {
    func target(initialVelocity: CGFloat, decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue) -> CGFloat {
        return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
    }
}
