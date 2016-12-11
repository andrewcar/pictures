//
//  PageViewController.swift
//  pictures
//
//  Created by Andrew Carvajal on 12/2/16.
//  Copyright © 2016 YugeTech. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
        
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "camera"), self.newViewController(name: "feed")]
    }()

    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)ViewController")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

// MARK: UINavigationControllerDelegate

extension PageViewController: UINavigationControllerDelegate {
    
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil

        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
