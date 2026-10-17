# MSL Trend Follow

- url: https://www.tradingview.com/script/nKDLOq2T-msl-trend-follow/
- type: indicator
- pine_id: PUB;522d63c0aed54feab6dc77f31de343ad
- version: 1.0

## Description

MSL Trend Follow is a market-structure trend-following indicator designed to help traders identify when price may be shifting from one directional phase to another, and then follow that phase using an ATR-based trailing stop.

The indicator combines two core ideas:

1. Market structure break logic
2. Adaptive ATR trailing stop management

Instead of plotting a large number of separate signals, MSL Trend Follow focuses on a cleaner workflow: detect a structural trend change, display the direction, and then provide a dynamic trailing stop line that follows the active trend.

How it works

The script identifies confirmed swing highs and swing lows using a pivot-based structure model. When price closes above the most recent confirmed swing high, the indicator marks a potential bullish trend shift. When price closes below the most recent confirmed swing low, it marks a potential bearish trend shift.

After a trend signal appears, the indicator plots an ATR-based trailing stop:

- In an uptrend, the green trailing stop line is plotted below price.
- In a downtrend, the red trailing stop line is plotted above price.

The trailing stop uses a ratchet mechanism. During an uptrend, the stop can only move upward. During a downtrend, the stop can only move downward. This helps the line follow the active trend without constantly moving back and forth with every minor price fluctuation.

What makes it useful

MSL Trend Follow is not designed to predict every candle or call every market turn. Its purpose is to give traders a structured way to read trend direction and manage the active phase after a structural breakout.

The indicator may help traders answer three practical questions:

- Has price shifted above or below an important structural level?
- Is the current trend phase still active?
- How far is price from the current trailing stop?

The chart output is intentionally simple:

- Green Trend signal: bullish structure shift
- Red Trend signal: bearish structure shift
- Green line: bullish trailing stop
- Red line: bearish trailing stop
- Dashboard: current trend state, signal age, and distance to stop

Dashboard

The dashboard gives a compact view of the current state:

Trend
Shows the current directional state:
UP, DOWN, or NEUTRAL.

Signal Age
Shows how many bars have passed since the most recent trend signal. A small number means the signal is relatively fresh. A larger number means the trend phase has already been active for a longer period.

To Stop
Shows the current distance between price and the trailing stop as a percentage. This helps traders understand how much room price has before reaching the active stop line.

How to use it

A bullish scenario appears when the indicator prints a green Trend signal and starts plotting a green trailing stop below price. This means price has broken above the latest confirmed structural high and the indicator has shifted into an upward trend state.

A bearish scenario appears when the indicator prints a red Trend signal and starts plotting a red trailing stop above price. This means price has broken below the latest confirmed structural low and the indicator has shifted into a downward trend state.

The trailing stop can be used as a visual reference for trend continuation or trend invalidation. As long as price respects the active trailing stop, the current trend phase remains structurally intact according to the indicator logic. If price moves through the trailing stop area, the current trend phase may be weakening or ending.

Suggested interpretation

Stronger bullish context:
- Trend state is UP
- Price remains above the green trailing stop
- The green stop line continues to move upward
- The signal is not extremely old
- The broader market context supports upward continuation

Stronger bearish context:
- Trend state is DOWN
- Price remains below the red trailing stop
- The red stop line continues to move downward
- The signal is not extremely old
- The broader market context supports downward continuation

Weaker or more cautious context:
- Price is very close to the trailing stop
- The signal is very old
- Market is moving sideways
- Price repeatedly crosses back and forth around structural levels
- Higher-timeframe direction conflicts with the current signal

Settings

Pivot Length
Controls how major or minor the detected structure points are. Lower values make the indicator more reactive, but may create more noise. Higher values focus on larger structural swings and may produce fewer signals.

Min Bars Between Signals
Adds a minimum bar distance between trend signals. This can help reduce rapid flip-flopping in choppy markets.

ATR Length
Controls the ATR calculation used for the trailing stop.

