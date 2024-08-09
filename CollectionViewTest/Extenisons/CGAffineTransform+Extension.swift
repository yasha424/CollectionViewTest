//
//  CGAffineTransform+Extension.swift
//  CollectionViewTest
//
//  Created by Yakiv Serhiienko on 9/8/24.
//

import CoreGraphics

extension CGAffineTransform {
    
    static func transform(parent: CGRect,
                          soChild child: CGRect,
                          matches rect: CGRect) -> Self {
        let scaleX = rect.width / child.width
        let scaleY = rect.height / child.height
        
        let offsetX = rect.midX - parent.midX
        let offsetY = rect.midY - parent.midY
        let centerOffsetX = (parent.midX - child.midX) * scaleX
        let centerOffsetY = (parent.midY - child.midY) * scaleY
        
        let translateX = offsetX + centerOffsetX
        let translateY = offsetY + centerOffsetY
        
        let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let translate = CGAffineTransform(translationX: translateX, y: translateY)
        
        return scale.concatenating(translate)
    }
    
    static func transform(parent: CGRect,
                          soChild child: CGRect,
                          aspectFills rect: CGRect) -> Self {
        // 1.
        let childRatio = child.width / child.height
        let rectRatio = rect.width / rect.height
        
        let scaleX = rect.width / child.width
        let scaleY = rect.height / child.height
        
        // 2.
        let scaleFactor = rectRatio < childRatio ? scaleY : scaleX
        
        let offsetX = rect.midX - parent.midX
        let offsetY = rect.midY - parent.midY
        let centerOffsetX = (parent.midX - child.midX) * scaleFactor
        let centerOffsetY = (parent.midY - child.midY) * scaleFactor
        
        let translateX = offsetX + centerOffsetX
        let translateY = offsetY + centerOffsetY
        
        let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let translateTransform = CGAffineTransform(translationX: translateX, y: translateY)
        
        return scaleTransform.concatenating(translateTransform)
    }
    
}
