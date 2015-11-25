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
    
    var threadStop : Bool = false
    var isN2o :Bool = false
    
    var subThreadRun : Bool = false
    var isdecelerate : Bool = false
    var addSpeed : Double = 0.0
    var theOption : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //速度处理线程
        self.subThread()
        knob = Knob(frame: knobPlaceholder.bounds)
        knob.lineWidth = 2.0
        knob.pointerLength = 20.0
        knobPlaceholder.addSubview(knob)
        knob.value = 0.0
        knob.backgroundColor = UIColor.clearColor()
    }
    

    func subThread() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.theOption = 0.0
            self.addSpeed = 0.25
            
            while(true) {
                NSThread.sleepForTimeInterval(0.1)
                while(self.threadStop) {
                    NSThread.sleepForTimeInterval(0.1)
                    NSLog("加速")
                    
                    if(self.addSpeed > 0.06) {
                        self.addSpeed -= 0.05
                    }else {
                        self.addSpeed = 0.02
                    }
                    self.theOption += self.addSpeed
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.editValue(CGFloat(self.theOption))
                    })
                    
                    NSLog("%f", self.knob.value)
                }
                
                while(self.isdecelerate) {//在减速
                    NSThread.sleepForTimeInterval(0.1)
                    NSLog("减速")
                    
                    //加速度
                    if(self.addSpeed > 0.06) {
                        self.addSpeed += 0.02
                    }else {
                        self.addSpeed = 0.06
                    }
                    if(self.theOption <= 0.00) {
                        self.isdecelerate = false
                    }
                    self.theOption -= self.addSpeed
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.editValue(CGFloat(self.theOption))
                    })
                    
                    NSLog("%f", self.knob.value)
                }
            }
        }
    }
    
    @IBAction func sliderValueChanged(slider: UISlider) {
        knob.value = CGFloat(slider.value)
    }
    
    //N2O
    @IBAction func clickN2OButton(sender: AnyObject) {
        self.isN2o = !self.isN2o
        if(!self.isN2o) {
            self.addSpeed = 0.1
            self.isdecelerate = true
            sender.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        }else {
            sender.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            while(self.isN2o) {
                
                self.theOption = Double(arc4random_uniform(25) + 65)/100.0
                NSLog("%f", self.theOption)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.editValue(CGFloat(self.theOption))
                })
            }
            
        }
    }
    
    //touchUpInside
    @IBAction func randomButtonTouched(button: UIButton) {
        self.threadStop = false
        self.isdecelerate = true
    }
    
    @IBAction func randomButtonTouchDownRepeat(sender: AnyObject) {
        NSLog("双击")
    }
    
    @IBAction func randomButtonTouchDown(sender: AnyObject) {
        
        if(self.theOption <= 0.02) {//回到起点
            self.addSpeed = 0.25
        }
        
        //to do new
        self.isdecelerate = false
        
//        var option = 0.0
//        var aSpeed = 0.25
        self.threadStop = true
//        self.istoZero = false
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            while(self.threadStop) {
                if(aSpeed > 0.04) {
                    aSpeed -= 0.04
                }
                option += aSpeed

                
                NSThread.sleepForTimeInterval(0.1)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.editValue(CGFloat(option))
                })
                
                NSLog("%f", self.knob.value)
            }
        }
*/
    }
    
    func editValue(value: CGFloat) {
            
            //安全措施
            if(value >= 0.9) {
                //抖动效果
                self.knob.value = CGFloat(arc4random_uniform(10) + 85) / 100.0
                return
            }
            if(value <= 0) {
                self.knob.value = 0.0
                return
            }
            self.knob.value = value
            
    }
}
