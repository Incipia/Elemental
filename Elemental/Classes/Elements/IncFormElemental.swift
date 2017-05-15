//
//  Elemental.swift
//  GigSalad
//
//  Created by Gregory Klein on 4/14/17.
//  Copyright © 2017 Incipia. All rights reserved.
//

import UIKit
import Bindable

public enum ElementalDimension {
   case horizontal(CGFloat)
   case vertical(CGFloat)
}

public protocol Elemental {
   var cellID: String { get }
   var elementalConfig: ElementalConfiguring { get }
   
   func register(collectionView cv: UICollectionView)
   func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?)
   func reconfigure(cell: UICollectionViewCell, for element: Elemental, in containerViewController: UIViewController?)
   func size(forConstrainedDimension dimension: ElementalDimension) -> CGSize
}

public extension Elemental {
   var cellID: String { return String(describing: Self.self) }
   var elementalConfig: ElementalConfiguring { return ElementalConfiguration() }
   
   static func register(collectionView cv: UICollectionView) {}
   func configure(cell: UICollectionViewCell, in containerViewController: UIViewController?) {}
   func reconfigure(cell: UICollectionViewCell, for element: Elemental, in containerViewController: UIViewController?) {}
}

protocol BindableElemental: Elemental {
   var bindings: [Binding] { get }
}

