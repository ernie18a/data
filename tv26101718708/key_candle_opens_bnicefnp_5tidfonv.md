# Key Candle Opens [@Bnice_FNP]

- url: https://www.tradingview.com/script/5tIdFoNv-Key-Candle-Opens-Bnice-FNP/
- type: indicator
- pine_id: PUB;cfaa8826faae4e9f856c05f2748b8fe1
- version: 2.0

## Description

This indicator plots the most important candle open levels used in ICT methodology, giving you instant visual reference for key price levels that smart money and institutional traders pay close attention to throughout the trading day.
All times are based on the New York (ET) timezone and are designed to align with TradingView's actual candle boundaries.
Levels plotted:

Midnight Open (MNO) — The 12:00 AM candle open. One of the most referenced price levels in ICT concepts, used to gauge daily directional bias.
4H Opens — The six 4-hour candle opens (12:00 AM, 6:00 AM, 10:00 AM, 2:00 PM, 6:00 PM, 10:00 PM ET) that align with TradingView's real 4H chart boundaries. Each open can be toggled on or off individually so you only see the ones relevant to your session.
Asian Open — The 8:00 PM ET candle open marking the start of the Asian trading session.
London Open — The 3:00 AM ET candle open marking the start of the London killzone.
New York Open — The 9:30 AM ET candle open marking the NYSE cash open and NY killzone.

Features:

Individual toggle, color, line style, and width controls for every open
4H opens are independently toggled so you can focus on the sessions you trade
Labels display at the right edge of each line for clean, unobstructed chart reading
Adjustable line extension length
Works on all intraday timeframes (1m, 5m, 15m, 1H, etc.)

Best used on 1m, 5m, or 15m charts for intraday trading setups.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FNP_Trades

// ══════════════════════════════════════════════════
// Key Candle Opens by {@Bnice_FNP}
// 4H opens individually toggled with time labels
// ══════════════════════════════════════════════════
//@version=5
indicator("Key Candle Opens [@Bnice_FNP]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Midnight Open ─────────────────────────────────
var string G1 = "Midnight Open (12:00 AM ET)"
show_mid  = input.bool(true,   "Show",  group=G1, inline="m")
mid_col   = input.color(#FFFFFF,         "Color", group=G1, inline="m")
mid_sty   = input.string("Solid",  "",      group=G1, inline="m", options=["Solid","Dashed","Dotted"])
mid_wid   = input.int(2,             "",      group=G1, inline="m", minval=1, maxval=4)

// ── 4H Opens — shared style, individual toggles ───
var string G2 = "4H Opens"
h4_col    = input.color(#4FC3F7,         "Color", group=G2, inline="style")
h4_sty    = input.string("Dashed", "",      group=G2, inline="style", options=["Solid","Dashed","Dotted"])
h4_wid    = input.int(1,             "",      group=G2, inline="style", minval=1, maxval=4)
show_6am  = input.bool(false,  "6:00  (6AM)",  group=G2)
show_10am = input.bool(true,   "10:00 (10AM)", group=G2)
show_2pm  = input.bool(false,  "14:00 (2PM)",  group=G2)
show_6pm  = input.bool(false,  "18:00 (6PM)",  group=G2)
show_10pm = input.bool(false,  "22:00 (10PM)", group=G2)

// ── Asian Open ────────────────────────────────────
var string G3 = "Asian Open (8:00 PM ET)"
show_asian = input.bool(true,  "Show",  group=G3, inline="a")
asian_col  = input.color(#FFD700,        "Color", group=G3, inline="a")
asian_sty  = input.string("Dashed", "",     group=G3, inline="a", options=["Solid","Dashed","Dotted"])
asian_wid  = input.int(1,             "",     group=G3, inline="a", minval=1, maxval=4)

// ── London Open ───────────────────────────────────
var string G4 = "London Open (3:00 AM ET)"
show_lon  = input.bool(true,   "Show",  group=G4, inline="l")
lon_col   = input.color(#CE93D8,         "Color", group=G4, inline="l")
lon_sty   = input.string("Dashed", "",      group=G4, inline="l", options=["Solid","Dashed","Dotted"])
lon_wid   = input.int(1,             "",      group=G4, inline="l", minval=1, maxval=4)

// ── New York Open ─────────────────────────────────
var string G5 = "New York Open (9:30 AM ET)"
show_ny   = input.bool(true,   "Show",  group=G5, inline="n")
ny_col    = input.color(#F06292,         "Color", group=G5, inline="n")
ny_sty    = input.string("Solid",  "",      group=G5, inline="n", options=["Solid","Dashed","Dotted"])
ny_wid    = input.int(2,             "",      group=G5, inline="n", minval=1, maxval=4)

// ── Display Settings ──────────────────────────────
var string G6 = "Display Settings"
show_labels  = input.bool(true, "Show Labels",        group=G6)
extend_bars  = input.int(60,   "Extend Lines (bars)", group=G6, minval=10, maxval=500)

// ══════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════
f_style(s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

f_draw(price, col, sty, wid, lbl) =>
    line.new(bar_index, price, bar_index + extend_bars, price,
             color=col, style=f_style(sty), width=wid)
    if show_labels
        label.new(bar_index + extend_bars, price, lbl,
                  color=color.new(col, 75), textcolor=col,
                  style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════════
// TIME DETECTION — New York timezone
// ══════════════════════════════════════════════════
tz = "America/New_York"
h  = hour(time, tz)
m  = minute(time, tz)

is_mid   = h == 0  and m == 0
is_asian = h == 20 and m == 0
is_lon   = h == 3  and m == 0
is_ny    = h == 9  and m == 30
is_6am   = h == 6  and m == 0
is_10am  = h == 10 and m == 0
is_2pm   = h == 14 and m == 0
is_6pm   = h == 18 and m == 0
is_10pm  = h == 22 and m == 0

// ══════════════════════════════════════════════════
// DRAW — intraday charts only
// ══════════════════════════════════════════════════
if timeframe.isintraday
    // 4H — each open individually toggled with its time as label
    if show_6am and is_6am
        f_draw(open, h4_col, h4_sty, h4_wid, "6:00")
    if show_10am and is_10am
        f_draw(open, h4_col, h4_sty, h4_wid, "10:00")
    if show_2pm and is_2pm
        f_draw(open, h4_col, h4_sty, h4_wid, "14:00")
    if show_6pm and is_6pm
        f_draw(open, h4_col, h4_sty, h4_wid, "18:00")
    if show_10pm and is_10pm
        f_draw(open, h4_col, h4_sty, h4_wid, "22:00")
    // Session opens
    if show_mid and is_mid
        f_draw(open, mid_col, mid_sty, mid_wid, "MNO")
    if show_asian and is_asian
        f_draw(open, asian_col, asian_sty, asian_wid, "Asian")
    if show_lon and is_lon
        f_draw(open, lon_col, lon_sty, lon_wid, "London")
    if show_ny and is_ny
        f_draw(open, ny_col, ny_sty, ny_wid, "NY Open")
````
