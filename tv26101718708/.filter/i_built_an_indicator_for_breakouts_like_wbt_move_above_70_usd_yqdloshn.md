# I Built an Indicator for Breakouts Like WBT Move Above 70 USD

- url: https://www.tradingview.com/script/YQDlosHn-I-Built-an-Indicator-for-Breakouts-Like-WBT-Move-Above-70-USD/
- type: indicator
- pine_id: PUB;cd54516d53964119895fc9129659b47d
- version: 1.0

## Description

WBT 4H Breakout Momentum is built to identify the transition from consolidation into strong bullish expansion. Instead of reacting to every move above resistance, it combines price structure, candle strength, volume, ATR, and EMA direction to focus on breakouts that actually have participation behind them.

⚡ The main BREAKOUT signal appears when price closes above the previous range high with an ATR buffer, the bullish candle is large enough relative to current volatility, volume is elevated, and EMA 9 is above EMA 21. The default setup uses a 24-candle lookback, 14 ATR, and volume above 1.5x its 20-period average.

📈 After the initial breakout, the script keeps tracking momentum. Continuation signals appear when price holds above the breakout structure, remains above the fast EMA, and pushes through the previous candle's high, while unusually large candles with strong volume are marked separately as impulses.

🔍 I mainly use this on the 4H chart as a filter rather than an automatic entry system. It helps me quickly see whether a breakout has real momentum behind it, but I still pay attention to higher-timeframe levels, how extended price already is, and where the trade would actually be invalidated.

The settings can be adjusted for other assets and timeframes. Alerts are included for breakouts, momentum continuation, and strong impulse moves.

Disclaimer: This indicator is for analysis and educational purposes only. Always manage position size and test the setup before using it with real funds.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Crypto_Andy_

//@version=6
indicator("WBT 4H Breakout Momentum", overlay=true, max_labels_count=500)

// === Inputs ===
rangeLength     = input.int(24, "Consolidation Lookback", minval=5)
atrLength       = input.int(14, "ATR Length", minval=1)
volumeLength    = input.int(20, "Volume MA Length", minval=1)

breakoutATR     = input.float(0.25, "Breakout Buffer (ATR)", step=0.05)
strongBodyATR   = input.float(0.8, "Strong Candle Body (ATR)", step=0.1)
volumeMult      = input.float(1.5, "Volume Spike Multiplier", step=0.1)

emaFastLength   = input.int(9, "Fast EMA")
emaSlowLength   = input.int(21, "Slow EMA")

showLevels      = input.bool(true, "Show Breakout Levels")
showSignals     = input.bool(true, "Show Buy Signals")
showBackground  = input.bool(true, "Highlight Momentum")

// === Core calculations ===
atr = ta.atr(atrLength)

emaFast = ta.ema(close, emaFastLength)
emaSlow = ta.ema(close, emaSlowLength)

volumeMA = ta.sma(volume, volumeLength)

// Previous range, excluding current candle
rangeHigh = ta.highest(high[1], rangeLength)
rangeLow  = ta.lowest(low[1], rangeLength)

rangeSize = rangeHigh - rangeLow

// === Candle strength ===
bodySize = math.abs(close - open)

bullishCandle = close > open
strongBullCandle = bullishCandle and bodySize > atr * strongBodyATR

// === Volume ===
volumeSpike = volume > volumeMA * volumeMult

// === Breakout ===
breakoutLevel = rangeHigh + atr * breakoutATR

priceBreakout = close > breakoutLevel
freshBreakout = priceBreakout and close[1] <= rangeHigh[1]

// === Trend filters ===
bullTrend = emaFast > emaSlow
aboveFastEMA = close > emaFast

// === Main breakout signal ===
breakoutSignal =
     freshBreakout and
     strongBullCandle and
     volumeSpike and
     bullTrend

// === Momentum continuation ===
previousHighBreak =
     close > high[1] and
     bullishCandle and
     bodySize > atr * 0.5

continuationSignal =
     priceBreakout and
     previousHighBreak and
     aboveFastEMA and
     bullTrend and
     volume > volumeMA

// === Extreme impulse candle ===
impulseSignal =
     bullishCandle and
     bodySize > atr * 1.5 and
     volumeSpike and
     close > rangeHigh

// === Plot EMAs ===
plot(
     emaFast,
     title="EMA 9",
     color=color.new(color.green, 0),
     linewidth=2
)

plot(
     emaSlow,
     title="EMA 21",
     color=color.new(color.orange, 0),
     linewidth=2
)

// === Range levels ===
plot(
     showLevels ? rangeHigh : na,
     title="Range High",
     color=color.new(color.blue, 35),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showLevels ? rangeLow : na,
     title="Range Low",
     color=color.new(color.gray, 65),
     linewidth=1,
     style=plot.style_linebr
)

// === Signals ===
plotshape(
     showSignals and breakoutSignal,
     title="Breakout",
     location=location.belowbar,
     style=shape.labelup,
     text="BREAKOUT",
     color=color.green,
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and continuationSignal and not breakoutSignal,
     title="Momentum Continuation",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.tiny
)

plotshape(
     showSignals and impulseSignal,
     title="Impulse",
     location=location.abovebar,
     style=shape.circle,
     color=color.yellow,
     size=size.tiny
)

// === Momentum background ===
momentumActive =
     close > rangeHigh and
     emaFast > emaSlow and
     close > emaFast

bgcolor(
     showBackground and momentumActive
     ? color.new(color.green, 92)
     : na
)

// === Optional bar coloring ===
barcolor(
     impulseSignal
     ? color.lime
     : breakoutSignal
     ? color.green
     : na
)

// === Alerts ===
alertcondition(
     breakoutSignal,
     title="WBT Breakout",
     message="WBT bullish breakout detected"
)

alertcondition(
     continuationSignal,
     title="WBT Momentum Continuation",
     message="WBT bullish momentum continuation detected"
)

alertcondition(
     impulseSignal,
     title="WBT Strong Impulse",
     message="WBT strong bullish impulse candle detected"
)
````
