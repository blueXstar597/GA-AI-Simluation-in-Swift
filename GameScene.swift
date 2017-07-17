//
//  GameScene.swift
//  2DSimatulorAI
//
//  Created by Student on 2017-06-03.
//  Copyright © 2017 Danny. All rights reserved.
//

import SpriteKit
import GameplayKit

//Setting a previous update time to compare the delta
var lastUpdateTime: TimeInterval = 0
let MaxHealth: CGFloat = 100
let HealthBarWidth: CGFloat = 40
let HealthBarHeight: CGFloat = 4
let Population = 20
var Generation = 1
var Fitness: CGFloat = 0
var PopulationDNA = [[Int]] ()
var largest : CGFloat = 0
var GreatestDNA = [Int] ()
//Genetics Evolution
var GroupFitness: [CGFloat] = Array (repeating: 0, count: Population)
var SplitNeuralWeights = [[CGFloat]] ()
var NeuralWeights = [[CGFloat]] ()

struct game {
    static var IsOver : Bool = false
}

enum ColliderType: UInt32 {
    case player = 1
    case obstacles = 2
    case food = 4
    case wall = 8
    case Sensor = 16
}

//#MARK : MATH GROUP
//Enable Vector Properties
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

//Develop to 2D vectors maths and techiques
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    func angleForVector () -> CGFloat{
        var alfa: CGFloat = atan2 (self.y,self.x)
        return alfa
    }
}

//Creating a random min and max function
func random (min: Float, max: Float) -> Float
{
    let random = Float (Double (arc4random()%1000) / (1000.0))
    return random * (max-min) + min
}
//------------------------------

