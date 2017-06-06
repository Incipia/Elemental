//
//  HorizontalElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/17/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

//
//  ViewControllerElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/10/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

protocol HorizontalFormElementCellDelegate: class {
   func componentSelected(_ component: Elemental, in cell: HorizontalFormElementCell)
}

// TODO: Disable scrolling when the keyboard is about to show

class HorizontalFormElementCell: ElementCell {
   private var _form: ElementalViewController?
   private var _components: [Elemental]?
   weak var delegate: HorizontalFormElementCellDelegate?
   weak var containerVC: UIViewController! {
      willSet {
         guard newValue != containerVC else { return }
         _contained = false
      }
      didSet {
         guard oldValue != containerVC else { return }
         _contained = window != nil
      }
   }
   
   private var _contained: Bool = false {
      willSet {
         guard newValue != _contained, let form = _form else { return }
         if (newValue) {
            containerVC.addChildViewController(form)
            contentView.addAndFill(subview: form.view)
            form.didMove(toParentViewController: containerVC)
         } else {
            form.willMove(toParentViewController: nil)
            form.view.removeFromSuperview()
            form.removeFromParentViewController()
         }
      }
   }
   
   func reloadLayout() {
      _form?.reloadLayout()
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? HorizontalFormElement else { fatalError() }
      _contained = false
      _form = _form ?? ElementalViewController()
      guard let form = _form else { fatalError("Could not instantiate ElementalViewController") }
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      form.layout = layout
      form.formDelegate = self
      form.configure(with: element.elements)
      _components = element.elements
      _contained = window != nil
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? HorizontalFormElement else { fatalError() }
      let height: CGFloat = element.elements.reduce(0) { (height, component) -> CGFloat in
         max(height, component.size(forConstrainedSize: size, layoutDirection: .vertical).height)
      }
      return CGSize(width: width, height: ceil(height))
   }
   
   func reconfigure(elements: [Elemental]) {
      _form?.reconfigure(elements: elements)
   }
   
   override func prepareForReuse() {
      _contained = false
      _components = nil
      super.prepareForReuse()
   }
   
   override func willMove(toWindow newWindow: UIWindow?) {
      _contained = newWindow != nil
   }
   
}

extension HorizontalFormElementCell: ElementalViewControllerDelegate {
   func elementSelected(_ element: Elemental, in viewController: ElementalViewController) {
      delegate?.componentSelected(element, in: self)
   }
}
