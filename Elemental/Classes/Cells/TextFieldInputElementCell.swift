//
//  TextInputElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class TextFieldInputElementCell: BindableElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _detailLabelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet private var _nameLabelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _textField: InsetTextField!
   @IBOutlet private var _textFieldHeightConstraint: NSLayoutConstraint!
   
   @IBOutlet fileprivate var _horizontalConstraints: [NSLayoutConstraint]!
   @IBOutlet fileprivate var _verticalConstraints: [NSLayoutConstraint]!
   fileprivate var _readyToUpdateConstraints: Bool = false
   
   fileprivate var _action: InputElementAction?
   fileprivate var _isEnabled: Bool {
      get { return _textField.isEnabled }
      set {
         if !newValue, _textField.isFirstResponder {
            _textField.resignFirstResponder()
         }
         _textField.isEnabled = newValue
      }
   }

   static var bindableKeys: [BindableElementKey] { return [.text] }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      _textField.addTarget(self, action: #selector(_textChanged), for: .editingChanged)
      _textField.delegate = self
      
      
      // the constraints installed in the xib are activated sometime after awakeFromNib() and configure(with:) get called,
      // so activating uninstalled constraints before then causes conflicts
      DispatchQueue.main.async {
         self._readyToUpdateConstraints = true
         self.setNeedsUpdateConstraints()
      }
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? TextFieldInputElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let action = element.action
      _label.text = content.name
      _detailLabel.text = content.detail
      _label.font = style.nameStyle.font
      _textField.font = style.inputStyle.font
      _detailLabel.font = style.detailStyle?.font
      _label.textColor = style.nameStyle.color
      _textField.textColor = style.inputStyle.color
      _detailLabel.textColor = style.detailStyle?.color
      _textField.backgroundColor = style.inputBackgroundColor
      _textField.keyboardType = style.keyboardStyle.type
      _textField.keyboardAppearance = style.keyboardStyle.appearance
      _textField.isSecureTextEntry = style.keyboardStyle.isSecureTextEntry
      _textField.autocapitalizationType = style.keyboardStyle.autocapitalizationType
      _textField.returnKeyType = style.keyboardStyle.returnKeyType
      _textField.tintColor = style.inputTintColor ?? style.inputStyle.color
      
      if let placeholder = content.placeholder, let placeholderStyle = style.placeholderStyle {
         let attrs: [String : AnyHashable] = [
            NSFontAttributeName : placeholderStyle.font,
            NSForegroundColorAttributeName : placeholderStyle.color
         ]
         
         let attrPlaceholder = NSAttributedString(string: placeholder, attributes: attrs)
         _textField.attributedPlaceholder = attrPlaceholder
      } else {
         _textField.placeholder = nil
      }
      
      _detailLabelVerticalSpaceConstraint.constant = content.detail != nil ? 10.0 : 0.0
      _nameLabelVerticalSpaceConstraint.constant = content.name != "" ? 10.0 : 0.0
      _textFieldHeightConstraint.constant = style.inputHeight
      
      _textField.textAlignment = style.layoutDirection == .vertical ? .left : .right
      
      _action = action
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? TextFieldInputElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      
      var nameHeight: CGFloat
      switch style.layoutDirection {
      case .horizontal: nameHeight = 0
      case .vertical: nameHeight = content.name != "" ? content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font) : 0
      }
      
      if style.layoutDirection == .horizontal {
         nameHeight = 0
      }
      let namePadding: CGFloat = nameHeight != 0 ? 10.0 : 0.0
      
      var detailHeight: CGFloat = 0
      if let detail = content.detail, let detailFont = style.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      }
      let detailPadding: CGFloat = content.detail != nil ? 10.0 : 0.0
      let totalHeight = nameHeight + detailHeight + detailPadding + namePadding + style.inputHeight
      return CGSize(width: width, height: totalHeight)
   }
   
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .text: return _textField.text ?? ""
      case .isEnabled: return _isEnabled
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: BindableElementKey) throws {
      switch key {
      case .text:
         guard value == nil || value is String else { throw key.kvTypeError(value: value) }
         _textField.text = value as? String ?? ""
      case .doubleValue, .intValue: _textField.text = "\(value ?? "")"
      case .isEnabled:
         guard let validValue = value as? Bool else { throw key.kvTypeError(value: value) }
         _isEnabled = validValue
     default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   override func updateConstraints() {
      guard _readyToUpdateConstraints, let layoutDirection = element?.elementalConfig.layoutDirection else {
         super.updateConstraints()
         return
      }
      
      switch layoutDirection {
      case .horizontal:
         NSLayoutConstraint.deactivate(_verticalConstraints)
         NSLayoutConstraint.activate(_horizontalConstraints)
      case .vertical:
         NSLayoutConstraint.deactivate(_horizontalConstraints)
         NSLayoutConstraint.activate(_verticalConstraints)
      }
      
      super.updateConstraints()
   }
   
   override func prepareForReuse() {
      _action = nil
      super.prepareForReuse()
   }
}

extension TextFieldInputElementCell {
   @objc fileprivate func _textChanged() {
      trySetBoundValue(_textField.text, for: .text)
      
      if _textField.text == "" {
         trySetBoundValue(Double(0), for: .doubleValue)
         trySetBoundValue(0, for: .intValue)
      } else {
         trySetBoundValue(Double(_textField.text!), for: .doubleValue)
         trySetBoundValue(Int(_textField.text!), for: .intValue)
      }
   }
}

extension TextFieldInputElementCell: UITextFieldDelegate {
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      guard let action = _action else { return true }
      let nextState: InputElementState = action(.unfocused, .focused) ?? .focused
      textField.inputView = nextState == .unfocused ? UIView() : nil
      return true
   }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      guard textField.inputView == nil else {
         DispatchQueue.main.async {
            textField.resignFirstResponder()
         }
         return
      }
      guard let action = _action else { return }
      let nextState = action(.focused, nil)
      if nextState == .unfocused {
         DispatchQueue.main.async {
            textField.resignFirstResponder()
         }
      }
   }
   
   func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      guard textField.inputView == nil, let action = _action else { return true }
      let nextState: InputElementState = action(.focused, .unfocused) ?? .unfocused
      return nextState.shouldEndEditing
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      defer {
         if textField.inputView != nil {
            textField.inputView = nil
         }
      }
      guard let action = _action else { return }
      let proposedNextState: InputElementState? = textField.inputView == nil ? nil : .unfocused
      let nextState = action(.unfocused, proposedNextState)
      if nextState == .focused {
         DispatchQueue.main.async {
            textField.becomeFirstResponder()
         }
      }
   }
}

extension InputElementState {
   var shouldBeginEditing: Bool {
      switch self {
      case .focused: return true
      case .unfocused: return false
      }
   }
   
   var shouldEndEditing: Bool {
      switch self {
      case .focused: return false
      case .unfocused: return true
      }
   }
}
