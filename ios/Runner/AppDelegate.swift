import Flutter
import UIKit
import SwiftUI
import FamilyControls

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let model = DesvicioModel()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "com.desvicio.app/control",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    model.errorMessage = nil
    switch call.method {
    case "getState":
      model.refresh()
      result(state())
    case "saveName":
      model.saveName(args["name"] as? String ?? "Pingo")
      result(nil)
    case "saveLimit":
      guard let minutes = args["minutes"] as? Int,
            [30, 60, 90, 120, 150, 180, 240].contains(minutes) else {
        result(failure("Meta diária inválida."))
        return
      }
      model.limitMinutes = minutes
      model.saveLimit()
      finish(result)
    case "chooseApps":
      showPicker(result: result)
    case "configure":
      model.configure { message in
        if let message {
          result(self.failure(message))
        } else {
          result(nil)
        }
      }
    case "startFocus":
      guard let minutes = args["minutes"] as? Int,
            [15, 25, 45].contains(minutes) else {
        result(failure("Duração de foco inválida."))
        return
      }
      model.startFocus(minutes: minutes)
      finish(result)
    case "cancelFocus":
      model.cancelFocus()
      result(nil)
    case "stopControl":
      model.stopControl()
      result(nil)
    case "eraseData":
      model.eraseLocalData()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func state() -> [String: Any] {
    var value: [String: Any] = [
      "configured": model.isConfigured,
      "name": model.pet.name,
      "mood": model.pet.mood.rawValue,
      "selectedCount": model.selectedCount,
      "limitMinutes": model.limitMinutes,
      "focusMinutes": model.pet.focusMinutes
    ]
    if let session = model.focusSession {
      value["focusEnd"] = Int(session.endDate.timeIntervalSince1970 * 1000)
    }
    return value
  }

  private func failure(_ message: String) -> FlutterError {
    FlutterError(code: "SCREEN_TIME", message: message, details: nil)
  }

  private func finish(_ result: @escaping FlutterResult) {
    if let message = model.errorMessage {
      result(failure(message))
    } else {
      result(nil)
    }
  }

  private func showPicker(result: @escaping FlutterResult) {
    guard let scene = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene }).first,
      let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
      result(failure("Não foi possível abrir a seleção de apps."))
      return
    }
    let picker = AppPickerView(model: model) { [weak self] in
      guard let self else { return }
      self.model.saveSelection()
      self.finish(result)
    }
    let host = UIHostingController(rootView: picker)
    host.isModalInPresentation = true
    var top = root
    while let presented = top.presentedViewController { top = presented }
    top.present(host, animated: true)
  }
}

private struct AppPickerView: View {
  @ObservedObject var model: DesvicioModel
  let onDone: () -> Void

  var body: some View {
    NavigationStack {
      FamilyActivityPicker(selection: $model.selection)
        .navigationTitle("Apps e sites")
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Concluído") {
              onDone()
              UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first?
                .windows.first(where: { $0.isKeyWindow })?
                .rootViewController?.presentedViewController?.dismiss(animated: true)
            }
          }
        }
    }
  }
}
