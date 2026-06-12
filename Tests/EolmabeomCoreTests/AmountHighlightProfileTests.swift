import XCTest
@testable import EolmabeomCore

final class AmountHighlightProfileTests: XCTestCase {
    func testHighlightProfileUsesSofterBlueWithBroaderTextGradient() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.highlightRed, 0.58, accuracy: 0.001)
        XCTAssertEqual(profile.highlightGreen, 0.78, accuracy: 0.001)
        XCTAssertEqual(profile.highlightBlue, 1, accuracy: 0.001)
        XCTAssertEqual(profile.textCoreWidth, 0.32, accuracy: 0.001)
        XCTAssertEqual(profile.textFeatherWidth, 0.82, accuracy: 0.001)
    }

    func testHighlightProfileUsesSofterGlowAcrossWiderRange() {
        let profile = AmountHighlightProfile.defaultValue

        XCTAssertEqual(profile.glowInnerWidth, 0.4, accuracy: 0.001)
        XCTAssertEqual(profile.glowOuterWidth, 0.88, accuracy: 0.001)
        XCTAssertEqual(profile.glowPeakOpacity, 0.3, accuracy: 0.001)
        XCTAssertEqual(profile.glowEdgeOpacity, 0.08, accuracy: 0.001)
    }
}
