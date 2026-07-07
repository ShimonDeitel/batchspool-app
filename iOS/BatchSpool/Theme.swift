import SwiftUI

/// Batch Spool - Embroidery Thread Log's own palette: distinct from every sibling app in the portfolio.
enum BSTheme {
    static let backdrop = Color(red: 0.965, green: 0.965, blue: 0.973)
    static let card = Color.white

    static let ink = Color(red: 0.114, green: 0.122, blue: 0.157)
    static let inkFaded = Color(red: 0.114, green: 0.122, blue: 0.157).opacity(0.56)

    static let accent = Color(red: 0.212, green: 0.443, blue: 0.784)
    static let accentDeep = Color(red: 0.132, green: 0.363, blue: 0.7040000000000001)
    static let accent2 = Color(red: 0.902, green: 0.475, blue: 0.216)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BSDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BSDismissKeyboardOnTap())
    }
}

enum BSHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
