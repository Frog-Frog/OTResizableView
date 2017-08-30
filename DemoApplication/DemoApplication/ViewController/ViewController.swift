//
//  ViewController.swift
//  DemoApplication
//
//  Created by Tomosuke Okada on 2017/08/27.
//  Copyright © 2017年 TomosukeOkada. All rights reserved.
//

import UIKit

import OTResizableView

class ViewController: UIViewController,OTResizableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let yourView = UIView.init(frame: CGRect(x: 40, y: 40, width: 200, height: 300))
        yourView.backgroundColor = UIColor.blue
        
        let resizableView = OTResizableView.init(contentView: yourView)
        resizableView.delegate = self;
        
        self.view.addSubview(resizableView)
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func tapBegin(resizableView: OTResizableView)
    {
        resizableView.resizeEnabled = resizableView.resizeEnabled ? false : true
        
        print("tapBegin:\(NSStringFromCGRect(resizableView.frame))")
    }
    
    
    func tapChanged(resizableView: OTResizableView)
    {
        print("changeNow:\(NSStringFromCGRect(resizableView.frame))")
    }
    
    
    func tapMoved(resizableView: OTResizableView)
    {
        print("tapMoved:\(NSStringFromCGRect(resizableView.frame))")
    }
    
    
    func tapEnd(resizableView: OTResizableView)
    {
        print("tapEnd:\(NSStringFromCGRect(resizableView.frame))")
    }
}
