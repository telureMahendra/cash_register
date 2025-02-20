//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import bluetooth_print_plus
import connectivity_plus
import device_info_plus
import file_selector_macos
import path_provider_foundation
import qr_bar_code
import shared_preferences_foundation
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BluetoothPrintPlusPlugin.register(with: registry.registrar(forPlugin: "BluetoothPrintPlusPlugin"))
  ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  QrBarCodePlugin.register(with: registry.registrar(forPlugin: "QrBarCodePlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
