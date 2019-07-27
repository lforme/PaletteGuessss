//
//  ViewController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import MultiPeer
import PKHUD

class ViewController: UIViewController {
    
    var navigationVC: BaseNavigationController!
    
    fileprivate var _statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self._statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeStatusBarChanged()
        setupStartVC()
    }
    
    func setupStartVC() {
        
        guard let uuid = UIDevice.getUUID() else {
            HUD.flash(.label("无法获取设备UUID"), delay: 2)
            return
        }
        MultiPeer.instance.initialize(serviceType: "Palette-Guess", deviceName: uuid)
        MultiPeer.instance.autoConnect()
        
        let startVC: StartViewController = ViewLoader.Storyboard.controller(from: "Main")
        navigationVC = BaseNavigationController(rootViewController: startVC)
        
        view.addSubview(navigationVC.view)
        navigationVC.view.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.view)
        }
        self.addChild(navigationVC)
    }
    
    func observeStatusBarChanged() {
        NotificationCenter.default.rx.notification(.statuBarDidChnage)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                if let style = noti.object as? UIStatusBarStyle {
                    self?._statusBarStyle = style
                }
            }).disposed(by: rx.disposeBag)
    }
}
