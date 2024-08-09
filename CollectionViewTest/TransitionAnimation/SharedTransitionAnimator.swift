//
//  SharedTransitionAnimator.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import UIKit

protocol SharedTransitioning {
    var sharedFrame: CGRect { get }
}

class SharedTransitionAnimator: NSObject {

    enum Transition {
        case push, pop
    }

    var transition: Transition = .push

    private let transitionDuration = 0.4
    private let animation = UIView.AnimationOptions.curveEaseInOut
}


extension SharedTransitionAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        if transition == .push {
            pushAnimation(context: transitionContext)
        } else {
            popAnimation(context: transitionContext)
        }
    }

    private func pushAnimation(context: UIViewControllerContextTransitioning) {
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
            return
        }

        let transform: CGAffineTransform = .transform(
            parent: toView.frame,
            soChild: toFrame,
            aspectFills: fromFrame
        )
        toView.transform = transform

        let maskFrame = fromFrame.aspectFit(to: toFrame)
        let mask = UIView(frame: maskFrame)
        mask.layer.cornerCurve = .continuous
        mask.backgroundColor = .black
        toView.mask = mask

        let placeholder = UIView()
        placeholder.backgroundColor = .white
        placeholder.frame = fromFrame
        fromView.addSubview(placeholder)

        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.layer.opacity = 0
        overlay.frame = fromView.frame
        fromView.addSubview(overlay)

        UIView.animate(withDuration: transitionDuration, delay: 0, options: [animation]) {
            toView.transform = .identity
            mask.frame = toView.frame
            mask.layer.cornerRadius = 39
            overlay.layer.opacity = 0.5
        } completion: { _ in
            toView.mask = nil
            overlay.removeFromSuperview()
            placeholder.removeFromSuperview()
            context.completeTransition(true)
        }
    }

    private func popAnimation(context: UIViewControllerContextTransitioning) {
        guard let (fromView, fromFrame, toView, toFrame) = setup(with: context) else {
            context.completeTransition(false)
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
        placeholder.backgroundColor = .white
        placeholder.frame = toFrame
        toView.addSubview(placeholder)

        let overlay = UIView()
        overlay.backgroundColor = .black
        overlay.frame = toView.frame
        overlay.layer.cornerRadius = 39
        toView.addSubview(overlay)

        let maskFrame = toFrame.aspectFit(to: fromFrame)

        UIView.animate(withDuration: transitionDuration, delay: 0, options: [animation]) {
            fromView.transform = transform
            mask.frame = maskFrame
            mask.layer.cornerRadius = 0
            overlay.layer.opacity = 0
        } completion: { _ in
            overlay.removeFromSuperview()
            placeholder.removeFromSuperview()
            let isCancelled = context.transitionWasCancelled
            context.completeTransition(!isCancelled)
        }
    }

    private func setup(with context: UIViewControllerContextTransitioning) -> (UIView, CGRect, UIView, CGRect)? {
        guard let toView = context.view(forKey: .to),
              let fromView = context.view(forKey: .from) else {
            return nil
        }

        if transition == .push {
            context.containerView.addSubview(toView)
        } else {
            context.containerView.insertSubview(toView, belowSubview: fromView)
        }

        guard let toFrame = context.sharedFrame(forKey: .to),
              let fromFrame = context.sharedFrame(forKey: .from) else {
            return nil
        }

        return (fromView, fromFrame, toView, toFrame)
    }

}
