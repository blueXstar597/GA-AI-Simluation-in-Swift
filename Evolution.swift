//
//  Evolution.swift
//  GG
//
//  Created by Student on 2017-06-18.
//  Copyright © 2017 Danny. All rights reserved.
//

import Foundation
import SpriteKit

//Initalizer Population Function
func PopulationMod () -> [[Int]]
{
    //Declare Variables
    var PopulationDNA = [[Int]] ()
    var Individual = [Int] ()
    //Summon Individuals
    for _ in 0...Population - 1
    {
        Individual = []
        //Summons the Chromosomes
        for _ in 0...4799 //43
        {
            //Initalizing Random Bits
            Individual.append (Int(arc4random_uniform(2)))
        }
        //Store the Individuals within the population
        PopulationDNA.append(Individual)
    }
    //Return the Current Generation of Population
    return PopulationDNA
}

//Rounlette Selection
func RouletteSel (Generation: [[Int]], GenFitness: [CGFloat] ) -> ([Int])
{
    //Calculating the fitness through the Binary F6 Function
    var RelativeFitness: CGFloat = 0.0
    var Picker = [Int] ()
    //Print a Table
    //Check the Individual's Fitness
    for (index,Individuals) in Generation.enumerated()
    {
        //Determine the Average Relative Fitness within the Population
        RelativeFitness += GenFitness [index]
        if GenFitness [index] > largest
        {
            largest = GenFitness [index]
            GreatestDNA = Individuals
        }
        
    }
    Fitness = RelativeFitness / CGFloat (Population)
    
    //Implent Rounlette Selection
    for _ in 1...Population * 2
    {
        //Geneterating a random value from the total fitness
        var r = CGFloat (arc4random_uniform(UInt32(Int32(RelativeFitness))+1))
        //Counter value
        var i = 0
        //Enter until r is less than 0
        while true
        {
            //Otherwise, subract r from each individual's fitness to obtain
            r = r - GenFitness [i]
            //Add 1 to the counter
            if r < 0
            {
                break
            }
            i+=1
        }
        //If the loop exits out, meaning that the random value = 0, the individual is now selected for crossing over
        Picker.append(i)
    }
    //Return Data
    return Picker
}

//CrossingOver Function
func CrossingOver  (Population: [[Int]], inDividualWeight: [[CGFloat]]) -> ([[Int]],[[CGFloat]])
{
    //Declare variables for the next generation
    var NewGenChild = [[Int]] ()
    var NewNeuralNeural = [[CGFloat]] ()
    //Counting by pairs - Parent 1 & Parent 2
    for size in stride(from:0 , to: Population.count - 1 / 2, by:2)
    {
        //Create a single array
        var Child = [Int] ()
        var Neural = [CGFloat] ()
        //Counting by bits of 4
        for bits in stride (from:0, to:Population [size].count - 1 / 4, by:4)
        {
            //Determine the crossing over rate
            let probability = arc4random_uniform(20)
            //No Crossing Over
            if (probability >= 13)
            {
                Child.append (Population [size] [bits])
                Child.append (Population [size] [bits+1])
                Child.append (Population [size] [bits+2])
                Child.append (Population [size] [bits+3])
                Neural.append (inDividualWeight [size] [bits/4])
            }
            //Crossing Over
            else if (probability <= 12)
            {
                //Choose to pick which Parent
                let probability = arc4random_uniform(2)
                if (probability == 0)
                {
                    //Parent 1 Side
                    //Storing the bits into the Child's gene
                    Child.append (Population [size] [bits])
                    Child.append (Population [size] [bits+1])
                    Child.append (Population [size] [bits+2])
                    Child.append (Population [size] [bits+3])
                    //Storing the weights NeuronNetwork
                    Neural.append (inDividualWeight [size] [bits/4])
                }
                else
                {
                    //Parent 2 Side
                    //Storing the bits into the Child's gene
                    Child.append (Population [size+1] [bits])
                    Child.append (Population [size+1] [bits+1])
                    Child.append (Population [size+1] [bits+2])
                    Child.append (Population [size+1] [bits+3])
                    //Storing the weights NeuronNetwork
                    Neural.append (inDividualWeight [size+1] [bits/4])
                }
            }
        }
        //Store into the NewGeneration
        NewGenChild.append (Child)
        NewNeuralNeural.append (Neural)
    }
    //Return the NewGeneration
    return (NewGenChild,NewNeuralNeural)
}

func Mutation (Population: [[Int]]) -> [[Int]]
{
    var NewGenMutated = Population
    for Individual in 0...Population.count - 1
    {
        for bits in 0...4799
        {
            var mutation = arc4random_uniform(1000) + 1
            if mutation <= 8
            {
                if NewGenMutated [Individual] [bits] == 0
                {
                    NewGenMutated [Individual] [bits] = 1
                }
                else
                {
                    NewGenMutated [Individual] [bits] = 0
                }
            }
        }
    }
    return NewGenMutated
}
