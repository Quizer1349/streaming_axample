
//
//  router.swift
//  HLSCatalog
//
//  Created by Alex Sklyarenko on 9/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

enum StartFlows: String {
    case login = "LoginViewController"
    case main = "MainViewController"
}

struct Router {
    static func switchToFlow(_ flow: StartFlows) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: flow.rawValue)
        let appdelegate = UIApplication.shared.delegate as? AppDelegate
        appdelegate?.window?.rootViewController = newViewController
        appdelegate?.window?.makeKeyAndVisible()
    }
}
