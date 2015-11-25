//
//  Knob.swift
//  KnobDemo
//
//  Created by liuzhiyi on 15/11/10.
//  Copyright © 2015年 Mikael Konutgan. All rights reserved.
//

import UIKit

let π : CGFloat = CGFloat(M_PI)

class Knob: UIControl {

    private var backingValue : CGFloat = 0.0
    var minimumValue : CGFloat = 0.0
    var maximumValue : CGFloat = 1.0
    var continuous = true
    
    private let knobRenderer = KnobRenderer()
    
    var startAngle : CGFloat {
        get { return knobRenderer.startAngle }
        set { knobRenderer.startAngle = newValue }
    }
    
    var endAngle : CGFloat {
        get { return knobRenderer.endAngle }
        set { knobRenderer.endAngle = newValue }
    }
    
    var lineWidth : CGFloat {
        get { return knobRenderer.lineWidth }
        set { knobRenderer.lineWidth = newValue }
    }
    
    var pointerLength : CGFloat {
        get { return knobRenderer.lineWidth }
        set { knobRenderer.pointerLength = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        backgroundColor = UIColor.whiteColor()
        createSubLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var value : CGFloat {
        get {return backingValue}
        set { setValue(newValue, animated: false) }
    }
    func setValue(value: CGFloat, animated: Bool) {
//        if(value != backingValue) {
//            backingValue = min(maximumValue, max(minimumValue, value))
//        }
        if(value != self.value) {
            //保证大于0，小于1
            self.backingValue = min(maximumValue, max(minimumValue, value))
            
            //颜色变换
//            let index = self.backingValue * 255
//            tintColor = UIColor(red: index/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
            var index : CGFloat = 0.0
            
            if(self.backingValue < 0.3) {
                index = CGFloat(self.backingValue)/0.3
                tintColor = UIColor(red: (91+8*index)/255.0, green: (142+112*index)/255.0, blue: (254-186*index)/255.0, alpha: 1)
            }else if(self.backingValue < 0.7) {
                index = CGFloat(self.backingValue - 0.3)/0.4
                tintColor = UIColor(red: (99+156*index)/255.0, green: (254-254*index)/255.0, blue: (68-68*index)/255.0, alpha: 1)
            }else {
                tintColor = UIColor ( red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0 )
            }
        }
        
        let angleRange = endAngle - startAngle
        let valueRange = CGFloat(maximumValue - minimumValue)
        //value对应的弧度
        let angle = CGFloat(value - minimumValue) / valueRange * angleRange + startAngle
        knobRenderer.setPointerAngle(angle, animated: animated)
    }
    
    func createSubLayers() {
        knobRenderer.update(bounds)
        knobRenderer.strokeColor = tintColor
//        knobRenderer.startAngle = -(π * 11.0 / 8.0)
        knobRenderer.startAngle = -(π * 9.5 / 10.0)
//        knobRenderer.endAngle = π * 3.0 / 8.0
        knobRenderer.endAngle = -(π * 0.5 / 10.0)
        knobRenderer.pointAngle = knobRenderer.startAngle
        knobRenderer.lineWidth = 2.0
        knobRenderer.pointerLength = 6.0
        
        self.layer.addSublayer(knobRenderer.trackLayer)
        self.layer.addSublayer(knobRenderer.pointerLayer)
    }
    
    
    override func tintColorDidChange() {
        knobRenderer.strokeColor = tintColor
    }
}


private class KnobRenderer {
    
    var lineWidth : CGFloat = 1.0 {
        didSet{ update() }
    }
    var startAngle : CGFloat = 0.0 {
        didSet{ update() }
    }
    var endAngle : CGFloat = 0.0 {
        didSet{ update() }
    }
    var pointerLength : CGFloat = 0.0 {
        didSet{ update() }
    }
    var backingPointerAngle : CGFloat = 0.0
    
    let trackLayer = CAShapeLayer()
    let pointerLayer = CAShapeLayer()
    
    var strokeColor : UIColor {
        get {
            return UIColor(CGColor: trackLayer.strokeColor!)
        }
        set(strokeColor) {
            trackLayer.strokeColor = strokeColor.CGColor
            pointerLayer.strokeColor = strokeColor.CGColor
        }
    }
    
    var pointAngle : CGFloat {
        get { return backingPointerAngle }
        set { setPointerAngle(newValue, animated: false)}
    }
    func setPointerAngle(pointerAngle : CGFloat, animated: Bool) {
        
        if(animated && pointerAngle <= 0.01) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
            
            
        //旋转layer
        pointerLayer.transform = CATransform3DMakeRotation(pointerAngle, 0.0, 0.0, 0.1)
        
        
            let midAngle = 0.5 * (max(pointerAngle, self.backingPointerAngle) - min(pointerAngle, self.backingPointerAngle)) + min(pointerAngle, self.backingPointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.duration = 0.25
            
            animation.values = [self.backingPointerAngle, midAngle, pointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pointerLayer.addAnimation(animation, forKey: nil)
        
        CATransaction.commit()
        
        self.backingPointerAngle = pointerAngle
        }else {
            //旋转layer
            pointerLayer.transform = CATransform3DMakeRotation(pointerAngle, 0.0, 0.0, 0.1)
            self.backingPointerAngle = pointerAngle
        }


    }
    
    init() {
        trackLayer.fillColor = UIColor.clearColor().CGColor
        pointerLayer.fillColor = UIColor.clearColor().CGColor
    }
    
    func updatePointerLayerPath() {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(pointerLayer.bounds.width - pointerLength - pointerLayer.lineWidth / 2.0, pointerLayer.bounds.height / 2.0))
        path.addLineToPoint(CGPointMake(pointerLayer.bounds.width, pointerLayer.bounds.height / 2.0))
        pointerLayer.path = path.CGPath
    }
    
    func updateTrackLayerPathc() {
        let arcCenter = CGPointMake(trackLayer.bounds.width / 2.0, trackLayer.bounds.height / 2.0)
        let offset = max(pointerLength, trackLayer.lineWidth / 2.0)
        let radius = min(trackLayer.bounds.height, trackLayer.bounds.width) / 2.0 - offset
        trackLayer.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
    }
    
    func update() {
        trackLayer.lineWidth = lineWidth
        pointerLayer.lineWidth = lineWidth
        
        updateTrackLayerPathc()
        updatePointerLayerPath()
    }
    
    //更新旋钮的尺寸
    func update(bounds: CGRect) {
        let position = CGPointMake(bounds.width / 2.0, bounds.height / 2.0)
        
        trackLayer.bounds = bounds
        trackLayer.position = position
        
        pointerLayer.bounds = bounds
        pointerLayer.position = position
        
        update()
    }
    
    
    
    
    
}
