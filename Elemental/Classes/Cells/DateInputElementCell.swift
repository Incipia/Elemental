//
//  DateInputElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

fileprivate let kPickerBackgroundHeight: CGFloat = 172.0

class DateInputElementCell: BindableElementCell {
   // MARK: - Private Properties
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _detailLabelVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet private var _dateInputView: UIView!
   @IBOutlet private var _dateInputHeightConstraint: NSLayoutConstraint!
   @IBOutlet private var _placeholderLabel: UILabel!
   @IBOutlet private var _leftAccessoryImageView: UIImageView!
   @IBOutlet private var _leftAccessoryPaddingConstraint: NSLayoutConstraint!
   @IBOutlet private var _leftAccessoryImageViewWidthConstraint: NSLayoutConstraint!
   @IBOutlet private var _pickerBackgroundTopVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet private var _datePicker: UIDatePicker!
   @IBOutlet private var _pickerBackgroundView: UIView!
   
   fileprivate var _pickerColor: UIColor = .black
   fileprivate var _selectedInterval: Double?
   
   // MARK: - Overridden
   override func awakeFromNib() {
      super.awakeFromNib()
      
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      _dateInputView.addSubview(button)
      button.topAnchor.constraint(equalTo: _dateInputView.topAnchor).isActive = true
      button.bottomAnchor.constraint(equalTo: _dateInputView.bottomAnchor).isActive = true
      button.leftAnchor.constraint(equalTo: _dateInputView.leftAnchor).isActive = true
      button.rightAnchor.constraint(equalTo: _dateInputView.rightAnchor).isActive = true
      
      let fadeSelector = #selector(DateInputElementCell._fadePickerInput)
      button.addTarget(self, action: fadeSelector, for: .touchDown)
      button.addTarget(self, action: fadeSelector, for: .touchDragEnter)
      let unfadeSelector = #selector(DateInputElementCell._unfadePickerInput)
      button.addTarget(self, action: unfadeSelector, for: .touchDragExit)
      button.addTarget(self, action: unfadeSelector, for: .touchCancel)
      let touchUpSelector = #selector(DateInputElementCell._pickerInputTouchUpInside)
      button.addTarget(self, action: touchUpSelector, for: .touchUpInside)
      
      _pickerBackgroundView.layer.cornerRadius = 6.0

      let changeSelector = #selector(DateInputElementCell._pickerValueChanged)
      _datePicker.addTarget(self, action: changeSelector, for: .valueChanged)
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? DateInputElement else { fatalError() }
      let content = element.content
      let config = element.configuration
      if let layoutDelegate = config.layoutDelegate {
         self.layoutDelegate = layoutDelegate
      }
      _label.text = content.name
      _detailLabel.text = content.detail
      _placeholderLabel.text = content.placeholder
      _label.font = config.nameStyle.font
      _dateInputView.backgroundColor = config.inputBackgroundColor
      _placeholderLabel.font = config.placeholderStyle?.font
      _detailLabel.font = config.detailStyle?.font
      _label.textColor = config.nameStyle.color
      _detailLabel.textColor = config.detailStyle?.color
      _placeholderLabel.textColor = config.placeholderStyle?.color
      _placeholderLabel.textAlignment = config.placeholderStyle?.alignment ?? .left
      
      _leftAccessoryImageView.image = content.leftAccessoryImage
      _leftAccessoryImageView.tintColor = config.nameStyle.color
      _leftAccessoryPaddingConstraint.constant = content.leftAccessoryImage != nil ? 10.0 : 0.0
      _leftAccessoryImageViewWidthConstraint.constant = content.leftAccessoryImage != nil ? 20.0 : 0.0
      
      _pickerBackgroundTopVerticalSpaceConstraint.constant = config.datePickerTopMargin
      _pickerColor = config.inputStyle.color
      _pickerBackgroundView.backgroundColor = config.datePickerBackgroundColor ?? config.inputBackgroundColor
      
      _detailLabelVerticalSpaceConstraint.constant = content.detail != nil ? 10.0 : 0.0
      _dateInputHeightConstraint.constant = config.inputHeight
      
      _datePicker.datePickerMode = config.datePickerMode
      _datePicker.locale = config.datePickerLocale
      _datePicker.minimumDate = content.minimumDate
      _datePicker.maximumDate = content.maximumDate
      _datePicker.minuteInterval = config.datePickerMinuteInterval
      _datePicker.setDate(content.date ?? Date(), animated: true)
      _datePicker.setValue(_pickerColor, forKey: "textColor")
      _updateIndicatorColor()
      
      _datePicker.isUserInteractionEnabled = element.inputState == .focused
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? DateInputElement else { fatalError() }
      let content = element.content
      let config = element.configuration
      
      let nameHeight = config.layoutDirection == .horizontal ? 0 : content.name.heightWithConstrainedWidth(width: width, font: config.nameStyle.font)
      let namePadding: CGFloat = nameHeight != 0 ? 10 : 0
      
      let focusedHeight = element.configuration.datePickerTopMargin + kPickerBackgroundHeight + element.configuration.datePickerBottomMargin
      let pickerHeight: CGFloat = element.inputState == .focused ? focusedHeight : 0
      
      guard let detail = content.detail, let detailFont = config.detailStyle?.font else {
         return CGSize(width: width, height: nameHeight + namePadding + config.inputHeight + pickerHeight)
      }
      
      let detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      let detailPadding: CGFloat = 10.0
      let totalHeight = nameHeight + namePadding + detailHeight + detailPadding + config.inputHeight + pickerHeight
      return CGSize(width: width, height: totalHeight)
   }
   