//Develop the class scene
class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    //Create SKSpirtNode and Picture
    //Set Parameter for the Wander Algthorim
    let radius: CGFloat = 5
    let distance: CGFloat = 50
    let angleNosise: Float = 0.3
    let speedD: CGFloat = 10 //20
    var angle : [CGFloat] = Array (repeating: 0, count: Population)
    var Circle = [SKSpriteNode] ()
    var Target = [SKSpriteNode] ()
    var counter = 0
    //Save every location - (Rather than saving every point, the points are updated every 5 seconds)
    var locationObstacle = [CGPoint] ()
    var locationFood = [CGPoint] ()
    //Fitness Score and Generation #
    var scoreLabel: SKLabelNode!
    var genLabel : SKLabelNode!
    var largestLabel : SKLabelNode!
    var bestLabel: SKLabelNode!
    var possibleChar = ["player1","player2","player3"]
    var possibleObs = ["obstacles0", "obstacles1"]
    
    //Generate a gameTimer to recrod and update everytime
    var ObsTimer: Timer!
    var FoodTimer: Timer!
    //Player's Properties and Behavior
    var HealthBar = [SKSpriteNode] ()
    var playerHP : [CGFloat] = Array (repeating: MaxHealth, count: Population)
    var foodeaten = Array (repeating: 0, count: Population)
    //Setuping AI System and Connect to Neural Network
    var AIradius: CGFloat = 40
    var playerRef: [CGFloat] = Array (repeating: 0, count: Population)
    var locationObjPos = ([Int](), [SKSpriteNode] (), [SKSpriteNode] ())
    var FieldView: CGFloat = 180
    var ReponseSystem = Array (repeating: 0, count: Population)
    var NewWeights = [[CGFloat]] ()
    
    //Set-up Function and the new World
    override func didMove(to view: SKView) {
        //Set BackGround and Wall to white
        backgroundColor = SKColor.white
        self.physicsWorld.contactDelegate = self
        //Develop Edge detection
        var edge = SKSpriteNode()
        edge.color = UIColor.black
        let edgeRect = CGRect (x: 0, y:0 , width:frame.size.width, height:frame.size.height)
        edge.physicsBody = SKPhysicsBody (edgeLoopFrom: edgeRect)
        //Allow Wall to have collision and set-up physics
        edge.physicsBody!.categoryBitMask = ColliderType.wall.rawValue
        //edge.physicsBody!.collisionBitMask = ColliderType.player.rawValue
        edge.physicsBody!.contactTestBitMask = ColliderType.player.rawValue
        edge.physicsBody!.isDynamic = false
        edge.name = "wall"
        addChild(edge)
        
        //Develop the Players
        for _ in 0...Population - 1
        {
            self.addPlayer()
            counter += 1
        }
        
        //If 1st Generation, the genes are randomly generated
        if Generation == 1
        {
            PopulationDNA = PopulationMod()
            for Individuals in 0...Population - 1
            {
                SplitNeuralWeights.append ((ConvertBinToNum(Binary: PopulationDNA [Individuals])))
                NeuralWeights.append ((FromGreyToWeights(Binary: SplitNeuralWeights [Individuals])))
            }
        }
        else
        {
            //Else the gene is carried through its parent
            for Individuals in 0...Population - 1
            {
                NewWeights.append ((ConvertBinToNum(Binary: PopulationDNA [Individuals])))
                //A Evalution Method to detect the presence of mutation
                if areEqual(NewWeight: NewWeights [Individuals], OldWeight: SplitNeuralWeights [Individuals])
                {
                    print ("No Mutation \(Individuals)")
                }
                else
                {
                    print ("Yes Mutation \(Individuals)")
                    SplitNeuralWeights [Individuals] = NewWeights [Individuals]
                }
                //Save into the neural network
                NeuralWeights.append ((FromGreyToWeights(Binary: SplitNeuralWeights [Individuals])))
            }
        }
        
        
        //Set a counter
        counter = 0
        // Score Label //
        scoreLabel = SKLabelNode(text: "Fitness: \(Int(Fitness))")
        scoreLabel.position = CGPoint (x: 115, y:self.frame.size.height - 60)
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.black
        self.addChild (scoreLabel)
        //Generation Label
        genLabel = SKLabelNode (text: "Generation \(Generation)")
        genLabel.position = CGPoint (x: 110, y: self.frame.size.height - 100)
        genLabel.fontSize = 36
        genLabel.fontColor = UIColor.blue
        self.addChild (genLabel)
        //Greatest Label
        largestLabel = SKLabelNode (text: "Greatest: \(Int(largest))")
        largestLabel.position = CGPoint (x: 110, y: self.frame.size.height - 140)
        largestLabel.fontSize = 36
        largestLabel.fontColor = UIColor.black
        self.addChild (largestLabel)
        
        //Update every second for the addObstacle
        ObsTimer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(addObstacle), userInfo: nil, repeats: true)
        //AddFood
        FoodTimer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(addFood), userInfo: nil, repeats: true)
    }
    
    //Method to develop player
    func addPlayer()
    {
        //Set a SpriteImage
        let ri = Int(arc4random_uniform(UInt32(possibleChar.count)))
        //Declare Players and Physics
        let player = SKSpriteNode(imageNamed: "player\(ri)")
        let playerHealthBar = SKSpriteNode ()
        player.position = CGPoint (x:self.frame.size.width/2 , y:self.frame.size.height/2)
        self.physicsWorld.gravity = CGVector (dx: 0, dy: 0)
        //Physics and Collision for Player
        player.physicsBody = SKPhysicsBody (rectangleOf: player.size)
        player.physicsBody?.categoryBitMask =  ColliderType.player.rawValue
        player.physicsBody?.collisionBitMask = ColliderType.obstacles.rawValue //|ColliderType.wall.rawValue
        player.physicsBody?.contactTestBitMask = ColliderType.obstacles.rawValue | ColliderType.wall.rawValue
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.restitution = 1.0;
        player.physicsBody?.friction = 0.0;
        player.physicsBody?.linearDamping = 0.0;
        player.physicsBody?.angularDamping = 0.0;
        player.name = "player"
        player.userData = NSMutableDictionary ()
        player.userData?.setValue(counter, forKey: "Key")
        self.addChild(player)
        
        //Set the health bar to the player
        playerHealthBar.position = CGPoint (
            x: player.position.x,
            y: player.position.y - player.size.height/2 - 15
        )
        self.addChild(playerHealthBar)
        //Save the health num
        HealthBar.append (playerHealthBar)
        
        //Develop and Setup the Wander Algthroim - Detector/ Position
        let circle = SKSpriteNode (imageNamed: "circle")
        circle.position = CGPoint (x: 0 + player.position.x,y: distance + player.position.y)
        circle.xScale = radius/50
        circle.yScale = radius/50
        circle.physicsBody = SKPhysicsBody (circleOfRadius: circle.size.width + 15)
        circle.physicsBody!.categoryBitMask = ColliderType.Sensor.rawValue
        circle.physicsBody?.collisionBitMask = 0
        //Need for a FOV detection
        circle.physicsBody?.contactTestBitMask = ColliderType.food.rawValue | ColliderType.obstacles.rawValue | ColliderType.player.rawValue
        circle.userData = NSMutableDictionary ()
        circle.userData?.setValue(counter, forKey: "Key")
        self.addChild(circle)
        Circle.append(circle)
        //Wander Algortim - Sliding Transition
        let target = SKSpriteNode (imageNamed: "")
        target.position = CGPoint (x:0 + circle.position.x, y: radius + circle.position.y )
        target.xScale = radius / 2000
        target.yScale = radius / 2000
        self.addChild(target)
        Target.append(target)
        
    }
    
    //Adding Obstacle and entitles
    func addObstacle()
    {
        let ri = Int(arc4random_uniform(UInt32(possibleObs.count)))
        //Declare Obsctacles for Local Variables
        let localobstacle = SKSpriteNode (imageNamed: "obstacles\(ri)")
        //Contain a physics body on the local variables
        localobstacle.physicsBody = SKPhysicsBody (rectangleOf: localobstacle.size)
        //Allow Collision to take place with certain Item ID
        localobstacle.physicsBody?.categoryBitMask = ColliderType.obstacles.rawValue
        localobstacle.physicsBody?.contactTestBitMask = ColliderType.player.rawValue
        localobstacle.physicsBody?.collisionBitMask = ColliderType.player.rawValue
        localobstacle.physicsBody?.isDynamic = false
        localobstacle.physicsBody?.usesPreciseCollisionDetection = true
        //Name the local obstacles
        localobstacle.name = "obstacle"
        
        //Selecting a random x and y position
        while (true)
        {
            //Use a bool to exit the random poistion searching
            var gate = true
            let randomX : CGFloat = CGFloat (arc4random_uniform(UInt32(self.frame.size.width - 100))+55)
            let randomY : CGFloat = CGFloat (arc4random_uniform(UInt32(self.frame.size.height - 150))+50)
            //Set poisition based on random Point
            localobstacle.position = CGPoint(x: randomX,y: randomY)
            //If there is no obstacles within the area
            if locationObstacle.count == 0
            {
                //Add obstacles into the ground
                locationObstacle.append (localobstacle.position)
                self.addChild(localobstacle)
                break
            }
            //However, if != 0
            for sprite in 0 ... locationObstacle.count - 1
            {
                //Set a range of position that is not inbetween the obstacle's range (The obstacle will range about 20 units long from each other)
                if (localobstacle.position.x > locationObstacle [sprite].x - 30 && localobstacle.position.x < locationObstacle [sprite].x + 30 ) && (localobstacle.position.y > locationObstacle [sprite].y - 30 &&
                    localobstacle.position.y < locationObstacle [sprite].y + 30)
                {
                    //But, if it lies witin another obstacle range
                    //Re-determine the random function
                    gate = false
                    break
                }
            }
            //If the random Point is safe
            if gate == true
            {
                //Store and break out of the random loop
                locationObstacle.append (localobstacle.position)
                self.addChild(localobstacle)
                break
            }
        }
    }
    
    //Develop Food and Image
    func addFood ()
    {
        //Set up SpriteNode and Image
        let localFood = SKSpriteNode (imageNamed: "food")
        localFood.physicsBody = SKPhysicsBody (rectangleOf: localFood.size)
        localFood.physicsBody?.categoryBitMask = ColliderType.food.rawValue
        localFood.physicsBody?.contactTestBitMask = ColliderType.player.rawValue
        localFood.physicsBody?.collisionBitMask = ColliderType.player.rawValue
        localFood.physicsBody?.isDynamic = false
        localFood.physicsBody?.usesPreciseCollisionDetection = true
        localFood.name = "food"
        while true
        {
            //Find Random Position and see if it is safe, if it is, allow to place
            var gate = true
            let randomX : CGFloat = CGFloat (arc4random_uniform(UInt32(self.frame.size.width - 100))+55)
            let randomY : CGFloat = CGFloat (arc4random_uniform(UInt32(self.frame.size.height - 150))+50)
            //Set poisition based on random Point
            localFood.position = CGPoint(x: randomX,y: randomY)
            //If there is no obstacles within the area
            if locationFood.count == 0
            {
                //Add obstacles into the ground
                locationFood.append (localFood.position)
                self.addChild(localFood)
                break
            }
            //However, if != 0
            for sprite in 0 ... locationFood.count - 1
            {
                //Set a range of position that is not inbetween the obstacle's range (The obstacle will range about 20 units long from each other)
                if (localFood.position.x > locationFood [sprite].x - 30 && localFood.position.x < locationFood [sprite].x + 30 ) && (localFood.position.y > locationFood [sprite].y - 30 &&
                    localFood.position.y < locationFood [sprite].y + 30)
                {
                    //But, if it lies witin another obstacle range
                    //Re-determine the random function
                    gate = false
                    break
                }
            }
            //If the random Point is safe
            if gate == true
            {
                //Store and break out of the random loop
                locationFood.append (localFood.position)
                self.addChild(localFood)
                break
            }
        }
    }
    
    
    //Function for updating the player's speed and direction
    func updatePlayer (player: SKSpriteNode,health: SKSpriteNode, target: SKSpriteNode, circle: SKSpriteNode, counter: Int )
    {
        //Design a desireable location
        var targetLoc = target.position
        //Find the distance in between the target and the player
        var desiredDirection = CGPoint (x: targetLoc.x - player.position.x ,y: targetLoc.y - player.position.y )
        
        //Normalized the distance to a unit of 1
        desiredDirection = desiredDirection.normalized()
        
        //Find the speed and its movement
        let velocity = CGPoint (x: desiredDirection.x*speedD, y:desiredDirection.y*speedD)
        //Re-position the player
        player.position = CGPoint (x: player.position.x + velocity.x, y: player.position.y + velocity.y)
        player.zRotation = velocity.angleForVector() - 90 * CGFloat (M_PI/180)
        playerRef.append (player.zRotation)
        
        //See if the player exit out of the screen, reposition themselves
        
        if (player.position.x >= frame.size.width)
        {
            player.position = CGPoint (x:player.position.x - size.width,y:player.position.y)
        }
        if (player.position.x <= 0)
        {
            player.position = CGPoint (x:player.position.x + size.width,y:player.position.y)
        }
        if (player.position.y >= frame.size.height)
        {
            player.position = CGPoint (x:player.position.x,y:player.position.y - size.height)
        }
        if (player.position.y <= 0)
        {
            player.position = CGPoint (x:player.position.x,y:player.position.y + size.height)
        }
        
        //Reposition the Health bar to match up the player
        health.position = CGPoint (
            x: player.position.x,
            y: player.position.y - player.size.height/2 - 15
        )
        
        //Decrease its health according to movement
        playerHP [counter] -= 1
        //Declare a circle location, which takes in the unit 1
        var circleLoc = velocity.normalized()
        //Re-define the circleLoc to maintain its distance and take in the travelled distance
        circleLoc = CGPoint (x: circleLoc.x*distance, y: circleLoc.y*distance)
        //Reset the position of the circle's location to continue the player's circular movement
        circleLoc = CGPoint (x: player.position.x + circleLoc.x, y: player.position.y + circleLoc.y)
        
        //Develop an angle for the player to move within
        if ReponseSystem [counter] == 2
        {
            angle [counter] = angle [counter] + CGFloat (-angleNosise) //Left
            //print ("left")
        }
        else if ReponseSystem [counter] == 1
        {
            angle [counter] = angle [counter] + CGFloat (angleNosise) //Right
            //print ("right")
        }
        else
        {
            angle [counter] = angle [counter] + CGFloat (random(min: -angleNosise, max: angleNosise))
        }
        //Empty out the response system after response
        ReponseSystem [counter] = 0
        //Use direction vectors to calculate the x and y component of the point
        var perimitterPoint = CGPoint (x: CGFloat (cosf(Float(angle [counter]))),y: CGFloat(sinf(Float(angle [counter]))))
        //The "sliding" effect within the target poistion
        perimitterPoint = CGPoint (x: perimitterPoint.x * radius, y: perimitterPoint.y * radius)
        //Relocate the target loc to mimic the steering effect within the circle
        targetLoc = CGPoint (x: circleLoc.x + perimitterPoint.x, y: circleLoc.y + perimitterPoint.y)
        
        //Re-define the location of the circle and the target to allow for continous movement
        circle.position = circleLoc
        target.position = targetLoc
    }
    
    //Deleting Nodes
    func deleteNodes (Onebody: SKSpriteNode)
    {
        Onebody.removeFromParent()
        Onebody.physicsBody = nil
    }
    
    //Collision and Contact Dectection
    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == ColliderType.player.rawValue && contact.bodyB.categoryBitMask == ColliderType.obstacles.rawValue
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else if contact.bodyB.categoryBitMask == ColliderType.player.rawValue && contact.bodyA.categoryBitMask == ColliderType.obstacles.rawValue
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        else if contact.bodyA.categoryBitMask == ColliderType.player.rawValue && contact.bodyB.categoryBitMask == ColliderType.food.rawValue
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else if contact.bodyB.categoryBitMask == ColliderType.player.rawValue && contact.bodyA.categoryBitMask == ColliderType.food.rawValue
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        else if contact.bodyB.categoryBitMask == ColliderType.Sensor.rawValue
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        else if contact.bodyA.categoryBitMask == ColliderType.Sensor.rawValue
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            return
        }
        
        //Object Collision
        if let firstNode = firstBody.node as? SKSpriteNode,
        let secondNode = secondBody.node as? SKSpriteNode
        {
            if firstBody.categoryBitMask == ColliderType.player.rawValue &&
                secondBody.categoryBitMask == ColliderType.obstacles.rawValue
            {
                deleteNodes(Onebody: secondNode)
                if let playerNode = firstBody.node
                {
                    if let num = playerNode.userData?.value(forKey: "Key") as? Int
                    {
                        playerHP [num] -= 100
                        foodeaten [num] += 1
                    }
                }
            }
            if firstBody.categoryBitMask == ColliderType.player.rawValue &&
            secondBody.categoryBitMask == ColliderType.food.rawValue
            {
                deleteNodes(Onebody: secondNode)
                if let playerNode = firstBody.node
                {
                    if let num = playerNode.userData?.value(forKey:"Key") as? Int
                    {
                        playerHP [num] += 50
                        if playerHP [num] > 500
                        {
                            playerHP [num] = MaxHealth
                        }
                    }
                }
            }
            
            if firstBody.categoryBitMask == ColliderType.Sensor.rawValue && (secondBody.categoryBitMask == ColliderType.food.rawValue || secondBody.categoryBitMask == ColliderType.obstacles.rawValue || secondBody.categoryBitMask == ColliderType.player.rawValue)
            {
                if let playerPos = firstBody.node
                {
                    if let num = playerPos.userData?.value(forKey: "Key") as? Int
                    {
                        locationObjPos.0.append (num)
                        locationObjPos.1.append (firstBody.node as! SKSpriteNode)
                        locationObjPos.2.append (secondBody.node as! SKSpriteNode)
                    }
                }
            }
            else if secondBody.categoryBitMask == ColliderType.Sensor.rawValue && firstBody.categoryBitMask == ColliderType.food.rawValue | ColliderType.obstacles.rawValue | ColliderType.player.rawValue
            {
                if let playerPos = secondBody.node
                {
                    if let num = playerPos.userData?.value(forKey: "Key") as? Int
                    {
                        locationObjPos.0.append(num)
                        locationObjPos.1.append (firstBody.node as! SKSpriteNode)
                        locationObjPos.2.append(secondBody.node as! SKSpriteNode)
                    }
                }
            }
        }
    }
   
    //Develop the FOV AI for the player
    func AISensor(numValue: [Int], playPos: [SKSpriteNode], objPos: [SKSpriteNode])
    {
        var input = Array (repeating: CGFloat (0.0), count: 36)
        var Allow = false
        if numValue.count == 0
        {
            return
        }
        for individual in 0...numValue.count - 1
        {
            for tracking in 0...objPos.count - 1
            {
                var Setfactor = 1
                
                if objPos [tracking].physicsBody?.categoryBitMask == ColliderType.food.rawValue
                {
                    //Food Section - Neuron
                    Setfactor = 1
                }
                else if objPos [tracking].physicsBody?.categoryBitMask == ColliderType.obstacles.rawValue
                {
                    //Obstacles Section - Neuron
                    Setfactor = 2
                }
                else if objPos [tracking].physicsBody?.categoryBitMask == ColliderType.player.rawValue
                {
                    //Player Section - Neuron
                    Setfactor = 3
                }
                
                //1
                let gapLength = CGPoint (x: playPos [individual].position.x - objPos [tracking].position.x, y: playPos [individual].position.y - objPos [tracking].position.y)
                let gapDistance = gapLength.length()
                let AngluarPos: CGFloat = atan2 (CGFloat(gapLength.y), CGFloat(gapLength.x))
                if AIradius > gapDistance
                {
                    if AngluarPos > (playerRef [numValue [individual]] - FieldView/2) && AngluarPos < (playerRef [numValue [individual]] + FieldView/2)
                    {
                        Allow = true
                        //Left Side of the 90 deg
                        if AngluarPos > (playerRef [numValue [individual]] - FieldView/2)
                        {
                            if AngluarPos > (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //1
                                    input [Setfactor  - 1] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //2
                                    input [Setfactor + 2] = gapDistance
                                }
                            }
                            else if AngluarPos < (playerRef [numValue [individual]] - FieldView/6) && AngluarPos > (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //3
                                    input [Setfactor  + 5] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //4
                                    input [Setfactor  + 8] = gapDistance
                                }
                            }
                            else if AngluarPos < (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //5
                                    input [Setfactor  + 11] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //6
                                    input [Setfactor  + 14] = gapDistance
                                }
                            }
                        }
                            //Right Side of the 90 deg
                        else if AngluarPos < (playerRef [numValue [individual]] + FieldView/2)
                        {
                            if AngluarPos > (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //7
                                    input [Setfactor  + 17] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //8
                                    input [Setfactor  + 20] = gapDistance
                                }
                            }
                            else if AngluarPos < (playerRef [numValue [individual]] - FieldView/6) && AngluarPos > (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //9
                                    input [Setfactor  + 23] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //10
                                    input [Setfactor + 26] = gapDistance
                                }
                            }
                            else if AngluarPos < (playerRef [numValue [individual]] - FieldView/6)
                            {
                                if AngluarPos > (playerRef [numValue [individual]] - FieldView/12)
                                {
                                    //11
                                    input [Setfactor + 29] = gapDistance
                                }
                                else if AngluarPos < (playerRef [numValue [individual]] + FieldView/12)
                                {
                                    //12
                                    input [Setfactor  + 32] = gapDistance
                                }
                            }
                        }
                    }
                    
                }
                
            }
            if Allow == true
            {
                //If accesses the FOV, it activates the neural network
                ReponseSystem [numValue [individual]] = NeuralNetwork(Parent: PopulationDNA [numValue [individual]], Weights: NeuralWeights [numValue[individual]], Sensory: input)
                input = Array (repeating: CGFloat (0.0), count: 36)
            }
        }
    }
    
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: CGFloat) {
        
        let barSize = CGSize(width: HealthBarWidth, height: HealthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
        context!.stroke(borderRect, width: 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(MaxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        context!.fill(barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage!)
        node.size = barSize
    }
    
    func goToGameScene ()
    {
        let gameScene: GameScene = GameScene(size: self.view!.bounds.size) // create your new scene
        let transition = SKTransition.fade(withDuration: 1.0) // create type of transition (you can check in documentation for more transtions)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    //Update within frames
    override func update(_ currentTime: TimeInterval) {
        //Update players
        self.enumerateChildNodes(withName: "player")
        {
            node, stop in
            if let num = node.userData?.value(forKey: "Key") as? Int
            {
                self.updatePlayer(player:node as! SKSpriteNode, health:self.HealthBar [num], target: self.Target [num], circle: self.Circle [num], counter: num)
                if self.playerHP [num] <= 0
                {
                    self.deleteNodes(Onebody: node as! SKSpriteNode)
                    GroupFitness [num] = EvalutionMod(Time: currentTime, Food: self.foodeaten [num])
                }
                self.updateHealthBar(node: self.HealthBar [num], withHealthPoints: self.playerHP [num])
                self.counter += 1
            }
        }
        
        if counter == 0
        {
            game.IsOver = true
            Generation += 1
            let Picker = RouletteSel(Generation: PopulationDNA ,GenFitness: GroupFitness)
            var breeding = [[Int]] ()
            var breedingWeights = [[CGFloat]] ()
            for x in 0...Picker.count - 1
            {
                breeding.append (PopulationDNA [Picker [x]])
                breedingWeights.append (SplitNeuralWeights [Picker [x]])
            }
            (PopulationDNA,SplitNeuralWeights) = CrossingOver(Population: breeding, inDividualWeight: breedingWeights)
            PopulationDNA = Mutation(Population: PopulationDNA)
            NeuralWeights = [[CGFloat]] ()
            lastUpdateTime = currentTime
            removeAllChildren()
            goToGameScene()
        }
        
        counter = 0
        
        //If the node of the obstacle exceed 6, the obstacle will relocate themselves
        if locationObstacle.count >= 10
        {
            //In the child node, where the node are called "obstacles"
            self.enumerateChildNodes(withName: "obstacle")
            {
                node, stop in
                //Remove nodes within the parent node
                node.removeFromParent();
                node.physicsBody = nil
            }
            //Clear the location of the stored nodes (obstacles)
            locationObstacle = []
        }
        
        if locationFood.count >= 10
        {
            self.enumerateChildNodes(withName: "food")
            {
                node, stop in
                node.removeFromParent();
                node.physicsBody = nil
            }
            locationFood = []
        }
        
        AISensor(numValue: locationObjPos.0, playPos: locationObjPos.1, objPos: locationObjPos.2)
        playerRef = Array (repeating: 0, count: Population)
    }
}
