# winning 100%

- url: https://www.tradingview.com/script/y6qT3nXI-winning-100/
- type: indicator
- pine_id: PUB;29b0ba102c964e1cb03fa76d27dd03e0
- version: 1.0

## Description

follow strict rules ,this is for educational purpose only

## Source Code

````pine
//@version=6
indicator("winning 100%", overlay=true)

// ==========================
// INPUTS
// ==========================
emaFastLength = input.int(9, title="Fast EMA")
emaSlowLength = input.int(24, title="Slow EMA")
volumeLength  = input.int(20, title="Volume SMA Length")
showCloud     = input.bool(true, title="Show EMA Cloud")

// ==========================
// EMA CALCULATIONS
// ==========================
ema9  = ta.ema(close, emaFastLength)
ema24 = ta.ema(close, emaSlowLength)

// EMA Cloud
cloudTop = math.max(ema9, ema24)
cloudBottom = math.min(ema9, ema24)

// ==========================
// TREND FILTER
// ==========================
upTrend = ema9 > ema24
priceAboveEMAs = close > ema9 and close > ema24

// ==========================
// PRICE ACTION CONDITIONS
// ==========================

// 1. Candle closes above EMA cloud
closeAboveCloud = close > cloudTop

// 2. Bullish candle
bullishCandle = close > open

// 3. Break previous candle high
breakPreviousHigh = high > high[1]

// 4. Pullback to cloud support
pullbackToCloud =
     low <= cloudTop and
     low >= cloudBottom * 0.995

// 5. Wick rejection (strong lower wick)
candleBody = math.abs(close - open)
lowerWick = math.min(open, close) - low

wickRejection =
     lowerWick > candleBody * 0.7

// 6. Volume confirmation
volumeSMA = ta.sma(volume, volumeLength)
volumeConfirmation = volume > volumeSMA

// ==========================
// STRICT BUY CONDITION
// ==========================
buySignal =
     barstate.isconfirmed and
     upTrend and
     priceAboveEMAs and
     closeAboveCloud and
     bullishCandle and
     breakPreviousHigh and
     pullbackToCloud and
     wickRejection and
     volumeConfirmation

// ==========================
// PLOT BUY LABEL
// ==========================
plotshape(
     buySignal,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.small)

// ==========================
// EMA PLOTS
// ==========================
plotEMA9 = plot(ema9, color=color.green, linewidth=2, title="EMA 9")
plotEMA24 = plot(ema24, color=color.orange, linewidth=2, title="EMA 24")

fill(
     plotEMA9,
     plotEMA24,
     color=showCloud ?
     (ema9 > ema24 ? color.new(color.green, 85)
                   : color.new(color.red, 85))
     : na)

// ==========================
// ALERT CONDITION
// ==========================
alertcondition(
     buySignal,
     title="BUY Alert",
     message="Strict EMA Cloud BUY Signal Triggered")
````
