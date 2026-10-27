# Stock Comparison - Line Chart

- url: https://www.tradingview.com/script/IBTthBuF-Stock-Comparison-Line-Chart/
- type: indicator
- pine_id: PUB;5457ce42f04d415781c30a4d3174bfde
- version: 2.0

## Description

Compare the differnce between the 2 different stocks. Catch their behavior and make the trade.

## Source Code

````pine
//@version=6
indicator("Stock Comparison - Spread", shorttitle="StockCompare-Spread", overlay=false)

// ============================================================
// INPUTS
// ============================================================
symbol1     = input.symbol("AAPL", title="Stock 1 Symbol")
symbol2     = input.symbol("MSFT", title="Stock 2 Symbol")

compareMode = input.string("Price Spread (Value)", title="Comparison Mode",
                 options=["Percentage Change", "Raw Price", "Price Spread (Value)"])

spreadColor = input.color(color.new(#26A69A, 0), title="Spread Color")

color1      = input.color(color.new(#2962FF, 0), title="Stock 1 Color")
color2      = input.color(color.new(#FF6D00, 0), title="Stock 2 Color")

lineWidth   = input.int(2, title="Line Width", minval=1, maxval=4)
showTable   = input.bool(true, title="Show Legend Table")

// --- Highest / Lowest spread tracking ---
lookbackBars   = input.int(50, title="Spread High/Low Lookback (bars)", minval=1)
showHiLoLines  = input.bool(true, title="Plot Highest/Lowest Spread Lines")
hiSpreadColor  = input.color(color.new(color.lime, 0), title="Highest Spread Color")
loSpreadColor  = input.color(color.new(color.red, 0), title="Lowest Spread Color")

// --- VWAP spread ---
showVwapSpread   = input.bool(true, title="Show VWAP Spread")
vwapSpreadColor  = input.color(color.new(color.yellow, 0), title="VWAP Spread Color")
showVwapHiLo     = input.bool(true, title="Plot Highest/Lowest VWAP Spread Lines")
hiVwapColor      = input.color(color.new(color.aqua, 0), title="Highest VWAP Spread Color")
loVwapColor      = input.color(color.new(color.fuchsia, 0), title="Lowest VWAP Spread Color")

// --- Fixed price feed (keeps spread independent of chart timeframe) ---
useFixedFeed = input.bool(true, title="Lock Price Feed to Fixed Low Timeframe (Intraday Only)",
                 tooltip="When ON, on intraday charts prices are always pulled from the timeframe set below, regardless of the chart's resolution, so the spread reflects the latest real price instead of changing when you switch chart timeframe. Daily/Weekly/Monthly charts always use the chart's own timeframe, since locking those to 1-minute data would run out of available intraday history.")
feedTF       = input.timeframe("1", title="Price Feed Timeframe (used when locked)")

// --- Z-Score (statistical extremity of current spread vs. its own recent history) ---
zScoreThreshold = input.float(2.0, title="Z-Score Highlight Threshold", minval=0.5, step=0.5,
                     tooltip="Table cells turn red/green when the spread's z-score (over the lookback above) exceeds +/- this value, flagging a statistically extreme reading.")

// --- Decimal precision (independent of the chart's own symbol tick size) ---
decimalPlaces = input.string("2", title="Decimal Places for Price/Spread Display",
                     options=["0", "1", "2", "3", "4", "5"],
                     tooltip="format.mintick (used previously) rounds to the CHART's own tick size, not the symbols being compared - this can wrongly round off decimals. This setting forces a fixed decimal precision instead, independent of the chart symbol.")
priceFormat = switch decimalPlaces
    "0" => "#"
    "1" => "#.#"
    "2" => "#.##"
    "3" => "#.###"
    "4" => "#.####"
    "5" => "#.#####"
    => "#.##"

// --- NEW: Alerts ---
enableHighLowAlerts = input.bool(true, title="Enable New High/Low Spread Alerts", group="Alerts")
showHighLowMarkers   = input.bool(true, title="Show Triangle Markers on New High/Low", group="Alerts")

// ============================================================
// DATA
// ============================================================
// Timeframe actually used to pull symbol data.
// - On intraday charts (1m/5m/1H/4H etc.), lock to the fixed low timeframe
//   (feedTF) so the spread doesn't change just because you switch resolution.
// - On Daily/Weekly/Monthly charts, use the chart's own timeframe instead.
//   Forcing 1-minute data there would require many months/years of intraday
//   history that most feeds don't retain, causing distorted VWAP/price spikes
//   on bars where that history runs out.
dataTF = (useFixedFeed and timeframe.isintraday) ? feedTF : timeframe.period

price1 = request.security(symbol1, dataTF, close, lookahead=barmerge.lookahead_off)
price2 = request.security(symbol2, dataTF, close, lookahead=barmerge.lookahead_off)

// VWAP for each symbol (resets each session by default; requires volume data -
// returns na for symbols without volume, e.g. most forex pairs)
vwap1 = request.security(symbol1, dataTF, ta.vwap(close), lookahead=barmerge.lookahead_off)
vwap2 = request.security(symbol2, dataTF, ta.vwap(close), lookahead=barmerge.lookahead_off)
vwapSpread = vwap1 - vwap2

// Capture the first available price on the chart as the base for % comparison
var float base1 = na
var float base2 = na

if barstate.isfirst
    base1 := price1
    base2 := price2

pct1 = (price1 - base1) / base1 * 100
pct2 = (price2 - base2) / base2 * 100

// Exact value spread between the two stocks
spread = price1 - price2

isSpreadMode = compareMode == "Price Spread (Value)"

// Choose which series to plot based on selected mode
plotValue1 = compareMode == "Percentage Change" ? pct1 : price1
plotValue2 = compareMode == "Percentage Change" ? pct2 : price2

// --- Highest / Lowest spread over the lookback window ---
highestSpread = ta.highest(spread, lookbackBars)
lowestSpread  = ta.lowest(spread, lookbackBars)
spreadRange   = highestSpread - lowestSpread   // difference between the two extremes

// --- Highest / Lowest VWAP spread over the same lookback window ---
highestVwapSpread = ta.highest(vwapSpread, lookbackBars)
lowestVwapSpread  = ta.lowest(vwapSpread, lookbackBars)

// --- Z-Score - how many standard deviations the current spread is from
// its own rolling mean over the same lookback window. |z| >= ~2 is statistically
// uncommon (roughly the top/bottom ~5% of outcomes for a normal distribution)
// and is the more reliable "extreme" signal vs. a raw 50-bar high/low, since a
// single outlier bar can't distort it the way a raw high/low can.
spreadMean   = ta.sma(spread, lookbackBars)
spreadStdev  = ta.stdev(spread, lookbackBars)
spreadZScore = spreadStdev != 0 ? (spread - spreadMean) / spreadStdev : 0.0

vwapSpreadMean   = ta.sma(vwapSpread, lookbackBars)
vwapSpreadStdev  = ta.stdev(vwapSpread, lookbackBars)
vwapSpreadZScore = vwapSpreadStdev != 0 ? (vwapSpread - vwapSpreadMean) / vwapSpreadStdev : 0.0

// ============================================================
// NEW: NEW-HIGH / NEW-LOW DETECTION (for alerts + markers)
// ============================================================
// highestSpread[1] / lowestSpread[1] = the extreme over the PRIOR lookback
// window (not including the current bar). Comparing the current spread
// against that prior extreme means this only fires on the bar that actually
// sets a fresh record - it won't keep re-firing every bar while price sits
// flat at the existing high/low.
newHighSpread = not na(highestSpread[1]) and spread > highestSpread[1]
newLowSpread  = not na(lowestSpread[1]) and spread < lowestSpread[1]

// ============================================================
// PLOTS
// ============================================================
plot(isSpreadMode ? na : plotValue1, title="Stock 1", color=color1, linewidth=lineWidth)
plot(isSpreadMode ? na : plotValue2, title="Stock 2", color=color2, linewidth=lineWidth)
plot(isSpreadMode ? spread : na, title="Spread (Stock1 - Stock2)", color=spreadColor, linewidth=lineWidth, style=plot.style_line)

plot((isSpreadMode and showHiLoLines) ? highestSpread : na, title="Highest Spread (Lookback)", color=hiSpreadColor, style=plot.style_line, linewidth=1)
plot((isSpreadMode and showHiLoLines) ? lowestSpread : na, title="Lowest Spread (Lookback)", color=loSpreadColor, style=plot.style_line, linewidth=1)
plot((isSpreadMode and showVwapSpread) ? vwapSpread : na, title="VWAP Spread", color=vwapSpreadColor, linewidth=lineWidth, style=plot.style_line)
plot((isSpreadMode and showVwapSpread and showVwapHiLo) ? highestVwapSpread : na, title="Highest VWAP Spread (Lookback)", color=hiVwapColor, style=plot.style_line, linewidth=1)
plot((isSpreadMode and showVwapSpread and showVwapHiLo) ? lowestVwapSpread : na, title="Lowest VWAP Spread (Lookback)", color=loVwapColor, style=plot.style_line, linewidth=1)

plotshape((isSpreadMode and showHighLowMarkers and newHighSpread) ? spread : na, title="New High Marker",
     style=shape.triangleup, location=location.absolute, color=hiSpreadColor, size=size.tiny)
plotshape((isSpreadMode and showHighLowMarkers and newLowSpread) ? spread : na, title="New Low Marker",
     style=shape.triangledown, location=location.absolute, color=loSpreadColor, size=size.tiny)

hline((compareMode == "Percentage Change" or isSpreadMode) ? 0 : na, title="Zero Line",
     color=color.gray, linestyle=hline.style_dotted)

// ============================================================
// NEW: ALERT CONDITIONS
// ============================================================
// These show up in TradingView's "Create Alert" dialog under the Condition
// dropdown once this indicator is on your chart - no extra setup needed
// beyond selecting them there and choosing "Once Per Bar Close" (recommended,
// so it doesn't fire mid-bar on a value that might still change).
alertcondition(enableHighLowAlerts and isSpreadMode and newHighSpread,
     title="Spread - New Highest (Lookback)",
     message="{{ticker}} spread on {{interval}} made a new lookback-period HIGH: {{plot(\"Spread\")}}")

alertcondition(enableHighLowAlerts and isSpreadMode and newLowSpread,
     title="Spread - New Lowest (Lookback)",
     message="{{ticker}} spread on {{interval}} made a new lookback-period LOW: {{plot(\"Spread\")}}")

// ============================================================
// LEGEND TABLE
// ============================================================
if showTable
    var table legend = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 70), border_width=1)
    if barstate.islast
        table.cell(legend, 0, 0, "Symbol", text_color=color.white, bgcolor=color.new(color.black, 50))
        table.cell(legend, 1, 0, "Value", text_color=color.white, bgcolor=color.new(color.black, 50))

        table.cell(legend, 0, 1, str.tostring(symbol1), text_color=color1)
        table.cell(legend, 1, 1, str.tostring(price1, priceFormat), text_color=color1)

        table.cell(legend, 0, 2, str.tostring(symbol2), text_color=color2)
        table.cell(legend, 1, 2, str.tostring(price2, priceFormat), text_color=color2)

        table.cell(legend, 0, 3, "Spread", text_color=spreadColor)
        table.cell(legend, 1, 3, str.tostring(spread, priceFormat), text_color=spreadColor)

        table.cell(legend, 0, 4, "Highest Spread (" + str.tostring(lookbackBars) + ")", text_color=hiSpreadColor)
        table.cell(legend, 1, 4, str.tostring(highestSpread, priceFormat), text_color=hiSpreadColor)

        table.cell(legend, 0, 5, "Lowest Spread (" + str.tostring(lookbackBars) + ")", text_color=loSpreadColor)
        table.cell(legend, 1, 5, str.tostring(lowestSpread, priceFormat), text_color=loSpreadColor)

        table.cell(legend, 0, 6, "VWAP Spread", text_color=vwapSpreadColor)
        table.cell(legend, 1, 6, str.tostring(vwapSpread, priceFormat), text_color=vwapSpreadColor)

        table.cell(legend, 0, 7, "Highest VWAP Spread (" + str.tostring(lookbackBars) + ")", text_color=hiVwapColor)
        table.cell(legend, 1, 7, str.tostring(highestVwapSpread, priceFormat), text_color=hiVwapColor)

        table.cell(legend, 0, 8, "Lowest VWAP Spread (" + str.tostring(lookbackBars) + ")", text_color=loVwapColor)
        table.cell(legend, 1, 8, str.tostring(lowestVwapSpread, priceFormat), text_color=loVwapColor)

        spreadZExtreme = math.abs(spreadZScore) >= zScoreThreshold
        table.cell(legend, 0, 9, "Spread Z-Score (" + str.tostring(lookbackBars) + ")", text_color=color.white)
        table.cell(legend, 1, 9, str.tostring(spreadZScore, "#.##"), text_color=color.white,
             bgcolor=spreadZExtreme ? (spreadZScore > 0 ? color.new(color.green, 40) : color.new(color.red, 40)) : na)

        vwapZExtreme = math.abs(vwapSpreadZScore) >= zScoreThreshold
        table.cell(legend, 0, 10, "VWAP Spread Z-Score (" + str.tostring(lookbackBars) + ")", text_color=color.white)
        table.cell(legend, 1, 10, str.tostring(vwapSpreadZScore, "#.##"), text_color=color.white,
             bgcolor=vwapZExtreme ? (vwapSpreadZScore > 0 ? color.new(color.green, 40) : color.new(color.red, 40)) : na)
````
