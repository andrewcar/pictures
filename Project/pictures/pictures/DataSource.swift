//
//  DataSource.swift
//  pictures
//
//  Created by Andrew Carvajal on 12/14/16.
//  Copyright © 2016 YugeTech. All rights reserved.
//

import UIKit

enum CameraState {
    case takingPhoto
    case tookPhoto
}

class DataSource: NSObject {
    
    static let si = DataSource()
    var cameraState: CameraState?
    
    private override init() {}
}
