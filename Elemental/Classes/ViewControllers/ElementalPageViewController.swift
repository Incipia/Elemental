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

public protocol ElementalContextual {
   func enter<Context>(context: Context)
   func leave<Context>(context: Context)
   func changeContext<OldContext, NewContext>(from oldContext: OldContext, to context: NewContext)
}

public extension ElementalContextual {
   func enter<Context>(context: Context) {}
   func leave<Context>(context: Context) {}
   func changeContext<OldContext, NewContext>(from oldContext: OldContext, to context: NewContext) {}
}

open class ElementalContextPage<PageContext>: ElementalViewController, ElementalPage, ElementalContextual {
   // MARK: - Subclass Hooks
   open func enterOwn(context: PageContext) {}
   open func leaveOwn(context: PageContext) {}
   open func changeOwnContext(from oldContext: PageContext, to context: PageContext) {}
   
   // MARK: - ElementalContextual
   open func enter<Context>(context: Context) {
      guard let pageContext = context as? PageContext else { return }
      enterOwn(context: pageContext)
   }
   
   open func leave<Context>(context: Context) {
      guard let pageContext = context as? PageContext else { return }
      leaveOwn(context: pageContext)
   }
   
   open func changeContext<OldContext, NewContext>(from oldContext: OldContext, to context: NewContext) {
      if let oldPageContext = oldContext as? PageContext, let pageContext = context as? PageContext {
         changeOwnContext(from: oldPageContext, to: pageContext)
      } else if let oldPageContext = oldContext as? PageContext {
         leaveOwn(context: oldPageContext)
      } else if let pageContext = context as? PageContext {
         enterOwn(context: pageContext)
      }
   }
}

open class ElementalContextPageViewController<Context>: ElementalPageViewController {
   // MARK: - Nested Types
   typealias Page = ElementalContextPage<Context>
   
   // MARK: - Private Properties
   private var _transitionContext: Context?
   
   // MARK: - Public Properties
   var context: Context? {
      didSet {
         if let oldContext = oldValue, let context = context {
            viewControllers?.forEach { ($0 as? ElementalContextual)?.changeContext(from: oldValue, to: oldContext) }
         } else if let oldContext = oldValue {
            viewControllers?.forEach { ($0 as? ElementalContextual)?.leave(context: oldContext) }
         } else if let context = context {
            viewControllers?.forEach { ($0 as? ElementalContextual)?.enter(context: context) }
         }
      }
   }
   
   // Subclass Hooks
   override open func prepareForTransition(from currentPage: UIViewController?, to nextPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      super.prepareForTransition(from: currentPage, to: nextPage, direction: direction, animated: animated)
      
      guard let context = context else { return }
      guard _transitionContext == nil else { fatalError("Preparing for next transition before recovering from last") }
      _transitionContext = context
      (nextPage as? ElementalContextual)?.enter(context: context)
   }
   
   override open func recoverAfterTransition(from previousPage: UIViewController?, to currentPage: UIViewController?, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
      super.recoverAfterTransition(from: previousPage, to: currentPage, direction: direction, animated: animated)
      
      guard  let transitionContext = _transitionContext else { return }
      (previousPage as? ElementalContextual)?.leave(context: transitionContext)
      _transitionContext = nil
   }
   
   // MARK: - Init
   public convenience init(context: Context, viewControllers: [UIViewController]) {
      self.init(viewControllers: viewControllers)
      self.context = context
   }
}

