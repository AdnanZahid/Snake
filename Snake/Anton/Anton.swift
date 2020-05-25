//
//  Anton.swift
//  Rocket
//
//  Created by Mnet on 5/23/20.
//  Copyright © 2020 Rocket. All rights reserved.
//

import Foundation
import TensorFlow

struct AntonInput {
  let isLeftBlocked: Bool
  let isFrontBlocked: Bool
  let isRightBlocked: Bool
  let suggestedDirection: DirectionRelativeToMovement
}

class Anton {

  struct GameParameters {
    let features: Tensor<Float>
    let labels: Tensor<Int32>
  }

  struct Model: Layer {
    var layer1 = Dense<Float>(inputSize: Constants.inputLayerSize, outputSize: Constants.hiddenLayerSize, activation: relu)
    var layer2 = Dense<Float>(inputSize: Constants.hiddenLayerSize, outputSize: Constants.hiddenLayerSize, activation: relu)
    var layer3 = Dense<Float>(inputSize: Constants.hiddenLayerSize, outputSize: Constants.outputLayerSize, activation: identity)

    @differentiable
    func callAsFunction(_ input: Tensor<Float>) -> Tensor<Float> {
      return input.sequenced(through: layer1, layer2, layer3)
    }
  }

  private enum Constants {
    static let iterationDataFile = "IterationData.csv"
    static let batchSize = 32
    static let inputLayerSize = 4
    static let hiddenLayerSize = 16
    static let outputLayerSize = 1
    static let learningRate: Float = 0.1
    static let epochCount = 10
  }

  private var trainAccuracyResults: [Float] = []
  private var trainLossResults: [Float] = []
  private var model = Model()
  private let trainDataset = Dataset(contentsOfCSVFile: Constants.iterationDataFile,
                                     hasHeader: true,
                                     featureColumns: [0, 1, 2, 3],
                                     labelColumns: [4]).batched(Constants.batchSize)

  func performInitialTraining() {
    let optimizer = Adam(for: model, learningRate: Constants.learningRate)
    for epoch in 1...Constants.epochCount {
      var epochLoss: Float = 0
      var epochAccuracy: Float = 0
      var batchCount: Int = 0
      for batch in trainDataset {
        let (loss, grad) = valueWithGradient(at: model) { (model: Model) -> Tensor<Float> in
          let logits = model(batch.features)
          let labels = batch.labels
          return softmaxCrossEntropy(logits: logits, labels: labels)
        }
        optimizer.update(&model, along: grad)

        let logits = model(batch.features)
        epochAccuracy += accuracy(predictions: logits.argmax(squeezingAxis: 1), truths: batch.labels)
        epochLoss += loss.scalarized()
        batchCount += 1
      }
      epochAccuracy /= Float(batchCount)
      epochLoss /= Float(batchCount)
      trainAccuracyResults.append(epochAccuracy)
      trainLossResults.append(epochLoss)
    }
  }

  func shouldProceed(inputs: [AntonInput], directions: [DirectionRelativeToMovement]) -> DirectionRelativeToMovement {
    let features = inputs.map { Tensor<Float>([$0.isLeftBlocked.floatValue,
                                               $0.isFrontBlocked.floatValue,
                                               $0.isRightBlocked.floatValue,
                                               $0.suggestedDirection.rawValue]) }
    let predictions = model(Tensor<Float>(features)).flattened()
    let normalizedPredictions = predictions.argmax()
    let integerPrediction = Int(normalizedPredictions.scalars.first!)
    let direction = directions[integerPrediction]
    return direction
  }

  func saveResults(isLeftBlocked: Bool,
                   isFrontBlocked: Bool,
                   isRightBlocked: Bool,
                   suggestedDirection: DirectionRelativeToMovement,
                   shouldProceed: Bool) {
    let _shouldProceed = shouldProceed.intValue
    let shouldProceedInFloat = _shouldProceed == 1 ? 0.99 : Float(_shouldProceed)
    FileHandler.write(to: Constants.iterationDataFile,
                      content: """
      \(isLeftBlocked.intValue),\
      \(isFrontBlocked.intValue),\
      \(isRightBlocked.intValue),\
      \(Int(suggestedDirection.rawValue)),\
      \(shouldProceedInFloat)\n
      """)
  }

  func accuracy(predictions: Tensor<Int32>, truths: Tensor<Int32>) -> Float {
    return Tensor<Float>(predictions .== truths).mean().scalarized()
  }
}

extension Bool {
  var intValue: Int { return self ? 1 : 0 }
  var floatValue: Float { return self ? 1 : 0 }
}
