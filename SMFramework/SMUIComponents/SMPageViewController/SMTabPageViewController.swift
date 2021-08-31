//
//  SMTabPageViewController.swift
//  FrameworkTest
//
//  Created by 박성민 on 2021/08/30.
//

import UIKit
import SungminExtensions

open class SMTabPageViewController: UIViewController {
    var tabScrollContainerViewHeight: CGFloat = 50.0
    var tabTitleFontSize: CGFloat = 15.0
    var tabTitleHorizontalInset: CGFloat = 11.0
    var minimumTabTitleWidth: CGFloat = 55.0
    var tabHorizontalMargin: CGFloat = 10
    var tabIndicatorHeight: CGFloat = 3.0
    var indicatorHorizontalMargin: CGFloat = 3.0
    var highlightColor: UIColor = UIColor(hex: "#2AC1BC") ?? .systemPink

    weak var scrollDelegate: SMPageViewControllerDelegate?
    
    private var pageContentViewControllers = LinkedDictionary()
    private var pageViewController: SMPageViewController?
    private var tabs: [UILabel] = []
    private var tabIndicatorView: UIView?
    private var initialized: Bool = false
    
    @IBOutlet weak var tabScrollContainerView: UIView!
    @IBOutlet weak var tabScrollHairlineView: UIView!
    @IBOutlet weak var tabScrollContainerViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var tabScrollViewWidthConst: NSLayoutConstraint!
    @IBOutlet weak var tabScrollView: UIScrollView!
    @IBOutlet weak var pageViewControllerContainerView: UIView!
    
    public init() {
        super.init(nibName: "SMTabPageViewController", bundle: Bundle.module)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        initializeViews()
    }

    private func initializeViews() {
        pageViewController = SMPageViewController()
        var viewControllers: [UIViewController] = []
        for value in pageContentViewControllers.getValues() {
            if let viewController = value as? UIViewController {
                viewControllers.append(viewController)
            }
        }
        pageViewController?.pageContentViewControllers = viewControllers
        pageViewController?.scrollDelegate = self
        pageViewController?.initViewControllers()
        if let controller = pageViewController {
            addChild(controller)
            pageViewControllerContainerView.addSubview(controller.view)
        }
        view.clipsToBounds = false
        pageViewController?.view.clipsToBounds = false
        showTabContainer(true)
        
        tabScrollView.alwaysBounceHorizontal = true
        tabScrollView.delegate = self
        tabScrollView.clipsToBounds = false
        tabScrollView.showsVerticalScrollIndicator = false
        tabScrollView.showsHorizontalScrollIndicator = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialized {
            pageViewController?.view.frame = pageViewControllerContainerView.frame
            makeTitles()
            makeIndicator()
            initialized = true
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @objc func tabClicked(_ sender: UITapGestureRecognizer) {
        if let view = sender.view {
            let index = view.tag
            tabSelected(index)
        }
    }
    
}

private extension SMTabPageViewController {
    func makeTitles() {
        for label in tabs {
            label.removeFromSuperview()
        }
        tabs.removeAll()
        let count = pageContentViewControllers.getCount()
        
        for index in 0 ..< count {
            var titleText = ""
            if let viewTitle = pageContentViewControllers.getKeyAtIndexOf(index) {
                titleText = viewTitle
            }
            var width = labelIntrinsicContentWidth(titleText) + (tabTitleHorizontalInset * 2)
            width = width < minimumTabTitleWidth ? minimumTabTitleWidth : width
            
            var originX: CGFloat = 0
            if tabs.count == 0 {
                originX = tabHorizontalMargin
            } else if let prevTabLabel = tabs[safe: index - 1] {
                originX = prevTabLabel.frame.origin.x + prevTabLabel.frame.size.width
            }
            let frame = CGRect(x: originX, y: 0, width: width, height: tabScrollContainerViewHeight)
            let label = makeTitleLabel(frame: frame, titleText: titleText)
            label.tag = index
            tabs.append(label)
            tabScrollView.addSubview(label)
        }
        if let lastTabTitleLabel = tabs.last {
            tabScrollView.contentSize.width = lastTabTitleLabel.frame.origin.x + lastTabTitleLabel.frame.width + tabHorizontalMargin
        }
        var widthTotal = UIScreen.main.bounds.width
        var calculated: CGFloat = tabHorizontalMargin * 2
        for label in tabs {
            calculated += label.frame.size.width
        }
        if calculated < widthTotal {
            widthTotal = calculated
        }
        tabScrollViewWidthConst.constant = widthTotal
        highlightSelectedIndex()
    }
    
    func labelIntrinsicContentWidth(_ text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: tabTitleFontSize, weight: .regular)
        
        return label.intrinsicContentSize.width
    }
    
    func makeTitleLabel(frame: CGRect, titleText: String) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = .systemFont(ofSize: tabTitleFontSize, weight: .regular)
        label.text = titleText
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabClicked))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }
    
    func highlightSelectedIndex() {
        let currentIndex = pageViewController?.getCurrentIndex()
        for index in 0 ..< tabs.count {
            let tab = tabs[index]
            if index == currentIndex {
                tab.font = .systemFont(ofSize: tabTitleFontSize, weight: .bold)
                tab.textColor = highlightColor
            } else {
                tab.font = .systemFont(ofSize: tabTitleFontSize, weight: .regular)
                tab.textColor = .black
            }
        }
    }
    
    func makeIndicator() {
        if tabIndicatorView == nil {
            let width = minimumTabTitleWidth
            let height = tabIndicatorHeight
            
            let frame = CGRect(x: 0, y: tabScrollContainerViewHeight - height, width: width, height: height)
            tabIndicatorView = UIView(frame: frame)
            tabIndicatorView?.backgroundColor = highlightColor
        }
        moveIndicatorToCurrentIndex()
        if let indicator = tabIndicatorView, !tabScrollView.subviews.contains(indicator) {
            tabScrollView.addSubview(indicator)
        }
    }
    
    func moveIndicatorToCurrentIndex() {
        guard let currentIndex = pageViewController?.getCurrentIndex(),
              let title = pageContentViewControllers.getKeyAtIndexOf(currentIndex) else { return }
        let count = pageContentViewControllers.getCount()
        let width = indicatorWidth(title)
        if count > 0 {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                guard let self = self else { return }
                self.tabIndicatorView?.frame.size.width = width
                self.tabIndicatorView?.center.x = self.tabs[currentIndex].center.x
                
                if self.tabs.count > currentIndex {
                    let frameWidth = self.tabScrollView.frame.size.width
                    let contentWidth = self.tabScrollView.contentSize.width
                    let cPosX = self.tabs[currentIndex].frame.origin.x
                    var offsetX: CGFloat = 0.0
                    if currentIndex > 0 {
                        if contentWidth - cPosX >= frameWidth {
                            offsetX = cPosX
                        } else {
                            offsetX = contentWidth - frameWidth
                        }
                    }
                    self.tabScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
                }
                
            })
        }
    }
    
    func indicatorWidth(_ title: String) -> CGFloat {
        return labelIntrinsicContentWidth(title) + (indicatorHorizontalMargin * 2)
    }
    
}

