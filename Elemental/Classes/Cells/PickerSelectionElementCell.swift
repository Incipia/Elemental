//
//  PickerElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 4/26/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

fileprivate let kPickerHeight: CGFloat = 216.0
fileprivate let kPickerBackgroundHeight: CGFloat = 172.0

class PickerElementCell: BindableElementCell {
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
   @IBOutlet fileprivate var _rightImageViewHorizontalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _nameVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _detailVerticalSpaceConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _buttonHeightConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate var _pickerBackgroundTopVerticalSpaceConstraint: NSLayoutConstraint!
   
   @IBOutlet fileprivate var _leftImageViewHorizontalSpaceConstraints: [NSLayoutConstraint]!
   
   @IBOutlet fileprivate var _horizontalConstraints: [NSLayoutConstraint]!
   @IBOutlet fileprivate var _verticalConstraints: [NSLayoutConstraint]!
   
   // MARK: - Private Properties
   fileprivate var _options: [(option: PickerElement.Option, dataValue: Data)] = []
   fileprivate var _optionStyle: ElementalTextStyle = ElementalTextStyle()
   fileprivate var _selectedOption: PickerElement.Option? {
      let selectedOptions = _options.filter { $0.option.isSelected }
      guard selectedOptions.count <= 1 else { fatalError() }
      return selectedOptions.first?.option
   }
   fileprivate var _selectedValue: Any? {
      get { return _selectedOption?.value }
      set {
         guard !_options.isEmpty else { return }
         guard let element = element as? PickerElement else { fatalError() }
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
   
   fileprivate var _readyToUpdateConstraints: Bool = false
   
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
      
      let fadeSelector = #selector(PickerElementCell._fadePickerButton)
      button.addTarget(self, action: fadeSelector, for: .touchDown)
      button.addTarget(self, action: fadeSelector, for: .touchDragEnter)
      let unfadeSelector = #selector(PickerElementCell._unfadePickerButton)
      button.addTarget(self, action: unfadeSelector, for: .touchDragExit)
      button.addTarget(self, action: unfadeSelector, for: .touchCancel)
      let touchUpSelector = #selector(PickerElementCell._pickerButtonTouchUpInside)
      button.addTarget(self, action: touchUpSelector, for: .touchUpInside)
      
      _pickerBackgroundView.layer.cornerRadius = 6.0
      
      // the constraints installed in the xib are activated sometime after awakeFromNib() and configure(with:) get called,
      // so activating uninstalled constraints before then causes conflicts
      DispatchQueue.main.async {
         self._readyToUpdateConstraints = true
         self.setNeedsUpdateConstraints()
      }
   }
   
   override func configure(with component: Elemental) {
      guard let element = component as? PickerElement else { fatalError() }
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
      _buttonLabel.textAlignment = config.layoutDirection == .vertical ? .left : .right
      _nameVerticalSpaceConstraint.constant = content.name != nil ? 10 : 0
      _detailVerticalSpaceConstraint.constant = content.detail != nil ? 10 : 0
      _buttonHeightConstraint.constant = config.buttonHeight
      
      _options = element.content.options.map { return (option: $0, dataValue: ElementCell.dataValue($0.value)) }
      guard Set(_options.map { return $0.dataValue }).count == _options.count else { fatalError() }

      _pickerBackgroundTopVerticalSpaceConstraint.constant = element.configuration.pickerTopMargin
      _pickerBackgroundView.backgroundColor = config.pickerBackgroundColor ?? config.buttonBackgroundColor
      _pickerView.reloadAllComponents()

      _selectedValue = _selectedOption?.value
      
      _updateIndicatorColor()
      _updateAccessoryImages(with: element)
      
      let angle: CGFloat = element.inputState == .focused ? .pi : 0.0
      _rightAccessoryImageView.transform = CGAffineTransform(rotationAngle: angle)
      
      setNeedsUpdateConstraints()
   }
   
   override class func contentSize(for element: Elemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? PickerElement else { fatalError() }
      let content = element.content
      let config = element.configuration
      let finalWidth = config.width ?? width
      
      guard config.height == nil else {
         return CGSize(width: finalWidth, height: config.height!)
      }
      
      let nameHeight = config.layoutDirection == .horizontal ? 0 : content.name?.heightWithConstrainedWidth(width: width, font: config.nameStyle.font) ?? 0
      let namePadding: CGFloat = nameHeight != 0 ? 10 : 0
      
      let focusedHeight = element.configuration.pickerTopMargin + kPickerBackgroundHeight + element.configuration.pickerBottomMargin
      let pickerHeight: CGFloat = element.inputState == .focused ? focusedHeight : 0
      
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
   
   override func updateConstraints() {
      guard _readyToUpdateConstraints, let layoutDirection = element?.elementalConfig.layoutDirection else { super.updateConstraints(); return }
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
   
   // MARK: - Private
   private func _updateAccessoryImages(with element: PickerElement) {
      _leftAccessoryImageView.image = element.content.leftAccessoryImage
      _leftAccessoryImageView.tintColor = element.configuration.leftAccessoryImageTintColor
      _leftAccessoryImageViewWidthConstraint.constant = _leftAccessoryImageView.image != nil ? 20 : 0
      _leftImageViewHorizontalSpaceConstraints.forEach { $0.constant = _leftAccessoryImageView.image != nil ? 10 : 0 }
      _rightAccessoryImageView.image = element.content.rightAccessoryImage
      _rightAccessoryImageView.tintColor = element.configuration.rightAccessoryImageTintColor
      _rightAccessoryImageViewWidthConstraint.constant = _rightAccessoryImageView.image != nil ? 20 : 0
      _rightImageViewHorizontalSpaceConstraint.constant = _rightAccessoryImageView.image != nil ? 10 : 0
   }
   
   fileprivate func _updateButton(with element: PickerElement) {
      let selectedOption = _selectedOption
      let style = element.configuration.textStyle(for: selectedOption)
      _buttonLabel.font = style.font
      _buttonLabel.textColor = style.color
      _buttonLabel.text = selectedOption?.text ?? element.content.placeholder
   }
   
   private func _updateOptionStyle(with style: ElementalTextStyling) {
      _optionStyle = ElementalTextStyle(style: style)
   }
   
   private func _updateIndicatorColor() {
      _pickerView.subviews.forEach {
         guard $0.bounds.height <= 1.0 else { return }
         $0.backgroundColor = self._optionStyle.color.withAlphaComponent(0.5)
      }
   }
   
   @objc private func _pickerButtonTouchUpInside() {
      guard let element = element as? PickerElement else { fatalError() }
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
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .anyValue: return _selectedValue
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: BindableElementKey) throws {
      switch key {
      case .anyValue: _selectedValue = value
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
}

extension PickerElementCell: UIPickerViewDelegate {
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

extension PickerElementCell: UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return _options.isEmpty ? 0 : 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return _options.count
   }
}

extension PickerElementConfiguring {
   func textStyle(for selectedOption: PickerElement.Option?) -> ElementalTextStyling {
      return selectedOption == nil && placeholderStyle != nil ? placeholderStyle! : buttonStyle
   }
}
