# ES Breakout Toolkit ADX Regime Filter Free

- url: https://www.tradingview.com/script/1O196EXo-ES-Breakout-Toolkit-ADX-Regime-Filter-Free/
- type: indicator
- pine_id: PUB;c4534ea180844323bb28a8a66ab60b9d
- version: 1.0

## Description

=== PART OF THE ES BREAKOUT TOOLKIT ===
This is one of several free, standalone indicators that make up the ES Breakout Toolkit series. Each indicator isolates a single component used in the full ES London Breakout Pro strategy. They are designed to be useful on their own and educational for traders looking to filter trades by market regime using ADX.

=== WHAT THIS INDICATOR DOES ===
The ADX Regime Filter classifies the current market environment into three states: Flat/Choppy, Trending, and Overextended. It does this using the Average Directional Index (ADX) with configurable minimum and maximum thresholds that define a "sweet spot" where the market is trending enough to produce clean breakouts but not so extended that it is likely to reverse or stall.

The indicator plots ADX alongside DI+ and DI- lines, highlights the sweet spot zone between your min and max ADX values, and provides visual markers when ADX enters or exits each regime. DI crossovers are also marked to help identify directional shifts.

=== HOW TO USE IT ===
Apply this indicator to a separate pane below your chart. The shaded zone between the min and max ADX lines represents the regime where trend-following and breakout strategies tend to perform best. When ADX is below the minimum, the market is likely choppy and breakout signals are less reliable. When ADX is above the maximum, the trend may be overextended and new entries carry higher reversal risk.

The dashboard shows the current ADX value, regime classification, DI direction, DI spread, ADX slope, and an overall trade readiness assessment. The DI spread reading helps confirm whether the directional move has conviction — a narrow spread suggests indecision even if ADX is technically in range.

=== KEY FEATURES ===
- Three-state regime classification (Flat, Trending, Overextended)
- Configurable ADX sweet spot zone with visual fill
- DI+/DI- directional lines with crossover markers
- ADX slope tracking (rising vs falling momentum)
- Optional bar coloring by regime and direction
- Background shading by current state
- Dashboard with ADX, regime, direction, DI spread, slope, and trade readiness
- Alerts for regime transitions and DI crossovers

=== WHY ADX BOUNDARIES MATTER ===
Most traders using ADX only set a minimum threshold. However, extremely high ADX readings often indicate that a trend is mature and vulnerable to exhaustion. By defining both a floor and a ceiling, you can focus on the portion of the trend cycle where momentum is building rather than peaking. This indicator makes that concept visual and actionable.

=== ABOUT THE ES BREAKOUT TOOLKIT ===
This indicator is part of a free series that breaks down the building blocks of a London session ES futures breakout strategy. Other free indicators in the series cover session highlighting, consolidation range detection, breakout candle scanning, and momentum close analysis. Each is published separately on my profile.

The full ES London Breakout Pro indicator combines all of these components into a unified strategy with additional proprietary features including advanced risk management, trade qualification, and data tracking. It is available as an invite-only script on my profile. Use the access request instructions on that script's page if you are interested.

=== DISCLAIMER ===
This indicator is provided for educational and informational purposes only. It is NOT financial advice. It does not constitute a recommendation to buy, sell, or hold any financial instrument. Trading futures involves substantial risk of loss and is not suitable for all investors. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial advisor before making any trading decisions. You are solely responsible for your own trading activity.

## Source Code

````pine
//@version=6
indicator("[ES Breakout Toolkit] ADX Regime Filter — Free", overlay=false)

// ==================== INPUTS ====================
adxLength = input.int(12, "ADX Length", minval=5, maxval=50)
diLength = input.int(12, "DI Length", minval=5, maxval=50)
minADX = input.float(18, "Min ADX (Trending)", minval=5, step=1)
maxADX = input.float(35, "Max ADX (Overextended)", minval=20, step=1)
showDILines = input.bool(true, "Show DI+/DI- Lines")
showZones = input.bool(true, "Show ADX Zones")
showBarColor = input.bool(false, "Color Bars by Regime")

// ==================== INDICATORS ====================
[diPlus, diMinus, adx] = ta.dmi(diLength, adxLength)

// ==================== REGIME CLASSIFICATION ====================
isTrending = adx >= minADX and adx <= maxADX
isOverextended = adx > maxADX
isFlat = adx < minADX
diDirectionLong = diPlus > diMinus
diDirectionShort = diMinus > diPlus
diSpread = math.abs(diPlus - diMinus)

