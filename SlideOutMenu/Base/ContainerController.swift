//
//  ContainerController.swift
//  SlideOutMenu
//
//  Created by alfian on 27/11/2016.
//  Copyright © 2016 alfian.official.organization. All rights reserved.
//

import UIKit

enum SlideOutState {
    case bothCollapsed
    case leftPanelExpanded
    case rightPanelExpanded
}

public protocol ISlideOutMenu {
    func setCenterViewController() -> ICenterViewController
    func setLeftViewController() -> UIViewController?
    func setRightViewController() -> UIViewController?
}

public protocol ISlideOutMenuDelegate {
    func toggleLeftPanel()
    func toggleRightPanel()
    func collapseSidePanels()
}

public protocol ICenterViewController {
    var delegate: ISlideOutMenuDelegate! { get set }
}

open
class ContainerController: UIViewController {
    fileprivate var nv: UINavigationController!
    fileprivate var cv: ICenterViewController!
    fileprivate var rv: UIViewController?
    fileprivate var lv: UIViewController?
    
    open var delegate: ISlideOutMenu? {
        didSet {
            self.setVc()
        }
    }
    
    fileprivate var currentState: SlideOutState = .bothCollapsed {
        didSet {
            let shouldShowShadow = (currentState != .bothCollapsed)
            self.showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    fileprivate var offset: CGFloat = 60
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func setVc() {
        guard let delegate = self.delegate else {
            return
        }
        self.cv = delegate.setCenterViewController()
        self.cv.delegate = self
        self.nv = UINavigationController(rootViewController: self.cv as! UIViewController)
        
        self.view.addSubview(self.nv.view)
        self.addChild(self.nv)
        self.nv.didMove(toParent: self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ContainerController.handlePanGesture(_:)))
        nv.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    fileprivate func addLeftMenu() {
        guard let delegate = self.delegate else {
            return
        }
        self.lv = delegate.setLeftViewController()
        guard let leftViewController = self.lv else {
            return
        }
        leftViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - self.offset, height: self.view.frame.height)
        self.addSideMenu(leftViewController)
    }
    
    fileprivate func addSideMenu(_ vc: UIViewController) {
        self.view.insertSubview(vc.view, at: 0)
        self.addChild(vc)
        vc.didMove(toParent: self)
    }
    
    fileprivate func addRightMenu() {
        guard let delegate = self.delegate else {
            return
        }
        self.rv = delegate.setRightViewController()
        guard let rightViewController = self.rv else {
            return
        }
        rightViewController.view.frame = CGRect(x: self.offset, y: 0, width: self.view.frame.width - self.offset, height: self.view.frame.height)
        self.addSideMenu(rightViewController)
    }
    
    func animateLeftPanel(_ shouldExpand: Bool) {
        if (shouldExpand) {
            self.currentState = .leftPanelExpanded
            self.animateCenterPanelXPosition(self.nv.view.frame.width - self.offset)
        } else {
            self.animateCenterPanelXPosition(0) { _ in
                self.currentState = .bothCollapsed
                guard let lv = self.lv else { return }
                lv.view.removeFromSuperview()
                self.lv = nil
            }
        }
    }
    
    fileprivate func animateCenterPanelXPosition(_ targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.nv.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(_ shouldExpand: Bool) {
        if (shouldExpand) {
            self.currentState = .rightPanelExpanded
            self.animateCenterPanelXPosition(-self.nv.view.frame.width + self.offset)
        } else {
            self.animateCenterPanelXPosition(0) { _ in
                self.currentState = .bothCollapsed
                guard let rv = self.rv else { return }
                rv.view.removeFromSuperview()
                self.rv = nil
            }
        }
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            self.nv.view.layer.shadowOpacity = 0.8
            self.nv.view.layer.shadowColor = UIColor.lightGray.cgColor
        } else {
            self.nv.view.layer.shadowOpacity = 0.0
            self.nv.view.layer.shadowColor = UIColor.lightGray.cgColor
        }
    }
}

extension ContainerController: UIGestureRecognizerDelegate {
    @objc fileprivate func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let isLefttoRight = (recognizer.velocity(in: self.view).x > 0)
        switch (recognizer.state) {
        case .began:
            if (self.currentState == .bothCollapsed) {
                if isLefttoRight {
                    self.addLeftMenu()
                } else {
                    self.addRightMenu()
                }
                self.showShadowForCenterViewController(true)
            }
        case .changed:
            guard let recognizerView = recognizer.view else {
                return
            }
            if (self.lv != nil) || (self.rv != nil) {
                recognizerView.center.x = recognizerView.center.x + recognizer.translation(in: self.view).x
                recognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        case .ended:
            guard let recognizerView = recognizer.view else {
                return
            }
            if (self.lv != nil) {
                let isGreaterThanHalfway = recognizerView.center.x > self.view.bounds.size.width
                self.animateLeftPanel(isGreaterThanHalfway)
            } else if (self.rv != nil) {
                let isGreaterThanHalfway = recognizerView.center.x < 0
                self.animateRightPanel(isGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

extension ContainerController: ISlideOutMenuDelegate {
    public func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        if notAlreadyExpanded {
            self.addLeftMenu()
        }
        self.animateLeftPanel(notAlreadyExpanded)
    }
    
    public func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .rightPanelExpanded)
        if notAlreadyExpanded {
            self.addRightMenu()
        }
        self.animateRightPanel(notAlreadyExpanded)
    }
    
    public func collapseSidePanels() {
        switch (currentState) {
        case .rightPanelExpanded:
            toggleRightPanel()
        case .leftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
}
