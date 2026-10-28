# PumpC Options Flow: Calls vs Puts (+VWAPs)

- url: https://www.tradingview.com/script/931R4iec-PumpC-Options-Flow-Calls-vs-Puts-VWAPs/
- type: indicator
- pine_id: PUB;b688687fef35418691d0f6dbe8d0ef84
- version: 1.0

## Description

[b]PumpC Options Flow: Calls vs Puts VWAP[/b]
This indicator compares the price action of a selected [b]Call option[/b] and [b]Put option[/b], helping visualize relative strength and potential shifts in market sentiment using VWAP and crossover logic.

[b]🔍 Overview[/b]
[list]
[*]Plots Call and Put option prices in a separate pane
[*]Calculates anchored VWAP for both selected instruments
[*]Includes optional VWAP standard deviation bands
[*]Detects Call vs Put crossover events
[*]Displays a real-time table with price and VWAP values
[*]Supports alert messages for crossover signals

[/list]
[b]🧠 Concept[/b]
Rather than focusing only on the underlying asset, this indicator tracks relative performance between Calls and Puts.
[list]
[*]Calls strengthening versus Puts may suggest bullish pressure
[*]Puts strengthening versus Calls may suggest bearish pressure
[*]VWAP provides an average price reference over the selected anchor period

[/list]
[b]⚙️ How It Works[/b]
[b]Call vs Put Comparison[/b]
[list]
[*]Select one Call contract and one Put contract manually
[*]View both instruments together for direct comparison
[*]Use relative movement to evaluate which side is gaining strength
[/list]

[b]Anchored VWAP[/b]
[list]
[*]VWAP is calculated independently for each selected option contract
[*]The calculation uses HLC3 as the source
[*]Available anchor periods include Session, Week, Month, Quarter, and Year

[/list]
[b]VWAP Bands[/b]
[list]
[*]Optional standard deviation bands can be displayed around VWAP
[*]Bands may help identify extended price movement or volatility expansion

[/list]
[b]Cross Detection[/b]
[list]
[*]Call crossing above Put may indicate improving Call-side relative strength
[*]Put crossing above Call may indicate improving Put-side relative strength

[/list]
[b]Data Table[/b]
[list]
[*]Shows the selected option symbol
[*]Shows the current price
[*]Shows the current VWAP value

[/list]
[b]🚨 Alerts[/b]
[list]
[*]Create an alert using “Any alert() function call”
[*]Alerts trigger when a Call vs Put crossover occurs
[*]Alert messages include crossover direction, symbols, and current values

[/list]
[b]🎯 Usage Ideas[/b]
[list]
[*]Use Call and Put VWAP positioning as trend context
[*]Monitor crossover events for potential momentum shifts
[*]Use VWAP bands to observe possible overextension

[/list]
[b]⚠️ Notes[/b]
[list]
[*]This script uses individual option symbols, not aggregated options flow data
[*]Selected contracts should ideally have similar expiration dates
[*]Near-the-money contracts are generally easier to compare
[*]Illiquid contracts may create irregular or noisy plots

[/list]
[b]🧩 Use Cases[/b]
[list]
[*]Intraday index and ETF options analysis
[*]SPY, QQQ, or index-related options monitoring
[*]VWAP-based relative strength analysis
[*]Confirmation alongside other trading systems

[/list]
[b]💡 Tips[/b]
[list]
[*]Use the Session anchor for intraday analysis
[*]Watch for divergence between Call and Put movement
[*]Focus on relative performance rather than absolute option price

[/list]
[b]🚀 Summary[/b]
PumpC Options Flow: Calls vs Puts VWAP provides a structured way to compare selected Call and Put contracts using VWAP, bands, crossovers, and table-based values. It is designed to help visualize relative strength shifts within the options market.

## Source Code

````pine
//@version=5
indicator("PumpC Options Flow: Calls vs Puts (+VWAPs)", overlay=false, max_labels_count=500)

