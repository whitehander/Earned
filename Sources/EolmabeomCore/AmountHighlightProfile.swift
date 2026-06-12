public struct AmountHighlightProfile: Equatable {
    public let highlightRed: Double
    public let highlightGreen: Double
    public let highlightBlue: Double
    public let textCoreWidth: Double
    public let textFeatherWidth: Double
    public let glowInnerWidth: Double
    public let glowOuterWidth: Double
    public let glowPeakOpacity: Double
    public let glowEdgeOpacity: Double

    public init(
        highlightRed: Double,
        highlightGreen: Double,
        highlightBlue: Double,
        textCoreWidth: Double,
        textFeatherWidth: Double,
        glowInnerWidth: Double,
        glowOuterWidth: Double,
        glowPeakOpacity: Double,
        glowEdgeOpacity: Double
    ) {
        self.highlightRed = highlightRed
        self.highlightGreen = highlightGreen
        self.highlightBlue = highlightBlue
        self.textCoreWidth = textCoreWidth
        self.textFeatherWidth = textFeatherWidth
        self.glowInnerWidth = glowInnerWidth
        self.glowOuterWidth = glowOuterWidth
        self.glowPeakOpacity = glowPeakOpacity
        self.glowEdgeOpacity = glowEdgeOpacity
    }

    public static let defaultValue = AmountHighlightProfile(
        highlightRed: 0.43,
        highlightGreen: 0.66,
        highlightBlue: 1,
        textCoreWidth: 0.24,
        textFeatherWidth: 0.62,
        glowInnerWidth: 0.28,
        glowOuterWidth: 0.68,
        glowPeakOpacity: 0.38,
        glowEdgeOpacity: 0.05
    )
}
