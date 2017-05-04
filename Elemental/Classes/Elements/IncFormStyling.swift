//
//  GigSalad.swift
//  GigSalad
//
//  Created by Gregory Klein on 4/14/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

// MARK: - Text Styling
public protocol IncFormTextStyling {
   var font: UIFont { get }
   var color: UIColor { get }
   var alignment: NSTextAlignment { get }
}

public class IncFormTextStyle: IncFormTextStyling {
   public let font: UIFont
   public let color: UIColor
   public let alignment: NSTextAlignment
   
   init(font: UIFont = UIFont.systemFont(ofSize: 14), color: UIColor = .black, alignment: NSTextAlignment = .left) {
      self.font = font
      self.color = color
      self.alignment = alignment
   }
   
   init(style: IncFormTextStyling) {
      self.font = style.font
      self.color = style.color
      self.alignment = style.alignment
   }
}

// MARK: - Keyboard Styling
public protocol IncFormKeyboardStyling {
   var type: UIKeyboardType { get }
   var appearance: UIKeyboardAppearance { get }
   var returnKeyType: UIReturnKeyType { get }
   var autocapitalizationType: UITextAutocapitalizationType { get }
   var isSecureTextEntry: Bool { get }
}

public class IncFormKeyboardStyle: IncFormKeyboardStyling {
   public let type: UIKeyboardType
   public let appearance: UIKeyboardAppearance
   public let returnKeyType: UIReturnKeyType
   public let autocapitalizationType: UITextAutocapitalizationType
   public let isSecureTextEntry: Bool
   
   init(type: UIKeyboardType = .default, appearance: UIKeyboardAppearance = .default, returnKeyType: UIReturnKeyType = .default, autocapitalizationType: UITextAutocapitalizationType = .sentences, isSecureTextEntry: Bool = false) {
      self.type = type
      self.appearance = appearance
      self.returnKeyType = returnKeyType
      self.autocapitalizationType = autocapitalizationType
      self.isSecureTextEntry = isSecureTextEntry
   }
}

