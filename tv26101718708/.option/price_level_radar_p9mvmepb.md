# Price Level Radar

- url: https://www.tradingview.com/script/P9mvMePB-Price-Level-Radar/
- type: indicator
- pine_id: PUB;401eab726fde430f8185c9fddbb7548f
- version: 1.0

## Description

A clean, universal tool for tracking up to five custom price levels on any ticker, each with a configurable percentage band and built-in crossing alerts.
Features

5 custom levels — enter your own prices (support/resistance, prior day high/low, VWAP, key strikes, anything). Set any level to 0 to disable it.

Percentage bands — each level draws a center line plus an upper/lower band at ±X% (default 0.5%, adjustable down to 0). Useful for treating a level as a zone rather than a single price.

On-chart dashboard — compact table showing current price and each level's range, with the active band highlighted when price is inside it.

Alerts — 15 individual crossing conditions (each level and both band edges), plus a single consolidated "any alert() call" option so one alert can cover every level.

[b]How to use
[/b]Add to any chart, open settings, and enter your levels. Adjust the band width to taste. To set alerts, create an alert with the condition set to "Price Level Radar" — either pick a specific level/edge, or choose "Any alert() function call" to capture all crossings with one alert.

## Source Code

````pine
// © DashingBixby
// All Rights Reserved
// June 2026

// Price Level Radar (Universal)
// Adapted from Volatility Radar — Levels + 0.5% Bands + Alerts.
// Works on any ticker. Plots user-entered price levels on the active chart.

//@version=6
indicator("Price Level Radar", shorttitle="Lvl Radar", overlay=true)

// ============================================================================
// DISPLAY SETTINGS
// ============================================================================
grpDisplay = "Display Settings"
table_pos_input = input.string("Bottom Right", "Table Position", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=grpDisplay)
text_size_input = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=grpDisplay)
table_bg_color = input.color(color.rgb(30, 30, 35), "Table Background", group=grpDisplay)
table_bg_transp = input.int(10, "Background Transparency", minval=0, maxval=90, group=grpDisplay)
band_pct = input.float(0.5, "Level Band Width (%)", minval=0.0, step=0.1, group=grpDisplay, tooltip="Half-width of the band drawn around each price level, as a percentage of the level value.")

// ============================================================================
// PRICE LEVELS - MANUAL INPUT
// Levels are ordered high price -> low price on the dashboard.
// L1 is the top level, L5 the bottom. L3 sits in the middle.
// ============================================================================
grpLvl = "Price Levels"
lvl1 = input.float(0.0, "Level 1 (Top / Green)",    group=grpLvl, tooltip="Set to 0 to disable this level.")
lvl2 = input.float(0.0, "Level 2 (Upper / Yellow)", group=grpLvl, tooltip="Set to 0 to disable this level.")
lvl3 = input.float(0.0, "Level 3 (Middle / White)", group=grpLvl, tooltip="Set to 0 to disable this level.")
lvl4 = input.float(0.0, "Level 4 (Lower / Orange)", group=grpLvl, tooltip="Set to 0 to disable this level.")
lvl5 = input.float(0.0, "Level 5 (Bottom / Red)",   group=grpLvl, tooltip="Set to 0 to disable this level.")

// A level of 0 (or less) is treated as "off" — no line, no band, no alerts.
bool on1 = lvl1 > 0
bool on2 = lvl2 > 0
bool on3 = lvl3 > 0
bool on4 = lvl4 > 0
bool on5 = lvl5 > 0

// ============================================================================
// PRICE FEED (native chart close)
// ============================================================================
float price = close

// ============================================================================
// BAND CALCULATIONS (0.5% +/- ranges around each level)
// ============================================================================
float band = band_pct / 100.0

float l1_up = lvl1 * (1 + band)
float l1_dn = lvl1 * (1 - band)
float l2_up = lvl2 * (1 + band)
float l2_dn = lvl2 * (1 - band)
float l3_up = lvl3 * (1 + band)
float l3_dn = lvl3 * (1 - band)
float l4_up = lvl4 * (1 + band)
float l4_dn = lvl4 * (1 - band)
float l5_up = lvl5 * (1 + band)
float l5_dn = lvl5 * (1 - band)

