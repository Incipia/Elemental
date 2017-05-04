//
//  IncFormElementalConfiguring.swift
//  GigSalad
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public protocol IncFormElementalConfiguring {
   var backgroundColor: UIColor { get }
   var insets: UIEdgeInsets { get }
   var isSelectable: Bool { get }
   var width: CGFloat? { get }
   var height: CGFloat? { get }
   var isConfinedToMargins: Bool { get }
}

public extension IncFormElementalConfiguring {
   var backgroundColor: UIColor { return .clear }
   var insets: UIEdgeInsets { return .zero }
   var isSelectable: Bool { return true }
   var width: CGFloat? { return nil }
   var height: CGFloat? { return nil }
   var isConfinedToMargins: Bool { return true }
}

public class IncFormElementalConfiguration: IncFormElementalConfiguring {
   public let backgroundColor: UIColor
   public let insets: UIEdgeInsets
   public let isSelectable: Bool
   public let width: CGFloat?
   public let height: CGFloat?
   public let isConfinedToMargins: Bool
   
   init(backgroundColor: UIColor = .clear, insets: UIEdgeInsets = .zero, isSelectable: Bool = true, width: CGFloat? = nil, height: CGFloat? = nil, isConfinedToMargins: Bool = true) {
      self.backgroundColor = backgroundColor
      self.insets = insets
      self.isSelectable = isSelectable
      self.width = width
      self.height = height
      self.isConfinedToMargins = isConfinedToMargins
   }
}

public protocol IncFormTextConfiguring: IncFormElementalConfiguring {
   var textStyle: IncFormTextStyling { get }
}

public class IncFormTextConfiguration: IncFormElementalConfiguration, IncFormTextConfiguring {
   public let textStyle: IncFormTextStyling
   
   init(textStyle: IncFormTextStyling = IncFormTextStyle(), height: CGFloat = 48) {
      self.textStyle = textStyle
      super.init(height: height)
   }
}

public protocol IncFormPickerConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var detailStyle: IncFormTextStyling? { get }
   var placeholderStyle: IncFormTextStyling? { get }
   var optionStyle: IncFormTextStyling { get }
   var buttonStyle: IncFormTextStyling { get }
   var buttonHeight: CGFloat { get }
   var buttonBackgroundColor: UIColor { get }
   var inputState: IncFormElementInputState { get }
   var leftAccessoryImageTintColor: UIColor { get }
   var rightAccessoryImageTintColor: UIColor { get }
   weak var layoutDelegate: IncFormElementLayoutDelegate? { get }
}

public class IncFormPickerConfiguration: IncFormElementalConfiguration, IncFormPickerConfiguring {
   public let nameStyle: IncFormTextStyling
   public let detailStyle: IncFormTextStyling?
   public let placeholderStyle: IncFormTextStyling?
   public var optionStyle: IncFormTextStyling
   public let buttonStyle: IncFormTextStyling
   public let buttonHeight: CGFloat
   public let buttonBackgroundColor: UIColor
   public var inputState: IncFormElementInputState
   public var leftAccessoryImageTintColor: UIColor
   public var rightAccessoryImageTintColor: UIColor
   weak public var layoutDelegate: IncFormElementLayoutDelegate?
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), detailStyle: IncFormTextStyling? = nil, placeholderStyle: IncFormTextStyling? = nil, optionStyle: IncFormTextStyling? = nil, buttonStyle: IncFormTextStyling = IncFormTextStyle(), buttonHeight: CGFloat = 64, buttonBackgroundColor: UIColor = .gray, inputState: IncFormElementInputState = .unfocused, leftAccessoryImageTintColor: UIColor = .gray, rightAccessoryImageTintColor: UIColor = .gray, layoutDelegate: IncFormElementLayoutDelegate? = nil) {
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

public enum IncFormRadioAlignment {
   case left, right
}

public protocol IncFormRadioConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var componentStyle: IncFormTextStyling { get }
   var fillColor: UIColor? { get }
   var alignment: IncFormRadioAlignment { get }
}

