//
//  VerticalLineElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/18/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class VerticalLineElementCell: ElementCell {
   override func configure(with component: Elemental) {
      super.configure(with: component)
      switch component {
      case let element as VerticalLineElement: backgroundColor = element.configuration.color
      case _ as HorizontalSpaceElement: backgroundColor = .clear
      default: fatalError()
      }
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      switch element {
      case let element as VerticalLineElement: return CGSize(width: width, height: 0)
      case let element as HorizontalSpaceElement: return CGSize(width: element.value, height: 1)
      default: fatalError()
      }
   }
}
