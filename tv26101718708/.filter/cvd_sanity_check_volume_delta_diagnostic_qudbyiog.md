# CVD Sanity Check Volume Delta Diagnostic

- url: https://www.tradingview.com/script/qudbyiOg-CVD-Sanity-Check-Volume-Delta-Diagnostic/
- type: indicator
- pine_id: PUB;9cf70a2ccb114bfc9dc7469f13974efa
- version: 1.0

## Description

═══════════════════════════════════════════════════════════════════════
SUGGESTED PUBLICATION TITLE
═══════════════════════════════════════════════════════════════════════

CVD Sanity Check — Volume Delta Diagnostic

(Short title for chart legend: "CVD Check")


═══════════════════════════════════════════════════════════════════════
SUGGESTED DESCRIPTION (paste into TradingView's publish form)
═══════════════════════════════════════════════════════════════════════

A small diagnostic tool for Pine Script developers and traders who
want to verify whether ta.requestVolumeDelta() actually works on a
given symbol and timeframe BEFORE building anything that depends on it.

█ THE PROBLEM THIS SOLVES

TradingView's requestVolumeDelta() function (from the official
TradingView/ta library) is incredibly useful for estimating buyer vs
seller pressure from intrabar volume data. But it has a catch: not
every symbol on TradingView exposes intrabar volume.

Forex pairs, CFDs, some indexes, and certain low-liquidity instruments
silently return `na` or all-zero values. If you're building a serious
indicator on top of CVD logic — order flow tools, volume-weighted zone
scoring, delta-confirmed signals — you want to know that BEFORE you
spend hours debugging why your indicator looks empty on certain charts.

This script tells you in three seconds.

█ HOW TO USE

1. Add to chart on the symbol + timeframe you care about
2. Look at the diagnostic table top-right
3. Look at the chart pane: green/red histogram + aqua line

Status meanings:
  ✅ Working      → real data, build away
  ⚠ All zeros    → symbol doesn't expose intrabar volume
  ❌ NA           → symbol/TF combo entirely unsupported

█ WHAT YOU SEE ON CHART

• Green/red histogram columns — per-bar volume delta. Green = buyers
  dominated that bar's flow, red = sellers dominated.
• Aqua line — cumulative volume delta since the last reset (default
  daily reset). Trending up = net buying pressure period. Trending
  down = net selling pressure period.
• Zero line — gray dashed reference.

█ INPUTS

• Lower timeframe — granularity for delta calculation. "1" (1-minute)
  is the safest default. Seconds-based options ("1S" through "30S")
  give finer resolution but may not work on all symbols/plans.
• Cumulative reset period — when the CVD line resets to zero.
  "1D" (default) is the standard daily reset most traders expect.

█ NOTES

This is a TEST/DIAGNOSTIC tool, not a trading indicator. It does one
thing: tells you whether CVD data is available on your symbol. If you
want a polished CVD indicator with anchoring, divergences, and
analysis features, look elsewhere — there are many published.

█ CREDITS

Uses the TradingView/ta library (MPL-2.0) for requestVolumeDelta().
Library reference:
https://www.tradingview.com/script/BICzyhq0-ta/

Released under MPL-2.0. Free to use, modify, redistribute. Attribution
appreciated.

═══════════════════════════════════════════════════════════════════════
SUGGESTED CATEGORIES / TAGS
═══════════════════════════════════════════════════════════════════════

Categories:
  • Volume — primary
  • Pine utility / Other — secondary

Tags:
  cvd, volume-delta, diagnostic, order-flow, sanity-check, utility,
  developer-tool, requestVolumeDelta, intrabar-volume

═══════════════════════════════════════════════════════════════════════
PUBLICATION SETTINGS
═══════════════════════════════════════════════════════════════════════

Visibility: Open-source (recommended — utility scripts work best as
            community resources)

License: MPL-2.0 (already set in code header)

Chart: Make sure you have a clean chart with the indicator running on
       a recognizable symbol (BTCUSDT.P or SPY both work well) when you
       click "Publish Script". The screenshot taken at that moment
       becomes the publication's preview image.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © D_Rebellionaire
//
// Uses TradingView/ta library (MPL-2.0) — credit to TradingView for requestVolumeDelta.
// Library reference: https://www.tradingview.com/script/BICzyhq0-ta/

//@version=6
indicator("CVD Sanity Check — Volume Delta Diagnostic", shorttitle = "CVD Check", overlay = false, format = format.volume)

