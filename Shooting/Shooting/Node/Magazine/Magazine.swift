//
//  Magazine.swift
//  Shooting
//
//  Created by tongji on 2020/12/25.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation
import SpriteKit

class Magazine{
    
    var bullets: [Bullet]!
    var capacity: Int!
    
    init(bullets: [Bullet]){
        self.bullets = bullets
        self.capacity = bullets.count
        
    }
    
    func shoot(){
        bullets.first{ $0.wasShot() == false}?.shoot()
    }
    
    func needToReload() -> Bool {
        return bullets.allSatisfy { $0.wasShot() == true}
    }
    
    func reloadIfNeeded(){
        if needToReload(){
            for bullet in bullets{
                bullet.reloadIfNeeded()
            }
        }
    }
    
    func reload(){
        for bullet in bullets{
            bullet.reloadIfNeeded()
        }
    }
}
