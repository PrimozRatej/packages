// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter

public final class QuickActionsPlugin: NSObject, FlutterPlugin, IOSQuickActionsApi {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let flutterApi = IOSQuickActionsFlutterApi(binaryMessenger: messenger)
    let instance = QuickActionsPlugin(flutterApi: flutterApi)
    IOSQuickActionsApiSetup.setUp(binaryMessenger: messenger, api: instance)
    registrar.addApplicationDelegate(instance)
  }

  private let shortcutItemProvider: ShortcutItemProviding
  private let flutterApi: IOSQuickActionsFlutterApiProtocol
  /// The type of the shortcut item selected when launching the app.
  private var launchingShortcutType: String? = nil

  init(
    flutterApi: IOSQuickActionsFlutterApiProtocol,
    shortcutItemProvider: ShortcutItemProviding = UIApplication.shared
  ) {
    self.flutterApi = flutterApi
    self.shortcutItemProvider = shortcutItemProvider
  }

  func setShortcutItems(itemsList: [ShortcutItemMessage]) {
    shortcutItemProvider.shortcutItems =
      convertShortcutItemMessageListToUIApplicationShortcutItemList(itemsList)
  }

  func clearShortcutItems() {
    shortcutItemProvider.shortcutItems = []
  }

  public func application(
    _ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) -> Bool {
    handleShortcut(shortcutItem.type)
    return true
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    if let shortcutItem = launchOptions[UIApplication.LaunchOptionsKey.shortcutItem]
      as? UIApplicationShortcutItem
    {
      // Keep hold of the shortcut type and handle it in the
      // `applicationDidBecomeActive:` method once the Dart MethodChannel
      // is initialized.
      launchingShortcutType = shortcutItem.type

      // Return false to indicate we handled the quick action to ensure
      // the `application:performActionFor:` method is not called (as
      // per Apple's documentation:
      // https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622935-application).
      return false
    }
    return true
  }

  public func applicationDidBecomeActive(_ application: UIApplication) {
    if let shortcutType = launchingShortcutType {
      handleShortcut(shortcutType)
      launchingShortcutType = nil
    }
  }

  func handleShortcut(_ shortcut: String) {
    flutterApi.launchAction(action: shortcut) { _ in
      // noop
    }
  }

  private func convertShortcutItemMessageListToUIApplicationShortcutItemList(
    _ items: [ShortcutItemMessage]
  ) -> [UIApplicationShortcutItem] {
    return items.compactMap { convertShortcutItemMessageToUIApplicationShortcutItem(with: $0) }
  }

  private func convertShortcutItemMessageToUIApplicationShortcutItem(
    with shortcut: ShortcutItemMessage
  ) -> UIApplicationShortcutItem? {
      let icon: UIApplicationShortcutIcon?

      print(shortcut.iconBase64 ?? "Image is null")
      if let base64Icon = shortcut.iconBase64,
        let imageData = Data(base64Encoded: base64Icon),
        let image = UIImage(data: imageData) {
          // Save the image to the app's temporary directory
          let tempDirectory = NSTemporaryDirectory()
          let imageName = "shortcut_icon_\(UUID().uuidString).png"
          let imagePath = (tempDirectory as NSString).appendingPathComponent(imageName)
          if let pngData = image.pngData() {
              do {
                  try pngData.write(to: URL(fileURLWithPath: imagePath))
                  // Use the saved image as a template icon
                  // USe system for now the UIApplicationShortcutIcon do not support custom icons
                  icon = UIApplicationShortcutIcon(systemImageName: "arrow.right")
              } catch {
                  print("Error saving base64 icon to disk: \(error)")
                  icon = nil
              }
          } else {
              print("Error converting UIImage to PNG data.")
              icon = nil
          }
      } else if let templateImageName = shortcut.icon {
          // Use the provided template image name
          icon = UIApplicationShortcutIcon(templateImageName: templateImageName)
      } else {
          // No valid icon provided
          print("Warning: No icon found for shortcut item: \(shortcut.type)")
          icon = nil
      }

      // Return the UIApplicationShortcutItem with the created icon
      return UIApplicationShortcutItem(
          type: shortcut.type,
          localizedTitle: shortcut.localizedTitle,
          localizedSubtitle: shortcut.localizedSubtitle,
          icon: icon,
          userInfo: nil
      )
  }

}
