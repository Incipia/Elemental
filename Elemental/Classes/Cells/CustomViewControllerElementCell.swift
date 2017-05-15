//
//  ViewControllerElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/10/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class CustomViewControllerElementCell: ElementCell {
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
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? CustomViewControllerElement else { fatalError() }
      _viewController = element.viewController
      _contained = window != nil
   }
   
   override class func contentSize(for element: Elemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? CustomViewControllerElement else { fatalError() }
      return element.sizeDelegate?.size(for: element, constrainedWidth: width) ?? .zero
   }
   
   override func prepareForReuse() {
      _contained = false
      super.prepareForReuse()
   }
   
   override func willMove(toWindow newWindow: UIWindow?) {
      _contained = newWindow != nil
   }
}
