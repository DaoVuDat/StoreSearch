//
//  BounceAnimationController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/5/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation
import UIKit

// this animates "ViewController" not a UIView -> inherit NSObject and conform UIViewControllerAnimatedTransitioning
class BounceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
   
    // need to override 2 methods which are duration of transition and how transition works
    // duration of transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4 // duration of transition = 0.4s
    }
    
    // how transition works
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to){
            
            let containerView = transitionContext.containerView
            toView.frame = transitionContext.finalFrame(for: toViewController) // location and size of view in ITS superview ===> in this situation, FINAL location and size of THAT VIEW
            
            containerView.addSubview(toView) // we must addSubView with View to container (in presenting) to show on screen
            toView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7) // setting initial view which is 70% of origin
            
            // many serial animations -> using key frames
            // animate key frames of CURRENT view
            UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext),
                                    delay: 0,
                                    options: .calculationModeCubic,
                                    animations: {
                                        // list of animation by adding keyframe
                                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.334,
                                            animations: {
                                            toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                                        })
                                    
                                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.333, animations: {
                                            toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                        })
                                            
                                        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.333, animations: {
                                            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                        })
            
                                    },
                                    completion: {
                                        finished in
                                        transitionContext.completeTransition(finished)
                                    })
        }
    }
    
    
}