// ============================================================================
// HORIZONTAL LINES & BANDS AT EACH LEVEL
// ============================================================================
var line ln_1 = na
var line ln_1u = na
var line ln_1d = na
var line ln_2 = na
var line ln_2u = na
var line ln_2d = na
var line ln_3 = na
var line ln_3u = na
var line ln_3d = na
var line ln_4 = na
var line ln_4u = na
var line ln_4d = na
var line ln_5 = na
var line ln_5u = na
var line ln_5d = na

var box bx_1 = na
var box bx_2 = na
var box bx_3 = na
var box bx_4 = na
var box bx_5 = na

f_band_color(_c) => color.new(_c, 85)

if barstate.islast
    line.delete(ln_1), line.delete(ln_1u), line.delete(ln_1d)
    line.delete(ln_2), line.delete(ln_2u), line.delete(ln_2d)
    line.delete(ln_3), line.delete(ln_3u), line.delete(ln_3d)
    line.delete(ln_4), line.delete(ln_4u), line.delete(ln_4d)
    line.delete(ln_5), line.delete(ln_5u), line.delete(ln_5d)
    box.delete(bx_1), box.delete(bx_2), box.delete(bx_3), box.delete(bx_4), box.delete(bx_5)

    int x1 = bar_index - 1
    int x2 = bar_index

    // Level 1 (green)
    if on1
        bx_1 := box.new(x1, l1_up, x2, l1_dn, border_color=color.new(color.green,100), bgcolor=f_band_color(color.green), extend=extend.both)
        ln_1  := line.new(x1, lvl1, x2, lvl1, color=color.green, width=2, extend=extend.both)
        ln_1u := line.new(x1, l1_up, x2, l1_up, color=color.green, width=1, style=line.style_dotted, extend=extend.both)
        ln_1d := line.new(x1, l1_dn, x2, l1_dn, color=color.green, width=1, style=line.style_dotted, extend=extend.both)

    // Level 2 (yellow)
    if on2
        bx_2 := box.new(x1, l2_up, x2, l2_dn, border_color=color.new(color.yellow,100), bgcolor=f_band_color(color.yellow), extend=extend.both)
        ln_2  := line.new(x1, lvl2, x2, lvl2, color=color.yellow, width=2, extend=extend.both)
        ln_2u := line.new(x1, l2_up, x2, l2_up, color=color.yellow, width=1, style=line.style_dotted, extend=extend.both)
        ln_2d := line.new(x1, l2_dn, x2, l2_dn, color=color.yellow, width=1, style=line.style_dotted, extend=extend.both)

    // Level 3 (white)
    if on3
        bx_3 := box.new(x1, l3_up, x2, l3_dn, border_color=color.new(color.white,100), bgcolor=f_band_color(color.white), extend=extend.both)
        ln_3  := line.new(x1, lvl3, x2, lvl3, color=color.white, width=2, extend=extend.both)
        ln_3u := line.new(x1, l3_up, x2, l3_up, color=color.white, width=1, style=line.style_dotted, extend=extend.both)
        ln_3d := line.new(x1, l3_dn, x2, l3_dn, color=color.white, width=1, style=line.style_dotted, extend=extend.both)

    // Level 4 (orange)
    if on4
        bx_4 := box.new(x1, l4_up, x2, l4_dn, border_color=color.new(color.orange,100), bgcolor=f_band_color(color.orange), extend=extend.both)
        ln_4  := line.new(x1, lvl4, x2, lvl4, color=color.orange, width=2, extend=extend.both)
        ln_4u := line.new(x1, l4_up, x2, l4_up, color=color.orange, width=1, style=line.style_dotted, extend=extend.both)
        ln_4d := line.new(x1, l4_dn, x2, l4_dn, color=color.orange, width=1, style=line.style_dotted, extend=extend.both)

    // Level 5 (red)
    if on5
        bx_5 := box.new(x1, l5_up, x2, l5_dn, border_color=color.new(color.red,100), bgcolor=f_band_color(color.red), extend=extend.both)
        ln_5  := line.new(x1, lvl5, x2, lvl5, color=color.red, width=2, extend=extend.both)
        ln_5u := line.new(x1, l5_up, x2, l5_up, color=color.red, width=1, style=line.style_dotted, extend=extend.both)
        ln_5d := line.new(x1, l5_dn, x2, l5_dn, color=color.red, width=1, style=line.style_dotted, extend=extend.both)

