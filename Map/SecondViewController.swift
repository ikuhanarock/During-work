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
    
    var lm: CLLocationManager!
    
    let btn = UIButton(frame: CGRectMake(0, 0, 100, 30))
    let btnAPI = UIButton(frame: CGRectMake(20, 0, 100, 30))
    var titleLabel = UILabel(frame: CGRectMake(8, 80, 100, 30))
    var logLabel = UILabel(frame: CGRectMake(0, 00, 00, 00))
    
    var targetLatitude: Double = 0.0
    var targetLongitude: Double = 0.0
    var isUpdatingLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        if lm == nil {
            lm = CLLocationManager()
            lm.delegate = self
            
            // 位置情報取得の許可を求めるメッセージの表示．必須．
            lm.requestAlwaysAuthorization()
            
            // GPSの使用を開始する
            lm.startUpdatingLocation()
            lm.desiredAccuracy = kCLLocationAccuracyBest
            // lm.distanceFilter = 200
            lm.activityType = CLActivityType.Fitness
            isUpdatingLocation = true
        }
        
        // ターゲットの位置情報を読み込む
        targetLatitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLatitudeKey")
        targetLongitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLongitudeKey")
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
        
        // GetAPIButtonを設置
        btnAPI.setTitle("Get API", forState: UIControlState.Normal)
        btnAPI.backgroundColor = UIColor.cyanColor()
        btnAPI.layer.cornerRadius = 10
        btnAPI.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btnAPI.layer.position = CGPoint(x: 100, y: 100)
        btnAPI.addTarget(self, action: "onClickGetAPI", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btnAPI)
        
        // Title
        titleLabel.text = "Title"
        titleLabel.textColor = UIColor.cyanColor()
        self.view.addSubview(titleLabel);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 位置情報取得成功時に実行される関数 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        let latitude = newLocation.coordinate.latitude;
        let longitude = newLocation.coordinate.longitude;
        
        if function1().locationToMeter(latitude, latitude2: targetLatitude, longitude1: longitude, longitude2: targetLongitude) > 200 {
            return
        }
        
        var log: String? = logLabel.text!
        
        log = log! + function1().FormatLocationLog(latitude, longitude:longitude)
        logLabel.text = log!
        self.view.addSubview(logLabel);
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        logLabel.text = logLabel.text! + function1().FormatLocationLog(nil, longitude: nil)
        self.view.addSubview(logLabel);
    }
    
    func onClickBack() {
        self.dismissViewControllerAnimated(true, completion: {self.delegate.initView()})
        
        // 保存
        NSUserDefaults.standardUserDefaults().setObject(logLabel.text, forKey:"logKey");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        // インスタンスを破棄
        lm  = nil
    }
    
    func onClickGetAPI() {
        getData("http://express.heartrails.com/api/json?method=getPrefectures")
    }
    
    // API取得の開始処理
    func getData(hostAddress : String) {
        let url: NSURL = NSURL(string: hostAddress)!
        let req = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithRequest(req, completionHandler: { (data, response, error) in
            print("data: \(data)")
            print("response: \(response)")
            print("error: \(error)")
        }).resume()
        
    }
}