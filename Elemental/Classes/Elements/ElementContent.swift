//
//  IncFormElementContent.swift
//  Elemental
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public struct RadioElementContent {
   public var name: String?
   public var components: [RadioSelectionElement.Component]
   
   public init(name: String? = nil, components: [RadioSelectionElement.Component]) {
      self.name = name
      self.components = components
   }
}

public struct TextInputElementContent {
   public var name: String
   public var detail: String?
   public var placeholder: String?
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
   }
}

public struct DropdownElementContent {
   public var name: String
   public var detail: String?
   public var placeholder: String?
   public var elements: [String]
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil, elements: [String] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.elements = elements
   }
}

public struct DateInputElementContent {
   public var name: String
   public var detail: String?
   public var placeholder: String?
   public var leftAccessoryImage: UIImage?
   public var maximumDate: Date?
   public var minimumDate: Date?
   public var date: Date?
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil, leftAccessoryImage: UIImage? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, date: Date? = nil) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.leftAccessoryImage = leftAccessoryImage
      self.minimumDate = minimumDate
      self.maximumDate = maximumDate
      self.date = date
   }
}

public struct IconElementContent {
   public var name: String
   public var icon: UIImage
   
   public init(name: String, icon: UIImage) {
      self.name = name
      self.icon = icon
   }
}

public enum FormComponentAccessory {
   case button(text: String), image(UIImage), buttonImage(UIImage)
}

public struct AccessoryElementContent {
   public var name: String
   public var detail: String?
   public var accessory: FormComponentAccessory?
   
   public init(name: String, detail: String? = nil, accessory: FormComponentAccessory? = nil) {
      self.name = name
      self.detail = detail
      self.accessory = accessory
   }
   
   public static func content(name: String = "", detail: String? = nil, accessory: FormComponentAccessory? = nil) -> AccessoryElementContent {
      return AccessoryElementContent(name: name, detail: detail, accessory: accessory)
   }
}

public struct ThumbnailElementContent {
   public var name: String
   public var detail: String?
   public var accessory: FormComponentAccessory?
   public var image: UIImage?

   public init(name: String, detail: String? = nil, accessory: FormComponentAccessory? = nil, image: UIImage? = nil) {
      self.name = name
      self.detail = detail
      self.accessory = accessory
      self.image = image
   }
}

public struct SwitchElementContent {
   public var name: String
   public var detail: String?
   public var on: Bool
   
   public init(name: String, detail: String? = nil, on: Bool = false) {
      self.name = name
      self.detail = detail
      self.on = on
   }
}

public struct PickerElementContent {
   public var name: String?
   public var detail: String?
   public var placeholder: String?
   public var leftAccessoryImage: UIImage?
   public var rightAccessoryImage: UIImage?
   public var options: [PickerElement.Option]
   
   public init(name: String? = nil, detail: String? = nil, placeholder: String? = nil, leftAccessoryImage: UIImage? = nil, rightAccessoryImage: UIImage? = nil, options: [PickerElement.Option] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.leftAccessoryImage = leftAccessoryImage
      self.rightAccessoryImage = rightAccessoryImage
      self.options = options
   }
}
