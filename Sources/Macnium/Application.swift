//
//  Application.swift
//  Macnium
//
//  Created by Wttch on 2024/11/10.
//

import AppKit
import Foundation

struct AXApplication {}

extension AXApplication {
    func test() throws {
        let appId = "com.tencent.xinWeChat"
        //  "com.roadesign.Codyeapp"
        guard let appElement = AccessibilityApplication(withBundleIdentifier: appId) else { return
        }
        try appElement.visit(appElement.root, 0) { element, level in
            print(element)
        }
//        
//        let element1 = appElement.findElement { element in
//            element.description?.contains("PNG") ?? false
//        }
//        element1?.perform(.press)
//        
//        // wait 2s
//        usleep(2000000)
//        
//        let element = appElement.findElement { element in
//            element.description?.contains("PNG (base64)") ?? element.title?.contains("PNG (base64)") ?? false
//        }
//        element?.perform(.press)
        
    }
}
