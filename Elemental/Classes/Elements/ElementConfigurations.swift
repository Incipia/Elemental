//
//  ElementConfigurations.swift
//  Elemental
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public protocol ElementalConfiguring {
   var backgroundColor: UIColor { get }
   var insets: UIEdgeInsets { get }
   var isSelectable: Bool { get }
   var sizeConstraint: ElementalSize { get }
   var isConfinedToMargins: Bool { get }
   var layoutDirection: ElementalLayoutDirection { get }
   var cornerRadius: CGFloat { get }
}

public extension ElementalConfiguring {
   var backgroundColor: UIColor { return .clear }
   var insets: UIEdgeInsets { return .zero }
   var isSelectable: Bool { return true }
   var sizeConstraint: ElementalSize { return ElementalSize() }
   var isConfinedToMargins: Bool { return true }
   var layoutDirection: ElementalLayoutDirection { return .vertical }
   var cornerRadius: CGFloat { return 0 }
}

open class ElementalConfiguration: ElementalConfiguring {
   public var backgroundColor: UIColor
   public var insets: UIEdgeInsets
   public var isSelectable: Bool
   public var sizeConstraint: ElementalSize
   public var isConfinedToMargins: Bool
   public var layoutDirection: ElementalLayoutDirection
   public var cornerRadius: CGFloat
   
   public init(backgroundColor: UIColor = .clear, insets: UIEdgeInsets = .zero, isSelectable: Bool = true, sizeConstraint: ElementalSize = ElementalSize(), isConfinedToMargins: Bool = true, layoutDirection: ElementalLayoutDirection = .vertical, cornerRadius: CGFloat = 0) {
      self.backgroundColor = backgroundColor
      self.insets = insets
      self.isSelectable = isSelectable
      self.sizeConstraint = sizeConstraint
      self.isConfinedToMargins = isConfinedToMargins
      self.layoutDirection = layoutDirection
      self.cornerRadius = cornerRadius
   }
}

public protocol TextElementConfiguring: ElementalConfiguring {
   var textStyle: ElementalTextStyling { get }
}

open class TextElementConfiguration: ElementalConfiguration, TextElementConfiguring {
   public var textStyle: ElementalTextStyling
   
   public init(textStyle: ElementalTextStyling = ElementalTextStyle()) {
      self.textStyle = textStyle
      super.init()
   }
}

public protocol PickerElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var placeholderStyle: ElementalTextStyling? { get }
   var optionStyle: ElementalTextStyling { get }
   var buttonStyle: ElementalTextStyling { get }
   var buttonHeight: CGFloat { get }
   var buttonBackgroundColor: UIColor { get }
   var pickerBackgroundColor: UIColor? { get }
   var pickerTopMargin: CGFloat { get }
   var pickerBottomMargin: CGFloat { get }
   var inputState: InputElementState { get }
   var leftAccessoryImageTintColor: UIColor { get }
   var rightAccessoryImageTintColor: UIColor { get }
   weak var layoutDelegate: ElementalLayoutDelegate? { get }
}

open class PickerElementConfiguration: ElementalConfiguration, PickerElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var detailStyle: ElementalTextStyling?
   public var placeholderStyle: ElementalTextStyling?
   public var optionStyle: ElementalTextStyling
   public var buttonStyle: ElementalTextStyling
   public var buttonHeight: CGFloat
   public var buttonBackgroundColor: UIColor
   public var pickerBackgroundColor: UIColor?
   public var pickerTopMargin: CGFloat
   public var pickerBottomMargin: CGFloat
   public var inputState: InputElementState
   public var leftAccessoryImageTintColor: UIColor
   public var rightAccessoryImageTintColor: UIColor
   weak public var layoutDelegate: ElementalLayoutDelegate?
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, optionStyle: ElementalTextStyling? = nil, buttonStyle: ElementalTextStyling = ElementalTextStyle(), buttonHeight: CGFloat = 64, buttonBackgroundColor: UIColor = .gray, pickerBackgroundColor: UIColor? = nil, pickerTopMargin: CGFloat = 10, pickerBottomMargin: CGFloat = 10, inputState: InputElementState = .unfocused, leftAccessoryImageTintColor: UIColor = .gray, rightAccessoryImageTintColor: UIColor = .gray, layoutDelegate: ElementalLayoutDelegate? = nil) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.placeholderStyle = placeholderStyle
      self.optionStyle = optionStyle ?? buttonStyle
      self.buttonStyle = buttonStyle
      self.buttonHeight = buttonHeight
      self.buttonBackgroundColor = buttonBackgroundColor
      self.pickerBackgroundColor = pickerBackgroundColor
      self.pickerTopMargin = pickerTopMargin
      self.pickerBottomMargin = pickerBottomMargin
      self.inputState = inputState
      self.leftAccessoryImageTintColor = leftAccessoryImageTintColor
      self.rightAccessoryImageTintColor = rightAccessoryImageTintColor
      self.layoutDelegate = layoutDelegate
      super.init()
   }
}

