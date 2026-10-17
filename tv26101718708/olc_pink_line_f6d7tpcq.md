# OLC Pink Line 

- url: https://www.tradingview.com/script/f6D7TPCQ-OLC-Pink-Line/
- type: indicator
- pine_id: PUB;30c71e5fdb514427841beecd8a94ce8f
- version: 1.0

## Description

OLC Pink   -  a shooting star and a engulfing candle  , shooting star with a sweep

## Source Code

````pine
//@version=6
indicator("OLC Pink", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
lookback      = input.int(20,   title="Lookback (X candles)", minval=2, maxval=200, group="Settings")
shootingColor = input.color(color.new(#FF1493, 0), title="Shooting Star Color", group="Colors")
engulfColor   = input.color(color.new(#00CED1, 0), title="Engulfing Candle Color", group="Colors")
showLabels    = input.bool(true, title="Show Labels", group="Settings")

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
candleBody  = math.abs(close - open)
candleRange = high - low
upperWick   = high - math.max(close, open)
lowerWick   = math.min(close, open) - low

// ─────────────────────────────────────────────
//  BEARISH SHOOTING STAR  (top of uptrend)
//  - Long upper wick >= 2x body
//  - Small lower wick <= 20% of range
//  - High sweeps the highest high of previous X candles
// ─────────────────────────────────────────────
recentHigh = ta.highest(high[1], lookback)

isBearishStar = upperWick >= 2.0 * candleBody and lowerWick <= 0.20 * candleRange and candleBody > 0 and high >= recentHigh

// ─────────────────────────────────────────────
//  BULLISH HAMMER STAR  (bottom of downtrend)
//  - Long lower wick >= 2x body
//  - Small upper wick <= 20% of range
//  - Low sweeps the lowest low of previous X candles
// ─────────────────────────────────────────────
recentLow = ta.lowest(low[1], lookback)

isBullishStar = lowerWick >= 2.0 * candleBody and upperWick <= 0.20 * candleRange and candleBody > 0 and low <= recentLow

isAnyStar = isBearishStar or isBullishStar

// ─────────────────────────────────────────────
//  BEARISH ENGULFING  (follows Bearish Shooting Star)
//  - Previous candle was a Bearish Star
//  - Current candle is bearish (close < open)
//  - Body engulfs previous candle's body
// ─────────────────────────────────────────────
prevWasBearishStar = isBearishStar[1]

isBearishEngulf = prevWasBearishStar and close < open and open >= close[1] and close <= open[1]

// ─────────────────────────────────────────────
//  BULLISH ENGULFING  (follows Bullish Hammer Star)
//  - Previous candle was a Bullish Hammer Star
//  - Current candle is bullish (close > open)
//  - Body engulfs previous candle's body
// ─────────────────────────────────────────────
prevWasBullishStar = isBullishStar[1]

isBullishEngulf = prevWasBullishStar and close > open and open <= close[1] and close >= open[1]

isAnyEngulf = isBearishEngulf or isBullishEngulf

// ─────────────────────────────────────────────
//  BAR COLOURING
// ─────────────────────────────────────────────
barColor = isAnyStar ? shootingColor : isAnyEngulf ? engulfColor : na
barcolor(barColor)

// ─────────────────────────────────────────────
//  BACKGROUND GLOW
// ─────────────────────────────────────────────
bgcolor(isAnyStar   ? color.new(shootingColor, 88) : na, title="Star BG")
bgcolor(isAnyEngulf ? color.new(engulfColor,   88) : na, title="Engulfing BG")

// ─────────────────────────────────────────────
//  SHAPES
// ─────────────────────────────────────────────
plotshape(isBearishStar,   style=shape.arrowdown, location=location.abovebar, color=shootingColor, size=size.small, title="Bearish Star Marker")
plotshape(isBullishStar,   style=shape.arrowup,   location=location.belowbar, color=shootingColor, size=size.small, title="Bullish Star Marker")
plotshape(isBearishEngulf, style=shape.arrowdown, location=location.abovebar, color=engulfColor,   size=size.small, title="Bearish Engulf Marker")
plotshape(isBullishEngulf, style=shape.arrowup,   location=location.belowbar, color=engulfColor,   size=size.small, title="Bullish Engulf Marker")

// ─────────────────────────────────────────────
//  LABELS
// ─────────────────────────────────────────────
if showLabels and isBearishStar
    label.new(bar_index, high, text="★ Bearish Star", color=shootingColor, textcolor=color.white, style=label.style_label_down, size=size.small)

if showLabels and isBullishStar
    label.new(bar_index, low, text="★ Bullish Star", color=shootingColor, textcolor=color.white, style=label.style_label_up, size=size.small)

if showLabels and isBearishEngulf
    label.new(bar_index, high, text="⬇ Bearish Engulf", color=engulfColor, textcolor=color.white, style=label.style_label_down, size=size.small)

if showLabels and isBullishEngulf
    label.new(bar_index, low, text="⬆ Bullish Engulf", color=engulfColor, textcolor=color.white, style=label.style_label_up, size=size.small)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(isBearishStar,   title="OLC Pink – Bearish Shooting Star", message="OLC Pink: Bearish Shooting Star — sweeps recent high")
alertcondition(isBullishStar,   title="OLC Pink – Bullish Hammer Star",   message="OLC Pink: Bullish Hammer Star — sweeps recent low")
alertcondition(isBearishEngulf, title="OLC Pink – Bearish Engulfing",     message="OLC Pink: Bearish Engulfing after Shooting Star")
alertcondition(isBullishEngulf, title="OLC Pink – Bullish Engulfing",     message="OLC Pink: Bullish Engulfing after Hammer Star")
alertcondition(isAnyStar,       title="OLC Pink – Any Star",              message="OLC Pink: Star candle detected")
alertcondition(isAnyEngulf,     title="OLC Pink – Any Engulfing",         message="OLC Pink: Engulfing candle detected")
````
