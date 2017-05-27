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

public class ElementCell: UICollectionViewCell, ElementalCell {
   // MARK: - Public Properties
   weak var element: Element?
   weak var layoutDelegate: ElementalLayoutDelegate?
   
   // MARK: - Life Cycle
   public override func awakeFromNib() {
      super.awakeFromNib()
      backgroundColor = .clear
   }
   
   // MARK: - ElementalCell Protocol
   class func contentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      guard let element = element as? Element else { return size }
      
      let intrinsicSize = intrinsicContentSize(for: element, constrainedSize: size)
      return size.constrained(to: element.elementalConfig.sizeConstraint, intrinsicSize: intrinsicSize)
   }
   
   class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize { fatalError() }
   
   func configure(with component: Elemental) {
      element = component as? Element
   }
}

extension ElementCell {
   // MARK: - Utility Functions for Subclasses
   static func dataValue(_ value: Any) -> Data {
      var value = value
      if let jsonRepresentable = value as? IncJSONRepresentable, let jsonObject = jsonRepresentable.jsonRepresentation {
         value = jsonObject
      }
      if JSONSerialization.isValidJSONObject(value), let data = try? JSONSerialization.data(withJSONObject: value, options: []) {
         return data
      } else if JSONSerialization.isValidJSONObject([value]), let data = try? JSONSerialization.data(withJSONObject: [value], options: []) {
         return data
      } else if let data = "\(value)".data(using: .utf8) {
         return data
      }
      return Data()
   }
}
