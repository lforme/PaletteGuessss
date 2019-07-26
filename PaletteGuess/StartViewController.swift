//
//  StartViewController.swift
//  PaletteGuess
//
//  Created by mugua on 2019/7/23.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var morePeopleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactiveNavigationBarHidden = true
        
        setupButtons()
    }
    
    
    func setupButtons() {
        morePeopleButton.setCircular(value: 7)
    }
}
