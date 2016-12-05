# ポーカー作りで Swift 3 の空気を感じる(後半)

<p style="font-size:80px; text-align: center;">⛄🎄🎅🎂🎁🎄⛄
</p>
<p style="text-align: center;">めりーさんたさん❗</p>


こんにちは [Liaro](http://company.liaro.me) の [131e55](https://twitter.com/131e55) です。

この記事は、[前半]()からの続きのもので、Swift 3 でコマンドライン上で動く簡単なポーカーを作る流れを書いたものになります。また、[Swift その2 Advent Calendar 2016](http://qiita.com/advent-calendar/2016/swift2)の25日目の記事となります。トリにしてはなぁ感がある記事ですがその2だしいっかという軽い気持ちで書きます(てへ)

# 開発環境

- Swift 3.0.1
- Xcode 8.1
- macOS 10.12.1

# 開発の流れ

以下の流れで作っていきます。項目1から7は[前半]()で終えていますので今回は項目8からとなります。

1. Xcodeプロジェクト作成 (前半)
1. カードを管理する構造体 (前半)
1. カードの表示 (前半)
1. カードの比較 (前半)
1. 山札を管理する構造体 (前半)
1. 手札を管理する構造体 (前半)
1. 役を管理する列挙型 (前半)
1. 役判定の実装
1. ポーカーの実装

では役判定の実装から❗

# 役判定の実装

役判定をどう実装するかを考えるために、とりあえず各役の関係を整理してみます。

じゃん。

<img width="450" alt="PokerHands.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/a9077b31-7bd1-4e15-bcec-b251c74ce28c.png">

図から、ポーカーの役は「同じランクを含む役」と「同じランクを含まない役」のふたつに分類でき、「同じランクを含まない役」はエースハイストレート(A, K, Q, J, 10 によるストレート)、ストレート、フラッシュの3つを判定できればそれらを組み合わせることで4つ全てを判定できることがわかります。対して「同じランクを含む役」は以下の表のように、手札を同じランク別に分けてそれぞれの枚数を見れば判定できることがわかります。

<a name="table_SameRankHands"></a>

|同じランクを含む役|同じランク別の枚数|例|
|:--|:--|:--|
|フォーカード|4, 1|[♣️A ♦️A ♥️A ♠️A] [♥️K]|
|フルハウス|3, 2|[♣️A ♦️A ♥️A] [♠️2 ♥️2]|
|スリーカード|3, 1, 1|[♣️A ♦️A ♥️A] [♠️2] [♥️K]|
|ツーペア|2, 2, 1|[♣️A ♦️A] [♥️2 ♠️2] [♥️K]|
|ワンペア|2, 1, 1, 1|[♣️A ♦️A] [♥️2] [♠️3] [♥️K]|

と、言うわけで、役判定実装の流れは以下の順にしてみます。

- 同じランク別の枚数の取得
- 同じランクを含む役の判定
- エースハイストレートを含むかどうかの判定
- ストレートを含むかどうかの判定
- フラッシュを含むかどうかの判定
- 同じランクを含まない役の判定

役判定に関するコードはちゃんと動くのか怪しいので、テストコードも書いていきます。今までに作成した `Suit.swift`、`Rank.swift`、`Card.swift`、`PokerHand.swift` を `PokerCLITests` ターゲットから参照できるように以下の図のようにそれぞれチェックをいれます。(図の一番下)

<img width="264" alt="テスト準備.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/03a01708-a3f2-92c9-9e4a-8c2f1b25c33c.png">

## 同じランク別の枚数の取得

ではまず同じランク別の枚数の取得からです。 `PokerHand` 列挙型に `static` なメソッドとして追加します。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }

    // ココ❗
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


    init(cards: [Card]) { /* 長いので省略 */ }
}
```

英語が合ってるか微妙ですが `PokerHand.countsBySameRank(cards: [Card]) -> [Int]` と定義し、渡された5枚のカードの同じランク別の枚数を配列で返します。

テストコードは簡単に、全ての役の手札を用意しておき、`PokerHand.countsBySameRank(cards: [Card]) -> [Int]` が期待通りに動くかをテストします。「同じランクを含む役」は[同じランクを含む役の各枚数](#table_SameRankHands)の通りに、「同じランクを含まない役」と🐷は `[1, 1, 1, 1, 1]` となってほしいです。

```swift:PokerCLITests.swift
import XCTest
@testable import PokerCLI

