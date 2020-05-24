//
//  Anton.swift
//  Rocket
//
//  Created by Mnet on 5/23/20.
//  Copyright © 2020 Rocket. All rights reserved.
//

import Foundation
import TensorFlow

class Anton {

  struct GameParameters {
    let features: Tensor<Float>
    let labels: Tensor<Int32>
  }

  struct Model: Layer {
    var layer1 = Dense<Float>(inputSize: Constants.inputLayerSize, outputSize: Constants.hiddenLayerSize, activation: relu)
    var layer2 = Dense<Float>(inputSize: Constants.hiddenLayerSize, outputSize: Constants.hiddenLayerSize, activation: relu)
    var layer3 = Dense<Float>(inputSize: Constants.hiddenLayerSize, outputSize: Constants.outputLayerSize)

    @differentiable
    func callAsFunction(_ input: Tensor<Float>) -> Tensor<Float> {
      return input.sequenced(through: layer1, layer2, layer3)
    }
  }

  private enum Constants {
    static let iterationDataFile = "IterationData.csv"
    static let batchSize = 1
    static let inputLayerSize = 4
    static let hiddenLayerSize = 10
    static let outputLayerSize = 1
  }

  private var model = Model()

  func shouldProceed(isLeftBlocked: Bool,
                     isFrontBlocked: Bool,
                     isRightBlocked: Bool,
                     suggestedDirection: DirectionRelativeToMovement) -> Bool {
    let features = [isLeftBlocked.floatValue,
                    isFrontBlocked.floatValue,
                    isRightBlocked.floatValue,
                    suggestedDirection.rawValue]
    let featuresDataset = [Tensor<Float>(features), Tensor<Float>(features)]
    let unlabeledDataset = Tensor<Float>(featuresDataset)
    let predictions = model(unlabeledDataset)
    let normalizedPredictions = predictions.argmax(squeezingAxis: 1)
    let integerPrediction = normalizedPredictions.scalars.first
    let shouldProceed = integerPrediction == 0 ? false : true
    return shouldProceed
  }

  func saveResults(isLeftBlocked: Bool,
                   isFrontBlocked: Bool,
                   isRightBlocked: Bool,
                   suggestedDirection: DirectionRelativeToMovement,
                   shouldProceed: Bool) {
    FileHandler.write(to: Constants.iterationDataFile,
                      content: """
      \(isLeftBlocked.floatValue),
      \(isFrontBlocked.floatValue),
      \(isRightBlocked.floatValue),
      \(suggestedDirection.rawValue),
      \(shouldProceed.floatValue)\n
      """)
  }
}

extension Bool {
  var floatValue: Float {
    return self ? 1 : 0
  }
}
