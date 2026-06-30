import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if let registrar = self.registrar(forPlugin: "EarthARViewPlugin") {
            let factory = EarthARViewFactory(messenger: registrar.messenger())
            registrar.register(factory, withId: "earth_ar_view")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Pausa AR em background para poupar bateria
    override func applicationDidEnterBackground(_ application: UIApplication) {
        NotificationCenter.default.post(name: .init("ARPause"), object: nil)
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: .init("ARResume"), object: nil)
    }
}