ATR Multiplier
Controls how far the trailing stop sits from price. A higher multiplier creates a wider stop and fewer stop-outs. A lower multiplier creates a tighter stop and faster reaction.

Signal Offset ATR
Controls how far the signal label is placed from the trailing stop line. This is a visual setting only and does not change the signal logic.

Best use cases

MSL Trend Follow is best suited for traders who want a clean trend-following tool based on market structure and dynamic stop tracking. It can be used on different markets, including stocks, crypto, forex, indices, and commodities, but the settings should be adjusted to the asset and timeframe.

Suggested timeframes:
- H1 for more active trading
- H4 for intraday and short swing context
- D1 for broader swing trend structure

The indicator is not intended to be used as a standalone trading system. It should be combined with broader market context, support and resistance, volatility conditions, risk management, and the trader’s own trading plan.

Important notes

This indicator does not guarantee future performance.
It does not predict the market.
It does not replace risk management.
It is designed for market analysis and educational use.

All signals should be interpreted in context. A trend signal shows that a structural condition has been met according to the indicator logic, not that a trade must be opened automatically.

Markets can remain volatile, choppy, or unpredictable, and any technical tool can produce false signals.[url=https://www.tradingview.com/x/PnLuSmOL/]https://www.tradingview.com/x/PnLuSmOL/[/url][image]https://www.tradingview.com/x/PnLuSmOL/[/image]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// MSL_Trend_Follow — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.

//@version=6
indicator("MSL Trend Follow", "MSL Trend", overlay = true, max_lines_count = 200, max_labels_count = 200)

//==== INPUTS ===========================================================
groupStruct = "Structure"
groupStop   = "ATR Trailing Stop"
groupVis    = "Visuals"
groupTbl    = "Dashboard"

// Group: Structure
msLen = input.int(10, "Pivot Length", minval = 2, maxval = 100, group = groupStruct,
     tooltip = "Lookback and lookahead window for pivot detection. Smaller values find more pivots and react faster but produce more noise. Larger values find only major structural turns.")

minBarsBetween = input.int(0, "Min Bars Between Signals", minval = 0, maxval = 500, group = groupStruct,
     tooltip = "Minimum number of bars required between consecutive Trend signals. Helps filter out rapid flip-flopping in choppy markets. Set to 0 to disable.")

// Group: ATR Trailing Stop
showStop = input.bool(true, "Show Trailing Stop", group = groupStop,
     tooltip = "Display the ATR-based trailing stop line. In bull phase it sits BELOW price as a protective floor that ratchets up; in bear phase it sits ABOVE price as a protective ceiling that ratchets down. A break through the line signals the end of the current trend.")

atrLen = input.int(14, "ATR Length", minval = 1, maxval = 200, group = groupStop, active = showStop,
     tooltip = "Period for ATR calculation. Standard is 14. Lower values make the stop more reactive; higher values give a smoother stop.")

atrMult = input.float(4.0, "ATR Multiplier", minval = 0.5, maxval = 20.0, step = 0.5, group = groupStop, active = showStop,
     tooltip = "How far the trailing stop sits from price, measured in ATR units. Higher means wider stop and fewer stop-outs. Lower means tighter stop and more frequent stop-outs.")

// Group: Visuals
bullColor = input.color(color.rgb(0, 200, 83), "Bull / Bear Color", group = groupVis, inline = "colors",
     tooltip = "Color used for bullish trend: the Trend ↑ marker, the trailing stop line, and the background tint.")

bearColor = input.color(color.rgb(239, 83, 80), "", group = groupVis, inline = "colors",
     tooltip = "Color used for bearish trend: the Trend ↓ marker, the trailing stop line, and the background tint.")

showTrendLabels = input.bool(true, "Trend Labels", group = groupVis,
     tooltip = "Show the Trend ↑ / Trend ↓ markers near the beginning of the trailing stop line.")

signalOffsetAtr = input.float(0.35, "Signal Offset ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = groupVis,
     tooltip = "Distance between the signal label and the trailing stop line, measured in ATR. Bull labels are placed below the green line; bear labels are placed above the red line.")

// Group: Dashboard
showTable = input.bool(true, "Show Dashboard", group = groupTbl,
     tooltip = "Display a compact status table on the chart with current trend, signal age, and distance to trailing stop.")

tablePosInput = input.string("top_right", "Position",
     options = ["top_right", "top_left", "middle_right", "bottom_right"],
     group = groupTbl, active = showTable,
     display = display.none,
     tooltip = "Where on the chart to anchor the dashboard. Change requires a chart refresh to take effect.")

//==== HELPERS ==========================================================
safeDiv(float num, float den, float fallback) =>
    (na(num) or na(den) or den == 0.0) ? fallback : (num / den)

clampInt(int x, int lo, int hi) =>
    x < lo ? lo : x > hi ? hi : x

f_tablePos(string s) =>
    switch s
        "top_right"    => position.top_right
        "top_left"     => position.top_left
        "middle_right" => position.middle_right
        "bottom_right" => position.bottom_right
        =>                position.top_right

//==== CALCULATIONS =====================================================
// Pivot detection: centered window of msLen bars on each side
ph = ta.pivothigh(msLen, msLen)
pl = ta.pivotlow(msLen, msLen)

// Volatility for stop and signal spacing
volatility = ta.atr(atrLen)

// State variables
var int   trendState       = 0
var float lastPivotHigh    = na
var float lastPivotLow     = na
var int   lastPivotHighBar = 0
var int   lastPivotLowBar  = 0
var int   lastSignalBar    = na
var float trailStop        = na
var float entryLevel       = na

// Capture pivot values into state when confirmed
if not na(ph)
    lastPivotHigh    := high[msLen]
    lastPivotHighBar := bar_index[msLen]

if not na(pl)
    lastPivotLow    := low[msLen]
    lastPivotLowBar := bar_index[msLen]

//==== SIGNAL ENGINE ====================================================
barsSinceLastSig = na(lastSignalBar) ? 999999 : bar_index - lastSignalBar
filterPass       = minBarsBetween == 0 or barsSinceLastSig >= minBarsBetween

bullCross = ta.crossover(close, lastPivotHigh) and trendState != 1 and filterPass
bearCross = ta.crossunder(close, lastPivotLow) and trendState != -1 and filterPass

if bullCross
    trendState    := 1
    entryLevel    := lastPivotHigh
    trailStop     := close - volatility * atrMult
    lastSignalBar := bar_index

    if showTrendLabels
        label.new(
             bar_index,
             trailStop - volatility * signalOffsetAtr,
             "Trend ↑",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(bullColor, 100),
             textcolor = bullColor,
             size = size.small)

if bearCross
    trendState    := -1
    entryLevel    := lastPivotLow
    trailStop     := close + volatility * atrMult
    lastSignalBar := bar_index

    if showTrendLabels
        label.new(
             bar_index,
             trailStop + volatility * signalOffsetAtr,
             "Trend ↓",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(bearColor, 100),
             textcolor = bearColor,
             size = size.small)

// Ratchet update
if trendState == 1 and not bullCross
    newStop   = close - volatility * atrMult
    trailStop := na(trailStop) ? newStop : math.max(trailStop, newStop)

if trendState == -1 and not bearCross
    newStop   = close + volatility * atrMult
    trailStop := na(trailStop) ? newStop : math.min(trailStop, newStop)

//==== VISUAL STATE =====================================================
// The trailing stop line now starts from the signal bar.
bullActive = showStop and trendState == 1
bearActive = showStop and trendState == -1

//==== PLOTS ============================================================
plot(bullActive ? trailStop : na, "Bull Trailing Stop",
     color = bullColor, style = plot.style_linebr, linewidth = 2)

plot(bearActive ? trailStop : na, "Bear Trailing Stop",
     color = bearColor, style = plot.style_linebr, linewidth = 2)

bgcolor(bullActive ? color.new(bullColor, 92) : na, title = "Bull Background")
bgcolor(bearActive ? color.new(bearColor, 92) : na, title = "Bear Background")

//==== ALERTS ===========================================================
alertcondition(bullCross, title = "Bull Trend",
     message = "MSL Trend Follow: Bull trend started on {{ticker}} {{interval}}")

alertcondition(bearCross, title = "Bear Trend",
     message = "MSL Trend Follow: Bear trend started on {{ticker}} {{interval}}")

//==== TABLE ============================================================
var table dash = table.new(f_tablePos(tablePosInput), 2, 4,
     border_width = 1, force_overlay = true)

if barstate.islast
    if showTable
        trendText = trendState == 1 ? "UP" : trendState == -1 ? "DOWN" : "NEUTRAL"
        trendBg   = trendState == 1 ? color.new(bullColor, 40) : trendState == -1 ? color.new(bearColor, 40) : color.new(color.gray, 60)

        sigBarTxt = na(lastSignalBar) ? "—" : str.tostring(bar_index - lastSignalBar)

        toStopPct = trendState == 0 or na(trailStop) or close == 0.0 ? "—" :
             str.format("{0,number,#.##}%", math.abs(close - trailStop) / close * 100)

        headerBg = color.new(color.black, 20)
        cellBg   = color.new(color.black, 60)
        textCol  = color.white
        labelCol = color.new(color.white, 35)

        // Row 0 — header
        table.cell(dash, 0, 0, "MSL TREND FOLLOW", text_color = textCol, bgcolor = headerBg, text_size = size.small)
        table.cell(dash, 1, 0, "",                 text_color = textCol, bgcolor = headerBg, text_size = size.small)

        // Row 1 — trend direction
        table.cell(dash, 0, 1, "Trend",   text_color = labelCol, bgcolor = cellBg, text_size = size.small)
        table.cell(dash, 1, 1, trendText, text_color = textCol,  bgcolor = trendBg, text_size = size.small)

        // Row 2 — signal age
        table.cell(dash, 0, 2, "Signal Age", text_color = labelCol, bgcolor = cellBg, text_size = size.small)
        table.cell(dash, 1, 2, sigBarTxt,     text_color = textCol,  bgcolor = cellBg, text_size = size.small)

        // Row 3 — distance to stop in %
        table.cell(dash, 0, 3, "To Stop",  text_color = labelCol, bgcolor = cellBg, text_size = size.small)
        table.cell(dash, 1, 3, toStopPct,  text_color = textCol,  bgcolor = cellBg, text_size = size.small)

//==== USAGE GUIDE ======================================================
//
// MSL_Trend_Follow — what it does:
//   Detects market structure shifts and rides the new trend with an
//   ATR-based trailing stop that only moves in the direction of the trend.
//
// Signal logic:
//   1. The indicator finds swing highs and swing lows using Pivot Length.
//   2. When close crosses above the most recent pivot high, a Bull Trend signal fires.
//   3. When close crosses below the most recent pivot low, a Bear Trend signal fires.
//   4. After a signal, an ATR trailing stop is plotted:
//      - Bull phase: green line below price.
//      - Bear phase: red line above price.
//
// Dashboard:
//   - Trend: current direction. UP, DOWN or NEUTRAL.
//   - Signal Age: how many bars have passed since the last trend signal.
//   - To Stop: current distance from price to trailing stop, shown in %.
//
// Alerts:
//   - Bull Trend — fires once on each Bull signal.
//   - Bear Trend — fires once on each Bear signal.
//
// Suggested timeframes:
//   - Scalping:  msLen 5–8   on H1
//   - Intraday:  msLen 8–12  on H1–H4
//   - Swing:     msLen 15–20 on H4–D1
//
// Tips:
//   - Wider ATR Multiplier gives fewer stop-outs but a wider stop.
//   - Tighter ATR Multiplier gives more frequent stop-outs but a tighter stop.
//   - Min Bars Between Signals can help reduce noise in choppy markets.
````