public class IncFormRadioConfiguration: IncFormElementalConfiguration, IncFormRadioConfiguring {
   public let nameStyle: IncFormTextStyling
   public let componentStyle: IncFormTextStyling
   public let fillColor: UIColor?
   public let alignment: IncFormRadioAlignment
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), componentStyle: IncFormTextStyling = IncFormTextStyle(), fillColor: UIColor? = nil, alignment: IncFormRadioAlignment = .left) {
      self.nameStyle = nameStyle
      self.componentStyle = componentStyle
      self.fillColor = fillColor
      self.alignment = alignment
      super.init()
   }
}

public protocol IncFormTextInputConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var detailStyle: IncFormTextStyling? { get }
   var placeholderStyle: IncFormTextStyling? { get }
   var inputStyle: IncFormTextStyling { get }
   var keyboardStyle: IncFormKeyboardStyling { get }
   var inputHeight: CGFloat { get }
   var inputBackgroundColor: UIColor { get }
   var isEnabled: Bool { get }
}

extension IncFormTextInputConfiguring {
   public var isEnabled: Bool { return true }
}

public class IncFormTextInputConfiguration: IncFormElementalConfiguration, IncFormTextInputConfiguring {
   public let nameStyle: IncFormTextStyling
   public let detailStyle: IncFormTextStyling?
   public let placeholderStyle: IncFormTextStyling?
   public let inputStyle: IncFormTextStyling
   public let keyboardStyle: IncFormKeyboardStyling
   public let inputHeight: CGFloat
   public let inputBackgroundColor: UIColor
   public let isEnabled: Bool
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), detailStyle: IncFormTextStyling? = nil, placeholderStyle: IncFormTextStyling? = nil, inputStyle: IncFormTextStyling = IncFormTextStyle(), keyboardStyle: IncFormKeyboardStyling = IncFormKeyboardStyle(), inputHeight: CGFloat = 48, inputBackgroundColor: UIColor = .gray, isEnabled: Bool = true) {
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

public protocol IncFormDateInputConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var detailStyle: IncFormTextStyling? { get }
   var placeholderStyle: IncFormTextStyling? { get }
   var inputStyle: IncFormTextStyling { get }
   var inputHeight: CGFloat { get }
   var inputBackgroundColor: UIColor { get }
   var datePickerMode: UIDatePickerMode { get }
   var dateFormatter: DateFormatter { get }
   var inputState: IncFormElementInputState { get set }
   weak var layoutDelegate: IncFormElementLayoutDelegate? { get }
}

public class IncFormDateInputConfiguration: IncFormElementalConfiguration, IncFormDateInputConfiguring {
   public let nameStyle: IncFormTextStyling
   public let detailStyle: IncFormTextStyling?
   public let placeholderStyle: IncFormTextStyling?
   public let inputStyle: IncFormTextStyling
   public let inputHeight: CGFloat
   public let inputBackgroundColor: UIColor
   public let datePickerMode: UIDatePickerMode
   public let dateFormatter: DateFormatter
   public var inputState: IncFormElementInputState
   weak public var layoutDelegate: IncFormElementLayoutDelegate?
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), detailStyle: IncFormTextStyling? = nil, placeholderStyle: IncFormTextStyling? = nil, inputStyle: IncFormTextStyling = IncFormTextStyle(), inputHeight: CGFloat = 64, inputBackgroundColor: UIColor = .gray, inputState: IncFormElementInputState = .unfocused, datePickerMode: UIDatePickerMode = .dateAndTime, dateFormatter: DateFormatter = DateFormatter(), layoutDelegate: IncFormElementLayoutDelegate? = nil) {
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

public protocol IncFormDropdownConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var placeholderStyle: IncFormTextStyling? { get }
   var dropdownHeight: CGFloat { get }
   var dropdownBackgroundColor: UIColor { get }
   var iconTintColor: UIColor { get }
}

