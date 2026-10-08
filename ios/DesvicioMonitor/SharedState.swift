import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

enum DesvicioConfig {
    static let groupID = "group.com.desvicio.app"
    static let dailyActivity = DeviceActivityName("desvicio.daily")
    static let focusActivity = DeviceActivityName("desvicio.focus")
    static let halfway = DeviceActivityEvent.Name("halfway")
    static let limit = DeviceActivityEvent.Name("limit")
    static let extra = DeviceActivityEvent.Name("extra")
}

enum PetMood: Int, Codable {
    case happy = 0
    case tired = 1
    case sick = 2
    case ghost = 3

    var title: String {
        switch self {
        case .happy: "Saudável"
        case .tired: "Cansado"
        case .sick: "Fritando"
        case .ghost: "Pifou"
        }
    }

    var message: String {
        switch self {
        case .happy: "Seu cérebro tá fresco e pronto pra viver."
        case .tired: "O excesso de tela começou a pesar na mente."
        case .sick: "Seu cérebro tá fritando no scroll infinito!"
        case .ghost: "Seu cérebro pifou pra se proteger. Desconecte agora."
        }
    }
}

struct PetState: Codable {
    var name: String = "Meu Cérebro"
    var mood: PetMood = .happy
    var day: String = Self.todayKey()
    var focusMinutes: Int = 0
    var streakDays: Int = 0

    static func todayKey(_ date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct FocusSession: Codable {
    let endDate: Date
    let minutes: Int
}

enum SharedStorage {
    static var isSharedContainerAvailable: Bool {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: DesvicioConfig.groupID
        ) != nil
    }

    static var defaults: UserDefaults {
        UserDefaults(suiteName: DesvicioConfig.groupID) ?? .standard
    }

    static var selection: FamilyActivitySelection {
        get {
            guard let data = defaults.data(forKey: "selection"),
                  let value = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            else { return FamilyActivitySelection() }
            return value
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: "selection")
        }
    }

    static var pet: PetState {
        get {
            guard let data = defaults.data(forKey: "pet"),
                  var value = try? JSONDecoder().decode(PetState.self, from: data)
            else { return PetState() }
            if value.day != PetState.todayKey() {
                if value.mood != .ghost {
                    value.streakDays += 1
                } else {
                    value.streakDays = 0
                }
                value.day = PetState.todayKey()
                value.mood = .happy
                value.focusMinutes = 0
                self.pet = value
            }
            return value
        }
        set {
            defaults.set(try? JSONEncoder().encode(newValue), forKey: "pet")
        }
    }

    static var dailyLimitMinutes: Int {
        get {
            let value = defaults.integer(forKey: "dailyLimitMinutes")
            return value == 0 ? 120 : value
        }
        set { defaults.set(newValue, forKey: "dailyLimitMinutes") }
    }

    static var isConfigured: Bool {
        get { defaults.bool(forKey: "isConfigured") }
        set { defaults.set(newValue, forKey: "isConfigured") }
    }

    static var focusSession: FocusSession? {
        get {
            guard let data = defaults.data(forKey: "focusSession") else { return nil }
            return try? JSONDecoder().decode(FocusSession.self, from: data)
        }
        set {
            if let newValue {
                defaults.set(try? JSONEncoder().encode(newValue), forKey: "focusSession")
            } else {
                defaults.removeObject(forKey: "focusSession")
            }
        }
    }

    static func erase() {
        for key in ["selection", "pet", "dailyLimitMinutes", "isConfigured", "focusSession"] {
            defaults.removeObject(forKey: key)
        }
    }
}

enum ShieldControl {
    static func sync(_ pet: PetState, selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore()
        guard pet.mood == .ghost else {
            store.clearAllSettings()
            return
        }
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
    }
}

enum FocusShield {
    private static var store: ManagedSettingsStore {
        ManagedSettingsStore(named: ManagedSettingsStore.Name("desvicio.focus"))
    }

    static func start(selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
    }

    static func stop() {
        store.clearAllSettings()
    }
}
