//
//  GameScene.swift
//  Car_game2
//
//  Created by Anthony Dinh on 7/5/18.
//  Copyright © 2018 Anthony Dinh. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var car = SKSpriteNode()
    var scoreText = SKLabelNode()
    var stopEverything = true
    var score = 0
    var centerPoint: CGFloat!
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    let trafficCat:UInt32 = 0x1 << 1
    let carCat: UInt32 = 0x1 << 0
    
    var gameSettings = Settings.sharedInstance
    
    
//    var scoreLabel:SKLabelNode!
//    var score: Int = 0 {
//        didSet {
//            scoreLabel.text = "Score: \(score)"
//        }
//    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        car = SKSpriteNode(imageNamed: "car")
        car.position = CGPoint(x: self.frame.size.width / 2, y: car.size.height/2 + 20)
        self.addChild(car)
        
        createRoadStrip()
        setUp()
        Timer.scheduledTimer(timeInterval: (0.2), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: (TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8))), target: self, selector: #selector(GameScene.traffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
//        let deadTime = DispatchTime.now() + 1
//        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
//        }
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error:Error?) in if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
                self.yAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.25
            }
        }

    }
    
    override func update(_ currentTime: TimeInterval) {
        showRoadStrip()
    }
    
    @objc func createRoadStrip() {
        let RoadStrip = SKShapeNode(rectOf:CGSize (width: 10, height: 40) )
        RoadStrip.strokeColor = SKColor.white
        RoadStrip.fillColor = SKColor.white
        RoadStrip.alpha = 0.4
        RoadStrip.name = "RoadStrip" 
        RoadStrip.zPosition = 10
        RoadStrip.position.x = -107.5
        RoadStrip.position.y = 700
        addChild(RoadStrip)
        
        let RoadStrip1 = SKShapeNode(rectOf:CGSize (width: 10, height: 40) )
        RoadStrip1.strokeColor = SKColor.white
        RoadStrip1.fillColor = SKColor.white
        RoadStrip1.alpha = 0.4
        RoadStrip1.name = "RoadStrip1"
        RoadStrip1.zPosition = 9
        RoadStrip1.position.x = 107.5
        RoadStrip1.position.y = 700
        addChild(RoadStrip1)
    }
    
    func showRoadStrip () {
        enumerateChildNodes(withName: "RoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 15
        })
        enumerateChildNodes(withName: "RoadStrip1", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 15
        })
        enumerateChildNodes(withName: "cone", using: { (car, stop) in
            let car = car as! SKSpriteNode
            car.position.y -= 15
        })
        enumerateChildNodes(withName: "tree", using: { (car, stop) in
            let car = car as! SKSpriteNode
            car.position.y -= 15
        })
        enumerateChildNodes(withName: "rock", using: { (car, stop) in
            let car = car as! SKSpriteNode
            car.position.y -= 15
        })
    }
    
    @objc func removeItems() {
        for child in children {
            if child.position.y < -self.size.height - 100 {
                child.removeFromParent()
            }
        }
    }
    
    @objc func traffic() {
        let trafficItem: SKSpriteNode!
        let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 9)
        switch Int(randomNumber) {
        case 1...3:
            trafficItem = SKSpriteNode(imageNamed: "cone")
            trafficItem.name = "cone"
                break
        case 4...6:
            trafficItem = SKSpriteNode(imageNamed: "rock")
            trafficItem.name = "rock"
                break
        case 7...9:
            trafficItem = SKSpriteNode(imageNamed: "tree")
            trafficItem.name = "tree"
                break
        default:
            trafficItem = SKSpriteNode(imageNamed: "cone")
            trafficItem.name = "cone"
        }
        trafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        trafficItem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 12)
        switch Int(randomNum) {
        case 1...4:
            trafficItem.position.x = -280
            break
        case 5...8:
            trafficItem.position.x = 280
            break
        case 9...12:
            trafficItem.position.x = 0
        default:
            trafficItem.position.x = 0
        }
        trafficItem.position.y = 700
        trafficItem.position.y = 700
        trafficItem.physicsBody = SKPhysicsBody(circleOfRadius: trafficItem.size.height/4)
        trafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        trafficItem.physicsBody?.contactTestBitMask = ColliderType.CAR_COLLIDER
        trafficItem.physicsBody?.collisionBitMask = ColliderType.CAR_COLLIDER
        trafficItem.physicsBody?.affectedByGravity = false
        addChild(trafficItem)
    }
    
    func afterCollision() {
        gameSettings.highScore = score
        let gameOverScene = SKScene(fileNamed: "GameOverMenu")!
        gameOverScene.scaleMode = .aspectFill
        view?.presentScene(gameOverScene, transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(2)))
    }
    
    func setUp() {

        car = self.childNode(withName:"car") as! SKSpriteNode
        centerPoint = self.frame.size.width / self.frame.size.height
        
        car.physicsBody = SKPhysicsBody(circleOfRadius: car.size.height/4)
        car.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        car.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        car.physicsBody?.collisionBitMask = ColliderType.ITEM_COLLIDER_1
        car.physicsBody?.affectedByGravity = false
        
        let scoreBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 70 ,y:self.size.height/2 - 130 ,width:180,height:80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AmericaTypewriter-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    
    @objc func increaseScore(){
            score += 1
            scoreText.text = String(score)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "car" {
            firstBody = contact.bodyA
        }
        else {
            firstBody = contact.bodyB
        }
        firstBody.node?.removeFromParent()
        print("we Have contact")
        afterCollision()
    }
    
    
    override func didSimulatePhysics() {
        car.position.x += xAcceleration * 20
        car.position.y += yAcceleration * 20
        
        if car.position.x < -340 {
            car.position = CGPoint(x:-240, y: car.position.y)
        }
        else if car.position.x > 340 {
            car.position = CGPoint(x: 240, y: car.position.y)
        }
       if car.position.y < -740 {
            car.position = CGPoint(x:car.position.x, y: 0)
        }
        else if car.position.y > 340 {
            car.position = CGPoint(x: car.position.x, y: 200)
        }
    }
}
