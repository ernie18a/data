# OLS Slope For Loop [MiesOnCharts]

- url: https://www.tradingview.com/script/81V9MoUb-OLS-Slope-For-Loop-MiesOnCharts/
- type: indicator
- pine_id: PUB;29ef2ae4d6d549658063eec099f9f9ce
- version: 1.0

## Description

Ordinary Least Squares Slope For Loop

An ensemble of least squares regression lines, one for every window length in a range. Each fits a straight line to recent price and votes on whether that line points up or down. The plotted score is the margin of the vote, running from -1 when every window is falling to +1 when every window is rising.

Built and tuned for the daily timeframe. The inputs adjust for others.

[b]Why an ensemble[/b]

Any single regression length is an arbitrary pick, and the best one is only obvious afterwards. Short windows turn fast and catch noise. Long windows are steady and late. This runs the whole range at once and treats direction as a vote, so no single length decides the answer.

[b]Why a slope instead of a crossing[/b]

Price above a moving average, or price above where it sat some bars ago, both compare one number against one other number. A single violent bar can push either across the line.

A regression slope is fitted to every bar in its window. One outlier is one point among many, so the fit barely moves. A wick, a gap or a liquidation candle does not get a vote of its own.

That resistance is the whole trade, and it cuts both ways. The reading holds steady when price is chopping inside a range, which is where crossing based tools whipsaw. It is also slower to commit during a clean fast run, where a simple moving average vote will usually be ahead of it. This is meant to sit beside those tools rather than replace them.

[b]How it works[/b]

A loop steps from the min window to the max window. Each step fits a least squares line over that many bars and votes +1 if the line rises, -1 if it falls. The votes are averaged into the score.

Every member keeps two running totals that update once per bar, so its slope comes out at a fixed cost no matter how long its window is. Re-summing every window on every bar would not survive a long chart.

A second line shows the average move the fitted lines imply, as a percent of price. It is rescaled to share the vote's axis and clipped at the edges, so if it sits pinned at the top it has run off the scale rather than maxed out. The exact figure is in the data window as Consensus Slope %.

[b]Signals[/b]

Score at or above the threshold turns the state to uptrend and everything green. Score at or below the mirror of it turns the state to downtrend and everything red. In between, the previous state holds.

Holding between the thresholds is deliberate. A brief loss of agreement does not end a regime, and the state only turns when the other side wins outright. Triangles mark each flip, and both flips have alerts.

[b]Inputs[/b]

[list]
[*] Source: the price series the lines are fitted to.
[*] Min Window and Max Window: the shortest and longest lookbacks in the ensemble. A wider span mixes more timescales and gives a smoother, slower score.
[*] Window Step: the spacing between members. Smaller packs in more lines, finer but heavier. Larger uses fewer, coarser ones.
[*] Trend Threshold: how much agreement is needed before the state flips. Higher is more selective and later. Lower reacts sooner and flips more often.
[*] Show Consensus Slope and Fill To Zero: display toggles.
[/list]

[b]How to use it[/b]

[list]
[*] Read the colour as a regime filter. A score near an extreme means every horizon agrees. A score near the middle means they are split and directional trades have less behind them.
[*] Watch it beside a faster tool. When that one has flipped and this has not, the move so far rests on the newest bars rather than on the shape of the whole window.
[*] Check the slope as well as the score. A full vote on a shallow drift and a full vote on a steep run look identical in the score.
[/list]

[b]Limits[/b]

[list]
[*] It is reactive. It describes the trend price is already in and will lag turns. It does not forecast.
[*] Nearby window lengths give similar answers, so a narrow range delivers less of the averaging benefit than a wide one.
[*] The score moves in steps set by how many members there are. A small ensemble gives a coarse, stair stepped reading, and one member changing its mind moves the score a long way. Wider spans and smaller steps smooth this out.
[*] Runtime grows with the number of members.
[*] No setting is right everywhere. Test on your own market and timeframe.
[/list]


