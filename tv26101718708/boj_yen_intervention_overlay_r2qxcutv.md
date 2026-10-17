# BOJ Yen Intervention Overlay

- url: https://www.tradingview.com/script/r2QXCUTv-BOJ-Yen-Intervention-Overlay/
- type: indicator
- pine_id: PUB;71506470b04b45df99f3f45ecbbe8c6c
- version: 1.0

## Description

BOJ intervention Overlay FX ... tells you when BOJ intervenes

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOJ Yen Intervention Overlay

//@version=6
indicator("BOJ Yen Intervention Overlay", overlay=true, max_labels_count=100, max_lines_count=100)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
show_sell_yen  = input.bool(true,    "Show Sell-Yen Interventions (JPY weakening)",    group="Display")
show_buy_yen   = input.bool(true,    "Show Buy-Yen Interventions (JPY strengthening)", group="Display")
show_labels    = input.bool(true,    "Show Labels",             group="Display")
show_lines     = input.bool(true,    "Show Vertical Lines",     group="Display")
show_bg        = input.bool(false,   "Show Background Shading", group="Display")
label_size     = input.string("small", "Label Size", options=["tiny","small","normal","large"], group="Display")

buy_yen_color  = input.color(color.new(color.green, 0), "Buy-Yen Color",  group="Colors")
sell_yen_color = input.color(color.new(color.red,   0), "Sell-Yen Color", group="Colors")
line_transp    = input.int(70, "Line/BG Transparency", minval=0, maxval=90, group="Colors")

// ─── INTERVENTION TIMESTAMPS ──────────────────────────────────────────────────
// Type 1 = Sell Yen (curb JPY strength)  |  Type 2 = Buy Yen (curb JPY weakness)
// Sources: Ministry of Finance Japan, Reuters, Bloomberg, CNBC

var int t_1993_a = timestamp("1993-01-04")  // Sell - 1993 campaign start
var int t_1993_b = timestamp("1993-12-31")  // Sell - 1993 campaign end
var int t_1994_a = timestamp("1994-04-01")  // Buy  - US+JP support USD
var int t_1995_a = timestamp("1995-08-15")  // Buy  - post USD low
var int t_1997_a = timestamp("1997-12-17")  // Buy  - Asian crisis
var int t_1998_a = timestamp("1998-04-09")  // Buy  - Asian crisis
var int t_1998_b = timestamp("1998-04-10")  // Buy  - Asian crisis
var int t_1998_c = timestamp("1998-06-17")  // Buy  - coordinated
var int t_1999_a = timestamp("1999-01-12")  // Sell - 1999-2000 campaign start
var int t_2000_a = timestamp("2000-04-03")  // Sell - 1999-2000 campaign end
var int t_2002_a = timestamp("2002-05-31")  // Sell - May 2002
var int t_2002_b = timestamp("2002-06-28")  // Sell - Jun 2002
var int t_2003_a = timestamp("2003-09-01")  // Sell - 2003-04 campaign start
var int t_2004_a = timestamp("2004-03-16")  // Sell - 2003-04 campaign end
var int t_2010_a = timestamp("2010-09-15")  // Sell - first in 6 years
var int t_2011_a = timestamp("2011-03-18")  // Sell - G7 post-quake
var int t_2011_b = timestamp("2011-08-04")  // Sell - Aug 2011
var int t_2011_c = timestamp("2011-10-31")  // Sell - Oct 2011
var int t_2022_a = timestamp("2022-09-22")  // Buy  - 2,838B JPY, first in 24yr
var int t_2022_b = timestamp("2022-10-21")  // Buy  - 5,620B JPY record (then)
var int t_2022_c = timestamp("2022-10-24")  // Buy  - 730B JPY
var int t_2024_a = timestamp("2024-04-29")  // Buy  - 5,919B JPY new record
var int t_2024_b = timestamp("2024-05-01")  // Buy  - 3,870B JPY
var int t_2024_c = timestamp("2024-07-11")  // Buy  - 3,168B JPY
var int t_2024_d = timestamp("2024-07-12")  // Buy  - 2,367B JPY

// ─── HELPERS ──────────────────────────────────────────────────────────────────
isBar(int ts) =>
    time >= ts and time < ts + timeframe.in_seconds() * 1000

getLabelSize() =>
    switch label_size
        "tiny"   => size.tiny
        "normal" => size.normal
        "large"  => size.large
        =>          size.small

// ─── BGCOLOR — must be at global scope in Pine v6 (CE10188 fix) ───────────────
// Pre-compute booleans for each intervention bar, then call bgcolor once globally.
isSellBar =
     isBar(t_1993_a) or isBar(t_1993_b) or
     isBar(t_1999_a) or isBar(t_2000_a) or
     isBar(t_2002_a) or isBar(t_2002_b) or
     isBar(t_2003_a) or isBar(t_2004_a) or
     isBar(t_2010_a) or
     isBar(t_2011_a) or isBar(t_2011_b) or isBar(t_2011_c)

