import XCTest
@testable import EolmabeomCore

final class AmountHighlightProfileTests: XCTestCase {
    func testHighlightProfileUsesMutedBlueWithBroaderTextGradient() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.highlightRed, 0.43, accuracy: 0.001)
        XCTAssertEqual(profile.highlightGreen, 0.66, accuracy: 0.001)
        XCTAssertEqual(profile.highlightBlue, 1, accuracy: 0.001)
        XCTAssertEqual(profile.textCoreWidth, 0.24, accuracy: 0.001)
        XCTAssertEqual(profile.textFeatherWidth, 0.62, accuracy: 0.001)
    }

    func testHighlightProfileUsesLowerGlowOpacityAcrossWiderRange() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.glowInnerWidth, 0.28, accuracy: 0.001)
        XCTAssertEqual(profile.glowOuterWidth, 0.68, accuracy: 0.001)
        XCTAssertEqual(profile.glowPeakOpacity, 0.38, accuracy: 0.001)
        XCTAssertEqual(profile.glowEdgeOpacity, 0.05, accuracy: 0.001)
    }
}
