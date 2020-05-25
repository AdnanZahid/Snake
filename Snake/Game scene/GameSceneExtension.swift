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
  static let deathXOffset: CGFloat = 100
  static let deathYOffset: CGFloat = 100
  static let sizeOfRow: Int = 10
  static let sizeOfColumn: Int = 10
}

extension GameScene {

  var numberOfRows: Int { return Int(screenSize.height) / Constants.sizeOfRow }
  var numberOfColumns: Int { return Int(screenSize.width) / Constants.sizeOfColumn }
  var isGameOver: Bool { return snake.isDead }
  var didConsumeFood: Bool { return GridHelper.didConsumeFood(snake: snake, grid: grid) }

  func setupGame() {
    setupWorld()
    setupGrid()
    setupScore()
    setupDeathCount()
    setupSnake()
    setupFood()
  }

  func restartGame() {
    removeAllNodes()
    setupGame()
  }

  func gameOver() {
    score = 0
    deathCount += 1
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
        var occupant = GridNodeOccupant.empty
        if column == 0 || column == numberOfColumns - 1 ||
            row == 0 || row == numberOfRows - 1 { occupant = .wall }
        return GridNode(x: column,
                        y: row,
                        width: Constants.sizeOfColumn,
                        height: Constants.sizeOfRow,
                        occupant: occupant)
      }
    }
    addChild(gridLayerNode)
    grid.forEach { $0.forEach { gridLayerNode.addChild($0.getSprite()) } }
  }

  func setupScore() {
    scoreLabel.text = "Score: \(score)"
    scoreLabel.position = CGPoint(x: screenSize.width - Constants.scoreXOffset,
                                  y: screenSize.height - Constants.scoreYOffset)
    addChild(scoreLabel)
  }

  func setupDeathCount() {
    deathLabel.text = "Deaths: \(deathCount)"
    deathLabel.position = CGPoint(x: screenSize.width - Constants.deathXOffset,
                                  y: screenSize.height - Constants.deathYOffset)
    addChild(deathLabel)
  }

  func incrementScore() {
    score += 1
    scoreLabel.text = "Score: \(score)"
  }

  func incrementStuckCount() {
    grid[safe: snake.getX()]?[safe: snake.getY()]?.incrementStuckCount()
  }

  func removeFood() {
    let foodNode = GridHelper.foodNode(grid: grid)
    foodNode?.setOccupant(.empty)
    foodNode?.getSprite().removeFromParent()
  }

  func setupFood() {
    guard let randomPosition = grid.randomElement()?.randomElement()?.getPosition(),
          let gridNode = grid[safe: randomPosition.x]?[safe: randomPosition.y] else { return }
    gridNode.setOccupant(.food)
    gridNode.getSprite().removeFromParent()
    gridLayerNode.addChild(gridNode.getSprite())
  }

  func setupSnake() {
    guard let randomPosition = grid.randomElement()?.randomElement()?.getPosition() else { return }
    snake = Snake(x: randomPosition.x,
                  y: randomPosition.y,
                  numberOfColumns: numberOfColumns,
                  numberOfRows: numberOfRows)
    addChild(snakeLayerNode)
  }

  func moveSnake() {
    snake.incrementFrame()
    if snake.shouldAnimate {
      snake.moveSnake()
    }
  }

  func mapSnakeToGrid() {
    //    [Int](0..<numberOfColumns).forEach { column in
    //      [Int](0..<numberOfRows).forEach { row in
    //        var occupant = GridNodeOccupant.empty
    //        if column == 0 || column == numberOfColumns - 1 ||
    //            row == 0 || row == numberOfRows - 1 { occupant = .wall }
    //        grid[safe: column]?[safe: row]?.setOccupant(occupant)
    //      }
    //    }
    //    snake.getNodes().forEach {
    //      let x = $0.x
    //      let y = $0.y
    //      grid[safe: x]?[safe: y]?.setOccupant(.snake)
    //    }
  }

  func clearSnake() {
    snakeLayerNode.removeAllChildren()
  }

  func drawSnake() {
    snake.getSprites().forEach { snakeLayerNode.addChild($0) }
  }

  func updateSnake() {
    if isGameOver { gameOver() }
    let relativeDirections: [DirectionRelativeToMovement] = [.front, .left, .right].shuffled()
    let isLeftBlocked = GridHelper.isLeftBlocked(snake: snake, grid: grid)
    let isFrontBlocked = GridHelper.isFrontBlocked(snake: snake, grid: grid)
    let isRightBlocked = GridHelper.isRightBlocked(snake: snake, grid: grid)
    let orthogonalAngleToFood = GridHelper.orthogonalAngleToFood(snake: snake, grid: grid)
    let antonInputs = relativeDirections.map { AntonInput(isLeftBlocked: isLeftBlocked,
                                                          isFrontBlocked: isFrontBlocked,
                                                          isRightBlocked: isRightBlocked,
                                                          orthogonalAngleToFood: orthogonalAngleToFood,
                                                          suggestedDirection: $0) }
    var suggestedDirection: DirectionRelativeToMovement?
    if GridHelper.isSnakeStuck(snake: snake, grid: grid),
       let randomDirection = relativeDirections.randomElement() {
      snake.setDirection(relativeDirection: randomDirection)
      grid[safe: snake.getX()]?[safe: snake.getY()]?.resetStuckCount()
    } else {
      suggestedDirection = anton.shouldProceed(inputs: antonInputs, directions: relativeDirections)
      if let _suggestedDirection = suggestedDirection {
        snake.setDirection(relativeDirection: _suggestedDirection)
      }
    }
    incrementStuckCount()
    clearSnake()
    let previousDistanceFromFood = GridHelper.distanceFromFood(snake: snake, grid: grid)
    moveSnake()
    let currentDistanceFromFood = GridHelper.distanceFromFood(snake: snake, grid: grid)
    if didConsumeFood { removeFood(); setupFood(); }
    mapSnakeToGrid()
    drawSnake()
    guard let _suggestedDirection = suggestedDirection else { return }
    let didDistanceDecrease = currentDistanceFromFood < previousDistanceFromFood
    let decision = isGameOver ? -1 : didDistanceDecrease.intValue
    anton.saveResults(isLeftBlocked: isLeftBlocked,
                      isFrontBlocked: isFrontBlocked,
                      isRightBlocked: isRightBlocked,
                      orthogonalAngleToFood: orthogonalAngleToFood,
                      suggestedDirection: _suggestedDirection,
                      decision: decision)
  }
}
