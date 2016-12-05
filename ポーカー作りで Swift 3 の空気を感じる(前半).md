# ポーカー作りで Swift 3 の空気を感じる(前半)

こんにちは [Liaro](http://company.liaro.me) の [131e55](https://twitter.com/131e55) です。

[Swift その2 Advent Calendar 2016](http://qiita.com/advent-calendar/2016/swift2)の13日目の記事となります。

先月トランプ大統領が誕生したので、トランプにかけた何かを作りたいなーと思い何番煎じかはわかりませんがポーカーを作ることにしました。

この記事は、実際に僕がポーカーを作った流れを淡々と書いていくだけのもので、Swift 3 の構文についての解説は特にしません。Swift 3 で書くとこんな感じになるのか〜という空気を感じてもらえたらうれしいです。ポーカー作りの参考にもなるかもしれません。

また、出来るだけ純粋な Swift の空気を感じてもらうため、作るポーカーは GUI のものではなくコマンドラインで動かすものとし、利用するフレームワークも Swift を使う上で必須となるであろう `Foundation` のみとします。

# 開発環境
- Swift 3.0.1
- Xcode 8.1
- macOS 10.12.1

# 今回作るポーカーの動きを考える

最終的にこんな感じで遊べるポーカーを作っていくことにしましょうか。ポーカーにしてはちゃっちいですが役判定で苦戦しそうなのでこんなもんにします。ジョーカーもなしで。

```
ポーカーを始めます❗

あなたの手札: |♥️10||♠️ 4||♥️ A||♦️ 9||♣️ Q|

何枚目の手札を交換しますか❓(半角数字、半角スペース区切り)
(交換しない場合は何も入力せずにエンター)
> 2 4 5

あなたの手札: |♥️10||♥️ K||♥️ A||♥️ Q||♥️ J|

ロイヤルストレートフラッシュでした❗
```

# 開発の流れ

開発は以下の流れで行います。項目8と9は本記事ではなく後半として別の記事とします。

1. Xcodeプロジェクト作成
1. カードを管理する構造体
1. カードの表示
1. カードの比較
1. 山札を管理する構造体
1. 手札を管理する構造体
1. 役を管理する列挙型
1. 役判定の実装 (後半)
1. ポーカーの実装 (後半)

# Xcodeプロジェクト作成

今回作るポーカーは Xcode を使って作ります。
まず新規プロジェクトを `Command Line Tool` として作成します。

<img width="400" alt="Xcodeプロジェクト作成1.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/f4575785-6a4f-2551-3aff-0c8a0ee8ee4b.png">

プロジェクト名は適当に`PokerCLI`とします。

<img width="400" alt="Xcodeプロジェクト作成2.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/af1e9fd6-8474-346f-04e7-660083ee7cf5.png">

作成したら`main.swift`が用意されています。
とりあえず実行して`Hello, World!`を確認。

<img width="400" alt="Xcodeプロジェクト作成3.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/f44047e9-7399-7b5a-43ea-e16e6703ef0f.png">

最終的にこの `main.swift` 内にポーカーの処理を書いていきますが、そこで用いる構造体や列挙型 (カード、山札、手札、役等を管理するもの。これから作っていきます) はそれぞれ新しくファイルを作っていくことにします。

## テストの準備

後々実装する役判定はちゃんと動くのか怪しくなる気がするので簡単なテストコードを書くことにし、予めテストの準備を進めておきます。

Xcode メニューの File > New > Target から `OS X Unit Testing Bundle` を追加します。

<img width="400" alt="Xcodeプロジェクト作成4.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/7fae90c2-f9d5-eba4-f82c-a7926f9bd76a.png">

ターゲット名は適当に `PokerCLITests` とします。

<img width="400" alt="Xcodeプロジェクト作成5.png" src="https://qiita-image-store.s3.amazonaws.com/0/104039/4e671fb8-789d-73d5-5d7c-31b2ed218178.png">

作成された `PokerCLITests.swift` の中に役判定のテストコードを書いていきます。とりあえず以下の様に、元々書いてある `testExample()` と `testPerformanceExample()` は不要なので削除し、これから作っていく `PokerCLI` をテストターゲットとするため `@testable import PokerCLI` を追記しておきます。

```swift:PokerCLITests.swift
import XCTest
@testable import PokerCLI

class PokerCLITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
```


# カードを管理する構造体

ポーカーをするにはまずカードが必要ですね。ポーカーの役を判定するにあたってカードのマークと数字が必要になるのでそれらの情報をまとめた型があると便利そうです。そこで `Card` という名前の構造体を定義します。

```swift:Card.swift
struct Card {
    let suit: Suit
    let rank: Rank
}
```

(´-\`).｡oO(何も考えずカードのマークを mark、数字を numberと名付けようとしましたが[トランプ-Wikipedia](https://ja.wikipedia.org/wiki/トランプ)ではスートとランクと呼んでいたのでそれに合わせることにしました)

ここで、謎の `Suit` 型、`Rank` 型は次の列挙型として定義しています。

```swift:Suit.swift
enum Suit: Int {
    case club
    case diamond
    case heart
    case spade
}
```

```swift:Rank.swift
enum Rank: Int {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king
}
```

(´-`).｡oO(Swift 2までは列挙型の各値(各ケース)の名前は大文字で始めるのが普通でしたが、Swift 3からは小文字で始めるのが推奨されています)

これで、次のようにカードを表すことができます。

```swift
// クラブのエースのカード構造体
let card = Card(suit: .club, rank: .ace)
```

わざわざ列挙型として `Suit` と `Rank` を定義したのは、しなかった場合、例えばスートを `String` 型、ランクを `Int` 型にしたとすると、

```swift
let card = Card(suit: "こんにちは", rank: 200)
```

とかできちゃってちょーださいからです。持つ値が有限で全て列挙できるときは列挙型 `enum` を使うと良いでしょう。

# カードの表示

`Card` 構造体を用いて生成したカードを `print` でそのまま表示すると次のようになります。

```swift
let card = Card(suit: .club, rank: .ace)
print(card)

// こんな感じで出力される
// Card(suit: PokerCLI.Suit.club, rank: PokerCLI.Rank.ace)
```

手札を表示する際にこれだとわかりづらいので、今回のポーカーでは、例えばクラブのエースの場合 `|♣️ A|` 、ハートの10の場合は `|♥️10|` という感じで表示してみたいと思います。

`print` で表示される内容を変更したいときは `CustomStringConvertible` プロトコルの `description` を実装すれば良いです。`Suit` 、`Rank` 、`Card` それぞれに実装します。

```swift:Suit.swift
                // ココ❗
enum Suit: Int, CustomStringConvertible {
    case club
    case diamond
    case heart
    case spade

    // ココ❗
    var description: String {
        switch self {
        case .club:     return "♣️"
        case .diamond:  return "♦️"
        case .heart:    return "♥️"
        case .spade:    return "♠️"
        }
    }
}
```

```swift:Rank.swift
                // ココ❗
enum Rank: Int, CustomStringConvertible {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king

    // ココ❗
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
```

```swift:Card.swift
             // ココ❗
struct Card: CustomStringConvertible {
    let suit: Suit
    let rank: Rank

    // ココ❗
    var description: String {
        return "|" + suit.description + rank.description + "|"
    }
}

```

これで改めてカードを表示してみます。

```swift
let card1 = Card(suit: .club, rank: .ace)
let card2 = Card(suit: .diamond, rank: .six)
let card3 = Card(suit: .heart, rank: .ten)
let card4 = Card(suit: .spade, rank: .queen)
print(card1, card2, card3, card4)

// こう表示される
// |♣️ A| |♦️ 6| |♥️10| |♠️ Q|
```

うんよさげです。手札の表示はこれでいくことにします。

# カードの比較

あるカードとあるカードが同じカードなのかを判断するにはどうすれば良いでしょうか。

以下の様に書けたら便利ですが、ただの構造体同士ではこういった比較ができずエラーになります。

```swift
let card1 = Card(suit: .club, rank: .ace)
let card2 = Card(suit: .club, rank: .ace)
print(card1 == card2) // エラー
```

列挙型同士ではできるので以下の様に書けば確かに同じカードなのかどうかがわかりますが、構造体の全プロパティに対してひとつひとつチェックしていくのはださすぎます。

```swift
let card1 = Card(suit: .club, rank: .ace)
let card2 = Card(suit: .club, rank: .ace)
print(card1.suit == card2.suit && card1.rank == card2.rank)
```

Swift では構造体同士でも、構造体に `Equatable` プロトコルを実装することで `==` 演算子を使えるようになります。要は `==` 演算子を自作するわけですが。

```swift:Card.swift
                                      // ココ❗
struct Card: CustomStringConvertible, Equatable {
    let suit: Suit
    let rank: Rank

    var description: String {
        return "|" + suit.description + rank.description + "|"
    }

    // ココ❗
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.rank == rhs.rank
    }
}
```

`==` を実装することで、左辺と右辺がどういうときに等しいとするかを定義することができます。今回はスートとランクが同じであったら同じカードであるとします。

これで次のようにカードが同じのものかどうかを楽に比較することができるようになります。

```swift
let card1 = Card(suit: .club, rank: .ace)
let card2 = Card(suit: .club, rank: .ace)
print(card1 == card2)
// true と表示される
```

(´-\`).｡oO( `>` や `<` など大小の比較をしたい場合は `Comparable` プロトコルを実装するとできます。後々の役判定のときに `Rank` 型に対して大小の比較をできるように `Comparable` プロトコルを実装するべきかなとも思いましたが今回は列挙型の  `rawValue` の値だけでやりきることにしました。また、`Suit` 型に `Comparable` を実装すれば、♥️と♠️はどちらが強いかとかを比較できたりします。今回つくるポーカーでは２組の手札の強さを比べるまではしないので実装しません。)

# 山札を表す構造体

続いて、ポーカーの山札を管理するための `Deck` 構造体を作ることにします。`Deck` 構造体は次のような機能を持たせます。

- 山札のカードを管理する
- 山札のカードをシャッフルする
- 山札からカードを引く

## 山札のカードを管理する

というわけでまず、初期値として52(4スート * 13ランク)種類のカードを山札として持つように、次のような感じで書きはじめようとしましたが…

```swift:Deck.swift
struct Deck {
    private(set) var cards: [Card]

    init() {
        cards = [
            Card(suit: .club, rank: .ace),
            Card(suit: .club, rank: .two),
            Card(suit: .club, rank: .three),
            ...,
            ...,
            ...
        ]
    }
}
```

…カード52枚分をずらーっとを書くのがめんどくさすぎました。どっかで抜けたり重なったりとミスしそうですしやってられません。`Suit` 型と `Rank` 型の値それぞれを `for in` で回せると楽に書けて漏れも置きずに済みそうです。しかし、Swift 3 では(でも😔)列挙型の各値を `for in` で回すことはできないようなので `Suit` と `Rank` を以下のように改良することにします。

(´-\`).｡oO(列挙型でも `for in` を使えるように拡張するプロトコルを自作している記事があったので多分標準ではできないと思われます。ちょっと不便です。Swift 4でこないかしら…(｡•ˇ‸ˇ•｡))

```swift:Suit.swift
enum Suit: Int, CustomStringConvertible {
    case club
    case diamond
    case heart
    case spade

    // ココ❗
    static var allCases: [Suit] {
        var value = 0
        var cases: [Suit] = []
        while let suit = Suit(rawValue: value) {
            cases.append(suit)
            value += 1
        }
        return cases
    }

    var description: String { /* 長いので省略 */ }
}
```

```swift:Rank.swift
enum Rank: Int, CustomStringConvertible {
    case ace = 1
    case two, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king

    // ココ❗
    static var allCases: [Rank] {
        var value = 1
        var cases: [Rank] = []
        while let rank = Rank(rawValue: value) {
            cases.append(rank)
            value += 1
        }
        return cases
    }

    var description: String { /* 長いので省略 */ }
}
```

`Suit.allCases` と `Rank.allCases` で全ての値(全てのケース)を配列として返すようにしてみました。ちなみにこの `while` の使い方も面白いところです。値を指定して列挙型を生成するとき、その値に該当するものがなかった場合は生成が失敗し `nil` が返るので `if let` と同様に `false` となり `while` を抜けます。

改めて `Deck` 構造体を定義します。

```swift:Deck.swift
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
}
```

試しに生成して出力してみましょう。

```swift
let deck = Deck()
print(deck)

// こう表示される
// Deck(cards: [|♣️ A|, |♣️ 2|, |♣️ 3|, |♣️ 4|, |♣️ 5|, |♣️ 6|, |♣️ 7|, |♣️ 8|, |♣️ 9|, |♣️10|, |♣️ J|, |♣️ Q|, |♣️ K|, |♦️ A|, |♦️ 2|, |♦️ 3|, |♦️ 4|, |♦️ 5|, |♦️ 6|, |♦️ 7|, |♦️ 8|, |♦️ 9|, |♦️10|, |♦️ J|, |♦️ Q|, |♦️ K|, |♥️ A|, |♥️ 2|, |♥️ 3|, |♥️ 4|, |♥️ 5|, |♥️ 6|, |♥️ 7|, |♥️ 8|, |♥️ 9|, |♥️10|, |♥️ J|, |♥️ Q|, |♥️ K|, |♠️ A|, |♠️ 2|, |♠️ 3|, |♠️ 4|, |♠️ 5|, |♠️ 6|, |♠️ 7|, |♠️ 8|, |♠️ 9|, |♠️10|, |♠️ J|, |♠️ Q|, |♠️ K|])
```

かんぺき。

## 山札のカードをシャッフルする

次に山札のシャッフルを作ります。シャッフルのアルゴリズムは考えるのめんどいので単純に「ランダムな位置にあるカードを一度抜いてランダムな位置に再び挿入する」をいくらか繰り返したものにします。

```swift:Deck.swift
import Foundation

struct Deck {
    private(set) var cards: [Card] = []

    init() { /* 長いので省略 */ }

    // ココ❗
    mutating func shuffle() {
        for _ in 0..<100 {
            let cardsCount = UInt32(cards.count)
            let removeIndex = Int(arc4random_uniform(cardsCount))
            let insertIndex = Int(arc4random_uniform(cardsCount - 1))
            let card = cards.remove(at: removeIndex)
            cards.insert(card, at: insertIndex)
        }
    }
}
```

`mutating` は構造体が持つデータ自身を変更する際に必要となるキーワードです。シャッフルは自分のカード配列を変更するので `mutating` が必要になります。

(´-\`).｡oO(`arc4random_uniform()` は乱数を返すメソッドですが、純粋な Swift のものではありません。`import Foundation` から読み込んでいます。できるだけ純粋な Swift で進めて行きたかったのですが実際のところ　`Foundation` フレームワークを使わない場合はほとんどないと思うので妥協しました)

これでシャッフルができたはずなので上手くシャッフルできるか確認してみます。

```swift
var deck = Deck()
print("シャッフル前:", deck)
deck.shuffle()
print("シャッフル後:", deck)

// こんな感じで表示される
// シャッフル前: Deck(cards: [|♣️ A|, |♣️ 2|, |♣️ 3|, |♣️ 4|, |♣️ 5|, |♣️ 6|, |♣️ 7|, |♣️ 8|, |♣️ 9|, |♣️10|, |♣️ J|, |♣️ Q|, |♣️ K|, |♦️ A|, |♦️ 2|, |♦️ 3|, |♦️ 4|, |♦️ 5|, |♦️ 6|, |♦️ 7|, |♦️ 8|, |♦️ 9|, |♦️10|, |♦️ J|, |♦️ Q|, |♦️ K|, |♥️ A|, |♥️ 2|, |♥️ 3|, |♥️ 4|, |♥️ 5|, |♥️ 6|, |♥️ 7|, |♥️ 8|, |♥️ 9|, |♥️10|, |♥️ J|, |♥️ Q|, |♥️ K|, |♠️ A|, |♠️ 2|, |♠️ 3|, |♠️ 4|, |♠️ 5|, |♠️ 6|, |♠️ 7|, |♠️ 8|, |♠️ 9|, |♠️10|, |♠️ J|, |♠️ Q|, |♠️ K|])
// シャッフル後: Deck(cards: [|♣️ 6|, |♦️ J|, |♠️ 8|, |♠️ 9|, |♦️ 5|, |♣️ A|, |♣️10|, |♣️ 7|, |♦️ 3|, |♥️ 8|, |♥️ 5|, |♦️ 4|, |♣️ 5|, |♣️ 9|, |♦️ 2|, |♦️ 8|, |♦️ K|, |♥️ 7|, |♠️ 3|, |♣️ 2|, |♦️ 7|, |♥️ J|, |♠️ A|, |♦️ 9|, |♠️10|, |♦️10|, |♠️ K|, |♥️ 2|, |♣️ 8|, |♠️ Q|, |♠️ 7|, |♥️ A|, |♥️ 3|, |♦️ A|, |♥️ 6|, |♥️ Q|, |♥️ K|, |♣️ K|, |♣️ 3|, |♥️ 9|, |♣️ J|, |♣️ 4|, |♥️ 4|, |♠️ 6|, |♠️ 5|, |♠️ 4|, |♦️ 6|, |♠️ J|, |♦️ Q|, |♣️ Q|, |♠️ 2|, |♥️10|])
```

上手くシャッフルできてますね。

ちなみに上記の例ですが、以下のように `var deck` ではなく `let deck` だとエラーになります。

```
let deck = Deck()
deck.shuffle()	// エラー
```

これは構造体は、**複数のデータをまとめたひとつのデータ** であるので,
そのひとつのデータを定数としてしまうと、自身のデータを変更する `mutating` なメソッド `shuffle` を呼ぼうとすると、いやいや定数だし変更できませんよ。とエラーになるわけですね。

## 山札からカードを引く

次は山札からカードを引く操作を実装します。引く枚数は任意とし引数で渡すことにしましょう。
最初にカードを配るときは5枚引きますが、その後の交換時には1枚から5枚と変わってくるので。

```swift:Deck.swift
import Foundation

struct Deck {
    private(set) var cards: [Card] = []

    init() { /* 長いので省略 */ }

    mutating func shuffle() { /* 長いので省略 */ }

    // ココ❗
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
```

カードを引く操作も山札のカードを管理する自身の配列 `cards` を変更するものなので `mutating` が必要です。引いたカードをオプショナルで返しているのは山札が0枚のときに何枚か引こうとしたり、山札が3枚のときに5枚引こうとしたりしたときはカードがないので、その場合は失敗を意味して nil を返しますよってことですね。

(´-\`).｡oO(今回作るポーカーは配られて交換して役を出したら終了するので山札が足りなくなるということはないですが)

上手くできているか確認してみましょう。

```swift
var deck = Deck()
deck.shuffle()
print("引く前:", deck)

let cards1 = deck.draw(count: 1)!
print("引いたカード:", cards1)
print("引いた後:", deck)

let cards2 = deck.draw(count: 3)!
print("さらに引いたカード: ", cards2)
print("さらに引いた後:", deck)

// こんな感じで表示される
// 引く前: Deck(cards: [|♥️ 2|, |♣️ 2|, |♥️ 9|, |♣️ 6|, |♥️ K|, |♥️ 8|, |♦️10|, |♦️ 8|, |♦️ 4|, |♣️ 3|, |♥️ A|, |♥️ 7|, |♠️ 9|, |♥️ 4|, |♥️ 6|, |♥️ 5|, |♣️ Q|, |♦️ Q|, |♣️ 5|, |♦️ A|, |♦️ K|, |♥️ Q|, |♠️ 7|, |♣️ 4|, |♦️ 7|, |♣️ K|, |♣️ 7|, |♠️ 5|, |♦️ 6|, |♥️ J|, |♠️ 8|, |♠️ K|, |♠️ 2|, |♠️ Q|, |♠️ J|, |♣️ A|, |♣️10|, |♦️ 5|, |♠️ 3|, |♦️ 9|, |♣️ 9|, |♠️ A|, |♦️ 3|, |♠️10|, |♠️ 4|, |♦️ 2|, |♥️10|, |♣️ J|, |♥️ 3|, |♣️ 8|, |♠️ 6|, |♦️ J|])
// 引いたカード: [|♥️ 2|]
// 引いた後: Deck(cards: [|♣️ 2|, |♥️ 9|, |♣️ 6|, |♥️ K|, |♥️ 8|, |♦️10|, |♦️ 8|, |♦️ 4|, |♣️ 3|, |♥️ A|, |♥️ 7|, |♠️ 9|, |♥️ 4|, |♥️ 6|, |♥️ 5|, |♣️ Q|, |♦️ Q|, |♣️ 5|, |♦️ A|, |♦️ K|, |♥️ Q|, |♠️ 7|, |♣️ 4|, |♦️ 7|, |♣️ K|, |♣️ 7|, |♠️ 5|, |♦️ 6|, |♥️ J|, |♠️ 8|, |♠️ K|, |♠️ 2|, |♠️ Q|, |♠️ J|, |♣️ A|, |♣️10|, |♦️ 5|, |♠️ 3|, |♦️ 9|, |♣️ 9|, |♠️ A|, |♦️ 3|, |♠️10|, |♠️ 4|, |♦️ 2|, |♥️10|, |♣️ J|, |♥️ 3|, |♣️ 8|, |♠️ 6|, |♦️ J|])
// さらに引いたカード:  [|♣️ 2|, |♥️ 9|, |♣️ 6|]
// さらに引いた後: Deck(cards: [|♥️ K|, |♥️ 8|, |♦️10|, |♦️ 8|, |♦️ 4|, |♣️ 3|, |♥️ A|, |♥️ 7|, |♠️ 9|, |♥️ 4|, |♥️ 6|, |♥️ 5|, |♣️ Q|, |♦️ Q|, |♣️ 5|, |♦️ A|, |♦️ K|, |♥️ Q|, |♠️ 7|, |♣️ 4|, |♦️ 7|, |♣️ K|, |♣️ 7|, |♠️ 5|, |♦️ 6|, |♥️ J|, |♠️ 8|, |♠️ K|, |♠️ 2|, |♠️ Q|, |♠️ J|, |♣️ A|, |♣️10|, |♦️ 5|, |♠️ 3|, |♦️ 9|, |♣️ 9|, |♠️ A|, |♦️ 3|, |♠️10|, |♠️ 4|, |♦️ 2|, |♥️10|, |♣️ J|, |♥️ 3|, |♣️ 8|, |♠️ 6|, |♦️ J|])
```

シャッフルした山札からカードを何枚か引くとその分山札からそのカードがなくなっていますね。よさげです。

# 手札を表す構造体

次は自分の手札を管理する `Hand` 構造体を作ります。`Hand`構造体で実装する機能はこれらとします。

- 手札とするカードの管理
- 手札のカードと新しいカードを交換する

## 手札とするカードの管理

まず基本の定義はこちら。手札とするカードを管理します。
ついでに `print` で表示される内容も変更してます。(´-\`).｡oO(こんな感じで表示したい`|♣️ A||♣️ 2||♣️ 3||♣️ 4||♣️ 5|`)

```swift:Hand.swift
struct Hand: CustomStringConvertible {
    private(set) var cards: [Card]

    var description: String {
        var string = ""
        cards.forEach { (card) in
            string += card.description
        }
        return string
    }
}
```

生成して表示してみましょう。山札を用意してシャッフルして5枚引いたのを手札として生成しています。

```swift
var deck = Deck()
deck.shuffle()
print("手札を配る前:", deck)

let hand = Hand(cards: deck.draw(count: 5)!)
print("配られた手札:", hand)
print("手札を配った後:", deck)

// こんな感じで表示される
// 手札を配る前: Deck(cards: [|♥️10|, |♦️ Q|, |♠️ K|, |♣️ 3|, |♣️ 4|, |♠️ 2|, |♦️10|, |♠️ A|, |♣️ 6|, |♥️ A|, |♣️ 8|, |♣️ 2|, |♣️ A|, |♦️ 4|, |♣️ J|, |♥️ Q|, |♠️ 7|, |♠️ 3|, |♦️ 5|, |♥️ 2|, |♥️ K|, |♦️ K|, |♦️ J|, |♠️ 9|, |♥️ 5|, |♦️ 9|, |♣️ K|, |♣️ 5|, |♥️ 8|, |♥️ J|, |♠️ 8|, |♣️ 9|, |♦️ 2|, |♦️ 7|, |♥️ 7|, |♣️10|, |♥️ 4|, |♣️ Q|, |♥️ 9|, |♣️ 7|, |♦️ 6|, |♥️ 6|, |♠️10|, |♠️ 4|, |♦️ A|, |♦️ 3|, |♠️ 6|, |♠️ 5|, |♠️ J|, |♦️ 8|, |♠️ Q|, |♥️ 3|])
// 配られた手札: |♥️10||♦️ Q||♠️ K||♣️ 3||♣️ 4|
// 手札を配った後: Deck(cards: [|♠️ 2|, |♦️10|, |♠️ A|, |♣️ 6|, |♥️ A|, |♣️ 8|, |♣️ 2|, |♣️ A|, |♦️ 4|, |♣️ J|, |♥️ Q|, |♠️ 7|, |♠️ 3|, |♦️ 5|, |♥️ 2|, |♥️ K|, |♦️ K|, |♦️ J|, |♠️ 9|, |♥️ 5|, |♦️ 9|, |♣️ K|, |♣️ 5|, |♥️ 8|, |♥️ J|, |♠️ 8|, |♣️ 9|, |♦️ 2|, |♦️ 7|, |♥️ 7|, |♣️10|, |♥️ 4|, |♣️ Q|, |♥️ 9|, |♣️ 7|, |♦️ 6|, |♥️ 6|, |♠️10|, |♠️ 4|, |♦️ A|, |♦️ 3|, |♠️ 6|, |♠️ 5|, |♠️ J|, |♦️ 8|, |♠️ Q|, |♥️ 3|])
```

良さげ。

## 手札のカードと新しいカードを交換する

次に手札のカードと新しいカードを交換する操作を実装します。

```swift:Hand.swift
struct Hand: CustomStringConvertible {
    private(set) var cards: [Card]

    var description: String { /* 長いので省略 */ }

    // ココ❗
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
```

(´-\`).｡oO(`guard` がちょっと読みづらくなってしまった…不正な値を渡したときに処理させないようにしたかっただけなので無視して良いです)

手札のどの位置のカードを捨てるかの配列と、新しいカードの配列を渡して交換させることにしました。 配列に対して `enumerated()` を使って `for in` をまわすと配列のインデックスと配列の要素をそれぞれ取れるので便利ですね。

正しく動くか確認してみます。

```swift
var deck = Deck()
deck.shuffle()
print("山札:", deck)

var hand = Hand(cards: deck.draw(count: 5)!)
print("配られた手札: ", hand)
print("現在の山札:", deck)

let discardIndices = [0, 3, 4]
hand.replace(
    discardIndices: discardIndices,
    newCards: deck.draw(count: discardIndices.count)!
)
print("1, 4, 5枚目を交換後の手札: ", hand)
print("現在の山札:", deck)

// こんな感じで表示される
// 山札: Deck(cards: [|♦️ 6|, |♥️ 6|, |♣️ A|, |♣️ 6|, |♣️ J|, |♥️ K|, |♠️ 9|, |♣️ 3|, |♥️ 8|, |♦️ J|, |♠️ Q|, |♣️ 4|, |♠️ 8|, |♥️ 3|, |♣️10|, |♦️ 2|, |♠️ 2|, |♠️ 7|, |♦️ A|, |♥️ Q|, |♦️ 5|, |♥️ A|, |♣️ Q|, |♣️ 9|, |♥️ 5|, |♣️ K|, |♦️ 3|, |♠️ 4|, |♦️ 9|, |♦️ Q|, |♥️ 7|, |♦️10|, |♥️ J|, |♠️ K|, |♦️ K|, |♣️ 5|, |♦️ 8|, |♦️ 4|, |♥️ 9|, |♥️10|, |♠️ 3|, |♠️ 6|, |♠️10|, |♥️ 2|, |♣️ 7|, |♣️ 8|, |♥️ 4|, |♠️ 5|, |♠️ A|, |♠️ J|, |♦️ 7|, |♣️ 2|])
// 配られた手札:  |♦️ 6||♥️ 6||♣️ A||♣️ 6||♣️ J|
// 現在の山札: Deck(cards: [|♥️ K|, |♠️ 9|, |♣️ 3|, |♥️ 8|, |♦️ J|, |♠️ Q|, |♣️ 4|, |♠️ 8|, |♥️ 3|, |♣️10|, |♦️ 2|, |♠️ 2|, |♠️ 7|, |♦️ A|, |♥️ Q|, |♦️ 5|, |♥️ A|, |♣️ Q|, |♣️ 9|, |♥️ 5|, |♣️ K|, |♦️ 3|, |♠️ 4|, |♦️ 9|, |♦️ Q|, |♥️ 7|, |♦️10|, |♥️ J|, |♠️ K|, |♦️ K|, |♣️ 5|, |♦️ 8|, |♦️ 4|, |♥️ 9|, |♥️10|, |♠️ 3|, |♠️ 6|, |♠️10|, |♥️ 2|, |♣️ 7|, |♣️ 8|, |♥️ 4|, |♠️ 5|, |♠️ A|, |♠️ J|, |♦️ 7|, |♣️ 2|])
// 1, 4, 5枚目を交換後の手札:  |♥️ K||♥️ 6||♣️ A||♠️ 9||♣️ 3|
// 現在の山札: Deck(cards: [|♥️ 8|, |♦️ J|, |♠️ Q|, |♣️ 4|, |♠️ 8|, |♥️ 3|, |♣️10|, |♦️ 2|, |♠️ 2|, |♠️ 7|, |♦️ A|, |♥️ Q|, |♦️ 5|, |♥️ A|, |♣️ Q|, |♣️ 9|, |♥️ 5|, |♣️ K|, |♦️ 3|, |♠️ 4|, |♦️ 9|, |♦️ Q|, |♥️ 7|, |♦️10|, |♥️ J|, |♠️ K|, |♦️ K|, |♣️ 5|, |♦️ 8|, |♦️ 4|, |♥️ 9|, |♥️10|, |♠️ 3|, |♠️ 6|, |♠️10|, |♥️ 2|, |♣️ 7|, |♣️ 8|, |♥️ 4|, |♠️ 5|, |♠️ A|, |♠️ J|, |♦️ 7|, |♣️ 2|])
```

手札の1, 4, 5枚目を交換してみました。良さそうですね。

# 役を表す列挙型

ポーカーの役を `PokerHand` という列挙型で定義します。

```swift:PokerHand.swift
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
}
```

この時点で `print(PokerHand.onePair)` とすると `ワンペア` と表示されるのは大丈夫でしょう多分。(`CustomStringConvertible` の `description` です)

役判定ですが、Swift の列挙型はコンストラクタ `init` を持たせることができるので、`PokerHand` にカード5枚で初期化するコンストラクタ `init` を追加し、渡したカード5枚に相当する役の値に自身を初期化してもらいます。

```swift:PokerHand.swift
enum PokerHand: Int, CustomStringConvertible {

    case highCard
    /* 長いので省略 */
    case royalFlush

    var description: String { /* 長いので省略 */　}
    
    // ココ❗
    init(cards: [Card]) {
        // カードが5枚であることを保証
        guard cards.count == 5 else {
            self = .highCard
            return
        }

        // ここで役判定して self に適切な値を入れる
        self = .highCard
    }
}
```

これで次のような使い方ができます。(役判定はまだしていないので必ず🐷になりますが)

```swift
var deck = Deck()
deck.shuffle()

var hand = Hand(cards: deck.draw(count: 5)!)
print("手札: ", hand)
print("手札の役:", PokerHand(cards: hand.cards))

// こんな感じで表示される
// 手札:  |♠️ 3||♣️ 5||♣️ A||♦️ A||♣️ 3|
// 手札の役: 🐷
```

# 役判定の実装
よーし、役判定をどう実装するか考えましょう。(´-\`).｡oO(苦戦する気しかしない)

と言いたいところですが

後半へ〜つづく (キートン山田風)

後半は[Swift その2 Advent Calendar 2016](http://qiita.com/advent-calendar/2016/swift2)の25日目に公開する予定です。