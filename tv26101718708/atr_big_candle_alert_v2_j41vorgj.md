# ATR Big Candle Alert v2

- url: https://www.tradingview.com/script/J41VorGj/
- type: indicator
- pine_id: PUB;2fb863507cd849bf825c0858f336f23c
- version: 1.0

## Description

Highlighits candles whose body size exceeds ATR × multiplier. Useful for identifying unusually strong  bullish and bearish momentum candles relative to current market volatility. Works on all markets and timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © shojiy940207

//@version=6
indicator("ATR Big Candle Alert v2", overlay=true)

// ===== inputs =====
atrLen       = input.int(14, "ATR Length")
mult1        = input.float(1.3, "ATR Multiplier 1 (標準)", step=0.1)
mult2        = input.float(2.0, "ATR Multiplier 2 (大)", step=0.1)
mult3        = input.float(3.0, "ATR Multiplier 3 (特大)", step=0.1)
maxWickPct   = input.float(33.0, "最大ひげ割合 (%)", minval=0.0, maxval=100.0)
enableAlerts = input.bool(true, "Enable Alerts")

// ===== calc =====
atr = ta.atr(atrLen)
body = math.abs(close - open)
candleRange = high - low

// ひげの割合計算（高値-安値に対して、ひげが占めるパーセンテージ）
wickTotal = candleRange - body
wickPct = candleRange > 0 ? (wickTotal / candleRange) * 100 : 0.0

// ひげの条件チェック（指定した％未満であればパス）
validWick = wickPct < maxWickPct

// ===== conditions =====
// 1.3倍以上 (Level 1)
bigBull1 = close > open and body > atr * mult1 and validWick
bigBear1 = close < open and body > atr * mult1 and validWick

// 2.0倍以上 (Level 2)
bigBull2 = close > open and body > atr * mult2 and validWick
bigBear2 = close < open and body > atr * mult2 and validWick

// 3.0倍以上 (Level 3)
bigBull3 = close > open and body > atr * mult3 and validWick
bigBear3 = close < open and body > atr * mult3 and validWick

// ===== visual (色の塗り分け) =====
// 倍率が高い方を優先して色を上書きします
color bullColor = na
color bearColor = na

if bigBull1
    bullColor := color.rgb(0, 255, 0, 60)   // 薄い緑
if bigBull2
    bullColor := color.lime                 // 通常のライム
if bigBull3
    bullColor := color.green                // 濃い緑

if bigBear1
    bearColor := color.rgb(255, 0, 0, 60)   // 薄い赤
if bigBear2
    bearColor := color.red                  // 通常の赤
if bigBear3
    bearColor := color.maroon               // 濃い赤（マルーン）

barcolor(bullColor)
barcolor(bearColor)

// ===== alerts =====
// Level 1
alertcondition(enableAlerts and bigBull1, title="Big Bull 1.3x", message="ATR Big Bull Candle (1.3x)")
alertcondition(enableAlerts and bigBear1, title="Big Bear 1.3x", message="ATR Big Bear Candle (1.3x)")

// Level 2
alertcondition(enableAlerts and bigBull2, title="Big Bull 2.0x", message="ATR Big Bull Candle (2.0x)")
alertcondition(enableAlerts and bigBear2, title="Big Bear 2.0x", message="ATR Big Bear Candle (2.0x)")

// Level 3
alertcondition(enableAlerts and bigBull3, title="Big Bull 3.0x", message="ATR Big Bull Candle (3.0x)")
alertcondition(enableAlerts and bigBear3, title="Big Bear 3.0x", message="ATR Big Bear Candle (3.0x)")
````
