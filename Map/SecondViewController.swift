//
//  SecondViewController.swift
//  Map
//
//  Created by UCHIDAYUTA on 2015/9/9.
//  Copyright (c) 2015 YUT. All rights reserved.
//

import UIKit
import CoreLocation

class SecondViewController: UIViewController, CLLocationManagerDelegate {
    
    var delegate: ViewControllerDelegate!
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var lm: CLLocationManager!
    
    let btn = UIButton(frame: CGRectMake(0, 0, 100, 30))
    var titleLabel = UILabel(frame: CGRectMake(8, 80, 100, 30))
    
    var isUpdatingLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        if appDelegate.timer == nil {
            appDelegate.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("onUpdate"), userInfo: nil, repeats: true)
        }
        
        // ターゲットの位置情報を読み込む
        appDelegate.targetLatitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLatitudeKey")
        appDelegate.targetLongitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLongitudeKey")
    }
    
    func onUpdate() {
        if appDelegate.lm == nil {
            appDelegate.lm = CLLocationManager()
            appDelegate.lm.delegate = appDelegate
            
            // 位置情報取得の許可を求めるメッセージの表示．必須．
            appDelegate.lm.requestAlwaysAuthorization()
            
            //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
            appDelegate.lm.requestAlwaysAuthorization()
            
            // GPSの使用を開始する
            appDelegate.lm.startUpdatingLocation()
            appDelegate.lm.desiredAccuracy = kCLLocationAccuracyBest
            // lm.distanceFilter = 200
            appDelegate.lm.activityType = CLActivityType.Fitness
            isUpdatingLocation = true
        }
    }
    
    func initView() -> Void {
        self.view.backgroundColor = UIColor.whiteColor()
        
        // BackButtonを設置
        btn.setTitle("Done", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.cyanColor()
        btn.layer.cornerRadius = 10
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.layer.position = CGPoint(x: 100, y: 100)
        btn.addTarget(self, action: "onClickBack", forControlEvents: UIControlEvents.TouchUpInside)
        
        // AutoLayout ----------------------
        btn.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(btn);
        
        view.addConstraints([
            
            NSLayoutConstraint(
                item: btn,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Right,
                multiplier: 1.0,
                constant: -8
            ),
            
            NSLayoutConstraint(
                item: btn,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Top,
                multiplier: 1.0,
                constant: 20
            ),
            
            NSLayoutConstraint(
                item: btn,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Width,
                multiplier: 1.0,
                constant: 50
            ),
            
            NSLayoutConstraint(
                item: btn,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1.0,
                constant: 40
            )]
        )
        self.view.addSubview(btn);
        // AutoLayout End ----------------------
        
        // Title
        titleLabel.text = "Info"
        titleLabel.textColor = UIColor.cyanColor()
        self.view.addSubview(titleLabel);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickBack() {
        self.dismissViewControllerAnimated(true, completion: {self.delegate.initView()})
        
        // インスタンスを破棄
        appDelegate.lm  = nil
    }
}