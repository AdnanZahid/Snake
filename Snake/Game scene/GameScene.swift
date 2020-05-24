//
//  GameScene.swift
//  Rocket
//
//  Created by Adnan Zahid on 22/05/2020.
//  Copyright © 2020 Rocket. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

  var grid: [[GridNode]] = []
  var screenSize: CGSize!
  var snake: Snake!
  var anton = Anton()
  var score = 0
  let scoreLabel = SKLabelNode()

  override func sceneDidLoad() {
    super.sceneDidLoad()
    setupGame()
  }

  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    updateSnake()
  }
}
