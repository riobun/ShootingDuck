//
//  StageScene.swift
//  Shooting
//
//  Created by tongji on 2020/12/22.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class StageScene:SKScene{
    
    //nodes
    var rifle: SKSpriteNode?
    var crosshair: SKSpriteNode?
    var fire =  FireButton()
    var duckScoreNode: SKNode!
    var targetScoreNode: SKNode!
    var label:SKLabelNode?
   
    var magazine: Magazine!
    
    //information
    var info1 = "试着移动靶心、瞄准小黄鸭，点击屏幕下方开火按钮，开始游戏吧～"
    var info2 = "再来一局吧，击倒屏幕左侧的靶子go！go！go！"
    
    //touches
    var selectedNodes: [UITouch:SKSpriteNode]=[:]
    
    //game logic
    var manager:GameManager!
    
    //gameStateMachine
    var gameStateMachine: GKStateMachine!
    
    var touchDifferent: (CGFloat,CGFloat)?
    
    override func didMove(to view: SKView) {
        manager = GameManager(scene: self)
        
        loadUI()
        
        Audio.sharedInstance.playSound(soundFileName: Sound.musicLoop.fileName)
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.volume = 0.3
        Audio.sharedInstance.player(with: Sound.musicLoop.fileName)?.numberOfLoops = -1
        
        
        gameStateMachine = GKStateMachine(states: [
            ReadyState(fire: fire, magazine: magazine),
            ShootingState(fire: fire, magazine: magazine),
            ReloadingState(fire: fire, magazine: magazine)])
        
        gameStateMachine.enter(ReadyState.self)
        
        manager.createStartButton()
        //manager.activeDucks()
        //manager.activeTargets()
    }
}

//mark: -GameLoop
extension StageScene{
    override func update(_ currentTime: TimeInterval) {
        synRiflePosition()
    }
}

//MARK: -Touches
extension StageScene{
    //touches began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crosshair = crosshair else {return}
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = self.atPoint(location) as? SKSpriteNode{
                if !selectedNodes.values.contains(crosshair) && !(node is FireButton){
                    selectedNodes[touch] = crosshair
                    let xDifferent = touch.location(in: self).x - crosshair.position.x
                    let yDifferent = touch.location(in: self).y - crosshair.position.y
                    touchDifferent = (xDifferent,yDifferent)
                }
                //shoot
                if node is FireButton {
                    selectedNodes[touch] = fire
                    
                    //check if is reloading
                    if !fire.isReloading {
                        fire.isPressed = true
                        
                        //find shotNode
                        let shotNode = manager.findShotNode(at: crosshair.position)
                        
                        if shotNode.name == "startBtn"{
                            manager.gameType = "ing"
                            label?.text = ""
    
                        }
                        else if shotNode.name == "again" {
                            manager.scoreBack(duck_node: &duckScoreNode,target_node: &targetScoreNode)
                            manager.gameType = "again"
                            magazine.reload()
                            label?.text = info1
                        }
                            
                        if manager.gameType == "ing" && shotNode.name != "startBtn" {
                            magazine.shoot()
                        }
                        
                        
                           //play sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.hit.fileName)
                        
                        if magazine.needToReload(){
                            gameStateMachine.enter(ReloadingState.self)
                        }
                        
                        
                        
                        guard let (scoreText,shotImageName) = manager.findTextAndImageName(for: shotNode.name) else {return}
                        
                        //add shot image
                        manager.addShot(imageNamed: shotImageName, to: shotNode, on: crosshair.position)
                        
                        //add score text
                        manager.addTextNode(on: crosshair.position, from: scoreText)
                        
                        //play score sound
                        Audio.sharedInstance.playSound(soundFileName: Sound.score.fileName)
                        
                        //update score node
                        let duckScore = manager.update(text: String(manager.duckCount * manager.duckScore), node: &duckScoreNode)
                        duckScore.name = "duck_score"
                        let targetScore = manager.update(text: String(manager.targetCount * manager.targetScore), node: &targetScoreNode)
                        targetScore.name = "target_score"
                        
                        //animate shotNode
                        shotNode.physicsBody = nil
                        
                        if let node = shotNode.parent {
                            node.run(.sequence([
                                .wait(forDuration: 0.2),
                                .scaleY(to: 0.0, duration: 0.2)]))
                        }
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    
    //move
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let crosshair = crosshair else {return}
        guard let touchDifferent = touchDifferent else {return}
        
        for touch in touches {
            let location = touch.location(in: self)
            if let node = selectedNodes[touch]{
                if node.name == "fire"{
                    
                }else{
                    let newCrosshairPosition = CGPoint(x: location.x-touchDifferent.0, y: location.y-touchDifferent.1)
                    crosshair.position = newCrosshairPosition
                }
            }
        }


    }
    
    //end
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                if let fire = selectedNodes[touch] as? FireButton {
                    fire.isPressed = false
                }
                selectedNodes[touch] = nil
            }
        }
    }
    
}

