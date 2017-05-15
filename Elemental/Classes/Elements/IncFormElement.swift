//
//  Elemental.swift
//  GigSalad
//
//  Created by Gregory Klein on 2/23/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit
import Bindable

public enum InputElementState {
   case focused, unfocused
   
   // may be temporary
   public var other: InputElementState {
      switch self {
      case .focused: return .unfocused
      case .unfocused: return .focused
      }
   }
}

// optionally override the target state with the return value
public typealias InputElementAction = (_ currentState: InputElementState, _ proposedNextState: InputElementState?) -> InputElementState?

// called when the accessory button is pressed
public typealias AccessoryElementAction = () -> ()

public protocol ElementalSizeDelegate: class {
   func size(for element: Elemental, constrainedWidth width: CGFloat) -> CGSize
}

public protocol ElementalLayoutDelegate: class {
   func reloadLayout(for element: Elemental, animated: Bool, scrollToCenter: Bool)
}

open class Element: Elemental {
   // MARK: - Public Properties
   open class var defaultCellID: String {
      let classString = NSStringFromClass(self)
      let elements = classString.components(separatedBy: ".")
      assert(elements.count > 0, "Failed extract class name from \(classString)")
      return "\(elements.last!)Cell"
   }
   
   open var cellID: String { return type(of: self).defaultCellID }
   private weak var _containerViewController: UIViewController?
   public private(set) weak var cell: ElementCell?
   
   // MARK: - Elemental Protocol
   open var elementalConfig: ElementalConfiguring
   
   open func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      guard let cell = cell as? ElementCell else { fatalError() }
      self.cell = cell
      _containerViewController = containerViewController
      cell.layoutDelegate = containerViewController as? ElementalLayoutDelegate
      cell.configure(with: self)
      if let bindableCell = cell as? BindableElementCell {
         bindableCell.bind(with: self)
      }
   }
   
   open func reconfigure() {
      guard let cell = cell, cell.element === self else { return }
      configure(cell: cell, in: _containerViewController)
   }
   
   open func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize { fatalError() }
   
   // MARK: - Public Class Methods
   public class func form(_ elements: [Element]) -> [Elemental] {
      return elements
   }
   
   open func register(collectionView cv: UICollectionView) {
      let nib = UINib(nibName: cellID, bundle: Bundle(for: type(of:self)))
      cv.register(nib, forCellWithReuseIdentifier: cellID)
   }
   
   // MARK: - Init
   public init(configuration: ElementalConfiguring) {
      elementalConfig = configuration
   }
}

public class TextElement: Element {
   // MARK: - Public Properties
   public var configuration: TextElementConfiguring { return elementalConfig as! TextElementConfiguring }
   public var content: String
   
