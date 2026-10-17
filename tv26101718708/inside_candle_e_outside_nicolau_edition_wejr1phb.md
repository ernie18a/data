# Inside Candle e Outside Nicolau Edition

- url: https://www.tradingview.com/script/WEjr1phb/
- type: indicator
- pine_id: PUB;378782bfb5274696a40935717870d4d7
- version: 1.0

## Description

This indicator automatically identifies and highlights two of the most 
reliable candlestick patterns in technical analysis:

🔹 Inside Candle — A candle fully contained within the previous one, 
signaling market compression and potential breakout setup.

🔸 Bullish Engulfing — A bullish candle that completely engulfs the 
body of the prior bearish candle, indicating potential reversal to 
the upside.

🔸 Bearish Engulfing — A bearish candle that completely engulfs the 
body of the prior bullish candle, indicating potential reversal to 
the downside.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ FEATURES
━━━━━━━━━━━━━━━━━━━━━━
✅ Candle coloring directly on the chart (barcolor)
✅ Optional arrows for quick visual identification
✅ Minimum body size filter for engulfing patterns
✅ Fully customizable colors
✅ Built-in alerts for all patterns
✅ Engulfing takes priority over Inside Candle when both occur

━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━
This tool is for educational and analytical purposes only. 
It does not constitute financial advice. Always use proper 
risk management and combine with other analysis methods.

## Source Code

````pine
//@version=6
indicator(title="Inside Candle & Outside — Nicolau Edition", shorttitle="Inside&Outside", overlay=true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
showInside      = input.bool(true,     "Show Inside Candle?",      group="Inside Candle")
insideColor     = input.color(#FFD700, "Inside Candle Color",      group="Inside Candle")
insideArrow     = input.bool(true,     "Show Arrow?",              group="Inside Candle")

showOutside     = input.bool(true,     "Show Outside?",            group="Outside")
bullEngulfColor = input.color(#2962FF, "Bullish Outside Color",    group="Outside")
bearEngulfColor = input.color(#E91E63, "Bearish Outside Color",    group="Outside")
engulfArrow     = input.bool(true,     "Show Arrow?",              group="Outside")
engulfMinSize   = input.float(0.0,     "Min Body Size Filter (%)", group="Outside", minval=0.0, maxval=100.0, step=0.5, tooltip="Filtra onde o candle atual engole pelo menos X% do corpo anterior. 0 = sem filtro.")

// ─────────────────────────────────────────
// CÁLCULOS
// ─────────────────────────────────────────
bullCandle  = close > open
bearCandle  = close < open
bodyHigh    = math.max(open, close)
bodyLow     = math.min(open, close)
bodyHigh_1  = math.max(open[1], close[1])
bodyLow_1   = math.min(open[1], close[1])
bodySize    = math.abs(close - open)
bodySize_1  = math.abs(close[1] - open[1])

// ─────────────────────────────────────────
// INSIDE CANDLE
// ─────────────────────────────────────────
isInside = high < high[1] and low > low[1]

// ─────────────────────────────────────────
// OUTSIDE CANDLE
// ─────────────────────────────────────────
engulfFilter = engulfMinSize > 0 ? bodySize >= bodySize_1 * (engulfMinSize / 100) : true

isBullEngulf = bullCandle and bearCandle[1] and
               bodyLow  < bodyLow_1  and
               bodyHigh > bodyHigh_1 and
               engulfFilter

isBearEngulf = bearCandle and bullCandle[1] and
               bodyHigh > bodyHigh_1 and
               bodyLow  < bodyLow_1  and
               engulfFilter

// ─────────────────────────────────────────
// PRIORIDADE: Outside prevalece sobre Inside
// ─────────────────────────────────────────
isInsideOnly    = isInside and not isBullEngulf and not isBearEngulf
isBullOutside   = isBullEngulf
isBearOutside   = isBearEngulf

// ─────────────────────────────────────────
// COLORAÇÃO DOS CANDLES
// ─────────────────────────────────────────
candleColor =
     showOutside and isBullOutside ? bullEngulfColor :
     showOutside and isBearOutside ? bearEngulfColor :
     showInside  and isInsideOnly  ? insideColor     :
     na

wickColor =
     showOutside and isBullOutside ? color.new(bullEngulfColor, 30) :
     showOutside and isBearOutside ? color.new(bearEngulfColor, 30) :
     showInside  and isInsideOnly  ? color.new(insideColor, 30)     :
     na

borderColor =
     showOutside and isBullOutside ? color.new(bullEngulfColor, 0) :
     showOutside and isBearOutside ? color.new(bearEngulfColor, 0) :
     showInside  and isInsideOnly  ? color.new(insideColor, 0)     :
     na

plotcandle(open, high, low, close,
     color       = candleColor,
     wickcolor   = wickColor,
     bordercolor = borderColor)

// ─────────────────────────────────────────
// MARCADORES
// ─────────────────────────────────────────
plotshape(showInside and insideArrow and isInsideOnly,
     title    = "Inside Candle",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = color.new(insideColor, 40),
     size     = size.tiny)

plotshape(showOutside and engulfArrow and isBullOutside,
     title    = "Bullish Outside",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.new(bullEngulfColor, 20),
     size     = size.tiny)

plotshape(showOutside and engulfArrow and isBearOutside,
     title    = "Bearish Outside",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = color.new(bearEngulfColor, 20),
     size     = size.tiny)

// ─────────────────────────────────────────
// BARCOLOR
// ─────────────────────────────────────────
barcolor(
     showOutside and isBullOutside ? bullEngulfColor :
     showOutside and isBearOutside ? bearEngulfColor :
     showInside  and isInsideOnly  ? insideColor     :
     na)

// ─────────────────────────────────────────
// ALERTAS
// ─────────────────────────────────────────
alertcondition(isInsideOnly,  title="Inside Candle",   message="Inside Candle detected")
alertcondition(isBullOutside, title="Bullish Outside",  message="Bullish Outside detected")
alertcondition(isBearOutside, title="Bearish Outside",  message="Bearish Outside detected")
alertcondition(isBullOutside or isBearOutside, title="Any Outside", message="Outside Candle detected")
````
