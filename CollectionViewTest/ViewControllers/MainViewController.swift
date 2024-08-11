//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 8/8/24.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var mockData = [[CharacterDetails]]()

    private var numberOfColumns = 3.0
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private var selectedIndexPath: IndexPath?

    private let transitionAnimator = SharedTransitionAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.isHidden = true

        layout.sectionInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 30)

        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        setupCollectionView()

        layoutCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        mockData = MockData.data
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        self.view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(self.view)
        }

        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        collectionView.register(CollectionCellView.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        layoutCollectionView()
    }

    private func layoutCollectionView() {
        let safeAreaWidth = view.frame.width - (view.safeAreaInsets.left + view.safeAreaInsets.right)

        numberOfColumns = Double(Int(safeAreaWidth / 150) + 1)

        let cellWidth = safeAreaWidth / numberOfColumns - (numberOfColumns - 1) / numberOfColumns
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
}


extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "sectionHeader",
                for: indexPath
            ) as? SectionHeaderView {
                sectionHeader.label.text = MockData.pirateTeams[indexPath.section]
                return sectionHeader
            }
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mockData[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let characterDetail = mockData[indexPath.section][indexPath.row]

        if let cell = cell as? CollectionCellView {
            cell.imageView.image = UIImage(named: characterDetail.imageName)
        }

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mockData.count
    }

}


extension MainViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        navigationController?.pushViewController(
            DetailViewController(characterDetails: mockData[indexPath.section][indexPath.row]),
            animated: true
        )
    }

}


extension MainViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        if fromVC is Self, toVC is DetailViewController {
            transitionAnimator.transition = .push
            return transitionAnimator
        }
        if toVC is Self, fromVC is DetailViewController {
            transitionAnimator.transition = .pop
            return transitionAnimator
        }
        return nil
    }

}


extension MainViewController: SharedTransitioning {

    var sharedFrame: CGRect {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else { return .zero }
        return frame
    }

}
