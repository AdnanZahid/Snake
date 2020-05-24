//
//  GameSceneExtension.swift
//  Snake
//
//  Created by Adnan Zahid on 24/05/2020.
//  Copyright © 2020 Snake. All rights reserved.
//

import Foundation

enum Constants {
  static let scoreXOffset: CGFloat = 100
  static let scoreYOffset: CGFloat = 50
  static let sizeOfRow: Int = 10
  static let sizeOfColumn: Int = 10
}

extension GameScene {

  var numberOfRows: Int { return Int(screenSize.height) / Constants.sizeOfRow }
  var numberOfColumns: Int { return Int(screenSize.width) / Constants.sizeOfColumn }
  var isGameOver: Bool { return snake.isDead }

  func setupGame() {
    setupWorld()
    setupGrid()
    setupScore()
    setupSnake()
    drawSnake()
  }

  func restartGame() {
    removeAllNodes()
    setupGame()
  }

  func gameOver() {
    score = 0
    restartGame()
  }

  func removeAllNodes() {
    children.forEach { $0.removeAllChildren() }
    removeAllChildren()
  }

  func setupWorld() {
    screenSize = CGSize(width: frame.width, height: frame.height)
  }

  func setupAnton() {
    anton = Anton()
    anton.performInitialTraining()
  }

  func setupGrid() {
    grid = [Int](0..<numberOfColumns).map { column in
      [Int](0..<numberOfRows).map { row in
        GridNode(x: column,
                 y: row,
                 width: Constants.sizeOfColumn,
                 height: Constants.sizeOfRow)
      }
    }
  }

  func setupScore() {
    scoreLabel.text = "Score: \(score)"
    scoreLabel.position = CGPoint(x: screenSize.width - Constants.scoreXOffset,
                                  y: screenSize.height - Constants.scoreYOffset)
    addChild(scoreLabel)
  }

  func incrementScore() {
    score += 1
    scoreLabel.text = "Score: \(score)"
  }

  func setupSnake() {
    guard let randomPosition = grid.randomElement()?.randomElement()?.getPosition() else { return }
    snake = Snake(x: 0,
                  y: 0,
                  numberOfColumns: numberOfColumns,
                  numberOfRows: numberOfRows)
  }

  func moveSnake() {
    snake.incrementFrame()
    if snake.shouldAnimate {
      snake.moveSnake()
    }
  }

  func drawSnake() {
    removeAllNodes()
    snake.getSprites().forEach { addChild($0) }
  }

  //  func updateSnake() {
  //    if isGameOver { gameOver() }
  //
  //    // Generates random direction
  ////    var absoluteDirections: [DirectionRelativeToGrid] = [.up, .down, .left, .right]
  ////    absoluteDirections.removeAll { $0 == snake.getOppositeDirection() }
  ////    newDirection = absoluteDirections.randomElement()
  //    newDirection = .up
  //
  //    let relativeDirections: [DirectionRelativeToMovement] = [.front, .left, .right]
  //    let isLeftBlocked = CollisionDetector.isLeftBlocked(snake: snake, grid: grid)
  //    let isFrontBlocked = CollisionDetector.isFrontBlocked(snake: snake, grid: grid)
  //    let isRightBlocked = CollisionDetector.isRightBlocked(snake: snake, grid: grid)
  //    let allowedDirections = relativeDirections.filter { anton.shouldProceed(isLeftBlocked: isLeftBlocked,
  //                                                                            isFrontBlocked: isFrontBlocked,
  //                                                                            isRightBlocked: isRightBlocked,
  //                                                                            suggestedDirection: $0) }
  //    var suggestedDirection = snake.getDirection(relativeTo: newDirection)
  //    if let allowedDirection = allowedDirections.first {
  //      suggestedDirection = allowedDirection
  //      snake.setDirection(relativeDirection: suggestedDirection)
  //      moveSnake()
  //      drawSnake()
  //      anton.saveResults(isLeftBlocked: isLeftBlocked,
  //                        isFrontBlocked: isFrontBlocked,
  //                        isRightBlocked: isRightBlocked,
  //                        suggestedDirection: suggestedDirection,
  //                        shouldProceed: !isGameOver)
  //    }
  //  }

  func updateSnake() {
    if isGameOver { gameOver() }
    let relativeDirections: [DirectionRelativeToMovement] = [.front, .left, .right].shuffled()
    let isLeftBlocked = CollisionDetector.isLeftBlocked(snake: snake, grid: grid)
    let isFrontBlocked = CollisionDetector.isFrontBlocked(snake: snake, grid: grid)
    let isRightBlocked = CollisionDetector.isRightBlocked(snake: snake, grid: grid)
    let antonInputs = relativeDirections.map { AntonInput(isLeftBlocked: isLeftBlocked,
                                                          isFrontBlocked: isFrontBlocked,
                                                          isRightBlocked: isRightBlocked,
                                                          suggestedDirection: $0) }
    snake.setDirection(relativeDirection: anton.shouldProceed(inputs: antonInputs, directions: relativeDirections))
    moveSnake()
    drawSnake()
  }
}
