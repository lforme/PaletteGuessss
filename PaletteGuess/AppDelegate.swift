//
//  AppDelegate.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import EasyAnimation
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        EasyAnimation.enable()
        return true
    }
}

