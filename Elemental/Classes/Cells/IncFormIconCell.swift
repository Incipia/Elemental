//
//  IncFormIconCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/1/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormIconCell: IncFormElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _imageView: UIImageView!
   
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormIcon else { fatalError() }
      let style = element.configuration
      _label.textAlignment = style.textStyle.alignment
      _label.font = style.textStyle.font
      _label.textColor = style.textStyle.color
      _label.text = element.content.name
      
      _imageView.image = element.content.icon
      _imageView.tintColor = style.iconTintColor
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormIcon else { fatalError() }
      let style = element.configuration
      let content = element.content
      let height = max(max(content.name.heightWithConstrainedWidth(width: width, font: style.textStyle.font), style.height ?? 0), content.icon.size.height)
      return CGSize(width: width, height: height)
   }
}
