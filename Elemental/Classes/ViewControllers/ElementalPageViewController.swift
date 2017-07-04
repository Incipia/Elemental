//
//  ElementalPageViewController.swift
//  Pods
//
//  Created by Leif Meyer on 7/3/17.
//
//

import UIKit

public protocol ElementalPageViewControllerDelegate: class {
   func elementalPageTransitionCompleted(index: Int, in viewController: ElementalPageViewController)
}

public protocol ElementalPage {
   func willAppear(inPageViewController pageViewController: ElementalPageViewController)
   func didAppear(inPageViewController pageViewController: ElementalPageViewController)
   func willDisappear(fromPageViewController pageViewController: ElementalPageViewController)
   func didDisappear(fromPageViewController pageViewController: ElementalPageViewController)
}

public extension ElementalPage {
   func willAppear(inPageViewController pageViewController: ElementalPageViewController) {}
   func didAppear(inPageViewController pageViewController: ElementalPageViewController) {}
   func willDisappear(fromPageViewController pageViewController: ElementalPageViewController) {}
   func didDisappear(fromPageViewController pageViewController: ElementalPageViewController) {}
}

open class ElementalPageViewController: UIPageViewController {
   // MARK: - Public Properties
   public fileprivate(set) var pages: [UIViewController] = [] {
      didSet {
         for (index, vc) in pages.enumerated() { vc.view.tag = index }
      }
   }
   
   public func setPages(_ pages: [UIViewController], currentIndex: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: (() -> Void)? = nil) {
      self.pages = pages
      
      setCurrentIndex(currentIndex, direction: direction, animated: animated, completion: completion)
   }
   
   public private(set) var currentIndex: Int = 0

   public func setCurrentIndex(_ currentIndex: Int, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: (() -> Void)? = nil) {
      self.currentIndex = currentIndex
      _transition(from: viewControllers?.first, to: pages.count > currentIndex ? pages[currentIndex] : nil, direction: direction, animated: animated, notifyDelegate: true, completion: completion)
   }

   public weak var elementalDelegate: ElementalPageViewControllerDelegate?
   
   public var pageCount: Int {
      return pages.count
   }
   
   // Subclass Hooks
   open func prepareForTransition(from currentPage: UIViewController?, to nextPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      (currentPage as? ElementalPage)?.willDisappear(fromPageViewController: self)
      (nextPage as? ElementalPage)?.willAppear(inPageViewController: self)
   }

   open func recoverAfterTransition(from previousPage: UIViewController?, to currentPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      (previousPage as? ElementalPage)?.didDisappear(fromPageViewController: self)
      (currentPage as? ElementalPage)?.didAppear(inPageViewController: self)
   }
   
   // MARK: - Init
   public convenience init(viewControllers: [UIViewController]) {
      self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
      self.pages = viewControllers
   }
   
   public required init?(coder: NSCoder) {
      super.init(coder: coder)
      _commonInit()
   }
   
   public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
      super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
      _commonInit()
   }
   
   private func _commonInit() {
      delegate = self
      dataSource = self
   }
   
   // MARK: - Life Cycle
   open override func viewDidLoad() {
      super.viewDidLoad()
      view.subviews.forEach { ($0 as? UIScrollView)?.delaysContentTouches = false }
      _transition(from: nil, to: pages.first, direction: .forward, animated: false, notifyDelegate: false, completion: nil)
   }
   
   // MARK: - Public
   public func navigate(_ direction: UIPageViewControllerNavigationDirection, completion: (() -> Void)? = nil) {
      guard let current = viewControllers?.first else { completion?(); return }
      
      var next: UIViewController?
      switch direction {
      case .forward: next = dataSource?.pageViewController(self, viewControllerAfter: current)
      case .reverse: next = dataSource?.pageViewController(self, viewControllerBefore: current)
      }
      
      guard let target = next else { completion?(); return }
      switch direction {
      case .forward: currentIndex = currentIndex + 1
      case .reverse: currentIndex = currentIndex - 1
      }
      
      _transition(from: current, to: next, direction: direction, animated: true, notifyDelegate: true, completion: completion)
   }
   
   public func navigate(to index: Int) {
      guard !pages.isEmpty else { return }
      let index = min(index, pages.count - 1)
      switch index {
      case 0..<currentIndex:
         let count = currentIndex - index
         for _ in 0..<count { navigate(.reverse) }
      case currentIndex+1..<pages.count:
         let count = index - currentIndex
         for _ in 0..<count { navigate(.forward) }
      default: break
      }
   }

   public func navigateToFirst() {
      navigate(to: 0)
   }

   // MARK: - Private
   private func _transition(from current: UIViewController?, to next: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool, notifyDelegate: Bool, completion: (() -> Void)?) {
      guard current != next else { return }
      
      prepareForTransition(from: current, to: next, direction: direction, animated: true)
      let nextViewControllers = next == nil ? nil : [next!]
      setViewControllers(nextViewControllers, direction: direction, animated: true) { finished in
         self.recoverAfterTransition(from: current, to: next, direction: direction, animated: true)
         if let next = next, let index = self.pages.index(of: next) {
            // calling setViewControllers(direction:animated:) doesn't trigger the UIPageViewControllerDelegate method
            // didFinishAnimating, so we have to tell our elementalDelegate that a transition was just completed
            self.elementalDelegate?.elementalPageTransitionCompleted(index: index, in: self)
         }
         completion?()
      }
   }
   
   fileprivate func _setCurrentIndex(_ index: Int) {
      currentIndex = index
   }
}

extension ElementalPageViewController: UIPageViewControllerDataSource {
   public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
      guard let index = pages.index(of: viewController), index < pages.count - 1 else { return nil }
      return pages[index + 1]
   }
   
   public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
      guard let index = pages.index(of: viewController), index > 0 else { return nil }
      return pages[index - 1]
   }
   
   public func presentationCount(for pageViewController: UIPageViewController) -> Int {
      return pages.count
   }
   
   public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
      return currentIndex
   }
}

extension ElementalPageViewController: UIPageViewControllerDelegate {
   public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      guard completed else { return }
      guard let index = pageViewController.viewControllers?.first?.view.tag else { return }
      _setCurrentIndex(index)
      elementalDelegate?.elementalPageTransitionCompleted(index: index, in: self)
   }
}

open class ElementalContextPage<Context>: ElementalViewController, ElementalPage {
   // MARK: - Subclass Hooks
   func changeContext(to context: Context?) {}
}

open class ElementalContextPageViewController<Context>: ElementalPageViewController {
   // MARK: - Nested Types
   typealias Page = ElementalContextPage<Context>
   
   // MARK: - Public Properties
   var context: Context! = nil {
      didSet {
         viewControllers?.forEach { ($0 as? Page)?.changeContext(to: context) }
      }
   }
   
   // Subclass Hooks
   override open func prepareForTransition(from currentPage: UIViewController?, to nextPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      super.prepareForTransition(from: currentPage, to: nextPage, direction: direction, animated: animated)
      (nextPage as? Page)?.changeContext(to: context)
   }
   
   override open func recoverAfterTransition(from previousPage: UIViewController?, to currentPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      super.recoverAfterTransition(from: previousPage, to: currentPage, direction: direction, animated: animated)
      (previousPage as? Page)?.changeContext(to: nil)
   }
   
   // MARK: - Init
   public convenience init(context: Context, viewControllers: [UIViewController]) {
      self.init(viewControllers: viewControllers)
      self.context = context
   }
}

