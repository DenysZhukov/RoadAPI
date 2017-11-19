//
//  ContainerViewController.swift
//  RoadAPI
//
//  Created by Denys on 11/19/17.
//  Copyright © 2017 Denys Zhukov. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var contentViewController: UIViewController?
    @IBOutlet weak var contentView: UIView!
    var nextTransitionBlock: Completion?
    var inTransition = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showContentController(controller: UIViewController) {
        childViewControllers.count > 0 ?
            transitToContentController(controller) :
            displayContentController(controller)
    }
    
    func transitToContentController(_ controller: UIViewController) {
        inTransition ?
            setNextTransitionWithController(controller) :
            performTransitionToController(controller)
    }
    
    func setNextTransitionWithController(_ controller: UIViewController) {
        nextTransitionBlock = { [unowned self] in
            self.performTransitionToController(controller)
        }
    }
    
    func performTransitionToController(_ controller: UIViewController) {
        guard contentViewController != controller else {return}
        inTransition = true
        transitionToContentController(controller, withCompletion: {
            [unowned self] () in
            self.inTransition = false
            self.performNextTransition()
        })
    }
    
    func performNextTransition() {
        nextTransitionBlock?()
        nextTransitionBlock = nil
    }
    
    func displayContentController(_ childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = contentView.bounds
        contentView.addSubview(childController.view!)
        childController.didMove(toParentViewController: self)
        contentViewController = childController
    }
    
    func transitionToContentController(_ newController: UIViewController,
                                       withCompletion completionBlock: Completion) {
        guard let contentVC = contentViewController else {return}
        contentVC.willMove(toParentViewController: nil)
        newController.view.frame = contentView.bounds
        addChildViewController(newController)
        contentVC.view.removeFromSuperview()
        contentView.addSubview(newController.view)
        self.contentViewController?.removeFromParentViewController()
        newController.didMove(toParentViewController: self)
        self.contentViewController? = newController
        completionBlock()
    }

}
