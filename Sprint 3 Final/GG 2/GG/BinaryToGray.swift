//
//  BinaryToGray.swift
//  GG
//
//  Created by Student on 2017-06-18.
//  Copyright © 2017 Danny. All rights reserved.
//

import Foundation
import SpriteKit

func ConvertBinToNum (Binary: [Int]) -> [CGFloat]
{
    //Declare variables
    var bits = ""
    var BinaryNum = [CGFloat] ()
    //Every 4 bits
    for x in stride (from: 0, to: Binary.count-1/4, by: 4)
    {
        //Within the four bits
        for counter in 0...3
        {
            //Gray Code Implentation
            //Store the 1st bits
            if counter == 0
            {
                bits += String (Binary [counter+x])
            }
            else
            {
                //Otherwise, compare the current bits to the previous bits
                //If it is the same, Ex: 11 or 00 = 0
                if String (Binary [counter+x]) == String (Binary [counter-1+x])
                {
                    bits += "0"
                }
                    //If it is differnet, Ex: 10 or 01 = 1
                else if String(Binary[counter+x]) != String (Binary[counter-1+x])
                {
                    bits += "1"
                }
            }
        }
        //Store it into a [CGFloat]
        BinaryNum.append (CGFloat (strtoul(bits,nil,2)))
        //Reset the bits string
        bits = ""
    }
    //Return
    return BinaryNum
}

//Changing from Greyvale to One Weight
func FromGreyToWeights (Binary:[CGFloat]) -> [CGFloat]
{
    var Weights = [CGFloat] ()
    //Take two split weights
    for x in stride (from: 0, to: Binary.count - 1 / 2, by: 2)
    {
        var product: CGFloat = 1.0
        //Muplite the two split weight together to create a whole weight
        for counter in 0...1
        {
            product*=Binary [counter+x]
        }
        //Store Weights
        Weights.append (product)
    }
    //Return
    return Weights
}
