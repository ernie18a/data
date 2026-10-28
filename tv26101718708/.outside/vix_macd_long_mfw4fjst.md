# VIX MACD Long

- url: https://www.tradingview.com/script/mfw4fJST/
- type: strategy
- pine_id: PUB;d436bd860df34a43b27fe46cd10e5c41
- version: 1.0

## Description

これは VIX（恐怖指数）のMACDを使って、日経平均を売買するロング戦略。

ルールはシンプル。

VIX MACDがデッドクロス
市場の恐怖が弱まり始めたと判断
日経平均を買う
VIX MACDがゴールデンクロス
市場の恐怖が強まり始めたと判断
日経平均を売る

| 総トレード数   |        70回 |
| 勝ち       |        47回 |
| 負け       |        22回 |
| 引き分け     |         1回 |
| 勝率       |     約67.1% |
| 累計利益     |  +921,137円 |
| 平均損益     |   +13,159円 |
| 最大利益     |  +132,177円 |
| 最大損失     |  -173,434円 |
| 最大ドローダウン | 約-173,434円 |

## Source Code

````pine
//@version=6
strategy("VIX MACD Long", overlay=true)

// === VIX取得 ===
vix = request.security("CBOE:VIX", timeframe.period, close)

// === MACD設定 ===
fastLength = input.int(12, "MACD Fast")
slowLength = input.int(26, "MACD Slow")
signalLength = input.int(9, "MACD Signal")

macdLine = ta.ema(vix, fastLength) - ta.ema(vix, slowLength)
signalLine = ta.ema(macdLine, signalLength)

// === エントリー条件 ===
// VIX MACDデッドクロス
longCondition = ta.crossunder(macdLine, signalLine)

// === 決済条件 ===
// VIX MACDゴールデンクロス
exitCondition = ta.crossover(macdLine, signalLine)

// === 売買 ===
if longCondition
    strategy.entry("Long", strategy.long)

if exitCondition
    strategy.close("Long")
````