public class IncFormDropdownConfiguration: IncFormElementalConfiguration, IncFormDropdownConfiguring {
   public let nameStyle: IncFormTextStyling
   public let placeholderStyle: IncFormTextStyling?
   public let dropdownHeight: CGFloat
   public let dropdownBackgroundColor: UIColor
   public let iconTintColor: UIColor
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), placeholderStyle: IncFormTextStyling? = nil, dropdownHeight: CGFloat = 64, dropdownBackgroundColor: UIColor = .gray, iconTintColor: UIColor = .black) {
      self.nameStyle = nameStyle
      self.placeholderStyle = placeholderStyle
      self.dropdownHeight = dropdownHeight
      self.dropdownBackgroundColor = dropdownBackgroundColor
      self.iconTintColor = iconTintColor
      super.init()
   }
}

public protocol IncFormDividingLineConfiguring: IncFormElementalConfiguring {
   var color: UIColor { get }
}

public class IncFormDividingLineConfiguration: IncFormElementalConfiguration, IncFormDividingLineConfiguring {
   public let color: UIColor
   
   init(height: CGFloat = 1, color: UIColor = .gray) {
      self.color = color
      super.init(height: height)
   }
}

public protocol IncFormIconConfiguring: IncFormTextConfiguring {
   var iconTintColor: UIColor { get }
}

public class IncFormIconConfiguration: IncFormElementalConfiguration, IncFormIconConfiguring {
   public let iconTintColor: UIColor
   public let textStyle: IncFormTextStyling
   
   init(iconTintColor: UIColor = .black, textStyle: IncFormTextStyling = IncFormTextStyle(), height: CGFloat = 48) {
      self.iconTintColor = iconTintColor
      self.textStyle = textStyle
      super.init(height: height)
   }
}

public protocol IncFormAccessoryConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var detailStyle: IncFormTextStyling? { get }
   var accessoryStyle: IncFormTextStyling? { get }
   var accessoryTintColor: UIColor? { get }
   var buttonContentInsets: UIEdgeInsets? { get }
}

public class IncFormAccessoryConfiguration: IncFormElementalConfiguration, IncFormAccessoryConfiguring {
   public let nameStyle: IncFormTextStyling
   public let detailStyle: IncFormTextStyling?
   public let accessoryStyle: IncFormTextStyling?
   public let accessoryTintColor: UIColor?
   public let buttonContentInsets: UIEdgeInsets?
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), detailStyle: IncFormTextStyling? = nil, accessoryStyle: IncFormTextStyling? = nil, accessoryTintColor: UIColor? = nil, buttonContentInsets: UIEdgeInsets? = nil, height: CGFloat = 64) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.accessoryStyle = accessoryStyle
      self.accessoryTintColor = accessoryTintColor
      self.buttonContentInsets = buttonContentInsets
      super.init(height: height)
   }
}

public protocol IncFormSwitchConfiguring: IncFormElementalConfiguring {
   var nameStyle: IncFormTextStyling { get }
   var detailStyle: IncFormTextStyling? { get }
   var offTintColor: UIColor { get }
   var onTintColor: UIColor { get }
}

public class IncFormSwitchConfiguration: IncFormElementalConfiguration, IncFormSwitchConfiguring {
   public let nameStyle: IncFormTextStyling
   public let detailStyle: IncFormTextStyling?
   public let offTintColor: UIColor
   public let onTintColor: UIColor
   
   init(nameStyle: IncFormTextStyling = IncFormTextStyle(), detailStyle: IncFormTextStyling? = nil, height: CGFloat = 64, offTintColor: UIColor = .white, onTintColor: UIColor = .blue) {
      self.nameStyle = nameStyle
      self.detailStyle = detailStyle
      self.offTintColor = offTintColor
      self.onTintColor = onTintColor
      super.init(height: height)
   }
}
