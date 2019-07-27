//
//  UIdevice+Ex.swift
//  DoAction
//
//  Created by mugua on 2019/7/12.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    static func getBundleIdentifier() -> String {
        return Bundle.main.bundleIdentifier ?? "com.oldwhy.DoAction"
    }
    
    static func getAPPVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }
    
    static func getUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}
