//
//  TVButtonAnimation.swift
//  TVButton
//
//  Created by Roy Marmelstein on 10/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import CoreMotion

/**
TVButtonAnimation class
 */
internal class TVButtonAnimation {
    
    let motion = CMMotionManager()
    
    
    var highlightMode = true
    weak var button: TVButton?

    init(button: TVButton) {
        self.button = button
    }
    
    // Movement begins
    func enterMovement() {
        guard !highlightMode, let tvButton = button else {
            return
        }
        
        self.highlightMode = true
        let targetShadowOffset = CGSize(width: 0.0, height: tvButton.bounds.size.height/shadowFactor)
        tvButton.layer.removeAllAnimations()
        CATransaction.begin()
        
        CATransaction.setCompletionBlock({ () -> Void in
            tvButton.layer.shadowOffset = targetShadowOffset
        })
        
        let shadowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shadowOffsetAnimation.toValue = NSValue(cgSize: targetShadowOffset)
        shadowOffsetAnimation.duration = animationDuration
        shadowOffsetAnimation.isRemovedOnCompletion = false
        shadowOffsetAnimation.fillMode = CAMediaTimingFillMode.forwards
        shadowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeOut"))
        tvButton.layer.add(shadowOffsetAnimation, forKey: "shadowOffset")
        
        let shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        shadowOpacityAnimation.toValue = 0.6
        shadowOpacityAnimation.duration = animationDuration
        shadowOpacityAnimation.isRemovedOnCompletion = false
        shadowOpacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        shadowOpacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeOut"))
        tvButton.layer.add(shadowOpacityAnimation, forKey: "shadowOpacityAnimation")
        
        CATransaction.commit()
    }
    
    // Movement continues
    func processMovement(_ attitude: CMAttitude){
        guard highlightMode, let tvButton = button else { return }
        
//        let offsetX = point.x / tvButton.bounds.size.width
//        let offsetY = point.y / tvButton.bounds.size.height
//        let dx = point.x - tvButton.bounds.size.width/2
//        let dy = point.y - tvButton.bounds.size.height/2

        //print("oX: \(offsetX), oY: \(offsetY)")
        //print("dX: \(dx), dY: \(dy)")
        
//        let xRotation = (dy - offsetY)*(rotateXFactor/tvButton.bounds.size.width)
//        let yRotation = (offsetX - dx)*(rotateYFactor/tvButton.bounds.size.width)
//        let zRotation = (xRotation + yRotation)/rotateZFactor
        
        //let xTranslation = (-2*point.x/tvButton.bounds.size.width)*maxTranslationX
        //let yTranslation = (-2*point.y/tvButton.bounds.size.height)*maxTranslationY
        
        
        let pitch = attitude.pitch > 0 ? min(attitude.pitch, 0.261799) : max(attitude.pitch, -0.261799)
        let roll = attitude.roll > 0 ? min(attitude.roll, 0.261799) : max(attitude.roll, -0.261799)
        let yaw = attitude.yaw > 0 ? min(attitude.yaw, 0.261799) : max(attitude.yaw, -0.261799)
        
        let xRotateTransform = CATransform3DMakeRotation(-CGFloat(pitch), 1, 0, 0)
        let yRotateTransform = CATransform3DMakeRotation(CGFloat(roll), 0, 1, 0)
        let zRotateTransform = CATransform3DMakeRotation(-CGFloat(yaw), 0, 0, 0)
        
        let combinedRotateTransformXY = CATransform3DConcat(xRotateTransform, yRotateTransform)
        let combinedRotateTransformXYZ = CATransform3DConcat(combinedRotateTransformXY, zRotateTransform)
        //let translationTransform = CATransform3DMakeTranslation(-xTranslation, yTranslation, 0.0)
        //let combinedRotateTranslateTransform = CATransform3DConcat(combinedRotateTransformXYZ, translationTransform)
        
        //let targetScaleTransform = CATransform3DMakeScale(highlightedScale, highlightedScale, highlightedScale)
        
        //let combinedTransform = CATransform3DConcat(combinedRotateTranslateTransform, targetScaleTransform)
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            tvButton.layer.transform = combinedRotateTransformXYZ
            tvButton.specularView.alpha = specularAlpha
            //tvButton.specularView.center = point
            for i in 1 ..< tvButton.containerView.subviews.count {
                let adjusted = i/2
                let scale = 1 + maxScaleDelta*CGFloat(adjusted/tvButton.containerView.subviews.count)
                let subview = tvButton.containerView.subviews[i]
                if subview != tvButton.specularView {
                    subview.contentMode = UIView.ContentMode.redraw
                    subview.frame.size = CGSize(width: tvButton.bounds.size.width*scale, height: tvButton.bounds.size.height*scale)
                }
            }

            }, completion: nil)