public enum RadioElementAlignment {
   case left, right
}

public protocol RadioSelectionElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var componentStyle: ElementalTextStyling { get }
   var fillColor: UIColor? { get }
   var alignment: RadioElementAlignment { get }
}

open class RadioElementConfiguration: ElementalConfiguration, RadioSelectionElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var componentStyle: ElementalTextStyling
   public var fillColor: UIColor?
   public var alignment: RadioElementAlignment
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), componentStyle: ElementalTextStyling = ElementalTextStyle(), fillColor: UIColor? = nil, alignment: RadioElementAlignment = .left) {
      self.nameStyle = nameStyle
      self.componentStyle = componentStyle
      self.fillColor = fillColor
      self.alignment = alignment
      super.init()
   }
}

public protocol TextInputElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var placeholderStyle: ElementalTextStyling? { get }
   var inputStyle: ElementalTextStyling { get }
   var keyboardStyle: ElementalKeyboardStyling { get }
   var inputHeight: CGFloat { get }
   var inputBackgroundColor: UIColor { get }
   var isEnabled: Bool { get }
}

public extension TextInputElementConfiguring {
   var isEnabled: Bool { return true }
}

open class TextInputElementConfiguration: ElementalConfiguration, TextInputElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var detailStyle: ElementalTextStyling?
   public var placeholderStyle: ElementalTextStyling?
   public var inputStyle: ElementalTextStyling
   public var keyboardStyle: ElementalKeyboardStyling
   public var inputHeight: CGFloat
   public var inputBackgroundColor: UIColor
   public var isEnabled: Bool
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, inputStyle: ElementalTextStyling = ElementalTextStyle(), keyboardStyle: ElementalKeyboardStyling = ElementalKeyboardStyle(), inputHeight: CGFloat = 48, inputBackgroundColor: UIColor = .gray, isEnabled: Bool = true) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.placeholderStyle = placeholderStyle
      self.inputStyle = inputStyle
      self.keyboardStyle = keyboardStyle
      self.inputHeight = inputHeight
      self.inputBackgroundColor = inputBackgroundColor
      self.isEnabled = isEnabled
      super.init()
   }
}

public protocol DateInputElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var placeholderStyle: ElementalTextStyling? { get }
   var inputStyle: ElementalTextStyling { get }
   var inputHeight: CGFloat { get }
   var inputBackgroundColor: UIColor { get }
   var datePickerMode: UIDatePickerMode { get }
   var dateFormatter: DateFormatter { get }
   var inputState: InputElementState { get set }
   weak var layoutDelegate: ElementalLayoutDelegate? { get }
}

open class DateInputElementConfiguration: ElementalConfiguration, DateInputElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var detailStyle: ElementalTextStyling?
   public var placeholderStyle: ElementalTextStyling?
   public var inputStyle: ElementalTextStyling
   public var inputHeight: CGFloat
   public var inputBackgroundColor: UIColor
   public var datePickerMode: UIDatePickerMode
   public var dateFormatter: DateFormatter
   public var inputState: InputElementState
   weak public var layoutDelegate: ElementalLayoutDelegate?
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, inputStyle: ElementalTextStyling = ElementalTextStyle(), inputHeight: CGFloat = 64, inputBackgroundColor: UIColor = .gray, inputState: InputElementState = .unfocused, datePickerMode: UIDatePickerMode = .dateAndTime, dateFormatter: DateFormatter = DateFormatter(), layoutDelegate: ElementalLayoutDelegate? = nil) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.placeholderStyle = placeholderStyle
      self.inputStyle = inputStyle
      self.inputHeight = inputHeight
      self.inputBackgroundColor = inputBackgroundColor
      self.inputState = inputState
      self.datePickerMode = datePickerMode
      self.dateFormatter = dateFormatter
      self.layoutDelegate = layoutDelegate
      super.init()
   }
}

