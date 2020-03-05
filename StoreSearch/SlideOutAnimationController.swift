//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/5/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation
import UIKit

// UIViewControllerAnimatedTransitioning is creating animation for custom view transition
class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let containerView = transitionContext.containerView
            let time = transitionDuration(using: transitionContext)
            
            // only one animation -> using animate
            UIView.animate(withDuration: time, animations: {
                fromView.center.y -= containerView.bounds.size.height // move upward (vertically) 50% of container view
                fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) // scale to 50% of view
            }, completion: {
                finished in
                transitionContext.completeTransition(finished)
            })
        }
    }
    
    
}
