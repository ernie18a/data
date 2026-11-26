# S/R & Liquidity Pro

- url: https://www.tradingview.com/script/rGUkAzOL-S-R-Liquidity-Pro/
- type: indicator
- pine_id: PUB;d7e06d8021c24c73a7169818f3e8e7c2
- version: 1.0

## Description

Overview
DT S/R & Liquidity Pro is a clean, multi-layer Support and Resistance toolkit that maps three distinct sources of structural memory onto a single chart: pivot-based liquidity zones, daily session anchors, and psychological round numbers. Each layer is independently toggleable, all lines extend right of the last bar, and nothing repaints.

How It Works
Layer 1 — Pivot Liquidity S/R
The indicator scans historical bars for confirmed swing highs and swing lows using a configurable lookback window. Each confirmed pivot is treated as a liquidity zone — a price where a meaningful number of participants were previously stopped out, filled, or reversed. These levels tend to act as magnets on subsequent approaches because trapped positions and pending orders cluster there.
Only the most recent N levels are kept on chart (adjustable input labeled Max Historical Levels), which prevents the chart from becoming a graveyard of every pivot ever made. Lines are color-coded: resistance in red, support in green by default.
What makes a pivot significant: the lookback (Pivot Strength) sets how many bars must form on each side of the high or low before it is confirmed. Higher values = fewer, higher-quality levels. Lower values = more granular intraday structure.

Layer 2 — Session Anchor Levels
Three automatic levels anchor each trading day:
Daily Open — Algos and institutional order flow are benchmarked against this level throughout the day. Reclaims and rejections at the daily open are among the most repeatable intraday setups.
Previous Day High (PDH) — A magnet for liquidity sweeps and breakout/breakdown setups, particularly in the first 90 minutes of the session.
Previous Day Low (PDL) — One of the most watched levels by professional desk traders and algorithms.
These levels update automatically at each new session. No manual input required.

Layer 3 — Psychological Round Numbers
Optional grid of horizontal levels spaced at a user-defined interval (default: every $10). Round numbers attract options strike clustering, retail stop placement, and institutional limit orders. Useful as a secondary confirmation layer, not a primary setup trigger.
Painted as faint dotted lines to minimize visual weight while remaining visible when warranted.

Recommended Inputs by Trading Style:

Scalping / Active Day Trading (1m – 15m chart)
Pivot Strength (Lookback): 5 – 7 — Captures granular intraday swing points; lower bars confirm faster
Max Historical Levels: 4 – 5 — More nearby levels needed for tight intraday decision-making
Show Session Levels: On — Daily Open is a primary intraday reference — essential
Show Previous Day H/L: On — PDH/PDL sweeps are bread-and-butter scalp setups
Show Round Numbers: Optional — Enable on high-priced instruments (e.g., SPX, TSLA) where $5–$10 intervals cluster options strikes
Round Number Step: 5.0 – 10.0 — Match to the instrument's typical daily range

Swing Trading (1H – Daily chart)
Pivot Strength (Lookback): 15 – 25 — Filters intraday noise; only confirms swing-level structural highs/lows
Max Historical Levels: 2 – 3 — On higher timeframes, only the most recent major levels matter
Show Session Levels: Optional — Daily Open is less relevant on a weekly hold; PDH/PDL retain value as weekly structure markers
Show Previous Day H/L: On — Still useful; overnight gaps into PDH/PDL are structural events on swing timeframes
Show Round Numbers: On — Psychological levels matter more over multi-day holds as price cycles through them repeatedly
Round Number Step: 10.0 – 25.0 — Larger intervals appropriate for instruments moving $10–$50 per week

## Source Code

````pine
//@version=6
indicator("Day Trading S/R & Liquidity Pro", shorttitle="DT S/R Pro", overlay=true, max_lines_count=100, max_labels_count=100)

