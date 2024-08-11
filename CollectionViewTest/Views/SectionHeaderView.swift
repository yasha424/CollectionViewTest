//
//  SectionHeader.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 11/8/24.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {

    var label: UILabel = {
        let label: UILabel = UILabel()
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(label)

        label.snp.makeConstraints { make in
            make.top.right.equalTo(self)
            make.left.equalTo(self).offset(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
