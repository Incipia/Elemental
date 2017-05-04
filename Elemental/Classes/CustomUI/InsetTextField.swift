//
//  InsetTextField.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/13/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      _commonInit()
   }
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      _commonInit()
   }
   
   convenience init() {
      self.init(frame: .zero)
      _commonInit()
   }
   
   private func _commonInit() {
      backgroundColor = UIColor.gray.withAlphaComponent(0.1)
   }
   
   override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: 14, dy: 0)
   }
   
   override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: 14, dy: 0)
   }
}
