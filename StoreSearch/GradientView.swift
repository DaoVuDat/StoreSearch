//
//  GradientView.swift
//  StoreSearch
//
//  Created by DaoVuDat on 3/5/20.
//  Copyright © 2020 DaoVuDat. All rights reserved.
//

import Foundation
import UIKit


class GradientView: UIView {
    
    // init the class with the clear background (transparent and grayscale are equal 0.0)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
    }
    
    // this initializer is called from storyboard -> compulsory method for customizing UIView
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
    
    // drawing this view -> drawing gradient color
    // we could instantialize the gradient component by using LAZY LOADING
    // if the UIView call draw method too much -> could decrease the performance
    override func draw(_ rect: CGRect) {
    
        // 2 color here, which are black with 30% opacity and black with 70 opacity
        // gradient will be from 30% opacity to 70% opacity
        let colorComponents: [CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7]
        let locations: [CGFloat] = [0, 1] // location of
        
        // create RGB color space which is dependent of RGB of device
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // create gradient space from color space, color components, locations and count (number of locations)
        let gradient = CGGradient(colorSpace: colorSpace,
                                  colorComponents: colorComponents,
                                  locations: locations,
                                  count: 2)
        
        // creating the circle gradient effect at the center of UIView
        let x = bounds.midX // bound rectangle of its view's location and sizes
        let y = bounds.midY
        
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x,y)
        
        
        // drawing the gradient effect
        let context = UIGraphicsGetCurrentContext() // get the current context of this view -> return the optional
        // drawing radial gradient not linear one
        context?.drawRadialGradient(gradient!,
                                    startCenter: centerPoint, startRadius: 0,
                                    endCenter: centerPoint, endRadius: radius,
                                    options: .drawsAfterEndLocation)
            
    }
    
}
