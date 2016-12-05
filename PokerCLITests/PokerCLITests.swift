//
//  PokerCLITests.swift
//  PokerCLITests
//
//  Created by 131e55 on 2016/11/28.
//  Copyright © 2016年 131e55. All rights reserved.
//

import XCTest
@testable import PokerCLI

class PokerCLITests: XCTestCase {

    // |♣️ A||♣️ 2||♥️ J||♦️ 3||♥️ Q| 🐷手札
    let highCardCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .jack), Card(suit: .diamond, rank: .three), Card(suit: .heart, rank: .queen)]
    // |♣️ A||♣️ 2||♥️ A||♦️ 3||♥️ Q| ワンペア手札
    let onePairCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .ace), Card(suit: .diamond, rank: .three), Card(suit: .heart, rank: .queen)]
    // |♣️ A||♣️ 2||♥️ A||♦️ 2||♥️ Q| ツーペア手札
    let twoPairCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .ace), Card(suit: .diamond, rank: .two), Card(suit: .heart, rank: .queen)]
    // |♣️ A||♣️ 2||♥️ A||♦️ A||♥️ Q| スリーカード手札
    let threeOfAKindCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .ace), Card(suit: .diamond, rank: .ace), Card(suit: .heart, rank: .queen)]
    // |♣️ A||♣️ 2||♥️ 3||♦️ 4||♥️ 5] ストレート手札
    let straightCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .three), Card(suit: .diamond, rank: .four), Card(suit: .heart, rank: .five)]
    // |♣️ A||♣️10||♥️ J||♦️ Q||♥️ K| エースハイストレート手札
    let aceHighStraightCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .ten), Card(suit: .heart, rank: .jack), Card(suit: .diamond, rank: .queen), Card(suit: .heart, rank: .king)]
    // |♣️ A||♣️ 3||♣️ 5||♣️ J||♣️ K| フラッシュ手札
    let flushCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .three), Card(suit: .club, rank: .jack), Card(suit: .club, rank: .four), Card(suit: .club, rank: .king)]
    // |♣️ A||♣️ 2||♥️ A||♦️ A||♥️ 2| フルハウス手札
    let fullHouseCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .ace), Card(suit: .diamond, rank: .ace), Card(suit: .heart, rank: .two)]
    // |♣️ A||♣️ 2||♥️ A||♦️ A||♠️ A| フォーカード手札
    let fourOfAKindCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .heart, rank: .ace), Card(suit: .diamond, rank: .ace), Card(suit: .spade, rank: .ace)]
    // |♣️ A||♣️ 2||♣️ 3||♣️ 4||♣️ 5| ストレートフラッシュ手札
    let straightFlushCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .two), Card(suit: .club, rank: .three), Card(suit: .club, rank: .four), Card(suit: .club, rank: .five)]
    // |♣️ A||♣️10||♣️ J||♣️ Q||♣️ K| ロイヤルストレートフラッシュ手札
    let royalFlushCards = [Card(suit: .club, rank: .ace), Card(suit: .club, rank: .ten), Card(suit: .club, rank: .jack), Card(suit: .club, rank: .queen), Card(suit: .club, rank: .king)]

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCountsBySameRank() {
        XCTAssertEqual(PokerHand.countsBySameRank(cards: highCardCards), [1, 1, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: onePairCards), [2, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: twoPairCards), [2, 2, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: threeOfAKindCards), [3, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: straightCards), [1, 1, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: aceHighStraightCards), [1, 1, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: flushCards), [1, 1, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: fullHouseCards), [3, 2])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: fourOfAKindCards), [4, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: straightFlushCards), [1, 1, 1, 1, 1])
        XCTAssertEqual(PokerHand.countsBySameRank(cards: royalFlushCards), [1, 1, 1, 1, 1])
    }

    func testContainsAceHighStraight() {
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: highCardCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: onePairCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: twoPairCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: threeOfAKindCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: straightCards))
        XCTAssertTrue(PokerHand.containsAceHighStraight(cards: aceHighStraightCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: flushCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: fullHouseCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: fourOfAKindCards))
        XCTAssertFalse(PokerHand.containsAceHighStraight(cards: straightFlushCards))
        XCTAssertTrue(PokerHand.containsAceHighStraight(cards: royalFlushCards))
    }

    func testContainsStraight() {
        XCTAssertFalse(PokerHand.containsStraight(cards: highCardCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: onePairCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: twoPairCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: threeOfAKindCards))
        XCTAssertTrue(PokerHand.containsStraight(cards: straightCards))
        XCTAssertTrue(PokerHand.containsStraight(cards: aceHighStraightCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: flushCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: fullHouseCards))
        XCTAssertFalse(PokerHand.containsStraight(cards: fourOfAKindCards))
        XCTAssertTrue(PokerHand.containsStraight(cards: straightFlushCards))
        XCTAssertTrue(PokerHand.containsStraight(cards: royalFlushCards))
    }

    func testContainsFlush() {
        XCTAssertFalse(PokerHand.containsFlush(cards: highCardCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: onePairCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: twoPairCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: threeOfAKindCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: straightCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: aceHighStraightCards))
        XCTAssertTrue(PokerHand.containsFlush(cards: flushCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: fullHouseCards))
        XCTAssertFalse(PokerHand.containsFlush(cards: fourOfAKindCards))
        XCTAssertTrue(PokerHand.containsFlush(cards: straightFlushCards))
        XCTAssertTrue(PokerHand.containsFlush(cards: royalFlushCards))
    }

    func testPokerHand() {
        XCTAssertEqual(PokerHand(cards: highCardCards), .highCard)
        XCTAssertEqual(PokerHand(cards: onePairCards), .onePair)
        XCTAssertEqual(PokerHand(cards: twoPairCards), .twoPair)
        XCTAssertEqual(PokerHand(cards: threeOfAKindCards), .threeOfAKind)
        XCTAssertEqual(PokerHand(cards: straightCards), .straight)
        XCTAssertEqual(PokerHand(cards: aceHighStraightCards), .straight)
        XCTAssertEqual(PokerHand(cards: flushCards), .flush)
        XCTAssertEqual(PokerHand(cards: fullHouseCards), .fullHouse)
        XCTAssertEqual(PokerHand(cards: fourOfAKindCards), .fourOfAKind)
        XCTAssertEqual(PokerHand(cards: straightFlushCards), .straightFlush)
        XCTAssertEqual(PokerHand(cards: royalFlushCards), .royalFlush)
    }
}


