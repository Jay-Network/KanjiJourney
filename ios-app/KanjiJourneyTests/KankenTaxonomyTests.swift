import XCTest
import SharedCore
@testable import KanjiJourney

final class KankenTaxonomyTests: XCTestCase {
    @MainActor
    func testAvailableAxisAndDefault() {
        XCTAssertEqual(HomeViewModel.kankenLevels, [10, 9, 8, 7, 6, 5, 4])
        XCTAssertEqual(HomeUiState().selectedKankenLevel, 10)
        XCTAssertEqual(KanjiSortMode.allCases, [.schoolGrade, .kankenLevel, .jlptLevel, .strokes, .frequency])
        XCTAssertEqual(KanjiSortMode.kankenLevel.rawValue, "Kanken Level")
    }

    func testDetailUsesSharedGradeDerivedTaxonomy() {
        let grades: [(Int32, Int32?)] = [(1, 10), (2, 9), (3, 8), (4, 7), (5, 6), (6, 5), (8, 4), (7, nil), (0, nil)]
        for (grade, expected) in grades {
            let kanji = makeKanji(grade: KotlinInt(value: grade))
            XCTAssertEqual(kanji.kankenLevel?.int32Value, expected)
        }
        XCTAssertNil(makeKanji(grade: nil).kankenLevel)
    }

    private func makeKanji(grade: KotlinInt?) -> Kanji {
        Kanji(id: 1, literal: "A", grade: grade, jlptLevel: nil, frequency: nil,
              strokeCount: 1, meaningsEn: [], onReadings: [], kunReadings: [], strokeSvg: nil)
    }
}
