//
//  SharedTransitionInteractionController.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import UIKit

class SharedTransitionInteractionController: NSObject {

    struct Context {
        var transitionContext: UIViewControllerContextTransitioning
        var fromFrame: CGRect
        var toFrame: CGRect
        var fromView: UIView
        var toView: UIView
        var mask: UIView
        var transform: CGAffineTransform
        var overlay: UIView
        var placeholder: UIView
    }

    private var context: Context?

}


extension SharedTransitionInteractionController: UIViewControllerInteractiveTransitioning {

    var wantsInteractiveStart: Bool { false }

    func startInteractiveTransition(_ transitionContext: any UIViewControllerContextTransitioning) {
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: transitionContext) else {
            transitionContext.completeTransition(false)
            return
        }

        let transform: CGAffineTransform = .transform(
            parent: fromView.frame,
            soChild: fromFrame,
            aspectFills: toFrame
        )

        let mask = UIView(frame: fromView.frame)
        mask.layer.cornerCurve = .continuous
        mask.backgroundColor = .black
        mask.layer.cornerRadius = 39
        fromView.mask = mask

        let placeholder = UIView()
        placeholder.frame = fromFrame
        placeholder.backgroundColor = .white
        toView.addSubview(placeholder)

        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.layer.opacity = 0.5
        overlay.frame = toView.frame
        toView.addSubview(overlay)

        context = Context(
            transitionContext: transitionContext,
            fromFrame: fromFrame,
            toFrame: toFrame,
            fromView: fromView,
            toView: toView,
            mask: mask,
            transform: transform,
            overlay: overlay,
            placeholder: placeholder
        )
    }

    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)? {
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else {
            return nil
        }
        context.containerView.insertSubview(toView, belowSubview: fromView)
        guard let toFrame = context.sharedFrame(forKey: .to),
              let fromFrame = context.sharedFrame(forKey: .from) else {
            return nil
        }
        return (fromView, fromFrame, toView, toFrame)
    }

    func update(_ recognizer: UIPanGestureRecognizer, _ completion: ((_ progress: CGFloat) -> Void)? = nil) {
        guard let context else { return }

        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last!
        let translation = recognizer.translation(in: window)
        let progress = abs(translation.x / window.frame.width) + abs(translation.y / window.frame.height)

        context.transitionContext.updateInteractiveTransition(progress)

        var scaleFactor = 1 - progress * 0.2
        scaleFactor = min(max(scaleFactor, 0.4), 1)


        context.fromView.transform = .init(scaleX: scaleFactor, y: scaleFactor)
            .translatedBy(x: translation.x, y: translation.y)

        completion?(progress)
    }

    func cancel() {
        guard let context else { return }

        context.transitionContext.cancelInteractiveTransition()

        UIView.animate(withDuration: 0.25) {
            context.fromView.transform = .identity
            context.mask.frame = context.fromView.frame
            context.mask.layer.cornerRadius = 39
            context.overlay.layer.opacity = 0.5
        } completion: { _ in

            context.overlay.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            context.toView.removeFromSuperview()

            context.transitionContext.completeTransition(false)
        }
    }

    func finish() {
        guard let context else { return }

        context.transitionContext.finishInteractiveTransition()

        let maskFrame = context.toFrame.aspectFit(to: context.fromFrame)
        UIView.animate(withDuration: 0.25) {
            context.fromView.transform = context.transform
            context.mask.frame = maskFrame
            context.mask.layer.cornerRadius = 0
            context.overlay.layer.opacity = 0
        } completion: { _ in
            context.overlay.removeFromSuperview()
            context.placeholder.removeFromSuperview()
            context.transitionContext.completeTransition(true)
        }
    }

}
