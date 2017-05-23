//
//  DropdownElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class DropdownElementCell: ElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _dropdownView: UIView!
   @IBOutlet private var _dropdownPlaceholderLabel: UILabel!
   @IBOutlet private var _dropdownViewHeightConstraint: NSLayoutConstraint!
   @IBOutlet private var _button: UIButton!
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? DropdownElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      _label.font = style.nameStyle.font
      _label.textColor = style.nameStyle.color
      _label.text = content.name
      _dropdownPlaceholderLabel.font = style.placeholderStyle?.font
      _dropdownPlaceholderLabel.textColor = style.placeholderStyle?.color
      _dropdownPlaceholderLabel.text = content.placeholder
      _dropdownViewHeightConstraint.constant = style.dropdownHeight
      _dropdownView.backgroundColor = style.dropdownBackgroundColor
      _button.tintColor = style.iconTintColor
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? DropdownElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let finalWidth = style.width ?? width
      guard style.height == nil else { return CGSize(width: finalWidth, height: style.height!) }
      let height = content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font)
      return CGSize(width: finalWidth, height: height + style.dropdownHeight + 10.0)
   }
}
