# Liquidity Pressure Structure

- url: https://www.tradingview.com/script/HkqQDjBg-Liquidity-Pressure-Structure/
- type: indicator
- pine_id: PUB;41f656a0997b42d1869c89cbe2f9f8a6
- version: 1.0

## Description

Liquidity Pressure Structure transforms liquidity and price behavior into a visual framework for understanding how price interacts with potential liquidity zones.

The indicator identifies recent swing-based liquidity areas and monitors how price behaves when approaching, sweeping, rejecting, or breaking those zones. Directional pressure and volume expansion are then used to highlight potential BUY or SELL conditions.

Key visual elements include:

Liquidity Zones — highlights areas around recent swing highs and lows where liquidity may be concentrated.
Liquidity Sweeps — identifies when price moves beyond a liquidity level and closes back through it, highlighting a potential sweep.
Directional Pressure — visualizes whether bullish or bearish pressure is becoming dominant around liquidity.
Volume Expansion — helps identify stronger participation when price interacts with important liquidity areas.
BUY / SELL Signals — highlights potential directional conditions when liquidity interaction and pressure align.
Pressure Visualization — uses the chart itself to make shifts between bullish and bearish pressure easier to recognize.

The framework is designed to answer a simple question:

What happens when price reaches liquidity?

Price may sweep a liquidity area and reject it, or break through it with stronger pressure and participation. By combining these behaviors into one visual structure, the indicator helps traders study liquidity interaction rather than relying on isolated price levels.

Use the signals as a contextual tool alongside price action, market structure, and other technical analysis. Liquidity levels are derived from historical price structure and do not represent confirmed institutional orders or guaranteed future price behavior.

## Source Code

````pine
//@version=6
indicator("Liquidity Pressure Structure", shorttitle="LPS", overlay=true, max_boxes_count=100, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupLiquidity = "Liquidity"
swingLength = input.int(10, "Swing Length", minval=3, group=groupLiquidity)
zoneATR = input.float(0.25, "Liquidity Zone Width", minval=0.05, step=0.05, group=groupLiquidity)
zoneLookback = input.int(100, "Zone Lookback", minval=20, group=groupLiquidity)

groupPressure = "Pressure"
volumeLength = input.int(20, "Volume Average Length", minval=5, group=groupPressure)
volumeThreshold = input.float(1.3, "Volume Expansion", minval=1.0, step=0.1, group=groupPressure)
pressureLength = input.int(5, "Pressure Smoothing", minval=1, group=groupPressure)

groupVisual = "Visual"
showLiquidityZones = input.bool(true, "Show Liquidity Zones", group=groupVisual)
showPressure = input.bool(true, "Show Pressure", group=groupVisual)
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupVisual)
showSweeps = input.bool(true, "Show Liquidity Sweeps", group=groupVisual)

//──────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
//──────────────────────────────────────────────────────────────────────────────
atr = ta.atr(14)

volumeAverage = ta.sma(volume, volumeLength)
relativeVolume = volumeAverage > 0 ? volume / volumeAverage : 0.0
volumeExpansion = relativeVolume >= volumeThreshold

candleRange = math.max(high - low, syminfo.mintick)
closePosition = ((close - low) / candleRange) * 2.0 - 1.0
bodyDirection = close > open ? 1.0 : close < open ? -1.0 : 0.0

rawPressure = (closePosition + bodyDirection) / 2.0
pressure = ta.ema(rawPressure, pressureLength)

//──────────────────────────────────────────────────────────────────────────────
// SWING LIQUIDITY
//──────────────────────────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, swingLength, swingLength)
pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float buySideLiquidity = na
var float sellSideLiquidity = na

if not na(pivotHigh)
    buySideLiquidity := pivotHigh

if not na(pivotLow)
    sellSideLiquidity := pivotLow

//──────────────────────────────────────────────────────────────────────────────
// LIQUIDITY ZONES
//──────────────────────────────────────────────────────────────────────────────
buyZoneTop = buySideLiquidity + atr * zoneATR
buyZoneBottom = buySideLiquidity - atr * zoneATR

sellZoneTop = sellSideLiquidity + atr * zoneATR
sellZoneBottom = sellSideLiquidity - atr * zoneATR

nearBuyLiquidity =
     not na(buySideLiquidity) and
     high >= buyZoneBottom and
     low <= buyZoneTop

nearSellLiquidity =
     not na(sellSideLiquidity) and
     high >= sellZoneBottom and
     low <= sellZoneTop

//──────────────────────────────────────────────────────────────────────────────
// LIQUIDITY SWEEPS
//──────────────────────────────────────────────────────────────────────────────
// High liquidity sweep:
// price trades above the previous swing high but closes back below it.
buySideSweep =
     not na(buySideLiquidity) and
     high > buySideLiquidity and
     close < buySideLiquidity

// Low liquidity sweep:
// price trades below the previous swing low but closes back above it.
sellSideSweep =
     not na(sellSideLiquidity) and
     low < sellSideLiquidity and
     close > sellSideLiquidity

