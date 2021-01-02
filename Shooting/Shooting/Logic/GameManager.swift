//
//  GameManager.swift
//  Shooting
//
//  Created by rio on 2020/12/26.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation
import SpriteKit

class GameManager {
    unowned var scene: SKScene!
    var duckList:[Duck] = []
    var targetList: [Target] = []
    
    //timer
    var duckTimer: Timer!
    var targetTimer: Timer!
    var displayTimer:Timer!
    
    //node
    let label = SKLabelNode()
    var timeNode = SKNode()
    var bestScoreNode = SKSpriteNode()
    
    //score
    var totalScore = 0
    let targetScore = 10
    let duckScore = 10
    var bestScore = 0
    
    //count
    var duckCount = 0
    var targetCount = 0
    
    //time
    var gameTime = 20
    
    //vertical
    var duckV = 7
    var duckTargetV = 5
    var dV = 0
    
    var info2 = "再来一局吧，击倒屏幕左侧的靶子go！go！go！"
    
    //game process type
    var gameType = "before"
    {
        didSet{
            if gameType == "ing"{
                activeDucks()
                activeTargets()
                activeCountDown()
            }
            else if gameType == "end"{
                //delete node,close timer
                createAgainBtn()
                
                
            }
            else if gameType == "again"{

                createStartButton()
                label.removeFromParent()
                bestScoreNode.removeFromParent()
                self.scene.childNode(withName: "best_icon")?.zPosition = -1
            }
        }
    }
    
    var duckMoveDuration: TimeInterval!
    
    let targetXPosition: [Int] = [160,240,320,400,480,560,640]
    var usingTargetXPosition = Array<Int>()
    
    let ammunitionQuantity = 5
    
    var zPositionDecimal = 0.001{
        didSet{
            if zPositionDecimal == 1{
                zPositionDecimal = 0.001
            }
        }
    }
    
    init(scene: SKScene){
        self.scene = scene
        
    }
    
    func createStartButton() {
        var startBtn:SKSpriteNode
        var stick:SKSpriteNode
        let node = Duck(hasTarget: true)
        
        let texture = SKTexture(imageNamed: "duck_target/1")
        
        startBtn = SKSpriteNode(texture: texture)
        startBtn.name = "startBtn"
        startBtn.position = CGPoint(x: 200, y: 140)
        
        let physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        
        startBtn.physicsBody = physicsBody
        
        stick = SKSpriteNode(imageNamed: "stick/1")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 200, y: 0)
        
        startBtn.xScale = 0.8
        startBtn.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(startBtn)
        
        node.position = CGPoint(x: 200, y: 90)
        node.zPosition = 6
        node.zPosition += CGFloat(self.zPositionDecimal)
        self.zPositionDecimal += 0.001
        
