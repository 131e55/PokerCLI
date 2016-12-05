//
//  omake.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/12/04.
//  Copyright © 2016年 131e55. All rights reserved.
//

import Foundation

func omake() {
    print("最初の手札でロイヤルストレートフラッシュを出すぞい")

    var count = 1
    var pokerHand = PokerHand.highCard
    let start = Date().timeIntervalSince1970

    while pokerHand != .royalFlush {

        var deck = Deck()
        deck.shuffle()

        let hand = Hand(cards: deck.draw(count: 5)!)
        pokerHand = PokerHand(cards: hand.cards)

        let elapsed = (Date().timeIntervalSince1970 - start)
        print("\(count)回目❗", hand, pokerHand, "(\(elapsed) 秒経過)")

        count += 1
    }

    print("最初の手札でロイヤルストレートフラッシュを出したぞい❗")
    print()
}
