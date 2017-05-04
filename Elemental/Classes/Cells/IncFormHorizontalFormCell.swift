//
//  IncFormHorizontalCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/17/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

//
//  IncFormViewControllerCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/10/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

protocol IncFormHorizontalFormCellDelegate: class {
   func componentSelected(_ component: IncFormElemental, in cell: IncFormHorizontalFormCell)
}

// TODO: Disable scrolling when the keyboard is about to show

class IncFormHorizontalFormCell: IncFormElementCell {
   private var _form: IncFormViewController?
   private var _components: [IncFormElemental]?
   weak var delegate: IncFormHorizontalFormCellDelegate?
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
   
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormHorizontalForm else { fatalError() }
      _contained = false
      _form = _form ?? IncFormViewController()
      guard let form = _form else { fatalError("Could not instantiate IncFormViewController") }
      let layout = UICollectionViewFlowLayout()
      layout.scrollDirection = .horizontal
      form.layout = layout
      form.formDelegate = self
      form.configure(with: element.elements)
      _components = element.elements
      _contained = window != nil
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormHorizontalForm else { fatalError() }
      let height: CGFloat = element.elements.reduce(0) { (height, component) -> CGFloat in
         max(height, component.size(forConstrainedDimension: .horizontal(width)).height)
      }
      return CGSize(width: width, height: ceil(height))
   }
   
   func reconfigure(elements: [IncFormElemental]) {
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

extension IncFormHorizontalFormCell: IncFormViewControllerDelegate {
   func elementSelected(_ element: IncFormElemental, in viewController: IncFormViewController) {
      delegate?.componentSelected(element, in: self)
   }
}
