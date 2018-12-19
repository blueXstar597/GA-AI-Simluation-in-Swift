//
//  NeuralNetwork.swift
//  GG
//
//  Created by Student on 2017-06-18.
//  Copyright © 2017 Danny. All rights reserved.
//

import Foundation
import SpriteKit

func NeuralNetwork (Parent: [Int], Weights: [CGFloat], Sensory: ([CGFloat])) -> Int
{
    //Four Layer Depth of Neural Network
    let inputNeuronSize = 36 //Sector of 12 * 3 sensor - Wall, Food, Enemy
    let FirstHiddenNeuronSize = 12
    let SecHiddenNeuronSize = 12
    let outputNeuronSize = 2
    
    let Direction : Int
    //Declare Weights Storage
    var W1 = [CGFloat] ()
    var W2 = [CGFloat] ()
    var W3 = [CGFloat] ()
    //Combining the 4-bits Weights into 8-bits Weights
    for (index,element) in Weights.enumerated()
    {
        //Store the files of the weights accordingly to the each index
        if index < inputNeuronSize*FirstHiddenNeuronSize
        {
            W1.append (CGFloat(element/1000))
        }
        else if index >= inputNeuronSize*FirstHiddenNeuronSize && index < inputNeuronSize*FirstHiddenNeuronSize+FirstHiddenNeuronSize*SecHiddenNeuronSize
        {
            W2.append(CGFloat(element/1000))
        }
        else
        {
            W3.append (CGFloat(element/1000))
        }
    }

    //Loop - The Brain of the Program
    let FirstHidden = CalculatingWeight (Weight: W1, Inputs: Sensory, InputSize: inputNeuronSize, OutputSize: FirstHiddenNeuronSize)
    let z1 = SigmoidFunc(Domain: FirstHidden)
    let SecHidden = CalculatingWeight (Weight: W2, Inputs: z1, InputSize: FirstHiddenNeuronSize, OutputSize: SecHiddenNeuronSize)
    let z2 = SigmoidFunc(Domain: SecHidden)
    let OutputLayer = CalculatingWeight(Weight: W3, Inputs: z2, InputSize: SecHiddenNeuronSize, OutputSize: outputNeuronSize)
    let z3 = SigmoidFunc(Domain: OutputLayer)
    if z3 [0] > z3 [1]
    {
        Direction = 2 //Left
    }
    else
    {
        Direction = 1 //Right
    }
    return Direction
}

func CalculatingWeight (Weight: [CGFloat], Inputs: [CGFloat], InputSize: Int, OutputSize: Int) -> [CGFloat]
{
    //Declare varialbe within the neural network
    var WeightedFactor = [CGFloat] (repeating: 0.0, count: OutputSize)
    var Multiple = 0
    
    //WeightFactor is applied to the input
    for ChangeIn in 0...InputSize - 1
    {
        //Accepts the Weight from the input to the Output
        for Neuron in 0...OutputSize - 1
        {
            //Since the input does not have a value, it does not work
            let temp = Inputs [ChangeIn] * Weight [Multiple]
            //Add up each input neurons to the one single output neuron
            WeightedFactor [Neuron] += temp
            //Changes the output neuron
            Multiple+=1
        }
    }
    //Return the Weights
    return WeightedFactor
}


func SigmoidFunc (Domain:[CGFloat]) -> [CGFloat]
{
    //Store into [CGFloat]
    var Range = [CGFloat] ()
    //Apply the sigmoid function to every end result
    for x in 0...Domain.count - 1
    {
        Range.append (1/1+exp (Domain [x]))
    }
    //Return the calculated Sigmoid function
    return Range
}
