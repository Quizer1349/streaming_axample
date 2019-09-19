/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`AppDelegate` is the AppDelegate for this sample.  The only additional work this
 class does is intiate the restoring process of `AssetPersistenceManager by calling
 AssetPersistenceManager.sharedManager.restorePersistenceManager().
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // To be sure the window is created
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Check is user exist and set entry point
        if AuthManager.shared.isUserAuthorized() {
            Router.switchToFlow(.main)
        } else {
            Router.switchToFlow(.login)
        }

        return true
    }
}
