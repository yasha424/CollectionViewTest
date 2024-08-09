//
//  DetailViewController.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 8/8/24.
//

import UIKit

class DetailViewController: UIViewController {

    let characterDetails: CharacterDetails

    private let imageView = UIImageView()
    private let titleView = UILabel()
    private let scrollView = UIScrollView()
    private let descriptionTextView = UILabel()

    private let transitionAnimator = SharedTransitionAnimator()
    private var interactionController: SharedTransitionInteractionController?
    private lazy var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))

    private var isChangingOrientation: Bool = false

    init(characterDetails: CharacterDetails) {
        self.characterDetails = characterDetails

        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        isChangingOrientation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
            self?.isChangingOrientation = false
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewLayoutMarginsDidChange()

        removeConstraints()

        layoutImageView()
        layoutTitleView()
        layoutScrollView()
        layoutDescriptionTextView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true
        self.view.addGestureRecognizer(recognizer)

        setupImageView()
        setupTitleView()
        setupScrollView()
    }

    private func removeConstraints() {
        descriptionTextView.snp.removeConstraints()
        scrollView.snp.removeConstraints()
        titleView.snp.removeConstraints()
        imageView.snp.removeConstraints()
    }

    private func setupImageView() {
        self.view.addSubview(imageView)

        imageView.image = UIImage(named: characterDetails.imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped)))

        layoutImageView()
    }

    @objc private func imageViewTapped() {
        self.navigationController?.pushViewController(ImageViewController(imageName: characterDetails.imageName), animated: true)
    }

    private func layoutImageView() {
        imageView.snp.makeConstraints { make in
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                make.top.left.equalTo(self.view.safeAreaLayoutGuide)
                make.width.equalTo(self.view.safeAreaLayoutGuide.layoutFrame.width / 2)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
            default:
                make.top.left.right.equalTo(self.view)
                make.height.equalTo(260)
            }
        }
    }

    private func setupTitleView() {
        self.view.addSubview(titleView)

        titleView.text = characterDetails.title
        titleView.font = .boldSystemFont(ofSize: 24)

        layoutTitleView()

        titleView.backgroundColor = .clear
    }

    private func layoutTitleView() {
        titleView.snp.makeConstraints { make in
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                make.bottom.left.equalTo(self.view.safeAreaLayoutGuide)
                make.height.equalTo(30)
            default:
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
                make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            }
        }

    }

    private func setupScrollView() {
        self.view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        layoutScrollView()

        descriptionTextView.text = characterDetails.description
        descriptionTextView.numberOfLines = 0
        descriptionTextView.textAlignment = .justified
        scrollView.addSubview(descriptionTextView)

        layoutDescriptionTextView()

        scrollView.addSubview(descriptionTextView)
    }

    private func layoutScrollView() {
        scrollView.snp.makeConstraints { make in
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                make.left.equalTo(imageView.snp.right).offset(20)
                make.top.right.bottom.equalToSuperview()
            default:
                make.top.equalTo(titleView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            }
        }
    }

    private func layoutDescriptionTextView() {
        descriptionTextView.snp.makeConstraints { make in
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                make.left.equalTo(imageView.snp.right).offset(20)
                make.right.equalTo(self.view.safeAreaLayoutGuide)
                make.bottom.equalToSuperview()
                make.top.equalToSuperview()
            default:
                make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
                make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
                make.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(20)
            }
        }
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


extension DetailViewController: SharedTransitioning {

    var sharedFrame: CGRect {
        imageView.frameInWindow ?? .zero
    }

}


extension DetailViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (fromVC is Self && toVC is MainViewController) {
            transitionAnimator.transition = .pop
        } else if fromVC is Self, toVC is ImageViewController {
            transitionAnimator.transition = .push
        }

        return transitionAnimator
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
