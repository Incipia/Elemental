//
//  PlaceholderTextView.swift
//  Elemental
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit

@IBDesignable
open class PlaceholderTextView: UITextView {
   // MARK: - Public Properties
   open let placeholderLabel: UILabel = UILabel()
   
   @IBInspectable open var placeholder: String = "" {
      didSet {
         placeholderLabel.text = placeholder
      }
   }
   
   @IBInspectable open var placeholderColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22) {
      didSet {
         placeholderLabel.textColor = placeholderColor
      }
   }
   
   open var placeholderFont: UIFont? {
      didSet {
         let font = (placeholderFont != nil) ? placeholderFont : self.font
         placeholderLabel.font = font
      }
   }
   
   // MARK: - Private Properties
   private var _placeholderLabelConstraints = [NSLayoutConstraint]()
   
   // MARK: - Init
   required public init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      _commonInit()
   }
   
   // MARK: - Overridden
   override open var font: UIFont! {
      didSet {
         guard placeholderFont == nil else { return }
         placeholderLabel.font = font
      }
   }
   
   override open var textAlignment: NSTextAlignment {
      didSet {
         placeholderLabel.textAlignment = textAlignment
      }
   }
   
   override open var text: String! {
      didSet {
         _textDidChange()
      }
   }
   
   override open var attributedText: NSAttributedString! {
      didSet {
         _textDidChange()
      }
   }
   
   override open var textContainerInset: UIEdgeInsets {
      didSet {
         _updateConstraintsForPlaceholderLabel()
      }
   }
   
   override public init(frame: CGRect, textContainer: NSTextContainer?) {
      super.init(frame: frame, textContainer: textContainer)
      _commonInit()
   }
   
   open override func layoutSubviews() {
      super.layoutSubviews()
      placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
   }
   
   // MARK: - Private
   private func _commonInit() {
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(_textDidChange),
                                             name: NSNotification.Name.UITextViewTextDidChange,
                                             object: nil)
      
      placeholderLabel.font = font
      placeholderLabel.textColor = placeholderColor
      placeholderLabel.textAlignment = textAlignment
      placeholderLabel.text = placeholder
      placeholderLabel.numberOfLines = 0
      placeholderLabel.backgroundColor = .clear
      placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
      addSubview(placeholderLabel)
      _updateConstraintsForPlaceholderLabel()
   }
   
   private func _updateConstraintsForPlaceholderLabel() {
      var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
         options: [],
         metrics: nil,
         views: ["placeholder": placeholderLabel])
      newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
         options: [],
         metrics: nil,
         views: ["placeholder": placeholderLabel])
      newConstraints.append(NSLayoutConstraint(
         item: placeholderLabel,
         attribute: .width,
         relatedBy: .equal,
         toItem: self,
         attribute: .width,
         multiplier: 1.0,
         constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
      ))
      removeConstraints(_placeholderLabelConstraints)
      addConstraints(newConstraints)
      _placeholderLabelConstraints = newConstraints
   }
   
   @objc private func _textDidChange() {
      placeholderLabel.isHidden = !text.isEmpty
   }
}