//        UIView.animate(withDuration: 0.16, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
//            for i in 1 ..< tvButton.containerView.subviews.count {
//                let subview = tvButton.containerView.subviews[i]
//                let xParallax = tvButton.parallaxIntensity*parallaxIntensityXFactor
//                let yParallax = tvButton.parallaxIntensity*parallaxIntensityYFactor
//                if subview != tvButton.specularView {
//                    subview.center = CGPoint(x: tvButton.bounds.size.width/2 + xTranslation*CGFloat(i)*xParallax, y: tvButton.bounds.size.height/2 + yTranslation*CGFloat(i)*0.3*yParallax)
//                }
//            }
//        }, completion: nil)
    }
    
    // Movement ends
    func exitMovement() {
        guard highlightMode, let tvButton = button else { return }
    
        let targetShadowOffset = CGSize(width: 0.0, height: shadowFactor/3)
        let targetScaleTransform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        tvButton.specularView.layer.removeAllAnimations()
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            tvButton.layer.transform = targetScaleTransform
            tvButton.layer.shadowOffset = targetShadowOffset
            self.highlightMode = false
        })
        let shaowOffsetAnimation = CABasicAnimation(keyPath: "shadowOffset")
        shaowOffsetAnimation.toValue = NSValue(cgSize: targetShadowOffset)
        shaowOffsetAnimation.duration = animationDuration
        shaowOffsetAnimation.fillMode = CAMediaTimingFillMode.forwards
        shaowOffsetAnimation.isRemovedOnCompletion = false
        shaowOffsetAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeOut"))
        
        tvButton.layer.add(shaowOffsetAnimation, forKey: "shadowOffset")
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.toValue = NSValue(caTransform3D: targetScaleTransform)
        scaleAnimation.duration = animationDuration
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fillMode = CAMediaTimingFillMode.forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeOut"))
        tvButton.layer.add(scaleAnimation, forKey: "scaleAnimation")
        CATransaction.commit()
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            tvButton.transform = CGAffineTransform.identity
            tvButton.specularView.alpha = 0.0
            for i in 0 ..< tvButton.containerView.subviews.count {
                let subview = tvButton.containerView.subviews[i]
                subview.frame.size = CGSize(width: tvButton.bounds.size.width, height: tvButton.bounds.size.height)
                subview.center = CGPoint(x: tvButton.bounds.size.width/2, y: tvButton.bounds.size.height/2)
            }
            }, completion:nil)
    }
    
    // MARK: Convenience
    
    func degreesToRadians(_ value:CGFloat) -> CGFloat {
        return value * CGFloat(Double.pi) / 180.0
    }
    
    func startGyro() {
        if motion.isGyroAvailable {
            motion.gyroUpdateInterval = 1.0 / 2.0
            motion.startDeviceMotionUpdates(to: OperationQueue.main) {[weak self] data, error in
                guard let data = data, let self = self else {
                    print(error)
                    return
                }
                let roll = data.attitude.roll
                let pitch = data.attitude.pitch
                let yaw = data.attitude.yaw
                
                
                
                self.processMovement(data.attitude)

                print("roll: \(roll), pitch: \(pitch), yaw:\(yaw)")
            }
        }
    }
    
    
    func stopGyros() {
        if motion.isGyroActive {
            motion.stopGyroUpdates()
        }
    }

}
