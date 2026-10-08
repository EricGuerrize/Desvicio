import SwiftUI

struct PetView: View {
    let mood: PetMood
    var size: CGFloat = 220

    private var bodyColor: Color {
        switch mood {
        case .happy: Theme.mint
        case .tired: Theme.yellow
        case .sick: Theme.coral
        case .ghost: Color(red: 0.83, green: 0.81, blue: 0.91)
        }
    }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Theme.ink.opacity(0.12))
                .frame(width: size * 0.72, height: size * 0.10)
                .offset(y: size * 0.45)

            Ellipse()
                .fill(bodyColor)
                .frame(width: size * 0.76, height: size * 0.80)
                .overlay {
                    Ellipse()
                        .strokeBorder(Theme.ink, lineWidth: size * 0.014)
                }
                .offset(y: size * 0.04)

            HStack(spacing: size * 0.15) {
                eye
                eye
            }
            .offset(y: -size * 0.04)

            mouth
                .offset(y: size * 0.16)

            if mood == .sick {
                Image(systemName: "bandage.fill")
                    .font(.system(size: size * 0.16))
                    .foregroundStyle(Theme.cream, Theme.coral)
                    .rotationEffect(.degrees(-22))
                    .offset(x: size * 0.28, y: -size * 0.22)
            }

            if mood == .ghost {
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.13))
                    .foregroundStyle(Theme.ink.opacity(0.5))
                    .offset(x: -size * 0.35, y: -size * 0.30)
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Bichinho \(mood.title.lowercased())")
    }

    private var eye: some View {
        Ellipse()
            .fill(Theme.ink)
            .frame(width: size * 0.055, height: mood == .tired ? size * 0.026 : size * 0.085)
    }

    @ViewBuilder private var mouth: some View {
        if mood == .happy {
            Smile()
                .stroke(Theme.ink, style: StrokeStyle(lineWidth: size * 0.014, lineCap: .round))
                .frame(width: size * 0.18, height: size * 0.08)
        } else {
            Capsule()
                .fill(Theme.ink)
                .frame(width: size * 0.11, height: size * 0.018)
        }
    }
}

private struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.7)
        )
        return path
    }
}
