# SMT w Alerts

- url: https://www.tradingview.com/script/2qfBPJPd-SMT-w-Alerts/
- type: indicator
- pine_id: PUB;0b1598e9f8e34a9892efe0f6e50b8a1c
- version: 1.0

## Description

This script is a Smart Money Tool (SMT) Divergence Indicator written in TradingView's Pine Script v6. It automatically detects and visualizes instances where highly correlated assets (like NQ, ES, and YM) fall out of sync at major price swings.

Here is a breakdown of how the script works and its key features:

1. Core Logic (Pivot Tracking)
The script uses ta.pivothigh and ta.pivotlow to identify swing highs and swing lows on your main chart based on a window of bars (default 3 bars left and right). It remembers the most recent pivot and the one right before it so it can compare the two.

2. Dual-Symbol Comparison
When a pivot is confirmed on your main chart, the script immediately looks at the price action of two comparison symbols (e.g., MNQ and MES) at that exact same time.

Tolerance Window: Because assets like NQ and ES don't always peak on the exact same 1-minute or 5-minute candle, the script includes a "Comparison Tolerance" input. It looks a few bars before and after the pivot on the comparison symbols to find their true peak/valley.

3. Divergence Detection
The script compares the slope of the pivots on your chart against the comparison symbols:

Bearish SMT (Highs): If your chart makes a Higher High, but the comparison symbol makes a Lower High (or vice versa). This indicates underlying weakness in the buying pressure.

Bullish SMT (Lows): If your chart makes a Lower Low, but the comparison symbol makes a Higher Low (or vice versa). This indicates underlying strength in the selling absorption.

It checks both comparison symbols simultaneously — if an SMT forms against either of them, it triggers the signal.

4. Visuals & Aesthetics
The SMT Bracket: When an SMT is detected, it draws a clean bracket (or "bridge") connecting the two diverging pivots. It draws horizontal tick marks at the pivots, vertical lines extending outward, and a horizontal bridge connecting them with a small "SMT" label. The bracket dynamically sizes itself using ATR (Average True Range).

Unused Pivots: Pivots that do not result in an SMT divergence are optionally connected with subtle grey dashed lines so you can see the market structure.

Bar Coloring: The candle where the SMT is officially confirmed is highlighted with a subtle background color.

5. Dashboard & Alerts
Dashboard: A clean table in the top right corner tracks how many Bearish and Bullish SMTs have occurred on the chart, and how many bars ago the most recent one fired.
Alerts: The script exposes alert conditions (alertcondition) that you can hook into TradingView's alert system to receive notifications when a Bullish or Bearish SMT forms.

## Source Code