isBuyBar =
     isBar(t_1994_a) or isBar(t_1995_a) or
     isBar(t_1997_a) or
     isBar(t_1998_a) or isBar(t_1998_b) or isBar(t_1998_c) or
     isBar(t_2022_a) or isBar(t_2022_b) or isBar(t_2022_c) or
     isBar(t_2024_a) or isBar(t_2024_b) or isBar(t_2024_c) or isBar(t_2024_d)

bgcolor(show_bg and show_sell_yen and isSellBar ? color.new(sell_yen_color, line_transp) :
        show_bg and show_buy_yen  and isBuyBar  ? color.new(buy_yen_color,  line_transp) :
        na)

// ─── LINES & LABELS (safe inside functions/if blocks) ────────────────────────
f_plot(int ts, int itype, string lbl, string amt) =>
    if isBar(ts)
        clr      = itype == 2 ? buy_yen_color : sell_yen_color
        fullText = amt != "" ? lbl + "\n" + amt : lbl
        if show_lines
            line.new(bar_index, low, bar_index, high,
                     color=clr, width=2, style=line.style_dashed)
        if show_labels
            label.new(
                 x         = bar_index,
                 y         = itype == 2 ? high : low,
                 text      = fullText,
                 color     = clr,
                 textcolor = color.white,
                 style     = itype == 2 ? label.style_label_up : label.style_label_down,
                 size      = getLabelSize())

// ─── SELL-YEN EVENTS ─────────────────────────────────────────────────────────
if show_sell_yen
    f_plot(t_1993_a, 1, "BOJ Sell JPY\n1993 Campaign\nStart", "")
    f_plot(t_1993_b, 1, "BOJ Sell JPY\n1993 Campaign\nEnd",   "")
    f_plot(t_1999_a, 1, "BOJ Sell JPY\n1999-2000 Campaign",   "")
    f_plot(t_2000_a, 1, "BOJ Sell JPY\nCampaign End",         "35T JPY total")
    f_plot(t_2002_a, 1, "BOJ Sell JPY\nMay 2002",             "")
    f_plot(t_2002_b, 1, "BOJ Sell JPY\nJun 2002",             "")
    f_plot(t_2003_a, 1, "BOJ Sell JPY\n2003-04 Campaign",     "")
    f_plot(t_2004_a, 1, "BOJ Sell JPY\nCampaign End",         "35T JPY total")
    f_plot(t_2010_a, 1, "BOJ Sell JPY\nSep 15, 2010",         "1st in 6yr")
    f_plot(t_2011_a, 1, "G7 Sell JPY\nMar 18, 2011",          "Post-quake")
    f_plot(t_2011_b, 1, "BOJ Sell JPY\nAug 4, 2011",          "")
    f_plot(t_2011_c, 1, "BOJ Sell JPY\nOct 31, 2011",         "")

// ─── BUY-YEN EVENTS ──────────────────────────────────────────────────────────
if show_buy_yen
    f_plot(t_1994_a, 2, "US+JP Buy JPY\nApr 1994",       "USD support")
    f_plot(t_1995_a, 2, "US+JP Buy JPY\nAug 1995",       "Post low")
    f_plot(t_1997_a, 2, "JP Buy JPY\nDec 17-19, 1997",   "Asian crisis")
    f_plot(t_1998_a, 2, "JP Buy JPY\nApr 9, 1998",       "")
    f_plot(t_1998_b, 2, "JP Buy JPY\nApr 10, 1998",      "")
    f_plot(t_1998_c, 2, "US+JP Buy JPY\nJun 17, 1998",   "Coordinated")
    f_plot(t_2022_a, 2, "MOF Buy JPY\nSep 22, 2022",     "2,838B JPY\n1st in 24yr")
    f_plot(t_2022_b, 2, "MOF Buy JPY\nOct 21, 2022",     "5,620B JPY\nRecord (then)")
    f_plot(t_2022_c, 2, "MOF Buy JPY\nOct 24, 2022",     "730B JPY")
    f_plot(t_2024_a, 2, "MOF Buy JPY\nApr 29, 2024",     "5,919B JPY\nNew record\n160.245 low")
    f_plot(t_2024_b, 2, "MOF Buy JPY\nMay 1, 2024",      "3,870B JPY")
    f_plot(t_2024_c, 2, "MOF Buy JPY\nJul 11, 2024",     "3,168B JPY")
    f_plot(t_2024_d, 2, "MOF Buy JPY\nJul 12, 2024",     "2,367B JPY\n161.96 low")

// ─── LEGEND ───────────────────────────────────────────────────────────────────
plot(series=na, color=buy_yen_color,  linewidth=2, title="Buy JPY  (Curb Weakness)")
plot(series=na, color=sell_yen_color, linewidth=2, title="Sell JPY (Curb Strength)")
````
