//
//  TextViewElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class TextViewInputElementCell: BindableElementCell {
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _labelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet private var _detailLabelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _textView: PlaceholderTextView!
   @IBOutlet private var _textFieldHeightConstraint: NSLayoutConstraint!
   
   fileprivate var _action: InputElementAction?
   fileprivate var _isEnabled: Bool {
      get { return _textView.isEditable }
      set {
         if !newValue, _textView.isFirstResponder {
            _textView.resignFirstResponder()
         }
         _textView.isEditable = newValue
         _textView.isSelectable = newValue
      }
   }

   static var bindableKeys: [BindableElementKey] { return [.text, .isEnabled] }

   override func awakeFromNib() {
      super.awakeFromNib()
      _textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
      _textView.delegate = self
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? TextViewInputElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let action = element.action
      _label.text = content.name
      _detailLabel.text = content.detail
      _label.font = style.nameStyle.font
      _textView.font = style.inputStyle.font
      _detailLabel.font = style.detailStyle?.font
      _label.textColor = style.nameStyle.color
      _textView.textColor = style.inputStyle.color
      _detailLabel.textColor = style.detailStyle?.color
      _textView.backgroundColor = style.inputBackgroundColor
      _textView.textContainerInset = style.textInsets
      
      _textView.keyboardType = style.keyboardStyle.type
      _textView.keyboardAppearance = style.keyboardStyle.appearance
      _textView.isSecureTextEntry = style.keyboardStyle.isSecureTextEntry
      _textView.autocapitalizationType = style.keyboardStyle.autocapitalizationType
      _textView.returnKeyType = style.keyboardStyle.returnKeyType
      _textView.tintColor = style.inputTintColor ?? style.inputStyle.color
      
      _textView.placeholder = content.placeholder ?? ""
      _textView.placeholderFont = style.placeholderStyle?.font
      _textView.placeholderColor = style.placeholderStyle?.color ?? .black
      
      _labelVerticalSpaceConstraint.constant = content.name != "" ? 10.0 : 0.0
      _detailLabelVerticalSpaceConstraint.constant = content.detail != nil ? 10.0 : 0.0
      _textFieldHeightConstraint.constant = style.inputHeight
      
      _action = action
      _isEnabled = style.isEnabled
   }
   
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .text: return _textView.text
      case .isEnabled: return _isEnabled
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: inout Any?, for key: BindableElementKey) throws {
      switch key {
      case .text:
         guard value == nil || value is String else { throw key.kvTypeError(value: value) }
         _textView.text = value as? String ?? ""
      case .isEnabled:
         guard let validValue = value as? Bool else { throw key.kvTypeError(value: value) }
         _isEnabled = validValue
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? TextViewInputElement else { fatalError() }
      let content = element.content
      let config = element.configuration
      let nameHeight = content.name == "" ? 0.0 : content.name.heightWithConstrainedWidth(width: width, font: config.nameStyle.font)
      let namePadding: CGFloat = nameHeight == 0.0 ? 0.0 : 10.0
      var detailHeight: CGFloat = 0
      if let detail = content.detail, let detailFont = config.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      }
      let detailPadding: CGFloat = content.detail != nil ? 10.0 : 0.0
      let totalHeight = nameHeight + namePadding + detailHeight + detailPadding + config.inputHeight
      return CGSize(width: width, height: totalHeight)
   }
}

extension TextViewInputElementCell: UITextViewDelegate {
   func textViewDidChange(_ textView: UITextView) {
      trySetBoundValue(_textView.text, for: .text)
   }
   
   func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
      guard let action = _action else { return true }
      let nextState: InputElementState = action(.unfocused, .focused) ?? .focused
      textView.inputView = nextState == .unfocused ? UIView() : nil
      return true
   }
   
   func textViewDidBeginEditing(_ textView: UITextView) {
      guard textView.inputView == nil else {
         DispatchQueue.main.async {
            textView.resignFirstResponder()
         }
         return
      }
      guard let action = _action else { return }
      let nextState = action(.focused, nil)
      if nextState == .unfocused {
         DispatchQueue.main.async {
            textView.resignFirstResponder()
         }
      }
   }
   
   func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
      guard textView.inputView == nil, let action = _action else { return true }
      let nextState: InputElementState = action(.focused, .unfocused) ?? .unfocused
      return nextState.shouldEndEditing
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      defer {
         if textView.inputView != nil {
            textView.inputView = nil
         }
      }
      guard let action = _action else { return }
      let proposedNextState: InputElementState? = textView.inputView == nil ? nil : .unfocused
      let nextState = action(.unfocused, proposedNextState)
      if nextState == .focused {
         DispatchQueue.main.async {
            textView.becomeFirstResponder()
         }
      }
   }
}
