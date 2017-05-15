//
//  ElementalConfiguring.swift
//  GigSalad
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public protocol ElementalConfiguring {
   var backgroundColor: UIColor { get }
   var insets: UIEdgeInsets { get }
   var isSelectable: Bool { get }
   var width: CGFloat? { get }
   var height: CGFloat? { get }
   var isConfinedToMargins: Bool { get }
}

public extension ElementalConfiguring {
   var backgroundColor: UIColor { return .clear }
   var insets: UIEdgeInsets { return .zero }
   var isSelectable: Bool { return true }
   var width: CGFloat? { return nil }
   var height: CGFloat? { return nil }
   var isConfinedToMargins: Bool { return true }
}

open class ElementalConfiguration: ElementalConfiguring {
   public let backgroundColor: UIColor
   public let insets: UIEdgeInsets
   public let isSelectable: Bool
   public let width: CGFloat?
   public let height: CGFloat?
   public let isConfinedToMargins: Bool
   
   public init(backgroundColor: UIColor = .clear, insets: UIEdgeInsets = .zero, isSelectable: Bool = true, width: CGFloat? = nil, height: CGFloat? = nil, isConfinedToMargins: Bool = true) {
      self.backgroundColor = backgroundColor
      self.insets = insets
      self.isSelectable = isSelectable
      self.width = width
      self.height = height
      self.isConfinedToMargins = isConfinedToMargins
   }
}

public protocol TextElementConfiguring: ElementalConfiguring {
   var textStyle: ElementalTextStyling { get }
}

open class IncFormTextConfiguration: ElementalConfiguration, TextElementConfiguring {
   public let textStyle: ElementalTextStyling
   
   public init(textStyle: ElementalTextStyling = IncFormTextStyle(), height: CGFloat = 48) {
      self.textStyle = textStyle
      super.init(height: height)
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
   var inputState: InputElementState { get }
   var leftAccessoryImageTintColor: UIColor { get }
   var rightAccessoryImageTintColor: UIColor { get }
   weak var layoutDelegate: ElementalLayoutDelegate? { get }
}

open class IncFormPickerConfiguration: ElementalConfiguration, PickerElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let detailStyle: ElementalTextStyling?
   public let placeholderStyle: ElementalTextStyling?
   public var optionStyle: ElementalTextStyling
   public let buttonStyle: ElementalTextStyling
   public let buttonHeight: CGFloat
   public let buttonBackgroundColor: UIColor
   public var inputState: InputElementState
   public var leftAccessoryImageTintColor: UIColor
   public var rightAccessoryImageTintColor: UIColor
   weak public var layoutDelegate: ElementalLayoutDelegate?
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, optionStyle: ElementalTextStyling? = nil, buttonStyle: ElementalTextStyling = IncFormTextStyle(), buttonHeight: CGFloat = 64, buttonBackgroundColor: UIColor = .gray, inputState: InputElementState = .unfocused, leftAccessoryImageTintColor: UIColor = .gray, rightAccessoryImageTintColor: UIColor = .gray, layoutDelegate: ElementalLayoutDelegate? = nil) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.placeholderStyle = placeholderStyle
      self.optionStyle = optionStyle ?? buttonStyle
      self.buttonStyle = buttonStyle
      self.buttonHeight = buttonHeight
      self.buttonBackgroundColor = buttonBackgroundColor
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

public protocol RadioElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var componentStyle: ElementalTextStyling { get }
   var fillColor: UIColor? { get }
   var alignment: RadioElementAlignment { get }
}

