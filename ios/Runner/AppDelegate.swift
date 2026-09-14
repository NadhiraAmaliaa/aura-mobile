import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDNQbbmEELM2cPz5bwNZV9c4P_rbKWM-QM")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerDeviceTimeChannel(with: engineBridge.pluginRegistry)
  }

  /// Registers the `id.aura.app/device_time` channel on the implicit engine.
  /// Wiring it here (not via `window?.rootViewController`) keeps it working
  /// under the UIScene lifecycle, where `AppDelegate.window` is nil at launch.
  private func registerDeviceTimeChannel(with registry: FlutterPluginRegistry) {
    guard let messenger = registry.registrar(forPlugin: "DeviceTimeChannel")?.messenger()
    else { return }

    let channel = FlutterMethodChannel(
      name: "id.aura.app/device_time",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "getMonotonicMs":
        // ProcessInfo.systemUptime: seconds since last boot, including sleep.
        // Monotonic, unaffected by wall-clock changes. Resets on reboot.
        let uptimeMs = Int64(ProcessInfo.processInfo.systemUptime * 1000)
        result(uptimeMs)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
