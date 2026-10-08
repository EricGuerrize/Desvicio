import Foundation
import Combine
import FamilyControls
import DeviceActivity
import ManagedSettings

@MainActor
final class DesvicioModel: ObservableObject {
    @Published var pet = SharedStorage.pet
    @Published var selection = SharedStorage.selection
    @Published var limitMinutes = SharedStorage.dailyLimitMinutes
    @Published var isConfigured = SharedStorage.isConfigured
    @Published var errorMessage: String?
    @Published var isBusy = false

    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore()

    var selectedCount: Int {
        selection.applicationTokens.count
        + selection.categoryTokens.count
        + selection.webDomainTokens.count
    }

    func refresh() {
        pet = SharedStorage.pet
    }

    func saveName(_ name: String) {
        pet.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Pingo" : String(name.prefix(20))
        SharedStorage.pet = pet
    }

    func saveSelection() {
        SharedStorage.selection = selection
        if isConfigured { startMonitoring() }
    }

    func saveLimit() {
        SharedStorage.dailyLimitMinutes = limitMinutes
        if isConfigured { startMonitoring() }
    }

    func configure() {
        guard selectedCount > 0 else {
            errorMessage = "Escolha pelo menos um app, categoria ou site."
            return
        }
        isBusy = true
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                SharedStorage.selection = selection
                SharedStorage.dailyLimitMinutes = limitMinutes
                try installMonitor()
                SharedStorage.isConfigured = true
                isConfigured = true
            } catch {
                errorMessage = "Não foi possível ativar o Tempo de Uso: \(error.localizedDescription)"
            }
            isBusy = false
        }
    }

    func startMonitoring() {
        do {
            SharedStorage.selection = selection
            SharedStorage.dailyLimitMinutes = limitMinutes
            try installMonitor()
        } catch {
            errorMessage = "Não foi possível atualizar a meta: \(error.localizedDescription)"
        }
    }

    private func installMonitor() throws {
        func duration(_ minutes: Int) -> DateComponents {
            DateComponents(hour: minutes / 60, minute: minutes % 60)
        }
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let domains = selection.webDomainTokens
        let half = max(1, limitMinutes / 2)
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            DesvicioConfig.halfway: DeviceActivityEvent(
                applications: apps, categories: categories, webDomains: domains,
                threshold: duration(half), includesPastActivity: true
            ),
            DesvicioConfig.limit: DeviceActivityEvent(
                applications: apps, categories: categories, webDomains: domains,
                threshold: duration(limitMinutes), includesPastActivity: true
            ),
            DesvicioConfig.extra: DeviceActivityEvent(
                applications: apps, categories: categories, webDomains: domains,
                threshold: duration(limitMinutes + 30), includesPastActivity: true
            )
        ]
        center.stopMonitoring([DesvicioConfig.dailyActivity])
        store.clearAllSettings()
        try center.startMonitoring(DesvicioConfig.dailyActivity, during: schedule, events: events)
    }

    func stopControl() {
        center.stopMonitoring([DesvicioConfig.dailyActivity])
        store.clearAllSettings()
        SharedStorage.isConfigured = false
        isConfigured = false
    }

    func finishFocus(minutes: Int) {
        refresh()
        pet.focusMinutes += minutes
        if pet.mood.rawValue > 0 {
            pet.mood = PetMood(rawValue: pet.mood.rawValue - 1) ?? .happy
        }
        SharedStorage.pet = pet
    }
}
