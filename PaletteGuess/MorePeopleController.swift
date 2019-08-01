//
//  MorePeopleController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/26.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import ChameleonFramework
import MultiPeer
import AlignedCollectionViewFlowLayout
import PKHUD
import MultipeerConnectivity
import RxCocoa
import RxSwift

class PeopleCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var role: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setShadow(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    }
    
    func bindData(peer: Peer, numbser: Int) {
        
        if peer.isPainter {
            role.text = "来画!"
            imageView.image = UIImage(named: "role_painter")
        } else {
            role.text = "来猜,"
            imageView.image = UIImage(named: "role_guesser")
        }
        
        if peer.peerID.displayName == UIDevice.getUUID() {
            playLabel.text = "我"
        } else {
            playLabel.text = "玩家 \(numbser.description) "
        }
    }
}


class MorePeopleController: UICollectionViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    var dataSource: Set<Peer> = []
    let waitingView: WaitingPlayerView = ViewLoader.Xib.view()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.removeAll()
        threeSecondsTimerTrigger()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MultiPeer.instance.delegate = self
        setupNavigation()
        setupColletionView()
    }
    
    func setupNavigation() {
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "等待玩家加入"
        self.navigationItem.titleView = waitingView
        
        let button = UIButton(type: .system)
        button.setTitle("  我来当画家~ ", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.catFont(size: 22)
        button.addTarget(self, action: #selector(becomePainterTap(button:)), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.3803921569, green: 0.6156862745, blue: 0.9137254902, alpha: 1)
        button.setShadow()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func setupColletionView() {
        
        collectionView.backgroundColor = bgColor
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .center
        alignedFlowLayout?.minimumInteritemSpacing = 10
        alignedFlowLayout?.minimumLineSpacing = 10
        alignedFlowLayout?.itemSize = CGSize(width: 136, height: 240)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        
        let data = Array(dataSource)[indexPath.item]
        cell.bindData(peer: data, numbser: indexPath.item)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PainterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension MorePeopleController: MultiPeerDelegate {
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        
        guard let t = PeerSendDataType(rawValue: type) else { return }
        switch t {
        case .peer:
            let jsonString = String(data: data, encoding: .utf8)
            let handyJSONPeer = HandyJSONPeer.deserialize(from: jsonString)
            guard let peer = handyJSONPeer?.toPeer() else { break }
            dataSource.forEach { (roopItem) in
                if peer.peerID.displayName == roopItem.peerID.displayName {
                    roopItem.isPainter = peer.isPainter
                }
            }
            collectionView.reloadData()
        default:
            break
        }
        
      
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) { }
}


extension MorePeopleController {
    
    func threeSecondsTimerTrigger() {
        
        Observable<Int>
            .interval(.seconds(3), scheduler: MainScheduler.instance)
            .takeUntil(self.rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: {[weak self] (_) in
                
                self?.checkNewPlayerJoin()
                self?.checkGamePrepareForStart()
                
            }).disposed(by: rx.disposeBag)
    }
    
    private func checkNewPlayerJoin() {
        
        let mySelfPeer = MultiPeer.instance.currentPeer
        MultiPeer.instance.connectedPeers.insert(mySelfPeer, at: 0)
        Set<Peer>(MultiPeer.instance.connectedPeers).forEach({[weak self] (p) in
            self?.dataSource.insert(p)
        })
        self.collectionView.reloadData()
    }
    
    private func checkGamePrepareForStart() {
        dataSource.forEach {[weak self] (peer) in
            if peer.isPainter {
                HUD.flash(.label("游戏即将开始"), delay: 2)
                if peer.peerID == MultiPeer.instance.currentPeer.peerID {
                    print("我来画画")
                    let painterVC = PainterViewController()
                    self?.navigationController?.pushViewController(painterVC, animated: true)
                    
                } else {
                    print("我来猜")
                }
            }
        }
    }
}

// MARK: - 按钮事件
extension MorePeopleController {
    
    @objc func becomePainterTap(button: UIButton) {
        MultiPeer.instance.currentPeer.isPainter = true
        let set = Set<Peer>(self.dataSource)
        
        let optionValue = set.filter { (peer) -> Bool in
            return MultiPeer.instance.currentPeer.peerID == peer.peerID
            }.last
        
        guard let myself = optionValue else {
            return
        }
        
        set.map { (peer) -> Peer in
            if MultiPeer.instance.currentPeer.peerID == peer.peerID {
                peer.isPainter = true
            }
            return peer
            }.forEach {[weak self] (p) in
                self?.dataSource.insert(p)
        }
        collectionView.reloadData()
        
        //  广播我要当画家
        myself.isPainter = true
        guard let jsonString = myself.toHandyJSONPeer().toJSONString() else {
            return
        }
        
        if let data = jsonString.data(using: .utf8) {
            MultiPeer.instance.send(data: data, type: PeerSendDataType.peer.rawValue)
        }
        
    }
}
