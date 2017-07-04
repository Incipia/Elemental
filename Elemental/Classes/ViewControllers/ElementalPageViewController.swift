//
//  ElementalPageViewController.swift
//  Pods
//
//  Created by Leif Meyer on 7/3/17.
//
//

import UIKit

protocol ElementalPageViewControllerDelegate: class {
   func elementalPageTransitionCompleted(index: Int, in viewController: ElementalPageViewController)
}

class ElementalPageViewController: UIPageViewController {
   // MARK: - Private Properties
   fileprivate var _vcs: [UIViewController] = [] {
      didSet {
         for (index, vc) in _vcs.enumerated() { vc.view.tag = index }
      }
   }
   
   fileprivate var _currentIndex = 0
   
   // MARK: - Public Properties
   weak var elementalDelegate: ElementalPageViewControllerDelegate?
   
   var totalSteps: Int {
      return _vcs.count
   }
   
   // MARK: - Init
   convenience init(viewControllers: [UIViewController]) {
      self.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
      self._vcs = viewControllers
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
      _commonInit()
   }
   
   override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
      super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
      _commonInit()
   }
   
   private func _commonInit() {
      delegate = self
      dataSource = self
   }
   
   // MARK: - Life Cycle
   override func viewDidLoad() {
      super.viewDidLoad()
      view.subviews.forEach { ($0 as? UIScrollView)?.delaysContentTouches = false }
      setViewControllers([_vcs.first!], direction: .forward, animated: false, completion: nil)
   }
   
   // MARK: - Public
   func navigate(_ direction: UIPageViewControllerNavigationDirection, completion: (() -> Void)? = nil) {
      guard let current = viewControllers?.first else { completion?(); return }
      
      var next: UIViewController?
      switch direction {
      case .forward: next = dataSource?.pageViewController(self, viewControllerAfter: current)
      case .reverse: next = dataSource?.pageViewController(self, viewControllerBefore: current)
      }
      
      guard let target = next else { completion?(); return }
      switch direction {
      case .forward: _currentIndex = _currentIndex + 1
      case .reverse: _currentIndex = _currentIndex - 1
      }
      
      setViewControllers([target], direction: direction, animated: true) { finished in
         if let index = self._vcs.index(of: target) {
            // calling setViewControllers(direction:animated:) doesn't trigger the UIPageViewControllerDelegate method
            // didFinishAnimating, so we have to tell our listingPageDelegate that a transition was just completed
            self.elementalDelegate?.elementalPageTransitionCompleted(index: index, in: self)
         }
         completion?()
      }
   }
   
   func navigateToFirst() {
      for _ in 0..<_vcs.count { navigate(.reverse) }
      _currentIndex = 0
   }
}

extension ElementalPageViewController: UIPageViewControllerDataSource {
   func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
      guard let index = _vcs.index(of: viewController), index < _vcs.count - 1 else { return nil }
      return _vcs[index + 1]
   }
   
   func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
      guard let index = _vcs.index(of: viewController), index > 0 else { return nil }
      return _vcs[index - 1]
   }
   
   func presentationCount(for pageViewController: UIPageViewController) -> Int {
      return _vcs.count
   }
   
   func presentationIndex(for pageViewController: UIPageViewController) -> Int {
      return _currentIndex
   }
}

extension ElementalPageViewController: UIPageViewControllerDelegate {
   func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      guard completed else { return }
      guard let index = pageViewController.viewControllers?.first?.view.tag else { return }
      _currentIndex = index
      elementalDelegate?.elementalPageTransitionCompleted(index: index, in: self)
   }
}
