//
//  UIView+Extension.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import UIKit

extension UIView {
    var frameInWindow: CGRect? {
        superview?.convert(frame, to: nil)
    }
}
