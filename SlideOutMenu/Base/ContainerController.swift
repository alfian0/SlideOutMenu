//
//  ContainerController.swift
//  SlideOutMenu
//
//  Created by alfian on 27/11/2016.
//  Copyright © 2016 alfian.official.organization. All rights reserved.
//

import UIKit

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
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

public
class ContainerController: UIViewController {
    private var nv: UINavigationController!
    private var cv: ICenterViewController!
    private var rv: UIViewController?
    private var lv: UIViewController?
    public var delegate: ISlideOutMenu? {
        didSet {
            self.setVc()
        }
    }
    private var currentState: SlideOutState = .BothCollapsed {
        didSet {
            let shouldShowShadow = (currentState != .BothCollapsed)
            self.showShadowForCenterViewController(shouldShowShadow)
        }
    }
    private var offset: CGFloat = 60
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setVc() {
        guard let delegate = self.delegate else {
            return
        }
        self.cv = delegate.setCenterViewController()
        self.cv.delegate = self
        self.nv = UINavigationController(rootViewController: self.cv as! UIViewController)
        
        self.view.addSubview(self.nv.view)
        self.addChildViewController(self.nv)
        self.nv.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanGesture:"))
        nv.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addLeftMenu() {
        guard let delegate = self.delegate else {
            return
        }
        self.lv = delegate.setLeftViewController()
        guard let leftViewController = self.lv else {
            return
        }
        self.addSideMenu(leftViewController)
    }
    
    private func addSideMenu(vc: UIViewController) {
        self.view.insertSubview(vc.view, atIndex: 0)
        self.addChildViewController(vc)
        vc.didMoveToParentViewController(self)
    }
    
    private func addRightMenu() {
        guard let delegate = self.delegate else {
            return
        }
        self.rv = delegate.setRightViewController()
        guard let rightViewController = self.rv else {
            return
        }
        self.addSideMenu(rightViewController)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            self.currentState = .LeftPanelExpanded
            self.animateCenterPanelXPosition(CGRectGetWidth(self.nv.view.frame) - self.offset)
        } else {
            self.animateCenterPanelXPosition(0) { _ in
                self.currentState = .BothCollapsed
                guard let lv = self.lv else { return }
                lv.view.removeFromSuperview()
                self.lv = nil
            }
        }
    }
    
    private func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.nv.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            self.currentState = .RightPanelExpanded
            self.animateCenterPanelXPosition(-CGRectGetWidth(self.nv.view.frame) + self.offset)
        } else {
            self.animateCenterPanelXPosition(0) { _ in
                self.currentState = .BothCollapsed
                guard let rv = self.rv else { return }
                rv.view.removeFromSuperview()
                self.rv = nil
            }
        }
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            self.nv.view.layer.shadowOpacity = 0.8
            self.nv.view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        } else {
            self.nv.view.layer.shadowOpacity = 0.0
            self.nv.view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        }
    }
}

extension ContainerController: UIGestureRecognizerDelegate {
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let isLefttoRight = (recognizer.velocityInView(self.view).x > 0)
        switch (recognizer.state) {
        case .Began:
            if (self.currentState == .BothCollapsed) {
                if isLefttoRight {
                    self.addLeftMenu()
                } else {
                    self.addRightMenu()
                }
                self.showShadowForCenterViewController(true)
            }
        case .Changed:
            guard let recognizerView = recognizer.view else {
                return
            }
            if (self.lv != nil) || (self.rv != nil) {
                recognizerView.center.x = recognizerView.center.x + recognizer.translationInView(self.view).x
                recognizer.setTranslation(CGPointZero, inView: self.view)
            }
        case .Ended:
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
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        if notAlreadyExpanded {
            self.addLeftMenu()
        }
        self.animateLeftPanel(notAlreadyExpanded)
    }
    
    public func toggleRightPanel() {
        let notAlreadyExpanded = (currentState != .RightPanelExpanded)
        if notAlreadyExpanded {
            self.addRightMenu()
        }
        self.animateRightPanel(notAlreadyExpanded)
    }
    
    public func collapseSidePanels() {
        switch (currentState) {
        case .RightPanelExpanded:
            toggleRightPanel()
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
}
