//
//  IncFormElemental.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit
import Bindable

public enum IncFormElementInputState {
   case focused, unfocused
   
   // may be temporary
   public var other: IncFormElementInputState {
      switch self {
      case .focused: return .unfocused
      case .unfocused: return .focused
      }
   }
}

// optionally override the target state with the return value
public typealias IncFormElementInputAction = (_ currentState: IncFormElementInputState, _ proposedNextState: IncFormElementInputState?) -> IncFormElementInputState?

// called when the accessory button is pressed
public typealias IncFormElementAccessoryAction = () -> ()

public protocol IncFormSizeDelegate: class {
   func size(for element: IncFormElemental, constrainedWidth width: CGFloat) -> CGSize
}

public protocol IncFormElementLayoutDelegate: class {
   func reloadLayout(for element: IncFormElement, scrollToCenter: Bool)
}

open class IncFormElement: IncFormElemental {
   // MARK: - Public Properties
   open class var defaultCellID: String {
      let classString = NSStringFromClass(self)
      let elements = classString.components(separatedBy: ".")
      assert(elements.count > 0, "Failed extract class name from \(classString)")
      return "\(elements.last!)Cell"
   }
   
   open var cellID: String { return type(of: self).defaultCellID }
   private weak var _containerViewController: UIViewController?
   public private(set) weak var cell: IncFormElementCell?
   
   // MARK: - IncFormElemental Protocol
   open var elementalConfig: IncFormElementalConfiguring
   
   open func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      guard let cell = cell as? IncFormElementCell else { fatalError() }
      self.cell = cell
      _containerViewController = containerViewController
      cell.layoutDelegate = containerViewController as? IncFormElementLayoutDelegate
      cell.configure(with: self)
      if let bindableCell = cell as? IncFormBindableElementCell {
         bindableCell.bind(with: self)
      }
   }
   
   open func reconfigure() {
      guard let cell = cell, cell.element === self else { return }
      configure(cell: cell, in: _containerViewController)
   }
   
   open func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize { fatalError() }
   
   // MARK: - Public Class Methods
   public class func form(_ elements: [IncFormElement]) -> [IncFormElemental] {
      return elements
   }
   
   open func register(collectionView cv: UICollectionView) {
      let nib = UINib(nibName: cellID, bundle: Bundle(for: type(of:self)))
      cv.register(nib, forCellWithReuseIdentifier: cellID)
   }
   
   // MARK: - Init
   public init(configuration: IncFormElementalConfiguring) {
      elementalConfig = configuration
   }
}

public class IncFormText: IncFormElement {
   // MARK: - Public Properties
   public var configuration: IncFormTextConfiguring { return elementalConfig as! IncFormTextConfiguring }
   public var content: String
   
