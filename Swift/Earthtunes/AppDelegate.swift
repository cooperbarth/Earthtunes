import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let locationUrl = "http://service.iris.edu/fdsnws/station/1/query?format=text"
        do {
            let data = try String(contentsOf: URL(string: locationUrl)!)
            let dflines = data.split(separator: "\n")
            for i in 1..<dflines.count {
                let line = dflines[i].split(separator: "|")
                let name = String(line[5])
                let network = String(line[0])
                let station = String(line[1])
                locations.append(Location(name: name, network: network, station: station))
            }
            return true
        } catch {
            return false
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

