//
//  GridHelper.swift
//  Snake
//
//  Created by Adnan Zahid on 24/05/2020.
//  Copyright © 2020 Snake. All rights reserved.
//

import Foundation

class GridHelper {
  private enum SignedSides {
    case positiveBase
    case positivePerpendicular
    case negativeBase
    case negativePerpendicular
  }

  private static var orthogonalAngleOffsetMap: [DirectionRelativeToGrid: [SignedSides: [SignedSides: Float]]]
                      = [.right: [.positiveBase: [.positivePerpendicular: 0,
                                                  .negativePerpendicular: 0],
                                  .negativeBase: [.positivePerpendicular: 90,
                                                  .negativePerpendicular: 90]],
                         .up: [.positiveBase: [.positivePerpendicular: 90,
                                               .negativePerpendicular: 0],
                               .negativeBase: [.positivePerpendicular: 90,
                                               .negativePerpendicular: 0]],
                         .left: [.positiveBase: [.positivePerpendicular: 90,
                                                 .negativePerpendicular: 90],
                                 .negativeBase: [.positivePerpendicular: 0,
                                                 .negativePerpendicular: 0]],
                         .down: [.positiveBase: [.positivePerpendicular: 0,
                                                 .negativePerpendicular: 90],
                                 .negativeBase: [.positivePerpendicular: 0,
                                                 .negativePerpendicular: 90]]]

  static func isLeftBlocked(snake: Snake, grid: [[GridNode]]) -> Bool {
    let x = snake.getX()
    let y = snake.getY()
    var occupant: GridNodeOccupant?
    switch snake.getDirection() {
    case .up:
      occupant = grid[safe: x - 1]?[safe: y]?.getOccupant()
    case .down:
      occupant = grid[safe: x + 1]?[safe: y]?.getOccupant()
    case .left:
      occupant = grid[safe: x]?[safe: y - 1]?.getOccupant()
    case .right:
      occupant = grid[safe: x]?[safe: y + 1]?.getOccupant()
    }
    return decideIfBlocked(occupant: occupant)
  }

  static func isFrontBlocked(snake: Snake, grid: [[GridNode]]) -> Bool {
    let x = snake.getX()
    let y = snake.getY()
    var occupant: GridNodeOccupant?
    switch snake.getDirection() {
    case .up:
      occupant = grid[safe: x]?[safe: y + 1]?.getOccupant()
    case .down:
      occupant = grid[safe: x]?[safe: y - 1]?.getOccupant()
    case .left:
      occupant = grid[safe: x - 1]?[safe: y]?.getOccupant()
    case .right:
      occupant = grid[safe: x + 1]?[safe: y]?.getOccupant()
    }
    return decideIfBlocked(occupant: occupant)
  }

  static func isRightBlocked(snake: Snake, grid: [[GridNode]]) -> Bool {
    let x = snake.getX()
    let y = snake.getY()
    var occupant: GridNodeOccupant?
    switch snake.getDirection() {
    case .up:
      occupant = grid[safe: x + 1]?[safe: y]?.getOccupant()
    case .down:
      occupant = grid[safe: x - 1]?[safe: y]?.getOccupant()
    case .left:
      occupant = grid[safe: x]?[safe: y + 1]?.getOccupant()
    case .right:
      occupant = grid[safe: x]?[safe: y - 1]?.getOccupant()
    }
    return decideIfBlocked(occupant: occupant)
  }

  static func isSnakeStuck(snake: Snake, grid: [[GridNode]]) -> Bool {
    let x = snake.getX()
    let y = snake.getY()
    guard let stuckCount = grid[safe: x]?[safe: y]?.getStuckCount() else { return true }
    return stuckCount > 5
  }

  static func foodNode(grid: [[GridNode]]) -> GridNode? {
    return grid.flatMap({ $0 }).first(where: { $0.getOccupant() == .food })
  }

  static func distanceFromFood(snake: Snake, grid: [[GridNode]]) -> Float {
    guard let foodNode = foodNode(grid: grid) else { return Float.infinity }
    let snakeX = snake.getX()
    let snakeY = snake.getY()
    let (foodX, foodY) = foodNode.getPosition()
    return Float(distance(CGPoint(x: snakeX, y: snakeY), CGPoint(x: foodX, y: foodY)))
  }

  static func didConsumeFood(snake: Snake, grid: [[GridNode]]) -> Bool {
    return distanceFromFood(snake: snake, grid: grid) == 0
  }

  static func orthogonalAngleToFood(snake: Snake, grid: [[GridNode]]) -> Float {
    guard let foodNode = foodNode(grid: grid) else { return 0 }
    let snakeX = snake.getX()
    let snakeY = snake.getY()
    let (foodX, foodY) = foodNode.getPosition()
    var degrees = angle(between: CGPoint(x: snakeX, y: snakeY),
                        ending: CGPoint(x: foodX, y: foodY))
    let signedBase: SignedSides = (foodX - snakeX) > 0 ? .positiveBase : .negativeBase
    let signedPerpendicular: SignedSides = (foodY - snakeY) > 0 ? .positivePerpendicular : .negativePerpendicular
    degrees += orthogonalAngleOffsetMap[snake.getDirection()]?[signedBase]?[signedPerpendicular] ?? 0
    return degrees.degreesToRadians
  }

  private static func decideIfBlocked(occupant: GridNodeOccupant?) -> Bool {
    guard let occupant = occupant else { return true }
    return !(occupant == .empty || occupant == .food)
  }

  private static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let xDistance = a.x - b.x
    let yDistance = a.y - b.y
    return CGFloat(sqrt(xDistance * xDistance + yDistance * yDistance))
  }

  private static func angle(between starting: CGPoint, ending: CGPoint) -> Float {
    let center = CGPoint(x: ending.x - starting.x, y: ending.y - starting.y)
    let radians = atan2(center.y, center.x)
    return Float(radians.radiansToDegrees).truncatingRemainder(dividingBy: 90)
  }
}

extension FloatingPoint {
  var degreesToRadians: Self { self * .pi / 180 }
  var radiansToDegrees: Self { self * 180 / .pi }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
