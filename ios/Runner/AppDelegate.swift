import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var clipboardChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    setUpClipboardProbe()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Tells the app whether the clipboard holds a web link, without reading it
  /// (so iOS shows no "Allow Paste" prompt). The app then offers "Add to
  /// cart", and only reads the clipboard if the shopper taps it.
  private func setUpClipboardProbe() {
    guard let registrar = self.registrar(forPlugin: "HmhClipboard") else { return }
    let channel = FlutterMethodChannel(
      name: "hmh/clipboard", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      guard call.method == "probe" else {
        result(FlutterMethodNotImplemented)
        return
      }
      let board = UIPasteboard.general
      let count = board.changeCount
      if #available(iOS 14.0, *) {
        board.detectPatterns(for: [.probableWebURL]) { found in
          var hasLink = false
          if case .success(let patterns) = found {
            hasLink = patterns.contains(.probableWebURL)
          }
          DispatchQueue.main.async {
            result(["count": count, "link": hasLink])
          }
        }
      } else {
        result(["count": count, "link": board.hasURLs])
      }
    }
    clipboardChannel = channel
  }
}
