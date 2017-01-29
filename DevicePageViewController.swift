//
//  DevicePageViewController.swift
//  PiLed
//
//  Created by Shanu Gandhi on 11/12/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

class DevicePageViewController: UIPageViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
    
    var service: NetService!

    lazy var DeviceVC: [UIViewController] = {
        let viewControllerArray = [self.VCInstance(identityOfVC: "BrightnessVC"),
                                   self.VCInstance(identityOfVC: "ColorVC"),
                                   self.VCInstance(identityOfVC: "ModeVC")]
        
        for VC in viewControllerArray{
            let cardVC = VC as! CardViewController
            cardVC.service = self.service
        }
        return viewControllerArray
    }()
    
    
    private func VCInstance(identityOfVC: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identityOfVC)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = DeviceVC.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

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
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = DeviceVC.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < DeviceVC.count else {
            return DeviceVC.first
        }
        
        guard DeviceVC.count > nextIndex else {
            return nil
        }
        
        return DeviceVC[nextIndex]
    }
    
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = DeviceVC.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return DeviceVC.last
        }
        
        guard DeviceVC.count > previousIndex else {
            return nil
        }
        
        return DeviceVC[previousIndex]
    }
    
  
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return DeviceVC.count
    }
    
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = DeviceVC.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
