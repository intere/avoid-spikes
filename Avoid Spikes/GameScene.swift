//
//  GameScene.swift
//  Avoid Spikes
//
//  Created by Internicola, Eric on 2/24/16.
//  Copyright (c) 2016 iColasoft. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var player: SKSpriteNode?
    var spike: SKSpriteNode?
    var ground: SKSpriteNode?

    var lblMain: SKLabelNode?
    var lblScore: SKLabelNode?

    var spikeSpeed = 1.0
    var isAlive = true
    var score = 0
    var location: CGPoint?
    var spikeTimeSpawnNumber = 0.3

    let offWhiteColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    let offBlackColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)

    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.orangeColor()
        physicsWorld.contactDelegate = self

        spawnPlayer()
        spawnGround()

        spawnMainLabel()
        spawnScoreLabel()

        spawnSpikeTimer()
        hideLabel()
        updateScoreTimer()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            location = touch.locationInNode(self)
            if let player = player, location = location where isAlive {
                player.position.x = location.x
            } else if let player = player where !isAlive {
                player.position.x = -200
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {

    }
}


// MARK: - Spawn Functions
extension GameScene {
    func spawnPlayer() {
        player = SKSpriteNode(color: offWhiteColor, size: CGSize(width: 50, height: 50))
        if let player = player {
            player.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMinY(frame) + 100)
            player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.dynamic = true
            player.physicsBody?.categoryBitMask = PhysicsCategory.player
            player.physicsBody?.contactTestBitMask = PhysicsCategory.spike

            addChild(player)
        }
    }

    func spawnSpike() {
        spike = SKSpriteNode(color: offBlackColor, size: CGSize(width: 10, height: 125))
        if let spike = spike {
            spike.position.x = CGFloat(arc4random_uniform(UInt32(frame.size.width)))
            spike.position.y = CGRectGetMaxY(frame)+spike.size.height
            spike.physicsBody = SKPhysicsBody(rectangleOfSize: spike.size)
            spike.physicsBody?.affectedByGravity = false
            spike.physicsBody?.allowsRotation = false
            spike.physicsBody?.dynamic = true
            spike.physicsBody?.categoryBitMask = PhysicsCategory.spike
            spike.physicsBody?.collisionBitMask = PhysicsCategory.player

            spike.runAction(SKAction.moveToY(-200, duration: spikeSpeed))
            addChild(spike)
        }
    }

    func spawnGround() {
        ground = SKSpriteNode(color: offBlackColor, size: CGSize(width: CGRectGetWidth(frame), height: 150))
        if let ground = ground {
            ground.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMinY(frame))
            addChild(ground)
        }
    }

    func spawnMainLabel() {
        lblMain = SKLabelNode(fontNamed: "Futura")
        if let lblMain = lblMain {
            lblMain.fontSize = 100
            lblMain.fontColor = offWhiteColor
            lblMain.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame)+150)
            lblMain.text = "Start!"

            addChild(lblMain)
        }
    }

    func spawnScoreLabel() {
        lblScore = SKLabelNode(fontNamed: "Futura")
        if let lblScore = lblScore {
            lblScore.fontSize = 50
            lblScore.fontColor = offWhiteColor
            lblScore.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMinY(frame)+25)
            lblScore.text = "Start!"

            addChild(lblScore)
        }
    }
}

// MARK: - Spawn Timer Functions
extension GameScene {
    func spawnSpikeTimer() {
        let spikeTimer = SKAction.waitForDuration(spikeTimeSpawnNumber)
        let spawn = SKAction.runBlock {
            if self.isAlive {
                self.spawnSpike()
            }
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence([spikeTimer, spawn])))
    }

    func hideLabel() {
        let wait = SKAction.waitForDuration(3)
        let hideLabel = SKAction.runBlock {
            self.lblMain?.alpha = 0
        }
        runAction(SKAction.sequence([wait, hideLabel]))
    }

    func updateScoreTimer() {
        let wait = SKAction.waitForDuration(1)
        let scoreAction = SKAction.runBlock {
            if self.isAlive {
                self.score += 1
                self.updateScore()
            }
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence([wait, scoreAction])))
    }
}


// MARK: - Physics Delegate
extension GameScene : SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if (firstBody.categoryBitMask == PhysicsCategory.player && secondBody.categoryBitMask == PhysicsCategory.spike) || (firstBody.categoryBitMask == PhysicsCategory.spike && secondBody.categoryBitMask == PhysicsCategory.player) {
            spikeCollision(firstBody.node as? SKSpriteNode, spikeTemp: secondBody.node as? SKSpriteNode)
        }
    }

    func spikeCollision(playerTemp: SKSpriteNode?, spikeTemp: SKSpriteNode?) {
        if let _ = playerTemp, spikeTemp = spikeTemp {
            spikeTemp.removeFromParent()
            isAlive = false
            showGameOver()
        }
    }

    func showGameOver() {
        if let lblMain = lblMain {
            lblMain.alpha = 1
            lblMain.fontSize = 75
            lblMain.text = "Game Over"
        }
    }
}

// MARK: - PhysicsCategory
extension GameScene {
    struct PhysicsCategory {
        static let player: UInt32 = 0
        static let spike: UInt32 = 2 >> 0
    }
}

// MARK: - Helper Methods
extension GameScene {
    func updateScore() {
        if let lblScore = lblScore {
            lblScore.text = "Score: \(score)"
        }
    }
}