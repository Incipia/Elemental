//
//  IncFormElementContent.swift
//  GigSalad
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public struct RadioElementContent {
   public let name: String?
   public let components: [RadioSelectionElement.Component]
   
   public init(name: String? = nil, components: [RadioSelectionElement.Component]) {
      self.name = name
      self.components = components
   }
}

public struct TextInputElementContent {
   public let name: String
   public let detail: String?
   public let placeholder: String?
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
   }
}

public struct DropdownElementContent {
   public let name: String
   public let detail: String?
   public let placeholder: String?
   public let elements: [String]
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil, elements: [String] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.elements = elements
   }
}

public struct DateInputElementContent {
   public let name: String
   public let detail: String?
   public let placeholder: String?
   public let leftAccessoryImage: UIImage?
   public let maximumDate: Date?
   public let minimumDate: Date?
   public let date: Date?
   
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
   public let name: String
   public let icon: UIImage
   
   public init(name: String, icon: UIImage) {
      self.name = name
      self.icon = icon
   }
}

public enum FormComponentAccessory {
   case button(text: String), image(UIImage), buttonImage(UIImage)
}

public struct AccessoryElementContent {
   public let name: String
   public let detail: String?
   public let accessory: FormComponentAccessory?
   
   public init(name: String, detail: String? = nil, accessory: FormComponentAccessory? = nil) {
      self.name = name
      self.detail = detail
      self.accessory = accessory
   }
}

public struct ThumbnailElementContent {
   public let name: String
   public let detail: String?
   public let accessory: FormComponentAccessory?
   public let image: UIImage?

   public init(name: String, detail: String? = nil, accessory: FormComponentAccessory? = nil, image: UIImage? = nil) {
      self.name = name
      self.detail = detail
      self.accessory = accessory
      self.image = image
   }
}

public struct SwitchElementContent {
   public let name: String
   public let detail: String?
   var on: Bool
   
   public init(name: String, detail: String? = nil, on: Bool = false) {
      self.name = name
      self.detail = detail
      self.on = on
   }
}

public struct PickerElementContent {
   public let name: String?
   public let detail: String?
   public let placeholder: String?
   var leftAccessoryImage: UIImage?
   var rightAccessoryImage: UIImage?
   var options: [PickerElement.Option]
   
   public init(name: String? = nil, detail: String? = nil, placeholder: String? = nil, leftAccessoryImage: UIImage? = nil, rightAccessoryImage: UIImage? = nil, options: [PickerElement.Option] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.leftAccessoryImage = leftAccessoryImage
      self.rightAccessoryImage = rightAccessoryImage
      self.options = options
   }
}
