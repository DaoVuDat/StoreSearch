//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/4/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation
import UIKit


// because of being used in DetailViewController, this UIPresentationController could set up
// model presentation's animation (in UIViewControllerTransitioningDelegate), background color, etc.
class DimmingPresentationController: UIPresentationController {
    
    // dimmingView is from GradientView
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    // presentation animation starts
    override func presentationTransitionWillBegin() {
        // frame for it's super view, bound for it's view
        // set parent's view = DimmingPresentationController
        dimmingView.frame = containerView!.bounds // setting dimmingView as large as containerView
        
        // add subview into DimmingPresentationController -> customize the view of Dimming...
        containerView!.insertSubview(dimmingView, at: 0)
        
        // this depends on Animation OBJECTS - must-have for "transitionCoordinator"
        // for animation of backgroundColor of the view
        dimmingView.alpha = 0
        // returning the active transition (presenting or dismissing)
        if let coordinator = presentedViewController.transitionCoordinator {
            // animating the animation in closure AT THE SAME TIME
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    // dismission animation starts
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        }
    }
}
