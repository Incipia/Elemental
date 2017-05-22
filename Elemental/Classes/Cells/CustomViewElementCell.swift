//
//  CustomViewElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class CustomViewElementCell: ElementCell {
   private var _customView: UIView?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      clipsToBounds = false
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? CustomViewElement else { fatalError() }
      contentView.addSubview(element.view)
      _customView = element.view
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? CustomViewElement else { fatalError() }
      return element.view.bounds.size
   }
   
   override func prepareForReuse() {
      if _customView?.superview == contentView {
         _customView?.removeFromSuperview()
      }
      _customView = nil
      super.prepareForReuse()
   }
}
