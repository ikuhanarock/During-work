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
    
    let btn = UIButton()
    var titleLabel = UILabel(frame: CGRectMake(8, 80, 100, 30))
    var infoLabel = UILabel()
    var viewsDictionary = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    /* 画面の初期化 */
    func initView() -> Void {
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Doneボタン 生成
        btn.setTitle("Done", forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.cyanColor()
        btn.layer.cornerRadius = 10
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.layer.position = CGPoint(x: 100, y: 100)
        btn.addTarget(self, action: "onClickBack", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btn);
        btn.translatesAutoresizingMaskIntoConstraints = false
        viewsDictionary["btn_layout"] = btn
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[btn_layout(60)]-8-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[btn_layout(40)]|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        self.view.addSubview(btn);
        
        // Titleラベル 生成
        titleLabel.text = "Info"
        titleLabel.textColor = UIColor.cyanColor()
        self.view.addSubview(titleLabel);
        
        // Info 生成
        infoLabel.text = "Copyright (c) 2015 YUTA UCHIDA. All rights reserved.\n"
        infoLabel.textColor = UIColor.cyanColor()
        infoLabel.numberOfLines = 3
        self.view.addSubview(infoLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        viewsDictionary["info_layout"] = infoLabel
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-8-[info_layout]-8-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-110-[info_layout(100)]-|",
                                                                            options: NSLayoutFormatOptions(rawValue: 0),
                                                                            metrics: nil,
                                                                            views: viewsDictionary))
        self.view.addSubview(infoLabel);

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onClickBack() {
        self.dismissViewControllerAnimated(true, completion: {self.delegate.initView()})
    }
}