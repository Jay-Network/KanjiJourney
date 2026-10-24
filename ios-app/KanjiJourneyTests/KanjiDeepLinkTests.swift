import XCTest
@testable import KanjiJourney

final class KanjiDeepLinkTests: XCTestCase {
    private func parse(_ value: String) -> KanjiDeepLink? {
        URL(string: value).flatMap { KanjiDeepLink(url: $0) }
    }

    func testCollectAndDefaults() {
        XCTAssertEqual(parse("kanjijourney://collect?kanji_id=23383"), .collect(kanjiId: 23383, source: "kanjilens"))
        XCTAssertEqual(parse("kanjijourney://collect?kanji_id=23383&source=scan%20app"), .collect(kanjiId: 23383, source: "scan app"))
    }

    func testImportDecodingAndBlankEntries() {
        XCTAssertEqual(parse("kanjijourney://import?kanji=%E5%AD%97,,%20,%E5%AD%97&source=test"),
                       .importKanji(literals: ["\u{5B57}", "\u{5B57}"], source: "test"))
        XCTAssertEqual(parse("kanjijourney://import?kanji=A,B"), .importKanji(literals: ["A", "B"], source: "kanjisage"))
        // Android filters blanks but does not trim a nonblank literal or deduplicate imports.
        XCTAssertEqual(parse("kanjijourney://import?kanji=%20A%20,A"), .importKanji(literals: [" A ", "A"], source: "kanjisage"))
    }

    func testSubscriptionAndInvalidLinks() {
        XCTAssertEqual(parse("kanjijourney://subscription"), .subscription)
        for url in ["https://subscription", "kanjijourney://unknown", "kanjijourney://collect",
                    "kanjijourney://collect?kanji_id=no", "kanjijourney://collect?kanji_id=2147483648",
                    "kanjijourney://import", "kanjijourney://import?kanji=,%20,"] {
            XCTAssertNil(parse(url), url)
        }
    }

    func testImportResultCounts() {
        XCTAssertEqual(KanjiDeepLink.importMessage(imported: 2, alreadyKnown: 3, notFound: 1),
                       "2 kanji added to study deck, 3 already studying, 1 not found")
        XCTAssertEqual(KanjiDeepLink.importMessage(imported: 0, alreadyKnown: 1, notFound: 0), "1 already studying")
        XCTAssertEqual(KanjiDeepLink.importMessage(imported: 0, alreadyKnown: 0, notFound: 1), "1 not found")
        XCTAssertEqual(KanjiDeepLink.importMessage(imported: 0, alreadyKnown: 0, notFound: 0), "No kanji to import.")
    }

    @MainActor
    func testQueueWaitsForMainAndResultDismissal() throws {
        let queue = DeepLinkQueue()
        queue.enqueue(try XCTUnwrap(URL(string: "kanjijourney://collect?kanji_id=1")))
        queue.enqueue(try XCTUnwrap(URL(string: "kanjijourney://subscription")))
        queue.enqueue(try XCTUnwrap(URL(string: "https://ignored")))
        XCTAssertNil(queue.beginNext(isReady: false)) // splash, initialization or login
        XCTAssertEqual(queue.pending.count, 2)
        XCTAssertEqual(queue.beginNext(isReady: true), .collect(kanjiId: 1, source: "kanjilens"))
        XCTAssertNil(queue.beginNext(isReady: true)) // collection result still visible
        queue.enqueue(try XCTUnwrap(URL(string: "kanjijourney://import?kanji=A")))
        queue.finish()
        XCTAssertNil(queue.beginNext(isReady: false))
        XCTAssertEqual(queue.beginNext(isReady: true), .subscription)
        queue.finish()
        XCTAssertEqual(queue.beginNext(isReady: true), .importKanji(literals: ["A"], source: "kanjisage"))
        queue.finish()
        XCTAssertNil(queue.beginNext(isReady: true))
        XCTAssertFalse(queue.isProcessing)
    }
}
