//
//  IncFormAccessoryCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/8/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormAccessoryCell: IncFormBindableElementCell {
   // MARK: - Outlets
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _button: UIButton!
   @IBOutlet private var _imageView: UIImageView!
   @IBOutlet private var _detailToButtonHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _buttonToImageHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _detailToSuperviewHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _buttonToSuperviewHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _buttonWidthConstraint: NSLayoutConstraint!

   // MARK - Public Properties
   static var bindableKeys: [IncFormBindableElementKey] { return [.detail] }

   // MARK: - Private Properties
   private var _action: IncFormElementAccessoryAction?
   private var _accessory: FormComponentAccessory?
   
   // MARK: - Actions
   @IBAction private func _accessoryButtonPressed() {
      _action?()
   }
   
   // MARK: - Life Cycle
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormAccessory else { fatalError() }
      let content = element.content
      let style = element.configuration
      let action = element.action
      _label.text = content.name
      _detailLabel.text = content.detail
      _label.font = style.nameStyle.font
      _detailLabel.font = style.detailStyle?.font
      _label.textColor = style.nameStyle.color
      _detailLabel.textColor = style.detailStyle?.color
      _button.titleLabel?.font = style.accessoryStyle?.font
      _button.titleLabel?.textColor = style.accessoryStyle?.color
      _button.contentEdgeInsets = style.buttonContentInsets ?? .zero
      _imageView.tintColor = style.accessoryTintColor
      
      if let accessory = content.accessory {
         switch accessory {
         case .button(let text):
            _button.setTitle(text, for: .normal)
            _button.setImage(nil, for: .normal)
            _button.tintColor = nil
            _imageView.image = nil
         case .image(let image):
            _button.setTitle(nil, for: .normal)
            _button.setImage(nil, for: .normal)
            _button.tintColor = nil
            _imageView.image = image
         case .buttonImage(let image):
            _button.setTitle(nil, for: .normal)
            _button.setImage(image, for: .normal)
            _button.tintColor = style.accessoryTintColor
            _imageView.image = nil
         }
      } else {
         _button.setTitle(nil, for: .normal)
         _button.setImage(nil, for: .normal)
         _button.tintColor = nil
         _imageView.image = nil
      }
      
      _action = action
      _accessory = content.accessory
      
      setNeedsUpdateConstraints()
   }
   
   override func updateConstraints() {
      if let accessory = _accessory {
         switch accessory {
         case .button, .buttonImage:
            _buttonWidthConstraint.isActive = false
            _buttonToImageHorizontalSpacing.isActive = false
            _detailToSuperviewHorizontalSpacing.isActive = false
            _buttonToSuperviewHorizontalSpacing.isActive = true
            _detailToButtonHorizontalSpacing.isActive = true
         case .image:
            _detailToSuperviewHorizontalSpacing.isActive = false
            _buttonToSuperviewHorizontalSpacing.isActive = false
            _buttonWidthConstraint.isActive = true
            _buttonToImageHorizontalSpacing.isActive = true
            _detailToButtonHorizontalSpacing.isActive = true
         }
      } else {
         _detailToButtonHorizontalSpacing.isActive = false
         _detailToSuperviewHorizontalSpacing.isActive = true
         _buttonWidthConstraint.isActive = true
      }
      
      super.updateConstraints()
   }
   
   override func prepareForReuse() {
      _action = nil
      _accessory = nil
      super.prepareForReuse()
   }
   
   // MARK: - KVCompliance
   override func value(for key: IncFormBindableElementKey) -> Any? {
      switch key {
      case .detail: return _detailLabel.text
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: IncFormBindableElementKey) throws {
      switch key {
      case .detail:
         guard value != nil else { _detailLabel.text = nil; return }
         guard let validValue = value as? String else { throw key.kvTypeError(value: value) }
         _detailLabel.text = validValue
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   // MARK: - Size
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormAccessory else { fatalError() }
      let content = element.content
      let style = element.configuration
      let nameHeight = content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font)
      var detailHeight: CGFloat = 0
      if let detail = content.detail, let detailFont = style.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      }
      var accessoryHeight: CGFloat = 0
      if let accessory = content.accessory {
         switch accessory {
         case .button(let text):
            if let font = style.accessoryStyle?.font {
               accessoryHeight = text.heightWithConstrainedWidth(width: width, font: font)
            }
         case .image(let image), .buttonImage(let image): accessoryHeight = image.size.height
         }
      }
      let height = max(max(nameHeight, detailHeight), accessoryHeight)
      return CGSize(width: width, height: max(height, style.height ?? 0))
   }
}
