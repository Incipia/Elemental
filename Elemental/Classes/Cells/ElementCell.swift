//
//  ElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/22/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit
import Bindable

protocol ElementalCell: class {
   static func contentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize
   func configure(with component: Elemental)
}

open class ElementCell: UICollectionViewCell, ElementalCell {
   // MARK: - Public Properties
   public weak var element: Element?
   public weak var layoutDelegate: ElementalLayoutDelegate?
   
   // MARK: - Life Cycle
   open override func awakeFromNib() {
      super.awakeFromNib()
      backgroundColor = .clear
   }
   
   // MARK: - ElementalCell Protocol
   open class func contentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      guard let element = element as? Element else { return size }
      let intrinsicSize = intrinsicContentSize(for: element, constrainedSize: size.inset(by: element.elementalConfig.insets))
      return size.constrained(to: element.elementalConfig.sizeConstraint, intrinsicSize: intrinsicSize.outset(by: element.elementalConfig.insets))
   }
   
   open class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize { fatalError() }
   
   open func configure(with component: Elemental) {
      element = component as? Element
      backgroundColor = element?.elementalConfig.backgroundColor
      layer.cornerRadius = element?.elementalConfig.cornerRadius ?? 0
      contentView.layoutMargins = component.elementalConfig.insets
      
      setNeedsUpdateConstraints()
   }
}

extension ElementCell {
   // MARK: - Utility Functions for Subclasses
   static func dataValue(_ value: Any?) -> Data {
      guard var value = value else { return Data() }
      if let jsonRepresentable = value as? IncJSONRepresentable, let jsonObject = jsonRepresentable.jsonRepresentation {
         value = jsonObject
      }
      if JSONSerialization.isValidJSONObject(value), let data = try? JSONSerialization.data(withJSONObject: value, options: []) {
         return data
      } else if JSONSerialization.isValidJSONObject([value]), let data = try? JSONSerialization.data(withJSONObject: [value], options: []) {
         return data
      } else if let data = "\(value)".data(using: .ascii) {
         return data
      }
      return Data()
   }
}
