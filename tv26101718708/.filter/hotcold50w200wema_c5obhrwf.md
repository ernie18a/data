# Hot_Cold_50W_200W_EMA

- url: https://www.tradingview.com/script/C5ObHRwf-Hot-Cold-50W-200W-EMA/
- type: indicator
- pine_id: PUB;22d29b86c8f247fdb4552cddcf07e984
- version: 3.0

## Description

A MACD-style oscillator built from trend distance instead of raw EMAs. Instead of comparing two moving averages directly, it compares how far price has stretched from each one — surfacing whether short-term momentum is running ahead of or falling behind the long-term trend.

• Line 1 (orange) — % distance from the 200-week EMA (long-term trend)
• Line 2 (blue) — % distance from the 50-week EMA (short-term trend)
• Histogram — the gap between the two lines, shaded like a classic MACD histogram (full color when the gap is widening, faded when it's contracting)

A zero-line cross in the histogram marks a regime shift: short-term trend either breaking away from or collapsing back toward the long-term trend. Built-in alerts fire on both crossover directions.

Like its companion script (200W EMA Heat), all math runs on weekly bars via request.security() regardless of chart timeframe, with an "Avoid Repaint" toggle (on by default) to keep historical values stable.

Not financial advice — a momentum/regime tool meant to complement, not replace, your own analysis.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © utkarshikha
//@version=6
indicator("EMA Distance MACD (50W / 200W)", shorttitle="Hot_cold_50_200_WEMA", overlay=false, format=format.percent, precision=2)


// ───────────────────────────── Inputs ─────────────────────────────
slowLen         = input.int(200, "Slow EMA Length (weekly bars)", minval=10, group="Calculation")
fastLen         = input.int(50,  "Fast EMA Length (weekly bars)", minval=5,  group="Calculation")
shadeLookback   = input.int(260, "Shade Lookback (weekly bars)", minval=20, group="Calculation", tooltip="Histogram shade depth = how large the current spread is versus this stock's own spreads over the lookback. 260 ≈ 5 years.")
avoidRepaint    = input.bool(true, "Avoid Repaint (use last closed week)", group="Calculation", tooltip="On: every value comes from the last CLOSED weekly bar, so history never repaints — at the cost of being up to one week behind. Off: shows the live, still-forming week (repaints until the week closes).")

shadeSteps      = input.int(6, "Shades per side", minval=2, maxval=10, group="Colors", tooltip="Number of distinct red (above zero) and blue (below zero) histogram shades. Deeper shade = larger spread relative to this stock's history.")
posLight        = input.color(#EF9A9A, "Above zero: light", inline="pos", group="Colors")
posDeep         = input.color(#B71C1C, "deep", inline="pos", group="Colors")
negLight        = input.color(#90CAF9, "Below zero: light", inline="neg", group="Colors")
negDeep         = input.color(#0D47A1, "deep", inline="neg", group="Colors")
fadeContracting = input.bool(true, "Fade bars while spread is narrowing", group="Colors")
line1Color      = input.color(#FF9800, "Line 1: 200W distance", group="Colors")
line2Color      = input.color(#8E24AA, "Line 2: 50W distance", group="Colors")

showTable       = input.bool(true, "Show info table", group="Display")
tablePosIn      = input.string("Top Right", "Table position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")

// ───────────────────────────── Weekly calc (independent of chart timeframe) ─────────────────────────────
f_weekly() =>
    emaSlow     = ta.ema(close, slowLen)
    emaFast     = ta.ema(close, fastLen)
    pctSlow     = (close - emaSlow) / emaSlow * 100   // Line 1: distance from 200W EMA
    pctFast     = (close - emaFast) / emaFast * 100   // Line 2: distance from 50W EMA
    spread      = pctSlow - pctFast                   // > 0 exactly when the 50W EMA is above the 200W EMA
    magRank     = ta.percentrank(math.abs(spread), shadeLookback)
    contracting = math.abs(spread) < math.abs(spread[1])
    sinceCross  = ta.barssince(ta.cross(emaFast, emaSlow))
    off         = avoidRepaint ? 1 : 0
    [pctSlow[off], pctFast[off], spread[off], magRank[off], contracting[off], sinceCross[off], bar_index + 1]

// lookahead_on is safe only because every value above is offset by [1] (TradingView's documented non-repainting pattern).
lookaheadMode = avoidRepaint ? barmerge.lookahead_on : barmerge.lookahead_off
[line1, line2, hist, magRank, contracting, sinceCross, weeklyBars] = request.security(syminfo.tickerid, "W", f_weekly(), barmerge.gaps_off, lookaheadMode)

// ───────────────────────────── Histogram color: red above zero, blue below, deeper = larger spread ─────────────────────────────
// t in [0, 1] picks one of `steps` shades between lightC (t = 0) and deepC (t = 1).
f_shade(t, steps, lightC, deepC) =>
    bucket = math.min(math.floor(t * steps), steps - 1)
    color.from_gradient(float(bucket) / (steps - 1), 0, 1, lightC, deepC)

depth     = nz(magRank, 50) / 100
histBase  = na(hist) ? color(na) : hist >= 0 ? f_shade(depth, shadeSteps, posLight, posDeep) : f_shade(depth, shadeSteps, negLight, negDeep)
histColor = fadeContracting and contracting ? color.new(histBase, 55) : histBase

// ───────────────────────────── Plots ─────────────────────────────
plot(hist,  "Histogram (Line 1 - Line 2)", color=histColor, style=plot.style_columns)
plot(line1, "Line 1: 200W distance", color=line1Color, linewidth=2)
plot(line2, "Line 2: 50W distance",  color=line2Color, linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ───────────────────────────── Info table ─────────────────────────────
f_pct(x) =>
    (x >= 0 ? "+" : "") + str.tostring(x, "0.00") + "%"

// Black text on light shades, white on deep ones.
f_textOn(c) =>
    lum = 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
    lum > 150 ? color.black : color.white

f_cell(tbl, row, label, value, valueColor, valueBg) =>
    table.cell(tbl, 0, row, label, text_color=color.new(chart.fg_color, 35), text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, row, value, text_color=valueColor, bgcolor=valueBg, text_size=size.small, text_halign=text.align_right)

tablePos = switch tablePosIn
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table infoTable = table.new(tablePos, 2, 6, bgcolor=color.new(chart.fg_color, 93), border_width=1, border_color=color.new(chart.fg_color, 85))
if showTable and barstate.islast
    fg = chart.fg_color
    f_cell(infoTable, 0, syminfo.ticker, "EMA Dist MACD", fg, color(na))
    if na(line1)
        f_cell(infoTable, 1, "History", "needs " + str.tostring(slowLen) + " wks (has " + str.tostring(weeklyBars) + ")", fg, color(na))
    else
        f_cell(infoTable, 1, "200W distance", f_pct(line1), line1Color, color(na))
        f_cell(infoTable, 2, "50W distance", f_pct(line2), line2Color, color(na))
        f_cell(infoTable, 3, "Spread", f_pct(hist) + (contracting ? " · narrowing" : " · widening"), f_textOn(histBase), histBase)
        f_cell(infoTable, 4, "Weekly EMAs", (hist >= 0 ? "50W above 200W" : "50W below 200W") + (na(sinceCross) ? "" : " · " + str.tostring(sinceCross) + " wks"), fg, color(na))
    f_cell(infoTable, 5, "Data", avoidRepaint ? "last closed week" : "live week (repaints)", color.new(fg, 40), color(na))

// ───────────────────────────── Alerts ─────────────────────────────
alertcondition(ta.crossover(hist, 0),   "Weekly golden cross (spread above zero)", '{{ticker}}: 50W EMA crossed above 200W EMA. Spread: {{plot("Histogram (Line 1 - Line 2)")}}%')
alertcondition(ta.crossunder(hist, 0),  "Weekly death cross (spread below zero)",  '{{ticker}}: 50W EMA crossed below 200W EMA. Spread: {{plot("Histogram (Line 1 - Line 2)")}}%')
alertcondition(ta.crossover(line1, 0),  "Price crossed above 200W EMA", '{{ticker}} closed the week above its 200W EMA.')
alertcondition(ta.crossunder(line1, 0), "Price crossed below 200W EMA", '{{ticker}} closed the week below its 200W EMA.')
alertcondition(ta.crossover(line2, 0),  "Price crossed above 50W EMA",  '{{ticker}} closed the week above its 50W EMA.')
alertcondition(ta.crossunder(line2, 0), "Price crossed below 50W EMA",  '{{ticker}} closed the week below its 50W EMA.')
````
