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
        highlightRed: 0.58,
        highlightGreen: 0.78,
        highlightBlue: 1,
        textCoreWidth: 0.32,
        textFeatherWidth: 0.82,
        glowInnerWidth: 0.4,
        glowOuterWidth: 0.88,
        glowPeakOpacity: 0.3,
        glowEdgeOpacity: 0.08
    )
}
