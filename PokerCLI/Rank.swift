//
//  Rank.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/16.
//  Copyright © 2016年 131e55. All rights reserved.
//

enum Rank: Int, CustomStringConvertible {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king

    static var allCases: [Rank] {
        var value = 1
        var cases: [Rank] = []
        while let rank = Rank(rawValue: value) {
            cases.append(rank)
            value += 1
        }
        return cases
    }

    var description: String {
        // 10だけ2文字になるのを避けるため10以外は先頭に半角スペースを追加する
        switch self {
        case .ace:      return " A"
        case .ten:      return String(rawValue)
        case .jack:     return " J"
        case .queen:    return " Q"
        case .king:     return " K"
        default:        return " " + String(rawValue)
        }
    }
}
