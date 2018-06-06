//
//  RadioSelectionElementCell.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

class RadioSelectionElementCell: BindableElementCell {
   @IBOutlet private var _label: UILabel!
   
   typealias RadioOption = (view: RadioView, value: Any, dataValue: Data)
   var addedViews: [UIView] = []
   var radioOptions: [RadioOption] = []
   var selectedValue: Any? {
      get { return value(for: .anyValue) }
      set { try! setAsBindable(value: newValue, for: .anyValue) }
   }
   
   fileprivate let _tapRecognizer = UITapGestureRecognizer()
   fileprivate var _leftCollapsableRadioConstraints: [NSLayoutConstraint] = []
   fileprivate var _rightCollapsableRadioConstraints: [NSLayoutConstraint] = []
   
   fileprivate var _labelLeadingConstraints: [NSLayoutConstraint] = []
   fileprivate var _labelTrailingConstraints: [NSLayoutConstraint] = []
   
   override func awakeFromNib() {
      super.awakeFromNib()
      _tapRecognizer.addTarget(self, action: #selector(RadioSelectionElementCell.contentViewTapped(recognizer:)))
      contentView.addGestureRecognizer(_tapRecognizer)
   }
   
   override func configure(with component: Elemental) {
      super.configure(with: component)
      guard let element = component as? RadioSelectionElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      _label.text = content.name
      _label.textColor = style.nameStyle.color
      _label.font = style.nameStyle.font
      
      addedViews.forEach { $0.removeFromSuperview() }
      addedViews = []
      radioOptions = []
      
      _labelLeadingConstraints = []
      _labelTrailingConstraints = []
      _leftCollapsableRadioConstraints = []
      _rightCollapsableRadioConstraints = []
      
      var lastBottomAnchor = _label.bottomAnchor
      var verticalPadding: CGFloat = content.name != nil ? style.componentSpacing : 1.5
      for component in content.components {
         let leftRadioView = RadioView(delegate: self)
         leftRadioView.tintColor = style.componentStyle.color
         leftRadioView.fillColor = style.fillColor
         
         leftRadioView.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(leftRadioView)
         
         let leftRadioWidthConstraint = leftRadioView.widthAnchor.constraint(equalToConstant: 16)
         leftRadioWidthConstraint.isActive = true
         _leftCollapsableRadioConstraints.append(leftRadioWidthConstraint)
         
         leftRadioView.heightAnchor.constraint(equalToConstant: 16).isActive = true
         leftRadioView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
         
         let rightRadioView = RadioView(delegate: self)
         rightRadioView.tintColor = style.componentStyle.color
         rightRadioView.fillColor = style.fillColor
         
         rightRadioView.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(rightRadioView)
         
         let rightRadioWidthConstraint = rightRadioView.widthAnchor.constraint(equalToConstant: 16)
         rightRadioWidthConstraint.isActive = true
         _rightCollapsableRadioConstraints.append(rightRadioWidthConstraint)
         
         rightRadioView.heightAnchor.constraint(equalToConstant: 16).isActive = true
         rightRadioView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
         
         let label = UILabel()
         label.font = style.componentStyle.font
         label.textColor = style.componentStyle.color
         label.text = component.text
         label.translatesAutoresizingMaskIntoConstraints = false
         contentView.addSubview(label)
         
         let leadingConstraint = label.leadingAnchor.constraint(equalTo: leftRadioView.trailingAnchor, constant: 12)
         leadingConstraint.isActive = true
         _labelLeadingConstraints.append(leadingConstraint)
            
         let trailingConstraint = label.trailingAnchor.constraint(equalTo: rightRadioView.leadingAnchor, constant: -12)
         trailingConstraint.isActive = true
         _labelTrailingConstraints.append(trailingConstraint)
         
         label.topAnchor.constraint(equalTo: lastBottomAnchor, constant: verticalPadding).isActive = true
         
         leftRadioView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: -2).isActive = true
         rightRadioView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: -2).isActive = true
         lastBottomAnchor = label.bottomAnchor
         verticalPadding = style.componentSpacing
         
         addedViews.append(label)
         addedViews.append(rightRadioView)
         addedViews.append(leftRadioView)
         
         switch style.alignment {
         case .left: radioOptions.append((view: leftRadioView, value: component.value, dataValue: ElementCell.dataValue(component.value)))
         case .right: radioOptions.append((view: rightRadioView, value: component.value, dataValue: ElementCell.dataValue(component.value)))
         }
         rightRadioView.isUserInteractionEnabled = false
         leftRadioView.isUserInteractionEnabled = false
      }
      
