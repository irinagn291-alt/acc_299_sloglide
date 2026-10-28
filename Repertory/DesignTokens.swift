import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #1E151C
    static let bg = Color(red: 0.117647, green: 0.082353, blue: 0.109804)
    static let bgHex = "#1E151C"
    /// #2A1E28
    static let surface = Color(red: 0.164706, green: 0.117647, blue: 0.156863)
    static let surfaceHex = "#2A1E28"
    /// #F2EDF1
    static let ink = Color(red: 0.949020, green: 0.929412, blue: 0.945098)
    static let inkHex = "#F2EDF1"
    /// #D666C4
    static let accent = Color(red: 0.839216, green: 0.400000, blue: 0.768627)
    static let accentHex = "#D666C4"
    /// #A993A5
    static let muted = Color(red: 0.662745, green: 0.576471, blue: 0.647059)
    static let mutedHex = "#A993A5"
    static let fontFamily = "Avenir Next"
}
