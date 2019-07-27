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
        
        playLabel.backgroundColor = RandomFlatColorWithShade(.light)
        playLabel.clipsToBounds = true
        playLabel.layer.cornerRadius = playLabel.bounds.width / 2
        playLabel.layer.borderColor = ContrastColorOf(playLabel.backgroundColor!, returnFlat: true).cgColor
        playLabel.layer.borderWidth = 2
    }
    
    func bindData(peer: Peer, numbser: Int) {
        
        if peer.isPainter {
            role.text = "我来画!"
        } else {
            role.text = "我来猜,"
        }
        
        if peer.peerID.displayName == UIDevice.getUUID() {
            playLabel.text = "我"
        } else {
            playLabel.text = "玩家\(numbser.description)"
        }
    }
}


class MorePeopleController: UICollectionViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    var dataSource: [Peer] = []
    let waitingView: WaitingPlayerView = ViewLoader.Xib.view()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        threeSecondsTimerTrigger()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupColletionView()
    }
    
    func setupNavigation() {
        self.navigationController?.hidesNavigationBarHairline = true
        self.title = "等待玩家加入"
        self.navigationItem.titleView = waitingView
    }
    
    func setupColletionView() {
        
        collectionView.backgroundColor = bgColor
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let alignedFlowLayout = collectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .center
        alignedFlowLayout?.minimumInteritemSpacing = 10
        alignedFlowLayout?.minimumLineSpacing = 10
//        alignedFlowLayout?.estimatedItemSize = CGSize(width: 147, height: 177)
        alignedFlowLayout?.itemSize = CGSize(width: 136, height: 240)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        
        let data = dataSource[indexPath.item]
        cell.bindData(peer: data, numbser: indexPath.item)
        
        return cell
    }
}


extension MorePeopleController: MultiPeerDelegate {
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        
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
                let filterPeers = Set<Peer>(MultiPeer.instance.connectedPeers)
                self?.dataSource = Array(filterPeers)
                self?.collectionView.reloadData()
                
            }).disposed(by: rx.disposeBag)
    }
    
}
