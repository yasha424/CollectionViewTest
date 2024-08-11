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
        contentView.backgroundColor = .systemBackground

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
            guard 0.3...3.0 ~= imageView.transform.a || pinchRecognizer.scale < 1 else { return }

            let pinchCenter = CGPoint(x: pinchRecognizer.location(in: imageView).x - imageView.bounds.midX,
                                      y: pinchRecognizer.location(in: imageView).y - imageView.bounds.midY)
            let transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: pinchRecognizer.scale, y: pinchRecognizer.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            imageView.transform = transform
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
        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first!

        switch recognizer.state {
        case .began:
            interactionController = SharedTransitionInteractionController()
            navigationController?.popViewController(animated: true)
        case .changed:
            interactionController?.update(recognizer)
        case .ended:
            if recognizer.velocity(in: window).x > 0 || recognizer.velocity(in: window).y > 0 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
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