      _collapseRadioViews(for: element.configuration.alignment)
   }
   
   private func _collapseRadioViews(for alignment: RadioElementAlignment) {
      switch alignment {
      case .right:
         _leftCollapsableRadioConstraints.forEach { $0.constant = 0 }
         _rightCollapsableRadioConstraints.forEach { $0.constant = 16 }
         _labelLeadingConstraints.forEach { $0.constant = 0 }
         _labelTrailingConstraints.forEach { $0.constant = -12 }
      case .left:
         _leftCollapsableRadioConstraints.forEach { $0.constant = 16 }
         _rightCollapsableRadioConstraints.forEach { $0.constant = 0 }
         _labelLeadingConstraints.forEach { $0.constant = 12 }
         _labelTrailingConstraints.forEach { $0.constant = 0 }
      }
   }
   
   override class func intrinsicContentSize(for element: Elemental, constrainedSize size: CGSize) -> CGSize {
      let width = size.width
      guard let element = element as? RadioSelectionElement else { fatalError() }
      let content = element.content
      let style = element.configuration
      var totalComponentsHeight: CGFloat = 0
      for component in content.components {
         let textHeight = component.text.heightWithConstrainedWidth(width: width - 16, font: style.componentStyle.font)
         totalComponentsHeight += textHeight
         totalComponentsHeight += style.componentSpacing
      }
      totalComponentsHeight -= style.componentSpacing
      let nameHeight: CGFloat = content.name?.heightWithConstrainedWidth(width: width, font: style.nameStyle.font) ?? 0.0
      let namePadding: CGFloat = content.name != nil ? style.componentSpacing : 1.5
      return CGSize(width: width, height: max(totalComponentsHeight, 0) + nameHeight + namePadding)
   }
   
   override func value(for key: BindableElementKey) -> Any? {
      switch key {
      case .text: return _label.text
      case .anyValue:
         return radioOptions.filter { $0.view.on }.first?.value
      default: fatalError("\(type(of: self)) cannot retrieve value for \(key))")
      }
   }
   
   override func setOwn(value: inout Any?, for key: BindableElementKey) throws {
      switch key {
      case .text:
         guard let validValue = value as? String else { throw key.kvTypeError(value: value) }
         _label.text = validValue
      case .anyValue:
         if let validValue = value {
            let jsonData = ElementCell.dataValue(validValue)
            radioOptions.forEach { $0.view.on = $0.dataValue == jsonData }
         } else {
            radioOptions.forEach { $0.view.on = false }
         }
      default: fatalError("\(type(of: self)) cannot set value for \(key))")
      }
   }
   
   override func prepareForReuse() {
      addedViews.forEach { $0.removeFromSuperview() }
      addedViews = []
      radioOptions = []
      
      _labelLeadingConstraints = []
      _labelTrailingConstraints = []
      _leftCollapsableRadioConstraints = []
      _rightCollapsableRadioConstraints = []
      super.prepareForReuse()
   }
   
   @objc internal func contentViewTapped(recognizer: UITapGestureRecognizer) {
      let location = recognizer.location(in: contentView)
      guard location.y > _label.frame.maxY else {
         print("tap (\(location) is above label max y: (\(_label.frame))")
         return
      }
      
      if let closest = _closestRadioView(for: location), !closest.on {
         closest.toggle()
      }
   }
   
   private func _closestRadioView(for point: CGPoint) -> RadioView? {
      guard !radioOptions.isEmpty else { return nil }
      return radioOptions.reduce(radioOptions[0].view) { (currentResult, radioOption) -> RadioView in
         return currentResult.frame.distance(to: point) <= radioOption.view.frame.distance(to: point) ? currentResult : radioOption.view
      }
   }
}

extension RadioSelectionElementCell: RadioViewDelegate {
   func radioView(_ view: RadioView, didToggleTo on: Bool) {
      if on {
         radioOptions.forEach {
            if $0.view == view {
               selectedValue = $0.value
            } else {
               $0.view.on = false
            }
         }
      } else {
         radioOptions.forEach { $0.view.on = false }
         selectedValue = nil
      }
   }
}
