//
//  AppDelegate.swift
//  Map
//
//  Created by UCHIDAYUTA on 2015/5/15.
//  Copyright (c) 2015 YUT. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var lm: CLLocationManager!
    
    var timer: NSTimer!
    
    var targetLatitude: Double = 0.0
    var targetLongitude: Double = 0.0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // NSUserDefaultsの初期化
        NSUserDefaults.standardUserDefaults().setObject(0.0, forKey:"targetLatitudeKey");
        NSUserDefaults.standardUserDefaults().setObject(0.0, forKey:"targetLongitudeKey");
        NSUserDefaults.standardUserDefaults().synchronize();
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /* 位置情報取得成功時に実行される関数 */
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        
        let latitude = newLocation.coordinate.latitude;
        let longitude = newLocation.coordinate.longitude;
        
        if function1().locationToMeter(latitude, latitude2: targetLatitude, longitude1: longitude, longitude2: targetLongitude) > 200 {
            return
        }
        
        // var log: String? = logLabel.text!
        
//        var log = function1().FormatLocationLog(latitude, longitude:longitude)
//        NSLog(log)
        // logLabel.text = log!
        postData("http://localhost:8124/", user: "TESTUSER", latitude: latitude, longitude: longitude);
        // self.view.addSubview(logLabel);
        
        lm.stopUpdatingLocation()
        lm  = nil
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        NSLog("失敗しました。")
        
        lm.stopUpdatingLocation()
        lm  = nil
    }

    func postData(hostAddress : String, user : String, latitude : Double, longitude : Double) {
        
        let myConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundTask")
        let mySession:NSURLSession = NSURLSession(configuration: myConfig)
        let myUrl:NSURL = NSURL(string: hostAddress)!
        
        let myRequest:NSMutableURLRequest = NSMutableURLRequest(URL: myUrl)
        myRequest.HTTPMethod = "POST"
        
        let str:NSString = "{ \"user\" : \" \(user) \", \"latitude\": \(latitude) , \"longitude\": \(longitude) }"
        let myData:NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!
        myRequest.HTTPBody = myData
        
        let myTask:NSURLSessionDataTask = mySession.dataTaskWithRequest(myRequest)
        myTask.resume()
    }
}

