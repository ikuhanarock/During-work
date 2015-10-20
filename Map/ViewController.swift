//
//  ViewController.swift
//  Map
//
//  Created by UCHIDAYUTA on 2015/5/15.
//  Copyright (c) 2015 YUT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol ViewControllerDelegate {
    func initView()
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, ViewControllerDelegate {
    
    var lm: CLLocationManager!
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    let btn = UIButton(frame: CGRectMake(0, 0, 100, 30))
    
    //マップ
    var mapView: MKMapView = MKMapView()
    //長押し検知器
    var longtapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 画面の初期化
        initView()
        
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // 長押し検知器の設定
        // 長押し時に呼びだすメソッド
        self.longtapGesture.addTarget(self, action: "longPressed:")
        // マップに長押し検知器を追加
        self.mapView.addGestureRecognizer(self.longtapGesture)
    }
    
    func initView() -> Void {

        // 設定ボタン
        btn.setTitle("Settings", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.whiteColor()
        btn.layer.cornerRadius = 10
        btn.setTitleColor(UIColor.cyanColor(), forState: .Normal)
        btn.layer.position = CGPoint(x: 100, y: 100)
        btn.addTarget(self, action: "onClickSettings", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        // AutoLayout ----------------------
        btn.translatesAutoresizingMaskIntoConstraints = false;    //Autolayoutの時はここはfalse
        self.view.addSubview(btn);
        
        var btnsDictionary = [String: AnyObject]()
        btnsDictionary["top_hogehoge"] = btn
        let btn_constraint_1:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        let btn_constraint_2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[top_hogehoge]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        
        view.addConstraints(btn_constraint_1 as! [NSLayoutConstraint])
        view.addConstraints(btn_constraint_2 as! [NSLayoutConstraint])
        // AutoLayout End ----------------------
        
        // マップ
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        // ボタンを前面に移動
        self.view.bringSubviewToFront(btn)
        
        // 現在地取得ボタンの生成.
        let myButton = UIButton()
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("Get", forState: .Normal)
        myButton.layer.cornerRadius = 25.0
        myButton.addTarget(self, action: "onClickGetCurrentLocation:", forControlEvents: .TouchUpInside)

        // AutoLayout ----------------------
        myButton.translatesAutoresizingMaskIntoConstraints = false;    //Autolayoutの時はここはfalse
        self.view.addSubview(myButton);
  
        var btnsDictionary2 = [String: AnyObject]()
        btnsDictionary2["top_hogehoge"] = myButton
        let btn_constraint2_1:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[top_hogehoge]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary2)
        let btn_constraint2_2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary2)
        
        view.addConstraints(btn_constraint2_1 as! [NSLayoutConstraint])
        view.addConstraints(btn_constraint2_2 as! [NSLayoutConstraint])
        
        view.addConstraints([
            
            // centerViewの右から20pxのところに配置
            NSLayoutConstraint(
                item: myButton,
                attribute: NSLayoutAttribute.Left,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: NSLayoutAttribute.Right,
                multiplier: 1.0,
                constant: 8
            ),
            
            // center.yはcenterViewと同じ
            NSLayoutConstraint(
                item: myButton,
                attribute: NSLayoutAttribute.Bottom,
                relatedBy: NSLayoutRelation.Equal,
                toItem: self.view,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 8
            ),
            
            // 横（固定）
            NSLayoutConstraint(
                item: myButton,
                attribute: NSLayoutAttribute.Width,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.Width,
                multiplier: 1.0,
                constant: 50
            ),
            
            // 縦（固定）
            NSLayoutConstraint(
                item: myButton,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: nil,
                attribute: NSLayoutAttribute.Height,
                multiplier: 1.0,
                constant: 50
            )]
        )
        self.view.addSubview(myButton)
        // AutoLayout End ----------------------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func longPressed(sender: UILongPressGestureRecognizer){
        
        // 指を離したときだけ反応するようにする
        if(sender.state != .Began){
            return
        }
        
        let location = sender.locationInView(self.mapView)
        let mapPoint:CLLocationCoordinate2D = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        dropPin(mapPoint)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // 端末の向きがかわったらNotificationを呼ばす設定.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // 端末の向きがかわったら呼び出される.
    func onOrientationChange(notification: NSNotification){
        initView()
    }
    
    // buttonをタップしたときのアクション
    func onClickSettings() {
        let rootViewViewController = SecondViewController()
        rootViewViewController.delegate = self
        let second:SecondViewController = rootViewViewController
        self.presentViewController(second, animated: true, completion: nil)
        
        lm = nil
    }
    
    // 現在地取得ボタン
    func onClickGetCurrentLocation(sender: UIButton){
        
        // 現在地の取得
        if lm == nil {
            lm = CLLocationManager()
            lm.delegate = self
            
            let status = CLLocationManager.authorizationStatus()
            if(status == CLAuthorizationStatus.NotDetermined) {
                print("didChangeAuthorizationStatus:\(status)");
                lm.requestAlwaysAuthorization()
            }
            
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.distanceFilter = 100
        }
        
        // 現在位置の取得を開始.
        lm.startUpdatingLocation()
    }
    
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        let latitude = newLocation.coordinate.latitude
        let longitude = newLocation.coordinate.longitude
        
        let mapPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        mapView.setCenterCoordinate(mapPoint, animated: false)
        
        // ズーム
        var zoom: MKCoordinateRegion = mapView.region
        zoom.span.latitudeDelta = 0.005
        zoom.span.longitudeDelta = 0.005
        mapView.setRegion(zoom, animated: true)
        mapView.showsUserLocation = true

        dropPin(mapPoint)
        
        lm.stopUpdatingLocation()
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
    
    func dropPin(mapPoint: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate  = mapPoint
        annotation.title       = "現場"
        annotation.subtitle    = ""
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        // 位置情報を保存
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.latitude, forKey:"targetLatitudeKey")
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.longitude, forKey:"targetLongitudeKey")
        
        // ログをリセット
        NSUserDefaults.standardUserDefaults().setObject("", forKey:"logKey");
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}