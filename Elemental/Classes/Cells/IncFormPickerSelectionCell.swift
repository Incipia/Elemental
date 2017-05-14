//
//  IncFormPickerSelectionCell.swift
//  GigSalad
//
//  Created by Gregory Klein on 4/26/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormPickerSelectionCell: IncFormBindableElementCell {
   // MARK: - Label Outlets
   @IBOutlet fileprivate var _nameLabel: UILabel!
   @IBOutlet fileprivate var _detailLabel: UILabel!
   @IBOutlet fileprivate var _buttonLabel: UILabel!
   
   // MARK: - View Outlets
   @IBOutlet fileprivate var _buttonBackgroundView: UIView!
   @IBOutlet fileprivate var _leftAccessoryImageView: UIImageView!
   @IBOutlet fileprivate var _rightAccessoryImageView: UIImageView!
   @IBOutlet fileprivate var _pickerView: UIPickerView!
   @IBOutlet fileprivate var _pickerBackgroundView: UIView!
   
   // MARK: - Constraint Outlets
   @IBOutlet fileprivate var _leftAccessoryImageViewWidthConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _rightAccessoryImageViewWidthConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _leftImageViewHorizontalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _rightImageViewHorizontalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _nameVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _detailVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _buttonHeightConstraint: NSLayoutConstraint!
   
   // MARK: - Private Properties
   fileprivate var _options: [(option: IncFormPickerSelection.Option, dataValue: Data)] = []
   fileprivate var _optionStyle: IncFormTextStyle = IncFormTextStyle()
   fileprivate var _selectedOption: IncFormPickerSelection.Option? {
      let selectedOptions = _options.filter { $0.option.isSelected }
      guard selectedOptions.count <= 1 else { fatalError() }
      return selectedOptions.first?.option
   }
   fileprivate var _selectedValue: Any? {
      get { return _selectedOption?.value }
      set {
         guard !_options.isEmpty else { return }
         guard let element = element as? IncFormPickerSelection else { fatalError() }
         var selectIndex: Int? = nil
         if let someValue = newValue {
            let dataValue = ElementCell.dataValue(someValue)
            for (index, option) in _options.enumerated() {
               if option.dataValue == dataValue {
                  _options[index].option.isSelected = true
                  selectIndex = index
               } else {
                  _options[index].option.isSelected = false
               }
            }
         } else {
            for (index, _) in _options.enumerated() {
               _options[index].option.isSelected = false
            }
         }
         _updateButton(with: element)
         _updateOptionStyle(with: element.configuration.optionStyle)
         if _pickerView.selectedRow(inComponent: 0) != selectIndex {
            _pickerView.selectRow(selectIndex ?? 0, inComponent: 0, animated: true)
         }
         trySetBoundValue(newValue, for: .anyValue)
      }
   }
   
   // MARK: - Overridden
   override func awakeFromNib() {
      super.awakeFromNib()
      
      let button = UIButton()
      button.translatesAutoresizingMaskIntoConstraints = false
      _buttonBackgroundView.addSubview(button)
      button.topAnchor.constraint(equalTo: _buttonBackgroundView.topAnchor).isActive = true
      button.bottomAnchor.constraint(equalTo: _buttonBackgroundView.bottomAnchor).isActive = true
      button.leftAnchor.constraint(equalTo: _buttonBackgroundView.leftAnchor).isActive = true
      button.rightAnchor.constraint(equalTo: _buttonBackgroundView.rightAnchor).isActive = true
      
      let fadeSelector = #selector(IncFormPickerSelectionCell._fadePickerButton)
      button.addTarget(self, action: fadeSelector, for: .touchDown)
      button.addTarget(self, action: fadeSelector, for: .touchDragEnter)
      let unfadeSelector = #selector(IncFormPickerSelectionCell._unfadePickerButton)
      button.addTarget(self, action: unfadeSelector, for: .touchDragExit)
      button.addTarget(self, action: unfadeSelector, for: .touchCancel)
      let touchUpSelector = #selector(IncFormPickerSelectionCell._pickerButtonTouchUpInside)
      button.addTarget(self, action: touchUpSelector, for: .touchUpInside)
      
      _pickerBackgroundView.layer.cornerRadius = 6.0
   }
   
   override func configure(with component: IncFormElemental) {
      guard let element = component as? IncFormPickerSelection else { fatalError() }
      super.configure(with: component)
      let content = element.content
      let config = element.configuration
      if let layoutDelegate = config.layoutDelegate {
         self.layoutDelegate = layoutDelegate
      }
      
      _nameLabel.text = content.name
      _detailLabel.text = content.detail
      _nameLabel.font = config.nameStyle.font
      _buttonBackgroundView.backgroundColor = config.buttonBackgroundColor
      _detailLabel.font = config.detailStyle?.font
      _nameLabel.textColor = config.nameStyle.color
      _detailLabel.textColor = config.detailStyle?.color
      _nameVerticalSpaceConstraint.constant = content.name != nil ? 10 : 0
      _detailVerticalSpaceConstraint.constant = content.detail != nil ? 10 : 0
      _buttonHeightConstraint.constant = config.buttonHeight
      
      _options = element.content.options.map { return (option: $0, dataValue: ElementCell.dataValue($0.value)) }
      guard Set(_options.map { return $0.dataValue }).count == _options.count else { fatalError() }

      _pickerBackgroundView.backgroundColor = config.buttonBackgroundColor
      _pickerView.reloadAllComponents()

      _selectedValue = _selectedOption?.value
      
      _updateIndicatorColor()
      _updateAccessoryImages(with: element)
      
      let angle: CGFloat = element.inputState == .focused ? .pi : 0.0
      _rightAccessoryImageView.transform = CGAffineTransform(rotationAngle: angle)
   }
   
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormPickerSelection else { fatalError() }
      let content = element.content
      let config = element.configuration
      let finalWidth = config.width ?? width
      
      guard config.height == nil else {
         return CGSize(width: finalWidth, height: config.height!)
      }
      
      let nameHeight = content.name?.heightWithConstrainedWidth(width: width, font: config.nameStyle.font) ?? 0
      let namePadding: CGFloat = content.name != nil ? 10 : 0
      let pickerHeight: CGFloat = element.inputState == .focused ? 216 : 0
      
      guard let detail = content.detail, let detailFont = config.detailStyle?.font else {
         return CGSize(width: finalWidth, height: nameHeight + namePadding + config.buttonHeight + pickerHeight)
      }
      
      let detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      let detailPadding: CGFloat = 10.0
      let totalHeight = nameHeight + namePadding + detailHeight + detailPadding + config.buttonHeight + pickerHeight
      return CGSize(width: finalWidth, height: totalHeight)
   }
   
   override func didMoveToWindow() {
      _updateIndicatorColor()
   }
   
   // MARK: - Private
   private func _updateAccessoryImages(with element: IncFormPickerSelection) {
      _leftAccessoryImageView.image = element.content.leftAccessoryImage
      _leftAccessoryImageView.tintColor = element.configuration.leftAccessoryImageTintColor
      _leftAccessoryImageViewWidthConstraint.constant = _leftAccessoryImageView.image != nil ? 20 : 0
      _leftImageViewHorizontalSpaceConstraint.constant = _leftAccessoryImageView.image != nil ? 10 : 0
      _rightAccessoryImageView.image = element.content.rightAccessoryImage
      _rightAccessoryImageView.tintColor = element.configuration.rightAccessoryImageTintColor
      _rightAccessoryImageViewWidthConstraint.constant = _rightAccessoryImageView.image != nil ? 20 : 0
      _rightImageViewHorizontalSpaceConstraint.constant = _rightAccessoryImageView.image != nil ? 10 : 0
   }
   
   fileprivate func _updateButton(with element: IncFormPickerSelection) {
      let selectedOption = _selectedOption
      let style = element.configuration.textStyle(for: selectedOption)
      _buttonLabel.font = style.font
      _buttonLabel.textColor = style.color
      _buttonLabel.text = selectedOption?.text ?? element.content.placeholder
   }
   
   private func _updateOptionStyle(with style: IncFormTextStyling) {
      _optionStyle = IncFormTextStyle(style: style)
   }
   
   private func _updateIndicatorColor() {
      _pickerView.subviews.forEach {
         guard $0.bounds.height <= 1.0 else { return }
         $0.backgroundColor = self._optionStyle.color.withAlphaComponent(0.5)
      }
   }
   
   @objc private func _pickerButtonTouchUpInside() {
      guard let element = element as? IncFormPickerSelection else { fatalError() }
      _unfadePickerButton()
      let nextState = element.action?(element.inputState, element.inputState.other) ?? element.inputState.other
      guard nextState != element.inputState else { return }
      element.inputState = nextState
      layoutDelegate?.reloadLayout(for: element, animated: true, scrollToCenter: true)
      UIView.animate(withDuration: 0.25) {
         let angle: CGFloat = nextState == .focused ? .pi : 0.0
         self._rightAccessoryImageView.transform = CGAffineTransform(rotationAngle: angle)
      }
      guard nextState == .focused, !_options.isEmpty, _selectedOption == nil else { return }
      _selectedValue = _options.first?.option.value
   }
   
   @objc private func _fadePickerButton() {
      UIView.animate(withDuration: 0.15) {
         self._buttonBackgroundView.alpha = 0.5
      }
   }
   
   @objc private func _unfadePickerButton() {
      UIView.animate(withDuration: 0.15) {
         self._buttonBackgroundView.alpha = 1.0
      }
   }
   
   // MARK: - Bindable Protocol
   override func value(for key: IncFormBindableElementKey) -> Any? {
      switch key {
      case .anyValue: return _selectedValue
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: IncFormBindableElementKey) throws {
      switch key {
      case .anyValue: _selectedValue = value
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
}

extension IncFormPickerSelectionCell: UIPickerViewDelegate {
   func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      let label = view as? UILabel ?? UILabel()
      label.font = _optionStyle.font
      label.textColor = _optionStyle.color
      label.textAlignment = _optionStyle.alignment
      label.text = _options[row].option.text
      return label
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      _selectedValue = _options[row].option.value
   }
}

extension IncFormPickerSelectionCell: UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return _options.isEmpty ? 0 : 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return _options.count
   }
}

extension IncFormPickerConfiguring {
   func textStyle(for selectedOption: IncFormPickerSelection.Option?) -> IncFormTextStyling {
      return selectedOption == nil && placeholderStyle != nil ? placeholderStyle! : buttonStyle
   }
}
