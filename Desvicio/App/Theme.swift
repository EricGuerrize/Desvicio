import SwiftUI

enum Theme {
    static let ink = Color(red: 0.17, green: 0.21, blue: 0.18)
    static let moss = Color(red: 0.30, green: 0.45, blue: 0.34)
    static let mint = Color(red: 0.78, green: 0.88, blue: 0.72)
    static let cream = Color(red: 0.98, green: 0.97, blue: 0.91)
    static let coral = Color(red: 0.94, green: 0.55, blue: 0.43)
    static let yellow = Color(red: 0.99, green: 0.79, blue: 0.42)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Theme.ink, in: RoundedRectangle(cornerRadius: 20))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 26))
    }
}
