//
//  Meme.swift
//  MemeApp
//
//  Created by Kirill Varlamov on 24.01.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit

class Meme: NSObject {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
