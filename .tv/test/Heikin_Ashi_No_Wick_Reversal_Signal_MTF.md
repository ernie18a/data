<!-- tradingview-pine-id: PUB;942e63ff2eb84695be8180699431ce08 -->
<!-- tradingviewscripts-format: 1 -->
# Heikin Ashi No Wick Reversal Signal MTF

Source: https://www.tradingview.com/script/yZ2mcxqj-Heikin-Ashi-No-Wick-Reversal-Signal-MTF/

## Description

# Heikin Ashi No Wick Reversal Signal MTF

This indicator identifies potential reversal and continuation entries using **Heikin Ashi candles** and the **No Wick candle pattern**.

The script detects the first Heikin Ashi candle of the opposite direction that forms with:

* **No bottom wick on bullish candles** → potential LONG signal
* **No top wick on bearish candles** → potential SHORT signal

The idea behind this pattern is to identify strong momentum candles where buyers or sellers have maintained control during the entire candle formation.

## Multi-Timeframe Support

The indicator includes a selectable timeframe option, allowing you to display signals from a different timeframe than your current chart.

Examples:

* Open a **15-minute chart**
* Select **5-minute signals**
* View 5-minute Heikin Ashi No Wick setups directly on the 15-minute chart

This allows traders to analyze lower timeframe opportunities while maintaining a higher timeframe view.

## Features

✓ Heikin Ashi based calculations
✓ First opposite-color no-wick signal detection
✓ Multi-timeframe signal display
✓ LONG and SHORT labels
✓ Alert conditions included
✓ Works on any market and timeframe

## Suggested Usage

This indicator is designed as a visual signal tool and can be combined with additional analysis such as:

* Market structure
* Support and resistance
* Liquidity zones
* Fair Value Gaps (FVG)
* Trend direction
* Risk management

Signals should not be considered guaranteed entries. Always combine the indicator with your own trading plan and proper risk management.

## Alerts

Alerts can be created directly from TradingView using:

* "HA Long No Wick MTF"
* "HA Short No Wick MTF"

The timeframe selected in the indicator settings determines the timeframe used for signal calculations.

---

## Source Code

````pine
//@version=6
indicator("Heikin Ashi No Wick Reversal Signal MTF", overlay=true)

// ───── Timeframe Selection ─────
signalTF = input.timeframe("5", "Signal Timeframe")

// ───── Heikin Ashi Data From Selected TF ─────
haTicker = ticker.heikinashi(syminfo.tickerid)

haOpen  = request.security(haTicker, signalTF, open)
haHigh  = request.security(haTicker, signalTF, high)
haLow   = request.security(haTicker, signalTF, low)
haClose = request.security(haTicker, signalTF, close)


// ───── Candle Direction ─────
bull = haClose > haOpen
bear = haClose < haOpen


// ───── No Wick Conditions ─────
noBottomWick = haLow == haOpen
noTopWick    = haHigh == haOpen


// ───── Detect Color Change ─────
newBullSequence = bull and bear[1]
newBearSequence = bear and bull[1]


// ───── Memory ─────
var bool waitingBullNoWick = false
var bool waitingBearNoWick = false


if newBullSequence
    waitingBullNoWick := true
    waitingBearNoWick := false

if newBearSequence
    waitingBearNoWick := true
    waitingBullNoWick := false


// ───── Signals ─────
longSignal  = waitingBullNoWick and bull and noBottomWick
shortSignal = waitingBearNoWick and bear and noTopWick


// ───── Stop After First Signal ─────
if longSignal
    waitingBullNoWick := false

if shortSignal
    waitingBearNoWick := false


// ───── Plot Signals ─────
plotshape(longSignal,
     style=shape.labelup,
     text="LONG",
     color=color.green,
     textcolor=color.white,
     location=location.belowbar,
     size=size.small)

plotshape(shortSignal,
     style=shape.labeldown,
     text="SHORT",
     color=color.red,
     textcolor=color.white,
     location=location.abovebar,
     size=size.small)


// ───── Alerts ─────
alertcondition(longSignal,
     title="HA Long No Wick MTF",
     message="Heikin Ashi bullish no bottom wick signal")

alertcondition(shortSignal,
     title="HA Short No Wick MTF",
     message="Heikin Ashi bearish no top wick signal")
````