// ==================== ADX SLOPE ====================
adxRising = adx > adx[1]
adxSlope = adx - adx[3]

// ==================== REGIME COLOR ====================
regimeColor = isTrending ? color.lime : isOverextended ? color.orange : color.gray
adxColor = adxRising ? color.new(regimeColor, 0) : color.new(regimeColor, 40)

// ==================== PLOTTING ====================
minLine = plot(showZones ? minADX : na, "Min ADX", color=color.new(color.gray, 60), style=plot.style_line)
maxLine = plot(showZones ? maxADX : na, "Max ADX", color=color.new(color.orange, 60), style=plot.style_line)
fill(minLine, maxLine, color=color.new(color.teal, 90), title="Sweet Spot Zone")

plot(adx, "ADX", color=adxColor, linewidth=2)
plot(showDILines ? diPlus : na, "DI+", color=color.new(color.lime, 30), linewidth=1)
plot(showDILines ? diMinus : na, "DI-", color=color.new(color.red, 30), linewidth=1)

// ==================== ZONE ENTRY/EXIT MARKERS ====================
enteredSweetSpot = isTrending and not isTrending[1]
exitedSweetSpot = not isTrending and isTrending[1]
enteredOverextended = isOverextended and not isOverextended[1]

plotshape(enteredSweetSpot, title="Entered Trending", style=shape.diamond, location=location.bottom, color=color.lime, size=size.tiny, text="GO")
plotshape(enteredOverextended, title="Overextended", style=shape.diamond, location=location.top, color=color.orange, size=size.tiny, text="HOT")

// ==================== BAR COLORING ====================
barcolor(showBarColor ? (isTrending and diDirectionLong ? color.lime : isTrending and diDirectionShort ? color.red : isOverextended ? color.orange : color.gray) : na)

// ==================== BACKGROUND ====================
bgcolor(isTrending ? color.new(color.lime, 95) : isOverextended ? color.new(color.orange, 95) : na, title="Regime Background")

// ==================== DI CROSSOVER SIGNALS ====================
diCrossUp = ta.crossover(diPlus, diMinus)
diCrossDown = ta.crossunder(diPlus, diMinus)
plotshape(showDILines and diCrossUp, title="DI+ Cross Up", style=shape.triangleup, location=location.bottom, color=color.new(color.lime, 30), size=size.tiny)
plotshape(showDILines and diCrossDown, title="DI- Cross Down", style=shape.triangledown, location=location.top, color=color.new(color.red, 30), size=size.tiny)

// ==================== DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 10), border_width=1)
table.cell(dash, 0, 0, "ADX Regime", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 1, 0, "Filter", text_color=color.white, text_size=size.small, bgcolor=color.new(color.teal, 30))
table.cell(dash, 0, 1, "ADX", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 1, str.tostring(adx, "#.#"), text_color=regimeColor, text_size=size.small)
table.cell(dash, 0, 2, "Regime", text_color=color.gray, text_size=size.small)
regimeTxt = isTrending ? "TRENDING" : isOverextended ? "OVEREXTENDED" : "FLAT / CHOPPY"
table.cell(dash, 1, 2, regimeTxt, text_color=regimeColor, text_size=size.small)
table.cell(dash, 0, 3, "Direction", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 3, diDirectionLong ? "BULLISH (DI+)" : "BEARISH (DI-)", text_color=diDirectionLong ? color.lime : color.red, text_size=size.small)
table.cell(dash, 0, 4, "DI Spread", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 4, str.tostring(diSpread, "#.#"), text_color=diSpread > 10 ? color.lime : color.yellow, text_size=size.small)
table.cell(dash, 0, 5, "ADX Slope", text_color=color.gray, text_size=size.small)
table.cell(dash, 1, 5, (adxSlope >= 0 ? "+" : "") + str.tostring(adxSlope, "#.#"), text_color=adxRising ? color.lime : color.red, text_size=size.small)
table.cell(dash, 0, 6, "Trade OK", text_color=color.gray, text_size=size.small)
tradeOK = isTrending and diSpread > 3
table.cell(dash, 1, 6, tradeOK ? "YES" : "NO", text_color=tradeOK ? color.lime : color.red, text_size=size.small)

// ==================== ALERTS ====================
alertcondition(enteredSweetSpot, "ADX Entered Sweet Spot", "ADX entered trending zone")
alertcondition(enteredOverextended, "ADX Overextended", "ADX entered overextended zone")
alertcondition(diCrossUp, "DI+ Crossover", "DI+ crossed above DI-")
alertcondition(diCrossDown, "DI- Crossover", "DI- crossed above DI+")
````
