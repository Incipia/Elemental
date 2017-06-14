//
//  ElementalViewController.swift
//  Elemental
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public enum ElementalTransition {
   case none
   case forwards
   case backwards
}

public protocol ElementalViewControllerDelegate: class {
   func elementsBeganRefreshing(in viewController: ElementalViewController)
   func elementSelected(_ element: Elemental, in viewController: ElementalViewController)
   func reloadedLayout(for elements: [Elemental], scrollPosition: UICollectionViewScrollPosition, animated: Bool, in viewController: ElementalViewController)
}

extension ElementalViewControllerDelegate {
   public func elementSelected(_ element: Elemental, in viewController: ElementalViewController) {}
   public func elementsBeganRefreshing(in viewController: ElementalViewController) {}
   public func reloadedLayout(for elements: [Elemental], scrollPosition: UICollectionViewScrollPosition, animated: Bool, in viewController: ElementalViewController) {}
}

open class ElementalViewController: UIViewController {
   // MARK: - Private Properties
   fileprivate lazy var _refreshControl: UIRefreshControl = {
      let control = UIRefreshControl()
      let selector = #selector(ElementalViewController._refreshControlChanged(control:))
      control.addTarget(self, action: selector, for: .valueChanged)
      control.layer.zPosition = -1
      return control
   }()
   
   fileprivate var _footerViewTopSpaceConstraint: NSLayoutConstraint!
   fileprivate var _footerViewBottomSpaceConstraint: NSLayoutConstraint!
   
   fileprivate lazy var _footerContainerView: UIView = {
      let footerView = UIView(frame: .zero)
      footerView.translatesAutoresizingMaskIntoConstraints = false
      return footerView
   }()
   