        self.scene?.addChild(node)
    }
    
    func generateDuck(hasTarget:Bool = false)->Duck{
        var duck: SKSpriteNode!
        var stick: SKSpriteNode!
        var duckImageName:String
        var duckNodeName:String
        let node = Duck(hasTarget: hasTarget)
        var texture = SKTexture()
        
        if hasTarget{
            duckImageName = "duck_target/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck_target"
            
        }else{
            duckImageName = "duck/\(Int.random(in: 1...3))"
            texture = SKTexture(imageNamed: duckImageName)
            duckNodeName = "duck"
        }
        
        duck = SKSpriteNode(texture: texture)
        duck.name = duckNodeName
        duck.position = CGPoint(x: 0, y: 140)
        
        let physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: texture.size())
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        
        duck.physicsBody = physicsBody
        
        stick = SKSpriteNode(imageNamed: "stick/\(Int.random(in: 1...2))")
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        duck.xScale = 0.8
        duck.yScale = 0.8
        stick.xScale = 0.8
        stick.yScale = 0.8
        
        node.addChild(stick)
        node.addChild(duck)
        
        return node
        
    }
    
    func generateTarget()->Target{
        var target: SKSpriteNode
        var stick: SKSpriteNode
        let node = Target()
        let texture = SKTexture(imageNamed: "target/\(Int.random(in: 1...3))")
        
        target = SKSpriteNode(texture: texture)
        stick = SKSpriteNode(imageNamed: "stick_metal")
        
        target.xScale = 0.5
        target.yScale = 0.5
        target.position = CGPoint(x: 0, y: 95)
        target.name = "target"
        stick.xScale = 0.5
        stick.yScale = 0.5
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        node.addChild(stick)
        node.addChild(target)
        
        return node
    }
    
    func activeDucks(){

        self.duckTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){(timer)in
            let duck = self.generateDuck(hasTarget: Bool.random())
            duck.position = CGPoint(x: -10, y: Int.random(in: 60...90))
            duck.zPosition = Int.random(in: 0...1)==0 ? 4 : 6
            duck.zPosition += CGFloat(self.zPositionDecimal)
            self.zPositionDecimal += 0.001
            
            self.scene?.addChild(duck)
            self.duckList.append(duck)
            
            if duck.hasTarget {
                self.duckMoveDuration = TimeInterval(Int.random(in: (self.duckTargetV+self.dV)...self.duckTargetV))
            }else {
                self.duckMoveDuration = TimeInterval(Int.random(in: (self.duckV+self.dV)...self.duckV))
            }
            
                duck.run(.sequence([.moveTo(x: 850, duration: self.duckMoveDuration),
                                    .run {
                                        self.duckList.remove(at: self.duckList.firstIndex(of: duck)!)
                                        //print(self.duckMoveDuration)
                                    },
                                    .removeFromParent()]))
        }
    }
    
    func activeTargets(){
        self.targetTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){(timer)in
            let target = self.generateTarget()
            var xPosition = self.targetXPosition.randomElement()!
            
            while self.usingTargetXPosition.contains(xPosition){
                xPosition = self.targetXPosition.randomElement()!
            }
            
            self.usingTargetXPosition.append(xPosition)
            target.position = CGPoint(x: xPosition, y:Int.random(in: 120...145))
            target.zPosition = 1
            target.yScale = 0
            self.scene.addChild(target)
            self.targetList.append(target)
            
            let physicsBody = SKPhysicsBody(circleOfRadius: 71/2)
            physicsBody.affectedByGravity = false
            physicsBody.isDynamic = false
            physicsBody.allowsRotation = false
            
            target.run(.sequence([
                .scaleY(to:1,duration:0.2),
                .run {
                    if let node = target.childNode(withName: "target"){
                        node.physicsBody = physicsBody
                    }
                    },
                .wait(forDuration: TimeInterval(Int.random(in: 3...4))),
                .scaleY(to: 0, duration: 0.2),
                .run {
                    self.targetList.remove(at: self.targetList.firstIndex(of: target)!)
                },
                .removeFromParent(),
                .run{
                    self.usingTargetXPosition.remove(at: self.usingTargetXPosition.firstIndex(of: xPosition)!)
                }]))
            
        }
    }
    
    func activeCountDown(){
        Timer.scheduledTimer(withTimeInterval: TimeInterval(gameTime), repeats: false){(timer)in
            self.gameType = "end"
            self.gameOver()
        }
        timeNode = generateTextNode(from: "\(gameTime)")
        timeNode.run(.fadeIn(withDuration: 0.1))
        timeNode.zPosition = 11
        timeNode.position = CGPoint(x: 700, y: 360)
        self.scene.addChild(timeNode)
        var time = gameTime
        displayTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true){(timer)in
            //显示倒计时时间
            time -= 1
            self.update(text: "\(time)", node: &self.timeNode)
            var tmp : Int = (self.gameTime - time)/5
            if tmp > 0 && (time % 5 == 0) && self.dV < 4{
                self.dV -= 1
            }
        }
        
        
            
    }
    
    func gameOver(){
        self.duckTimer.invalidate()
        self.targetTimer.invalidate()
        self.displayTimer.invalidate()
        
        timeNode.run(.fadeOut(withDuration: 0.1))
        
        for duck in duckList{
            duck.physicsBody = nil
            
            duck.run(.sequence([
            //.wait(forDuration: 0.2),
            .scaleY(to: 0.0, duration: 0.1)]))
 
        }
        for target in targetList{
            target.physicsBody = nil
            target.run(.sequence([
            //.wait(forDuration: 0.1),
            .scaleY(to: 0.0, duration: 0.1)]))
        }
        
        self.scene.childNode(withName: "duck_icon")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                    .moveBy(x: 320, y: -120, duration: 0.1),
                                                                    .run {
                                                                        self.scene.childNode(withName: "duck_icon")?.xScale = 2
                                                                        self.scene.childNode(withName: "duck_icon")?.yScale = 2
                                                                        },
                                                                    .fadeIn(withDuration: 0.2)]))
        self.scene.childNode(withName: "target_icon")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                      .moveBy(x: 320, y: -160, duration: 0.1),
                                                                      .run {
                                                                      self.scene.childNode(withName: "target_icon")?.xScale = 2
                                                                      self.scene.childNode(withName: "target_icon")?.yScale = 2
                                                                      },
                                                                      .fadeIn(withDuration: 0.2)]))

        
        
        self.scene.childNode(withName: "duck_score")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                     .moveBy(x: 350, y: -120, duration: 0.1),
                                                                     .run {
                                                                     self.scene.childNode(withName: "duck_score")?.xScale = 1
                                                                     self.scene.childNode(withName: "duck_score")?.yScale = 1
                                                                     },
        
                                                                     .fadeIn(withDuration: 0.2)]))
        self.scene.childNode(withName: "target_score")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                     .moveBy(x: 350, y: -160, duration: 0.1),
                                                                     .run {
                                                                        self.scene.childNode(withName: "target_score")?.xScale = 1
                                                                        self.scene.childNode(withName: "target_score")?.yScale = 1
                                                                     },
        
                                                                     .fadeIn(withDuration: 0.2)]))
        
        //display best score
        if(totalScore > bestScore){
            bestScore = totalScore
        }
        bestScoreNode = self.generateTextNode(from: "\(bestScore)")
        bestScoreNode.position = CGPoint(x: 20, y: 365)
        bestScoreNode.zPosition = 11
        bestScoreNode.xScale = 0.6
        bestScoreNode.yScale = 0.6
        self.scene.addChild(bestScoreNode)
        
        self.scene.childNode(withName: "best_icon")?.zPosition = 11
        
    }
    
    func createAgainBtn(){
        var target: SKSpriteNode
        var stick: SKSpriteNode
        let node = Target()
        let texture = SKTexture(imageNamed: "target/1")
        
        target = SKSpriteNode(texture: texture)
        stick = SKSpriteNode(imageNamed: "stick_metal")
        
        target.xScale = 0.5
        target.yScale = 0.5
        target.position = CGPoint(x: 0, y: 95)
        target.name = "again"
        stick.xScale = 0.5
        stick.yScale = 0.5
        stick.anchorPoint = CGPoint(x: 0.5, y: 0)
        stick.position = CGPoint(x: 0, y: 0)
        
        node.addChild(stick)
        node.addChild(target)
        
        node.position = CGPoint(x: 220, y:145)//本来是500
        node.zPosition = 1
        node.yScale = 1
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 71/2)
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = false
        physicsBody.allowsRotation = false
        
        node.childNode(withName: "again")!.physicsBody = physicsBody
        self.scene.addChild(node)
        
        //again information
        label.text = info2
        label.fontSize = 19
        label.position = CGPoint(x: 390, y: 365)
        label.zPosition = 10.9
        label.fontColor = UIColor.black
        label.name="label2"
        self.scene.addChild(label)
        
     
    }
    
    func scoreBack(duck_node:inout SKNode,target_node:inout SKNode){
        self.scene.childNode(withName: "duck_icon")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                    .moveBy(x: -320, y: 120, duration: 0.1),
                                                                    .run {
                                                                        self.scene.childNode(withName: "duck_icon")?.xScale = 1
                                                                        self.scene.childNode(withName: "duck_icon")?.yScale = 1
                                                                        },
                                                                    .fadeIn(withDuration: 0.2)]))
        self.scene.childNode(withName: "target_icon")?.run(.sequence([.fadeOut(withDuration: 0.2),
                                                                      .moveBy(x: -320, y: 160, duration: 0.1),
                                                                      .run {
                                                                      self.scene.childNode(withName: "target_icon")?.xScale = 1
                                                                      self.scene.childNode(withName: "target_icon")?.yScale = 1
                                                                      },
                                                                      .fadeIn(withDuration: 0.2)]))

        
        
        duck_node.xScale = 0.5
        duck_node.yScale = 0.5
        duck_node.position=CGPoint(x:60,y: 365)
        target_node.position=CGPoint(x:60,y: 325)
        target_node.xScale = 0.5
        target_node.yScale = 0.5;
    }
    
    func findShotNode(at position:CGPoint)->SKSpriteNode{
        
        var shotNode = SKSpriteNode()
        var biggestZPosition: CGFloat = 0.0
        
        self.scene.physicsWorld.enumerateBodies(at: position) { (body, pointer) in
            guard let node = body.node as? SKSpriteNode else {return}
            
            if node.name == "duck" || node.name == "target" || node.name == "duck_target" || node.name == "startBtn" || node.name == "again"{
                if let parentNode = node.parent{
                    if parentNode.zPosition > biggestZPosition{
                        biggestZPosition = parentNode.zPosition
                        shotNode = node
                    }
                }
            }
        }
        
        return shotNode
    }
    
    func addShot(imageNamed imageName: String, to node: SKSpriteNode, on position: CGPoint){
        let convertedPosition = scene.convert(position, to: node)
        let shot = SKSpriteNode(imageNamed: imageName)
        
        shot.position = convertedPosition
        node.addChild(shot)
        shot.run(.sequence([
            .wait(forDuration: 2),
            .fadeAlpha(to: 0.0, duration: 0.3),
            .removeFromParent()]))
    }
    
    func generateTextNode(from text: String , leadingAnchorPoint: Bool = true)->SKSpriteNode{
        let node = SKSpriteNode()
        var width:CGFloat = 0.0
        
        for character in text{
            var characterNode = SKSpriteNode()
            
            if character == "0" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.zero.textureName)
            } else if character == "1" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.one.textureName)
            } else if character == "2" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.two.textureName)
            } else if character == "3" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.three.textureName)
            } else if character == "4" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.four.textureName)
            } else if character == "5" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.five.textureName)
            } else if character == "6" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.six.textureName)
            } else if character == "7" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.seven.textureName)
            } else if character == "8" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.eight.textureName)
            } else if character == "9" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.nine.textureName)
            } else if character == "+" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.plus.textureName)
            } else if character == "*" {
                characterNode = SKSpriteNode(imageNamed: ScoreNumber.multiplication.textureName)
            } else {
                continue
            }
            
            node.addChild(characterNode)
            
            characterNode.anchorPoint = CGPoint(x:0,y: 0.5)
            characterNode.position = CGPoint(x: width, y: 0.0)
            
            width += characterNode.size.width
        }
        
        if leadingAnchorPoint {
            return node
        } else {
            let anotherNode = SKSpriteNode()
            
            anotherNode.addChild(node)
            node.position = CGPoint(x:-width/2,y:0)
            
            return anotherNode
        }
        
    }
    
    func addTextNode(on position: CGPoint, from text: String){
        let scorePosition = CGPoint(x: position.x + 10, y: position.y + 30)
        let scoreNode = generateTextNode(from: text)
        scoreNode.position = scorePosition
        scoreNode.zPosition = 9
        scoreNode.xScale = 0.5
        scoreNode.yScale = 0.5
        scene.addChild(scoreNode)
        
        scoreNode.run(.sequence([
            .wait(forDuration: 0.5),
            .fadeOut(withDuration: 0.2),
            .removeFromParent()]))
    }
    
    //also include init
    func findTextAndImageName(for nodeName: String?) -> (String,String)?{
        var scoreText = ""
        var shotImageName = ""
        
        switch nodeName {
        case "duck":
            scoreText = "+\(duckScore)"
            duckCount += 1
            totalScore += duckScore
            shotImageName = Texture.shotBlue.imageName
        case "duck_target":
            scoreText = "+\(duckScore + targetScore)"
            duckCount += 1
            targetCount += 1
            totalScore += duckScore + targetScore
            shotImageName = Texture.shotBlue.imageName
        case "target":
            scoreText = "+\(targetScore)"
            targetCount += 1
            totalScore += targetScore
            shotImageName = Texture.shotBrown.imageName
        case "startBtn":
            scoreText = ""
            duckCount = 0
            targetCount = 0
            totalScore = 0
            shotImageName = Texture.shotBlue.imageName
        case "again":
            //init
            scoreText = ""
            duckCount = 0
            targetCount = 0
            totalScore = 0
            dV = 0
            shotImageName = Texture.shotBrown.imageName
        default:
            return nil
        }
        
        return (scoreText,shotImageName)
    }
    
    
    func update(text:String,node:inout SKNode,leadingAnchorPoint:Bool = true) -> SKNode {
        let position = node.position
        let zPosition = node.zPosition
        let xScale = node.xScale
        let yScale = node.yScale
        
        node.removeFromParent()
        
        node = generateTextNode(from: text,leadingAnchorPoint: leadingAnchorPoint)
        node.position = position
        node.zPosition = zPosition
        node.xScale = xScale
        node.yScale = yScale
        
        scene.addChild(node)
        return node
    }
}
