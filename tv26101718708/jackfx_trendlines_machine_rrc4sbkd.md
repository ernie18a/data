# Jackfx Trendlines Machine

- url: https://www.tradingview.com/script/Rrc4SBKd-Jackfx-Trendlines-Machine/
- type: indicator
- pine_id: PUB;0ce97c68eabe440b82eaadc54b0c333b
- version: 1.0

## Description

Jackfx Trendlines Machine
The Jackfx Trendlines Machine is an advanced, automated technical analysis tool designed to eliminate the subjectivity and noise associated with manual trendline drawing. Built for traders who rely on structural breakouts and retests, this indicator dynamically identifies high-probability zones by filtering out volatile market spikes.

Core Mechanics
Instead of relying on standard candlestick wicks, the indicator calculates major market pivots using background Heikin Ashi (HA) data. Because Heikin Ashi averages price action, the resulting swing highs and lows represent true structural turning points rather than momentary liquidity sweeps. The indicator then connects these definitive pivots on your standard candlestick chart to draw accurate, objective trendlines.

Key Features
Noise-Free Pivot Detection: By sourcing high/low pivots from Heikin Ashi data, the indicator ignores "fakeout" wicks, anchoring trendlines strictly to validated market structure.

Dynamic Auto-Drawing: The script automatically isolates the two most recent and significant swing highs (for downtrends) and swing lows (for uptrends), connecting them and projecting the line forward to anticipate future touches.

ATR-Filtered Breakouts: To protect against false breakouts, the indicator incorporates an Average True Range (ATR) buffer. A breakout signal (indicated by visual triangles) is only generated when the price closes across the trendline with sufficient momentum.

Retest Validation: The extended trendlines act as forward-looking support and resistance levels. When a breakout occurs, traders can use the extended lines to stalk high-probability retest entries.

Customizable Sensitivity: Users can adjust the "Pivot Length" inputs to tailor the indicator to their trading style. Lower values plot minor, short-term trendlines, while higher values isolate major, macro-structural trendlines.

Ideal Use Case
This tool is highly effective for price action traders looking to automate their structural analysis. It excels in identifying clean breakout setups and providing objective zones for pullback/retest entries across all timeframes.

## Source Code

````pine
//@version=6
indicator("Jackfx Trendlines Machine", overlay=true, max_lines_count=500)

// =========================================================================
// INPUTS
// =========================================================================
grp1 = "Trendline Sensitivity"
leftLen  = input.int(15, title="Left Pivot Length", group=grp1, tooltip="Higher number = more major trendlines. Lower = minor trendlines.")
rightLen = input.int(15, title="Right Pivot Length", group=grp1)

grp2 = "Calculation Source"
useHA    = input.bool(true, title="Use Heikin Ashi for Pivots (Filters Noise)", group=grp2)
useATR   = input.bool(true, title="Use ATR Filter for Breakouts", group=grp2)

// =========================================================================
// HEIKIN ASHI & DATA SETUP
// =========================================================================
// Fetch Heikin Ashi data to filter out market noise
haTicker = ticker.heikinashi(syminfo.tickerid)
haClose  = request.security(haTicker, timeframe.period, close)
haHigh   = request.security(haTicker, timeframe.period, high)
haLow    = request.security(haTicker, timeframe.period, low)

// Determine the calculation source
srcHigh  = useHA ? haHigh : high
srcLow   = useHA ? haLow : low
srcClose = useHA ? haClose : close

// =========================================================================
// PIVOT DETECTION
// =========================================================================
ph = ta.pivothigh(srcHigh, leftLen, rightLen)
pl = ta.pivotlow(srcLow, leftLen, rightLen)

// Variables to store the coordinates of the last two pivot points
var int ph_x1 = na, var float ph_y1 = na
var int ph_x2 = na, var float ph_y2 = na

var int pl_x1 = na, var float pl_y1 = na
var int pl_x2 = na, var float pl_y2 = na

// Update Pivot Highs
if not na(ph)
    ph_x1 := ph_x2
    ph_y1 := ph_y2
    ph_x2 := bar_index[rightLen]
    ph_y2 := ph

// Update Pivot Lows
if not na(pl)
    pl_x1 := pl_x2
    pl_y1 := pl_y2
    pl_x2 := bar_index[rightLen]
    pl_y2 := pl

// =========================================================================
// DRAWING THE TRENDLINES
// =========================================================================
var line tl_high = na
var line tl_low  = na

if not na(ph) and not na(ph_x1)
    // Draw Downtrend line connecting the tops
    tl_high := line.new(ph_x1, ph_y1, ph_x2, ph_y2, color=color.new(color.red, 0), width=2, extend=extend.right)
    
if not na(pl) and not na(pl_x1)
    // Draw Uptrend line connecting the bottoms
    tl_low := line.new(pl_x1, pl_y1, pl_x2, pl_y2, color=color.new(color.green, 0), width=2, extend=extend.right)

// =========================================================================
// BREAKOUT & RETEST LOGIC
// =========================================================================
// Function to get the current Y value of the extended line
get_line_y(x1, y1, x2, y2, x) =>
    if na(x1) or na(x2) or x1 == x2
        na
    else
        slope = (y2 - y1) / (x2 - x1)
        y1 + slope * (x - x1)

// Current trendline levels
current_tl_high_y = get_line_y(ph_x1, ph_y1, ph_x2, ph_y2, bar_index)
current_tl_low_y  = get_line_y(pl_x1, pl_y1, pl_x2, pl_y2, bar_index)

// ATR filter to ensure the breakout has momentum
atr = ta.atr(14)
breakout_buffer = useATR ? (atr * 0.2) : 0

// Breakout Conditions (using standard close to enter trades on normal charts)
bull_breakout = ta.crossover(close, current_tl_high_y + breakout_buffer) and current_tl_high_y < current_tl_high_y[1] // Ensure it's a downward sloping line
bear_breakout = ta.crossunder(close, current_tl_low_y - breakout_buffer) and current_tl_low_y > current_tl_low_y[1]   // Ensure it's an upward sloping line

// Plot Breakout Signals
plotshape(bull_breakout, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Bullish Breakout")
plotshape(bear_breakout, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Bearish Breakout")

// =========================================================================
// ALERTS
// =========================================================================
alertcondition(bull_breakout, title="Bullish Trendline Breakout", message="Jackfx: Bullish Breakout Detected!")
alertcondition(bear_breakout, title="Bearish Trendline Breakout", message="Jackfx: Bearish Breakout Detected!")
````
