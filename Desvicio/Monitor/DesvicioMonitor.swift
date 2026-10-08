import DeviceActivity
import ManagedSettings

final class DesvicioMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == DesvicioConfig.dailyActivity else { return }
        store.clearAllSettings()
        _ = SharedStorage.pet
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        guard activity == DesvicioConfig.dailyActivity else { return }
        var pet = SharedStorage.pet
        if event == DesvicioConfig.halfway {
            pet.mood = maxMood(pet.mood, .tired)
        } else if event == DesvicioConfig.limit {
            pet.mood = maxMood(pet.mood, .sick)
        } else if event == DesvicioConfig.extra {
            pet.mood = .ghost
            let selection = SharedStorage.selection
            store.shield.applications = selection.applicationTokens.isEmpty
                ? nil : selection.applicationTokens
            store.shield.applicationCategories = selection.categoryTokens.isEmpty
                ? nil : .specific(selection.categoryTokens)
            store.shield.webDomains = selection.webDomainTokens.isEmpty
                ? nil : selection.webDomainTokens
        }
        SharedStorage.pet = pet
    }

    private func maxMood(_ first: PetMood, _ second: PetMood) -> PetMood {
        first.rawValue >= second.rawValue ? first : second
    }
}
