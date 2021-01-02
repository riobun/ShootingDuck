//
//  Texture.swift
//  Shooting
//
//  Created by tongji on 2020/12/25.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation

enum Texture: String{
    case fireButtonNormal = "fire_normal"
    case fireButtonPressed = "fire_pressed"
    case fireButtonReloading = "fire_reloading"
    case bulletEmptyTexture = "icon_bullet_empty"
    case bulletTexture = "icon_bullet"
    case shotBlue = "shot_blue"
    case shotBrown = "shot_brown"
    case duckIcon = "icon_duck"
    case targetIcon = "icon_target"
    case bestRecord = "best_record"
    case newRecord = "new_record"
    
    var imageName: String {
        return rawValue
    }
}
