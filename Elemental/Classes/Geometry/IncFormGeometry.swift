//
//  IncFormGeometry.swift
//  Elemental
//
//  Created by Leif Meyer on 5/3/17.
//
//

import Foundation

extension CGRect {
   func distance(to point: CGPoint) -> CGFloat {
      var closestPoint: CGPoint = .zero
      switch point.x {
      case let x where x < minX: closestPoint.x = minX
      case let x where x > maxX: closestPoint.x = maxX
      default: closestPoint.x = point.x
      }
      switch point.y {
      case let y where y < minY: closestPoint.y = minY
      case let y where y > maxY: closestPoint.y = maxY
      default: closestPoint.y = point.y
      }
      return closestPoint.distance(to: point)
   }
}

extension CGPoint {
   func distance(to point: CGPoint) -> CGFloat {
      let difference = self - point
      return sqrt(difference.x * difference.x + difference.y * difference.y)
   }
   
   static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
      return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
   }
}