   fileprivate lazy var _emptyFooterView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.heightAnchor.constraint(equalToConstant: 0).isActive = true
      return view
   }()
   
   fileprivate lazy var _collectionView: UICollectionView = {
      let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
      cv.translatesAutoresizingMaskIntoConstraints = false
      self.view.addSubview(cv)
      let footerContainerView = self._footerContainerView
      self.view.addSubview(footerContainerView)
      
      
      self._footerViewBottomSpaceConstraint = footerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
      self._footerViewTopSpaceConstraint = footerContainerView.topAnchor.constraint(equalTo: cv.bottomAnchor)
      self._cvLeadingSpaceConstraint = cv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
      self._update(footerView: self._emptyFooterView)
      
      NSLayoutConstraint.activate([
         cv.topAnchor.constraint(equalTo: self.view.topAnchor),
         cv.widthAnchor.constraint(equalTo: self.view.widthAnchor),
         self._footerViewBottomSpaceConstraint,
         self._footerViewTopSpaceConstraint,
         self._cvLeadingSpaceConstraint,
         footerContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      ])
      
      cv.dataSource = self
      cv.delegate = self
      cv.backgroundColor = .clear
      cv.keyboardDismissMode = .onDrag
      cv.delaysContentTouches = true
   
      return cv
   }()
   
   fileprivate var _cvLeadingSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
   fileprivate var _elements: [Elemental] = []
   
   struct ReloadState {
      var needsReload = false
      var transition: ElementalTransition = .none
      
      mutating func reset() {
         self = ReloadState()
      }
   }
   fileprivate var _reloadState = ReloadState()
   
   struct LayoutState {
      var needsLayout = false
      var animated = false
      var elements: [Elemental] = []
      var scrollPosition: UICollectionViewScrollPosition = []
      
      mutating func reset() {
         self = LayoutState()
      }
   }
   fileprivate var _layoutState = LayoutState()
   
   // MARK: - Public Properties
   public var footerViewTopPadding: CGFloat = 0 {
      didSet {
         _footerViewTopSpaceConstraint.constant = footerViewTopPadding
      }
   }
   
   public var footerViewBottomPadding: CGFloat = 0 {
      didSet {
         _footerViewBottomSpaceConstraint.constant = -footerViewBottomPadding
      }
   }
   
   public var footerView: UIView? {
      didSet {
         switch footerView {
         case .none: _removeFooterView()
         case .some(let view): _update(footerView: view)
         }
      }
   }
   
   public var elements: [Elemental] {
      get { return _elements }
      set { configure(with: newValue) }
   }
   
   public weak var formDelegate: ElementalViewControllerDelegate?
   
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
   func index(of elemental: Elemental) -> Int? {
      for (index, element) in _elements.enumerated() {
         if element as AnyObject !== elemental as AnyObject { continue }
         return index
      }
      return nil
   }
   
    @discardableResult func scroll(to elemental: Elemental, position: UICollectionViewScrollPosition, animated: Bool) -> Bool {
      guard !position.isEmpty else { return false }
      guard let index = index(of: elemental) else { return false }
      collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: position, animated: animated)
      return true
   }
   
   open func reload(transition: ElementalTransition? = nil) {
      loadViewIfNeeded()
      let transition = transition ?? _reloadState.transition
      configure(with: generateElements() ?? _elements, transition: transition, scrollToTop: false)
      _reloadState.reset()
   }
   
   public func setNeedsReload(transition: ElementalTransition? = nil) {
      guard !_reloadState.needsReload else { return }
      _reloadState.needsReload = true
      
      if let transition = transition {
         _reloadState.transition = transition
      }
      DispatchQueue.main.async {
         guard self._reloadState.needsReload else { return }
         self.reload(transition: self._reloadState.transition)
      }
   }
   
   public func setNeedsLayout(animated: Bool = true) {
      _layoutState.animated = _layoutState.animated || animated
      guard !_layoutState.needsLayout else { return }
      _layoutState.needsLayout = true
      DispatchQueue.main.async {
         guard self._layoutState.needsLayout else { return }
         self.reloadLayout(animated: self._layoutState.animated)
      }
   }

   public func setNeedsLayout(for element: Elemental, scrollPosition: UICollectionViewScrollPosition, animated: Bool = true) {
      guard let index = index(of: element) else { return }
      let indexPath = IndexPath(row: index, section: 0)
      guard let cell = collectionView.cellForItem(at: indexPath) else { return }
      
      guard _layoutState.needsLayout || element.size(forConstrainedSize: _constrainedSize(for: element), layoutDirection: .vertical) != cell.frame.size else {
         scroll(to: element, position: scrollPosition, animated: animated)
         self.formDelegate?.reloadedLayout(for: [element], scrollPosition: scrollPosition, animated: animated, in: self)
         return
      }
      
      if scrollPosition.isEmpty {
         _layoutState.elements.insert(element, at: 0)
      } else {
         _layoutState.elements.append(element)
         _layoutState.scrollPosition = scrollPosition
      }
      
      setNeedsLayout(animated: animated)
   }
   
   public func contentSize(constrainedWidth width: CGFloat) -> CGSize {
      var height: CGFloat = 0
      let size = CGSize(width: width, height: collectionView.bounds.height)
      _elements.forEach { component in
         height += component.size(forConstrainedSize: size, layoutDirection: .vertical).height
      }
      height += CGFloat(max(0, _elements.count - 1)) * componentPadding
      return CGSize(width: width, height: height)
   }
   
   open func formDidLoad() {
      guard let elements = generateElements() else { return }
      self.elements = elements
   }
   
   open func generateElements() -> [Elemental]? {
      return nil
   }
   
   // MARK: - Overridden
   override open func viewDidLoad() {
      super.viewDidLoad()
      _ = collectionView
      formDidLoad()
   }
   
   // MARK: - Private
   private func _constrainedSize(for element: Elemental) -> CGSize {
      let padding: CGFloat = element.elementalConfig.isConfinedToMargins ? (sidePadding * 2) : 0.0
      let maxWidth: CGFloat = collectionView.bounds.width - padding
      return CGSize(width: maxWidth, height: collectionView.frame.height)
   }
   
   @objc private func _refreshControlChanged(control: UIRefreshControl) {
      formDelegate?.elementsBeganRefreshing(in: self)
   }
   
   private func _removeFooterView() {
      _update(footerView: _emptyFooterView)
   }
   
   private func _update(footerView: UIView) {
      _footerContainerView.subviews.forEach { $0.removeFromSuperview() }
      _footerContainerView.addSubview(footerView)
      
      if footerView.translatesAutoresizingMaskIntoConstraints {
         NSLayoutConstraint.activate([
            _footerContainerView.widthAnchor.constraint(equalTo: footerView.widthAnchor),
            _footerContainerView.heightAnchor.constraint(equalTo: footerView.heightAnchor),
            ])
      } else {
         NSLayoutConstraint.activate([
            footerView.centerYAnchor.constraint(equalTo: _footerContainerView.centerYAnchor),
            footerView.centerXAnchor.constraint(equalTo: _footerContainerView.centerXAnchor),
            _footerContainerView.widthAnchor.constraint(equalTo: footerView.widthAnchor),
            _footerContainerView.heightAnchor.constraint(equalTo: footerView.heightAnchor),
            ])
      }
   }
}

