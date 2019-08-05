//
//  MyProductionController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import SKPhotoBrowser
import RealmSwift
import AlignedCollectionViewFlowLayout
import ChameleonFramework

class ProdcutionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.setShadow()
        bgView.clipsToBounds = true
    }
}

class MyProductionController: UICollectionViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    var datasource: [RealmImageModel] = []
    var browserDs: [SKPhoto] = []
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy-MM-dd"
        
        setupColletionView()
        setupCollectionDataSource()
        setupBrowser()
    }
    
    func setupBrowser() {
        SKCaptionOptions.textColor = ContrastColorOf(SKPhotoBrowserOptions.backgroundColor, returnFlat: true)
        SKCaptionOptions.font = UIFont.catFont(size: 18)
    }
    
    func setupCollectionDataSource() {
        let realm = try! Realm()
        let realmPictrues = realm.objects(RealmImageModel.self)
        let laps = realmPictrues.sorted(byKeyPath: "createdDate", ascending: true)
        
        datasource = Array(laps)
        title = "我的作品集(\(datasource.count.description)张)"
        
        browserDs = Array(laps).map { (model) -> SKPhoto in
            let skPhoto = SKPhoto.photoWithImage(model.toImage() ?? UIImage())
            skPhoto.caption = "在\(formatter.string(from: model.createdDate))我画了一幅美丽的画, 有\(model.joinCount.value?.description ?? "0" )个小伙伴参与了这次游戏."
            return skPhoto
        }
        
        collectionView.reloadData()
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
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProdcutionCell", for: indexPath) as! ProdcutionCell
        
        cell.dateLabel.text = formatter.string(from: datasource[indexPath.item].createdDate)
        cell.imageView.image = datasource[indexPath.item].toImage()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = datasource[indexPath.item]
        let c = UIColor(averageColorFrom: data.toImage() ?? UIImage())
        SKPhotoBrowserOptions.backgroundColor = ComplementaryFlatColorOf(c)
        let browser = SKPhotoBrowser(photos: browserDs, initialPageIndex: indexPath.item)
        present(browser, animated: true, completion: {})
    }
}