// ============================================================================
// ALERTS: CROSSING ANY 0.5% THRESHOLD (15 individual conditions)
// Disabled levels (=0) never trigger because price won't cross 0.
// ============================================================================
f_cross(_lvl, _on) => _on and ta.cross(price, _lvl)

alertcondition(f_cross(l1_up, on1), title="Level 1 +0.5%", message="Price Crossing Level 1 +0.5%")
alertcondition(f_cross(lvl1, on1),  title="Level 1",       message="Price Crossing Level 1")
alertcondition(f_cross(l1_dn, on1), title="Level 1 -0.5%", message="Price Crossing Level 1 -0.5%")
alertcondition(f_cross(l2_up, on2), title="Level 2 +0.5%", message="Price Crossing Level 2 +0.5%")
alertcondition(f_cross(lvl2, on2),  title="Level 2",       message="Price Crossing Level 2")
alertcondition(f_cross(l2_dn, on2), title="Level 2 -0.5%", message="Price Crossing Level 2 -0.5%")
alertcondition(f_cross(l3_up, on3), title="Level 3 +0.5%", message="Price Crossing Level 3 +0.5%")
alertcondition(f_cross(lvl3, on3),  title="Level 3",       message="Price Crossing Level 3")
alertcondition(f_cross(l3_dn, on3), title="Level 3 -0.5%", message="Price Crossing Level 3 -0.5%")
alertcondition(f_cross(l4_up, on4), title="Level 4 +0.5%", message="Price Crossing Level 4 +0.5%")
alertcondition(f_cross(lvl4, on4),  title="Level 4",       message="Price Crossing Level 4")
alertcondition(f_cross(l4_dn, on4), title="Level 4 -0.5%", message="Price Crossing Level 4 -0.5%")
alertcondition(f_cross(l5_up, on5), title="Level 5 +0.5%", message="Price Crossing Level 5 +0.5%")
alertcondition(f_cross(lvl5, on5),  title="Level 5",       message="Price Crossing Level 5")
alertcondition(f_cross(l5_dn, on5), title="Level 5 -0.5%", message="Price Crossing Level 5 -0.5%")

// ----------------------------------------------------------------------------
// SINGLE DYNAMIC ALERT (one alert covers all 15 crossings)
// In the alert dialog, choose Condition = "Price Level Radar",
// then "Any alert() function call".
// ----------------------------------------------------------------------------
string alert_msg = na
if f_cross(l1_up, on1)
    alert_msg := "Price Crossing Level 1 +0.5%"
else if f_cross(lvl1, on1)
    alert_msg := "Price Crossing Level 1"
else if f_cross(l1_dn, on1)
    alert_msg := "Price Crossing Level 1 -0.5%"
else if f_cross(l2_up, on2)
    alert_msg := "Price Crossing Level 2 +0.5%"
else if f_cross(lvl2, on2)
    alert_msg := "Price Crossing Level 2"
else if f_cross(l2_dn, on2)
    alert_msg := "Price Crossing Level 2 -0.5%"
else if f_cross(l3_up, on3)
    alert_msg := "Price Crossing Level 3 +0.5%"
else if f_cross(lvl3, on3)
    alert_msg := "Price Crossing Level 3"
else if f_cross(l3_dn, on3)
    alert_msg := "Price Crossing Level 3 -0.5%"
else if f_cross(l4_up, on4)
    alert_msg := "Price Crossing Level 4 +0.5%"
else if f_cross(lvl4, on4)
    alert_msg := "Price Crossing Level 4"
else if f_cross(l4_dn, on4)
    alert_msg := "Price Crossing Level 4 -0.5%"
else if f_cross(l5_up, on5)
    alert_msg := "Price Crossing Level 5 +0.5%"
else if f_cross(lvl5, on5)
    alert_msg := "Price Crossing Level 5"
else if f_cross(l5_dn, on5)
    alert_msg := "Price Crossing Level 5 -0.5%"

if not na(alert_msg)
    alert(alert_msg, alert.freq_once_per_bar)

// ============================================================================
// UTILS
// ============================================================================
f_band_str(_lo, _hi) =>
    str.tostring(_lo, "#.##") + " - " + str.tostring(_hi, "#.##")

f_lvl_txt(_on, _lo, _hi) => _on ? f_band_str(_lo, _hi) : "—"

// ============================================================================
// TABLE DRAWING (Levels + Ranges only)
// ============================================================================
string txt_sz = switch text_size_input
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    => size.small

