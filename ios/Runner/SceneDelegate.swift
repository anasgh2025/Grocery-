import Flutter
import UIKit
import app_links

class SceneDelegate: FlutterSceneDelegate {

  // Called when the app is already running and opened via a custom URL scheme
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    if let url = URLContexts.first?.url {
      AppLinks.shared.handleLink(url: url)
    }
  }

  // Called when the app is cold-started via a custom URL scheme (scene path)
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let url = connectionOptions.urlContexts.first?.url {
      AppLinks.shared.handleLink(url: url)
    }
  }
}
