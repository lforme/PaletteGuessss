//
//  PainterViewController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/1.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import MultiPeer
import NXDrawKit
import AVFoundation
import MobileCoreServices
import EasyAnimation
import RxCocoa
import RxSwift
import PKHUD
import RealmSwift

class PainterViewController: UIViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    
    weak var canvasView: Canvas?
    weak var paletteView: Palette?
    weak var toolBar: ToolBar?
    weak var bottomView: UIView?
    let vm = PainterViewModel()
    var saveImage: UIImage?
    
    fileprivate var bottomBoundaryPositionY: CGFloat = 0.0
    fileprivate var bottomIsHiden = false {
        didSet {
            if self.bottomIsHiden {
                hideBottomViewWithAnimation()
            } else {
                showBottomViewWithAnimation()
            }
        }
    }
    
    private func initialize() {
        self.setupCanvas()
        self.setupPalette()
        self.setupToolBar()
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            randomWord()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBoundaryPositionY = self.bottomView?.layer.position.y ?? 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vm.targetWord.subscribe(onNext: {[weak self] (t) in
            self?.title = t
        }).disposed(by: rx.disposeBag)
        
        PeerMiddleware.shared.gameOver
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (isOver) in
                if isOver {
                   
                    self?.showAlert(title: "游戏结束", message: "游戏即将结束, 是否要保存这个画", buttonTitles: ["取消", "保存"], highlightedButtonIndex: 1, completion: { (buttonIndex) in
                        if buttonIndex == 1 {
                            let realm = try! Realm()
                            let picModel = RealmImageModel()
                            picModel.joinCount.value = MultiPeer.instance.connectedPeers.count + 1
                            picModel.imageData = self?.saveImage?.pngData()
                            try! realm.write {
                                realm.add(picModel)
                            }
                            
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                }
            }).disposed(by: rx.disposeBag)
        
        setupUI()
        initialize()
        setupRightNavigationItems()
    }
    
    func setupRightNavigationItems() {
        let paletteButton = UIButton(type: .system)
        paletteButton.sizeToFit()
        paletteButton.setTitle(" 画板 ", for: .normal)
        paletteButton.setTitleColor(UIColor.white, for: .normal)
        paletteButton.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6156862745, blue: 0.9137254902, alpha: 1)
        paletteButton.setShadow()
        paletteButton.titleLabel?.font = UIFont.catFont(size: 19)
        paletteButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.bottomIsHiden = false
        }).disposed(by: rx.disposeBag)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: paletteButton)
    }
    
    func setupUI() {
        view.backgroundColor = bgColor
    }
    
    private func setupPalette() {
        
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.21, alpha: 1.0)
        self.view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalTo(self.view.bounds.height / 3)
        }
        self.bottomView = bottomView
        
        let paletteView = Palette()
        paletteView.delegate = self
        paletteView.setup()
        bottomView.addSubview(paletteView)
        paletteView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalToSuperview().offset(-50)
        }
        self.paletteView = paletteView
    }
    
    private func setupToolBar() {
        let toolBar = ToolBar()
        toolBar.undoButton?.addTarget(self, action: #selector(PainterViewController.onClickUndoButton), for: .touchUpInside)
        toolBar.redoButton?.addTarget(self, action: #selector(PainterViewController.onClickRedoButton), for: .touchUpInside)
        toolBar.loadButton?.isHidden = true
        toolBar.saveButton?.addTarget(self, action: #selector(PainterViewController.onClickSaveButton), for: .touchUpInside)
        toolBar.saveButton?.setTitle("分享", for: UIControl.State())
        toolBar.saveButton?.titleLabel?.font = UIFont.catFont(size: 18)
        toolBar.clearButton?.addTarget(self, action: #selector(PainterViewController.onClickClearButton), for: .touchUpInside)
        toolBar.clearButton?.setTitle("清除", for: UIControl.State())
        toolBar.clearButton?.titleLabel?.font = UIFont.catFont(size: 18)
        
        self.bottomView?.addSubview(toolBar)
        toolBar.snp.makeConstraints { (maker) in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(50)
        }
        self.toolBar = toolBar
        
    }
    
    private func setupCanvas() {
        let canvasView = Canvas()
        canvasView.delegate = self
        canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
        canvasView.layer.borderWidth = 2.0
        canvasView.layer.cornerRadius = 5.0
        canvasView.clipsToBounds = true
        self.view.addSubview(canvasView)
        canvasView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(8)
            maker.bottom.equalToSuperview().offset(-8)
            maker.left.equalToSuperview().offset(8)
            maker.right.equalToSuperview().offset(-8)
        }
        self.canvasView = canvasView
    }
    
    private func updateToolBarButtonStatus(_ canvas: Canvas) {
        self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
        self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
        self.toolBar?.saveButton?.isEnabled = canvas.canSave()
        self.toolBar?.clearButton?.isEnabled = canvas.canClear()
    }
    
    @objc func onClickUndoButton() {
        self.canvasView?.undo()
    }
    
    @objc func onClickRedoButton() {
        self.canvasView?.redo()
    }
    
    @objc func onClickSaveButton() {
        self.canvasView?.save()
    }
    
    @objc func onClickClearButton() {
        self.canvasView?.clear()
    }
}

// MARK: - CanvasDelegate
extension PainterViewController: CanvasDelegate {
    func brush() -> Brush? {
        return self.paletteView?.currentBrush()
    }
    
    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        self.updateToolBarButtonStatus(canvas)
        bottomIsHiden = true
        if let data = image?.asPNGData() {
            MultiPeer.instance.send(data: data, type: PeerSendDataType.picture.rawValue)
        }
        
        self.saveImage = image
    }
    
    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
        // you can save merged image
        //        if let pngImage = image?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        // you can save strokeImage
        //        if let pngImage = drawing.stroke?.asPNGImage() {
        //            UIImageWriteToSavedPhotosAlbum(pngImage, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        //        }
        
        //        self.updateToolBarButtonStatus(canvas)
        
        // you can share your image with UIActivityViewController
        if let pngImage = image?.asPNGImage() {
            let activityViewController = UIActivityViewController(activityItems: [pngImage], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    return
                }
                
                if activityType == UIActivity.ActivityType.saveToCameraRoll {
                    let alert = UIAlertController(title: nil, message: "Image is saved successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

// MARK: - PaletteDelegate
extension PainterViewController: PaletteDelegate {
    
    func colorWithTag(_ tag: NSInteger) -> UIColor? {
        if tag == 4 {
            // if you return clearColor, it will be eraser
            return UIColor.clear
        }
        return nil
    }
}

// MARK: - EasyAnimation Method
extension PainterViewController {
    
    func hideBottomViewWithAnimation() {
        
        if bottomIsHiden {
            
            if self.bottomView?.layer.position.y ?? 0 > bottomBoundaryPositionY {
                return
            }
            
            UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.bottomView?.layer.position.y += self.bottomView?.layer.position.y ?? 0
            }, completion: nil)
        }
    }
    
    func showBottomViewWithAnimation() {
        if !bottomIsHiden {
            if self.bottomView?.layer.position.y ?? 0 == bottomBoundaryPositionY {
                return
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
                self.bottomView?.layer.position.y -= self.bottomBoundaryPositionY
            }, completion: nil)
        }
    }
}

// MARK: - 摇一摇
extension PainterViewController {
    
    func randomWord() {
        let index = Int(arc4random_uniform(UInt32(vm.commonWords.count)))
        let word = vm.commonWords[index]
        self.showAlert(title: word, message: "确定选择【\(word)】吗", buttonTitles: ["取消", "确定"], highlightedButtonIndex: 1) {[weak self] (buttonIndex) in
            
            if buttonIndex == 1 {
                self?.vm.targetWord.accept(word)
                if let data = word.data(using: .utf8) {
                    MultiPeer.instance.send(data: data, type: PeerSendDataType.text.rawValue)
                }
            }
        }
    }
}
