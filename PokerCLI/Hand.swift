//
//  Hand.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/22.
//  Copyright © 2016年 131e55. All rights reserved.
//

struct Hand: CustomStringConvertible {
    private(set) var cards: [Card]

    var description: String {
        var string = ""
        cards.forEach { (card) in
            string += card.description
        }
        return string
    }

    mutating func replace(discardIndices: [Int], newCards: [Card]) {
        // 捨てる枚数と新しいカードの枚数が同じであることと捨てるカードの位置が正しいものであることを保証
        guard discardIndices.count == newCards.count
            && discardIndices.count == discardIndices.filter({0..<cards.count ~= $0}).count
            else {
            return
        }

        for (index, card) in newCards.enumerated() {
            let discardIndex = discardIndices[index]
            cards[discardIndex] = card
        }
    }
}
