# ATR Range Adaptive 

- url: https://www.tradingview.com/script/Of3aHVZw-atr-range-adaptive/
- type: indicator
- pine_id: PUB;f86ebd397861432c9ee6d4f11a62c7d8
- version: 2.0

## Description

ATR Range Adaptive — TF-adaptive volatility bands with dashboard.

A precision volatility tool that projects the statistical extent of a "normal" bar move as five horizontal levels around the previous close — and recalculates automatically on whatever timeframe you're viewing.

How it works:
Add the indicator once. From the previous closed bar of the current chart timeframe it draws the middle line (previous close) plus four ATR-multiplied bands — ±0.5 × ATR and ±1.0 × ATR. Switch to 1H → hourly levels. Switch to 5M → 5-minute levels. No presets to change.

What it shows:
- Previous close as the anchor (middle line)
- +100% band (upper strong resistance) at previous close + 1 × ATR
- +50%  band (intermediate resistance) at previous close + 0.5 × ATR
- -50%  band (intermediate support)   at previous close - 0.5 × ATR
- -100% band (lower strong support)   at previous close - 1 × ATR
- Corner dashboard: current TF, previous close, 1 ATR as a percentage of price, and each level's value + distance from the live price

Key features:
- Fully TF-adaptive: no fixed daily/monthly assumption — bands follow the chart's timeframe
- Selectable ATR smoothing: RMA (Wilder), EMA, SMA, WMA
- Adjustable ATR length and multiplier
- Level lines extend a configurable number of bars to the right
- Middle line can be toggled independently of the ATR bands
- Dashboard: 6 anchor positions, 4 text sizes, adjustable cell transparency
- Full color palette for each band + header and text
- Tooltip on "1 ATR, %" explains volatility bands (low / normal / elevated / high)
- Clean overlay: only 5 lines and 1 dashboard, no chart clutter

Who it's for:
Traders who want a fast, timeframe-aware read on how far price has already stretched from the previous close — and where a "normal" move statistically ends. Useful for intraday range trading, scalping around ATR extremes, sizing stops, and spotting bars that break out of typical volatility.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
// ATR Range Adaptive | TF-adaptive with dashboard
//
// HOW TO USE:
//   1. Add the indicator to any chart / timeframe
//   2. Levels ±0.5 × ATR and ±1.0 × ATR are drawn from the previous close
//   3. Corner dashboard shows current TF, previous close, 1 ATR (%),
//      each level value and its distance to the current price
//
// IDEA:
//   Price on average travels about one ATR per bar. The ±100% band marks
//   the statistical extent of a "normal" move — a decisive break beyond
//   it is usually momentum, not noise.
//
// Unlike the original (which was always computed on 1D/1M),
// this version recalculates on the CHART timeframe automatically:
// switch to 1H → levels are hourly, switch to 5M → levels are 5-min.
// ─────────────────────────────────────────────────────────────
indicator(title           = "ATR Range Adaptive",
          shorttitle      = "ATR Range",
          overlay         = true,
          max_lines_count = 50)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

var G1 = "ATR Settings"
length    = input.int(14, "ATR Length", minval=1, group=G1,
     tooltip="Lookback window for ATR. 14 is the Welles Wilder default.")
smoothing = input.string("EMA", "Smoothing", options=["RMA","SMA","EMA","WMA"], group=G1,
     tooltip="Smoothing method for True Range. RMA — original Wilder, EMA — reacts faster, SMA — slowest, WMA — weighted.")
mult      = input.float(1.0, "ATR Multiplier", step=0.1, minval=0.1, group=G1,
     tooltip="Band multiplier. 1.0 = classic ATR channel around the previous close.")

var G2 = "Lines"
showLines  = input.bool(true, "Show lines on chart", group=G2,
     tooltip="Draw the five horizontal levels (previous close, ±0.5 ATR, ±1.0 ATR) on the chart.")
showClose  = input.bool(true, "Show previous close line", group=G2,
     tooltip="Toggle the middle line (previous bar close) separately from the four ATR bands.")
extendBars = input.int(50, "Line length to the right (bars)", minval=5, maxval=500, group=G2,
     tooltip="How many bars to the right the level lines extend from the current bar.")

var G3 = "Dashboard"
showTbl    = input.bool(true, "Show dashboard table", group=G3,
     tooltip="Show the corner summary table with TF, previous close, 1 ATR (%), each level and its distance from the current price.")
dashLoc    = input.string("Bottom Right", "Position",
     options=["Top Right","Bottom Right","Top Left","Bottom Left","Middle Right","Bottom Center"], group=G3,
     tooltip="Where the dashboard table is anchored on the chart.")
