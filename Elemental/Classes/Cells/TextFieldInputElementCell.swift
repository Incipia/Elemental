//
//  TextInputElementCell.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class TextFieldInputElementCell: BindableElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _detailLabelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _textField: InsetTextField!
   @IBOutlet private var _textFieldHeightConstraint: NSLayoutConstraint!
   
   fileprivate var _action: IncFormElementInputAction?
   fileprivate var _isEnabled: Bool {
      get { return _textField.isEnabled }
      set {
         if !newValue, _textField.isFirstResponder {
            _textField.resignFirstResponder()
         }
         _textField.isEnabled = newValue
      }
   }

   static var bindableKeys: [IncFormBindableElementKey] { return [.text] }
   
   override func awakeFromNib() {
      super.awakeFromNib()
      _textField.addTarget(self, action: #selector(_textChanged), for: .editingChanged)
      _textField.delegate = self
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
      
      _textField.tintColor = style.inputStyle.color
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
      _textFieldHeightConstraint.constant = style.inputHeight
      
      _action = action
   }
   
   override class func contentSize(for element: Elemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? TextFieldInputElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let finalWidth = style.width ?? width
      guard style.height == nil else { return CGSize(width: finalWidth, height: style.height!) }
      let nameHeight = content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font)
      var detailHeight: CGFloat = 0
      if let detail = content.detail, let detailFont = style.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      }
      let detailPadding: CGFloat = content.detail != nil ? 10.0 : 0.0
      let totalHeight = nameHeight + detailHeight + detailPadding + 10.0 + style.inputHeight
      return CGSize(width: finalWidth, height: totalHeight)
   }
   
   override func value(for key: IncFormBindableElementKey) -> Any? {
      switch key {
      case .text: return _textField.text ?? ""
      case .isEnabled: return _isEnabled
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: IncFormBindableElementKey) throws {
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
      let nextState: IncFormElementInputState = action(.unfocused, .focused) ?? .focused
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
      let nextState: IncFormElementInputState = action(.focused, .unfocused) ?? .unfocused
      return nextState.shouldEndEditing
   }
   
   func textFieldDidEndEditing(_ textField: UITextField) {
      defer {
         if textField.inputView != nil {
            textField.inputView = nil
         }
      }
      guard let action = _action else { return }
      let proposedNextState: IncFormElementInputState? = textField.inputView == nil ? nil : .unfocused
      let nextState = action(.unfocused, proposedNextState)
      if nextState == .focused {
         DispatchQueue.main.async {
            textField.becomeFirstResponder()
         }
      }
   }
}

extension IncFormElementInputState {
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
