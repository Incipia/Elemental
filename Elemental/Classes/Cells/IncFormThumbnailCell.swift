//
//  IncFormThumbnailCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/12/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class IncFormThumbnailCell: IncFormBindableElementCell {
   // MARK: - Outlets
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _button: UIButton!
   @IBOutlet private var _imageView: UIImageView!
   @IBOutlet private var _thumbnailView: UIImageView!
   @IBOutlet private var _thumbnailToDetailHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _nameToThumbnailVerticalSpacing: NSLayoutConstraint!
   @IBOutlet private var _nameToDetailVerticalSpacing: NSLayoutConstraint!
   @IBOutlet private var _buttonWidthConstraint: NSLayoutConstraint!
   
   // MARK - Public Properties
   static var bindableKeys: [IncFormBindableElementKey] { return [.name, .detail, .image] }
   
   // MARK: - Private Properties
   private var _action: IncFormElementAccessoryAction?
   
   // MARK: - Actions
   @IBAction private func _accessoryButtonPressed() {
      _action?()
   }
   
   // MARK: - Life Cycle
   override func configure(with component: IncFormElemental) {
      super.configure(with: component)
      guard let element = component as? IncFormThumbnail else { fatalError() }
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
      _thumbnailView.image = content.image
      
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
      self.bindings = bindings
      
      setNeedsUpdateConstraints()
   }
   
   override func prepareForReuse() {
      _action = nil
      super.prepareForReuse()
   }
   
   override func updateConstraints() {
      _buttonWidthConstraint.isActive = (_button.currentTitle?.isEmpty ?? true) && _button.currentImage == nil
      _thumbnailToDetailHorizontalSpacing.isActive = _thumbnailView.image != nil
      let verticalSpacing: CGFloat = (_thumbnailView.image == nil && _detailLabel.text?.isEmpty ?? true) ? 0 : 8
      _nameToThumbnailVerticalSpacing.constant = verticalSpacing
      _nameToDetailVerticalSpacing.constant = verticalSpacing
      
      super.updateConstraints()
   }
   
   // MARK: - IncKVCompliance
   override func value(for key: IncFormBindableElementKey) -> Any? {
      switch key {
      case .detail: return _detailLabel.text
      case .name: return _label.text
      case .image: return _thumbnailView.image
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: Any?, for key: IncFormBindableElementKey) throws {
      switch key {
      case .detail:
         if value == nil {
            _detailLabel.text = nil
         } else {
            guard let validValue = value as? String else { throw key.kvTypeError(value: value) }
            _detailLabel.text = validValue
         }
         setNeedsUpdateConstraints()
      case .name:
         guard let validValue = value as? String else { throw key.kvTypeError(value: value) }
         _label.text = validValue
      case .image:
         if value == nil {
            _thumbnailView.image = nil
         } else {
            guard let validValue = value as? UIImage else { throw key.kvTypeError(value: value) }
            _thumbnailView.image = validValue
         }
         setNeedsUpdateConstraints()
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   // MARK: - Size
   override class func contentSize(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize {
      guard let element = element as? IncFormThumbnail else { fatalError() }
      let content = element.content
      let style = element.configuration
      let nameHeight = content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font)
      var detailHeight: CGFloat = 0
      if let detail = content.detail, let detailFont = style.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
      }
      let imageHeight: CGFloat = content.image?.size.height ?? 0
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
      let thumbnailHeight = max(detailHeight, imageHeight)
      let contentHeight = thumbnailHeight > 0 ? nameHeight + 8 + thumbnailHeight : 0
      return CGSize(width: width, height: max(max(contentHeight, accessoryHeight), style.height ?? 0))
   }
}
