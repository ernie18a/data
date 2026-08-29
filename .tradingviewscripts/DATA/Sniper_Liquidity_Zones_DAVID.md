<!-- tradingview-pine-id: PUB;269f7f4f60814f75a2c8698634e06f8d -->
<!-- tradingviewscripts-format: 1 -->
# Sniper Liquidity Zones [DAVID]

Source: https://www.tradingview.com/script/ZBVrC2vn-Sniper-Liquidity-Zones-by-DAVID/

## Description

This indicator is built for Smart Money Concepts (SMC) and ICT traders who want to capture high-probability entry opportunities based on Liquidity Sweeps and Fair Value Gaps (FVG).

Instead of cluttering the chart with endless arrows, shapes, or text labels, this tool draws clean Rectangle Zones that mark exact trading areas and remain active on your chart until price mitigates them.

System Logic and How It Works

Liquidity Sweeps Detection
The indicator tracks dynamic Swing Highs (Buy-Side Liquidity / BSL) and Swing Lows (Sell-Side Liquidity / SSL) using customizable pivot lookback periods. A sweep is confirmed when price pierces past a key swing point and closes back inside the range.

Fair Value Gap (FVG) Confluence
After a liquidity sweep occurs, the algorithm scans the next few candles for a valid 3-bar Fair Value Gap (Imbalance). When a sweep is backed by an FVG, it confirms institutional footprint and validates the signal.

Dynamic Buy and Sell Rectangle Zones
When both Liquidity Sweep and FVG conditions align:

A Green Rectangle Zone labeled "buy" is created for bullish setups.

A Red Rectangle Zone labeled "sell" is created for bearish setups.
These boxes automatically extend horizontally across future bars until price crosses through them (mitigation), giving you clear retest levels.

Built-in Anti-Spam Filter
To prevent duplicate signals on lower timeframes and maintain chart clarity, a minimum bar distance filter is integrated. This ensures zones only appear on fresh, distinct setups.

How to Use for Trading

Buy Setup:

Wait for price to sweep Sell-Side Liquidity (SSL).

Look for the Green Rectangle Zone labeled "buy" to appear on your chart.

Enter on the open or retest of the green rectangle zone, placing stop loss below the zone low.

Sell Setup:

Wait for price to sweep Buy-Side Liquidity (BSL).

Look for the Red Rectangle Zone labeled "sell" to appear on your chart.

Enter on the open or retest of the red rectangle zone, placing stop loss above the zone high.

Indicator Inputs

Pivot Lookback Length: Determines how far back the script looks to mark major market structure highs and lows.

Max Bars After Sweep to Find FVG: Controls how many candles after a sweep the script checks for an imbalance gap.

Min Bars Between Zones: Filters out closely repeating signals to avoid noise on volatile charts.

Zone Transparency and Colors: Allows complete visual customization of the buy and sell boxes.

---

## Source Code

````pine
//@version=6
indicator("Sniper Liquidity Zones [DAVID]", overlay = true, max_labels_count = 100, max_boxes_count = 100)
// INPUTS
swingLength = input.int(5, "Pivot Lookback Length", minval = 1, group = "Market Structure")
fvgLookback = input.int(10, "Max Bars After Sweep to Find FVG", minval = 1, group = "Strategy Rules")
minSignalGap = input.int(5, "Minimum Bars Between Signals (Spam Prevention)", minval = 1, group = "Clean Visuals")

// Visual Controls
showSweeps  = input.bool(false, "Show Minor Sweep Shapes", group = "Clean Visuals")
showOB      = input.bool(true, "Show Active Order Blocks", group = "Clean Visuals")
showFVG     = input.bool(true, "Show FVG Highlights", group = "Clean Visuals")

// PIVOTS & LIQUIDITY SWEEPS
ph = ta.pivothigh(high, swingLength, swingLength)
pl = ta.pivotlow(low, swingLength, swingLength)

var float lastHigh = na
var float lastLow  = na

lastHigh := not na(ph) ? ph : lastHigh
lastLow  := not na(pl) ? pl : lastLow

// Sweep Detections (Only Trigger First Time)
rawBullSweep = not na(lastLow) and low < lastLow and close > lastLow
rawBearSweep = not na(lastHigh) and high > lastHigh and close < lastHigh

bullSweep = rawBullSweep and not rawBullSweep[1]
bearSweep = rawBearSweep and not rawBearSweep[1]

plotshape(showSweeps and bullSweep, title="Bull Sweep", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(showSweeps and bearSweep, title="Bear Sweep", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)

// FAIR VALUE GAPS (FVG) AFTER SWEEP
var int lastBullSweepBar = na
var int lastBearSweepBar = na

lastBullSweepBar := bullSweep ? bar_index : lastBullSweepBar
lastBearSweepBar := bearSweep ? bar_index : lastBearSweepBar

// FVG Logic (3-bar pattern)
isBullFVG = (low > high[2]) and (bar_index - lastBullSweepBar <= fvgLookback)
isBearFVG = (high < low[2]) and (bar_index - lastBearSweepBar <= fvgLookback)

// Plot FVGs Inline
if showFVG and isBullFVG and not isBullFVG[1]
    box.new(left=bar_index-1, top=low, right=bar_index+5, bottom=high[2], bgcolor=color.new(color.green, 85), border_color=color.green)

if showFVG and isBearFVG and not isBearFVG[1]
    box.new(left=bar_index-1, top=high[2], right=bar_index+5, bottom=low, bgcolor=color.new(color.red, 85), border_color=color.red)

// CLEAN ENTRY SIGNALS (FILTER SPAM)
rawLong  = bullSweep or (isBullFVG and not isBullFVG[1])
rawShort = bearSweep or (isBearFVG and not isBearFVG[1])

var int lastLongBar  = -999
var int lastShortBar = -999

sniperLong  = rawLong and (bar_index - lastLongBar >= minSignalGap)
sniperShort = rawShort and (bar_index - lastShortBar >= minSignalGap)

lastLongBar  := sniperLong ? bar_index : lastLongBar
lastShortBar := sniperShort ? bar_index : lastShortBar

// SMALL LETTER LABELS
plotshape(sniperLong, title="Sniper Long", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, text="long", size=size.tiny)
plotshape(sniperShort, title="Sniper Short", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, text="short", size=size.tiny)
````
