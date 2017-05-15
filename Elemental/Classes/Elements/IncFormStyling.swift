//
//  GigSalad.swift
//  GigSalad
//
//  Created by Gregory Klein on 4/14/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

// MARK: - Text Styling
public protocol ElementalTextStyling {
   var font: UIFont { get }
   var color: UIColor { get }
   var alignment: NSTextAlignment { get }
}

open class ElementalTextStyle: ElementalTextStyling {
   public let font: UIFont
   public let color: UIColor
   public let alignment: NSTextAlignment
   
   public init(font: UIFont = UIFont.systemFont(ofSize: 14), color: UIColor = .black, alignment: NSTextAlignment = .left) {
      self.font = font
      self.color = color
      self.alignment = alignment
   }
   
   public init(style: ElementalTextStyling) {
      self.font = style.font
      self.color = style.color
      self.alignment = style.alignment
   }
}

// MARK: - Keyboard Styling
public protocol ElementalKeyboardStyling {
   var type: UIKeyboardType { get }
   var appearance: UIKeyboardAppearance { get }
   var returnKeyType: UIReturnKeyType { get }
   var autocapitalizationType: UITextAutocapitalizationType { get }
   var isSecureTextEntry: Bool { get }
}

open class ElementalKeyboardStyle: ElementalKeyboardStyling {
   public let type: UIKeyboardType
   public let appearance: UIKeyboardAppearance
   public let returnKeyType: UIReturnKeyType
   public let autocapitalizationType: UITextAutocapitalizationType
   public let isSecureTextEntry: Bool
   
   public init(type: UIKeyboardType = .default, appearance: UIKeyboardAppearance = .default, returnKeyType: UIReturnKeyType = .default, autocapitalizationType: UITextAutocapitalizationType = .sentences, isSecureTextEntry: Bool = false) {
      self.type = type
      self.appearance = appearance
      self.returnKeyType = returnKeyType
      self.autocapitalizationType = autocapitalizationType
      self.isSecureTextEntry = isSecureTextEntry
   }
}

