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
    
    var timer: NSTimer!
    
    let btn = UIButton(frame: CGRectMake(0, 0, 100, 30))
    let btnAPI = UIButton(frame: CGRectMake(20, 0, 100, 30))
    var titleLabel = UILabel(frame: CGRectMake(8, 80, 100, 30))
    var logLabel = UILabel(frame: CGRectMake(0, 00, 00, 00))
    
    var isUpdatingLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("onUpdate"), userInfo: nil, repeats: true)
        
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
        
        logLabel.layer.borderWidth = 0.5;
        logLabel.numberOfLines = 0;
        
        let log:String? = NSUserDefaults.standardUserDefaults().stringForKey("logKey");
        
        if log != nil {
            logLabel.text = log;
        } else {
            logLabel.text = ""
        }
        self.view.addSubview(logLabel);
        
        // AutoLayout ----------------------
        logLabel.translatesAutoresizingMaskIntoConstraints = false; //Autolayoutの時はここはfalse
        self.view.addSubview(logLabel);
        
        var viewsDictionary = [String: AnyObject]()
        viewsDictionary["top_hogehoge"] = logLabel
        let label_constraint_1:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let label_constraint_2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-110-[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        
        view.addConstraints(label_constraint_1 as! [NSLayoutConstraint])
        view.addConstraints(label_constraint_2 as! [NSLayoutConstraint])
        // AutoLayout End ----------------------
        
        // BackButtonを設置
        btn.setTitle("Back", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.cyanColor()
        btn.layer.cornerRadius = 10
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.layer.position = CGPoint(x: 100, y: 100)
        btn.addTarget(self, action: "onClickBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        // AutoLayout ----------------------
        btn.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(btn);
        
        var btnsDictionary = [String: AnyObject]()
        btnsDictionary["top_hogehoge"] = btn
        let btn_constraint_1:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        let btn_constraint_2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[top_hogehoge]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        
        view.addConstraints(btn_constraint_1 as! [NSLayoutConstraint])
        view.addConstraints(btn_constraint_2 as! [NSLayoutConstraint])
        // AutoLayout End ----------------------
        
        // Title
        titleLabel.text = "Title"
        titleLabel.textColor = UIColor.cyanColor()
        self.view.addSubview(titleLabel);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickBack() {
        self.dismissViewControllerAnimated(true, completion: {self.delegate.initView()})
        
        // 保存
        NSUserDefaults.standardUserDefaults().setObject(logLabel.text, forKey:"logKey");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        // インスタンスを破棄
        appDelegate.lm  = nil
    }
}