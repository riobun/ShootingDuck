//
//  Duck.swift
//  Shooting
//
//  Created by tongji on 2020/12/22.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation
import SpriteKit

class Duck: SKNode {
    var hasTarget:Bool!
    init(hasTarget:Bool = false){
        super.init();
        self.hasTarget = hasTarget;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
