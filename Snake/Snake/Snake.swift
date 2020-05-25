//
//  Snake.swift
//  Snake
//
//  Created by Adnan Zahid on 24/05/2020.
//  Copyright © 2020 Snake. All rights reserved.
//

import Foundation
import SpriteKit

struct SnakeNode {
  var x: Int
  var y: Int
}

enum DirectionRelativeToMovement: Float {
  case left = -1
  case front = 0
  case right = 1
}

enum DirectionRelativeToGrid {
  case up
  case down
  case left
  case right
}

class Snake {
  private enum SnakeConstants {
    static let snakeSpeed = 1
    static let cornerRadius: CGFloat = 10
    static let animationInterval = 1
  }

  private var direction: DirectionRelativeToGrid
  private var nodes: [SnakeNode] = []
  private var sprites: [SKShapeNode] = []
  private var currentFrames = 0
  private var numberOfColumns: Int
  private var numberOfRows: Int
  private var oppositeDirectionMap: [DirectionRelativeToGrid: DirectionRelativeToGrid]
                = [.up: .down,
                   .down: .up,
                   .left: .right,
                   .right: .left]
  private var directionMap: [DirectionRelativeToGrid: [DirectionRelativeToMovement: DirectionRelativeToGrid]]
                = [.up: [.front: .up,
                         .left: .left,
                         .right: .right],
                   .down: [.front: .down,
                           .left: .right,
                           .right: .left],
                   .left: [.front: .left,
                           .left: .down,
                           .right: .up],
                   .right: [.front: .right,
                            .left: .up,
                            .right: .down]]
  private var relativeDirectionMap: [DirectionRelativeToGrid: [DirectionRelativeToGrid: DirectionRelativeToMovement]]
                = [.up: [.up: .front,
                         .left: .left,
                         .right: .right],
                   .down: [.down: .front,
                           .left: .right,
                           .right: .left],
                   .left: [.left: .front,
                           .down: .left,
                           .up: .right],
                   .right: [.right: .front,
                            .up: .left,
                            .down: .right]]

  init(x: Int, y: Int, numberOfColumns: Int, numberOfRows: Int) {
    self.numberOfColumns = numberOfColumns
    self.numberOfRows = numberOfRows
    nodes = [SnakeNode(x: x, y: y)]
    let directions: [DirectionRelativeToGrid] = [.up, .down, .left, .right]
    direction = directions.randomElement() ?? .up
  }

  var shouldAnimate: Bool {
    if currentFrames == SnakeConstants.animationInterval { currentFrames = 0; return true; }
    return false
  }

  var isDead: Bool {
    let x = getX()
    let y = getY()
    return x < 0 || x > numberOfColumns || y < 0 || y > numberOfRows
  }

  func incrementFrame() {
    currentFrames += 1
  }

  func getX() -> Int {
    return nodes.first?.x ?? numberOfColumns/2
  }

  func getY() -> Int {
    return nodes.first?.y ?? numberOfRows/2
  }

  func getNodes() -> [SnakeNode] {
    return nodes
  }

  func getSprites() -> [SKShapeNode] {
    return nodes.map { node in
      let sprite = SKShapeNode(rect: CGRect(x: node.x * Constants.sizeOfColumn,
                                            y: node.y * Constants.sizeOfRow,
                                            width: Constants.sizeOfColumn,
                                            height: Constants.sizeOfRow),
                               cornerRadius: SnakeConstants.cornerRadius)
      sprite.fillColor = .white
      return sprite
    }
  }

  func getDirection() -> DirectionRelativeToGrid {
    return direction
  }

  func getDirection(relativeTo newDirection: DirectionRelativeToGrid?) -> DirectionRelativeToMovement {
    guard let newDirection = newDirection else { return .front }
    return relativeDirectionMap[direction]?[newDirection] ?? .front
  }

  func getOppositeDirection() -> DirectionRelativeToGrid? {
    return oppositeDirectionMap[direction]
  }

  func setDirection(absoluteDirection: DirectionRelativeToGrid) {
    direction = absoluteDirection
  }

  func setDirection(relativeDirection: DirectionRelativeToMovement) {
    guard let _direction = directionMap[direction]?[relativeDirection] else { return }
    direction = _direction
  }

  func growSnake(_ node: SnakeNode) {
    nodes.append(node)
  }

  func moveSnake() {
    nodes = nodes.map {
      var x = $0.x
      var y = $0.y
      switch direction {
      case .up:
        y += SnakeConstants.snakeSpeed
      case .down:
        y -= SnakeConstants.snakeSpeed
      case .left:
        x -= SnakeConstants.snakeSpeed
      case .right:
        x += SnakeConstants.snakeSpeed
      }
      return SnakeNode(x: x, y: y)
    }
  }
}
