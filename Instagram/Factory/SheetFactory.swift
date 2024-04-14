//
//  SheetFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/27.
//

import UIKit

enum SheetFactory {
    
    static func makeSheetVC(vc: UIViewController) -> UIViewController {
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.largestUndimmedDetentIdentifier = .large
        }
        
        return vc
    }
    
    static func makeLargeSheetVC(vc: UIViewController) -> UIViewController {
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
            sheet.selectedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.largestUndimmedDetentIdentifier = .none
        }
        
        return vc
    }
    
}   
