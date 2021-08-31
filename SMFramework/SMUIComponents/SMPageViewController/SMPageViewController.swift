//
//  SMPageViewController.swift
//  FrameworkTest
//
//  Created by 박성민 on 2021/08/24.
//

import UIKit

protocol SMPageViewControllerDelegate: AnyObject {
    func indexMoved(_ index: Int, viewController: UIViewController)
}

open class SMPageViewController: UIPageViewController {
    
    weak var scrollDelegate: SMPageViewControllerDelegate?
    var pageContentViewControllers: [UIViewController] = []
    private var isInProgress: Bool = false
    
    public init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<pageContentViewControllers.count {
            if let vc = viewControllers?.last {
                if vc == pageContentViewControllers[i] {
                    scrollDelegate?.indexMoved(i, viewController: vc)
                    break
                }
            }
        }
    }
    
    public func initViewControllers() {
        if pageContentViewControllers.count <= 0 {
            return
        }
        
        delegate = self
        dataSource = self
        view.clipsToBounds = false
        if let viewController = getContentViewController(0) {
            let viewControllers: [UIViewController] = [viewController]
            if !isInProgress {
                isInProgress = true
                setViewControllers(viewControllers, direction: .forward, animated: false) {
                    complete in
                    self.isInProgress = !complete
                }
                
            }
        }
    }
    
    public func getCurrentIndex() -> Int {
        if pageContentViewControllers.count > 0 {
            guard let vc = viewControllers?.last else { return -2 }
            for idx in 0 ..< pageContentViewControllers.count {
                if vc == pageContentViewControllers[idx] {
                    return idx
                }
            }
        }
        return -1
    }
    
    public func getContentViewController(_ index: Int) -> UIViewController? {
        return pageContentViewControllers[safe: index]
    }
    
    public func tabSelected(_ index: Int) {
        let currentIndex = getCurrentIndex()
        if currentIndex >= 0,
           let vc = getContentViewController(index) {
            let vcs: [UIViewController] = [vc]
            if index < currentIndex {
                if !isInProgress {
                    isInProgress = true
                    setViewControllers(vcs, direction: .reverse, animated: false) { complete in
                        self.isInProgress = !complete
                    }
                }
            } else if index > currentIndex {
                if !isInProgress {
                    isInProgress = true
                    setViewControllers(vcs, direction: .forward, animated: false) { complete in
                        self.isInProgress = !complete
                    }
                }
            }
            makeScrollable(index)
            scrollDelegate?.indexMoved(index, viewController: vc)
        }
    }
}

private extension SMPageViewController {
    func makeScrollable(_ index: Int) {
        if let vc = getContentViewController(index) {
            for view in vc.view.subviews {
                if let scroll = view as? UIScrollView {
                    scroll.scrollsToTop = true
                }
            }
        }
    }
}

extension SMPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = getCurrentIndex()
        if index <= 0 {
            return nil
        }
        return self.getContentViewController(index - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = getCurrentIndex()
        if index >= pageContentViewControllers.count {
            return nil
        }
        return getContentViewController(index + 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = getCurrentIndex()
        if index >= 0 {
            if let currentVC = getContentViewController(index) {
                makeScrollable(index)
                scrollDelegate?.indexMoved(index, viewController: currentVC)
            }
        }
    }
}

extension SMPageViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: .zero)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: .zero)
    }
    
}
