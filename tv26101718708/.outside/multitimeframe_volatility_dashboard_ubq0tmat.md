# Multi-Timeframe Volatility Dashboard

- url: https://www.tradingview.com/script/UbQ0tmat-Multi-Timeframe-Volatility-Dashboard/
- type: indicator
- pine_id: PUB;bcbb9a5aeaa54d0095beac5c93a5000c
- version: 1.0

## Description

A clean, observation-only panel showing 6 key implied volatility indices plus the VVIX/VIX ratio in a single overlay. Built for traders who want to see the broader volatility regime at a glance without loading multiple charts.

Indices displayed:
- VIX — S&P 500 implied volatility
- VVIX — Volatility of VIX (vol-of-vol)
- MOVE — Treasury bond implied volatility
- VXN — Nasdaq 100 implied volatility
- OVX — Crude oil implied volatility
- GVZ — Gold implied volatility
- VVIX/VIX — Derived ratio (forward vol expectation proxy)

Features:
- Toggle individual indices on/off
- Color-coded by historical level (green below median, red elevated)
- Daily change indicator with percentage
- 5 panel positions, 4 text sizes

This is an observation tool, not a strategy. It displays vol data; how you use it is up to you. All data is end-of-day from CBOE and TVC public feeds.

Free. MIT licensed. Pull requests welcome on GitHub.

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Timeframe Volatility Dashboard
// =============================================================================
// A clean, observation-only panel showing key implied volatility indices
// across multiple asset classes. Useful for any trader who wants to see
// the broader volatility regime at a glance.
//
// Indices displayed:
//   VIX       — S&P 500 implied volatility
//   VVIX      — Volatility of VIX (vol-of-vol)
//   MOVE      — Treasury bond implied volatility
//   VXN       — Nasdaq 100 implied volatility
//   OVX       — Crude oil implied volatility
//   GVZ       — Gold implied volatility
//   VVIX/VIX  — Derived ratio (forward vol expectation)
//
// All data is end-of-day from CBOE / TVC public feeds. This indicator does
// not generate signals or trade decisions — it is purely a visualization
// to help you understand the volatility environment you are trading in.
//
// Author: Justin M
// License: MIT
// =============================================================================

indicator("Multi-Timeframe Volatility Dashboard", "MTF Vol Panel", overlay=true)

// =============================================================================
// INPUTS
// =============================================================================
grp_display = "Display"
showVIX  = input.bool(true,  "Show VIX (S&P)",      group=grp_display)
showVVIX = input.bool(true,  "Show VVIX (Vol of Vol)", group=grp_display)
showMOVE = input.bool(true,  "Show MOVE (Treasury)", group=grp_display)
showVXN  = input.bool(true,  "Show VXN (Nasdaq)",    group=grp_display)
showOVX  = input.bool(true,  "Show OVX (Oil)",       group=grp_display)
showGVZ  = input.bool(true,  "Show GVZ (Gold)",      group=grp_display)
showRatio = input.bool(true, "Show VVIX/VIX Ratio",  group=grp_display)

grp_style = "Style"
panel_pos = input.string("Top Right", "Panel Position",
    options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"],
    group=grp_style)
text_size = input.string("Normal", "Text Size",
    options=["Tiny", "Small", "Normal", "Large"],
    group=grp_style)
show_change = input.bool(true, "Show Daily Change", group=grp_style)
show_levels = input.bool(true, "Color-code by Level", group=grp_style,
    tooltip="Colors VIX/VVIX/etc green when below historical median, red when elevated.")

// =============================================================================
// DATA — All public CBOE / TVC feeds, daily timeframe (no repaint)
// =============================================================================
// Using lookahead_off + [1] indexing pattern for safety against any signal use.
// For pure observation this is conservative but correct.

f_get(sym) =>
    request.security(sym, "D", close, barmerge.gaps_off, barmerge.lookahead_off)

