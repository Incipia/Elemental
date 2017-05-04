//
//  RadioView.swift
//  Pods
//
//  Created by Leif Meyer on 5/3/17.
//
//

import UIKit

extension UIView {
   public func addAndFill(subview: UIView) {
      addSubview(subview)
      subview.translatesAutoresizingMaskIntoConstraints = false
      subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
      subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
      subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
   }
}

extension String {
   func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
      let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
      let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
      
      return boundingBox.height
   }
}

protocol RadioViewDelegate: class {
   func radioView(_ view: RadioView, didToggleTo on: Bool)
}

class RadioView: UIView {
   override var tintColor: UIColor! {
      didSet {
         let fillLayerColor: UIColor = fillColor ?? tintColor
         _fillLayer.backgroundColor = on ? fillLayerColor.cgColor : UIColor.clear.cgColor
         layer.borderColor = tintColor.cgColor
      }
   }
   
   var fillColor: UIColor?
   
   var on: Bool = false {
      didSet {
         let fillLayerColor: UIColor = fillColor ?? tintColor
         _fillLayer.backgroundColor = on ? fillLayerColor.cgColor : UIColor.clear.cgColor
      }
   }
   
   weak var delegate: RadioViewDelegate?
   private let _fillLayer = CALayer()
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      _commonInit()
   }
   
   init(delegate: RadioViewDelegate? = nil) {
      super.init(frame: .zero)
      _commonInit()
      self.delegate = delegate
   }
   
   private func _commonInit() {
      layer.borderColor = tintColor.cgColor
      layer.borderWidth = 1.5
      
      let toggleButton = UIButton()
      addAndFill(subview: toggleButton)
      
      toggleButton.addTarget(self, action: #selector(RadioView.toggle), for: .touchDown)
      layer.addSublayer(_fillLayer)
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
      _fillLayer.frame = bounds.insetBy(dx: 3.5, dy: 3.5)
      _fillLayer.cornerRadius = min(_fillLayer.frame.width, _fillLayer.frame.height) * 0.5
   }
   
   func toggle() {
      on = !on
      delegate?.radioView(self, didToggleTo: on)
   }
}
