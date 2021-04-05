
import UIKit
import UserNotifications

let contactsDataDirectoryName = "contactsData"
var contactsBookFileName = "contacts.json"
var recentsBookFileName = "recents.json"
var birthdaysFileName = "birthdays.json"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let fileManager = FileManager()
        if let path = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first{
            do {
                try fileManager.createDirectory(at: path.appendingPathComponent(contactsDataDirectoryName),
                                                withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("createDirectoryError")
            }
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            didAllow,error in
                if !didAllow{ print("User don't allow notifications")}
                else if error != nil {
                    print("Some other Error")
                }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func applicationWillTerminate(_ application: UIApplication) {
    }
}

