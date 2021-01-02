//
//  Sound.swift
//  Shooting
//
//  Created by rio on 2020/12/26.
//  Copyright © 2020 rio. All rights reserved.
//

import Foundation

enum Sound: String {
    case musicLoop = "Cheerful Annoyance.wav"
    case hit = "hit.wav"
    case reload = "reload.wav"
    case score = "score.wav"
    
    var fileName: String{
        return rawValue
    }
}
