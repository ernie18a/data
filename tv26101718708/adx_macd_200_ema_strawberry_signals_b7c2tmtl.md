# ADX/ MACD/ 200 EMA Strawberry Signals 

- url: https://www.tradingview.com/script/B7C2tMtl-ADX-MACD-200-EMA-Strawberry-Signals/
- type: indicator
- pine_id: PUB;e4f35b9b3da540d3b02cd6fd155fb499
- version: 1.0

## Description

[b]🍓 Strawberry Signals 🍓[/b]


The [b]Strawberry Signals[/b] indicator is a trend-following trading tool designed to help traders identify high-probability market entries by combining three core components:
[i]trend direction (EMA 200), momentum (MACD), and trend strength (ADX)[/i].
Signals are only displayed on confirmed candles to ensure stability and avoid repainting behavior.

[b]📌 Indicator Concept[/b]

This indicator focuses on trading in the direction of the dominant trend. Instead of generating frequent signals, it filters out low-quality market conditions and only highlights setups where trend, momentum, and strength are aligned.

The goal is to reduce noise and help traders focus on clearer market structures rather than overtrading in sideways conditions.

[b]
📊 Core Components
[/b]

[b]1. EMA 200 – Trend Filter[/b]

The EMA 200 is used as the primary trend direction filter.

- Price above EMA 200 → bullish market structure
- Price below EMA 200 → bearish market structure

This ensures that signals are always aligned with the higher timeframe bias of the market.


[b]2. MACD – Momentum Confirmation[/b]

The MACD crossover is used to confirm momentum shifts in the direction of the trend:

- Bullish signal: MACD line crosses above signal line
- Bearish signal: MACD line crosses below signal line

This helps identify moments where momentum supports the trend direction.


[b]3. ADX – Trend Strength Filter
[/b]
The ADX is used to measure whether the market is strong enough for trend trading.
Only when ADX is above the selected threshold (default: 20) will signals be allowed.

- Low ADX → weak or sideways market (no signals)
- High ADX → strong trend conditions (valid signals)


[b]🟢 Buy Signal Conditions[/b]

Price is above the EMA 200
MACD line crosses above the signal line
ADX is above the defined threshold (trend strength confirmed)
Signal is confirmed on candle close (no intrabar signals)


[b]🔴 Sell Signal Conditions[/b]

Price is below the EMA 200
MACD line crosses below the signal line
ADX is above the defined threshold (trend strength confirmed)
Signal is confirmed on candle close (no intrabar signals)


[b]⚙️ Settings Overview[/b]

EMA Length: Defines the trend filter (default: 200)
MACD Settings: Controls momentum sensitivity (fast, slow, signal)
ADX Length: Smoothness of trend strength calculation
ADX Threshold: Minimum trend strength required for signals


📉 Market Conditions

This indicator performs best in trending environments where price moves directionally with momentum.
During sideways or low-volatility conditions, fewer signals will appear by design, as weak trends are filtered out.


[b]👤 My Personal Use[/b]

This indicator is intentionally designed to produce fewer signals. Entries are only generated at the exact moment of a MACD crossover when all required conditions are aligned. I use it for [b]XAUUSD on the 1M chart[/b] but I'm confident for it to work on different instruments. 

In my personal trading, I also monitor situations where the ADX rises above the threshold [i]after[/i] the MACD crossover. If momentum remains strong and the overall trend structure (EMA direction) is still valid, these scenarios can still offer interesting trade opportunities even if no signal was printed.

For better decision-making, I recommend displaying the MACD and ADX directly on the chart alongside this indicator. This helps to visually confirm momentum development for trading and trend strength beyond the signal itself.

[b]⚠️ Important Notes[/b]

This indicator is designed for educational and analytical purposes.
It does not guarantee profitable trades.
Always combine signals with proper risk management and additional confirmation tools and market structure if needed.


[b]🍓 Summary[/b]

Strawberry Signals provides a clean and structured approach to trend trading by combining multiple technical indicators into a single signal system.
It is built to reduce noise, filter weak setups, and highlight only high-quality trend-aligned opportunities directly on the chart.

## Source Code

````pine
//@version=6
indicator("Strawberry Signals (Fixed to Candle)", overlay=true)

// === Inputs ===
adxLen = input.int(14, "ADX Length")
adxThreshold = input.int(20, "ADX Threshold")

fastLen = input.int(12, "MACD Fast")
slowLen = input.int(26, "MACD Slow")
signalLen = input.int(9, "MACD Signal")

emaLen = input.int(200, "EMA Length")

// === EMA 200 ===
ema200 = ta.ema(close, emaLen)

// === MACD ===
[macdLine, signalLine, _] = ta.macd(close, fastLen, slowLen, signalLen)

// === ADX ===
tr = math.max(math.max(high - low, math.abs(high - close[1])), math.abs(low - close[1]))

plusDM = (high - high[1] > low[1] - low and high - high[1] > 0) ? high - high[1] : 0
minusDM = (low[1] - low > high - high[1] and low[1] - low > 0) ? low[1] - low : 0

trRma = ta.rma(tr, adxLen)
plusDMRma = ta.rma(plusDM, adxLen)
minusDMRma = ta.rma(minusDM, adxLen)

plusDI = 100 * plusDMRma / trRma
minusDI = 100 * minusDMRma / trRma

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

// === FILTERS ===
trendStrong = adx > adxThreshold
confirmed = barstate.isconfirmed

// === TREND ===
upTrend = close > ema200
downTrend = close < ema200

// === MACD CROSS ===
macdBullCross = ta.crossover(macdLine, signalLine)
macdBearCross = ta.crossunder(macdLine, signalLine)

// === SIGNALS ===
buySignal = confirmed and trendStrong and upTrend and macdBullCross
sellSignal = confirmed and trendStrong and downTrend and macdBearCross

// === EMA ===
plot(ema200, "EMA 200", color=color.orange, linewidth=2)

// 🍓 FIXED TO CANDLE (BEST POSSIBLE OPTION)
plotshape(buySignal,
     location=location.belowbar,
     style=shape.labelup,
     text="🍓",
     size=size.small,
     color=color.new(#b6ffb9, 0),
     textcolor=color.white)

plotshape(sellSignal,
     location=location.abovebar,
     style=shape.labeldown,
     text="🍓",
     size=size.small,
     color=color.new(#fdcaeb, 0),
     textcolor=color.white)
````