public protocol DropdownElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var placeholderStyle: ElementalTextStyling? { get }
   var dropdownHeight: CGFloat { get }
   var dropdownBackgroundColor: UIColor { get }
   var iconTintColor: UIColor { get }
}

open class DropdownElementConfiguration: ElementalConfiguration, DropdownElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var placeholderStyle: ElementalTextStyling?
   public var dropdownHeight: CGFloat
   public var dropdownBackgroundColor: UIColor
   public var iconTintColor: UIColor
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), placeholderStyle: ElementalTextStyling? = nil, dropdownHeight: CGFloat = 64, dropdownBackgroundColor: UIColor = .gray, iconTintColor: UIColor = .black) {
      self.nameStyle = nameStyle
      self.placeholderStyle = placeholderStyle
      self.dropdownHeight = dropdownHeight
      self.dropdownBackgroundColor = dropdownBackgroundColor
      self.iconTintColor = iconTintColor
      super.init()
   }
}

public protocol LineElementConfiguring: ElementalConfiguring {
   var color: UIColor { get }
}

open class LineElementConfiguration: ElementalConfiguration, LineElementConfiguring {
   public var color: UIColor
   
   public init(height: CGFloat = 1, color: UIColor = .gray) {
      self.color = color
      super.init(sizeConstraint: ElementalSize(width: .intrinsic, height: .constant(height)))
   }
}

public protocol IconElementConfiguring: TextElementConfiguring {
   var iconTintColor: UIColor { get }
}

open class IconElementConfiguration: ElementalConfiguration, IconElementConfiguring {
   public var iconTintColor: UIColor
   public var textStyle: ElementalTextStyling
   
   public init(iconTintColor: UIColor = .black, textStyle: ElementalTextStyling = ElementalTextStyle()) {
      self.iconTintColor = iconTintColor
      self.textStyle = textStyle
      super.init()
   }
}

public protocol AccessoryElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var accessoryStyle: ElementalTextStyling? { get }
   var accessoryTintColor: UIColor? { get }
   var buttonContentInsets: UIEdgeInsets? { get }
   var leadingNamePadding: CGFloat { get }
   var trailingDetailPadding: CGFloat { get }
}

open class AccessoryElementConfiguration: ElementalConfiguration, AccessoryElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var detailStyle: ElementalTextStyling?
   public var accessoryStyle: ElementalTextStyling?
   public var accessoryTintColor: UIColor?
   public var buttonContentInsets: UIEdgeInsets?
   public var leadingNamePadding: CGFloat
   public var trailingDetailPadding: CGFloat
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), detailStyle: ElementalTextStyling? = nil, accessoryStyle: ElementalTextStyling? = nil, accessoryTintColor: UIColor? = nil, buttonContentInsets: UIEdgeInsets? = nil, leadingNamePadding: CGFloat = 0, trailingDetailPadding: CGFloat = 0) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.accessoryStyle = accessoryStyle
      self.accessoryTintColor = accessoryTintColor
      self.buttonContentInsets = buttonContentInsets
      self.leadingNamePadding = leadingNamePadding
      self.trailingDetailPadding = trailingDetailPadding
      super.init()
   }
}

public protocol SwitchElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var offTintColor: UIColor { get }
   var onTintColor: UIColor { get }
}

open class SwitchElementConfiguration: ElementalConfiguration, SwitchElementConfiguring {
   public var nameStyle: ElementalTextStyling
   public var detailStyle: ElementalTextStyling?
   public var offTintColor: UIColor
   public var onTintColor: UIColor
   
   public init(nameStyle: ElementalTextStyling = ElementalTextStyle(), detailStyle: ElementalTextStyling? = nil, height: CGFloat = 64, offTintColor: UIColor = .white, onTintColor: UIColor = .blue) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.offTintColor = offTintColor
      self.onTintColor = onTintColor
      super.init()
   }
}
