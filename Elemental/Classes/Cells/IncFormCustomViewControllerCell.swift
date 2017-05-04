//
//  IncFormViewControllerCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/10/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormCustomViewControllerCell: IncFormElementCell {
   private var _viewController: UIViewController?
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
         guard newValue != _contained, let viewController = _viewController else { return }
         if (newValue) {
            if (viewController.view.superview != nil) {
               viewController.view.removeFromSuperview()
               viewController.removeFromParentViewController()
            }
            containerVC.addChildViewController(viewController)
            contentView.addAndFill(subview: viewController.view)
            viewController.didMove(toParentViewController: containerVC)
         } else {
            guard viewController.view.superview == contentView else { return }
            viewController.view.removeFromSuperview()
            viewController.removeFromParentViewController()
         }
      }
   }
   
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormCustomViewController else { fatalError() }
      _viewController = element.viewController
      _contained = window != nil
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormCustomViewController else { fatalError() }
      return element.sizeDelegate.size(for: element, constrainedWidth: width)
   }
   
   override func prepareForReuse() {
      _contained = false
      super.prepareForReuse()
   }
   
   override func willMove(toWindow newWindow: UIWindow?) {
      _contained = newWindow != nil
   }
}
