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
    var infoBtn: UIButton!
    var getLocationBtn: UIButton!
    
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

        // infoボタン
        infoBtn = UIButton(type: UIButtonType.InfoDark)
        infoBtn.addTarget(self, action: "onClickSettings", forControlEvents: UIControlEvents.TouchUpInside)
        
        // AutoLayout Start ----------------------
        infoBtn.translatesAutoresizingMaskIntoConstraints = false;    //Autolayoutの時はここはfalse
        self.view.addSubview(infoBtn)
        
        view.addConstraints([
            
            NSLayoutConstraint(
                item: infoBtn,
                attribute: .Right,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Right,
                multiplier: 1.0,
                constant: -10
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
        getLocationBtn.translatesAutoresizingMaskIntoConstraints = false;    //Autolayoutの時はここはfalse
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