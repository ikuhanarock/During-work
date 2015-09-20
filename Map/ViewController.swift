//
//  ViewController.swift
//  Map
//
//  Created by UCHIDAYUTA on 2015/15/5.
//  Copyright (c) 2015 YUT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
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

        // ボタン
        btn.setTitle("Settings", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.whiteColor()
        btn.layer.cornerRadius = 10
        btn.setTitleColor(UIColor.cyanColor(), forState: .Normal)
        btn.layer.position = CGPoint(x: 100, y: 100)
        btn.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn)
        
        // AutoLayout ----------------------
        btn.translatesAutoresizingMaskIntoConstraints = false;    //Autolayoutの時はここはfalse
        self.view.addSubview(btn);
        
        var btnsDictionary = [String: AnyObject]()
        btnsDictionary["top_hogehoge"] = btn
        let btn_constraint_1:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("|-8-[top_hogehoge]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        let btn_constraint_2:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[top_hogehoge]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnsDictionary)
        
        view.addConstraints(btn_constraint_1 as! [NSLayoutConstraint])
        view.addConstraints(btn_constraint_2 as! [NSLayoutConstraint])
        // AutoLayout End ----------------------
        
        // マップ
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
        self.mapView.delegate = self
        self.view.addSubview(self.mapView)
        
        // ボタンを前面に移動
        self.view.bringSubviewToFront(btn)
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
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate  = mapPoint
        annotation.title       = "現場"
        annotation.subtitle    = ""
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        // 位置情報を保存
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.latitude, forKey:"targetLatitudeKey");
        NSUserDefaults.standardUserDefaults().setObject(mapPoint.longitude, forKey:"targetLongitudeKey");
        
        // ログをリセット
        NSUserDefaults.standardUserDefaults().setObject("", forKey:"logKey");
        
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // 端末の向きがかわったらNotificationを呼ばす設定.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // 端末の向きがかわったら呼び出される.
    func onOrientationChange(notification: NSNotification){
        
        // MapViewのサイズを再調整する。
        self.mapView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)
        self.view.addSubview(self.mapView)
    }
    
    // buttonをタップしたときのアクション
    func onClick() {
        let second:SecondViewController? = SecondViewController()
        self.presentViewController(second!, animated: true, completion: nil)
    }
    
}