// --- Groups & Inputs ---
groupPivot = "Liquidity S/R (Pivots)"
showPivots = input.bool(true, "Show Pivot Liquidity Levels", group=groupPivot)
pivotLen   = input.int(10, "Pivot Strength (Lookback)", minval=2, group=groupPivot, tooltip="Lower values (5-10) are better for day trading swing highs/lows.\n\nNote: Pivots require this number of bars to confirm. Therefore, levels are drawn 'late' (delayed by this amount of bars) relative to the actual swing high/low. They do not repaint.")
maxLevels  = input.int(3, "Max Historical Levels", minval=1, maxval=10, group=groupPivot, tooltip="Number of recent levels to keep on the chart.")
pStyle     = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupPivot)
pWidth     = input.int(1, "Line Width", minval=1, maxval=4, group=groupPivot)
resColor   = input.color(#f23645, "Resistance Color", group=groupPivot)
supColor   = input.color(#089981, "Support Color", group=groupPivot)

groupSession = "Day Trading Session Levels"
showSession  = input.bool(true, "Show Session Levels", group=groupSession)
showPrevDay  = input.bool(true, "Show Previous Day H/L", group=groupSession)
sessionColor = input.color(#5b9cf6, "Session Levels Color", group=groupSession)

groupPsych = "Psychological Levels"
showRound  = input.bool(false, "Show Round Numbers", group=groupPsych)
roundStep  = input.float(10.0, "Level Interval (Step)", minval=0.01, group=groupPsych)
rStyle     = input.string("Dotted", "Line Style", options=["Solid", "Dashed", "Dotted"], group=groupPsych)
roundColor = input.color(#5b9cf64d, "Level Color", group=groupPsych)

// --- Helper Functions ---
get_style(s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dotted

// --- Core Logic: Pivot S/R Liquidity ---
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

var line[] resLines = array.new_line()
var line[] supLines = array.new_line()

if not na(ph) and showPivots
    line newRes = line.new(bar_index - pivotLen, ph, bar_index, ph, color=resColor, style=get_style(pStyle), width=pWidth)
    array.push(resLines, newRes)
    if array.size(resLines) > maxLevels
        line.delete(array.shift(resLines))

if not na(pl) and showPivots
    line newSup = line.new(bar_index - pivotLen, pl, bar_index, pl, color=supColor, style=get_style(pStyle), width=pWidth)
    array.push(supLines, newSup)
    if array.size(supLines) > maxLevels
        line.delete(array.shift(supLines))

// Extend pivot lines
if barstate.islast and showPivots
    if array.size(resLines) > 0
        for i = 0 to array.size(resLines) - 1
            line.set_x2(array.get(resLines, i), bar_index + 15)
    if array.size(supLines) > 0
        for i = 0 to array.size(supLines) - 1
            line.set_x2(array.get(supLines, i), bar_index + 15)

// --- Core Logic: Session Levels ---
var float dayOpen = na
var float prevHigh = na
var float prevLow = na

// Track daily highs and lows properly
var float currentDailyHigh = high
var float currentDailyLow = low

if ta.change(time("D")) != 0
    dayOpen := open
    prevHigh := currentDailyHigh
    prevLow := currentDailyLow
    currentDailyHigh := high
    currentDailyLow := low
else
    currentDailyHigh := math.max(currentDailyHigh, high)
    currentDailyLow := math.min(currentDailyLow, low)

var line dayOpenLine = na
var line prevHighLine = na
var line prevLowLine = na
var label dayOpenLbl = na
var label prevHighLbl = na
var label prevLowLbl = na

if barstate.islast and showSession
    if na(dayOpenLine)
        dayOpenLine := line.new(bar_index - 50, dayOpen, bar_index + 15, dayOpen, color=sessionColor, style=line.style_dashed)
        dayOpenLbl := label.new(bar_index + 15, dayOpen, "Daily Open", color=color.new(color.black, 100), textcolor=sessionColor, style=label.style_label_left, size=size.small)
    else
        line.set_xy1(dayOpenLine, bar_index - 50, dayOpen)
        line.set_xy2(dayOpenLine, bar_index + 15, dayOpen)
        label.set_xy(dayOpenLbl, bar_index + 15, dayOpen)
        
if barstate.islast and showPrevDay
    if na(prevHighLine)
        prevHighLine := line.new(bar_index - 50, prevHigh, bar_index + 15, prevHigh, color=sessionColor, style=line.style_dotted)
        prevHighLbl := label.new(bar_index + 15, prevHigh, "PDH", color=color.new(color.black, 100), textcolor=sessionColor, style=label.style_label_left, size=size.small)
        
        prevLowLine := line.new(bar_index - 50, prevLow, bar_index + 15, prevLow, color=sessionColor, style=line.style_dotted)
        prevLowLbl := label.new(bar_index + 15, prevLow, "PDL", color=color.new(color.black, 100), textcolor=sessionColor, style=label.style_label_left, size=size.small)
    else
        line.set_xy1(prevHighLine, bar_index - 50, prevHigh)
        line.set_xy2(prevHighLine, bar_index + 15, prevHigh)
        label.set_xy(prevHighLbl, bar_index + 15, prevHigh)
        
        line.set_xy1(prevLowLine, bar_index - 50, prevLow)
        line.set_xy2(prevLowLine, bar_index + 15, prevLow)
        label.set_xy(prevLowLbl, bar_index + 15, prevLow)

// --- Core Logic: Round Numbers ---
var line[] rLns = array.new_line()
if barstate.isfirst
    for i = 0 to 4 
        array.push(rLns, line.new(na, na, na, na, color=roundColor, style=get_style(rStyle), width=1))

if showRound and barstate.islast
    float baseRound = math.floor(close / roundStep) * roundStep
    for i = 0 to 4
        float level = baseRound + (i - 2) * roundStep
        line ln = array.get(rLns, i)
        line.set_xy1(ln, bar_index - 50, level)
        line.set_xy2(ln, bar_index + 15, level)
else if not showRound and barstate.islast
    for i = 0 to 4
        line.set_xy1(array.get(rLns, i), na, na)
````
