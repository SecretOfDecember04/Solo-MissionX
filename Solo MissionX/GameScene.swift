//
//  GameScene.swift
//  Solo MissionX
//
//  Created by Longxuan Lin on 1/16/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = SKSpriteNode (imageNamed: "playerShip")
    
    
    let bulletSound = SKAction.playSoundFileNamed("gamesound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.setScale(2)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
        
    }
    
    
    func fireB() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(2)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let removeBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, removeBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireB()
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let prevPointOfTouch = touch.previousLocation(in: self)
            
            let amount = pointOfTouch.x - prevPointOfTouch.x
            player .position.x += amount
            
        }
    }

}
