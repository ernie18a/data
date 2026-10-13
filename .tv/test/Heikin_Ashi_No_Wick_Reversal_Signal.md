<!-- tradingview-pine-id: PUB;e5ffdac83cb044159e82c84271abdc5e -->
<!-- tradingviewscripts-format: 1 -->
# Heikin Ashi No Wick Reversal Signal

Source: https://www.tradingview.com/script/TYFu4gzk-Heikin-Ashi-No-Wick-Reversal-Signal/

## Description

**Heikin Ashi No Wick Reversal Signal**

This indicator identifies potential reversal signals using Heikin Ashi candle patterns.

The script detects the first Heikin Ashi candle with a strong directional body and no wick against the trend direction:

• **Bullish Signal (LONG):** Appears when a bullish Heikin Ashi candle forms with no lower wick, showing strong buying pressure.

• **Bearish Signal (SHORT):** Appears when a bearish Heikin Ashi candle forms with no upper wick, showing strong selling pressure.

The indicator is designed to highlight momentum shifts and potential continuation points after a change in candle direction. It works on any timeframe and includes built-in alert conditions for automated notifications.

**Features:**
✓ Uses Heikin Ashi candle calculations
✓ Detects no-wick bullish and bearish candles
✓ Provides clear LONG and SHORT signals
✓ Includes TradingView alert support
✓ Suitable for scalping, intraday, and trend-following strategies

This indicator is a visual signal tool and should be combined with proper risk management and additional market analysis.

---

## Source Code

````pine
//@version=6
indicator("Heikin Ashi No Wick Reversal Signal", overlay=true)

haTicker = ticker.heikinashi(syminfo.tickerid)

haOpen  = request.security(haTicker, timeframe.period, open)
haHigh  = request.security(haTicker, timeframe.period, high)
haLow   = request.security(haTicker, timeframe.period, low)
haClose = request.security(haTicker, timeframe.period, close)

bull = haClose > haOpen
bear = haClose < haOpen

noBottomWick = haLow == haOpen
noTopWick    = haHigh == haOpen

// Detect new color sequence
newBullSequence = bull and bear[1]
newBearSequence = bear and bull[1]

// Remember if we are inside a bullish/bearish run
var bool waitingBullNoWick = false
var bool waitingBearNoWick = false

if newBullSequence
    waitingBullNoWick := true
    waitingBearNoWick := false

if newBearSequence
    waitingBearNoWick := true
    waitingBullNoWick := false


// Signal when first no wick appears in the new sequence
longSignal = waitingBullNoWick and bull and noBottomWick
shortSignal = waitingBearNoWick and bear and noTopWick


// Stop looking after signal
if longSignal
    waitingBullNoWick := false

if shortSignal
    waitingBearNoWick := false


plotshape(longSignal,
     style=shape.labelup,
     text="LONG",
     color=color.green,
     textcolor=color.white,
     location=location.belowbar)

plotshape(shortSignal,
     style=shape.labeldown,
     text="SHORT",
     color=color.red,
     textcolor=color.white,
     location=location.abovebar)

alertcondition(longSignal,
     title="HA Long No Wick",
     message="Heikin Ashi bullish no bottom wick signal")

alertcondition(shortSignal,
     title="HA Short No Wick",
     message="Heikin Ashi bearish no top wick signal")
````
