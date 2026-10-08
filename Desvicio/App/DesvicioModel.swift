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
    @Published var focusSession = SharedStorage.focusSession
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
        completeFocusIfDue()
        pet = SharedStorage.pet
        focusSession = SharedStorage.focusSession
        if isConfigured {
            guard AuthorizationCenter.shared.authorizationStatus == .approved else {
                stopControl()
                return
            }
            ShieldControl.sync(pet, selection: SharedStorage.selection)
            if focusSession != nil {
                FocusShield.start(selection: SharedStorage.selection)
            }
        }
    }

    func saveName(_ name: String) {
        pet.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Meu Cérebro" : String(name.prefix(20))
        SharedStorage.pet = pet
    }

    func saveSelection() {
        if isConfigured {
            startMonitoring()
        } else {
            SharedStorage.selection = selection
        }
    }

    func saveLimit() {
        if isConfigured {
            startMonitoring()
        } else {
            SharedStorage.dailyLimitMinutes = limitMinutes
        }
    }

        guard SharedStorage.isSharedContainerAvailable else {
            errorMessage = "O App Group não está disponível. Confira a assinatura dos dois alvos no Xcode."
            return
        }
        isBusy = true
        Task {
            do {
                if AuthorizationCenter.shared.authorizationStatus != .approved {
                    try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                }
                SharedStorage.selection = selection
                SharedStorage.dailyLimitMinutes = limitMinutes
                if selectedCount > 0 {
                    try? installMonitor()
                }
                SharedStorage.isConfigured = true
                isConfigured = true
            } catch {
                errorMessage = "Não foi possível ativar o Tempo de Uso: \(error.localizedDescription)"
            }
            isBusy = false
        }
    }

    func startMonitoring() {
        let previousSelection = SharedStorage.selection
        let previousLimit = SharedStorage.dailyLimitMinutes
        do {
            SharedStorage.selection = selection
            SharedStorage.dailyLimitMinutes = limitMinutes
            try installMonitor()
            if SharedStorage.focusSession != nil {
                FocusShield.start(selection: selection)
            }
        } catch {
            SharedStorage.selection = previousSelection
            SharedStorage.dailyLimitMinutes = previousLimit
            selection = previousSelection
            limitMinutes = previousLimit
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
        guard !apps.isEmpty || !categories.isEmpty || !domains.isEmpty else {
            return
        }
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
        try center.startMonitoring(DesvicioConfig.dailyActivity, during: schedule, events: events)
        ShieldControl.sync(SharedStorage.pet, selection: selection)
    }

    func stopControl() {
        center.stopMonitoring([DesvicioConfig.dailyActivity, DesvicioConfig.focusActivity])
        store.clearAllSettings()
        FocusShield.stop()
        SharedStorage.focusSession = nil
        focusSession = nil
        SharedStorage.isConfigured = false
        isConfigured = false
    }

    func eraseLocalData() {
        center.stopMonitoring([DesvicioConfig.dailyActivity, DesvicioConfig.focusActivity])
        store.clearAllSettings()
        FocusShield.stop()
        SharedStorage.erase()
        pet = PetState()
        selection = FamilyActivitySelection()
        limitMinutes = 120
        isConfigured = false
        focusSession = nil
    }

    func startFocus(minutes: Int) {
        guard focusSession == nil else { return }
        let endDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        let calendar = Calendar.current
        let start = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: .now
        )
        let end = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: endDate
        )
        let schedule = DeviceActivitySchedule(
            intervalStart: start, intervalEnd: end, repeats: false
        )
        do {
            try center.startMonitoring(DesvicioConfig.focusActivity, during: schedule)
            let session = FocusSession(endDate: endDate, minutes: minutes)
            SharedStorage.focusSession = session
            focusSession = session
            FocusShield.start(selection: selection)
        } catch {
            errorMessage = "Não foi possível iniciar a pausa: \(error.localizedDescription)"
        }
    }

    func cancelFocus() {
        center.stopMonitoring([DesvicioConfig.focusActivity])
        FocusShield.stop()
        SharedStorage.focusSession = nil
        focusSession = nil
    }

    func completeFocusIfDue() {
        guard let session = SharedStorage.focusSession,
              Date() >= session.endDate else { return }
        center.stopMonitoring([DesvicioConfig.focusActivity])
        FocusShield.stop()
        var state = SharedStorage.pet
        state.focusMinutes += session.minutes
        if state.mood == .tired { state.mood = .happy }
        if state.mood == .sick { state.mood = .tired }
        SharedStorage.pet = state
        SharedStorage.focusSession = nil
        pet = state
        focusSession = nil
    }
}