open class IncFormRadioConfiguration: ElementalConfiguration, RadioElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let componentStyle: ElementalTextStyling
   public let fillColor: UIColor?
   public let alignment: RadioElementAlignment
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), componentStyle: ElementalTextStyling = IncFormTextStyle(), fillColor: UIColor? = nil, alignment: RadioElementAlignment = .left) {
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

open class IncFormTextInputConfiguration: ElementalConfiguration, TextInputElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let detailStyle: ElementalTextStyling?
   public let placeholderStyle: ElementalTextStyling?
   public let inputStyle: ElementalTextStyling
   public let keyboardStyle: ElementalKeyboardStyling
   public let inputHeight: CGFloat
   public let inputBackgroundColor: UIColor
   public let isEnabled: Bool
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, inputStyle: ElementalTextStyling = IncFormTextStyle(), keyboardStyle: ElementalKeyboardStyling = IncFormKeyboardStyle(), inputHeight: CGFloat = 48, inputBackgroundColor: UIColor = .gray, isEnabled: Bool = true) {
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

open class IncFormDateInputConfiguration: ElementalConfiguration, DateInputElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let detailStyle: ElementalTextStyling?
   public let placeholderStyle: ElementalTextStyling?
   public let inputStyle: ElementalTextStyling
   public let inputHeight: CGFloat
   public let inputBackgroundColor: UIColor
   public let datePickerMode: UIDatePickerMode
   public let dateFormatter: DateFormatter
   public var inputState: InputElementState
   weak public var layoutDelegate: ElementalLayoutDelegate?
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), detailStyle: ElementalTextStyling? = nil, placeholderStyle: ElementalTextStyling? = nil, inputStyle: ElementalTextStyling = IncFormTextStyle(), inputHeight: CGFloat = 64, inputBackgroundColor: UIColor = .gray, inputState: InputElementState = .unfocused, datePickerMode: UIDatePickerMode = .dateAndTime, dateFormatter: DateFormatter = DateFormatter(), layoutDelegate: ElementalLayoutDelegate? = nil) {
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

open class IncFormDropdownConfiguration: ElementalConfiguration, DropdownElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let placeholderStyle: ElementalTextStyling?
   public let dropdownHeight: CGFloat
   public let dropdownBackgroundColor: UIColor
   public let iconTintColor: UIColor
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), placeholderStyle: ElementalTextStyling? = nil, dropdownHeight: CGFloat = 64, dropdownBackgroundColor: UIColor = .gray, iconTintColor: UIColor = .black) {
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

open class IncFormDividingLineConfiguration: ElementalConfiguration, LineElementConfiguring {
   public let color: UIColor
   
   public init(height: CGFloat = 1, color: UIColor = .gray) {
      self.color = color
      super.init(height: height)
   }
}

public protocol IconElementConfiguring: TextElementConfiguring {
   var iconTintColor: UIColor { get }
}

open class IncFormIconConfiguration: ElementalConfiguration, IconElementConfiguring {
   public let iconTintColor: UIColor
   public let textStyle: ElementalTextStyling
   
   public init(iconTintColor: UIColor = .black, textStyle: ElementalTextStyling = IncFormTextStyle(), height: CGFloat = 48) {
      self.iconTintColor = iconTintColor
      self.textStyle = textStyle
      super.init(height: height)
   }
}

public protocol AccessoryElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var accessoryStyle: ElementalTextStyling? { get }
   var accessoryTintColor: UIColor? { get }
   var buttonContentInsets: UIEdgeInsets? { get }
}

open class IncFormAccessoryConfiguration: ElementalConfiguration, AccessoryElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let detailStyle: ElementalTextStyling?
   public let accessoryStyle: ElementalTextStyling?
   public let accessoryTintColor: UIColor?
   public let buttonContentInsets: UIEdgeInsets?
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), detailStyle: ElementalTextStyling? = nil, accessoryStyle: ElementalTextStyling? = nil, accessoryTintColor: UIColor? = nil, buttonContentInsets: UIEdgeInsets? = nil, height: CGFloat = 64) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.accessoryStyle = accessoryStyle
      self.accessoryTintColor = accessoryTintColor
      self.buttonContentInsets = buttonContentInsets
      super.init(height: height)
   }
}

public protocol SwitchElementConfiguring: ElementalConfiguring {
   var nameStyle: ElementalTextStyling { get }
   var detailStyle: ElementalTextStyling? { get }
   var offTintColor: UIColor { get }
   var onTintColor: UIColor { get }
}

open class IncFormSwitchConfiguration: ElementalConfiguration, SwitchElementConfiguring {
   public let nameStyle: ElementalTextStyling
   public let detailStyle: ElementalTextStyling?
   public let offTintColor: UIColor
   public let onTintColor: UIColor
   
   public init(nameStyle: ElementalTextStyling = IncFormTextStyle(), detailStyle: ElementalTextStyling? = nil, height: CGFloat = 64, offTintColor: UIColor = .white, onTintColor: UIColor = .blue) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.offTintColor = offTintColor
      self.onTintColor = onTintColor
      super.init(height: height)
   }
}
