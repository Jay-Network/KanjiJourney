import SwiftUI

// MARK: - Brand colors (per-app, used sparingly: borders, icon tints, glows)

enum GlassBrand {
    static let kanjiJourney = Color(hex: 0xFF6B35)   // warm orange
    static let kanjiLens    = Color(hex: 0x0D9488)   // teal
    static let eigoQuest    = Color(hex: 0x4A90D9)   // blue
    static let eigoLens     = Color(hex: 0x4F46E5)   // indigo

    /// Current app brand color
    static let current = kanjiJourney
}

// MARK: - Glass color palette

enum GlassColors {
    static let background    = Color(hex: 0x050508)
    static let surfaceLight  = Color(hex: 0x12121E)
    static let surfaceDark   = Color(hex: 0x08080F)

    static let border        = GlassBrand.current.opacity(0.28)
    static let borderHover   = GlassBrand.current.opacity(0.45)

    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.65)
    static let textMuted     = Color.white.opacity(0.4)

    /// Linear gradient for glass card backgrounds
    static let cardGradient = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.04)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Dimmed gradient for disabled/coming-soon cards
    static let cardDisabledGradient = LinearGradient(
        colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Glass typography (DM Sans)

enum GlassTypography {
    // Register DM Sans fonts — call once at app startup
    static func registerFonts() {
        let fontNames = ["dm_sans_light", "dm_sans_regular", "dm_sans_medium", "dm_sans_bold"]
        for name in fontNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    private static func dmSans(_ size: CGFloat, weight: Font.Weight) -> Font {
        let name: String
        switch weight {
        case .light:   name = "DMSans-Light"
        case .medium:  name = "DMSans-Medium"
        case .bold:    name = "DMSans-Bold"
        default:       name = "DMSans-Regular"
        }
        // Fallback to system if DM Sans not bundled
        if let _ = UIFont(name: name, size: size) {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight)
    }

    // Display
    static let displayLarge  = dmSans(57, weight: .light)
    static let displayMedium = dmSans(45, weight: .light)
    static let displaySmall  = dmSans(36, weight: .light)

    // Headline
    static let headlineLarge  = dmSans(32, weight: .regular)
    static let headlineMedium = dmSans(28, weight: .medium)
    static let headlineSmall  = dmSans(24, weight: .medium)

    // Title
    static let titleLarge  = dmSans(22, weight: .medium)
    static let titleMedium = dmSans(16, weight: .medium)
    static let titleSmall  = dmSans(14, weight: .medium)

    // Body
    static let bodyLarge  = dmSans(16, weight: .regular)
    static let bodyMedium = dmSans(14, weight: .regular)
    static let bodySmall  = dmSans(12, weight: .regular)

    // Label
    static let labelLarge  = dmSans(14, weight: .medium)
    static let labelMedium = dmSans(12, weight: .medium)
    static let labelSmall  = dmSans(11, weight: .medium)
}

// MARK: - Reusable glass components

/// Frosted-glass card with gradient background and brand-tinted border.
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 12
    var borderColor: Color = GlassColors.border
    var borderWidth: CGFloat = 1
    let content: () -> Content

    init(
        cornerRadius: CGFloat = 12,
        borderColor: Color = GlassColors.border,
        borderWidth: CGFloat = 1,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content
    }

    var body: some View {
        content()
            .background(GlassColors.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

/// Selectable chip with glass styling.
struct GlassChip<Content: View>: View {
    let selected: Bool
    var selectedColor: Color = GlassBrand.current
    let content: () -> Content

    init(
        selected: Bool,
        selectedColor: Color = GlassBrand.current,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.selected = selected
        self.selectedColor = selectedColor
        self.content = content
    }

    var body: some View {
        let bg = selected ? selectedColor.opacity(0.30) : Color.white.opacity(0.06)
        let border = selected ? selectedColor.opacity(0.40) : Color.white.opacity(0.10)

        content()
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(border, lineWidth: 1)
            )
    }
}

/// Glass-styled top bar with gradient background and brand glow.
struct GlassTopBar<Title: View, Actions: View, NavIcon: View>: View {
    let title: () -> Title
    let actions: () -> Actions
    let navigationIcon: () -> NavIcon

    init(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder actions: @escaping () -> Actions = { EmptyView() },
        @ViewBuilder navigationIcon: @escaping () -> NavIcon = { EmptyView() }
    ) {
        self.title = title
        self.actions = actions
        self.navigationIcon = navigationIcon
    }

    var body: some View {
        HStack(spacing: 4) {
            navigationIcon()
            title()
                .frame(maxWidth: .infinity, alignment: .leading)
            actions()
        }
        .frame(height: 56)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.10), Color.white.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .top) {
            // Orange warmth at the top edge
            LinearGradient(
                colors: [GlassBrand.current.opacity(0.14), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
        }
        .overlay(alignment: .bottom) {
            // Bottom divider
            Rectangle()
                .fill(GlassBrand.current.opacity(0.40))
                .frame(height: 1)
        }
    }
}

/// Glass-styled bottom navigation bar.
struct GlassNavigationBar<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top divider
            Rectangle()
                .fill(GlassBrand.current.opacity(0.25))
                .frame(height: 1)

            HStack {
                content()
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.05), Color.white.opacity(0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(alignment: .top) {
            // Subtle orange glow
            LinearGradient(
                colors: [GlassBrand.current.opacity(0.06), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 12)
        }
    }
}

/// Alternating section backgrounds for visual rhythm.
struct GlassSection<Content: View>: View {
    var variant: Bool = false
    let content: () -> Content

    init(variant: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.variant = variant
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(variant ? GlassColors.surfaceDark : GlassColors.surfaceLight)
            .overlay(alignment: .top) {
                // Decorative top gradient separator
                LinearGradient(
                    colors: [.clear, GlassBrand.current.opacity(0.15), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
            }
    }
}

// MARK: - Utility

/// Brand-tinted border color with adjustable opacity.
func glassBorderColor(_ color: Color = GlassBrand.current, alpha: Double = 0.28) -> Color {
    color.opacity(alpha)
}
