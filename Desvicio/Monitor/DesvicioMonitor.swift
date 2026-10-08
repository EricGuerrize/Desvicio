import DeviceActivity

final class DesvicioMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == DesvicioConfig.dailyActivity else { return }
        ShieldControl.sync(SharedStorage.pet, selection: SharedStorage.selection)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        if activity == DesvicioConfig.focusActivity {
            FocusShield.stop()
        }
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
        }
        SharedStorage.pet = pet
        ShieldControl.sync(pet, selection: SharedStorage.selection)
    }

    private func maxMood(_ first: PetMood, _ second: PetMood) -> PetMood {
        first.rawValue >= second.rawValue ? first : second
    }
}