extension ElementalViewController {
   public func stopRefreshing() {
      _refreshControl.endRefreshing()
   }
   
   public func configure(with elements: [Elemental], transition: ElementalTransition = .none, scrollToTop: Bool = true) {
      elements.forEach { $0.register(collectionView: collectionView) }
      self._elements = elements
      
      func _animateReloadedCollectionViewIn(fromRight: Bool) {
         defer { collectionView.reloadData() }
         
         guard let screenshot = view.snapshotView(afterScreenUpdates: false) else { return }
         view.addSubview(screenshot)
         
         _cvLeadingSpaceConstraint.constant = collectionView.bounds.width * (fromRight ? 1 : -1)
         view.layoutIfNeeded()
         collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
         
         collectionView.alpha = 0
         UIView.animate(withDuration: 0.25, animations: {
            self._cvLeadingSpaceConstraint.constant = 0
            screenshot.frame.origin.x += self.view.bounds.width * (fromRight ? -1 : 1)
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 1
            screenshot.alpha = 0
         }, completion: { finished in
            screenshot.removeFromSuperview()
         })
      }
      
      switch transition {
      case .none:
         collectionView.reloadData()
         if !elements.isEmpty, scrollToTop {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
         }
      case .forwards: _animateReloadedCollectionViewIn(fromRight: true)
      case .backwards: _animateReloadedCollectionViewIn(fromRight: false)
      }
   }
   
   public func reloadComponents() {
      collectionView.reloadData()
   }
   
   public func reconfigure(elements: [Elemental]) {
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
   
   public func reloadLayout(animated: Bool? = true) {
      let animated = animated ?? _layoutState.animated
      
      let reloadState = _layoutState
      _layoutState.reset()
      guard animated else {
         collectionView.collectionViewLayout.invalidateLayout()
         if let element = reloadState.elements.last {
            scroll(to: element, position: reloadState.scrollPosition, animated: animated)
         }
         return
      }
      collectionView.performBatchUpdates({
         self.collectionView.setCollectionViewLayout(self.collectionView.collectionViewLayout, animated: animated)
      }) { _ in
         self.formDelegate?.reloadedLayout(for: reloadState.elements, scrollPosition: reloadState.scrollPosition, animated: reloadState.animated, in: self)
      }
      if let element = reloadState.elements.last {
         DispatchQueue.main.async {
            self.scroll(to: element, position: reloadState.scrollPosition, animated: animated)
         }
      }
   }
}

extension ElementalViewController: UICollectionViewDataSource {
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

extension ElementalViewController: UICollectionViewDelegateFlowLayout {
   public func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
      let component = _elements[indexPath.row]
      let padding: CGFloat = component.elementalConfig.isConfinedToMargins ? (sidePadding * 2) : 0.0
      let maxWidth: CGFloat = collectionView.bounds.width - padding
      let size = CGSize(width: maxWidth, height: collectionView.frame.height)
      
      return component.size(forConstrainedSize: size, layoutDirection: .vertical)
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
      element.elementalConfig.selectAction?(element)
      formDelegate?.elementSelected(element, in: self)
   }
}
