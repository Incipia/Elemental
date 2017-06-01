//
//  IconElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/1/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IconElementCell: ElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _imageView: UIImageView!
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? IconElement else { fatalError() }
      let style = element.configuration
      _label.textAlignment = style.textStyle.alignment
      _label.font = style.textStyle.font
      _label.textColor = style.textStyle.color
      _label.text = element.content.name
      
      _imageView.image = element.content.icon
      _imageView.tintColor = style.iconTintColor
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? IconElement else { fatalError() }
      let style = element.configuration
      let content = element.content
      let height = max(content.name.heightWithConstrainedWidth(width: width, font: style.textStyle.font), content.icon.size.height)
      return CGSize(width: width, height: height)
   }
}
