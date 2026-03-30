import SwiftUI

extension Color {
    static let theme = Theme()
    
    struct Theme {
        let primary = Color.blue // Or a custom hex
        let secondary = Color.orange
        let background = Color(UIColor.systemBackground)
        let text = Color(UIColor.label)
        let accent = Color.pink
    }
}

// Fallback colors if assets are missing
extension Color {
    static let safePrimary = Color.blue
    static let safeSecondary = Color.cyan
    static let safeBackground = Color(UIColor.systemBackground)
}
