//
//  IncFormViewController.swift
//  GigSalad
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public enum FormContentTransitionType {
   case forwards
   case backwards
}

public protocol IncFormViewControllerDelegate: class {
   func elementsBeganRefreshing(in viewController: IncFormViewController)
   func elementSelected(_ element: IncFormElemental, in viewController: IncFormViewController)
}

extension IncFormViewControllerDelegate {
   public func elementSelected(_ element: IncFormElemental, in viewController: IncFormViewController) {}
   public func elementsBeganRefreshing(in viewController: IncFormViewController) {}
}

open class IncFormViewController: UIViewController {
   // MARK: - Private Properties
   fileprivate lazy var _refreshControl: UIRefreshControl = {
      let control = UIRefreshControl()
      let selector = #selector(IncFormViewController._refreshControlChanged(control:))
      control.addTarget(self, action: selector, for: .valueChanged)
      control.layer.zPosition = -1
      return control
   }()
   
   fileprivate var _cvLeadingSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
   fileprivate lazy var _collectionView: UICollectionView = {
      let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
      cv.translatesAutoresizingMaskIntoConstraints = false
      self.view.addSubview(cv)
      
      cv.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
      cv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
      cv.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
      
      self._cvLeadingSpaceConstraint = cv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
      self._cvLeadingSpaceConstraint.isActive = true
      
      cv.dataSource = self
      cv.delegate = self
      cv.backgroundColor = .clear
      cv.keyboardDismissMode = .onDrag
      cv.delaysContentTouches = false
   
      return cv
   }()
   
   fileprivate var _animatingIndexPaths: [IndexPath]?
   fileprivate var _needsLayout: Bool = false
   fileprivate var _elements: [IncFormElemental] = []
   
   // MARK: - Public Properties
   var elements: [IncFormElemental] {
      get { return _elements }
      set { configure(with: newValue) }
   }
   
   public weak var formDelegate: IncFormViewControllerDelegate?
   
   public var layout: UICollectionViewLayout {
      get { return collectionView.collectionViewLayout }
      set { collectionView.collectionViewLayout = newValue }
   }
   
   public var keyboardDismissMode: UIScrollViewKeyboardDismissMode {
      get { return collectionView.keyboardDismissMode }
      set { collectionView.keyboardDismissMode = newValue }
   }
   
   public var scrollIndicatorStyle: UIScrollViewIndicatorStyle = .default {
      didSet {
         collectionView.indicatorStyle = scrollIndicatorStyle
      }
   }
   
   public var allowsRefresh: Bool = false {
      didSet {
         if allowsRefresh {
            collectionView.refreshControl = self._refreshControl
         } else {
            collectionView.refreshControl = nil
         }
      }
   }
   
   public var showsScrollIndicator: Bool = true {
      didSet {
         collectionView.showsVerticalScrollIndicator = showsScrollIndicator
         collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
      }
   }
   
   public var delaysContentTouches: Bool {
      get { return collectionView.delaysContentTouches }
      set { collectionView.delaysContentTouches = newValue }
   }
   
   public var componentPadding: CGFloat = 0.0 {
      didSet {
         collectionView.collectionViewLayout.invalidateLayout()
      }
   }
   
   public var sidePadding: CGFloat = 24.0 {
      didSet {
         collectionView.collectionViewLayout.invalidateLayout()
      }
   }
   
   public var collectionView: UICollectionView {
      loadViewIfNeeded()
      return _collectionView
   }
   
   public var isScrollEnabled: Bool {
      get { return collectionView.isScrollEnabled }
      set { collectionView.isScrollEnabled = newValue }
   }
   
   // MARK: - Public
   func index(of elemental: IncFormElemental) -> Int? {
      for (index, element) in _elements.enumerated() {
         if element as AnyObject !== elemental as AnyObject { continue }
         return index
      }
      return nil
   }
   
    @discardableResult func scroll(to elemental: IncFormElemental, position: UICollectionViewScrollPosition, animated: Bool) -> Bool {
      guard let index = index(of: elemental) else { return false }
      collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: position, animated: animated)
      return true
   }
   
   open func reload() {
      loadViewIfNeeded()
      configure(with: generateElements() ?? _elements, scrollToTop: false)
   }
   
   public func setNeedsLayout() {
      guard !_needsLayout else { return }
      _needsLayout = true
      DispatchQueue.main.async {
         guard self._needsLayout else { return }
         self.reloadLayout()
      }
   }
   
   public func contentSize(constrainedWidth width: CGFloat) -> CGSize {
      var height: CGFloat = 0
      _elements.forEach { component in
         height += component.size(forConstrainedDimension: .horizontal(width)).height
      }
      height += CGFloat(max(0, _elements.count - 1)) * componentPadding
      return CGSize(width: width, height: height)
   }
   
   open func formDidLoad() {
      guard let elements = generateElements() else { return }
      self.elements = elements
   }
   
   open func generateElements() -> [IncFormElemental]? {
      return nil
   }
   
   // MARK: - Overridden
   override open func viewDidLoad() {
      super.viewDidLoad()
      _ = collectionView
      formDidLoad()
   }
   
   // MARK: - Private
   @objc private func _refreshControlChanged(control: UIRefreshControl) {
      formDelegate?.elementsBeganRefreshing(in: self)
   }
}

