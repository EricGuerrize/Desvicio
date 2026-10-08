import ManagedSettings
import ManagedSettingsUI
import UIKit

class DesvicioShieldConfiguration: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        make()
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        make()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        make()
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        make()
    }

    private func make() -> ShieldConfiguration {
        let pet = SharedStorage.pet
        let focusing = (SharedStorage.focusSession?.endDate.timeIntervalSinceNow ?? 0) > 0
        let copy = ShieldCopy.make(name: pet.name, mood: pet.mood.rawValue, focusing: focusing)
        let ink = UIColor(red: 38 / 255, green: 53 / 255, blue: 45 / 255, alpha: 1)
        let moss = UIColor(red: 65 / 255, green: 109 / 255, blue: 82 / 255, alpha: 1)
        let cream = UIColor(red: 248 / 255, green: 245 / 255, blue: 233 / 255, alpha: 1)
        return ShieldConfiguration(
            backgroundBlurStyle: .systemThinMaterial,
            backgroundColor: cream,
            title: ShieldConfiguration.Label(text: copy.title, color: ink),
            subtitle: ShieldConfiguration.Label(text: copy.subtitle, color: ink),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Fechar", color: .white),
            primaryButtonBackgroundColor: moss
        )
    }
}
