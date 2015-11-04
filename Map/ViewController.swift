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
    var viewsDictionary = [String: AnyObject]()
    
    var mapView: MKMapView = MKMapView()
    var longtapGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        // 現場の位置を読み込んでピンをドロップする
        appDelegate.targetLatitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLatitudeKey")
        appDelegate.targetLongitude = NSUserDefaults.standardUserDefaults().doubleForKey("targetLongitudeKey")
        
        latitude = appDelegate.targetLatitude
        longitude = appDelegate.targetLongitude
        
        let mapPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        dropPin(mapPoint)

        self.longtapGesture.addTarget(self, action: "longPressed:")
        self.mapView.addGestureRecognizer(self.longtapGesture)
    }
    
    /* 画面の初期化 */
    func initView() -> Void {

        // マップ 生成
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        // Infoボタン 生成
        infoBtn = UIButton(type: UIButtonType.InfoDark)
        infoBtn.addTarget(self, action: "onClickInfo", forControlEvents: UIControlEvents.TouchUpInside)
        
        infoBtn.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(infoBtn)
        viewsDictionary["infoBtn_layout"] = infoBtn
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[infoBtn_layout(20)]-20-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[infoBtn_layout(20)]-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        self.view.addSubview(infoBtn);
        
        // Getボタン 生成
        getLocationBtn = UIButton(frame: CGRectMake(0, 0, 50, 50))
        getLocationBtn.backgroundColor = UIColor.orangeColor()
        getLocationBtn.layer.masksToBounds = true
        getLocationBtn.setTitle("Get", forState: .Normal)
        getLocationBtn.layer.cornerRadius = 25.0
        getLocationBtn.addTarget(self, action: "onClickGetCurrentLocation:", forControlEvents: .TouchUpInside)
        
        getLocationBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(getLocationBtn);
        viewsDictionary["getBtn_layout"] = getLocationBtn
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[getBtn_layout(50)]-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[getBtn_layout(50)]-20-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        self.view.addSubview(getLocationBtn);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    /* 端末の向きがかわったら呼び出される */
    func onOrientationChange(notification: NSNotification){
        initView()
    }
    
    /* Infoボタン押下で呼び出される */
    func onClickInfo() {
        let rootViewViewController = SecondViewController()
        rootViewViewController.delegate = self
        let second:SecondViewController = rootViewViewController
        self.presentViewController(second, animated: true, completion: nil)
    }
    
    /* Getボタン押下で呼び出される */
    func onClickGetCurrentLocation(sender: UIButton){
        
        if self.lm == nil {
            self.lm = CLLocationManager()
            self.lm.delegate = self
            
            let status = CLLocationManager.authorizationStatus()
            if(status == CLAuthorizationStatus.NotDetermined) {
                print("didChangeAuthorizationStatus:\(status)");
                self.lm.requestAlwaysAuthorization()
            }
            
            self.lm.desiredAccuracy = kCLLocationAccuracyBest
            self.lm.distanceFilter = 100
        }
        
        self.lm.startUpdatingLocation()
    }
    
    /* 画面長押し時に呼び出される */
    func longPressed(sender: UILongPressGestureRecognizer){
        
        // 指を離したときだけ反応するようにする
        if(sender.state != .Began){
            return
        }
        
        let location = sender.locationInView(self.mapView)
        let mapPoint:CLLocationCoordinate2D = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        
        // アラート表示でokなら、ピンをドロップする
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
    
    /* 地図にピンを配置する */
    func dropPin(mapPoint: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate  = mapPoint
        annotation.title       = "現場"
        annotation.subtitle    = ""
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        // ピンの位置情報を保存
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.latitude, forKey:"targetLatitudeKey")
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.longitude, forKey:"targetLongitudeKey")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        appDelegate.targetLatitude = mapPoint.latitude
        appDelegate.targetLongitude = mapPoint.longitude
        
        if appDelegate.timer == nil {
            appDelegate.timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("onUpdateLocation"), userInfo: nil, repeats: true)
        }
        
    }

    /* タイマーで呼び出される */
    func onUpdateLocation() {
        if appDelegate.lm == nil {
            appDelegate.lm = CLLocationManager()
            appDelegate.lm.delegate = appDelegate
            
            appDelegate.lm.requestAlwaysAuthorization()
            
            appDelegate.lm.startUpdatingLocation()
            appDelegate.lm.desiredAccuracy = kCLLocationAccuracyBest
            appDelegate.lm.activityType = CLActivityType.Fitness
        }
    }
    
    /* 位置情報取得に成功したときに呼び出される */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        let latitude = newLocation.coordinate.latitude
        let longitude = newLocation.coordinate.longitude
        
        let mapPoint:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude,longitude)
        mapView.setCenterCoordinate(mapPoint, animated: false)
        
        var zoom: MKCoordinateRegion = mapView.region
        zoom.span.latitudeDelta = 0.005
        zoom.span.longitudeDelta = 0.005
        mapView.setRegion(zoom, animated: true)
        mapView.showsUserLocation = true
        
        dropPin(mapPoint)
        
        self.lm.stopUpdatingLocation()
        self.lm = nil
    }
    
    /* 位置情報取得に失敗した時に呼び出される */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
}