//
//  ViewController.swift
//  KnobDemo
//
//  Created by Mikael Konutgan on 05/09/14.
//  Copyright (c) 2014 Mikael Konutgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var knobPlaceholder: UIView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var valueSlider: UISlider!
    @IBOutlet var animateSwitch: UISwitch!
    
    var myThread : NSThread!
    
    var knob : Knob!
    
    var threadRealStop : Bool = true
    var mythreadStop : Bool = false
    var istoZero : Bool = false
    
    var option = 0.0
    var aSpeed = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化子线程
        //        self.initSubThread()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            while(true){
                NSThread.sleepForTimeInterval(0.1)
                if(!self.threadRealStop) {
                    if(self.mythreadStop) {
                        self.aSpeed += 0.02
                        self.option -= self.aSpeed
                    }else {
                        self.aSpeed += 0.03
                        self.option += self.aSpeed
                    }
                    
                    
                    //                    if(self.option <= 0.000) {
                    //                        self.threadRealStop = true
                    //                    }
                    NSLog("在跑")
                    NSThread.sleepForTimeInterval(0.1)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.editValue(CGFloat(self.option))
                    })
                    
                    NSLog("%f", self.knob.value)
                }
            }
        }
        
        
        
        
        knob = Knob(frame: knobPlaceholder.bounds)
        knob.lineWidth = 2.0
        knob.pointerLength = 20.0
        knobPlaceholder.addSubview(knob)
        knob.value = 0.3
        
        //        self.view.tintColor = UIColor.blueColor()
    }
    
    //touchUpInside
    @IBAction func randomButtonTouched(button: UIButton) {
        self.istoZero = false
        //        self.editValue(0.0)
        
        self.mythreadStop = true
        //        self.threadRealStop = false
    }
    
    
    @IBAction func sliderValueChanged(slider: UISlider) {
        //        knob.value = CGFloat(slider.value)
    }
    
    @IBAction func randomButtonTouchDown(sender: AnyObject) {
        //        self.option = 0.0
        self.aSpeed = 0.01
        self.mythreadStop = false
        self.istoZero = false
        self.threadRealStop = false
        
        
        
    }
    
    func editValue(value: CGFloat) {
        if(!self.istoZero) {
            if(value <= 0.01) {
                self.knob.value = 0.0
                self.threadRealStop = true
            }else {
                self.knob.value = value
            }
        }else {
            self.knob.value = 0.0
            self.threadRealStop = true
        }
    }
}
