//
//  FireButton.swift
//  Shooting
//
//  Created by tongji on 2020/12/25.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation
import SpriteKit

class FireButton: SKSpriteNode{
    
    var isReloading = false
    
    var isPressed = false {
        didSet{
            guard !isReloading else {return}
            
            if isPressed {
                texture = SKTexture(imageNamed: Texture.fireButtonPressed.imageName)
            }else{
                texture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
            }
        }
    }
    
    init(){
        let texture: SKTexture = SKTexture(imageNamed: Texture.fireButtonNormal.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        name = "fire"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
