//
//  ViewController.swift
//  Rocket
//
//  Created by Adnan Zahid on 22/05/2020.
//  Copyright © 2020 Rocket. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

  @IBOutlet var skView: SKView!

  override func viewDidLoad() {
    super.viewDidLoad()
    skView.showsNodeCount = true
    skView.presentScene(GameScene(size: skView.frame.size))
  }
}