// ════════════════════════════════════════════════════════════════════
// PURPOSE
// ════════════════════════════════════════════════════════════════════
// Before building any indicator that depends on ta.requestVolumeDelta(),
// run this on your symbol + timeframe to verify the data is actually
// available. Many forex pairs, CFDs, and exotic instruments silently
// return `na` from CVD — this script tells you immediately whether
// you're getting real data or empty values, saving hours of debugging
// downstream.
//
// HOW TO READ
// • Green/red histogram: per-bar volume delta (buyers vs sellers per bar)
// • Aqua line: cumulative delta since last reset
// • Diagnostic table top-right: status, symbol, settings, latest values
//
// VERDICT GUIDE
// ✅ Working      → CVD data is good, build away
// ⚠ All zeros    → Symbol probably doesn't expose intrabar volume
// ❌ NA           → Symbol/timeframe combo unsupported
// ════════════════════════════════════════════════════════════════════

import TradingView/ta/12 as tvta

// ===== INPUTS =====
ltf_choice = input.string("1", "Lower timeframe for delta",
     options = ["1S", "5S", "10S", "15S", "30S", "1", "3", "5"],
     tooltip = "Granularity used internally to estimate delta. 'S' suffix = seconds (only works on intraday charts and may not work on all symbols/plans). '1' = 1-minute is the safest default and works on virtually all symbols that have intrabar volume data.")

cum_reset = input.string("1D", "Cumulative reset period",
     options = ["1", "60", "240", "1D", "1W", "1M"],
     tooltip = "When the running CVD line resets to zero. '1D' (default) resets at start of each day — most useful for visual analysis. '1W' weekly. '60' hourly. '1' resets every chart bar (gives pure per-bar delta with no cumulative memory).")

// ===== FETCH DELTA =====
// requestVolumeDelta returns a 4-tuple: [openVol, maxVol, minVol, lastVol].
// We use lastVol (the cumulative delta at bar close) as the primary value.
[openVol, maxVol, minVol, lastVol] = tvta.requestVolumeDelta(ltf_choice, cum_reset)

// Per-bar delta = current cumulative minus previous bar's cumulative.
// Gives the green/red histogram showing each bar's directional flow.
per_bar_delta = nz(lastVol) - nz(lastVol[1])

// ===== PLOTS =====
plot(per_bar_delta, "Per-bar Delta",
     color = per_bar_delta >= 0 ? color.new(color.green, 30) : color.new(color.red, 30),
     style = plot.style_columns)

hline(0, "Zero", color = color.gray, linestyle = hline.style_dashed)

plot(lastVol, "Cumulative Delta (CVD)", color = color.new(color.aqua, 0), linewidth = 2)

// ===== DIAGNOSTIC TABLE =====
if barstate.islast
    var table diag = table.new(position.top_right, columns = 2, rows = 8,
         bgcolor = color.new(#1E1E2D, 10),
         frame_color = color.new(#2962FF, 40),
         frame_width = 2,
         border_width = 1,
         border_color = color.new(#4CAF50, 60))

    string status = na(lastVol) ? "❌ NA — symbol/TF doesn't support CVD" :
       lastVol == 0 and per_bar_delta == 0 ? "⚠ All zeros — likely unsupported" :
                                               "✅ Working"

    color statusColor = na(lastVol) or (lastVol == 0 and per_bar_delta == 0) ?
         color.new(color.red, 30) : color.new(color.green, 30)

    table.cell(diag, 0, 0, "CVD Sanity Check", bgcolor = color.new(color.blue, 30), text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 0, "", bgcolor = color.new(color.blue, 30))

    table.cell(diag, 0, 1, "Symbol:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 1, syminfo.tickerid, text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 2, "Chart TF:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 2, timeframe.period, text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 3, "Delta LTF:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 3, ltf_choice, text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 4, "Reset period:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 4, cum_reset, text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 5, "Status:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 5, status, bgcolor = statusColor, text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 6, "Last bar Δ:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 6, na(per_bar_delta) ? "NA" : str.tostring(per_bar_delta, "#.##"), text_color = color.white, text_size = size.small)

    table.cell(diag, 0, 7, "Cumulative CVD:", text_color = color.white, text_size = size.small)
    table.cell(diag, 1, 7, na(lastVol) ? "NA" : str.tostring(lastVol, "#.##"), text_color = color.white, text_size = size.small)
````
