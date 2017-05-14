//
//  IncFormCustomViewCell.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormCustomViewCell: ElementCell {
   private var _customView: UIView?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      clipsToBounds = false
   }
   
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormCustomView else { fatalError() }
      contentView.addSubview(element.view)
      _customView = element.view
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormCustomView else { fatalError() }
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
