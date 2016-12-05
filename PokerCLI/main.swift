//
//  main.swift
//  PokerCLI
//
//  Created by 131e55 on 2016/11/16.
//  Copyright © 2016年 131e55. All rights reserved.
//


print("ポーカーを始めます❗")

var deck = Deck()
deck.shuffle()

var hand = Hand(cards: deck.draw(count: 5)!)
print()
print("あなたの手札: ", hand)

print()
print("何枚目の手札を交換しますか❓(半角数字、半角スペース区切り)")
print("(交換しない場合は何も入力せずにエンター)")

// コマンドライン上で入力待ちになりエンターを押すまで停止する
print("> ", terminator: "")
let input = readLine(strippingNewline: true)

// 何か文字が入力されていれば交換できるかも
if let input = input, input.characters.count > 0 {

    // 何枚目のカードを捨てるかを配列のインデックスとして保存
    var discardIndices: [Int] = []

    // 入力された文字列を半角スペースで区切った配列としそれぞれ見ていく
    for separatedString in input.components(separatedBy: " ") {

        // Intに変換できて、1以上5以下の数字なら許可
        if let number = Int(separatedString), 1...5 ~= number {

            // 配列のインデックスとして扱うため1減らしたものを追加
            discardIndices.append(number - 1)
        }
    }

    // 重複しているかもしれないので重複を除く
    discardIndices = Array(Set(discardIndices))

    // 空でなければ手札を交換する
    if !discardIndices.isEmpty {
        hand.replace(
            discardIndices: discardIndices,
            newCards: deck.draw(count: discardIndices.count)!
        )

        print()
        print("あなたの手札: ", hand)
    }
}

print()
print(PokerHand(cards: hand.cards), "でした❗")
print()
