//
//  KVStringCompliance.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/3/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import Foundation

enum KVStringError: Error {
   case invalidKey(key: String)
}

protocol KVStringCompliance {
   func value(for key: String) -> Any?
   mutating func set(value: Any?, for key: String) throws
}

extension KVCompliance {
   func value(for key: String) -> Any? {
      guard let key = try? Key(keyString: key) else { return nil }
      return value(for: key)
   }
   
   mutating func set(value: Any?, for key: String) throws {
      let key = try Key(keyString: key)
      try set(value: value, for: key)
   }
}

extension KVKeyType {
   init(keyString: String) throws {
      guard let key = Self.init(rawValue: keyString) else { throw KVStringError.invalidKey(key: "\(Self.self).\(keyString)") }
      self = key
   }
}
