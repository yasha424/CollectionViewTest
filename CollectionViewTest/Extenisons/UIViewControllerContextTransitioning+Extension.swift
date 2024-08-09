//
//  UIViewControllerContextTransitioning+Extension.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import UIKit

extension UIViewControllerContextTransitioning {
    func sharedFrame(forKey key: UITransitionContextViewControllerKey) -> CGRect? {
        let viewController = viewController(forKey: key)
        viewController?.view.layoutIfNeeded()
        return (viewController as? SharedTransitioning)?.sharedFrame
    }
}
