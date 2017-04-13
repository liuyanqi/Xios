//
//  AppDelegate.swift
//  BLEX
//
//  Created by Yanqi Liu on 4/13/17.
//  Copyright © 2017 Yanqi Liu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var testNavigationController: UINavigationController?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let main = MainViewController();
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let testNavigationController = UINavigationController()
        testNavigationController.pushViewController(main, animated: true)
        window.backgroundColor = UIColor.white
        window.rootViewController = testNavigationController;
        window.makeKeyAndVisible()
        
        self.window = window
        return true;

    }
    

}
