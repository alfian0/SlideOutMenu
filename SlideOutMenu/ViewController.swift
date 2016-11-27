//
//  ViewController.swift
//  SlideOutMenu
//
//  Created by alfian on 27/11/2016.
//  Copyright © 2016 alfian.official.organization. All rights reserved.
//

import UIKit

class ViewController: ContainerController, ISlideOutMenu {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Root"
        self.delegate = self
    }

    func setCenterViewController() -> ICenterViewController {
        let vc = CenterViewController()
            vc.view.backgroundColor = UIColor.yellowColor()
            vc.title = "Center"
        return vc
    }
    
    func setLeftViewController() -> UIViewController? {
        let vc = UIViewController()
            vc.view.backgroundColor = UIColor.greenColor()
            vc.title = "Left"
        return vc
    }
    
    func setRightViewController() -> UIViewController? {
        let vc = UIViewController()
            vc.view.backgroundColor = UIColor.whiteColor()
            vc.title = "Right"
        return vc
    }
}

class CenterViewController: UIViewController, ICenterViewController {
    var delegate: ISlideOutMenuDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Organize, target: self, action: #selector(self.actionButton(_:)))
    }
    
    @objc func actionButton(sender: UIButton) {
        self.delegate.toggleLeftPanel()
    }
}