//
//  DividingLineElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class HorizontalLineElementCell: ElementCell {
   override func configure(with component: Elemental) {
      super.configure(with: component)
      switch component {
      case let element as HorizontalLineElement: backgroundColor = element.configuration.color
      case _ as VerticalSpaceElement: backgroundColor = .clear
      default: fatalError()
      }
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      switch element {
      case _ as HorizontalLineElement: return CGSize(width: width, height: 1)
      case let element as VerticalSpaceElement: return CGSize(width: width, height: element.value)
      default: fatalError()
      }
   }
}
