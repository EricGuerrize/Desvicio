import Foundation
import FamilyControls
import DeviceActivity

enum DesvicioConfig {
    static let groupID = "group.com.desvicio.app"
    static let dailyActivity = DeviceActivityName("desvicio.daily")
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
        case .happy: "Animado"
        case .tired: "Cansadinho"
        case .sick: "Dodói"
        case .ghost: "Fantasminha"
        }
    }

    var message: String {
        switch self {
        case .happy: "Tá sobrando tempo pra viver lá fora."
        case .tired: "Uma pausa cairia bem agora."
        case .sick: "Bora largar o scroll um pouquinho?"
        case .ghost: "Ainda dá tempo de cuidar de mim."
        }
    }
}

struct PetState: Codable {
    var name: String = "Pingo"
    var mood: PetMood = .happy
    var day: String = Self.todayKey()
    var focusMinutes: Int = 0

    static func todayKey(_ date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum SharedStorage {
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
}
