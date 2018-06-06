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
   case leftToRight
   case rightToLeft
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

   fileprivate var _headerViewTopSpaceConstraint: NSLayoutConstraint!
   fileprivate var _headerViewBottomSpaceConstraint: NSLayoutConstraint!
   
   fileprivate lazy var _headerContainerView: UIView = {
      let headerView = UIView(frame: .zero)
      headerView.translatesAutoresizingMaskIntoConstraints = false
      return headerView
   }()
   
   fileprivate lazy var _emptyHeaderView: UIView = {
      let view = UIView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.heightAnchor.constraint(equalToConstant: 0).isActive = true
      return view
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
      let headerContainerView = self._headerContainerView
      let footerContainerView = self._footerContainerView
      self.view.addSubview(headerContainerView)
      self.view.addSubview(footerContainerView)
      
      self._headerViewBottomSpaceConstraint = headerContainerView.bottomAnchor.constraint(equalTo: cv.topAnchor)
      self._headerViewTopSpaceConstraint = headerContainerView.topAnchor.constraint(equalTo: self.view.topAnchor)
      self._footerViewBottomSpaceConstraint = footerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
      self._footerViewTopSpaceConstraint = footerContainerView.topAnchor.constraint(equalTo: cv.bottomAnchor)
      self._cvLeadingSpaceConstraint = cv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
      self._update(containerView: self._headerContainerView, with: self._emptyHeaderView)
      self._update(containerView: self._footerContainerView, with: self._emptyFooterView)
      
      NSLayoutConstraint.activate([
         cv.widthAnchor.constraint(equalTo: self.view.widthAnchor),
         self._headerViewBottomSpaceConstraint,
         self._headerViewTopSpaceConstraint,
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
      
      if #available(iOS 11.0, *) {
         cv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
      } else {
         // Fallback on earlier versions
      }
   
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
   @objc public var headerViewTopPadding: CGFloat = 0 {
      didSet {
         _headerViewTopSpaceConstraint.constant = headerViewTopPadding
      }
   }
   
   @objc public var headerViewBottomPadding: CGFloat = 0 {
      didSet {
         _headerViewBottomSpaceConstraint.constant = -headerViewBottomPadding
      }
   }
   
   @objc public var headerView: UIView? {
      didSet {
         switch headerView {
         case .none: _update(containerView: _headerContainerView, with: _emptyHeaderView)
         case .some(let view): _update(containerView: _headerContainerView, with: view)
         }
      }
   }

   @objc public var footerViewTopPadding: CGFloat = 0 {
      didSet {
         _footerViewTopSpaceConstraint.constant = footerViewTopPadding
      }
   }
   
   @objc public var footerViewBottomPadding: CGFloat = 0 {
      didSet {
         _footerViewBottomSpaceConstraint.constant = -footerViewBottomPadding
      }
   }
   
   @objc public var footerView: UIView? {
      didSet {
         switch footerView {
         case .none: _update(containerView: _footerContainerView, with: _emptyFooterView)
         case .some(let view): _update(containerView: _footerContainerView, with: view)
         }
      }
   }
   
   public var elements: [Elemental] {
      get { return _elements }
      set { configure(with: newValue) }
   }
   
   public weak var formDelegate: ElementalViewControllerDelegate?
   
   @objc public var layout: UICollectionViewLayout {
      get { return collectionView.collectionViewLayout }
      set { collectionView.collectionViewLayout = newValue }
   }
   
   @objc public var keyboardDismissMode: UIScrollViewKeyboardDismissMode {
      get { return collectionView.keyboardDismissMode }
      set { collectionView.keyboardDismissMode = newValue }
   }
   
   @objc public var scrollIndicatorStyle: UIScrollViewIndicatorStyle = .default {
      didSet {
         collectionView.indicatorStyle = scrollIndicatorStyle
      }
   }
   
   @objc public var allowsRefresh: Bool = false {
      didSet {
         if allowsRefresh {
            collectionView.refreshControl = self._refreshControl
         } else {
            collectionView.refreshControl = nil
         }
      }
   }
   
   @objc public var showsScrollIndicator: Bool = true {
      didSet {
         collectionView.showsVerticalScrollIndicator = showsScrollIndicator
         collectionView.showsHorizontalScrollIndicator = showsScrollIndicator
      }
   }
   
   @objc public var delaysContentTouches: Bool {
      get { return collectionView.delaysContentTouches }
      set { collectionView.delaysContentTouches = newValue }
   }
   
   @objc public var componentPadding: CGFloat = 0.0 {
      didSet {
         collectionView.collectionViewLayout.invalidateLayout()
      }
   }
   
   @objc public var sidePadding: CGFloat = 24.0 {
      didSet {
         collectionView.collectionViewLayout.invalidateLayout()
      }
   }
   
   @objc public var collectionView: UICollectionView {
      loadViewIfNeeded()
      return _collectionView
   }
   
   @objc public var isScrollEnabled: Bool {
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
   
    @discardableResult public func scroll(to elemental: Elemental, position: UICollectionViewScrollPosition, animated: Bool) -> Bool {
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
   
   @objc public func setNeedsLayout(animated: Bool = true) {
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
   
   @objc public func contentSize(constrainedWidth width: CGFloat) -> CGSize {
      var height: CGFloat = 0
      let size = CGSize(width: width, height: collectionView.bounds.height)
      _elements.forEach { component in
         height += component.size(forConstrainedSize: size, layoutDirection: .vertical).height
      }
      height += CGFloat(max(0, _elements.count - 1)) * componentPadding
      return CGSize(width: width, height: height)
   }
   
   @objc open func formDidLoad() {
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

   private func _update(containerView: UIView, with view: UIView) {
      loadViewIfNeeded()
      containerView.subviews.forEach { $0.removeFromSuperview() }
      containerView.addSubview(view)
      
      if view.translatesAutoresizingMaskIntoConstraints {
         NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            ])
      } else {
         NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            ])
      }
   }
}

extension ElementalViewController {
   @objc public var isRefreshing: Bool { return collectionView.refreshControl?.isRefreshing ?? false }
   
   @objc public func startRefreshing() {
      guard let refreshControl = collectionView.refreshControl, !refreshControl.isRefreshing else { return }
      refreshControl.beginRefreshing()
   }
   
   @objc public func stopRefreshing() {
      guard let refreshControl = collectionView.refreshControl, refreshControl.isRefreshing else { return }
      _refreshControl.endRefreshing()
   }
   
   public func configure(with elements: [Elemental], transition: ElementalTransition = .none, scrollToTop: Bool = true) {
      elements.forEach { $0.register(collectionView: collectionView) }
      self._elements = elements
      
      func _animateReloadedCollectionViewIn(fromRight: Bool) {
         defer { collectionView.reloadData() }
         
         guard let screenshot = collectionView.snapshotView(afterScreenUpdates: false) else { return }
         view.insertSubview(screenshot, aboveSubview: collectionView)
         
         _cvLeadingSpaceConstraint.constant = collectionView.bounds.width * (fromRight ? 1 : -1)
         view.layoutIfNeeded()
         
         collectionView.alpha = 0
         UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self._cvLeadingSpaceConstraint.constant = 0
            screenshot.frame.origin.x += self.collectionView.bounds.width * (fromRight ? -1 : 1)
            screenshot.alpha = 0
            self.view.layoutIfNeeded()
            self.collectionView.alpha = 1
         }, completion: { finished in
            screenshot.removeFromSuperview()
         })
      }
      
      switch transition {
      case .none: collectionView.reloadData()
      case .rightToLeft: _animateReloadedCollectionViewIn(fromRight: true)
      case .leftToRight: _animateReloadedCollectionViewIn(fromRight: false)
      }
      
      if !elements.isEmpty, scrollToTop {
         collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
      }
   }
   
   @objc public func reloadComponents() {
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

   @objc public func reconfigure(componentsAt indices: IndexSet) {
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
      cell.bounds.size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
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