extension SMTabPageViewController {
    public func showTabContainer(_ show: Bool) {
        if show {
            self.tabScrollContainerViewHeightConst.constant = tabScrollContainerViewHeight
            self.tabScrollContainerView.isHidden = false
        } else {
            self.tabScrollContainerViewHeightConst.constant = 0.0
            self.tabScrollContainerView.isHidden = true
        }
    }
    
    public func addContentViewController(tabTitle name: String, viewController: UIViewController) {
        pageContentViewControllers.addValue(name, value: viewController)
    }
    
    public func removeContentViewControllers() {
        pageContentViewControllers = LinkedDictionary()
        pageViewController?.pageContentViewControllers = []
        pageViewController?.initViewControllers()
    }
    
    public func tabSelected(_ index: Int) {
        pageViewController?.tabSelected(index)
    }
    
    public func getCurrentViewController() -> UIViewController? {
        return getContentViewController(getCurrentIndex())
    }
    
    public func getContentViewController(_ index: Int) -> UIViewController? {
        return pageViewController?.getContentViewController(index)
    }
    
    public func getCurrentIndex() -> Int {
        if let controller = pageViewController {
            return controller.getCurrentIndex()
        }
        return -1
    }
    
    public func getCount() -> Int {
        return pageContentViewControllers.getCount()
    }
    
    public func remakeTabs() {
        makeTitles()
        makeIndicator()
    }
}

extension SMTabPageViewController: UIScrollViewDelegate {
    
}

extension SMTabPageViewController: SMPageViewControllerDelegate {
    public func indexMoved(_ index: Int, viewController: UIViewController) {
        highlightSelectedIndex()
        moveIndicatorToCurrentIndex()
        scrollDelegate?.indexMoved(index, viewController: viewController)
    }
}
