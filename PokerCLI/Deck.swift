//
//  Deck.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/17.
//  Copyright © 2016年 131e55. All rights reserved.
//

import Foundation

struct Deck {
    private(set) var cards: [Card] = []

    init() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                let card = Card(suit: suit, rank: rank)
                cards.append(card)
            }
        }
    }

    mutating func shuffle() {
        for _ in 0..<100 {
            let cardsCount = UInt32(cards.count)
            let removeIndex = Int(arc4random_uniform(cardsCount))
            let insertIndex = Int(arc4random_uniform(cardsCount - 1))
            let card = cards.remove(at: removeIndex)
            cards.insert(card, at: insertIndex)
        }
    }

    mutating func draw(count: Int) -> [Card]? {
        // 山札がゼロでないかつ引く枚数が確実に引ける枚数であることを保証
        guard !cards.isEmpty &&
            1...cards.count ~= count else {
            return nil
        }

        var drawCards: [Card] = []
        for _ in 0..<count {
            drawCards.append(cards.removeFirst())
        }
        return drawCards
    }
}
