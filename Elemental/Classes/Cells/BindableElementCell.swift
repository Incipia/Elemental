//
//  BindableElementCell.swift
//  GigSalad
//
//  Created by Leif Meyer on 3/6/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit
import Bindable

public enum BindableElementKey: String, IncKVKeyType {
   case name
   case detail
   case placeholder
   case text
   case `switch`
   case image
   case anyValue
   case isEnabled
   case doubleValue
   case intValue
}

class BindableElementCell: ElementCell, Bindable {
   var bindingBlocks: [BindableElementKey : [((targetObject: AnyObject, rawTargetKey: String)?, Any?) throws -> Bool?]] = [:]
   var keysBeingSet: [BindableElementKey] = []

   var bindings: [Binding] = []
   private var _bound: Bool = false
   
   private func _updateBindings(bound: Bool) {
      guard bound != _bound else { return }
      if (bound) {
         bindings.forEach {
            try! bind($0)
         }
      } else {
         bindings.forEach {
            unbind($0)
         }
      }
      _bound = bound
   }
   
   func value(for key: BindableElementKey) -> Any? { return nil }
   func setOwn(value: Any?, for key: BindableElementKey) throws { fatalError("\(type(of: self)) subclasses must override \(#function)") }

   func bind(with component: Elemental) {
      guard let element = component as? BindableElemental else { fatalError() }
      _updateBindings(bound: false)
      self.bindings = element.bindings
      _updateBindings(bound: self.window != nil)
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      _updateBindings(bound: false)
   }
   
   override func prepareForReuse() {
      _updateBindings(bound: false)
      super.prepareForReuse()
   }

   override func willMove(toWindow newWindow: UIWindow?) {
      _updateBindings(bound: newWindow != nil)
   }
}

