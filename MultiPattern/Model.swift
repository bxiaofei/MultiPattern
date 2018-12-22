//
//  Model.swift
//  MultiPattern
//
//  Created by 李松 on 2018/12/20.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit

class Model: NSObject {
    
    static let textDidChange = NSNotification.Name("TextDidChange")
    static let textKey: String = "TextKey"
    
    var value: String? {
        willSet {
            NotificationCenter.default.post(name: Model.textDidChange, object: nil, userInfo: [Model.textKey : newValue as Any])
        }
    }
    
    init(value: String) {
        super.init()
        
        self.value = value
    }
}


