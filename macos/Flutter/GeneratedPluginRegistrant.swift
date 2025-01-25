//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import bluetooth_print_plus
import connectivity_plus
import file_selector_macos
import qr_bar_code
import shared_preferences_foundation
import sqflite_darwin

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  BluetoothPrintPlusPlugin.register(with: registry.registrar(forPlugin: "BluetoothPrintPlusPlugin"))
  ConnectivityPlusPlugin.register(with: registry.registrar(forPlugin: "ConnectivityPlusPlugin"))
  FileSelectorPlugin.register(with: registry.registrar(forPlugin: "FileSelectorPlugin"))
  QrBarCodePlugin.register(with: registry.registrar(forPlugin: "QrBarCodePlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
}
