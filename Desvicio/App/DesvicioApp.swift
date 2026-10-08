import SwiftUI

@main
struct DesvicioApp: App {
    @StateObject private var model = DesvicioModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
        }
    }
}