//──────────────────────────────────────────────────────────────────────────────
// PRESSURE AFTER LIQUIDITY INTERACTION
//──────────────────────────────────────────────────────────────────────────────
bullishRejection =
     sellSideSweep and
     pressure > 0 and
     close > open

bearishRejection =
     buySideSweep and
     pressure < 0 and
     close < open

bullishBreak =
     not na(buySideLiquidity) and
     close > buySideLiquidity and
     pressure > 0 and
     volumeExpansion

bearishBreak =
     not na(sellSideLiquidity) and
     close < sellSideLiquidity and
     pressure < 0 and
     volumeExpansion

//──────────────────────────────────────────────────────────────────────────────
// SIGNAL LOGIC
//──────────────────────────────────────────────────────────────────────────────
buySetup =
     bullishRejection or bullishBreak

sellSetup =
     bearishRejection or bearishBreak

buySignal = buySetup and not buySetup[1]
sellSignal = sellSetup and not sellSetup[1]

//──────────────────────────────────────────────────────────────────────────────
// LIQUIDITY ZONE VISUALIZATION
//──────────────────────────────────────────────────────────────────────────────
buyZoneColor = color.new(color.red, 88)
sellZoneColor = color.new(color.green, 88)

pBuyTop = plot(
     showLiquidityZones and not na(buySideLiquidity) ? buyZoneTop : na,
     title="Buy-Side Liquidity Top",
     color=color.new(color.red, 65),
     linewidth=1
)

pBuyBottom = plot(
     showLiquidityZones and not na(buySideLiquidity) ? buyZoneBottom : na,
     title="Buy-Side Liquidity Bottom",
     color=color.new(color.red, 65),
     linewidth=1
)

fill(pBuyTop, pBuyBottom, color=buyZoneColor)

pSellTop = plot(
     showLiquidityZones and not na(sellSideLiquidity) ? sellZoneTop : na,
     title="Sell-Side Liquidity Top",
     color=color.new(color.green, 65),
     linewidth=1
)

pSellBottom = plot(
     showLiquidityZones and not na(sellSideLiquidity) ? sellZoneBottom : na,
     title="Sell-Side Liquidity Bottom",
     color=color.new(color.green, 65),
     linewidth=1
)

fill(pSellTop, pSellBottom, color=sellZoneColor)

// Liquidity reference lines
plot(
     showLiquidityZones ? buySideLiquidity : na,
     title="Buy-Side Liquidity",
     color=color.new(color.red, 20),
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showLiquidityZones ? sellSideLiquidity : na,
     title="Sell-Side Liquidity",
     color=color.new(color.green, 20),
     linewidth=2,
     style=plot.style_linebr
)

//──────────────────────────────────────────────────────────────────────────────
// PRESSURE VISUALIZATION
//──────────────────────────────────────────────────────────────────────────────
pressureColor =
     pressure > 0.65 ? color.new(color.lime, 0) :
     pressure > 0.20 ? color.new(color.green, 15) :
     pressure < -0.65 ? color.new(color.red, 0) :
     pressure < -0.20 ? color.new(color.red, 15) :
     color.new(color.gray, 45)

barcolor(showPressure ? pressureColor : na)

//──────────────────────────────────────────────────────────────────────────────
// SWEEP MARKERS
//──────────────────────────────────────────────────────────────────────────────
plotshape(
     showSweeps and sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     style=shape.circle,
     location=location.belowbar,
     color=color.yellow,
     size=size.tiny,
     text="SWEEP"
)

plotshape(
     showSweeps and buySideSweep,
     title="Buy-Side Liquidity Sweep",
     style=shape.circle,
     location=location.abovebar,
     color=color.yellow,
     size=size.tiny,
     text="SWEEP"
)

//──────────────────────────────────────────────────────────────────────────────
// BUY / SELL SIGNALS
//──────────────────────────────────────────────────────────────────────────────
plotshape(
     showSignals and buySignal,
     title="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignals and sellSignal,
     title="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small
)

//──────────────────────────────────────────────────────────────────────────────
// PRESSURE BACKGROUND
//──────────────────────────────────────────────────────────────────────────────
bgcolor(
     showPressure ?
         pressure > 0.65 ? color.new(color.green, 94) :
         pressure < -0.65 ? color.new(color.red, 94) :
         na
     : na
)

//──────────────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────────────
alertcondition(
     buySignal,
     title="Liquidity Pressure BUY",
     message="Vertex Liquidity Pressure Structure: potential BUY condition detected."
)

alertcondition(
     sellSignal,
     title="Liquidity Pressure SELL",
     message="Vertex Liquidity Pressure Structure: potential SELL condition detected."
)

alertcondition(
     sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     message="Vertex Liquidity Pressure Structure: sell-side liquidity sweep detected."
)

alertcondition(
     buySideSweep,
     title="Buy-Side Liquidity Sweep",
     message="Vertex Liquidity Pressure Structure: buy-side liquidity sweep detected."
)
````