class PokerCLITests: XCTestCase {

    // ココ❗
    
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

    override func setUp() { /* 省略 */ }
    override func tearDown() { /* 省略 */ }

    // ココ❗
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
}

```

ではテストを走らせてみます。

<img width="600" alt="テスト結果.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/af61c239-a647-7119-f4fc-4c90823e5a74.png">

左上に　`✅` がついているのでテストが通りました。雑なテストケースですが、`PokerHand.countsBySameRank(cards: [Card]) -> [Int]` はとりあえず期待どおりに動いていそうです。この流れで他のテストコードも書いていきます。長くなるので以降はテスト結果のみ載せます。

## 同じランクを含む役の判定

同じランク別の枚数の取得ができたら「同じランクを含む役」であるワンペア、ツーペア、スリーカード、フルハウス、フォーカードは全て確定できます。というわけでこれらの役の判定を `PokerHand` のコンストラクタ `init` に追記していきましょう。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }
    static func countsBySameRank(cards: [Card]) -> [Int] { /* 長いので省略 */ }
   
    init(cards: [Card]) {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            self = .highCard
            return
        }

        // ココ❗
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
        else {
            self = .highCard
        }
    }
}
```

(´-\`).｡oO( `switch` で書きたかったのに配列ではできない様子❓誰か教えてください...)

## エースハイストレートを含むかどうかの判定

ここからは「同じランクを含まない役」の判定です。

まずはエースハイストレートを含むかどうかを判定します。単純なストレートの判定は手札が連番かどうかを見れば良さそうですが `A, K, Q, J, 10` の場合は `A` がちょっと邪魔なので単純にこの5つ全てを含むかどうかで判定することにします。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }
    static func countsBySameRank(cards: [Card]) -> [Int] { /* 長いので省略 */ }
    
    // ココ❗
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
    
    init(cards: [Card]) { /* 長いので省略 */ }
}
```

渡されたカード5枚にエースハイストレートの役を含むなら `true`、含まないなら `false` を返します。

テストコードは以下です。エースハイストレートを含む役はロイヤルストレートフラッシュとエースハイストレートになるはずです。

<img width="600" alt="AceHighStraightテスト結果" src="https://qiita-image-store.s3.amazonaws.com/0/104039/a6f3978b-4797-2c6c-3598-c7ad931c819b.png">

## ストレートを含むかどうかの判定

エースハイストレートとならないストレートの判定は単純に連番になるかを見れば良いですね。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }
    static func countsBySameRank(cards: [Card]) -> [Int] { /* 長いので省略 */ }
    static func containsAceHighStraight(cards: [Card]) -> Bool { /* 長いので省略 */ }
    
    // ココ❗
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
    
    init(cards: [Card]) { /* 長いので省略 */ }
}
```

もっと上手い方法がありそうですが、連番かどうかを判定しています。エースハイストレートの場合もストレートなので、先に作った `PokerHand.containsAceHighStraight(cards: [Card]) -> Bool` を使って判定しています。

テストコードは以下です。ストレートを含む役はロイヤルストレートフラッシュ、ストレートフラッシュ、エースハイストレート、ストレートになるはずです。

<img width="600" alt="Straightテスト結果" src="https://qiita-image-store.s3.amazonaws.com/0/104039/348f6122-cd26-80c0-26c7-5231fa2fcb2e.png">

## フラッシュを含むかどうかの判定

含むかどうか判定最後のフラッシュ判定いきます。役判定の中で一番簡単そうです。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }
    static func countsBySameRank(cards: [Card]) -> [Int] { /* 長いので省略 */ }
    static func containsAceHighStraight(cards: [Card]) -> Bool { /* 長いので省略 */ }
    static func containsStraight(cards: [Card]) -> Bool { /* 長いので省略 */ }
    
    // ココ❗
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
    
    init(cards: [Card]) { /* 長いので省略 */ }
}
```

