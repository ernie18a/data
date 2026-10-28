# NYSE -TICK Cluster Low

- url: https://www.tradingview.com/script/DciojcT2-NYSE-TICK-Cluster-Low/
- type: indicator
- pine_id: PUB;b44f76b433464f71a47b218949c791b4
- version: 1.0

## Description

This indicator finds stretches of days when the NYSE TICK closes at an extreme low, then marks the lowest price point of that stretch on your chart.

How it works

It pulls the daily close of USI:TICK and flags any day where it closes at or below your threshold (default -300).
Flagged days are chained into a cluster. A new flagged day joins the current cluster if it lands within the cluster threshold (default 5 bars) of the previous flagged day. If the gap is larger, a new cluster starts.
Once a cluster has at least the minimum number of flagged days (default 2), it draws a horizontal line at the lowest low of the chart symbol during that cluster. The line extends forward 10 bars from the bar where that low occurred.
The line is redrawn each time a new flagged day is added, so it always reflects the cluster's lowest low so far.

Color tiers
The line and label color escalate with cluster size: yellow at 4+ flagged days, orange at 8+, and red at 12+. Clusters of 2 to 3 use the base line color (red by default). All tier sizes and colors are adjustable inputs.

Label
Under each line you'll see text like 5 in 9 days (using 5 day cluster threshold): the number of flagged days, the number of candles from the first flagged day to the most recent one, and your current cluster threshold setting.

Intended use
Heavy, repeated selling pressure (very negative TICK readings) often clusters near short-term lows. The lines give you reference levels to watch as potential support, with color showing how intense the selling was.

Caveat: It's built for daily charts. On intraday timeframes, the daily TICK close is repeated across every bar of the day, so a single extreme day would register as many signals and inflate the counts. If you want to use it intraday, the logic would need to be changed to count each day only once.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SROLES

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SROLES

//@version=6
indicator("NYSE TICK Cluster Low", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── Inputs ───────────────────────────────────────────────
tickSymbol  = input.symbol("USI:TICK", "NYSE TICK Symbol")
thresh      = input.int(-300, "Trigger when Tick Close <=")
minCount    = input.int(2, "Minimum # of qualifying days in cluster to trigger", minval=2)
clusterBars = input.int(5, "Cluster threshold (max trading days between consecutive signals)", minval=1)
extendBars  = input.int(10, "Extend line for N trading sessions")
lineColor   = input.color(color.rgb(35, 75, 250), "Line color (below first tier)")
lineWidth   = input.int(2, "Line width", minval=1)

// ─── Cluster tiers ────────────────────────────────────────
tier1Count  = input.int(4,  "Tier 1 cluster size", minval=2, group="Cluster Colors")
tier2Count  = input.int(8,  "Tier 2 cluster size", minval=2, group="Cluster Colors")
tier3Count  = input.int(12, "Tier 3 cluster size", minval=2, group="Cluster Colors")
tier1Color  = input.color(color.yellow, "Tier 1 color", group="Cluster Colors")
tier2Color  = input.color(color.orange, "Tier 2 color", group="Cluster Colors")
tier3Color  = input.color(color.red,    "Tier 3 color", group="Cluster Colors")

clusterColor(int cnt) =>
    color result = lineColor
    if cnt >= tier3Count
        result := tier3Color
    else if cnt >= tier2Count
        result := tier2Color
    else if cnt >= tier1Count
        result := tier1Color
    result

// ─── Get daily TICK close ─────────────────────────────────
tickClose = request.security(tickSymbol, "D", close, lookahead=barmerge.lookahead_off)

signal = tickClose <= thresh

// invisible plot so the TICK close value shows in the legend/status-line and Data Window on hover
plot(tickClose, title="NYSE TICK Close", color=color.new(color.blue, 100), linewidth=1)

// ─── Track the current cluster (chain of signals within clusterBars of each other) ───
var int   lastSignalBar  = na
var int   clusterCount   = 0
var int   clusterStartBar = na
var int   clusterMinBar  = na
var float clusterMinLow  = na
var line  clusterLine    = na
var label clusterLabel   = na

if signal
    gapOk = not na(lastSignalBar) and (bar_index - lastSignalBar) <= clusterBars

    if not gapOk
        // start a brand new cluster
        clusterCount    := 1
        clusterStartBar := bar_index
        clusterMinBar   := bar_index
        clusterMinLow   := low
        clusterLine     := na
        clusterLabel    := na
    else
        // still within the window of the last qualifying day -> extend the cluster
        clusterCount += 1
        if low < clusterMinLow
            clusterMinLow := low
            clusterMinBar := bar_index

        // once enough signals are in the cluster, (re)draw the line at the lowest low so far
        if clusterCount >= minCount
            curColor = clusterColor(clusterCount)

            // candles from the first signal in the cluster through the most recent signal (inclusive)
            spanDays = bar_index - clusterStartBar + 1

            if not na(clusterLine)
                line.delete(clusterLine)
            clusterLine := line.new(x1=clusterMinBar, y1=clusterMinLow, x2=clusterMinBar + extendBars, y2=clusterMinLow,
                 xloc=xloc.bar_index, color=curColor, width=lineWidth, style=line.style_solid)

            labelText = str.tostring(clusterCount) + " in " + str.tostring(spanDays) + " days (using " + str.tostring(clusterBars) + " day cluster threshold)"

            if not na(clusterLabel)
                label.delete(clusterLabel)
            clusterLabel := label.new(x=clusterMinBar, y=clusterMinLow, text=labelText,
                 xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.white, 100), textcolor=curColor, size=size.small)

    lastSignalBar := bar_index
````
