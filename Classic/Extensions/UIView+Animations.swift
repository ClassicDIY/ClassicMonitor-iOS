//
//  UIView+Animations.swift
//  Classic
//
//  Created by Urayoan Miranda on 10/8/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
import UIKit

//https://stackoverflow.com/questions/31478630/animate-rotation-uiimageview-in-swift/50157504
//https://www.raywenderlich.com/5976-uiview-animations-tutorial-practical-recipes

extension UIView {
    func spin(value: CGFloat) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue        = value
        rotation.duration       = 1
        rotation.isCumulative   = false
        rotation.repeatCount    = Float.nan
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func move(to destination: CGPoint, duration: TimeInterval,options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.center = destination
        }, completion: nil)
    }
    
    //MARK: Usage - button.rotate180(duration: 1.0, options: selectedCurve.animationOption)
    func rotate180(duration: TimeInterval, options: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = self.transform.rotated(by: CGFloat.pi)
        }, completion: nil)
    }
    
    //MARK: Usage - button.rotate(rotation: CGFloat.pi, duration: 1.0, options: selectedCurve.animationOption)
    func rotateCustom(rotation: CGFloat ,duration: TimeInterval, options: UIView.AnimationOptions) {
      UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
        self.transform = CGAffineTransform(rotationAngle: rotation)//self.transform.rotated(by: rotation)
      }, completion: nil)
    }
}
