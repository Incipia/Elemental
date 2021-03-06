//
//  AccessoryElementCell.swift
//  Elemental
//
//  Created by Leif Meyer on 3/8/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class AccessoryElementCell: BindableElementCell {
   // MARK: - Outlets
   @IBOutlet private var _label: UILabel!
   @IBOutlet private var _detailLabel: UILabel!
   @IBOutlet private var _button: UIButton!
   @IBOutlet private var _imageView: UIImageView!
   @IBOutlet private var _detailToButtonHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _detailToImageHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _detailToSuperviewHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _nameToDetailHorizontalSpacing: NSLayoutConstraint!
   @IBOutlet private var _nameToDetailVerticalSpacing: NSLayoutConstraint!
   
   @IBOutlet fileprivate var _horizontalConstraints: [NSLayoutConstraint]!
   @IBOutlet fileprivate var _verticalConstraints: [NSLayoutConstraint]!
   fileprivate var _readyToUpdateConstraints: Bool = false

   // MARK - Public Properties
   override class var bindableKeys: [BindableElementKey] { return [.detail] }

   // MARK: - Private Properties
   private var _action: AccessoryElementAction?
   private var _accessory: FormComponentAccessory?
   
   // MARK: - Actions
   @IBAction private func _accessoryButtonPressed() {
      _action?()
   }
   
   // MARK: - Life Cycle
   override func awakeFromNib() {
      super.awakeFromNib()
      
      // the constraints installed in the xib are activated sometime after awakeFromNib() and configure(with:) get called,
      // so activating uninstalled constraints before then causes conflicts
      DispatchQueue.main.async {
         self._readyToUpdateConstraints = true
         self.setNeedsUpdateConstraints()
      }
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? AccessoryElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let action = element.action
      _label.text = content.name
      _detailLabel.text = content.detail
      _label.font = style.nameStyle.font
      _detailLabel.font = style.detailStyle?.font
      _detailLabel.textAlignment = style.detailStyle?.alignment ?? .left
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
      
      let nameToDetailSpacing = content.detail != nil ? style.nameToDetailSpacing : 0
      _nameToDetailHorizontalSpacing.constant = nameToDetailSpacing
      _nameToDetailVerticalSpacing.constant = nameToDetailSpacing
      
      setNeedsUpdateConstraints()
   }
   
   override func updateConstraints() {
      guard _readyToUpdateConstraints, let layoutDirection = element?.elementalConfig.layoutDirection else {
         super.updateConstraints()
         return
      }

//      if let accessory = _accessory {
//         switch accessory {
//         case .button, .buttonImage:
//            _detailToSuperviewHorizontalSpacing.isActive = false
//            _detailToImageHorizontalSpacing.isActive = false
//            _detailToButtonHorizontalSpacing.isActive = true
//         case .image:
//            _detailToSuperviewHorizontalSpacing.isActive = false
//            _detailToButtonHorizontalSpacing.isActive = false
//            _detailToImageHorizontalSpacing.isActive = true
//         }
//      } else {
//         _detailToButtonHorizontalSpacing.isActive = false
//         _detailToImageHorizontalSpacing.isActive = false
//         _detailToSuperviewHorizontalSpacing.isActive = true
//      }

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
      _accessory = nil
      super.prepareForReuse()
   }
   
   // MARK: - IncKVCompliance
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .detail: return _detailLabel.text
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: inout Any?, for key: BindableElementKey) throws {
      switch key {
      case .detail:
         guard value != nil else { _detailLabel.text = nil; return }
         guard let validValue = value as? String else { throw key.kvTypeError(value: value) }
         _detailLabel.text = validValue
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   // MARK: - Size
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? AccessoryElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      let nameHeight = content.name.heightWithConstrainedWidth(width: width, font: style.nameStyle.font)
      var detailHeight: CGFloat = 0
      var detailPadding: CGFloat = 0
      if let detail = content.detail, let detailFont = style.detailStyle?.font {
         detailHeight = detail.heightWithConstrainedWidth(width: width, font: detailFont)
         detailPadding = style.layoutDirection == .vertical ? style.nameToDetailSpacing : 0
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
      let height = style.layoutDirection == .vertical ? max(nameHeight + detailPadding + detailHeight, accessoryHeight)
         : max(max(nameHeight, detailHeight), accessoryHeight)
      return CGSize(width: width, height: height)
   }
}
