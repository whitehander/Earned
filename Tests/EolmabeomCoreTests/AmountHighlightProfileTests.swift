import XCTest
@testable import EolmabeomCore

final class AmountHighlightProfileTests: XCTestCase {
    func testHighlightProfileUsesSofterBlueWithWiderTextGradient() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.highlightRed, 0.22, accuracy: 0.001)
        XCTAssertEqual(profile.highlightGreen, 0.52, accuracy: 0.001)
        XCTAssertEqual(profile.highlightBlue, 1, accuracy: 0.001)
        XCTAssertEqual(profile.textCoreWidth, 0.16, accuracy: 0.001)
        XCTAssertEqual(profile.textFeatherWidth, 0.42, accuracy: 0.001)
    }

    func testHighlightProfileUsesLowerGlowOpacityAcrossWiderRange() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.glowInnerWidth, 0.2, accuracy: 0.001)
        XCTAssertEqual(profile.glowOuterWidth, 0.5, accuracy: 0.001)
        XCTAssertEqual(profile.glowPeakOpacity, 0.52, accuracy: 0.001)
        XCTAssertEqual(profile.glowEdgeOpacity, 0.08, accuracy: 0.001)
    }
}