[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice, nor a recommendation to buy or sell any asset.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _
//  |  \/  (_) ___  ___
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ============================================================
//  Ordinary Least Squares SLOPE FOR LOOP
//  An ensemble of least squares regressions, one per window
//  length, each voting on the sign of the line it fits. The
//  score is the margin of that vote.
// ============================================================
indicator("OLS Slope For Loop - Mies", shorttitle = "OLSFL - Mies", overlay = false, max_bars_back = 4999)

src     = input.source(close, "Source")
minLen  = input.int(10, "Min Window", minval = 3)
maxLen  = input.int(50, "Max Window", minval = 4)
lenStep = input.int(1,  "Window Step", minval = 1)
thr     = input.float(0.2, "Trend Threshold", minval = 0.0, maxval = 1.0, step = 0.05,
     tooltip = "Score needed before the regime flips.")

showSlope = input.bool(true, "Show Consensus Slope", group = "Display")
showFill  = input.bool(true, "Fill To Zero",         group = "Display")

// --- Ensemble size --------------------------------------------
nRaw = (maxLen - minLen) / lenStep + 1                     // integer division is intended here
n    = nRaw < 1 ? 1 : nRaw

var array<float> sArr = array.new<float>(n, 0.0)           // rolling sum over each member's window
var array<float> aArr = array.new<float>(n, 0.0)           // same window, weighted by bar age

// --- The loop -------------------------------------------------
float votes  = 0.0
float pctSum = 0.0

for k = 0 to n - 1
    L = minLen + k * lenStep

    // Both sums roll forward in constant time, so cost per member does not grow with
    // its window length: S drops the bar leaving the window, A also discounts the shift.
    sPrev = array.get(sArr, k)
    full  = bar_index >= L                                 // window has started shedding its oldest bar
    yOut  = full ? src[L] : 0.0

    sNew = sPrev + src - (full ? yOut : 0.0)
    aNew = array.get(aArr, k) + sPrev - (full ? L * yOut : 0.0)
    array.set(sArr, k, sNew)
    array.set(aArr, k, aNew)

    // Slope of the least squares line through this member's window, per bar.
    slope = 12.0 * ((L - 1) * sNew / 2.0 - aNew) / (L * (L * L - 1.0))

    ok = bar_index >= L - 1
    votes += ok ? (slope > 0 ? 1.0 : -1.0) : 0.0
    // Fitted move across the member's own window, as a percent of price. Comparable
    // across members even though their windows differ.
    pctSum += ok and src != 0 ? slope * L / src * 100 : 0.0

score   = votes / n
consPct = pctSum / n

ready = bar_index >= maxLen + 1

// --- Regime ---------------------------------------------------
var int dir = 0
dir := ready ? (score >= thr ? 1 : score <= -thr ? -1 : dir) : dir

colUp   = color.rgb(0, 255, 21)
colDn   = color.rgb(255, 0, 0)
colFlat = color.rgb(120, 123, 134)
regCol  = dir == 0 ? colFlat : dir == 1 ? colUp : colDn

// --- Rendering ------------------------------------------------
ps = plot(ready ? score : na, "Vote Score", color = regCol, linewidth = 2)
pz = plot(ready ? 0.0 : na, "Zero", color = color.new(colFlat, 100), display = display.none)
fill(ps, pz, color = showFill ? color.new(regCol, 88) : na, title = "Score Fill")

// Consensus slope scaled onto the vote axis so both share one scale.
plot(showSlope and ready ? math.max(math.min(consPct / 20.0, 1.0), -1.0) : na,
     "Consensus Slope", color = color.new(color.orange, 35), linewidth = 1)

hline(0, "Zero", color = color.new(colFlat, 40))
hline(thr,  "Long Threshold",  color = color.new(colUp, 60), linestyle = hline.style_dashed)
hline(-thr, "Short Threshold", color = color.new(colDn, 60), linestyle = hline.style_dashed)

bgcolor(ready and dir != 0 ? color.new(regCol, 94) : na, title = "Regime Background")

flipUp = dir == 1  and dir[1] != 1
flipDn = dir == -1 and dir[1] != -1
plotshape(flipUp ? score : na, "Long",  shape.triangleup,   location.absolute, colUp, size = size.tiny)
plotshape(flipDn ? score : na, "Short", shape.triangledown, location.absolute, colDn, size = size.tiny)

// Unscaled slope reading, for the data window and for other scripts to reference.
plot(ready ? consPct : na, "Consensus Slope %", color = color.blue, display = display.data_window)

// --- Alerts ---------------------------------------------------
alertcondition(flipUp, "OLS Slope Up",   "The regression ensemble agrees on a rising slope")
alertcondition(flipDn, "OLS Slope Down", "The regression ensemble agrees on a falling slope")
````