1枚目のスートと同じスートを持つカードを抽出して、元の手札の数と同じなら全部同じスートでしょうということですね。

テストコードは以下です。フラッシュを含む役はロイヤルストレートフラッシュ、ストレートフラッシュ、フラッシュになるはずです。

<img width="600" alt="スクリーンショット 2016-12-05 18.06.49.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/9650f6d5-894d-548a-6208-736f09c4a531.png">

## 同じランクを含まない役の判定

ここまででエースハイストレート、ストレート、フラッシュを含むかどうかを判定できるようになったので、「同じランクを含まない役」であるストレート、フラッシュ、ストレートフラッシュ、ロイヤルストレートフラッシュを全て確定できます。というわけでこれらの役の判定を `PokerHand` のコンストラクタ `init` に追記して役判定を完成させましょう。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */ }
    static func countsBySameRank(cards: [Card]) -> [Int] { /* 長いので省略 */ }
    static func containsAceHighStraight(cards: [Card]) -> Bool { /* 長いので省略 */ }
    static func containsStraight(cards: [Card]) -> Bool { /* 長いので省略 */ }
    static func containsFlush(cards: [Card]) -> Bool { /* 長いので省略 */ }

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
        // ココ❗
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
```

まず `ココ❗` まで到達するのは同じランク別の枚数が全て1枚、つまり同じランクを含まない手札のときです。ここから、フラッシュとエースハイストレートを含む場合はロイヤルストレートフラッシュ、フラッシュとエースハイでないストレートを含むならストレートフラッシュ、フラッシュだけならフラッシュと確定でき、フラッシュを含まずストレートを含むならストレートと確定、フラッシュもストレートも含まないのなら🐷と確定できます。

これで役判定は完成したはずです。テストしてみましょう。手札に相当する `PokerHand` の値になっているはずです。(例えばワンペアの手札で `PokerHand` を生成すると列挙型の値は `.onePair`)

<img width="898" alt="PokerHandテスト結果.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/5bf41992-d61e-d1fb-c93f-6c32f438a72e.png">

ヾ(๑╹◡╹)ﾉ”いえーい

# ポーカーの実装

やっとだー！やっとポーカーを実装できます。`main.swift` に書いていきますよー。

```swift:main.swift
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
```

こんな感じで良いでしょう❗

さっそく何回か実行してみます。

<img width="350" alt="PokerCLI実行1.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/12417ae1-bffa-ffb4-108c-06e110504931.png">

おお

<img width="350" alt="PokerCLI実行2.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/97b10fb6-e16e-6b51-4e34-5983e2733155.png">

交換しない場合も動いていそう😃

<img width="350" alt="PokerCLI実行3.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/98da8cee-e924-0e2e-ffe0-8b9c7834dc05.png">

惜しいぶー🐷

<img width="350" alt="PokerCLI実行4.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/3e0e0019-1b69-67c1-4bd6-d8a69d95ccb0.png">

Σ(・∀・；)

# おわりに

[前半]()、後半(本記事)と長くなってしまいましたが、純粋な Swift 3 を使ってコマンドラインで動くポーカーを作ることができました。ジョーカーを含んでいないのでポーカーのアルゴリズムの参考になるかは怪しいところですが Swift 3 で書くとこんな感じのコードになるのか〜という空気は感じてもらえていたら嬉しいです。

これをきっかけに Swift に触れてみようかなという人が増えてくれたらいいなぁヾ(๑╹◡╹)ﾉ”



# おまけ

```swift:omake.swift
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
```

<img width="500" alt="omake1" src="https://qiita-image-store.s3.amazonaws.com/0/104039/68a8094b-65c6-cf6c-7ca9-351e6d860946.png">

<img width="500" alt="omake2" src="https://qiita-image-store.s3.amazonaws.com/0/104039/7e824b0a-d9b5-93f3-b2f9-65968d519283.png">