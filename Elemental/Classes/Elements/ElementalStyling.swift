//
//  ElementalStyling.swift
//  Elemental
//
//  Created by Gregory Klein on 4/14/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

// MARK: - Layout
public enum ElementalLayoutDirection {
   case horizontal, vertical
}

// MARK: - Sizing
public enum ElementalSizeConstraint {
   case intrinsic
   case constant(CGFloat)
   case multiplier(CGFloat)
   case calc(constant: CGFloat, multiplier: CGFloat)
   case callback((CGSize) -> CGFloat)
}

extension ElementalSizeConstraint: Equatable {
   public static func == (lhs: ElementalSizeConstraint, rhs: ElementalSizeConstraint) -> Bool {
      switch lhs {
      case .intrinsic:
         switch rhs {
         case .intrinsic: return true
         default: return false
         }
      case .constant(let lk):
         switch rhs {
         case .constant(let rk): return lk == rk
         default: return false
         }
      case .multiplier(let lm):
         switch rhs {
         case .multiplier(let rm): return lm == rm
         default: return false
         }
      case .calc(let lk, let lm):
         switch rhs {
         case .calc(let rk, let rm): return lk == rk && lm == rm
         default: return false
         }
      case .callback: return false
      }
   }
}

public struct ElementalSize {
   public var width: ElementalSizeConstraint
   public var height: ElementalSizeConstraint
   
   public init(width: ElementalSizeConstraint = .intrinsic, height: ElementalSizeConstraint = .intrinsic) {
      self.width = width
      self.height = height
   }
}

extension ElementalSize: Equatable {
   public static func == (lhs: ElementalSize, rhs: ElementalSize) -> Bool {
      return lhs.width == rhs.width && lhs.height == rhs.height
   }
}

extension CGSize {
   public func constrained(to sizeConstraint: ElementalSize, intrinsicSize: CGSize? = nil) -> CGSize {
      let intrinsicSize = intrinsicSize ?? self
      
      var width: CGFloat
      switch sizeConstraint.width {
      case .intrinsic: width = intrinsicSize.width
      case .constant(let value): width = value
      case .multiplier(let value): width = self.width * value
      case .calc(let constant, let multiplier): width = self.width * multiplier + constant
      case .callback(let callback): width = callback(self)
      }
      
      var height: CGFloat
      switch sizeConstraint.height {
      case .intrinsic: height = intrinsicSize.height
      case .constant(let value): height = value
      case .multiplier(let value): height = self.height * value
      case .calc(let constant, let multiplier): height = self.height * multiplier + constant
      case .callback(let callback): height = callback(self)
      }
      
      return CGSize(width: width, height: height)
   }
}

// MARK: - Text Styling
public protocol ElementalTextStyling {
   var font: UIFont { get }
   var color: UIColor { get }
   var alignment: NSTextAlignment { get }
}

open class ElementalTextStyle: ElementalTextStyling {
   public var font: UIFont
   public var color: UIColor
   public var alignment: NSTextAlignment
   
   public init(font: UIFont = .systemFont(ofSize: 14), color: UIColor = .black, alignment: NSTextAlignment = .left) {
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
   public var type: UIKeyboardType
   public var appearance: UIKeyboardAppearance
   public var returnKeyType: UIReturnKeyType
   public var autocapitalizationType: UITextAutocapitalizationType
   public var isSecureTextEntry: Bool
   
   public init(type: UIKeyboardType = .default, appearance: UIKeyboardAppearance = .default, returnKeyType: UIReturnKeyType = .default, autocapitalizationType: UITextAutocapitalizationType = .sentences, isSecureTextEntry: Bool = false) {
      self.type = type
      self.appearance = appearance
      self.returnKeyType = returnKeyType
      self.autocapitalizationType = autocapitalizationType
      self.isSecureTextEntry = isSecureTextEntry
   }
}