f_get_prev(sym) =>
    request.security(sym, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

vix      = showVIX  ? f_get("CBOE:VIX")      : na
vix_prev = showVIX  ? f_get_prev("CBOE:VIX") : na

vvix      = showVVIX ? f_get("CBOE:VVIX")      : na
vvix_prev = showVVIX ? f_get_prev("CBOE:VVIX") : na

move      = showMOVE ? f_get("TVC:MOVE")       : na
move_prev = showMOVE ? f_get_prev("TVC:MOVE")  : na

vxn      = showVXN  ? f_get("CBOE:VXN")      : na
vxn_prev = showVXN  ? f_get_prev("CBOE:VXN") : na

ovx      = showOVX  ? f_get("CBOE:OVX")      : na
ovx_prev = showOVX  ? f_get_prev("CBOE:OVX") : na

gvz      = showGVZ  ? f_get("CBOE:GVZ")      : na
gvz_prev = showGVZ  ? f_get_prev("CBOE:GVZ") : na

ratio      = (showRatio and showVIX and showVVIX) ? vvix / vix : na
ratio_prev = (showRatio and showVIX and showVVIX) ? vvix_prev / vix_prev : na

// =============================================================================
// HISTORICAL CONTEXT — rough median levels for color-coding
// =============================================================================
// These are conservative, publicly-known long-run levels. Useful for at-a-glance
// regime sense, not for any strategy filter.
vix_med  = 17.0
vvix_med = 95.0
move_med = 90.0
vxn_med  = 22.0
ovx_med  = 35.0
gvz_med  = 16.0
ratio_med = 5.5

// =============================================================================
// FORMATTING
// =============================================================================
f_fmt(v) => str.tostring(v, "#.##")

f_chg_str(curr, prev) =>
    chg = curr - prev
    pct = prev != 0 ? (chg / prev) * 100 : 0
    sign = chg >= 0 ? "+" : ""
    str.format("{0}{1} ({2}{3,number,#.##}%)", sign, f_fmt(chg), sign, pct)

f_level_color(v, med) =>
    if not show_levels or na(v)
        color.new(color.gray, 30)
    else if v < med * 0.75
        color.new(color.green, 30)
    else if v < med
        color.new(color.green, 50)
    else if v < med * 1.25
        color.new(color.orange, 40)
    else
        color.new(color.red, 30)

f_chg_color(curr, prev) =>
    chg = curr - prev
    chg >= 0 ? color.new(color.red, 50) : color.new(color.green, 50)

text_sz = text_size == "Tiny" ? size.tiny : text_size == "Small" ? size.small : text_size == "Large" ? size.large : size.normal

pos = panel_pos == "Top Right" ? position.top_right :
      panel_pos == "Top Left" ? position.top_left :
      panel_pos == "Bottom Right" ? position.bottom_right :
      panel_pos == "Bottom Left" ? position.bottom_left :
      position.middle_right

// =============================================================================
// BUILD TABLE
// =============================================================================
var table panel = table.new(pos, columns=3, rows=8, border_width=1)

if barstate.islast
    // Header row
    table.cell(panel, 0, 0, "Index",  bgcolor=color.new(color.gray, 10), text_color=color.white, text_size=text_sz)
    table.cell(panel, 1, 0, "Value",  bgcolor=color.new(color.gray, 10), text_color=color.white, text_size=text_sz)
    table.cell(panel, 2, 0, show_change ? "Daily Δ" : "Level", bgcolor=color.new(color.gray, 10), text_color=color.white, text_size=text_sz)

    row = 1

    if showVIX
        table.cell(panel, 0, row, "VIX",         bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(vix),    bgcolor=f_level_color(vix, vix_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(vix, vix_prev), bgcolor=f_chg_color(vix, vix_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showVVIX
        table.cell(panel, 0, row, "VVIX",        bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(vvix),   bgcolor=f_level_color(vvix, vvix_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(vvix, vvix_prev), bgcolor=f_chg_color(vvix, vvix_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showMOVE
        table.cell(panel, 0, row, "MOVE",        bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(move),   bgcolor=f_level_color(move, move_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(move, move_prev), bgcolor=f_chg_color(move, move_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showVXN
        table.cell(panel, 0, row, "VXN",         bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(vxn),    bgcolor=f_level_color(vxn, vxn_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(vxn, vxn_prev), bgcolor=f_chg_color(vxn, vxn_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showOVX
        table.cell(panel, 0, row, "OVX",         bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(ovx),    bgcolor=f_level_color(ovx, ovx_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(ovx, ovx_prev), bgcolor=f_chg_color(ovx, ovx_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showGVZ
        table.cell(panel, 0, row, "GVZ",         bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(gvz),    bgcolor=f_level_color(gvz, gvz_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(gvz, gvz_prev), bgcolor=f_chg_color(gvz, gvz_prev), text_color=color.white, text_size=text_sz)
        row += 1

    if showRatio and showVIX and showVVIX
        table.cell(panel, 0, row, "VVIX/VIX",    bgcolor=color.new(color.black, 30), text_color=color.white, text_size=text_sz)
        table.cell(panel, 1, row, f_fmt(ratio),  bgcolor=f_level_color(ratio, ratio_med), text_color=color.white, text_size=text_sz)
        table.cell(panel, 2, row, f_chg_str(ratio, ratio_prev), bgcolor=f_chg_color(ratio, ratio_prev), text_color=color.white, text_size=text_sz)
````
