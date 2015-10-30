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
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var infoBtn: UIButton!
    var getLocationBtn: UIButton!
    
    var mapView: MKMapView = MKMapView()
    var longtapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // ターゲットの位置情報を読み込む
        appDelegate.targetLatitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLatitudeKey")
        appDelegate.targetLongitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLongitudeKey")
        
        latitude = appDelegate.targetLatitude
        longitude = appDelegate.targetLongitude
        
        let mapPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        dropPin(mapPoint)

        self.longtapGesture.addTarget(self, action: "longPressed:")
        self.mapView.addGestureRecognizer(self.longtapGesture)
    }
    
    // 画面の初期化
    func initView() -> Void {

        // infoボタン
        infoBtn = UIButton(type: UIButtonType.InfoDark)
        infoBtn.addTarget(self, action: "onClickSettings", forControlEvents: UIControlEvents.TouchUpInside)
        
        // AutoLayout Start ----------------------
        infoBtn.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(infoBtn)
        
        view.addConstraints([
            
            NSLayoutConstraint(
                item: infoBtn,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Right,
                multiplier: 1.0,
                constant: -20
            ),
            
            NSLayoutConstraint(
                item: infoBtn,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Top,
                multiplier: 1.0,
                constant: 30
            )]
        )

        self.view.addSubview(infoBtn);
        // AutoLayout End ----------------------
        
        // マップ
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        // ボタンを前面に移動
        self.view.bringSubviewToFront(infoBtn)
        
        // 現在地取得ボタンの生成.
        getLocationBtn = UIButton(frame: CGRectMake(0, 0, 50, 50))
        getLocationBtn.backgroundColor = UIColor.orangeColor()
        getLocationBtn.layer.masksToBounds = true
        getLocationBtn.setTitle("Get", forState: .Normal)
        getLocationBtn.layer.cornerRadius = 25.0
        getLocationBtn.addTarget(self, action: "onClickGetCurrentLocation:", forControlEvents: .TouchUpInside)

        // AutoLayout Start ----------------------
        getLocationBtn.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(getLocationBtn);
        
        view.addConstraints([
            
            NSLayoutConstraint(
                item: getLocationBtn,
                attribute: .Left,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Left,
                multiplier: 1.0,
                constant: 8
            ),
            
            NSLayoutConstraint(
                item: getLocationBtn,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: -8
            ),
            
            NSLayoutConstraint(
                item: getLocationBtn,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Width,
                multiplier: 1.0,
                constant: 50
            ),
            
            NSLayoutConstraint(
                item: getLocationBtn,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .Height,
                multiplier: 1.0,
                constant: 50
            )]
        )
        self.view.addSubview(getLocationBtn)
        // AutoLayout End ----------------------
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // 端末の向きがかわったらNotificationを呼ばす設定.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // 端末の向きがかわったら呼び出される.
    func onOrientationChange(notification: NSNotification){
        initView()
    }
    
    func onClickSettings() {
        let rootViewViewController = SecondViewController()
        rootViewViewController.delegate = self
        let second:SecondViewController = rootViewViewController
        self.presentViewController(second, animated: true, completion: nil)
        
        //lm = nil
    }
    
    // 現在地取得ボタン
    func onClickGetCurrentLocation(sender: UIButton){
        
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
        lm = nil
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
    
    func longPressed(sender: UILongPressGestureRecognizer){
        
        // 指を離したときだけ反応するようにする
        if(sender.state != .Began){
            return
        }
        
        let location = sender.locationInView(self.mapView)
        let mapPoint:CLLocationCoordinate2D = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        
        // アラート表示
        let alertController = UIAlertController(title: "現場の変更", message: "現場を変更してもよろしいでしょうか？", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in self.dropPin(mapPoint)
        }
        let cancelAction = UIAlertAction(title: "CANCEL", style: .Cancel) {
            action in return
        }
        
        alertController.addAction(otherAction)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)

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
        NSUserDefaults.standardUserDefaults().synchronize()
        
        appDelegate.targetLatitude = mapPoint.latitude
        appDelegate.targetLongitude = mapPoint.longitude
        
        if appDelegate.timer == nil {
            appDelegate.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("onUpdate"), userInfo: nil, repeats: true)
        }
        
    }

    func onUpdate() {
        if appDelegate.lm == nil {
            appDelegate.lm = CLLocationManager()
            appDelegate.lm.delegate = appDelegate
            
            // 位置情報取得の許可を求めるメッセージの表示．必須．
            // appDelegate.lm.requestAlwaysAuthorization()
            
            //位置情報取得の可否。バックグラウンドで実行中の場合にもアプリが位置情報を利用することを許可する
            appDelegate.lm.requestAlwaysAuthorization()
            
            appDelegate.lm.startUpdatingLocation()
            appDelegate.lm.desiredAccuracy = kCLLocationAccuracyBest
            // lm.distanceFilter = 200
            appDelegate.lm.activityType = CLActivityType.Fitness
        }
    }
}