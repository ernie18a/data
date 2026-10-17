# Reversal Candle Patterns by SKVARMA

- url: https://www.tradingview.com/script/jNowjcJw-Reversal-Candle-Patterns-by-SKVARMA/
- type: indicator
- pine_id: PUB;54f09a58c1af4e499c81e5b1ef8507eb
- version: 1.0

## Description

Bearish: Bearish Engulfing, Shooting Star, Evening Star, Hanging Man
Bullish: Bullish Engulfing, Inverted Hammer, Morning Star, Hammer

## Source Code

````pine
//@version=6
indicator("Reversal Candle Patterns", overlay=true, max_labels_count=500)

// ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê
// Flags classic bullish and bearish reversal candlestick patterns.
//   Bullish reversal -> GREEN label below the candle
//   Bearish reversal -> RED label above the candle
// Patterns checked (loose/standard definitions, same as used in prior scripts):
//   Bearish: Bearish Engulfing, Shooting Star, Evening Star, Hanging Man
//   Bullish: Bullish Engulfing, Inverted Hammer, Morning Star, Hammer
// ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grp_disp = "Display"
showLabels   = input.bool(true, "Show pattern labels", group=grp_disp)
labelSize    = input.string("tiny", "Label size", options=["tiny","small","normal"], group=grp_disp)

lblSz = labelSize == "tiny" ? size.tiny : labelSize == "small" ? size.small : size.normal

// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ Candle geometry ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
bodyHi  = math.max(close, open)
bodyLo  = math.min(close, open)
bodySz  = math.abs(close - open)
rangeSz = high - low
upWick  = high - bodyHi
loWick  = bodyLo - low
isBullCandle = close > open
isBearCandle = close < open

// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ Bearish reversal patterns ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
isBearishEngulfing = close[1] > open[1] and close < open and
     open >= close[1] and close <= open[1] and bodySz > math.abs(close[1] - open[1])

isShootingStar = rangeSz > 0 and upWick >= bodySz * 2 and loWick <= bodySz * 0.5 and
     isBearCandle and bodyHi >= (high - rangeSz * 0.3)

isEveningStar = close[2] > open[2] and bodySz[1] < (math.abs(close[2]-open[2]) * 0.5) and
     isBearCandle and close < (open[2] + close[2]) / 2

isHangingMan = rangeSz > 0 and loWick >= bodySz * 2 and upWick <= bodySz * 0.5 and
     bodySz / rangeSz < 0.35 and isBearCandle

bearishReversal = isBearishEngulfing or isShootingStar or isEveningStar or isHangingMan
bearishPatternName = isBearishEngulfing ? "Bearish Engulfing" : isShootingStar ? "Shooting Star" :
     isEveningStar ? "Evening Star" : isHangingMan ? "Hanging Man" : "-"

// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ Bullish reversal patterns ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
isBullishEngulfing = close[1] < open[1] and close > open and
     open <= close[1] and close >= open[1] and bodySz > math.abs(close[1] - open[1])

isInvertedHammer = rangeSz > 0 and upWick >= bodySz * 2 and loWick <= bodySz * 0.5 and
     isBullCandle and bodyLo <= (low + rangeSz * 0.3)

isMorningStar = close[2] < open[2] and bodySz[1] < (math.abs(close[2]-open[2]) * 0.5) and
     isBullCandle and close > (open[2] + close[2]) / 2

isHammer = rangeSz > 0 and loWick >= bodySz * 2 and upWick <= bodySz * 0.5 and
     bodySz / rangeSz < 0.35 and isBullCandle

bullishReversal = isBullishEngulfing or isInvertedHammer or isMorningStar or isHammer
bullishPatternName = isBullishEngulfing ? "Bullish Engulfing" : isInvertedHammer ? "Inverted Hammer" :
     isMorningStar ? "Morning Star" : isHammer ? "Hammer" : "-"

// ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ Plot ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
if showLabels and bearishReversal
    label.new(bar_index, high, "‚ñº", style=label.style_label_down, color=color.new(color.red, 10),
         textcolor=color.white, size=lblSz, tooltip=bearishPatternName)

if showLabels and bullishReversal
    label.new(bar_index, low, "‚ñ≤", style=label.style_label_up, color=color.new(color.green, 10),
         textcolor=color.white, size=lblSz, tooltip=bullishPatternName)

// Background tint as a secondary visual cue, in addition to labels
bgcolor(bearishReversal ? color.new(color.red, 88) : bullishReversal ? color.new(color.green, 88) : na,
     title="Reversal Pattern Background")

// Alerts so you can get notified without watching the chart
alertcondition(bearishReversal, title="Bearish Reversal", message="Bearish reversal pattern detected")
alertcondition(bullishReversal, title="Bullish Reversal", message="Bullish reversal pattern detected")
````
