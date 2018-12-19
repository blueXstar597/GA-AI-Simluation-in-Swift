//
//  Evalution.swift
//  GG
//
//  Created by Student on 2017-06-18.
//  Copyright © 2017 Danny. All rights reserved.
//

import Foundation
import SpriteKit

//Fitness Function
func EvalutionMod (Time: TimeInterval, Food:Int) -> CGFloat
{
    //Undergo a Binary F6 Function
    let Fitness: CGFloat = CGFloat (Time/100) + CGFloat (Food * 20)
    return Fitness
}

func areEqual (NewWeight: [CGFloat], OldWeight:[CGFloat]) -> Bool
{
    for bits in 0...1199
    {
        if NewWeight [bits] != OldWeight [bits]
        {
            return false
        }
    }
    return true
}