   // MARK: - Init
   public init(configuration: TextElementConfiguring, content: String) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return TextElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class IconElement: Element {
   // MARK: - Public Properties
   public var configuration: IconElementConfiguring { return elementalConfig as! IconElementConfiguring }
   public var content: IconElementContent
   
   // MARK: - Init
   public init(configuration: IconElementConfiguring, content: IconElementContent) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return IconElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class AccessoryElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: AccessoryElementConfiguring { return elementalConfig as! AccessoryElementConfiguring }
   public var content: AccessoryElementContent
   public var bindings: [Binding]
   public var action: AccessoryElementAction?
   
   // MARK: - Init
   public init(configuration: AccessoryElementConfiguring, content: AccessoryElementContent, bindings: [Binding] = [], action: AccessoryElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return AccessoryElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class ThumbnailElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: AccessoryElementConfiguring { return elementalConfig as! AccessoryElementConfiguring }
   public var content: ThumbnailElementContent
   public var bindings: [Binding]
   public var action: AccessoryElementAction?
   
   // MARK: - Init
   public init(configuration: AccessoryElementConfiguring, content: ThumbnailElementContent, bindings: [Binding] = [], action: AccessoryElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return ThumbnailElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class SwitchElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: SwitchElementConfiguring { return elementalConfig as! SwitchElementConfiguring }
   public var content: SwitchElementContent
   public var bindings: [Binding]
   
   // MARK: - Init
   public init(configuration: SwitchElementConfiguring, content: SwitchElementContent, bindings: [Binding] = []) {
      self.content = content
      self.bindings = bindings
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return SwitchElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class DropdownElement: Element {
   // MARK: - Public Properties
   public var configuration: DropdownElementConfiguring { return elementalConfig as! DropdownElementConfiguring }
   public var content: DropdownElementContent
   
   // MARK: - Init
   public init(configuration: DropdownElementConfiguring, content: DropdownElementContent) {
      self.content = content
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return DropdownElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public class PickerSelectionElement: Element, BindableElemental {
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
   
   public var configuration: PickerElementConfiguring { return elementalConfig as! PickerElementConfiguring }
   public var content: PickerSelectionElementContent
   public var bindings: [Binding]
   public var action: InputElementAction?
   public var inputState: InputElementState
   
   // MARK: - Init
   public init(configuration: PickerElementConfiguring, content: PickerSelectionElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      inputState = configuration.inputState
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return PickerSelectionElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class RadioSelectionElement: Element, BindableElemental {
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
   public var configuration: RadioElementConfiguring { return elementalConfig as! RadioElementConfiguring }
   public var content: RadioElementContent
   public var bindings: [Binding]
   
   // MARK: - Init
   public init(configuration: RadioElementConfiguring, content: RadioElementContent, bindings: [Binding] = []) {
      self.content = content
      self.bindings = bindings
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return RadioSelectionElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class TextFieldInputElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: TextInputElementConfiguring { return elementalConfig as! TextInputElementConfiguring }
   public var content: TextInputElementContent
   public var bindings: [Binding]
   public var action: InputElementAction?
   
   // MARK: - Init
   public init(configuration: TextInputElementConfiguring, content: TextInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return TextFieldInputElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class TextViewInputElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: TextInputElementConfiguring { return elementalConfig as! TextInputElementConfiguring }
   public var content: TextInputElementContent
   public var bindings: [Binding]
   public var action: InputElementAction?
   
   // MARK: - Init
   public init(configuration: TextInputElementConfiguring, content: TextInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return TextViewInputElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class DateInputElement: Element, BindableElemental {
   // MARK: - Public Properties
   public var configuration: DateInputElementConfiguring { return elementalConfig as! DateInputElementConfiguring }
   public var content: DateInputElementContent
   public var bindings: [Binding]
   public var action: InputElementAction?
   public var inputState: InputElementState
   
   // MARK: - Init
   public init(configuration: DateInputElementConfiguring, content: DateInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) {
      self.content = content
      self.bindings = bindings
      self.action = action
      inputState = configuration.inputState
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return DateInputElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class HorizontalLineElement: Element {
   // MARK: - Public Properties
   public var configuration: LineElementConfiguring { return elementalConfig as! LineElementConfiguring }
   
   // MARK: - Init
   public init(configuration: LineElementConfiguring) {
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return HorizontalLineElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class VerticalSpaceElement: Element {
   // MARK: - Public Properties
   let value: CGFloat
   override public class var defaultCellID: String { return HorizontalLineElement.defaultCellID }
   
   // MARK: - Init
   public init(value: CGFloat) {
      self.value  = value
      super.init(configuration: ElementalConfiguration())
   }
   
   // MARK: - Elemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return HorizontalLineElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class CustomViewElement: Element {
   // MARK: - Public Properties
   let view : UIView
   
   // MARK: - Init
   public init(view: UIView) {
      self.view  = view
      super.init(configuration: ElementalConfiguration())
   }
   
   // MARK: - Elemental Protocol
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return CustomViewElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class CustomViewControllerElement: Element {
   // MARK: - Public Properties
   public let viewController : UIViewController
   weak var sizeDelegate: ElementalSizeDelegate?
   
   // MARK: - Init
   public init(viewController : UIViewController, sizeDelegate: ElementalSizeDelegate) {
      self.viewController  = viewController
      self.sizeDelegate = sizeDelegate
      super.init(configuration: ElementalConfiguration())
   }
   
   // MARK: - Elemental Protocol
   override public func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      super.configure(cell: cell, in: containerViewController)
      guard let vcCell = cell as? CustomViewControllerElementCell else { fatalError() }
      vcCell.containerVC = containerViewController
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return CustomViewControllerElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class HorizontalFormElement: Element {
   // MARK: - Public Properties
   let elements : [Elemental]
   
   // MARK: - Init
   public init(elements : [Elemental]) {
      self.elements  = elements
      super.init(configuration: ElementalConfiguration())
   }

   func reloadLayout() {
      guard let cell = cell as? HorizontalFormElementCell, cell.element === self else { return }
      cell.reloadLayout()
   }
   
   // MARK: - Elemental Protocol
   override public func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {
      super.configure(cell: cell, in: containerViewController)
      guard let cell = cell as? HorizontalFormElementCell else { fatalError() }
      cell.containerVC = containerViewController
      cell.delegate = containerViewController as? HorizontalFormElementCellDelegate
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return HorizontalFormElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public class HorizontalSpaceElement: Element {
   // MARK: - Public Properties
   let value: CGFloat
   override public class var defaultCellID: String { return VerticalLineElement.defaultCellID }
   
   // MARK: - Init
   public init(value: CGFloat) {
      self.value  = value
      super.init(configuration: ElementalConfiguration())
   }
   
   // MARK: - Elemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return VerticalLineElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}


public class VerticalLineElement: Element {
   // MARK: - Public Properties
   public var configuration: LineElementConfiguring { return elementalConfig as! LineElementConfiguring }
   
   // MARK: - Init
   public init(configuration: LineElementConfiguring) {
      super.init(configuration: configuration)
   }
   
   // MARK: - Elemental Protocol
   public var isSelectable: Bool {
      return false
   }
   
   override public func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize {
      switch dimension {
      case .horizontal(let width): return VerticalLineElementCell.contentSize(for: self, constrainedWidth: width)
      case .vertical: fatalError("\(type(of: self)) does not support \(dimension) constraint")
      }
   }
}

public extension Element {
   class func text(configuration: TextElementConfiguring, content: String) -> Element {
      return TextElement(configuration: configuration, content: content)
   }
   
   class func icon(configuration: IconElementConfiguring, content: IconElementContent) -> Element {
      return IconElement(configuration: configuration, content: content)
   }
   
   class func accessory(configuration: AccessoryElementConfiguring, content: AccessoryElementContent, bindings: [Binding] = [], action: AccessoryElementAction? = nil) -> Element {
      return AccessoryElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func thumbnail(configuration: AccessoryElementConfiguring, content: ThumbnailElementContent, bindings: [Binding] = [], action: AccessoryElementAction? = nil) -> Element {
      return ThumbnailElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func `switch`(configuration: SwitchElementConfiguring, content: SwitchElementContent, bindings: [Binding] = []) -> Element {
      return SwitchElement(configuration: configuration, content: content, bindings: bindings)
   }
   
   class func dropdown(configuration: DropdownElementConfiguring, content: DropdownElementContent) -> Element {
      return DropdownElement(configuration: configuration, content: content)
   }
   
   class func picker(configuration: PickerElementConfiguring, content: PickerSelectionElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) -> Element {
      return PickerSelectionElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func radioSelection(configuration: RadioElementConfiguring, content: RadioElementContent, bindings: [Binding] = []) -> Element {
      return RadioSelectionElement(configuration: configuration, content: content, bindings: bindings)
   }
   
   class func textFieldInput(configuration: TextInputElementConfiguring, content: TextInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) -> Element {
      return TextFieldInputElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func textViewInput(configuration: TextInputElementConfiguring, content: TextInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) -> Element {
      return TextViewInputElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func dateInput(configuration: DateInputElementConfiguring, content: DateInputElementContent, bindings: [Binding] = [], action: InputElementAction? = nil) -> Element {
      return DateInputElement(configuration: configuration, content: content, bindings: bindings, action: action)
   }
   
   class func horizontalLine(configuration: LineElementConfiguring) -> Element {
      return HorizontalLineElement(configuration: configuration)
   }
   
   class func verticalSpace(_ value: CGFloat) -> Element {
      return VerticalSpaceElement(value: value)
   }
   
   class func view(_ view: UIView) -> Element {
      return CustomViewElement(view: view)
   }
   
   class func viewController(_ viewController: UIViewController, sizeDelegate: ElementalSizeDelegate) -> Element {
      return CustomViewControllerElement(viewController: viewController, sizeDelegate: sizeDelegate)
   }
   
   class func horizontalForm(elements: [Elemental]) -> Element {
      return HorizontalFormElement(elements: elements)
   }
   
   class func horizontalSpace(_ value: CGFloat) -> Element {
      return HorizontalSpaceElement(value: value)
   }
   
   class func verticalLine(configuration: LineElementConfiguring) -> Element {
      return VerticalLineElement(configuration: configuration)
   }
}

extension ElementalViewController: HorizontalFormElementCellDelegate {
   func componentSelected(_ component: Elemental, in cell: HorizontalFormElementCell) {
      formDelegate?.elementSelected(component, in: self)
   }
}

extension ElementalViewController: ElementalLayoutDelegate {
   public func reloadLayout(for element: Elemental, animated: Bool = true,  scrollToCenter: Bool = true) {
      setNeedsLayout(animated: animated)
      guard scrollToCenter else { return }
      DispatchQueue.main.async {
         self.scroll(to: element, position: .centeredVertically, animated: true)
      }
   }
}
