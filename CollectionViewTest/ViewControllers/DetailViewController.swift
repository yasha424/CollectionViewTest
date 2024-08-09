//
//  DetailViewController.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 8/8/24.
//

import UIKit

class DetailViewController: UIViewController {

    let characterDetails: CharacterDetails

    let imageView = UIImageView()
    let titleView = UILabel()
    let scrollView = UIScrollView()
    let descriptionTextView = UILabel()

    private let transitionAnimator = SharedTransitionAnimator()
    private var interactionController: SharedTransitionInteractionController?
    private lazy var recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))

    init(characterDetails: CharacterDetails) {
        self.characterDetails = characterDetails

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

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

    private func setupImageView() {
        self.view.addSubview(imageView)

        imageView.image = UIImage(named: characterDetails.imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true

        layoutImageView()
    }

    func layoutImageView() {
        imageView.snp.removeConstraints()

        imageView.snp.makeConstraints { make in
            if UIDevice.current.orientation == .portrait {
                make.top.left.right.equalTo(self.view)//.safeAreaLayoutGuide)
                make.height.equalTo(260)
            } else {
                make.top.left.equalTo(self.view.safeAreaLayoutGuide)
                make.width.equalTo(self.view.safeAreaLayoutGuide.layoutFrame.width / 2)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-60)
            }
        }
    }

    private func setupTitleView() {
        self.view.addSubview(titleView)

        titleView.text = characterDetails.title
        titleView.font = .boldSystemFont(ofSize: 24)

        layoutTitleView()
    }

    func layoutTitleView() {
        titleView.snp.removeConstraints()

        titleView.snp.makeConstraints { make in
            if UIDevice.current.orientation == .portrait {
                make.top.equalTo(imageView.snp.bottom).offset(20)
                make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
                make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            } else {
                make.bottom.left.equalTo(self.view.safeAreaLayoutGuide)
                make.height.equalTo(30)
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
        scrollView.snp.removeConstraints()

        scrollView.snp.makeConstraints { make in
            if UIDevice.current.orientation == .portrait {
                make.top.equalTo(titleView.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            } else {
                make.left.equalTo(imageView.snp.right).offset(20)
                make.top.right.bottom.equalToSuperview()
            }
        }
    }

    private func layoutDescriptionTextView() {
        descriptionTextView.snp.removeConstraints()

        descriptionTextView.snp.makeConstraints { make in
            if UIDevice.current.orientation == .portrait {
                make.left.equalTo(self.view.safeAreaLayoutGuide).offset(10)
                make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
                make.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(20)
            } else {
                make.left.equalTo(imageView.snp.right).offset(20)
                make.right.equalTo(self.view.safeAreaLayoutGuide)
                make.bottom.equalToSuperview()
                make.top.equalToSuperview()
            }
        }
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last!

        switch recognizer.state {
        case .began:
            let velocity = recognizer.velocity(in: window)
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
        guard fromVC is Self, toVC is MainViewController else { return nil }
        transitionAnimator.transition = .pop
        return transitionAnimator
    }

    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        interactionController
    }
}
