import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // Holds a URL that arrived before the channel was ready.
  private var pendingUrl: String?
  private var channel: FlutterMethodChannel?

  // MARK: - Scene lifecycle

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Cold-start via custom URL scheme.
    if let url = connectionOptions.urlContexts.first?.url {
      pendingUrl = url.absoluteString
    }

    // Set up the MethodChannel after Flutter engine is ready.
    DispatchQueue.main.async {
      self.setupChannelIfNeeded(scene: scene)
    }
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    // App already running — deliver immediately.
    guard let url = URLContexts.first?.url else { return }
    let urlString = url.absoluteString
    if let ch = channel {
      ch.invokeMethod("onUrl", arguments: urlString)
    } else {
      pendingUrl = urlString
    }
  }

  // MARK: - Channel setup

  private func setupChannelIfNeeded(scene: UIScene) {
    guard channel == nil,
          let windowScene = scene as? UIWindowScene,
          let rootVC = windowScene.windows.first?.rootViewController else {
      return
    }

    let messenger: FlutterBinaryMessenger?
    if let flutterVC = rootVC as? FlutterViewController {
      messenger = flutterVC.binaryMessenger
    } else {
      // FlutterImplicitEngineBridge embeds the engine differently;
      // walk children to find the FlutterViewController.
      messenger = findMessenger(in: rootVC)
    }

    guard let binaryMessenger = messenger else {
      // Retry in 200 ms if engine not ready yet.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.setupChannelIfNeeded(scene: scene)
      }
      return
    }

    let ch = FlutterMethodChannel(name: "grovia/deep_links",
                                   binaryMessenger: binaryMessenger)
    ch.setMethodCallHandler { [weak self] call, result in
      if call.method == "getInitialUrl" {
        result(self?.pendingUrl)
        self?.pendingUrl = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    channel = ch

    // Deliver any URL that arrived during startup.
    if let pending = pendingUrl {
      ch.invokeMethod("onUrl", arguments: pending)
      pendingUrl = nil
    }
  }

  private func findMessenger(in vc: UIViewController) -> FlutterBinaryMessenger? {
    if let fvc = vc as? FlutterViewController { return fvc.binaryMessenger }
    for child in vc.children {
      if let m = findMessenger(in: child) { return m }
    }
    return nil
  }
}
