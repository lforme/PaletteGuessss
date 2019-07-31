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
        button.setTitle("我来当画家~", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.3803921569, green: 0.6156862745, blue: 0.9137254902, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.catFont(size: 22)
        button.addTarget(self, action: #selector(becomePainterTap(button:)), for: .touchUpInside)
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
}


extension MorePeopleController: MultiPeerDelegate {
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        
        let result = String(data: data, encoding: .utf8)
        print(result ?? "")
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) { }
}


extension MorePeopleController {
    
    func threeSecondsTimerTrigger() {
        
        Observable<Int>
            .interval(.seconds(3), scheduler: MainScheduler.instance)
            .takeUntil(self.rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: {[weak self] (_) in
                
                let mySelfPeer = Peer(peerID: MultiPeer.instance.devicePeerID, state: MCSessionState.connected)
                MultiPeer.instance.connectedPeers.insert(mySelfPeer, at: 0)
                Set<Peer>(MultiPeer.instance.connectedPeers).forEach({ (p) in
                    self?.dataSource.insert(p)
                })
                
                self?.collectionView.reloadData()
                
            }).disposed(by: rx.disposeBag)
    }
}

// MARK: - 按钮事件
extension MorePeopleController {
    
    @objc func becomePainterTap(button: UIButton) {
        let set = Set<Peer>(self.dataSource)
        
        let optionValue = set.filter { (peer) -> Bool in
            return MultiPeer.instance.devicePeerID == peer.peerID
            }.last
        
        guard let myself = optionValue else {
            return
        }
        
        set.map { (peer) -> Peer in
            if MultiPeer.instance.devicePeerID == peer.peerID {
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
