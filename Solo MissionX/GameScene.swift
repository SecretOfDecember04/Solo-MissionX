//
//  GameScene.swift
//  Solo MissionX
//
//  Created by Longxuan Lin on 1/16/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var gameScore = 0
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    
    let player = SKSpriteNode (imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("gamesound", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSound", waitForCompletion: false)
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    var gameArea: CGRect
    
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height*0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.05, y: self.size.height*0.9)
        self.addChild(livesLabel)
        
        
        
        startNewLevel()
        
    }
    
    
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
    }
    
    
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
            startNewLevel()
        }
        
    }
    
    func fireB() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let removeBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, removeBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)

        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            //if the player has hit the enemy
            
            
            if body1.node != nil{
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return
                }
                else{
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            addScore()
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        
        
        
        
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    
    func startNewLevel(){
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Cannot find level info")
        }
        
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
        
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
            
            if player.position.x > CGRectGetMaxX(gameArea) - player.size.width/2{
                player.position.x = CGRectGetMaxX(gameArea) - player.size.width/2
            }
            
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width/2{
                player.position.x = CGRectGetMinX(gameArea) + player.size.width/2
            }
            
            
            
        }
    }

}
