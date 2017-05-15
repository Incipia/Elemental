//
//  TextElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class TextElementCell: ElementCell {
   @IBOutlet private var _label: UILabel!
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? TextElement else { fatalError() }
      let style = element.configuration
      _label.textAlignment = style.textStyle.alignment
      _label.font = style.textStyle.font
      _label.textColor = style.textStyle.color
      _label.text = element.content
   }
   
   override class func contentSize(for element: Elemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? TextElement else { fatalError() }
      let style = element.configuration
      let height = element.content.heightWithConstrainedWidth(width: width, font: style.textStyle.font)
      return CGSize(width: width, height: max(height, style.height ?? 0))
   }
}
