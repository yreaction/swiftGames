//
//  GameScene.swift
//  lastLight
//
//  Created by Juan Pedro Lozano on 28/07/14.
//  Copyright (c) 2014 Juan Pedro Lozano. All rights reserved.
//


import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    //ball Shape
    private let ballNode = SKShapeNode(circleOfRadius: 20)
    let bottomEdge = SKNode()
    var scoreValue = Int(0)
    var ballImpulseVector = CGVectorMake(0, 40)
    var leftSprite = SKSpriteNode()
    var leftDownSprite = SKSpriteNode()
    var rightSprite = SKSpriteNode()
    var rightDownSprite = SKSpriteNode()
    var moveSpeed = CGFloat(5)
    var ballIncrease = CGFloat(0.9)
    let scoreLabel = SKLabelNode(fontNamed: "Futura Medium")
    var contactSpark = false
    //wall constants
    let wallBlocks = 7
    var heightSpace:CGFloat = 0.00
    
    //lightShadows
    let lightOne = SKLightNode()
    
    
    enum categoriesMaps: UInt32 {
        case ball = 1
        case block = 2
        case bottomEdge = 4
        case edgeWorld = 8
        case sparks = 16
    }
    
    enum wallSides {
        case rightSide
        case leftSide
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody.categoryBitMask = categoriesMaps.edgeWorld.toRaw()
        self.physicsBody.collisionBitMask = categoriesMaps.ball.toRaw()
        self.physicsBody.restitution = 0
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.blackColor()
    
        
        scoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame)-75)
        scoreLabel.fontSize = 50

        scoreLabel.text = "0"
        self.addChild(scoreLabel)
        
        
        bottomEdge.physicsBody = SKPhysicsBody (edgeFromPoint: CGPoint(x: 0, y: 25), toPoint: CGPoint(x:self.size.width,y:25))
        bottomEdge.physicsBody.categoryBitMask  = categoriesMaps.bottomEdge.toRaw()
        self.addChild(bottomEdge)
        
        heightSpace = self.frame.size.height / CGFloat (wallBlocks)
        
        leftSprite = self.addWall(self.size, side:wallSides.leftSide)
        self.addChild(leftSprite)
       

        rightSprite = self.addWall(self.size, side:wallSides.rightSide)
        self.addChild(rightSprite)
        
        leftDownSprite = self.addWall(self.size, side:wallSides.leftSide)
        leftDownSprite.position = CGPoint(x: 25, y: self.size.height + heightSpace/2)
        self.addChild(leftDownSprite)

        rightDownSprite = self.addWall(self.size, side:wallSides.rightSide)
        rightDownSprite.position = CGPointMake(self.size.width-25, self.size.height*2 + heightSpace*2)
        self.addChild(rightDownSprite)
        
        /* Ball setUp */
        ballNode.position = CGPointMake(CGRectGetMidX(self.frame) - ballNode.frame.size.width/4, CGRectGetMidY(self.frame) - ballNode.frame.size.height/4)
        ballNode.fillColor = SKColor.redColor()
        ballNode.strokeColor = SKColor.clearColor()
        
        /*add physics to Ball*/
        
        ballNode.physicsBody = SKPhysicsBody(circleOfRadius: ballNode.frame.size.width/2)
        ballNode.physicsBody.restitution = 0
        ballNode.physicsBody.categoryBitMask = categoriesMaps.ball.toRaw()
        ballNode.physicsBody.contactTestBitMask = categoriesMaps.block.toRaw() | categoriesMaps.bottomEdge.toRaw()
        self.addChild(ballNode)
      
        self.paused = true
    }
    func random() -> UInt32 {
        var range = UInt32(1)...UInt32(4)
        return range.startIndex + arc4random_uniform(range.endIndex - range.startIndex + 1)
    }
    func createSparks(coords:CGPoint) {
        contactSpark = false
        for _ in 0...5 {
            let shape = SKShapeNode(circleOfRadius:CGFloat(self.random()))
            shape.position = CGPoint(x:coords.x,y:coords.y)
            shape.fillColor = SKColor.yellowColor()
            //shape.blendMode = SKBlendMode.Multiply
            shape.lineWidth = 0
            shape.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/4)
            shape.physicsBody.categoryBitMask = categoriesMaps.sparks.toRaw()
            shape.physicsBody.collisionBitMask = categoriesMaps.block.toRaw() | categoriesMaps.ball.toRaw()
            shape.physicsBody.restitution = 0
            shape.physicsBody.friction = 1
            shape.physicsBody.linearDamping = 0
            self.addChild(shape)
            if coords.x > CGRectGetMidX(self.frame) {
                shape.physicsBody.applyImpulse(CGVectorMake(shape.frame.size.width/10, 0))
            } else
            {
                shape.physicsBody.applyImpulse(CGVectorMake(shape.frame.size.width/10, 0))
            }
            shape.runAction((SKAction.sequence([SKAction.waitForDuration(1),SKAction.fadeAlphaBy(0.5, duration:0.15)])), completion:{
                shape.removeFromParent()
                } )
            }
    

    }
    
    func didBeginContact(contact: SKPhysicsContact!) {

        var notTheBall:SKPhysicsBody?;
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            notTheBall = contact.bodyB
        } else {
            notTheBall = contact.bodyA
        }
        if notTheBall?.categoryBitMask == categoriesMaps.block.toRaw() {
            //Brick touch
            ballIncrease = 1.00
            if contactSpark { self.createSparks(contact.contactPoint)}
            var colorAction = SKAction.customActionWithDuration(1.0, actionBlock: {(node:SKNode?,speed:CGFloat) -> Void in let test = node as SKShapeNode;test.fillColor = SKColor.greenColor()})
            notTheBall?.node.runAction(colorAction)
            ballNode.runAction(SKAction.scaleTo(ballIncrease, duration: 0.15))
            
        } else {
            //Paddle
        }
        if notTheBall?.categoryBitMask == categoriesMaps.bottomEdge.toRaw() {
            self.gameEnds()
        }

        
       
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.paused = false
        ballIncrease -= 0.05
        contactSpark = true
        ++scoreValue
        let position = (ballNode.position.x,ballNode.position.y)
        switch position {
        case (self.view.frame.size.width/2...self.view.frame.size.width,_):
            self.ballImpulseVector.dx = -30
        case (0...self.view.frame.size.width/2,_):
            self.ballImpulseVector.dx = +30
        default:
            assert(position.0 < 0 && position.0 > self.view.frame.size.width , "Posicion no puede ser inferior a 0")
        }
       
        ballNode.physicsBody.applyImpulse(ballImpulseVector)
        ballNode.runAction(SKAction.scaleBy(ballIncrease, duration: 0.25))
    }
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!)  {
    }
    
    func addWall (size: CGSize, side:wallSides) -> SKSpriteNode {
        
        var spriteBlocks = SKSpriteNode()
        let blocks = size.height / CGFloat (wallBlocks)
        for i in 1...wallBlocks {
            let blockShape = SKShapeNode(rectOfSize: CGSize(width: 50, height: blocks))
            blockShape.position = CGPoint(x:0,y:Int(blocks)*(i-1))
            blockShape.lineWidth = 0
            blockShape.fillColor = SKColor.redColor()
            blockShape.physicsBody = SKPhysicsBody(rectangleOfSize: blockShape.frame.size)
            blockShape.physicsBody.dynamic = false
            blockShape.physicsBody.categoryBitMask = categoriesMaps.block.toRaw()
            
            let addBlock = arc4random()%4
            if addBlock != 3{
            spriteBlocks.addChild(blockShape)
            }
        }
        switch side {
        case  wallSides.leftSide:
            spriteBlocks.position = CGPoint(x:25,y:blocks/2)
            spriteBlocks.shadowCastBitMask = 1
        case wallSides.rightSide:
            spriteBlocks.position = CGPoint(x:size.width - 25,y:blocks/2)

        default:
            println("no Wall Side")
        }
        return spriteBlocks
    }
    func gameEnds () {
        let scena = EndScene(size: self.size)
        scena.endRecord = self.scoreValue
        self.view.presentScene(scena, transition: SKTransition.doorsCloseHorizontalWithDuration(0.25))

    }
    override func update(currentTime: CFTimeInterval) {
        if !self.paused {
        self.scoreLabel.text = "\(scoreValue)"
        if ballNode.frame.size.width < 10 {
            self.gameEnds()
        }
        if leftSprite.position.y < -(self.size.height - heightSpace/2 - CGFloat(wallBlocks)) {
            leftSprite.removeFromParent()
            leftSprite = self.addWall(self.size, side: wallSides.leftSide)
            leftSprite.position.y =  (self.size.height + heightSpace/2 - CGFloat(wallBlocks))
            self.addChild(leftSprite)
        } else {
            leftSprite.position.y -=  moveSpeed
        }

        if leftDownSprite.position.y < -(self.size.height - heightSpace/2 - CGFloat(wallBlocks))  {
            leftDownSprite.removeFromParent()
            leftDownSprite = self.addWall(self.size, side: wallSides.leftSide)
            leftDownSprite.position.y =  (self.size.height + heightSpace/2 - CGFloat(wallBlocks))
            self.addChild(leftDownSprite)
        } else {
            leftDownSprite.position.y -=  moveSpeed
        }
        
        if rightSprite.position.y < -(self.size.height - heightSpace/2 - CGFloat(wallBlocks)) {
            rightSprite.removeFromParent()
            rightSprite = self.addWall(self.size, side: wallSides.rightSide)
            rightSprite.position.y =  (self.size.height + heightSpace/2 - CGFloat(wallBlocks))
            self.addChild(rightSprite)
        } else {
            rightSprite.position.y -= moveSpeed
        }
        if rightDownSprite.position.y < -(self.size.height - heightSpace/2 - CGFloat(wallBlocks)) {
            rightDownSprite.removeFromParent()
            rightDownSprite = self.addWall(self.size, side: wallSides.rightSide)
            rightDownSprite.position.y =  (self.size.height + heightSpace/2 - CGFloat(wallBlocks))
            self.addChild(rightDownSprite)
        } else {
            rightDownSprite.position.y -=  moveSpeed
        }
        
        }
    }
  
}

