//
//  UIViewController+Swizzling.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/24.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    override open var next: UIResponder? {
        UIViewController.awake
        return super.next
    }
}


private var interactiveNavigationBarHiddenAssociationKey: UInt8 = 0
extension UIViewController {
  
    @IBInspectable public var interactiveNavigationBarHidden: Bool {
        get {
            var associateValue = objc_getAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey)
            if associateValue == nil {
                associateValue = false
            }
            return associateValue as! Bool;
        }
        set {
            objc_setAssociatedObject(self, &interactiveNavigationBarHiddenAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    fileprivate static let awake : Void  = {
        replaceInteractiveMethods()
        return
    }()
    
    fileprivate static func replaceInteractiveMethods() {
        method_exchangeImplementations(
            class_getInstanceMethod(self, #selector(UIViewController.viewWillAppear(_:)))!,
            class_getInstanceMethod(self, #selector(UIViewController.pg_interactiveViewWillAppear(_:)))!)
    }
    
    
    @objc func pg_interactiveViewWillAppear(_ animated: Bool) {
        pg_interactiveViewWillAppear(animated)
        navigationController?.setNavigationBarHidden(interactiveNavigationBarHidden, animated: animated)
    }

}
