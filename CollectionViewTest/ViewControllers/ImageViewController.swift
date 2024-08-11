//
//  ImageViewController.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import UIKit

class ImageViewController: UIViewController {

    private let contentView = UIView()
    private let imageView = UIImageView()

    let imageName: String

    private let transitionAnimator = SharedTransitionAnimator()
    private var interactionController: SharedTransitionInteractionController?
    private lazy var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private var isChangingOrientation = false
    private lazy var pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(imagePinched))

    init(imageName: String) {
        self.imageName = imageName

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.delegate = self
        self.view.addGestureRecognizer(recognizer)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        isChangingOrientation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            self?.isChangingOrientation = false
        }
    }

    private func setup() {
        view.addSubview(contentView)
        contentView.addSubview(imageView)

        contentView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
        contentView.backgroundColor = .black

        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        imageView.image = UIImage(named: imageName)

        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        imageView.addGestureRecognizer(pinchRecognizer)
        imageView.isUserInteractionEnabled = true
    }

    @objc private func imagePinched() {
        switch pinchRecognizer.state {
        case .changed:
            let pinchCenter = CGPoint(x: pinchRecognizer.location(in: imageView).x - imageView.bounds.midX,
                                      y: pinchRecognizer.location(in: imageView).y - imageView.bounds.midY)

            let transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: pinchRecognizer.scale, y: pinchRecognizer.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                .translatedBy(x: pinchCenter.x, y: pinchCenter.y)

            UIView.animate(withDuration: 0.05) { [weak self] in
                self?.imageView.transform = transform
            }
            pinchRecognizer.scale = 1
        case .ended:
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.imageView.transform = .identity
            }

        default:
            return
        }
    }

    @objc private func viewTapped() {
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.contentView.backgroundColor = .systemBackground.withAlphaComponent(0)
        }

        navigationController?.popViewController(animated: true)
    }

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard !isChangingOrientation else { return }

        switch recognizer.state {
        case .began:
            interactionController = SharedTransitionInteractionController()
            navigationController?.popViewController(animated: true)
        case .changed:
            guard let interactionController else { return }
            interactionController.update(recognizer)
            let opacity = max(min(1 - interactionController.progress * 10, 1), 0)
            contentView.backgroundColor = .black.withAlphaComponent(opacity)
        case .ended:
            guard let interactionController else { return }
            if interactionController.progress > 0.1 {
                interactionController.finish()
            } else {
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.contentView.backgroundColor = .black
                }
                interactionController.cancel()
            }
            self.interactionController = nil
        default:
            interactionController?.cancel()
            interactionController = nil
        }
    }

}


extension ImageViewController: SharedTransitioning {

    var sharedFrame: CGRect {
        imageView.frameInWindow ?? .zero
    }

}


extension ImageViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fromVC is Self, toVC is DetailViewController else { return nil }
        transitionAnimator.transition = .pop
        return transitionAnimator
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