   override func didMoveToWindow() {
      _updateIndicatorColor()
   }
   
   // MARK: - Actions
   @objc private func _pickerInputTouchUpInside() {
      guard let element = element as? DateInputElement else { fatalError() }
      _unfadePickerInput()
      let nextState = element.action?(element.inputState, element.inputState.other) ?? element.inputState.other
      guard nextState != element.inputState else { return }
      element.inputState = nextState
      layoutDelegate?.reloadLayout(for: element, animated: true, scrollPosition: .center)
      guard nextState == .focused, _selectedInterval == nil else { return }
      let interval = _datePicker.datePickerMode == .countDownTimer ? _datePicker.countDownDuration : _datePicker.date.timeIntervalSince1970
      _updateSelectedInterval(interval, updatePicker: false)
   }
   
   @objc private func _pickerValueChanged() {
      let interval = _datePicker.datePickerMode == .countDownTimer ? _datePicker.countDownDuration : _datePicker.date.timeIntervalSince1970
      _updateSelectedInterval(interval, updatePicker: false)
   }
   
   // MARK: - Private
   private func _updateSelectedInterval(_ interval: Double?, updatePicker: Bool = true) {
      guard let element = element as? DateInputElement else { return }
      guard interval != nil || element.inputState == .unfocused else { fatalError() }
      _selectedInterval = interval
      let dateValue: Date? = interval == nil ? nil :
      _datePicker.datePickerMode == .countDownTimer ? Date(timeIntervalSinceNow: interval!) :
      Date(timeIntervalSince1970: interval!)
      defer {
         _updateInput(with: element)
         trySetBoundValue(dateValue, for: .anyValue)
         trySetBoundValue(interval, for: .doubleValue)
         if let dateValue = dateValue {
            trySetBoundValue(element.configuration.dateFormatter.string(from: dateValue), for: .text)
         } else {
            trySetBoundValue(nil, for: .text)
         }
      }
      guard updatePicker else { return }
      if _datePicker.datePickerMode == .countDownTimer {
         _datePicker.countDownDuration = interval ?? 0.0
      } else {
         _datePicker.setDate(dateValue ?? Date(), animated: true)
      }
   }
   
   private func _updateInput(with element: DateInputElement) {
      let style = element.configuration._textStyle(for: _selectedInterval)
      _placeholderLabel.font = style.font
      _placeholderLabel.textColor = style.color
      _placeholderLabel.text = _selectedInterval == nil ? element.content.placeholder :
         _datePicker.datePickerMode == .countDownTimer ? element.configuration.dateFormatter.string(from: Date(timeIntervalSinceNow: _datePicker.countDownDuration)) :
         element.configuration.dateFormatter.string(from: _datePicker.date)
   }
   
   @objc private func _fadePickerInput() {
      _datePicker.isUserInteractionEnabled = false
      UIView.animate(withDuration: 0.15) {
         self._dateInputView.alpha = 0.5
      }
   }
   
   @objc private func _unfadePickerInput() {
      _datePicker.isUserInteractionEnabled = true
      UIView.animate(withDuration: 0.15) {
         self._dateInputView.alpha = 1.0
      }
   }
   
   private func _updateIndicatorColor() {
      guard let datePickerView = _datePicker.subviews.first else { return }
      datePickerView.subviews.forEach {
         guard $0.bounds.height <= 1.0 else { return }
         $0.backgroundColor = self._pickerColor
      }
   }
   
   // MARK: - Bindable Protocol
   override class var bindableKeys: [BindableElementKey] {
      return [
         .anyValue,
         .doubleValue,
         .text,
      ]
   }
   
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .anyValue: return _datePicker.date
      case .doubleValue: return Double(_datePicker.date.timeIntervalSince1970)
      case .text:
         guard let config = element?.elementalConfig as? DateInputElementConfiguring else { return nil }
         return config.dateFormatter.string(from: _datePicker.date)
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: inout Any?, for key: BindableElementKey) throws {
      switch key {
      case .anyValue:
         if let dateValue = value as? Date {
            _updateSelectedInterval(dateValue.timeIntervalSince1970)
            break
         }
         fallthrough
      case .doubleValue: _updateSelectedInterval(value as? Double)
      case .text:
         guard let config = element?.elementalConfig as? DateInputElementConfiguring,
            let dateValue = value as? String,
            let date = config.dateFormatter.date(from: dateValue) else { return }
         _updateSelectedInterval(date.timeIntervalSince1970)
         
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
}

extension DateInputElementConfiguring {
   fileprivate func _textStyle(for interval: Double?) -> ElementalTextStyling {
      return interval == nil && placeholderStyle != nil ? placeholderStyle! : inputStyle
   }
}