//────────────────────────────────────────────
// Tooltips
//────────────────────────────────────────────
ttCallSym = "Select the OPRA call option contract to plot.\n\nExample format:\nSPY260618C712.0\n\nThis should be the exact call contract you want to compare against the selected put contract."
ttPutSym = "Select the OPRA put option contract to plot.\n\nExample format:\nSPY260618P712.0\n\nThis should be the exact put contract you want to compare against the selected call contract."
ttAnchor = "Controls when VWAP resets.\n\nSession = resets every trading day.\nWeek = resets at the start of each week.\nMonth = resets at the start of each month.\nQuarter = resets every 3 months.\nYear = resets at the start of each year.\n\nFor intraday option flow, Session is usually the cleanest setting."
ttShowCallVWAP = "Displays the anchored VWAP for the selected call contract."
ttShowPutVWAP = "Displays the anchored VWAP for the selected put contract."
ttShowBand1 = "Displays one standard deviation band around each visible VWAP.\n\nBands help show when the option price is stretched above or below its VWAP."
ttBandMult1 = "Controls the width of the VWAP band.\n\n1.0 = one standard deviation.\n2.0 = wider band.\n0.5 = tighter band."
ttCallColor = "Color used for the call option close plot."
ttPutColor = "Color used for the put option close plot."
ttCallVWAPColor = "Color used for the call VWAP line and call VWAP band."
ttPutVWAPColor = "Color used for the put VWAP line and put VWAP band."
ttShowTable = "Shows a compact table with each option contract, its current VWAP, and its current close price."
ttTablePos = "Controls where the option summary table appears on the chart."
ttTableSize = "Controls the table text size."
ttTableText = "Controls the default text color used for table values and headers.\n\nThe option symbols still use their call/put plot colors for quick identification."

//────────────────────────────────────────────
// OPRA Symbols
//────────────────────────────────────────────
groupSymbols = "1. OPRA Symbols"

callSym = input.symbol("SPY260618C712.0", "Call Contract", group=groupSymbols, tooltip=ttCallSym)
putSym = input.symbol("SPY260618P712.0", "Put Contract", group=groupSymbols, tooltip=ttPutSym)
//────────────────────────────────────────────
// VWAP Settings
//────────────────────────────────────────────
groupVWAP = "2. VWAP Settings"

anchor = input.string("Session", "Anchor Period", options=["Session", "Week", "Month", "Quarter", "Year"], group=groupVWAP, tooltip=ttAnchor)
showCallVWAP = input.bool(true, "Show Call VWAP", group=groupVWAP, tooltip=ttShowCallVWAP)
showPutVWAP = input.bool(true, "Show Put VWAP", group=groupVWAP, tooltip=ttShowPutVWAP)
showBand1 = input.bool(false, "Show Band", group=groupVWAP, inline="band1", tooltip=ttShowBand1)
bandMult1 = input.float(1.0, "Band Mult", step=0.5, minval=0, group=groupVWAP, inline="band1", tooltip=ttBandMult1)

//────────────────────────────────────────────
// Visual Settings
//────────────────────────────────────────────
groupVisual = "3. Visual Settings"

