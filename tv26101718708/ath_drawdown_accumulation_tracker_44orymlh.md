# ATH Drawdown Accumulation Tracker

- url: https://www.tradingview.com/script/44OrYMLH-ATH-Drawdown-Accumulation-Tracker/
- type: indicator
- pine_id: PUB;1ff5b86ee53b4182b1aeedc02d6ebce7
- version: 1.0

## Description

Tracks drawdown from all-time high and identifies accumulation zones based on correction depth. Includes optional 9/20/50/100/200 EMAs, EMA distance tracking, trend state, ATH level, background zone coloring, alerts, and a compact table to support disciplined long-term buying decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("ATH Drawdown Accumulation Tracker", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

grp_ema      = "EMA Settings"
showEMAs     = input.bool(true,  "Show All EMAs (Master Toggle)", group=grp_ema)
show9        = input.bool(true,  "  └─ Show 9 EMA",              group=grp_ema)
show20       = input.bool(true,  "  └─ Show 20 EMA",             group=grp_ema)
show50       = input.bool(true,  "  └─ Show 50 EMA",             group=grp_ema)
show100      = input.bool(true,  "  └─ Show 100 EMA",            group=grp_ema)
show200      = input.bool(true,  "  └─ Show 200 EMA",            group=grp_ema)
showEmaLabels = input.bool(true, "  └─ Show EMA Price Labels",   group=grp_ema)

grp_tbl      = "Table Settings"
showTable    = input.bool(true, "Show Table", group=grp_tbl)
tblPos       = input.string("Bottom Right", "Table Position",
                 options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"],
                 group=grp_tbl)
tblSize      = input.string("Small", "Table Size",
                 options=["Small","Normal","Large"], group=grp_tbl)

// ─────────────────────────────────────────────────────────────────────────────
// EMA CALCULATIONS (always computed for distances)
// ─────────────────────────────────────────────────────────────────────────────

ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// ─────────────────────────────────────────────────────────────────────────────
// EMA COLORS — high contrast, easy to distinguish on any theme
// ─────────────────────────────────────────────────────────────────────────────

col9   = color.new(#FFEB3B, 0)  // bright yellow
col20  = color.new(#00E5FF, 0)  // cyan
col50  = color.new(#00E676, 0)  // green
col100 = color.new(#E040FB, 0)  // magenta
col200 = color.new(#FF5252, 0)  // red

// ─────────────────────────────────────────────────────────────────────────────
// EMA PLOTS — thicker lines for visibility
// ─────────────────────────────────────────────────────────────────────────────

plot(showEMAs and show9   ? ema9   : na, "9 EMA",   color=col9,   linewidth=2)
plot(showEMAs and show20  ? ema20  : na, "20 EMA",  color=col20,  linewidth=2)
plot(showEMAs and show50  ? ema50  : na, "50 EMA",  color=col50,  linewidth=3)
plot(showEMAs and show100 ? ema100 : na, "100 EMA", color=col100, linewidth=3)
plot(showEMAs and show200 ? ema200 : na, "200 EMA", color=col200, linewidth=4)

// ─────────────────────────────────────────────────────────────────────────────
// EMA PRICE LABELS — right-edge labels so you know which line is which
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast and showEMAs and showEmaLabels
    int xPos = bar_index + 3
    if show9
        lbl9 = label.new(xPos, ema9, "EMA 9", xloc.bar_index, yloc.price, color.new(col9, 85), label.style_label_left, col9, size.small)
        label.delete(lbl9[1])
    if show20
        lbl20 = label.new(xPos, ema20, "EMA 20", xloc.bar_index, yloc.price, color.new(col20, 85), label.style_label_left, col20, size.small)
        label.delete(lbl20[1])
    if show50
        lbl50 = label.new(xPos, ema50, "EMA 50", xloc.bar_index, yloc.price, color.new(col50, 85), label.style_label_left, col50, size.small)
        label.delete(lbl50[1])
    if show100
        lbl100 = label.new(xPos, ema100, "EMA 100", xloc.bar_index, yloc.price, color.new(col100, 85), label.style_label_left, col100, size.small)
        label.delete(lbl100[1])
    if show200
        lbl200 = label.new(xPos, ema200, "EMA 200", xloc.bar_index, yloc.price, color.new(col200, 85), label.style_label_left, col200, size.small)
        label.delete(lbl200[1])

// ─────────────────────────────────────────────────────────────────────────────
// ALL-TIME HIGH TRACKING
// ─────────────────────────────────────────────────────────────────────────────

var float athPrice = na
var int   athBar   = na

if na(athPrice) or high > athPrice
    athPrice := high
    athBar   := bar_index

athDate = str.format("{0,date,dd MMM yyyy}", time[bar_index - athBar])

// ─────────────────────────────────────────────────────────────────────────────
// DRAWDOWN & ZONE
// ─────────────────────────────────────────────────────────────────────────────

drawdownPct = ((athPrice - close) / athPrice) * 100

string zoneText = ""
if drawdownPct < 5
    zoneText := "No Action"
else if drawdownPct < 10
    zoneText := "Small Tranche"
else if drawdownPct < 15
    zoneText := "Medium Tranche"
else if drawdownPct < 20
    zoneText := "Large Tranche"
else
    zoneText := "Aggressive Accum."

color zoneColor = color.new(#78909C, 0)
if drawdownPct < 5
    zoneColor := color.new(#78909C, 0)
else if drawdownPct < 10
    zoneColor := color.new(#4CAF50, 0)
else if drawdownPct < 15
    zoneColor := color.new(#FF9800, 0)
else if drawdownPct < 20
    zoneColor := color.new(#F44336, 0)
else
    zoneColor := color.new(#9C27B0, 0)

// ─────────────────────────────────────────────────────────────────────────────
// TREND STATE
// ─────────────────────────────────────────────────────────────────────────────

string trendState = "Neutral"
if close > ema50 and ema50 > ema200
    trendState := "▲ Bullish"
else if close < ema50 and close > ema200
    trendState := "▽ Weakening"
else if close < ema200
    trendState := "▼ Bearish"
else if close > ema50 and ema50 < ema200
    trendState := "△ Recovery"

color trendColor = color.gray
if trendState == "▲ Bullish"
    trendColor := color.new(#00E676, 0)
else if trendState == "▽ Weakening"
    trendColor := color.new(#FFD600, 0)
else if trendState == "▼ Bearish"
    trendColor := color.new(#FF1744, 0)
else if trendState == "△ Recovery"
    trendColor := color.new(#2979FF, 0)

// ─────────────────────────────────────────────────────────────────────────────
// EMA DISTANCES
// ─────────────────────────────────────────────────────────────────────────────

dist9   = ((close - ema9)   / ema9)   * 100
dist20  = ((close - ema20)  / ema20)  * 100
dist50  = ((close - ema50)  / ema50)  * 100
dist100 = ((close - ema100) / ema100) * 100
dist200 = ((close - ema200) / ema200) * 100

// ─────────────────────────────────────────────────────────────────────────────
// TABLE POSITION & SIZE
// ─────────────────────────────────────────────────────────────────────────────

var string posResult = position.bottom_right
if tblPos == "Top Left"
    posResult := position.top_left
else if tblPos == "Top Right"
    posResult := position.top_right
else if tblPos == "Bottom Left"
    posResult := position.bottom_left
else if tblPos == "Bottom Right"
    posResult := position.bottom_right
else if tblPos == "Middle Left"
    posResult := position.middle_left
else
    posResult := position.middle_right

var string sizeResult = size.small
if tblSize == "Small"
    sizeResult := size.small
else if tblSize == "Normal"
    sizeResult := size.normal
else if tblSize == "Large"
    sizeResult := size.large

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

fmtDist(float val) =>
    (val >= 0 ? "+" : "") + str.tostring(val, "#.##") + "%"

distCol(float val) =>
    val >= 0 ? color.new(#00E676, 0) : color.new(#FF5252, 0)

// ─────────────────────────────────────────────────────────────────────────────
// STATUS TABLE — compact 3-column layout
// ─────────────────────────────────────────────────────────────────────────────

var table t = table(na)
if showTable
    t := table.new(posResult, 3, 12, bgcolor=color.new(#131722, 5), border_color=color.new(#2A2E39, 0), border_width=1, frame_color=color.new(#363A45, 0), frame_width=1)

if barstate.islast and showTable

    // Row 0: Header
    table.cell(t, 0, 0, "  ACCUMULATION TRACKER  ", text_color=color.white, text_size=sizeResult, bgcolor=color.new(#1565C0, 0), text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 2, 0)

    // Row 1: Price
    table.cell(t, 0, 1, "Price", text_color=color.new(#9E9E9E, 0), text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(close, format.mintick), text_color=color.white, text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 1, "", text_size=sizeResult)

    // Row 2: ATH + date
    table.cell(t, 0, 2, "ATH", text_color=color.new(#9E9E9E, 0), text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 2, str.tostring(athPrice, format.mintick), text_color=color.new(#FFD740, 0), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 2, athDate, text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

    // Row 3: Drawdown + zone badge
    table.cell(t, 0, 3, "Drawdown", text_color=color.new(#9E9E9E, 0), text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 3, str.tostring(drawdownPct, "#.##") + "%", text_color=zoneColor, text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 3, zoneText, text_color=color.white, text_size=sizeResult, text_halign=text.align_right, bgcolor=zoneColor)

    // Row 4: Trend
    table.cell(t, 0, 4, "Trend", text_color=color.new(#9E9E9E, 0), text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 4, trendState, text_color=trendColor, text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 4, "", text_size=sizeResult)

    // Row 5: Section divider
    table.cell(t, 0, 5, "EMA DISTANCES", text_color=color.new(#616161, 0), text_size=sizeResult, bgcolor=color.new(#1E222D, 0), text_halign=text.align_center)
    table.merge_cells(t, 0, 5, 2, 5)

    // Row 6-10: EMA distances — colored dot matches the plot line
    table.cell(t, 0, 6, "●  9", text_color=col9, text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 6, fmtDist(dist9), text_color=distCol(dist9), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 6, str.tostring(ema9, format.mintick), text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

    table.cell(t, 0, 7, "●  20", text_color=col20, text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 7, fmtDist(dist20), text_color=distCol(dist20), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 7, str.tostring(ema20, format.mintick), text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

    table.cell(t, 0, 8, "●  50", text_color=col50, text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 8, fmtDist(dist50), text_color=distCol(dist50), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 8, str.tostring(ema50, format.mintick), text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

    table.cell(t, 0, 9, "●  100", text_color=col100, text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 9, fmtDist(dist100), text_color=distCol(dist100), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 9, str.tostring(ema100, format.mintick), text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

    table.cell(t, 0, 10, "●  200", text_color=col200, text_size=sizeResult, text_halign=text.align_left)
    table.cell(t, 1, 10, fmtDist(dist200), text_color=distCol(dist200), text_size=sizeResult, text_halign=text.align_right)
    table.cell(t, 2, 10, str.tostring(ema200, format.mintick), text_color=color.new(#757575, 0), text_size=sizeResult, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ZONE BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

color zoneBg = na
if drawdownPct >= 20
    zoneBg := color.new(#9C27B0, 90)
else if drawdownPct >= 15
    zoneBg := color.new(#F44336, 92)
else if drawdownPct >= 10
    zoneBg := color.new(#FF9800, 93)
else if drawdownPct >= 5
    zoneBg := color.new(#4CAF50, 94)

bgcolor(zoneBg, title="Zone Background")

// ─────────────────────────────────────────────────────────────────────────────
// ATH LINE
// ─────────────────────────────────────────────────────────────────────────────

plot(athPrice, "All-Time High", color=color.new(#FFD740, 70), style=plot.style_stepline_diamond, linewidth=1)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(ta.crossover(drawdownPct, 5), title="Drawdown Crosses 5%", message="{{ticker}} entered Small Tranche zone (5% drawdown from ATH)")
alertcondition(ta.crossover(drawdownPct, 10), title="Drawdown Crosses 10%", message="{{ticker}} entered Medium Tranche zone (10% drawdown from ATH)")
alertcondition(ta.crossover(drawdownPct, 15), title="Drawdown Crosses 15%", message="{{ticker}} entered Large Tranche zone (15% drawdown from ATH)")
alertcondition(ta.crossover(drawdownPct, 20), title="Drawdown Crosses 20%", message="{{ticker}} entered Aggressive Accumulation zone (20% drawdown from ATH)")
````
