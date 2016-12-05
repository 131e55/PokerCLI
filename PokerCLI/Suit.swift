//
//  Suit.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/16.
//  Copyright © 2016年 131e55. All rights reserved.
//

enum Suit: Int, CustomStringConvertible {
    case club
    case diamond
    case heart
    case spade

    static var allCases: [Suit] {
        var value = 0
        var cases: [Suit] = []
        while let suit = Suit(rawValue: value) {
            cases.append(suit)
            value += 1
        }
        return cases
    }

    var description: String {
        switch self {
        case .club:     return "♣️"
        case .diamond:  return "♦️"
        case .heart:    return "♥️"
        case .spade:    return "♠️"
        }
    }
}
