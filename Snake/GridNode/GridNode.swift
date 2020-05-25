//
//  GridNode.swift
//  Snake
//
//  Created by Adnan Zahid on 24/05/2020.
//  Copyright © 2020 Snake. All rights reserved.
//

import Foundation
import SpriteKit

enum GridNodeOccupant {
  case empty
  case food
  case snake
  case wall
}

class GridNode {
  private var x: Int
  private var y: Int
  private var sprite: SKShapeNode
  private var occupant: GridNodeOccupant
  private var stuckCount = 0

  init(x: Int, y: Int, width: Int, height: Int, occupant: GridNodeOccupant = .empty) {
    self.x = x
    self.y = y
    self.occupant = occupant
    self.sprite = SKShapeNode(rect: CGRect(x: x * Constants.sizeOfColumn,
                                           y: y * Constants.sizeOfColumn,
                                           width: width, height: height))
    self.sprite.strokeColor = .clear
    self.sprite.fillColor = occupant == .wall ? .white : .clear
  }

  func getPosition() -> (x: Int, y: Int) {
    return (x: x, y: y)
  }

  func getSprite() -> SKShapeNode {
    return sprite
  }

  func getOccupant() -> GridNodeOccupant {
    return occupant
  }

  func getStuckCount() -> Int {
    return stuckCount
  }

  func incrementStuckCount() {
    stuckCount += 1
  }

  func resetStuckCount() {
    stuckCount = 0
  }
}
