//
//  GuesserViewController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/3.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import LTMorphingLabel
import RxCocoa
import RxSwift
import PKHUD

class GuesserViewController: UIViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    lazy var notiLabel: LTMorphingLabel = {
        let l = LTMorphingLabel(frame: .zero)
        l.morphingEffect = LTMorphingEffect(rawValue: Int(arc4random_uniform(3))) ?? .pixelate
        l.numberOfLines = 1
        l.font = UIFont.catFont(size: 18)
        l.textColor = UIColor.flatForestGreenDark
        return l
    }()
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var textfield: UITextField!
    
    let vm = GuesserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindRx()
        observeRx()
    }
    
    func observeRx() {
        PeerMiddleware.shared.gameOver
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (isOver) in
                if isOver {
                    HUD.flash(.label("游戏结束, 稍后返回"), delay: 2)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }).disposed(by: rx.disposeBag)
    }
    
    func bindRx() {
        vm.changeDescribeText().bind(to: notiLabel.rx.text).disposed(by: rx.disposeBag)
        
        textfield.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.obGuessWord).disposed(by: rx.disposeBag)
        
        textfield.rx.controlEvent(.editingDidEndOnExit).map {[weak self] (_) -> Bool in
            guard let this = self else { return false }
            
            return this.vm.checkWordsCorrectness()
            }.subscribe(onNext: {[weak self] (isRight) in
                
                if isRight {
                    self?.vm.broadcastIamWinner()
                    HUD.flash(.label("我猜对啦"), delay: 5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            }).disposed(by: rx.disposeBag)
        
        PeerMiddleware.shared.obReceivePicture.throttle(.seconds(2), latest: true, scheduler: MainScheduler.instance).bind(to: displayImageView.rx.image).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        title = "猜猜猜"
        view.backgroundColor = bgColor
        bgView.addSubview(notiLabel)
        notiLabel.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(16)
            maker.right.equalToSuperview().offset(-16)
            maker.top.equalToSuperview().offset(8)
        }
        
        textfield.returnKeyType = .done
    }
}
