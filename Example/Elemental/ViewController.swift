//
//  ViewController.swift
//  Elemental
//
//  Created by gklei on 05/03/2017.
//  Copyright (c) 2017 gklei. All rights reserved.
//

import UIKit
import Elemental

enum FontWeight: String {
   case xLight = "ExtraLight", light = "Light", medium = "Medium", bold = "Bold", book = "Book", black = "Black"
}

extension UIFont {
   convenience init(_ size: CGFloat, _ weight: FontWeight) {
      self.init(name: "HelveticaNeue-\(weight.rawValue)", size: size)!
   }
}

struct TextStyle: ElementalTextStyling {
   var font: UIFont
   var color: UIColor
   var alignment: NSTextAlignment
   
   init(size: CGFloat, weight: FontWeight, color: UIColor = .black, alignment: NSTextAlignment = .left) {
      self.font = UIFont(size, weight)
      self.color = color
      self.alignment = alignment
   }
}

class TextConfiguration: TextElementConfiguration {
   init(size: CGFloat, weight: FontWeight, alignment: NSTextAlignment = .left, height: CGFloat? = nil) {
      super.init()
      self.textStyle = TextStyle(size: size, weight: weight, alignment: alignment)
      
      if let height = height {
         self.sizeConstraint = ElementalSize(width: .intrinsic, height: .constant(height))
      }
   }
}

class ViewController: ElementalViewController {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .white
   }
   
   override func generateElements() -> [Elemental]? {
      return Element.form([
         .verticalSpace(24),
         .text(configuration: TextConfiguration(size: 50, weight: .light),
               content: "Hello!"),
         .verticalSpace(12),
         .text(configuration: TextConfiguration(size: 24, weight: .medium),
               content: "How are you doing today?")
      ])
   }
}

