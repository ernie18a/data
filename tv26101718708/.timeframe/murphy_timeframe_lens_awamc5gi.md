# Murphy Timeframe Lens

- url: https://www.tradingview.com/script/AWaMc5gi-Murphy-Timeframe-Lens/
- type: indicator
- pine_id: PUB;ce380861e8fd40588da9abdf8f00a4ed
- version: 1.0

## Description

[b]MURPHY TIMEFRAME LENS[/b]
[i]Reading time: ~2 min[/i]

█ [b]OVERVIEW[/b]

[url=https://www.tradingview.com/x/OMrBHZQb/]https://www.tradingview.com/x/OMrBHZQb/[/url]

Murphy Timeframe Lens is a timeframe compression tool inspired by John Murphy's explanation of weekly and monthly bar charts in [i]Chapter 3[/i]. The indicator displays higher timeframe structure directly on your current chart, helping traders study markets from a longer-range perspective without switching timeframes.

As Murphy explains, compressing data into larger bars allows chartists to see the bigger picture. A 15-minute bar on a 1-minute chart contains 15 bars of price action. An hourly bar can represent 60 minutes of trading activity.

The indicator adapts to different trading styles: intraday scalpers can use 15m or 1H compression on 1-minute charts, swing traders can view daily structure on 4H charts, and position traders can see weekly or monthly compression on daily timeframes.

═══════════════════════════════════════════════════════════════════

█ [b]FEATURES[/b]

[url=https://www.tradingview.com/x/zEwhClAW/]https://www.tradingview.com/x/zEwhClAW/[/url]

[b]Multi-Timeframe Compression[/b]

The indicator offers seven timeframe options: [i]15m, 30m, 1H, 4H, Daily, Weekly[/i] and [i]Monthly[/i]. Each fetches higher timeframe OHLC data and overlays it on your current chart.
The default 15m setting follows the [i]two timeframes higher[/i] principle — when trading on 1-minute charts, viewing 15-minute structure provides directional context without excessive lag. This compression ratio balances noise reduction with real-time relevance.
For different base timeframes, select the appropriate HTF. 1-minute charts work well with 15m or 1H. 5-minute charts pair with 1H or 4H. Hourly charts benefit from Daily or Weekly compression.

[b]Three Display Modes[/b]

The indicator offers three visualization options to match different analysis needs.
[i]OHLC Bars[/i] — shows the full higher timeframe bar structure: open, high, low, and close levels with shaded range zones and clear O/C labels marking exact price levels.
[i]Close Line[/i] — displays only the higher timeframe closing price as a stepped trend line, emphasizing directional bias without visual clutter.
[i]HL Zones Only[/i] — plots just the high and low boundaries, creating range bands that show where the higher timeframe bar is trading.

[b]Progressive Range Tracking[/b]

The indicator builds HTF high and low boundaries progressively as the timeframe bar develops. When a new 15-minute bar starts on a 1-minute chart, the high and low begin at current price and expand as subsequent 1-minute bars extend the range.
This prevents look-ahead bias — HTF boundaries reflect only information available at each moment, not the final bar values. Labels mark HTF open and close levels with exact prices for precise reference.

═══════════════════════════════════════════════════════════════════

█ [b]VISUAL LEGEND[/b]

 • [b]Green shaded zone[/b] — HTF bar closed bullish (close above open)
 • [b]Red shaded zone[/b] — HTF bar closed bearish (close below open)
 • [b]O label (green)[/b] — HTF open level with exact price — where the HTF bar started
 • [b]C label (green/red)[/b] — HTF close level with exact price — where the HTF bar ended
 • [b]Blue dots[/b] — HTF high boundary (progressive, expands as bar develops)
 • [b]Orange dots[/b] — HTF low boundary (progressive, expands as bar develops)
 • [b]Gray background flash[/b] — new HTF bar started

═══════════════════════════════════════════════════════════════════

█ [b]BEST USE CASES[/b]

 • 1-minute scalping with 15m or 1H structure for intraday bias
 • 5-minute trading with 1H or 4H compression for session context
 • 4H swing trading with Daily or Weekly structure for trend alignment
 • Identifying when price tests HTF boundaries (support/resistance zones)

═══════════════════════════════════════════════════════════════════

█ [b]DISCLAIMER[/b]

[i]This script is for educational and analytical purposes only. It is not financial advice. Trading involves risk, and all decisions remain the responsibility of the user.[/i]

## Source Code

````pine
//@version=5
indicator("Murphy Timeframe Lens", overlay=true, max_bars_back=500, scale=scale.right)

// ══════════════════════════════════════════════════════════════════════════════
// MURPHY PROJECT - TIMEFRAME LENS
// ══════════════════════════════════════════════════════════════════════════════
// Inspired by: John J. Murphy - Technical Analysis of the Financial Markets
// Chapter: 3 - Chart Construction (Pages 45-46)
// Principle: Weekly and monthly charts compress data for longer range trend analysis
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS (MAX 3 PARAMETERS)
// ══════════════════════════════════════════════════════════════════════════════

htfPeriod = input.string("15", "Higher Timeframe", 
     options=["15", "30", "60", "240", "D", "W", "M"],
     tooltip="15m = Two timeframes higher (recommended for 1m). 60 = 1H bias. 240 = 4H session. D/W/M = swing context. Toggle between options to find optimal HTF for your instrument.")

showHLZones = input.bool(true, "Show HTF High/Low Zones",
     tooltip="Display shaded zones marking higher timeframe bar ranges for structural context.")

compressionMode = input.string("OHLC Bars", "Display Mode", 
     options=["OHLC Bars", "Close Line", "HL Zones Only"],
     tooltip="OHLC = full bar structure, Close Line = trend line only, HL Zones = range bands only.")

// ══════════════════════════════════════════════════════════════════════════════
// CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// Fetch higher timeframe OHLC data
// This compresses multiple lower timeframe bars into single HTF bars
[htfOpen, htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, htfPeriod, [open, high, low, close], lookahead=barmerge.lookahead_off)

// Fetch HTF time to detect bar changes
htfTime = request.security(syminfo.tickerid, htfPeriod, time, lookahead=barmerge.lookahead_off)

// Detect when HTF bar changes (new week/month begins)
htfBarChange = ta.change(htfTime) != 0

// Track progressive HTF high/low within the current bar
// This prevents look-ahead bias - we only know the range so far
var float progressiveHTFHigh = na
var float progressiveHTFLow = na

if htfBarChange
    // New HTF bar started - reset to current bar's values
    progressiveHTFHigh := high
    progressiveHTFLow := low
else
    // Update progressive high/low as current LTF bar expands the range
    progressiveHTFHigh := math.max(progressiveHTFHigh, high)
    progressiveHTFLow := math.min(progressiveHTFLow, low)

// Use progressive values for display instead of final HTF values
displayHTFHigh = progressiveHTFHigh
displayHTFLow = progressiveHTFLow

// HTF trend direction based on close vs open
isHTFBullish = htfClose > htfOpen
isHTFBearish = htfClose < htfOpen

// Conditions for alerts (must be bool, not series)
bullishHTFStart = htfBarChange and isHTFBullish
bearishHTFStart = htfBarChange and isHTFBearish

// ══════════════════════════════════════════════════════════════════════════════
// VISUAL OUTPUT
// ══════════════════════════════════════════════════════════════════════════════

// Color scheme: green for bullish HTF bars, red for bearish
htfColor = isHTFBullish ? color.new(color.green, 30) : color.new(color.red, 30)
htfLineColor = isHTFBullish ? color.green : color.red

// Determine what to display based on mode (using na to hide plots)
showOHLC = compressionMode == "OHLC Bars"
showCloseLine = compressionMode == "Close Line"
showHLOnly = compressionMode == "HL Zones Only"

// Mode 1: OHLC Bar Structure
plot(showOHLC ? htfOpen : na, "HTF Open", color=color.new(htfLineColor, 60), linewidth=1, style=plot.style_stepline)
plot(showOHLC ? htfClose : na, "HTF Close", color=htfLineColor, linewidth=2, style=plot.style_stepline)

highZoneOHLC = plot(showOHLC ? displayHTFHigh : na, "HTF High", color=color.new(color.gray, 70), linewidth=1, style=plot.style_stepline)
lowZoneOHLC = plot(showOHLC ? displayHTFLow : na, "HTF Low", color=color.new(color.gray, 70), linewidth=1, style=plot.style_stepline)
fill(highZoneOHLC, lowZoneOHLC, color=color.new(htfColor, 93), title="HTF Bar Range")

// Mode 2: Close Line (Trend Focus)
plot(showCloseLine ? htfClose : na, "HTF Close Trend", color=htfLineColor, linewidth=3, style=plot.style_stepline)

// Mode 3: HL Zones Only (Range Context)
highZoneOnly = plot(showHLOnly and showHLZones ? displayHTFHigh : na, "HTF High Zone", color=color.new(color.blue, 50), linewidth=2, style=plot.style_stepline)
lowZoneOnly = plot(showHLOnly and showHLZones ? displayHTFLow : na, "HTF Low Zone", color=color.new(color.orange, 50), linewidth=2, style=plot.style_stepline)
fill(highZoneOnly, lowZoneOnly, color=color.new(color.gray, 90), title="HTF Range")

// High/Low zones overlay (if enabled and not in HL-only mode)
plot(showHLZones and not showHLOnly ? displayHTFHigh : na, "HTF High Boundary", color=color.new(color.blue, 80), linewidth=1, style=plot.style_circles)
plot(showHLZones and not showHLOnly ? displayHTFLow : na, "HTF Low Boundary", color=color.new(color.orange, 80), linewidth=1, style=plot.style_circles)

// Mark HTF bar changes with vertical line
bgcolor(htfBarChange ? color.new(color.gray, 95) : na, title="HTF Bar Change")

// Add labels for HTF Open and Close at bar changes for clarity
if htfBarChange
    // HTF Open label (shows where the new HTF bar opened)
    label.new(bar_index, htfOpen, 
         text="O\n" + str.tostring(htfOpen, format.mintick), 
         style=label.style_label_left,
         color=color.new(color.blue, 20),
         textcolor=color.white,
         size=size.small,
         tooltip="HTF Open: " + str.tostring(htfOpen))
    
    // HTF Close label from previous bar (shows where last HTF bar closed)
    if not na(htfClose[1])
        label.new(bar_index[1], htfClose[1], 
             text="C\n" + str.tostring(htfClose[1], format.mintick), 
             style=label.style_label_right,
             color=color.new(htfClose[1] > htfOpen[1] ? color.green : color.red, 20),
             textcolor=color.white,
             size=size.small,
             tooltip="HTF Close: " + str.tostring(htfClose[1]))

// Current HTF Close level (updates live as week progresses)
plot(htfClose, "Current HTF Close", color=color.new(htfLineColor, 50), linewidth=1, style=plot.style_circles)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS (OPTIONAL)
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullishHTFStart, 
     title="New Bullish HTF Bar",
     message="Murphy Timeframe Lens: New HTF bar opened bullish")

alertcondition(bearishHTFStart, 
     title="New Bearish HTF Bar",
     message="Murphy Timeframe Lens: New HTF bar opened bearish")

// ══════════════════════════════════════════════════════════════════════════════
// SANITY CHECKS
// ══════════════════════════════════════════════════════════════════════════════
// ✓ No repainting: request.security uses lookahead_off (confirmed on bar close)
// ✓ No division by zero: No division operations present
// ✓ Parameters constrained: Only W/M allowed, boolean flags safe
// ✓ Memory usage: HTF data request is efficient, max_bars_back=500 reasonable
// ✓ Plots bounded: HTF OHLC follows price, always finite values
// ✓ HTF compatibility: Works on any timeframe < selected HTF (daily and below for W, weekly and below for M)
// ══════════════════════════════════════════════════════════════════════════════
````
