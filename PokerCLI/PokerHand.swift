//
//  PokerHand.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/24.
//  Copyright © 2016年 131e55. All rights reserved.
//

enum PokerHand: Int, CustomStringConvertible {

    case highCard
    case onePair
    case twoPair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
    case straightFlush
    case royalFlush

    var description: String {
        switch self {
        case .highCard:      return "🐷"
        case .onePair:       return "ワンペア"
        case .twoPair:       return "ツーペア"
        case .threeOfAKind:  return "スリーカード"
        case .straight:      return "ストレート"
        case .flush:         return "フラッシュ"
        case .fullHouse:     return "フルハウス"
        case .fourOfAKind:   return "フォーカード"
        case .straightFlush: return "ストレートフラッシュ"
        case .royalFlush:    return "ロイヤルストレートフラッシュ"
        }
    }

    static func countsBySameRank(cards: [Card]) -> [Int] {
        // カードが何枚かあることを保証
        guard !cards.isEmpty else {
            return [0]
        }

        var cards = cards
        var counts: [Int] = []

        // 1枚目から順にそのカードと同じランクのカードを手札から抽出し枚数を数えていく
        // 抽出されたカードは手札から除いていき手札がなくなったら終わり
        while !cards.isEmpty {
            let card = cards.first!
            let sameRankCards = cards.filter({ $0.rank == card.rank })
            cards = cards.filter({ $0.rank != card.rank })
            counts.append(sameRankCards.count)
        }

        // 降順にソート
        counts.sort(by: { $0 > $1 })

        return counts
    }

    static func containsAceHighStraight(cards: [Card]) -> Bool {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            return false
        }

        // ランクの降順にソート
        let cards = cards.sorted { $0.rank.rawValue > $1.rank.rawValue }

        // K, Q, J, 10, A ならエースハイストレートを含む。違うなら含まない。
        if cards[0].rank == .king
            && cards[1].rank == .queen
            && cards[2].rank == .jack
            && cards[3].rank == .ten
            && cards[4].rank == .ace {

            return true
        }
        
        return false
    }


    static func containsStraight(cards: [Card]) -> Bool {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            return false
        }

        // エースハイストレートだったらストレートを含むとして終了。
        if PokerHand.containsAceHighStraight(cards: cards) {
            return true
        }

        // ランクの降順にソート
        let cards = cards.sorted { $0.rank.rawValue > $1.rank.rawValue }

        // 1枚目から4枚目までそれぞれ注目していく。
        // 全て「注目したカードの数字が次のカードの数字の１大きい数」ならストレートを含む。
        // 違うなら含まない。
        for i in 0..<cards.count - 1 {

            if cards[i].rank.rawValue == cards[i + 1].rank.rawValue + 1 {
                continue
            }

            return false
        }

        return true
    }

    static func containsFlush(cards: [Card]) -> Bool {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            return false
        }

        // 1枚目のスートを用意し、手札からそのスートと同じスートを持つカードだけを抽出する
        // 手札の枚数と同じなら全部同じスートなのでフラッシュを含む。違うなら含まない。
        let suit = cards[0].suit
        return cards.filter({ $0.suit == suit }).count == cards.count
    }

    init(cards: [Card]) {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            self = .highCard
            return
        }

        let counts = PokerHand.countsBySameRank(cards: cards)

        if counts == [2, 1, 1, 1] {
            self = .onePair
        }
        else if counts == [2, 2, 1] {
            self = .twoPair
        }
        else if counts == [3, 1, 1] {
            self = .threeOfAKind
        }
        else if counts == [3, 2] {
            self = .fullHouse
        }
        else if counts == [4, 1] {
            self = .fourOfAKind
        }
        else if PokerHand.containsFlush(cards: cards) {
            if PokerHand.containsAceHighStraight(cards: cards) {
                self = .royalFlush
            }
            else if PokerHand.containsStraight(cards: cards) {
                self = .straightFlush
            }
            else {
                self = .flush
            }
        }
        else if PokerHand.containsStraight(cards: cards) {
            self = .straight
        }
        else {
            self = .highCard
        }
    }
}
