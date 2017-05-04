//
//  JSONRepresentable.swift
//  GigSalad
//
//  Created by Leif Meyer on 2/24/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import Foundation

protocol JSONRepresentable {
   var jsonRepresentation: Any? { get }
}

protocol KVJSONRepresentable: JSONRepresentable, KVCompliance {
   static var jsonKeys: [Key] { get }
}

extension KVJSONRepresentable {
   var jsonRepresentation: Any? {
      var json: [String : Any] = [:]
      Self.jsonKeys.forEach {
         let value = self.value(for: $0)
         if let representableValue = value as? JSONRepresentable {
            json[$0.rawValue] = representableValue.jsonRepresentation
         } else {
            json[$0.rawValue] = value
         }
      }
      return json
   }
}
