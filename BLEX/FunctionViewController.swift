//
//  FunctionViewController.swift
//  BLEX
//
//  Created by Yanqi Liu on 4/13/17.
//  Copyright © 2017 Yanqi Liu. All rights reserved.
//

import Foundation
import UIKit


class FunctionViewController: UIViewController{
    var deviceName: String
    init(){
        self.deviceName = "Anonymous"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init? (coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemetned")
    }

    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor  = UIColor.white
        let text = UILabel();
        print("here name: \(deviceName)")
        text.text = deviceName;
        self.view.addSubview(text)
        
    }
    
}
