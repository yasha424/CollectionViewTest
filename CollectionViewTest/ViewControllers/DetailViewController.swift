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


    init(characterDetails: CharacterDetails) {
        self.characterDetails = characterDetails

        super.init(nibName: nil, bundle: nil)

        self.view.backgroundColor = .systemBackground

        setupImageView()
        setupTitleView()
        setupScrollView()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutImageView()
        layoutTitleView()
        layoutScrollView()
        layoutDescriptionTextView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        self.view.addSubview(imageView)

        imageView.image = UIImage(named: characterDetails.imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        layoutImageView()
    }

    func layoutImageView() {
        imageView.snp.removeConstraints()

        imageView.snp.makeConstraints { make in
            if UIDevice.current.orientation == .portrait {
                make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
                make.height.equalTo(200)
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
                make.height.equalTo(20)
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

}


extension DetailViewController: SharedTransitioning {

    var sharedFrame: CGRect {
        imageView.frameInWindow ?? .zero
    }

}
