//
//  SwitchElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/1/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class SwitchElementCell: BindableElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet fileprivate var _switch: UISwitch!
   @IBOutlet private var _detailConstraint: NSLayoutConstraint!
   
   static var bindableKeys: [BindableElementKey] { return [.switch] }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      _switch.addTarget(self, action: #selector(_switchChanged), for: .valueChanged)
   }

   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? SwitchElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      _label.text = content.name
      _detailLabel.text = content.detail
      _label.font = style.nameStyle.font
      _detailLabel.font = style.detailStyle?.font
      _label.textColor = style.nameStyle.color
      _detailLabel.textColor = style.detailStyle?.color
      
      _switch.isOn = content.on
      _switch.tintColor = style.offTintColor
      _switch.onTintColor = style.onTintColor
      
      setNeedsUpdateConstraints()
   }
   
   override func updateConstraints() {
      _detailConstraint.constant = (_detailLabel.text?.isEmpty ?? true) ? 0 : 2.0

      super.updateConstraints()
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? SwitchElement else { fatalError() }
      let content = element.content
      let config = element.configuration
      let nameHeight = content.name.heightWithConstrainedWidth(width: width, font: config.nameStyle.font)
      
      guard let detail = content.detail, let detailFont = config.detailStyle?.font else {
         return CGSize(width: width, height: nameHeight)
      }
      
      let detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      let detailPadding: CGFloat = 2.0
      let totalHeight = nameHeight + detailHeight + detailPadding
      return CGSize(width: width, height: totalHeight)
   }
   
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .switch: return _switch.isOn
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: inout Any?, for key: BindableElementKey) throws {
      switch key {
      case .switch:
         guard let validValue = value as? Bool else { throw key.kvTypeError(value: value) }
         _switch.isOn = validValue
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
}

extension SwitchElementCell {
   @objc fileprivate func _switchChanged() {
      trySetBoundValue(_switch.isOn, for: .switch)
   }
}
