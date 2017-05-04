//
//  IncFormDividingLineCell.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormHorizontalLineCell: IncFormElementCell {
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      switch component {
      case let element as IncFormHorizontalLine: backgroundColor = element.configuration.color
      case _ as IncFormVerticalSpace: backgroundColor = .clear
      default: fatalError()
      }
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      switch element {
      case let element as IncFormHorizontalLine: return CGSize(width: width, height: element.configuration.height ?? 0)
      case let element as IncFormVerticalSpace: return CGSize(width: width, height: element.value)
      default: fatalError()
      }
   }
}
