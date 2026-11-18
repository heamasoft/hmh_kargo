import Foundation
import SafariServices

/// The native side of the HMH Kargo Safari extension. The extension's button
/// talks to the app through a link (hmhkargo://add?url=…), not through here,
/// so this only answers that it is alive.
class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
  func beginRequest(with context: NSExtensionContext) {
    let response = NSExtensionItem()
    response.userInfo = [SFExtensionMessageKey: ["ok": true]]
    context.completeRequest(returningItems: [response], completionHandler: nil)
  }
}