textSize   = input.string("Small", "Size",
     options=["Tiny","Small","Normal","Large"], group=G3,
     tooltip="Font size for the dashboard cells.")
cellTransp = input.int(10, "Cell Transparency", minval=0, maxval=100, group=G3,
     tooltip="Transparency of dashboard cell backgrounds. 0 = solid, 100 = fully transparent.")

var G4 = "Colors"
cBearStrong = input.color(color.new(#7a1414, 0), "+100% (strong resistance)", group=G4,
     tooltip="Color of the upper band (+1.0 × ATR) and its dashboard cells. Marks the statistical extent of a normal upward move.")
cBearSoft   = input.color(color.new(#d94747, 0), "+50%  (resistance)",        group=G4,
     tooltip="Color of the +0.5 × ATR band and its dashboard cells. Intermediate upside target.")
cMid        = input.color(color.new(#9e9e9e, 0), "Previous close (mid)",      group=G4,
     tooltip="Color of the middle line — the closing price of the previous bar.")
cBullSoft   = input.color(color.new(#4cb377, 0), "-50%  (support)",           group=G4,
     tooltip="Color of the -0.5 × ATR band and its dashboard cells. Intermediate downside target.")
cBullStrong = input.color(color.new(#0b6e4f, 0), "-100% (strong support)",    group=G4,
     tooltip="Color of the lower band (-1.0 × ATR) and its dashboard cells. Marks the statistical extent of a normal downward move.")
cHdr        = input.color(color.new(#1e222d, 0), "Table header background",   group=G4,
     tooltip="Background color for the header row and the TF / Close / 1 ATR% cells of the dashboard.")
cTxt        = input.color(color.new(#e6e6e6, 0), "Table text",                group=G4,
     tooltip="Text color used across all dashboard cells.")

// ═══════════════════════════════════════════════════════════════
// ATR — CALCULATED ON THE CURRENT CHART TIMEFRAME
// ═══════════════════════════════════════════════════════════════

// Selectable smoothing wrapper. Kept as a small helper so that TR (with
// gap handling) can be smoothed with any of the four standard methods.
ma_function(float src, int len) =>
    switch smoothing
        "RMA" => ta.rma(src, len)
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        =>       ta.wma(src, len)

atr = ma_function(ta.tr(true), length) * mult

// Bands are anchored to the PREVIOUS CLOSED bar of the current TF —
// this keeps the levels stable within a live bar and matches the way
// most traders "measure" a session (from the last completed close).
prevClose = close[1]
prevAtr   = atr[1]

P100 = prevClose + prevAtr
P050 = prevClose + prevAtr * 0.5
M050 = prevClose - prevAtr * 0.5
M100 = prevClose - prevAtr

// Distance from the current price to each level (positive = the level is
// away from price in its side's direction).
P100diff = P100 - close
P050diff = P050 - close
M050diff = close - M050
M100diff = close - M100

// 1 × ATR expressed as a percentage of price — how much the instrument
// on average travels within a single bar of the current TF.
atrPct = prevClose != 0 ? prevAtr / prevClose * 100.0 : na

// ═══════════════════════════════════════════════════════════════
// LINES
// ═══════════════════════════════════════════════════════════════

var line lnClose = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=1, color=cMid,         extend=extend.right)
var line lnP100  = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=2, color=cBearStrong, extend=extend.right)
var line lnP050  = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=1, color=cBearSoft,   extend=extend.right)
var line lnM050  = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=1, color=cBullSoft,   extend=extend.right)
var line lnM100  = line.new(na, na, na, na, xloc=xloc.bar_index, style=line.style_solid, width=2, color=cBullStrong, extend=extend.right)

// Only reposition the lines on the last bar. Pine re-evaluates ATR / close
// every bar, so a single update on barstate.islast is enough for both live
// and historical repaints.
if showLines and barstate.islast
    x1 = bar_index
    x2 = bar_index + extendBars
    if showClose
        line.set_xy1(lnClose, x1, prevClose), line.set_xy2(lnClose, x2, prevClose)
    else
        line.set_xy1(lnClose, na, na),         line.set_xy2(lnClose, na, na)
    line.set_xy1(lnP100, x1, P100), line.set_xy2(lnP100, x2, P100)
    line.set_xy1(lnP050, x1, P050), line.set_xy2(lnP050, x2, P050)
    line.set_xy1(lnM050, x1, M050), line.set_xy2(lnM050, x2, M050)
    line.set_xy1(lnM100, x1, M100), line.set_xy2(lnM100, x2, M100)

// ═══════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════

// Map dashboard position string to a Pine `position` constant.
f_pos(string s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

// Map size string to Pine `size` constant.
f_sz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        =>          size.large

// Readable TF label for the header (converts "60" → "1H", "240" → "4H", etc.)
f_tfLabel() =>
    switch timeframe.period
        "1"    => "1m"
        "3"    => "3m"
        "5"    => "5m"
        "15"   => "15m"
        "30"   => "30m"
        "45"   => "45m"
        "60"   => "1H"
        "120"  => "2H"
        "180"  => "3H"
        "240"  => "4H"
        "360"  => "6H"
        "480"  => "8H"
        "720"  => "12H"
        "D"    => "1D"
        "W"    => "1W"
        "M"    => "1M"
        =>        timeframe.period

f_fmt(float v) => na(v) ? "—" : str.tostring(v, "#.#####")

var table tbl = table.new(position.bottom_right, 8, 3,
     frame_color  = color.new(#000000, 0), frame_width = 1,
     border_color = color.new(#000000, 0), border_width = 1)

if showTbl and barstate.islast
    table.delete(tbl)
    tbl := table.new(f_pos(dashLoc), 7, 3,
         frame_color  = color.new(#000000, 0), frame_width = 1,
         border_color = color.new(#000000, 0), border_width = 1)
    sz = f_sz(textSize)

    atrPctTooltip = "1 × ATR as a percentage of the previous close. Shows the average bar amplitude on the current TF.\n" +
       "• <0.5% — low volatility\n" +
       "• 0.5–1.5% — normal\n" +
       "• 1.5–3% — elevated\n" +
       "• >3% — high (news, reversal, extreme)"

    // Header row
    table.cell(tbl, 0, 0, "TF",       text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr,        cellTransp))
    table.cell(tbl, 1, 0, "Close",    text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr,        cellTransp))
    table.cell(tbl, 2, 0, "1 ATR, %", text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr,        cellTransp), tooltip=atrPctTooltip)
    table.cell(tbl, 3, 0, "+100%",    text_color=cTxt, text_size=sz, bgcolor=color.new(cBearStrong, cellTransp))
    table.cell(tbl, 4, 0, "+50%",     text_color=cTxt, text_size=sz, bgcolor=color.new(cBearSoft,   cellTransp))
    table.cell(tbl, 5, 0, "-50%",     text_color=cTxt, text_size=sz, bgcolor=color.new(cBullSoft,   cellTransp))
    table.cell(tbl, 6, 0, "-100%",    text_color=cTxt, text_size=sz, bgcolor=color.new(cBullStrong, cellTransp))

    // TF / Close / 1 ATR% — single value, spans rows 1 & 2 (no diff row).
    table.cell(tbl, 0, 1, f_tfLabel(),      text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr, cellTransp))
    table.merge_cells(tbl, 0, 1, 0, 2)
    table.cell(tbl, 1, 1, f_fmt(prevClose), text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr, cellTransp))
    table.merge_cells(tbl, 1, 1, 1, 2)
    table.cell(tbl, 2, 1, na(atrPct) ? "—" : str.tostring(atrPct, "#.##") + "%",
         text_color=cTxt, text_size=sz, bgcolor=color.new(cHdr, cellTransp), tooltip=atrPctTooltip)
    table.merge_cells(tbl, 2, 1, 2, 2)

    // Levels: value on row 1, distance to price on row 2.
    table.cell(tbl, 3, 1, f_fmt(P100), text_color=cTxt, text_size=sz, bgcolor=color.new(cBearStrong, cellTransp))
    table.cell(tbl, 4, 1, f_fmt(P050), text_color=cTxt, text_size=sz, bgcolor=color.new(cBearSoft,   cellTransp))
    table.cell(tbl, 5, 1, f_fmt(M050), text_color=cTxt, text_size=sz, bgcolor=color.new(cBullSoft,   cellTransp))
    table.cell(tbl, 6, 1, f_fmt(M100), text_color=cTxt, text_size=sz, bgcolor=color.new(cBullStrong, cellTransp))

    table.cell(tbl, 3, 2, f_fmt(P100diff), text_color=cTxt, text_size=sz, bgcolor=color.new(cBearStrong, cellTransp))
    table.cell(tbl, 4, 2, f_fmt(P050diff), text_color=cTxt, text_size=sz, bgcolor=color.new(cBearSoft,   cellTransp))
    table.cell(tbl, 5, 2, f_fmt(M050diff), text_color=cTxt, text_size=sz, bgcolor=color.new(cBullSoft,   cellTransp))
    table.cell(tbl, 6, 2, f_fmt(M100diff), text_color=cTxt, text_size=sz, bgcolor=color.new(cBullStrong, cellTransp))
````