extension IncFormViewController {
   public func stopRefreshing() {
      _refreshControl.endRefreshing()
   }
   
   public func configure(with elements: [IncFormElemental], transitionType: FormContentTransitionType? = nil, scrollToTop: Bool = true) {
      elements.forEach { $0.register(collectionView: collectionView) }
      self._elements = elements
      
      if let transitionType = transitionType {
         collectionView.reloadData()
         guard let screenshot = view.snapshotView(afterScreenUpdates: false) else { return }
         view.addSubview(screenshot)
         
         switch transitionType {
         case .forwards: _cvLeadingSpaceConstraint.constant = collectionView.bounds.width
         case .backwards: _cvLeadingSpaceConstraint.constant = -collectionView.bounds.width
         }
         view.layoutIfNeeded()
         collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
         
         collectionView.alpha = 0
         UIView.animate(withDuration: 0.25, animations: {
            self._cvLeadingSpaceConstraint.constant = 0
            switch transitionType {
            case .forwards: screenshot.frame.origin.x -= self.view.bounds.width
            case .backwards: screenshot.frame.origin.x += self.view.bounds.width
            }
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 1
            screenshot.alpha = 0
         }, completion: { finished in
            screenshot.removeFromSuperview()
         })
      } else {
         collectionView.reloadData()
         if !elements.isEmpty, scrollToTop {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
         }
      }
   }
   
   public func reloadComponents() {
      collectionView.reloadData()
   }
   
   public func reconfigure(elements: [IncFormElemental]) {
      for (index, element) in self.elements.enumerated() {
         if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) {
            elements.forEach {
               element.reconfigure(cell: cell, for: $0, in: self)
            }
         }
      }
   }

   public func reconfigure(componentsAt indices: IndexSet) {
      indices.forEach {
         let indexPath: IndexPath = IndexPath(row: $0, section: 0)
         if let cell = collectionView.cellForItem(at: indexPath) {
            _elements[$0].configure(cell: cell, in: self)
         }
      }
   }
   
   public func reloadLayout(animated: Bool = true) {
      _needsLayout = false
      guard animated else { collectionView.collectionViewLayout.invalidateLayout(); return }
      _animatingIndexPaths = collectionView.indexPathsForVisibleItems
      collectionView.performBatchUpdates({
         self.collectionView.collectionViewLayout.invalidateLayout()
      }, completion: { _ in
         self._animatingIndexPaths = nil
      })
   }
   
   func contentSize(constraintedWidth width: CGFloat) -> CGSize {
      var height: CGFloat = 0
      _elements.forEach { component in
         height += component.size(forConstrainedDimension: .horizontal(width)).height
      }
      height += CGFloat(max(0, _elements.count - 1)) * componentPadding
      return CGSize(width: width, height: height)
   }
}

extension IncFormViewController: UICollectionViewDataSource {
   public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return _elements.count
   }
   
   public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let component = _elements[indexPath.row]
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: component.cellID, for: indexPath)
      component.configure(cell: cell, in: self)
      return cell
   }
}

extension IncFormViewController: UICollectionViewDelegateFlowLayout {
   public func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
      let component = _elements[indexPath.row]
      let padding: CGFloat = component.elementalConfig.isConfinedToMargins ? (sidePadding * 2) : 0.0
      let maxWidth: CGFloat = collectionView.bounds.width - padding
      
      return component.size(forConstrainedDimension: .horizontal(maxWidth))
   }
   
   public func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       insetForSectionAt section: Int) -> UIEdgeInsets {
      return .zero
   }
   
   public func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return componentPadding
   }
   
   public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return componentPadding
   }
   
   public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      let element = _elements[indexPath.row]
      guard element.elementalConfig.isSelectable else { return }
      formDelegate?.elementSelected(element, in: self)
   }
   
   public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      if let animatingPaths = _animatingIndexPaths, !animatingPaths.contains(indexPath) {
         let finalAlpha = cell.alpha
         cell.alpha = 0
         DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0.2, animations: {
               cell.alpha = finalAlpha
            })
         }
      }
   }
}
