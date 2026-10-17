# Ichimoku Based Supertrend

- url: https://www.tradingview.com/script/2UEov2h8/
- type: indicator
- pine_id: PUB;84c501df29e44d2682a5b3c45d7ea862
- version: 1.0

## Description

Ichimoku Based Supertrend

The Ichimoku Based Supertrend is a trend-following indicator that combines the market structure of the Ichimoku Cloud with the simplicity of the Supertrend.

The indicator uses the midpoint between Senkou Span A and Senkou Span B as its core trend reference. ATR (Average True Range) is then applied to create dynamic upper and lower bands that adapt to market volatility. A bullish trend is confirmed when price closes above the upper band, while a bearish trend is confirmed when price closes below the lower band.

Key Features:

Combines Ichimoku Cloud structure with Supertrend logic
ATR-based adaptive volatility bands
Clear and easy-to-read trend signals
Automatic Buy and Sell signal generation
Suitable for Crypto, Forex, Stocks, and Indices

Designed for traders who want a cleaner view of trend direction while incorporating the powerful market structure of the Ichimoku system.

Ichimoku Based Supertrend

一目均衡表の雲とスーパートレンドを組み合わせたトレンドフォロー型インジケーターです。

先行スパンAと先行スパンBの中心値を基準ラインとして使用し、ATR（Average True Range）を利用して動的な上下バンドを形成します。価格が上部バンドを突破すると上昇トレンド、下部バンドを下抜けると下降トレンドへ転換したと判断します。

主な特徴：

一目均衡表の市場構造を活用
ATRによるボラティリティ適応型バンド
シンプルで分かりやすいトレンド判定
売買シグナルを自動表示
仮想通貨、FX、株式など幅広い市場に対応

トレンドの方向性を素早く把握したいトレーダー向けに設計されています。

## Source Code

````pine
//@version=5
indicator("Ichimoku Based Supertrend", overlay=true)

// Inputs
tenkanLen = input.int(9, "転換線")
kijunLen  = input.int(26, "基準線")
senkouLen = input.int(52, "先行スパンB")
atrLen    = input.int(14, "ATR期間")
mult      = input.float(2.0, "ATR倍率", step=0.1)

// Ichimoku
tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun  = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2
spanA  = (tenkan + kijun) / 2
spanB  = (ta.highest(high, senkouLen) + ta.lowest(low, senkouLen)) / 2

cloudMid = (spanA + spanB) / 2

// Bands
atr = ta.atr(atrLen)
upperBand = cloudMid + atr * mult
lowerBand = cloudMid - atr * mult

// Supertrend logic
var float trendLine = na
var int trend = 1

if close > upperBand
    trend := 1
else if close < lowerBand
    trend := -1
else
    trend := trend[1]

trendLine := trend == 1 ? lowerBand : upperBand

// Plot
plot(trendLine, color = trend == 1 ? color.lime : color.red, linewidth=2, title="Ichimoku Supertrend")

plot(spanA, color=color.new(color.green, 80), title="先行スパンA")
plot(spanB, color=color.new(color.red, 80), title="先行スパンB")

bgcolor(trend == 1 ? color.new(color.green, 90) : color.new(color.red, 90))

// Signals
buySignal  = trend == 1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] == 1

plotshape(buySignal, title="BUY", style=shape.labelup, text="BUY", color=color.lime, textcolor=color.black, location=location.belowbar)
plotshape(sellSignal, title="SELL", style=shape.labeldown, text="SELL", color=color.red, textcolor=color.white, location=location.abovebar)

alertcondition(buySignal, title="BUY Alert", message="Ichimoku Supertrend BUY")
alertcondition(sellSignal, title="SELL Alert", message="Ichimoku Supertrend SELL")
````
