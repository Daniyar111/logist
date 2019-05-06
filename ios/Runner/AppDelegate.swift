import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


// Todo don't forget to set facebook https://developers.facebook.com/apps/2326604400725274/fb-login/quickstart/
//Todo https://pub.dartlang.org/packages/flutter_facebook_login#-readme-tab-

//Todo don't forget to change splash screen  https://stackoverflow.com/questions/43879103/adding-a-splash-screen-to-flutter-apps
