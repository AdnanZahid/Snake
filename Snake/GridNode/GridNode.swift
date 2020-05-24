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

  init(x: Int, y: Int, width: Int, height: Int, occupant: GridNodeOccupant = .empty) {
    self.x = x
    self.y = y
    self.occupant = occupant
    self.sprite = SKShapeNode(rect: CGRect(x: x * Constants.sizeOfColumn,
                                           y: y * Constants.sizeOfColumn,
                                           width: width, height: height))
  }

  func getPosition() -> (x: Int, y: Int) {
    return (x: x, y: y)
  }

  func getOccupant() -> GridNodeOccupant {
    return occupant
  }
}
