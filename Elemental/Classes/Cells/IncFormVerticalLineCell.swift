//
//  IncFormVerticalLineCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/18/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormVerticalLineCell: ElementCell {
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      switch component {
      case let element as IncFormVerticalLine: backgroundColor = element.configuration.color
      case _ as IncFormHorizontalSpace: backgroundColor = .clear
      default: fatalError()
      }
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      switch element {
      case let element as IncFormVerticalLine: return CGSize(width: element.configuration.width ?? width, height: element.configuration.height ?? 0)
      case let element as IncFormHorizontalSpace: return CGSize(width: element.value, height: 1)
      default: fatalError()
      }
   }
}