callColor = input.color(#147e18, "Call Price Color", group=groupVisual, tooltip=ttCallColor)
putColor = input.color(#800000, "Put Price Color", group=groupVisual, tooltip=ttPutColor)
callVWAPColor = input.color(#2962FF, "Call VWAP Color", group=groupVisual, tooltip=ttCallVWAPColor)
putVWAPColor = input.color(color.orange, "Put VWAP Color", group=groupVisual, tooltip=ttPutVWAPColor)

//────────────────────────────────────────────
// Table Settings
//────────────────────────────────────────────
groupTable = "4. Table Settings"

showTable = input.bool(true, "Show Table", group=groupTable, inline="tbl1", tooltip=ttShowTable)
tablePos = input.string("Bottom Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupTable, inline="tbl1", tooltip=ttTablePos)
tableTextSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=groupTable, inline="tbl2", tooltip=ttTableSize)
tableTextColor = input.color(color.black, "Text Color", group=groupTable, inline="tbl2", tooltip=ttTableText)

//────────────────────────────────────────────
// Anchor Logic
//────────────────────────────────────────────
isNewPeriod = switch anchor
    "Session" => timeframe.change("D")
    "Week" => timeframe.change("W")
    "Month" => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year" => timeframe.change("12M")
    => false

//────────────────────────────────────────────
// Option Data
//────────────────────────────────────────────
callClose = request.security(callSym, timeframe.period, close)
callHLC3 = request.security(callSym, timeframe.period, hlc3)

putClose = request.security(putSym, timeframe.period, close)
putHLC3 = request.security(putSym, timeframe.period, hlc3)

//────────────────────────────────────────────
// VWAP — TradingView Native Method
//────────────────────────────────────────────
[callVWAP, callUpper1, _] = ta.vwap(callHLC3, isNewPeriod, bandMult1)
[putVWAP, putUpper1, _] = ta.vwap(putHLC3, isNewPeriod, bandMult1)

callStdev = callUpper1 - callVWAP
putStdev = putUpper1 - putVWAP

callUpperBand1 = callVWAP + callStdev * bandMult1
callLowerBand1 = callVWAP - callStdev * bandMult1

putUpperBand1 = putVWAP + putStdev * bandMult1
putLowerBand1 = putVWAP - putStdev * bandMult1

//────────────────────────────────────────────
// Plots
//────────────────────────────────────────────
plot(callClose, "Calls", color=callColor, linewidth=1)
plot(putClose, "Puts", color=putColor, linewidth=1)

plot(showCallVWAP ? callVWAP : na, "Call VWAP", color=callVWAPColor, linewidth=1)
plot(showPutVWAP ? putVWAP : na, "Put VWAP", color=putVWAPColor, linewidth=1)

callUpperPlot = plot(showBand1 and showCallVWAP ? callUpperBand1 : na, "Call Upper Band #1", color=color.new(callVWAPColor, 40))
callLowerPlot = plot(showBand1 and showCallVWAP ? callLowerBand1 : na, "Call Lower Band #1", color=color.new(callVWAPColor, 40))
fill(callUpperPlot, callLowerPlot, color=color.new(callVWAPColor, 92), title="Call Band Fill")

putUpperPlot = plot(showBand1 and showPutVWAP ? putUpperBand1 : na, "Put Upper Band #1", color=color.new(putVWAPColor, 40))
putLowerPlot = plot(showBand1 and showPutVWAP ? putLowerBand1 : na, "Put Lower Band #1", color=color.new(putVWAPColor, 40))
fill(putUpperPlot, putLowerPlot, color=color.new(putVWAPColor, 92), title="Put Band Fill")

//────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────
callCrossUpPut = ta.crossover(callClose, putClose)
putCrossUpCall = ta.crossover(putClose, callClose)

masterCrossAlert = callCrossUpPut or putCrossUpCall

alertcondition(masterCrossAlert, "Call/Put Cross", "Call and Put option prices crossed. Use Any alert() function call for detailed direction and prices.")

if masterCrossAlert
    alert(callCrossUpPut ? "CALLS CROSSED ABOVE PUTS | " + str.tostring(callSym) + " > " + str.tostring(putSym) + " | Call: " + str.tostring(callClose, format.mintick) + " | Put: " + str.tostring(putClose, format.mintick) : "PUTS CROSSED ABOVE CALLS | " + str.tostring(putSym) + " > " + str.tostring(callSym) + " | Put: " + str.tostring(putClose, format.mintick) + " | Call: " + str.tostring(callClose, format.mintick), alert.freq_once_per_bar_close)
    
//────────────────────────────────────────────
// Table Helpers
//────────────────────────────────────────────
pos = switch tablePos
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left

txtSize = switch tableTextSize
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large

formatTicker(sym) =>
    str.replace(sym, "OPRA:", "")

//────────────────────────────────────────────
// Table
//────────────────────────────────────────────
var table optTable = table.new(pos, 3, 3)

if showTable and barstate.islast
    table.clear(optTable, 0, 0, 2, 2)

    table.cell(optTable, 0, 0, "Option", text_color=tableTextColor, text_size=txtSize)
    table.cell(optTable, 1, 0, "VWAP", text_color=tableTextColor, text_size=txtSize)
    table.cell(optTable, 2, 0, "Close", text_color=tableTextColor, text_size=txtSize)

    table.cell(optTable, 0, 1, formatTicker(callSym), text_color=callColor, text_size=txtSize)
    table.cell(optTable, 1, 1, str.tostring(callVWAP, format.mintick), text_color=tableTextColor, text_size=txtSize)
    table.cell(optTable, 2, 1, str.tostring(callClose, format.mintick), text_color=tableTextColor, text_size=txtSize)

    table.cell(optTable, 0, 2, formatTicker(putSym), text_color=putColor, text_size=txtSize)
    table.cell(optTable, 1, 2, str.tostring(putVWAP, format.mintick), text_color=tableTextColor, text_size=txtSize)
    table.cell(optTable, 2, 2, str.tostring(putClose, format.mintick), text_color=tableTextColor, text_size=txtSize)
````
