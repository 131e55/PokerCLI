//
//  Card.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/16.
//  Copyright © 2016年 131e55. All rights reserved.
//

struct Card: CustomStringConvertible, Equatable {
    let suit: Suit
    let rank: Rank

    var description: String {
        return "|" + suit.description + rank.description + "|"
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