color base_bg = color.new(table_bg_color, table_bg_transp)
color header_bg = color.new(table_bg_color, math.max(0, table_bg_transp - 10))
string pos_str = switch table_pos_input
    "Top Right" => position.top_right
    "Top Center" => position.top_center
    "Top Left" => position.top_left
    "Middle Right" => position.middle_right
    "Middle Center" => position.middle_center
    "Middle Left" => position.middle_left
    "Bottom Right" => position.bottom_right
    "Bottom Center" => position.bottom_center
    "Bottom Left" => position.bottom_left
    => position.bottom_right

var table radar = table.new(pos_str, 3, 9, border_width=1, border_color=color.gray, frame_color=color.gray, frame_width=1)

if barstate.islast
    // Header (uses the chart's own ticker)
    table.cell(radar, 0, 0, "▌ " + syminfo.ticker + " Level Radar ▐", text_color=color.white, bgcolor=header_bg, text_size=txt_sz, text_halign=text.align_center)
    table.merge_cells(radar, 0, 0, 2, 0)

    // Price row
    table.cell(radar, 0, 1, "Price Now:", text_color=color.gray, bgcolor=base_bg, text_size=txt_sz, text_halign=text.align_left)
    table.cell(radar, 1, 1, str.tostring(price, format.mintick), text_color=color.white, bgcolor=base_bg, text_size=txt_sz, text_halign=text.align_right)
    table.merge_cells(radar, 1, 1, 2, 1)

    // Column sub-header
    table.cell(radar, 0, 2, "Level", text_color=color.white, bgcolor=header_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 2, "Range (±" + str.tostring(band_pct, "#.#") + "%)", text_color=color.white, bgcolor=header_bg, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 2, 2, 2)

    // Zone highlight: which band currently contains price (only if enabled)
    bool in1 = on1 and price <= l1_up and price >= l1_dn
    bool in2 = on2 and price <= l2_up and price >= l2_dn
    bool in3 = on3 and price <= l3_up and price >= l3_dn
    bool in4 = on4 and price <= l4_up and price >= l4_dn
    bool in5 = on5 and price <= l5_up and price >= l5_dn

    // L1 (green)
    color bg1 = in1 ? color.new(color.green, 60) : base_bg
    table.cell(radar, 0, 3, "Level 1", text_color=color.gray, bgcolor=bg1, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 3, f_lvl_txt(on1, l1_dn, l1_up), text_color=color.green, bgcolor=bg1, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 3, 2, 3)
    // L2 (yellow)
    color bg2 = in2 ? color.new(color.yellow, 60) : base_bg
    table.cell(radar, 0, 4, "Level 2", text_color=color.gray, bgcolor=bg2, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 4, f_lvl_txt(on2, l2_dn, l2_up), text_color=color.yellow, bgcolor=bg2, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 4, 2, 4)
    // L3 (white)
    color bg3 = in3 ? color.new(color.white, 60) : base_bg
    table.cell(radar, 0, 5, "Level 3", text_color=color.gray, bgcolor=bg3, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 5, f_lvl_txt(on3, l3_dn, l3_up), text_color=color.white, bgcolor=bg3, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 5, 2, 5)
    // L4 (orange)
    color bg4 = in4 ? color.new(color.orange, 60) : base_bg
    table.cell(radar, 0, 6, "Level 4", text_color=color.gray, bgcolor=bg4, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 6, f_lvl_txt(on4, l4_dn, l4_up), text_color=color.orange, bgcolor=bg4, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 6, 2, 6)
    // L5 (red)
    color bg5 = in5 ? color.new(color.red, 60) : base_bg
    table.cell(radar, 0, 7, "Level 5", text_color=color.gray, bgcolor=bg5, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 7, f_lvl_txt(on5, l5_dn, l5_up), text_color=color.red, bgcolor=bg5, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 7, 2, 7)

    // Footer note
    table.cell(radar, 0, 8, "Band:", text_color=color.gray, bgcolor=base_bg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(radar, 1, 8, "Level × (1 ± " + str.tostring(band_pct, "#.#") + "%)", text_color=color.gray, bgcolor=base_bg, text_size=size.tiny, text_halign=text.align_right)
    table.merge_cells(radar, 1, 8, 2, 8)

plot(price, "Price", display=display.status_line)
````
