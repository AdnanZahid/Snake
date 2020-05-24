//
//  CollisionDetector.swift
//  Snake
//
//  Created by Adnan Zahid on 24/05/2020.
//  Copyright © 2020 Snake. All rights reserved.
//

import Foundation

class CollisionDetector {

  static func decideIfBlocked(occupant: GridNodeOccupant?) -> Bool {
    guard let occupant = occupant else { return true }
    return !(occupant == .empty || occupant == .food)
  }

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
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