   // MARK: - Init
   public init(configuration: IncFormTextConfiguring, content: String) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormTextCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormIcon: IncFormElement {
   // MARK: - Public Properties
   public var configuration: IncFormIconConfiguring { return elementalConfig as! IncFormIconConfiguring }
   public var content: IncFormElementIconContent
   
   // MARK: - Init
   public init(configuration: IncFormIconConfiguring, content: IncFormElementIconContent) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormIconCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormAccessory: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormAccessoryConfiguring { return elementalConfig as! IncFormAccessoryConfiguring }
   public var content: IncFormElementAccessoryContent
   public var bindings: [Binding]
   public var action: IncFormElementAccessoryAction?
   
   // MARK: - Init
   public init(configuration: IncFormAccessoryConfiguring, content: IncFormElementAccessoryContent, bindings: [Binding] = [], action: IncFormElementAccessoryAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormAccessoryCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormThumbnail: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormAccessoryConfiguring { return elementalConfig as! IncFormAccessoryConfiguring }
   public var content: IncFormElementThumbnailContent
   public var bindings: [Binding]
   public var action: IncFormElementAccessoryAction?
   
   // MARK: - Init
   public init(configuration: IncFormAccessoryConfiguring, content: IncFormElementThumbnailContent, bindings: [Binding] = [], action: IncFormElementAccessoryAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormThumbnailCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormSwitch: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormSwitchConfiguring { return elementalConfig as! IncFormSwitchConfiguring }
   public var content: IncFormElementSwitchContent
   public var bindings: [Binding]
   
   // MARK: - Init
   public init(configuration: IncFormSwitchConfiguring, content: IncFormElementSwitchContent, bindings: [Binding] = []) {
      self.content = content
      self.bindings = bindings
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormSwitchCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormDropdown: IncFormElement {
   // MARK: - Public Properties
   public var configuration: IncFormDropdownConfiguring { return elementalConfig as! IncFormDropdownConfiguring }
   public var content: IncFormElementDropdownContent
   
   // MARK: - Init
   public init(configuration: IncFormDropdownConfiguring, content: IncFormElementDropdownContent) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormDropdownCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public class IncFormPickerSelection: IncFormElement, IncFormBindableElemental {
   public struct Option {
      public let text: String
      public let value: Any
      public var isSelected: Bool
      
      public init(text: String = "", value: Any? = nil, isSelected: Bool = false) {
         self.text = text
         self.value = value ?? text
         self.isSelected = isSelected
      }
      
      public static func option(text: String = "", value: Any? = nil, isSelected: Bool = false) -> Option {
         return Option(text: text, value: value, isSelected: isSelected)
      }
   }
   
   public var configuration: IncFormPickerConfiguring { return elementalConfig as! IncFormPickerConfiguring }
   public var content: IncFormElementPickerContent
   public var bindings: [Binding]
   public var action: IncFormElementInputAction?
   public var inputState: IncFormElementInputState
   
   // MARK: - Init
   public init(configuration: IncFormPickerConfiguring, content: IncFormElementPickerContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      inputState = configuration.inputState
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormPickerSelectionCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormRadioSelection: IncFormElement, IncFormBindableElemental {
   public struct Component {
      let text: String
      let value: Any
      public var on: Bool
      
      public init(text: String = "", value: Any? = nil, on: Bool = false) {
         self.text = text
         self.value = value ?? text
         self.on = on
      }
      
      public static func component(text: String = "", value: Any? = nil, on: Bool = false) -> Component {
         return Component(text: text, value: value, on: on)
      }
   }
   
   // MARK: - Public Properties
   public var configuration: IncFormRadioConfiguring { return elementalConfig as! IncFormRadioConfiguring }
   public var content: IncFormElementRadioContent
   public var bindings: [Binding]
   
   // MARK: - Init
   public init(configuration: IncFormRadioConfiguring, content: IncFormElementRadioContent, bindings: [Binding] = []) {
      self.content = content
      self.bindings = bindings
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormRadioSelectionCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormTextFieldInput: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormTextInputConfiguring { return elementalConfig as! IncFormTextInputConfiguring }
   public var content: IncFormElementTextInputContent
   public var bindings: [Binding]
   public var action: IncFormElementInputAction?
   
   // MARK: - Init
   public init(configuration: IncFormTextInputConfiguring, content: IncFormElementTextInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormTextFieldInputCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormTextViewInput: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormTextInputConfiguring { return elementalConfig as! IncFormTextInputConfiguring }
   public var content: IncFormElementTextInputContent
   public var bindings: [Binding]
   public var action: IncFormElementInputAction?
   
   // MARK: - Init
   public init(configuration: IncFormTextInputConfiguring, content: IncFormElementTextInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormTextViewInputCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormDateInput: IncFormElement, IncFormBindableElemental {
   // MARK: - Public Properties
   public var configuration: IncFormDateInputConfiguring { return elementalConfig as! IncFormDateInputConfiguring }
   public var content: IncFormElementDateInputContent
   public var bindings: [Binding]
   public var action: IncFormElementInputAction?
   public var inputState: IncFormElementInputState
   
   // MARK: - Init
   public init(configuration: IncFormDateInputConfiguring, content: IncFormElementDateInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      inputState = configuration.inputState
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormDateInputCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormHorizontalLine: IncFormElement {
   // MARK: - Public Properties
   public var configuration: IncFormDividingLineConfiguring { return elementalConfig as! IncFormDividingLineConfiguring }
   
   // MARK: - Init
   public init(configuration: IncFormDividingLineConfiguring) {
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormHorizontalLineCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormVerticalSpace: IncFormElement {
   // MARK: - Public Properties
   let value: CGFloat
   override public class var defaultCellID: String { return IncFormHorizontalLine.defaultCellID }
   
   // MARK: - Init
   public init(value: CGFloat) {
      self.value  = value
      super.init(configuration: IncFormElementalConfiguration())
   }
   
   // MARK: - IncFormElemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormHorizontalLineCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormCustomView: IncFormElement {
   // MARK: - Public Properties
   let view : UIView
   
   // MARK: - Init
   public init(view : UIView) {
      self.view  = view
      super.init(configuration: IncFormElementalConfiguration())
   }
   
   // MARK: - IncFormElemental Protocol
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormCustomViewCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormCustomViewController: IncFormElement {
   // MARK: - Public Properties
   public let viewController : UIViewController
   weak var sizeDelegate: IncFormSizeDelegate?
   
   // MARK: - Init
   public init(viewController : UIViewController, sizeDelegate: IncFormSizeDelegate) {
      self.viewController  = viewController
      self.sizeDelegate = sizeDelegate
      super.init(configuration: IncFormElementalConfiguration())
   }
   
   // MARK: - IncFormElemental Protocol
   override public func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      super.configure(cell: cell, in: containerViewController)
      guard let vcCell = cell as? IncFormCustomViewControllerCell else { fatalError() }
      vcCell.containerVC = containerViewController
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormCustomViewControllerCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormHorizontalForm: IncFormElement {
   // MARK: - Public Properties
   let elements : [IncFormElemental]
   
   // MARK: - Init
   public init(elements : [IncFormElemental]) {
      self.elements  = elements
      super.init(configuration: IncFormElementalConfiguration())
   }

   func reloadLayout() {
      guard let cell = cell as? IncFormHorizontalFormCell, cell.element === self else { return }
      cell.reloadLayout()
   }
   
   // MARK: - IncFormElemental Protocol
   override public func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      super.configure(cell: cell, in: containerViewController)
      guard let cell = cell as? IncFormHorizontalFormCell else { fatalError() }
      cell.containerVC = containerViewController
      cell.delegate = containerViewController as? IncFormHorizontalFormCellDelegate
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormHorizontalFormCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public class IncFormHorizontalSpace: IncFormElement {
   // MARK: - Public Properties
   let value: CGFloat
   override public class var defaultCellID: String { return IncFormVerticalLine.defaultCellID }
   
   // MARK: - Init
   public init(value: CGFloat) {
      self.value  = value
      super.init(configuration: IncFormElementalConfiguration())
   }
   
   // MARK: - IncFormElemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormVerticalLineCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IncFormVerticalLine: IncFormElement {
   // MARK: - Public Properties
   public var configuration: IncFormDividingLineConfiguring { return elementalConfig as! IncFormDividingLineConfiguring }
   
   // MARK: - Init
   public init(configuration: IncFormDividingLineConfiguring) {
      super.init(configuration: configuration)
   }
   
   // MARK: - IncFormElemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: IncFormElementDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IncFormVerticalLineCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public extension IncFormElement {
   class func text(configuration: IncFormTextConfiguring, content: String) -> IncFormElement {
      return IncFormText(configuration: configuration, content: content)
   }
   
   class func icon(configuration: IncFormIconConfiguring, content: IncFormElementIconContent) -> IncFormElement {
      return IncFormIcon(configuration: configuration, content: content)
   }
   
   class func accessory(configuration: IncFormAccessoryConfiguring, content: IncFormElementAccessoryContent, bindings: [Binding] = [], action: IncFormElementAccessoryAction? = nil) -> IncFormElement {
      return IncFormAccessory(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func thumbnail(configuration: IncFormAccessoryConfiguring, content: IncFormElementThumbnailContent, bindings: [Binding] = [], action: IncFormElementAccessoryAction? = nil) -> IncFormElement {
      return IncFormThumbnail(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func `switch`(configuration: IncFormSwitchConfiguring, content: IncFormElementSwitchContent, bindings: [Binding] = []) -> IncFormElement {
      return IncFormSwitch(configuration: configuration, content: content, bindings: bindings)
   }
   
   class func dropdown(configuration: IncFormDropdownConfiguring, content: IncFormElementDropdownContent) -> IncFormElement {
      return IncFormDropdown(configuration: configuration, content: content)
   }
   
   class func picker(configuration: IncFormPickerConfiguring, content: IncFormElementPickerContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) -> IncFormElement {
      return IncFormPickerSelection(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func radioSelection(configuration: IncFormRadioConfiguring, content: IncFormElementRadioContent, bindings: [Binding] = []) -> IncFormElement {
      return IncFormRadioSelection(configuration: configuration, content: content, bindings: bindings)
   }
   
   class func textFieldInput(configuration: IncFormTextInputConfiguring, content: IncFormElementTextInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) -> IncFormElement {
      return IncFormTextFieldInput(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func textViewInput(configuration: IncFormTextInputConfiguring, content: IncFormElementTextInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) -> IncFormElement {
      return IncFormTextViewInput(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func dateInput(configuration: IncFormDateInputConfiguring, content: IncFormElementDateInputContent, bindings: [Binding] = [], action: IncFormElementInputAction? = nil) -> IncFormElement {
      return IncFormDateInput(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func horizontalLine(configuration: IncFormDividingLineConfiguring) -> IncFormElement {
      return IncFormHorizontalLine(configuration: configuration)
   }
   
   class func verticalSpace(_ value: CGFloat) -> IncFormElement {
      return IncFormVerticalSpace(value: value)
   }
   
   class func view(_ view: UIView) -> IncFormElement {
      return IncFormCustomView(view: view)
   }
   
   class func viewController(_ viewController: UIViewController, sizeDelegate: IncFormSizeDelegate) -> IncFormElement {
      return IncFormCustomViewController(viewController: viewController, sizeDelegate: sizeDelegate)
   }
   
   class func horizontalForm(elements: [IncFormElemental]) -> IncFormElement {
      return IncFormHorizontalForm(elements: elements)
   }
   
   class func horizontalSpace(_ value: CGFloat) -> IncFormElement {
      return IncFormHorizontalSpace(value: value)
   }
   
   class func verticalLine(configuration: IncFormDividingLineConfiguring) -> IncFormElement {
      return IncFormVerticalLine(configuration: configuration)
   }
}

extension IncFormViewController: IncFormHorizontalFormCellDelegate {
   func componentSelected(_ component: IncFormElemental, in cell: IncFormHorizontalFormCell) {
      formDelegate?.elementSelected(component, in: self)
   }
}

extension IncFormViewController: IncFormElementLayoutDelegate {
   public func reloadLayout(for element: IncFormElement, scrollToCenter: Bool) {
      setNeedsLayout()
      DispatchQueue.main.async {
         self.scroll(to: element, position: .centeredVertically, animated: true)
      }
   }
}
