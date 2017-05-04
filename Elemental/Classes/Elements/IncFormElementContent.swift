//
//  IncFormElementContent.swift
//  GigSalad
//
//  Created by Gregory Klein on 3/2/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

public struct IncFormElementRadioContent {
   let name: String?
   let components: [IncFormRadioSelection.Component]
   
   init(name: String? = nil, components: [IncFormRadioSelection.Component]) {
      self.name = name
      self.components = components
   }
}

public struct IncFormElementTextInputContent {
   let name: String
   let detail: String?
   let placeholder: String?
   
   public init(name: String, detail: String? = nil, placeholder: String? = nil) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
   }
}

public struct IncFormElementDropdownContent {
   let name: String
   let detail: String?
   let placeholder: String?
   let elements: [String]
   
   init(name: String, detail: String? = nil, placeholder: String? = nil, elements: [String] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.elements = elements
   }
}

public struct IncFormElementDateInputContent {
   let name: String
   let detail: String?
   let placeholder: String?
   let maximumDate: Date?
   let minimumDate: Date?
   let date: Date?
   
   init(name: String, detail: String? = nil, placeholder: String? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, date: Date? = nil) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.minimumDate = minimumDate
      self.maximumDate = maximumDate
      self.date = date
   }
}

public struct IncFormElementIconContent {
   let name: String
   let icon: UIImage
}

enum FormComponentAccessory {
   case button(text: String), image(UIImage), buttonImage(UIImage)
}

public struct IncFormElementAccessoryContent {
   let name: String
   let detail: String?
   let accessory: FormComponentAccessory?
}

public struct IncFormElementThumbnailContent {
   let name: String
   let detail: String?
   let accessory: FormComponentAccessory?
   let image: UIImage?
}

public struct IncFormElementSwitchContent {
   let name: String
   let detail: String?
   var on: Bool
   
   init(name: String, detail: String? = nil, on: Bool = false) {
      self.name = name
      self.detail = detail
      self.on = on
   }
}

public struct IncFormElementPickerContent {
   let name: String?
   let detail: String?
   let placeholder: String?
   var leftAccessoryImage: UIImage?
   var rightAccessoryImage: UIImage?
   var options: [IncFormPickerSelection.Option]
   
   init(name: String? = nil, detail: String? = nil, placeholder: String? = nil, leftAccessoryImage: UIImage? = nil, rightAccessoryImage: UIImage? = nil, options: [IncFormPickerSelection.Option] = []) {
      self.name = name
      self.detail = detail
      self.placeholder = placeholder
      self.leftAccessoryImage = leftAccessoryImage
      self.rightAccessoryImage = rightAccessoryImage
      self.options = options
   }
}
