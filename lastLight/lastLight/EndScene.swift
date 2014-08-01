//
//  EndScene.swift
//  anoid
//
//  Created by Juan Pedro Lozano on 18/07/14.
//  Copyright (c) 2014 Juan Pedro Lozano. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
    var endRecord = 0
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        let endGameLabel = SKLabelNode(text:"Best record \(endRecord)")
        endGameLabel.fontColor = SKColor.whiteColor()
        endGameLabel.fontName  = "Futura Medium"
        endGameLabel.fontSize = 40
        endGameLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(endGameLabel)
        
        let playAgainLabel = SKLabelNode(text: "Tap for play again")
        playAgainLabel.fontColor = SKColor.grayColor()
        playAgainLabel.fontName = endGameLabel.fontName
        playAgainLabel.fontSize = 20
        playAgainLabel.position = CGPointMake(CGRectGetMidX(self.frame), endGameLabel.position.y - playAgainLabel.frame.size.height)
        self.addChild(playAgainLabel)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let repeatGame = GameScene(size: self.size)
        self.view.presentScene(repeatGame, transition: SKTransition.doorsOpenHorizontalWithDuration(0.35))
    }
}
