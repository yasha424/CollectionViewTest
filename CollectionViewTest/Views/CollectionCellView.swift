//
//  CollectionCellView.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 8/8/24.
//

import UIKit

class CollectionCellView: UICollectionViewCell {

    let imageView = UIImageView()


    override init(frame: CGRect) {
        super.init(frame: frame)

        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        self.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
    }

}
