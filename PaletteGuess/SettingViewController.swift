//
//  SettingViewController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/8/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RealmSwift

class SettingViewController: UITableViewController {
    
    let bgColor = UIColor(averageColorFrom: UIImage(named: "start_bg_image")!)
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var version: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "设置"
        view.backgroundColor = bgColor
        tableView.backgroundColor = bgColor
        tableView.tableFooterView = UIView(frame: .zero)
        
        figureOutAppSize()
        getAppVersion()
    }
    
    func getAppVersion() {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        version.text = v
    }
    
    func figureOutAppSize() {
        let path = NSHomeDirectory() 
        
        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = attr[FileAttributeKey.size] as? NSNumber {
                let mbSize = fileSize.doubleValue / 1000000
                if mbSize < 1 {
                    sizeLabel.text = fileSize.doubleValue.description + "KB"
                } else {
                    sizeLabel.text = mbSize.description + "MB"
                }
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
    
    func deleteRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        figureOutAppSize()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:

            indicator.startAnimating()
            deleteRealm()
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {[weak self] in
                self?.indicator.stopAnimating()
            }
            
        default:
            break
        }
        
    }
}
