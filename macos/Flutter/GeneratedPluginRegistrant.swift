//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import flutter_local_notifications
import flutter_timezone
import path_provider_foundation
import share_plus
import shared_preferences_foundation
import url_launcher_macos

/// Registers all generated Flutter plugins with the provided plugin registry.
///
/// This function ensures that the necessary plugins are registered and available for use within the Flutter macOS application.
///
/// - Parameter registry: The Flutter plugin registry to register plugins with.
func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin"))
  FlutterTimezonePlugin.register(with: registry.registrar(forPlugin: "FlutterTimezonePlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharePlusMacosPlugin.register(with: registry.registrar(forPlugin: "SharePlusMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