````pine
//@version=6
indicator("SMT", shorttitle="SMT", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ─── Inputs ─────────────────────────────────────────────────────────────────
grp1 = "Core"
sym2      = input.symbol("CME_MINI:MNQ1!", "Comparison Symbol 1", group=grp1)
useSym3   = input.bool(true, "Use 2nd Comparison Symbol?", group=grp1)
sym3      = input.symbol("CME_MINI:MES1!", "Comparison Symbol 2", group=grp1)
leftBars  = input.int(3, "Pivot Left Bars", minval=1, maxval=50, group=grp1)
rightBars = input.int(3, "Pivot Right Bars", minval=1, maxval=50, group=grp1)
compTol   = input.int(2, "Comparison Tolerance (Bars)", minval=0, maxval=10, group=grp1, tooltip="How many bars before/after the pivot to check on the comparison symbol (accounts for MES/MNQ peaking slightly out of sync).")

grp2 = "Visuals"
bearClr   = input.color(#FF1744, "Bearish SMT Color", group=grp2)
bullClr   = input.color(#00E676, "Bullish SMT Color", group=grp2)
unusedClr = input.color(color.new(#78909C, 60), "Unused Pivot Line Color", group=grp2)
lnWidth   = input.int(1, "Line Width", minval=1, maxval=4, group=grp2)
showLabel = input.bool(true, "Show SMT Label", group=grp2)
showUnused = input.bool(true, "Show Unused Pivot Lines", group=grp2)
showDash  = input.bool(true, "Show Dashboard", group=grp2)
maxBars   = input.int(100, "Max Bars Between Pivots", minval=5, maxval=500, group=grp2)

// ─── Fetch comparison data ──────────────────────────────────────────────────
[sym2H, sym2L] = request.security(sym2, timeframe.period, [high, low])
[sym3H, sym3L] = request.security(sym3, timeframe.period, [high, low])

// ─── Pivots on main chart ───────────────────────────────────────────────────
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

// Pre-compute every bar (avoids scope warnings)
float _atr = ta.atr(14)

// ─── Persistent state ───────────────────────────────────────────────────────

// Pivot High tracking
var float prevPH       = na
var int   prevPH_bar   = na
var float prevPH_comp2 = na
var float prevPH_comp3 = na

var float currPH       = na
var int   currPH_bar   = na
var float currPH_comp2 = na
var float currPH_comp3 = na

// Pivot Low tracking
var float prevPL       = na
var int   prevPL_bar   = na
var float prevPL_comp2 = na
var float prevPL_comp3 = na

var float currPL       = na
var int   currPL_bar   = na
var float currPL_comp2 = na
var float currPL_comp3 = na

// Counters
var int bearCount = 0
var int bullCount = 0
var int lastBearBar = 0
var int lastBullBar = 0

// ─── Flags ──────────────────────────────────────────────────────────────────
bool bearSMT = false
bool bullSMT = false

// ─── When a pivot HIGH is found ─────────────────────────────────────────────
if not na(ph)
    // Shift current → previous
    prevPH       := currPH
    prevPH_bar   := currPH_bar
    prevPH_comp2 := currPH_comp2
    prevPH_comp3 := currPH_comp3

    // Record new pivot
    currPH     := ph
    currPH_bar := bar_index - rightBars
    
    // Find the comparison symbol 1's peak around the exact pivot bar
    float cPeak2 = sym2H[rightBars]
    for i = math.max(0, rightBars - compTol) to (rightBars + compTol)
        cPeak2 := math.max(cPeak2, sym2H[i])
    currPH_comp2 := cPeak2

    // Find the comparison symbol 2's peak around the exact pivot bar
    float cPeak3 = sym3H[rightBars]
    for i = math.max(0, rightBars - compTol) to (rightBars + compTol)
        cPeak3 := math.max(cPeak3, sym3H[i])
    currPH_comp3 := cPeak3

    // Check for SMT divergence
    if not na(prevPH) and not na(prevPH_comp2)
        int gap = currPH_bar - prevPH_bar
        if gap > 0 and gap <= maxBars
            bool mainHH  = currPH > prevPH
            bool mainLH  = currPH < prevPH
            bool comp2HH = currPH_comp2 > prevPH_comp2
            bool comp2LH = currPH_comp2 < prevPH_comp2
            bool comp3HH = currPH_comp3 > prevPH_comp3
            bool comp3LH = currPH_comp3 < prevPH_comp3

            bool smt2 = (mainHH and comp2LH) or (mainLH and comp2HH)
            bool smt3 = useSym3 and ((mainHH and comp3LH) or (mainLH and comp3HH))

            if smt2 or smt3
                // ═══ BEARISH SMT DETECTED ═══
                bearSMT := true
                bearCount += 1
                lastBearBar := bar_index

                // ─── Draw bracket above the highs ───
                //       ──── SMT ────
                //       │            │
                //    ── •         ── •
                float topVal  = math.max(currPH, prevPH)
                float offset  = nz(_atr, topVal * 0.002) * 0.5
                float bridgeY = topVal + offset
                int tick = math.max(1, math.round(gap / 10))

                // Tick at pivot 1
                line.new(prevPH_bar - tick, prevPH, prevPH_bar + tick, prevPH, color=bearClr, width=lnWidth)
                // Vertical up from pivot 1
                line.new(prevPH_bar, prevPH, prevPH_bar, bridgeY, color=bearClr, width=lnWidth)
                // Horizontal bridge
                line.new(prevPH_bar, bridgeY, currPH_bar, bridgeY, color=bearClr, width=lnWidth)
                // Vertical down to pivot 2
                line.new(currPH_bar, bridgeY, currPH_bar, currPH, color=bearClr, width=lnWidth)
                // Tick at pivot 2
                line.new(currPH_bar - tick, currPH, currPH_bar + tick, currPH, color=bearClr, width=lnWidth)

                if showLabel
                    label.new(math.round((prevPH_bar + currPH_bar) / 2), bridgeY, "SMT",
                         color=color.new(color.white, 100), textcolor=bearClr,
                         style=label.style_none, size=size.tiny)
            else
                // Not an SMT — draw unused line if enabled
                if showUnused
                    line.new(prevPH_bar, prevPH, currPH_bar, currPH,
                         color=unusedClr, width=1, style=line.style_dashed)
        else if showUnused and gap > 0
            line.new(prevPH_bar, prevPH, currPH_bar, currPH,
                 color=unusedClr, width=1, style=line.style_dashed)
    else if showUnused and not na(prevPH)
        line.new(prevPH_bar, prevPH, currPH_bar, currPH,
             color=unusedClr, width=1, style=line.style_dashed)

// ─── When a pivot LOW is found ──────────────────────────────────────────────
if not na(pl)
    // Shift current → previous
    prevPL       := currPL
    prevPL_bar   := currPL_bar
    prevPL_comp2 := currPL_comp2
    prevPL_comp3 := currPL_comp3

    // Record new pivot
    currPL     := pl
    currPL_bar := bar_index - rightBars
    
    // Find the comparison symbol 1's low around the exact pivot bar
    float cLow2 = sym2L[rightBars]
    for i = math.max(0, rightBars - compTol) to (rightBars + compTol)
        cLow2 := math.min(cLow2, sym2L[i])
    currPL_comp2 := cLow2

    // Find the comparison symbol 2's low around the exact pivot bar
    float cLow3 = sym3L[rightBars]
    for i = math.max(0, rightBars - compTol) to (rightBars + compTol)
        cLow3 := math.min(cLow3, sym3L[i])
    currPL_comp3 := cLow3

    // Check for SMT divergence
    if not na(prevPL) and not na(prevPL_comp2)
        int gap = currPL_bar - prevPL_bar
        if gap > 0 and gap <= maxBars
            bool mainLL  = currPL < prevPL
            bool mainHL  = currPL > prevPL
            bool comp2LL = currPL_comp2 < prevPL_comp2
            bool comp2HL = currPL_comp2 > prevPL_comp2
            bool comp3LL = currPL_comp3 < prevPL_comp3
            bool comp3HL = currPL_comp3 > prevPL_comp3

            bool smt2 = (mainLL and comp2HL) or (mainHL and comp2LL)
            bool smt3 = useSym3 and ((mainLL and comp3HL) or (mainHL and comp3LL))

            if smt2 or smt3
                // ═══ BULLISH SMT DETECTED ═══
                bullSMT := true
                bullCount += 1
                lastBullBar := bar_index

                // ─── Draw bracket below the lows ───
                //    ── •         ── •
                //       │            │
                //       ──── SMT ────
                float botVal  = math.min(currPL, prevPL)
                float offset  = nz(_atr, botVal * 0.002) * 0.5
                float bridgeY = botVal - offset
                int tick = math.max(1, math.round(gap / 10))

                // Tick at pivot 1
                line.new(prevPL_bar - tick, prevPL, prevPL_bar + tick, prevPL, color=bullClr, width=lnWidth)
                // Vertical down from pivot 1
                line.new(prevPL_bar, prevPL, prevPL_bar, bridgeY, color=bullClr, width=lnWidth)
                // Horizontal bridge
                line.new(prevPL_bar, bridgeY, currPL_bar, bridgeY, color=bullClr, width=lnWidth)
                // Vertical up to pivot 2
                line.new(currPL_bar, bridgeY, currPL_bar, currPL, color=bullClr, width=lnWidth)
                // Tick at pivot 2
                line.new(currPL_bar - tick, currPL, currPL_bar + tick, currPL, color=bullClr, width=lnWidth)

                if showLabel
                    label.new(math.round((prevPL_bar + currPL_bar) / 2), bridgeY, "SMT",
                         color=color.new(color.white, 100), textcolor=bullClr,
                         style=label.style_none, size=size.tiny)
            else
                // Not an SMT — draw unused line if enabled
                if showUnused
                    line.new(prevPL_bar, prevPL, currPL_bar, currPL,
                         color=unusedClr, width=1, style=line.style_dashed)
        else if showUnused and gap > 0
            line.new(prevPL_bar, prevPL, currPL_bar, currPL,
                 color=unusedClr, width=1, style=line.style_dashed)
    else if showUnused and not na(prevPL)
        line.new(prevPL_bar, prevPL, currPL_bar, currPL,
             color=unusedClr, width=1, style=line.style_dashed)

// ─── Bar coloring ───────────────────────────────────────────────────────────
barcolor(bearSMT ? color.new(bearClr, 30) : na)
barcolor(bullSMT ? color.new(bullClr, 30) : na)

// ─── Dashboard ──────────────────────────────────────────────────────────────
if showDash and barstate.islast
    var table dash = table.new(position.top_right, 3, 4,
         bgcolor=color.new(#1A1A2E, 5), border_color=color.new(#FFFFFF, 85),
         border_width=1, frame_color=color.new(#FFFFFF, 80), frame_width=1)

    table.cell(dash, 0, 0, "SMT ⚡",  text_color=#E0E0E0, text_size=size.small, bgcolor=color.new(#16213E, 5))
    table.cell(dash, 1, 0, "Count",   text_color=#B0BEC5, text_size=size.tiny,  bgcolor=color.new(#16213E, 5))
    table.cell(dash, 2, 0, "Last",    text_color=#B0BEC5, text_size=size.tiny,  bgcolor=color.new(#16213E, 5))

    table.cell(dash, 0, 1, "▼ Bear",  text_color=bearClr, text_size=size.tiny,  bgcolor=color.new(#0F3460, 5))
    table.cell(dash, 1, 1, str.tostring(bearCount), text_color=#E0E0E0, text_size=size.tiny, bgcolor=color.new(#0F3460, 5))
    string bAgo = lastBearBar > 0 ? str.tostring(bar_index - lastBearBar) + "b" : "—"
    table.cell(dash, 2, 1, bAgo,      text_color=#B0BEC5, text_size=size.tiny,  bgcolor=color.new(#0F3460, 5))

    table.cell(dash, 0, 2, "▲ Bull",  text_color=bullClr, text_size=size.tiny,  bgcolor=color.new(#0F3460, 5))
    table.cell(dash, 1, 2, str.tostring(bullCount), text_color=#E0E0E0, text_size=size.tiny, bgcolor=color.new(#0F3460, 5))
    string buAgo = lastBullBar > 0 ? str.tostring(bar_index - lastBullBar) + "b" : "—"
    table.cell(dash, 2, 2, buAgo,     text_color=#B0BEC5, text_size=size.tiny,  bgcolor=color.new(#0F3460, 5))

    table.cell(dash, 0, 3, "Pivot",   text_color=#78909C, text_size=size.tiny,  bgcolor=color.new(#16213E, 5))
    table.cell(dash, 1, 3, str.tostring(leftBars) + "/" + str.tostring(rightBars), text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#16213E, 5))
    table.cell(dash, 2, 3, syminfo.ticker, text_color=#78909C, text_size=size.tiny, bgcolor=color.new(#16213E, 5))

// ─── Alerts ─────────────────────────────────────────────────────────────────
alertcondition(bearSMT, title="Bearish SMT", message="⚠️ Bearish SMT Divergence detected!")
alertcondition(bullSMT, title="Bullish SMT", message="⚠️ Bullish SMT Divergence detected!")
alertcondition(bearSMT or bullSMT, title="Any SMT", message="⚡ SMT Divergence detected!")
````
