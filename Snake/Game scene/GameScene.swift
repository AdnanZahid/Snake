//
//  GameScene.swift
//  Rocket
//
//  Created by Adnan Zahid on 22/05/2020.
//  Copyright © 2020 Rocket. All rights reserved.
//

import SpriteKit
import GameplayKit
import Carbon.HIToolbox

class GameScene: SKScene {

  var grid: [[GridNode]] = []
  var screenSize: CGSize!
  var snake: Snake!
  var anton: Anton!
  var score = 0
  var deathCount = 0
  let scoreLabel = SKLabelNode()
  let deathLabel = SKLabelNode()
  let snakeLayerNode = SKNode()
  var newDirection: DirectionRelativeToGrid?

  override func sceneDidLoad() {
    super.sceneDidLoad()
    setupAnton()
    setupGame()
  }

  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    updateSnake()
  }

  override func keyDown(with event: NSEvent) {
    switch Int(event.keyCode) {
    case kVK_UpArrow:
      newDirection = .up
    case kVK_DownArrow:
      newDirection = .down
    case kVK_LeftArrow:
      newDirection = .left
    case kVK_RightArrow:
      newDirection = .right
    default:
      break
    }
  }
}
