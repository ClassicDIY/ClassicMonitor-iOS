//
//  PageViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/22/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
//https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/

import UIKit
import Foundation

protocol PageViewControllerDelegateMqtt: class {
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func pageViewController(pageViewController: PageViewControllerMqtt, didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func pageViewController(pageViewController: PageViewControllerMqtt, didUpdatePageIndex index: Int)
    
}


class PageViewControllerMqtt: UIPageViewController {
    
    weak var pageDelegate: PageViewControllerDelegateMqtt?
    
    var classicURL: String      = ""
    var classicPort: Int32      = 1883
    var mqttUser: String        = ""
    var mqttPassword: String    = ""
    var mqttTopic: String       = ""
    var classicName: String     = ""
    
    var orderedViewControllers  = [UIViewController]()
    
    //private(set) lazy var orderedViewControllers: [UIViewController] = {
    //    return [
    //        self.newViewController(name: "MqttViewController"),
    //        self.newViewController(name: "WizbangJRViewController")
    //    ]
    //}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Received Parameters PageViewControllerMQTT: \(classicURL) - \(classicPort) - \(mqttUser) - \(mqttPassword) - \(mqttTopic) - \(classicName)")
        dataSource              = self
        delegate                = self
        
        let firstVC             = storyboard?.instantiateViewController(withIdentifier: "MqttViewController") as! MqttViewController
        let secondVC            = storyboard?.instantiateViewController(withIdentifier: "WizbangJRViewControllerMqtt") as! WizbangJRViewControllerMqtt
        let thirdVC             = storyboard?.instantiateViewController(withIdentifier: "ConsumptionViewControllerMqtt") as! ConsumptionViewControllerMqtt
        
        //MARK: Parameters set here to child view
        firstVC.classicURL      = self.classicURL
        firstVC.classicPort     = self.classicPort
        firstVC.mqttUser        = self.mqttUser
        firstVC.mqttPassword    = self.mqttPassword
        firstVC.mqttTopic       = self.mqttTopic
        firstVC.classicName     = self.classicName
        
        //MARK: Parameters set here to child view
        secondVC.classicURL     = self.classicURL
        secondVC.classicPort    = self.classicPort
        secondVC.mqttUser       = self.mqttUser
        secondVC.mqttPassword   = self.mqttPassword
        secondVC.mqttTopic      = self.mqttTopic
        secondVC.classicName    = self.classicName
        
        //MARK: Parameters set here to child view
        thirdVC.classicURL     = self.classicURL
        thirdVC.classicPort    = self.classicPort
        thirdVC.mqttUser       = self.mqttUser
        thirdVC.mqttPassword   = self.mqttPassword
        thirdVC.mqttTopic      = self.mqttTopic
        thirdVC.classicName    = self.classicName
        
        orderedViewControllers.append(firstVC)
        orderedViewControllers.append(secondVC)
        orderedViewControllers.append(thirdVC)
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        //MARK: Do not delete, for future tests
        //let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        //appearance.pageIndicatorTintColor = UIColor.white
        //appearance.currentPageIndicatorTintColor = UIColor.white
        //appearance.backgroundStyle = .minimal
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        pageDelegate?.pageViewController(pageViewController: self,didUpdatePageCount: orderedViewControllers.count)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("Prefered Barstatus Style")
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyDelegateOfNewIndex()
                           })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    private func notifyDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
           let index = orderedViewControllers.firstIndex(of: firstViewController) {
            pageDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewControllerMqtt: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = orderedViewControllers.firstIndex(of: firstViewController) else {
            return 0
        }
        
        return firstViewControllerIndex
    }
}

extension PageViewControllerMqtt: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyDelegateOfNewIndex()
    }
}

