# Trend / Range / Down Days Counter v6

- url: https://www.tradingview.com/script/gKHZz4BN/
- type: indicator
- pine_id: PUB;1f240b530ca940ae9c867f70a0512379
- version: 1.0

## Description

Trend Duration Tracker v6

A trend-state indicator that automatically detects whether the market is currently in an:

UPTREND
DOWNTREND
RANGE

and displays how long the current condition has been active directly on the chart.

Features
• Automatic Market State Detection

The indicator continuously analyzes price action and trend direction using:

EMA slope
Price position relative to EMA
ATR-based noise filtering

to classify the market environment in real time.

• Trend Duration Display

Shows how long the current trend or range has lasted.

Example:

UPTREND
Duration: 12 Days

This helps traders understand whether a move is still developing or potentially becoming exhausted.

• Visual Background Coloring

The chart background changes automatically depending on market condition:

Green → Uptrend
Red → Downtrend
Aqua → Range

Making trend recognition instant and intuitive.

• Trend Change Markers

The indicator highlights transitions between market phases with labels such as:

UP START
DOWN START
RANGE

allowing traders to quickly identify possible regime shifts.

What It’s Useful For
✔ Trend Analysis

Track how long trends remain active and identify extended market conditions.

✔ Market Environment Recognition

Quickly determine whether the market is trending or ranging before entering trades.

✔ Multi-Market Compatibility

Works well across:

Cryptocurrency
Forex
Stocks
Indices
Commodities

and multiple timeframes.

Core Logic

The indicator combines:

EMA direction
EMA slope analysis
ATR volatility filtering
Price location relative to trend

to create a cleaner and more reliable trend-state model.

Best For
Trend-following traders
Swing traders
Crypto traders
Traders who want cleaner market structure analysis
In One Sentence

👉 “A visual market-state tracker that shows what trend the market is in — and how long it has lasted.”



Trend Duration Tracker v6

現在の相場が
上昇トレンド・下降トレンド・レンジ のどの状態にあるのかを自動判定し、
その継続期間を「日数」で表示するトレンド分析インジケーターです。

■ 特徴
● トレンド状態を自動判定
UPTREND
DOWNTREND
RANGE

をリアルタイムで表示。

EMAの傾きと価格位置を組み合わせ、
相場の方向性をシンプルかつ視覚的に把握できます。

● 継続日数を表示

現在の状態が

何日続いているか
どれくらい継続しているか

をチャート上へ表示。

例：

UPTREND
Duration: 12 Days
● 背景色で視認性アップ
緑 → 上昇トレンド
赤 → 下降トレンド
水色 → レンジ

チャートを開いた瞬間に相場環境を判断できます。

● トレンド転換ポイントも表示

状態が変わったタイミングで

UP START
DOWN START
RANGE

を自動表示。

■ 何に使えるか
✔ トレンドの継続分析

「今の上昇は伸びすぎか？」
「レンジが長すぎないか？」

を日数ベースで確認できます。

✔ 環境認識

エントリー前に

トレンド相場なのか
レンジ相場なのか

を一目で判断可能。

✔ 仮想通貨・FX・株に対応
BTC
ETH
アルトコイン
FX
株価指数

など、あらゆる市場で利用可能。

■ 判定ロジック
EMAの方向
EMAの傾き
現在価格との位置関係
ATRベースのノイズ除去

を組み合わせて相場状態を分類。

■ 向いている人
トレンドフォローをする人
レンジ回避したい人
環境認識を重視する人
仮想通貨トレーダー
■ 一言でいうと

👉 「今の相場が“どの状態で、どれだけ続いているか”を見える化するインジケーター」

## Source Code

````pine
//@version=6
indicator("Trend / Range / Down Days Counter v6", overlay=true, max_bars_back=1000, max_labels_count=500)

// =====================
// Inputs
// =====================
emaLen      = input.int(50, "Trend EMA Length", minval=1)
slopeLen    = input.int(5, "Slope Check Bars", minval=1)
atrLen      = input.int(14, "ATR Length", minval=1)
rangeFactor = input.float(0.25, "Range Sensitivity", minval=0.01, step=0.01)

showBg      = input.bool(true, "Show Background Color")
showLabel   = input.bool(true, "Show Current Status Label")
showMarkers = input.bool(true, "Show Change Markers")

// =====================
// Core
// =====================
emaLine = ta.ema(close, emaLen)
atrVal  = ta.atr(atrLen)

// EMA slope
emaSlope = emaLine - emaLine[slopeLen]

// Range threshold
rangeThreshold = atrVal * rangeFactor

// Trend detection
isUp    = emaSlope > rangeThreshold and close > emaLine
isDown  = emaSlope < -rangeThreshold and close < emaLine
isRange = not isUp and not isDown

// State
//  1 = Uptrend
//  0 = Range
// -1 = Downtrend
state = isUp ? 1 : isDown ? -1 : 0

// =====================
// Count bars
// =====================
var int currentState = na
var int stateBars = 0

stateChanged = na(currentState) or state != currentState

if stateChanged
    currentState := state
    stateBars := 1
else
    stateBars += 1

// Days conversion
secondsPerBar = timeframe.in_seconds(timeframe.period)
daysValue = secondsPerBar > 0 ? stateBars * secondsPerBar / 86400.0 : stateBars

daysText = timeframe.isdaily ? str.tostring(stateBars) + " Days" : str.tostring(daysValue, "#.##") + " Days"

// =====================
// Colors / Text
// =====================
statusText =
     currentState == 1 ? "UPTREND" :
     currentState == -1 ? "DOWNTREND" :
     "RANGE"

statusColor =
     currentState == 1 ? color.new(color.lime, 0) :
     currentState == -1 ? color.new(color.red, 0) :
     color.new(color.aqua, 0)

bgColor =
     currentState == 1 ? color.new(color.green, 90) :
     currentState == -1 ? color.new(color.red, 90) :
     color.new(color.aqua, 92)

// =====================
// Plot
// =====================
plot(emaLine, "Trend EMA", color=color.white, linewidth=2)

bgcolor(showBg ? bgColor : na)

// =====================
// Current label
// =====================
var label statusLabel = na

if showLabel and barstate.islast
    if not na(statusLabel)
        label.delete(statusLabel)

    labelText = statusText + "\nDuration: " + daysText

    statusLabel := label.new(
         x=bar_index,
         y=high,
         text=labelText,
         xloc=xloc.bar_index,
         yloc=yloc.abovebar,
         style=label.style_label_down,
         color=statusColor,
         textcolor=color.white,
         size=size.normal)

// =====================
// Change markers
// =====================
plotshape(
     showMarkers and stateChanged and currentState == 1,
     title="Uptrend Start",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="UP START",
     textcolor=color.white,
     size=size.small)

plotshape(
     showMarkers and stateChanged and currentState == 0,
     title="Range Start",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.aqua,
     text="RANGE",
     textcolor=color.black,
     size=size.small)

plotshape(
     showMarkers and stateChanged and currentState == -1,
     title="Downtrend Start",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="DOWN START",
     textcolor=color.white,
     size=size.small)

// =====================
// Alerts
// =====================
alertcondition(stateChanged and currentState == 1, title="Uptrend Started", message="UPTREND started")
alertcondition(stateChanged and currentState == 0, title="Range Started", message="RANGE started")
alertcondition(stateChanged and currentState == -1, title="Downtrend Started", message="DOWNTREND started")
````