//MARK: -ACTION
extension StageScene{
    
    func loadUI(){
        
        if let scene = scene {
            rifle = childNode(withName: "rifle") as? SKSpriteNode
            crosshair = childNode(withName: "crosshair") as? SKSpriteNode
            crosshair?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        }
        
        //add fire
        fire.position = CGPoint(x: 720, y: 80)
        fire.xScale = 1.7
        fire.yScale = 1.7
        fire.zPosition = 11
        
        addChild(fire)
        
        //add icons
        let duckIcon = SKSpriteNode(imageNamed: Texture.duckIcon.imageName)
        duckIcon.position = CGPoint(x: 36, y: 365)
        duckIcon.zPosition = 11
        duckIcon.name = "duck_icon"
        addChild(duckIcon)
        
        let targetIcon = SKSpriteNode(imageNamed: Texture.targetIcon.imageName)
        targetIcon.position = CGPoint(x: 36, y: 325)
        targetIcon.zPosition = 11
        targetIcon.name = "target_icon"
        addChild(targetIcon)
        
        let bestIcon = SKSpriteNode(imageNamed: Texture.bestRecord.imageName)
        bestIcon.position = CGPoint(x: 130, y: 365)
        bestIcon.zPosition = -1
        bestIcon.xScale = 0.2
        bestIcon.yScale = 0.2
        bestIcon.name = "best_icon"
        addChild(bestIcon)
        
        //add scoreNode
        duckScoreNode = manager.generateTextNode(from: "0")
        duckScoreNode.position = CGPoint(x: 60, y: 365)
        duckScoreNode.zPosition = 11
        duckScoreNode.xScale = 0.5
        duckScoreNode.yScale = 0.5
        addChild(duckScoreNode)
        
        targetScoreNode = manager.generateTextNode(from: "0")
        targetScoreNode.position = CGPoint(x: 60, y: 325)
        targetScoreNode.zPosition = 11
        targetScoreNode.xScale = 0.5
        targetScoreNode.yScale = 0.5
        addChild(targetScoreNode)
        
        //add magazine
        let magazineNode = SKNode()
        magazineNode.position = CGPoint(x: 760, y: 20)
        magazineNode.zPosition = 11
        
        var bullets = Array<Bullet>()
        
        for i in 0...manager.ammunitionQuantity - 1 {
            let bullet = Bullet()
            bullet.position = CGPoint(x: -30 * i, y: 0)
            bullets.append(bullet)
            magazineNode.addChild(bullet)
        }
        
        magazine = Magazine(bullets: bullets)
        addChild(magazineNode)
        
        //add information label
        label = SKLabelNode()
        label?.text = info1
        label?.fontSize = 19
        label?.position = CGPoint(x: 390, y: 365)
        label?.zPosition = 10.9
        label?.fontColor = UIColor.black
        label?.name="label"
        addChild(label!)
        
    }
    
    func synRiflePosition(){
        guard let rifle = rifle else {return}
        guard let crosshair = crosshair else {return}
        rifle.position.x = crosshair.position.x+100
    }
    
    func setBoundary(){
        guard let scene = scene else {return}
        guard let crosshair = crosshair else {return}
        
        if crosshair.position.x < scene.frame.minX{
            crosshair.position.x = scene.frame.minX
        }
        if crosshair.position.x > scene.frame.maxX{
            crosshair.position.x = scene.frame.maxX
        }
        if crosshair.position.y < scene.frame.minY{
            crosshair.position.y = scene.frame.minY
        }
        if crosshair.position.y > scene.frame.maxY{
            crosshair.position.y = scene.frame.maxY
        }
    }
}
