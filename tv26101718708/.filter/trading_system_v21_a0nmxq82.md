#  Trading System v2.1

- url: https://www.tradingview.com/script/A0nMXq82-Trading-System-v2-1/
- type: indicator
- pine_id: PUB;6f5a0f55b93546d19037b591111509e1
- version: 1.0

## Description

TRADING SYSTEM INDICATOR.

multiple confluences.

VWAP
EMA
LIQUIDITY

## Source Code

````pine
//@version=6
indicator(" Trading System v2.1", overlay=true, max_bars_back=1000, max_lines_count=500, max_boxes_count=500, max_labels_count=500, shorttitle=" v2.1")

// =============================================================================
//  TRADING SYSTEM v2.1
// 1. Full input customisation: colour, width, style, label size on every element
// 2. OB / FVG zones removed only when price COMPLETELY closes through the zone
//    + max-age removal to prevent old zones cluttering the chart
// =============================================================================

// -- EMA Lines ----------------------------------------------------------------
var string GE    = "EMA Lines"
show_ema9        = input.bool(true,            "Show EMA 9",           group=GE)
col_ema9         = input.color(color.yellow,   "EMA 9 Colour",         group=GE)
w_ema9           = input.int(1,                "EMA 9 Width",          group=GE, minval=1, maxval=5)
show_ema21       = input.bool(true,            "Show EMA 21",          group=GE)
col_ema21        = input.color(color.orange,   "EMA 21 Colour",        group=GE)
w_ema21          = input.int(1,                "EMA 21 Width",         group=GE, minval=1, maxval=5)
show_ema50       = input.bool(true,            "Show EMA 50",          group=GE)
col_ema50        = input.color(color.blue,     "EMA 50 Colour",        group=GE)
w_ema50          = input.int(2,                "EMA 50 Width",         group=GE, minval=1, maxval=5)
show_ema200      = input.bool(true,            "Show EMA 200",         group=GE)
col_ema200       = input.color(color.red,      "EMA 200 Colour",       group=GE)
w_ema200         = input.int(2,                "EMA 200 Width",        group=GE, minval=1, maxval=5)

// -- EMA Crossover Signals ----------------------------------------------------
var string GS    = "EMA Crossover Signals"
show_signals     = input.bool(true,            "Show Signals",         group=GS)
txt_long         = input.string("LONG",        "Long Label",           group=GS)
txt_short        = input.string("SHORT",       "Short Label",          group=GS)
col_long         = input.color(color.lime,     "Long Colour",          group=GS)
col_short        = input.color(color.fuchsia,  "Short Colour",         group=GS)
sig_sz_str       = input.string("normal",      "Label Size",           group=GS, options=["tiny","small","normal","large","huge"])

// -- Order Blocks -------------------------------------------------------------
var string GOB   = "Order Blocks"
show_ob          = input.bool(true,            "Show Order Blocks",                    group=GOB)
col_bull_ob      = input.color(color.new(color.green, 80), "Bull OB Fill",             group=GOB)
col_bull_ob_bdr  = input.color(color.green,   "Bull OB Border and Candle Colour",     group=GOB)
col_bear_ob      = input.color(color.new(color.red,   80), "Bear OB Fill",             group=GOB)
col_bear_ob_bdr  = input.color(color.red,     "Bear OB Border and Candle Colour",     group=GOB)
ob_bdr_w         = input.int(1,               "OB Border Width",                      group=GOB, minval=1, maxval=4)
ob_limit         = input.int(8,               "Max Active OBs",                       group=GOB, minval=1, maxval=30)
ob_max_bars      = input.int(300,             "Auto-remove after N bars (0 = never)", group=GOB, minval=0, maxval=5000)

// -- FVG / iFVG ---------------------------------------------------------------
var string GFVG  = "FVG and iFVG"
show_fvg         = input.bool(true,            "Show FVG",                             group=GFVG)
show_ifvg        = input.bool(true,            "Show iFVG on violation (else delete)", group=GFVG)
col_bull_fvg     = input.color(color.new(color.teal,   80), "Bull FVG Fill",           group=GFVG)
col_bull_fvg_bdr = input.color(color.teal,    "Bull FVG Border",                      group=GFVG)
col_bear_fvg     = input.color(color.new(color.red,    82), "Bear FVG Fill",           group=GFVG)
col_bear_fvg_bdr = input.color(color.red,     "Bear FVG Border",                      group=GFVG)
col_bull_ifvg    = input.color(color.new(color.orange, 78), "Bull iFVG Fill",          group=GFVG)
col_bull_ifvg_b  = input.color(color.orange,  "Bull iFVG Border",                     group=GFVG)
col_bear_ifvg    = input.color(color.new(color.purple, 78), "Bear iFVG Fill",          group=GFVG)
col_bear_ifvg_b  = input.color(color.purple,  "Bear iFVG Border",                     group=GFVG)
fvg_bdr_w        = input.int(1,               "FVG Border Width",                     group=GFVG, minval=1, maxval=4)
fvg_limit        = input.int(8,               "Max Active FVGs",                      group=GFVG, minval=1, maxval=30)
fvg_max_bars     = input.int(300,             "Auto-remove after N bars (0 = never)", group=GFVG, minval=0, maxval=5000)

// -- 1-2-3 Pattern ------------------------------------------------------------
var string G123  = "1-2-3 Candle Pattern"
show_123         = input.bool(true,            "Show 1-2-3 Pattern",   group=G123)
txt_bull_123     = input.string("1-2-3",       "Bull Label",           group=G123)
txt_bear_123     = input.string("1-2-3",       "Bear Label",           group=G123)
col_bull_123     = input.color(color.lime,     "Bull Colour",          group=G123)
col_bear_123     = input.color(color.red,      "Bear Colour",          group=G123)
p123_sz_str      = input.string("small",       "Label Size",           group=G123, options=["tiny","small","normal","large","huge"])

// -- VWAP ---------------------------------------------------------------------
var string GV    = "VWAP"
show_vwap        = input.bool(true,            "Show VWAP",            group=GV)
col_vwap         = input.color(color.purple,   "VWAP Colour",          group=GV)
w_vwap           = input.int(2,                "VWAP Width",           group=GV, minval=1, maxval=5)

// -- Previous Day H/L ---------------------------------------------------------
var string GPD   = "Previous Day High / Low"
show_pdhl        = input.bool(true,            "Show PDH / PDL",       group=GPD)
col_pdh          = input.color(color.orange,   "PDH Colour",           group=GPD)
col_pdl          = input.color(color.orange,   "PDL Colour",           group=GPD)
w_pdh            = input.int(1,                "PDH Width",            group=GPD, minval=1, maxval=5)
w_pdl            = input.int(1,                "PDL Width",            group=GPD, minval=1, maxval=5)
sty_pdh_s        = input.string("dashed",      "PDH Style",            group=GPD, options=["solid","dashed","dotted"])
sty_pdl_s        = input.string("dashed",      "PDL Style",            group=GPD, options=["solid","dashed","dotted"])
txt_pdh          = input.string("PDH",         "PDH Label",            group=GPD)
txt_pdl          = input.string("PDL",         "PDL Label",            group=GPD)
pdhl_sz_str      = input.string("small",       "Label Size",           group=GPD, options=["tiny","small","normal","large","huge"])
LEVELS_MAX_AGE   = input.int(1,                "Keep PDH/PDL/Asia labels for N days", group=GPD, minval=1, maxval=10, tooltip="After this many days, session-specific labels auto-remove. Sweep/POI detection picks up any structural levels that remain relevant.")

// -- Asia Session -------------------------------------------------------------
var string GAS   = "Asia Session High / Low"
show_asia        = input.bool(true,            "Show Asia H/L",        group=GAS)
asia_start_h     = input.int(23,               "Start Hour GMT",       group=GAS, minval=0, maxval=23)
asia_end_h       = input.int(8,                "End Hour GMT",         group=GAS, minval=0, maxval=23)
col_asia         = input.color(color.silver,   "Asia H/L Colour",      group=GAS)
w_asia           = input.int(1,                "Asia Line Width",       group=GAS, minval=1, maxval=5)
sty_asia_s       = input.string("dotted",      "Asia Line Style",       group=GAS, options=["solid","dashed","dotted"])
txt_asia_h       = input.string("Asia H",      "High Label",           group=GAS)
txt_asia_l       = input.string("Asia L",      "Low Label",            group=GAS)
asia_sz_str      = input.string("small",       "Label Size",           group=GAS, options=["tiny","small","normal","large","huge"])

// -- Liquidity Pools (BSL / SSL) ----------------------------------------------
var string GEQL  = "Liquidity Pools (BSL and SSL)"
show_eql         = input.bool(true,           "Show Liquidity Pools",                 group=GEQL)
eql_lb           = input.int(5,               "Swing Sensitivity (bars each side)",   group=GEQL, minval=2, maxval=15)
eql_max          = input.int(6,               "Max Levels per Side",                  group=GEQL, minval=2, maxval=20)
col_bsl          = input.color(color.lime,    "BSL Colour (Buy-Side Liquidity)",      group=GEQL)
col_ssl          = input.color(#FF4444,       "SSL Colour (Sell-Side Liquidity)",     group=GEQL)
w_eql            = input.int(1,               "Line Width",                           group=GEQL, minval=1, maxval=3)
sty_eql_s        = input.string("dotted",     "Line Style",                           group=GEQL, options=["solid","dashed","dotted"])
txt_bsl          = input.string("BSL",        "Buy-Side Label",                       group=GEQL)
txt_ssl          = input.string("SSL",        "Sell-Side Label",                      group=GEQL)
eql_sz_str       = input.string("tiny",       "Label Size",                           group=GEQL, options=["tiny","small","normal","large","huge"])

// -- POI - Points of Interest (Macro Structural Levels) -----------------------
// High-sensitivity pivots that mark major structural turning points across days
// and weeks. These persist on the chart -- price bounces between them on a macro
// scale. When price closes through a POI it changes colour (SR flip) but stays
// visible. Adjust poi_lb up or down to match your chart timeframe:
//   1M chart: poi_lb=50-100  |  5M: poi_lb=30-50  |  15M: poi_lb=20-30  |  4H: poi_lb=10-20
var string GPOI  = "POI - Macro Structural Levels"
show_poi         = input.bool(true,           "Show POI Levels",                          group=GPOI)
poi_lb           = input.int(20,              "Swing Sensitivity (bars each side)",        group=GPOI, minval=5, maxval=200)
poi_max          = input.int(12,              "Max POI Levels to Show (each side)",        group=GPOI, minval=3, maxval=30)
col_poi          = input.color(#FF69A0,       "POI Colour (fresh / untested)",             group=GPOI)
col_poi_flip     = input.color(color.new(color.gray, 40), "POI Colour (tested / flipped)", group=GPOI)
w_poi            = input.int(1,               "Width",                                    group=GPOI, minval=1, maxval=4)
sty_poi_s        = input.string("dashed",     "Style",                                    group=GPOI, options=["solid","dashed","dotted"])
txt_poi          = input.string("POI",        "Label",                                    group=GPOI)
poi_sz_str       = input.string("tiny",       "Label Size",                               group=GPOI, options=["tiny","small","normal","large","huge"])

// =============================================================================
// STYLE / SIZE CONVERTERS  (inline -- avoids series-string type conflicts)
// =============================================================================
sig_sz    = sig_sz_str   == "tiny" ? size.tiny : sig_sz_str   == "small" ? size.small : sig_sz_str   == "large" ? size.large : sig_sz_str   == "huge" ? size.huge : size.normal
p123_sz   = p123_sz_str  == "tiny" ? size.tiny : p123_sz_str  == "small" ? size.small : p123_sz_str  == "large" ? size.large : p123_sz_str  == "huge" ? size.huge : size.normal
pdhl_sz   = pdhl_sz_str  == "tiny" ? size.tiny : pdhl_sz_str  == "small" ? size.small : pdhl_sz_str  == "large" ? size.large : pdhl_sz_str  == "huge" ? size.huge : size.normal
asia_sz   = asia_sz_str  == "tiny" ? size.tiny : asia_sz_str  == "small" ? size.small : asia_sz_str  == "large" ? size.large : asia_sz_str  == "huge" ? size.huge : size.normal
eql_sz    = eql_sz_str   == "small" ? size.small : eql_sz_str == "normal" ? size.normal : eql_sz_str == "large" ? size.large : eql_sz_str == "huge" ? size.huge : size.tiny
sty_eql   = sty_eql_s   == "solid" ? line.style_solid : sty_eql_s == "dashed" ? line.style_dashed : line.style_dotted
poi_sz    = poi_sz_str   == "small" ? size.small : poi_sz_str == "normal" ? size.normal : poi_sz_str == "large" ? size.large : poi_sz_str == "huge" ? size.huge : size.tiny
sty_poi   = sty_poi_s   == "solid" ? line.style_solid : sty_poi_s == "dashed" ? line.style_dashed : line.style_dotted

sty_pdh     = sty_pdh_s     == "dotted" ? line.style_dotted : sty_pdh_s     == "dashed" ? line.style_dashed : line.style_solid
sty_pdl     = sty_pdl_s     == "dotted" ? line.style_dotted : sty_pdl_s     == "dashed" ? line.style_dashed : line.style_solid
sty_asia    = sty_asia_s    == "dotted" ? line.style_dotted : sty_asia_s    == "dashed" ? line.style_dashed : line.style_solid

// =============================================================================
// EMA
// =============================================================================
ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(show_ema9   ? ema9   : na, "EMA 9",   color=col_ema9,   linewidth=w_ema9)
plot(show_ema21  ? ema21  : na, "EMA 21",  color=col_ema21,  linewidth=w_ema21)
plot(show_ema50  ? ema50  : na, "EMA 50",  color=col_ema50,  linewidth=w_ema50)
plot(show_ema200 ? ema200 : na, "EMA 200", color=col_ema200, linewidth=w_ema200)

// =============================================================================
// VWAP
// =============================================================================
vwap_val = ta.vwap(hlc3)
plot(show_vwap ? vwap_val : na, "VWAP", color=col_vwap, linewidth=w_vwap)

// =============================================================================
// GMT TIME HELPERS
// =============================================================================
bar_h     = hour(time,    "GMT+0")
bar_m     = minute(time,  "GMT+0")
bar_hh    = hour(time[1], "GMT+0")
bar_mm    = minute(time[1], "GMT+0")        // previous bar minute (for minute-precision detection)
bar_total = bar_h * 60 + bar_m             // current bar total minutes from midnight GMT
bar_prev  = bar_hh * 60 + bar_mm           // previous bar total minutes
bar_dow   = dayofweek(time, "GMT+0")
is_wday   = bar_dow != dayofweek.saturday and bar_dow != dayofweek.sunday
day_id    = year(time, "GMT+0") * 10000 + month(time, "GMT+0") * 100 + dayofmonth(time, "GMT+0")
new_day   = ta.change(day_id) != 0

// =============================================================================
// EMA CROSSOVER SIGNALS  (label.new anchored to bar_index)
// =============================================================================
bullCross = ta.crossover(ema9, ema21)
bearCross = ta.crossunder(ema9, ema21)

// -- Secondary entry signals --------------------------------------------------
// Entry 1: 9 EMA pullback bounce
//   Trend intact (9 above 21). Bar wicks into or below 9 EMA but BODY closes above it.
//   Excludes the crossover bar itself.
ema9_bounce_bull = ema9 > ema21 and low <= ema9 and close > ema9 and not bullCross
ema9_bounce_bear = ema9 < ema21 and high >= ema9 and close < ema9 and not bearCross

// Entry 2: 21 EMA pullback bounce
//   Deeper retracement. 9 EMA still above 21 EMA (spread intact). Bar closes back on trend side.
ema21_bounce_bull = ema9 > ema21 and low <= ema21 and close > ema21
ema21_bounce_bear = ema9 < ema21 and high >= ema21 and close < ema21

// Entry 3: 9 EMA reclaim after brief dip
//   Previous bar closed against the 9 EMA. Current bar body closes back on trend side.
//   21 EMA spread must still be intact.
ema9_reclaim_bull = ema9 > ema21 and close > ema9 and close[1] <= ema9[1]
ema9_reclaim_bear = ema9 < ema21 and close < ema9 and close[1] >= ema9[1]

if show_signals and bullCross
    label.new(bar_index, low,  txt_long,  style=label.style_arrowup,   color=col_long,  textcolor=color.white, size=sig_sz, xloc=xloc.bar_index, yloc=yloc.price)
if show_signals and bearCross
    label.new(bar_index, high, txt_short, style=label.style_arrowdown, color=col_short, textcolor=color.white, size=sig_sz, xloc=xloc.bar_index, yloc=yloc.price)

// =============================================================================
// ORDER BLOCKS
// Detection: bar[1] is the OB candle, bar[0] is the displacement
// Removal  : close COMPLETELY through the zone (below OB low / above OB high)
//            OR zone age exceeds ob_max_bars
// =============================================================================
var bull_ob_top = array.new_float()
var bull_ob_bot = array.new_float()
var bull_ob_box = array.new_box()
var bull_ob_age = array.new_int()

var bear_ob_top = array.new_float()
var bear_ob_bot = array.new_float()
var bear_ob_box = array.new_box()
var bear_ob_age = array.new_int()

c2_rng     = high[1] - low[1]
is_bull_ob = show_ob and close[1] < open[1] and close > open and close > high[1] and (close - open) > c2_rng * 0.4
is_bear_ob = show_ob and close[1] > open[1] and close < open and close < low[1]  and (open - close) > c2_rng * 0.4

if is_bull_ob
    bx = box.new(bar_index[1], high[1], bar_index + 20, low[1], border_color=col_bull_ob_bdr, bgcolor=col_bull_ob, border_width=ob_bdr_w)
    array.push(bull_ob_top, high[1])
    array.push(bull_ob_bot, low[1])
    array.push(bull_ob_box, bx)
    array.push(bull_ob_age, bar_index)
    if array.size(bull_ob_box) > ob_limit
        box.delete(array.shift(bull_ob_box))
        array.shift(bull_ob_top)
        array.shift(bull_ob_bot)
        array.shift(bull_ob_age)

if is_bear_ob
    bx = box.new(bar_index[1], high[1], bar_index + 20, low[1], border_color=col_bear_ob_bdr, bgcolor=col_bear_ob, border_width=ob_bdr_w)
    array.push(bear_ob_top, high[1])
    array.push(bear_ob_bot, low[1])
    array.push(bear_ob_box, bx)
    array.push(bear_ob_age, bar_index)
    if array.size(bear_ob_box) > ob_limit
        box.delete(array.shift(bear_ob_box))
        array.shift(bear_ob_top)
        array.shift(bear_ob_bot)
        array.shift(bear_ob_age)

// Colour OB candle: offset=-1 colours bar[1] (the actual OB candle)
barcolor(is_bull_ob ? col_bull_ob_bdr : is_bear_ob ? col_bear_ob_bdr : na, offset=-1, title="OB Candle")

// Maintain OB boxes -- remove when fully mitigated or too old
if show_ob
    if array.size(bull_ob_box) > 0
        for i = array.size(bull_ob_box) - 1 to 0
            bx  = array.get(bull_ob_box, i)
            bot = array.get(bull_ob_bot, i)
            age = bar_index - array.get(bull_ob_age, i)
            box.set_right(bx, bar_index)
            // Full mitigation: close BELOW OB low (completely through zone)
            if close < bot or (ob_max_bars > 0 and age > ob_max_bars)
                box.delete(bx)
                array.remove(bull_ob_box, i)
                array.remove(bull_ob_top, i)
                array.remove(bull_ob_bot, i)
                array.remove(bull_ob_age, i)

    if array.size(bear_ob_box) > 0
        for i = array.size(bear_ob_box) - 1 to 0
            bx  = array.get(bear_ob_box, i)
            top = array.get(bear_ob_top, i)
            age = bar_index - array.get(bear_ob_age, i)
            box.set_right(bx, bar_index)
            // Full mitigation: close ABOVE OB high (completely through zone)
            if close > top or (ob_max_bars > 0 and age > ob_max_bars)
                box.delete(bx)
                array.remove(bear_ob_box, i)
                array.remove(bear_ob_top, i)
                array.remove(bear_ob_bot, i)
                array.remove(bear_ob_age, i)

// =============================================================================
// FVG / iFVG
// Bull FVG: gap from high[2] to low[0]
// Bear FVG: gap from low[2] to high[0]
// Removal  : close completely through zone boundary
//            When show_ifvg=true: zone flips colour on first violation, removed on second
//            When show_ifvg=false: zone deleted immediately on violation
//            Also removed after fvg_max_bars regardless
// =============================================================================
var bfvg_top  = array.new_float()
var bfvg_bot  = array.new_float()
var bfvg_box  = array.new_box()
var bfvg_flip = array.new_bool()
var bfvg_age  = array.new_int()

var sfvg_top  = array.new_float()
var sfvg_bot  = array.new_float()
var sfvg_box  = array.new_box()
var sfvg_flip = array.new_bool()
var sfvg_age  = array.new_int()

is_bull_fvg = show_fvg and low > high[2]
is_bear_fvg = show_fvg and high < low[2]

if is_bull_fvg
    bx = box.new(bar_index[2], low, bar_index + 20, high[2], border_color=col_bull_fvg_bdr, bgcolor=col_bull_fvg, border_width=fvg_bdr_w)
    array.push(bfvg_top,  low)
    array.push(bfvg_bot,  high[2])
    array.push(bfvg_box,  bx)
    array.push(bfvg_flip, false)
    array.push(bfvg_age,  bar_index)
    if array.size(bfvg_box) > fvg_limit
        box.delete(array.shift(bfvg_box))
        array.shift(bfvg_top)
        array.shift(bfvg_bot)
        array.shift(bfvg_flip)
        array.shift(bfvg_age)

if is_bear_fvg
    bx = box.new(bar_index[2], low[2], bar_index + 20, high, border_color=col_bear_fvg_bdr, bgcolor=col_bear_fvg, border_width=fvg_bdr_w)
    array.push(sfvg_top,  low[2])
    array.push(sfvg_bot,  high)
    array.push(sfvg_box,  bx)
    array.push(sfvg_flip, false)
    array.push(sfvg_age,  bar_index)
    if array.size(sfvg_box) > fvg_limit
        box.delete(array.shift(sfvg_box))
        array.shift(sfvg_top)
        array.shift(sfvg_bot)
        array.shift(sfvg_flip)
        array.shift(sfvg_age)

// Bull FVG update loop
if array.size(bfvg_box) > 0
    for i = array.size(bfvg_box) - 1 to 0
        bx      = array.get(bfvg_box,  i)
        ft      = array.get(bfvg_top,  i)
        fb      = array.get(bfvg_bot,  i)
        flipped = array.get(bfvg_flip, i)
        age     = bar_index - array.get(bfvg_age, i)
        box.set_right(bx, bar_index)
        if not flipped and close < fb   // Close below FVG bottom: violated
            if show_ifvg
                box.set_bgcolor(bx,      col_bear_ifvg)
                box.set_border_color(bx, col_bear_ifvg_b)
                array.set(bfvg_flip, i, true)
            else
                box.delete(bx)
                array.remove(bfvg_box,  i)
                array.remove(bfvg_top,  i)
                array.remove(bfvg_bot,  i)
                array.remove(bfvg_flip, i)
                array.remove(bfvg_age,  i)
        else if flipped and close > ft  // iFVG broken upward: remove entirely
            box.delete(bx)
            array.remove(bfvg_box,  i)
            array.remove(bfvg_top,  i)
            array.remove(bfvg_bot,  i)
            array.remove(bfvg_flip, i)
            array.remove(bfvg_age,  i)
        else if fvg_max_bars > 0 and age > fvg_max_bars
            box.delete(bx)
            array.remove(bfvg_box,  i)
            array.remove(bfvg_top,  i)
            array.remove(bfvg_bot,  i)
            array.remove(bfvg_flip, i)
            array.remove(bfvg_age,  i)

// Bear FVG update loop
if array.size(sfvg_box) > 0
    for i = array.size(sfvg_box) - 1 to 0
        bx      = array.get(sfvg_box,  i)
        ft      = array.get(sfvg_top,  i)
        fb      = array.get(sfvg_bot,  i)
        flipped = array.get(sfvg_flip, i)
        age     = bar_index - array.get(sfvg_age, i)
        box.set_right(bx, bar_index)
        if not flipped and close > ft   // Close above FVG top: violated
            if show_ifvg
                box.set_bgcolor(bx,      col_bull_ifvg)
                box.set_border_color(bx, col_bull_ifvg_b)
                array.set(sfvg_flip, i, true)
            else
                box.delete(bx)
                array.remove(sfvg_box,  i)
                array.remove(sfvg_top,  i)
                array.remove(sfvg_bot,  i)
                array.remove(sfvg_flip, i)
                array.remove(sfvg_age,  i)
        else if flipped and close < fb  // iFVG broken downward: remove entirely
            box.delete(bx)
            array.remove(sfvg_box,  i)
            array.remove(sfvg_top,  i)
            array.remove(sfvg_bot,  i)
            array.remove(sfvg_flip, i)
            array.remove(sfvg_age,  i)
        else if fvg_max_bars > 0 and age > fvg_max_bars
            box.delete(bx)
            array.remove(sfvg_box,  i)
            array.remove(sfvg_top,  i)
            array.remove(sfvg_bot,  i)
            array.remove(sfvg_flip, i)
            array.remove(sfvg_age,  i)

// =============================================================================
// 1-2-3 CANDLE MOMENTUM PATTERN
// =============================================================================
bull_123 = close[2] < open[2] and close[1] > open[1] and low[1] > low[2] and close[1] < open[2] and close > high[1] and close > open
bear_123 = close[2] > open[2] and close[1] < open[1] and high[1] < high[2] and close[1] > open[2] and close < low[1]  and close < open

// Colour the 1-2-3 confirmation candle (C3) directly on the chart
barcolor(show_123 and bull_123 ? col_bull_123 : show_123 and bear_123 ? col_bear_123 : na, title="1-2-3 Confirmation")

// =============================================================================
// PREVIOUS DAY HIGH / LOW
// Drawn at start of each new day from yesterday's final H/L.
// Deleted when the next day starts -- no overlap.
// =============================================================================
var float pd_h          = na
var float pd_l          = na
var float td_h          = na
var float td_l          = na
var pdh_lines           = array.new_line()
var pdh_labels          = array.new_label()
var pdl_lines           = array.new_line()
var pdl_labels          = array.new_label()

if new_day
    if not na(td_h)
        pd_h := td_h
        pd_l := td_l
        if show_pdhl and not na(pd_h)
            new_pdh_ln  = line.new(bar_index, pd_h, bar_index + 1, pd_h, color=col_pdh, width=w_pdh, style=sty_pdh, extend=extend.right)
            new_pdh_lbl = label.new(bar_index, pd_h, txt_pdh, style=label.style_label_right, color=col_pdh, textcolor=color.white, size=pdhl_sz)
            new_pdl_ln  = line.new(bar_index, pd_l, bar_index + 1, pd_l, color=col_pdl, width=w_pdl, style=sty_pdl, extend=extend.right)
            new_pdl_lbl = label.new(bar_index, pd_l, txt_pdl, style=label.style_label_right, color=col_pdl, textcolor=color.white, size=pdhl_sz)
            array.push(pdh_lines,  new_pdh_ln)
            array.push(pdh_labels, new_pdh_lbl)
            array.push(pdl_lines,  new_pdl_ln)
            array.push(pdl_labels, new_pdl_lbl)
            // Trim to last LEVELS_MAX_AGE days
            if array.size(pdh_lines) > LEVELS_MAX_AGE
                line.delete(array.shift(pdh_lines))
                label.delete(array.shift(pdh_labels))
                line.delete(array.shift(pdl_lines))
                label.delete(array.shift(pdl_labels))
    td_h := high
    td_l := low
else
    td_h := na(td_h) ? high : math.max(td_h, high)
    td_l := na(td_l) ? low  : math.min(td_l, low)

// =============================================================================
// ASIA SESSION HIGH / LOW  (23:00 to 08:00 GMT by default)
// Captured during window, drawn when window ends. Deleted at next Asia open.
// =============================================================================
var float asia_h    = na
var float asia_l    = na
var bool  asia_on   = false
var bool  asia_done = false
var asia_h_lines    = array.new_line()
var asia_h_labels   = array.new_label()
var asia_l_lines    = array.new_line()
var asia_l_labels   = array.new_label()

in_asia    = is_wday and (bar_h >= asia_start_h or bar_h < asia_end_h)
asia_opens = is_wday and bar_h == asia_start_h and bar_hh != asia_start_h
asia_close = is_wday and bar_h == asia_end_h   and bar_hh != asia_end_h

if asia_opens
    asia_h    := high
    asia_l    := low
    asia_on   := true
    asia_done := false

if asia_on and in_asia
    asia_h := math.max(asia_h, high)
    asia_l := math.min(asia_l, low)

if asia_close and not asia_done and not na(asia_h)
    asia_on   := false
    asia_done := true
    if show_asia
        new_a_h_ln  = line.new(bar_index, asia_h, bar_index + 500, asia_h, color=col_asia, width=w_asia, style=sty_asia)
        new_a_h_lbl = label.new(bar_index, asia_h, txt_asia_h, style=label.style_label_right, color=col_asia, textcolor=color.black, size=asia_sz)
        new_a_l_ln  = line.new(bar_index, asia_l, bar_index + 500, asia_l, color=col_asia, width=w_asia, style=sty_asia)
        new_a_l_lbl = label.new(bar_index, asia_l, txt_asia_l, style=label.style_label_right, color=col_asia, textcolor=color.black, size=asia_sz)
        array.push(asia_h_lines,  new_a_h_ln)
        array.push(asia_h_labels, new_a_h_lbl)
        array.push(asia_l_lines,  new_a_l_ln)
        array.push(asia_l_labels, new_a_l_lbl)
        // Trim to last LEVELS_MAX_AGE days
        if array.size(asia_h_lines) > LEVELS_MAX_AGE
            line.delete(array.shift(asia_h_lines))
            label.delete(array.shift(asia_h_labels))
            line.delete(array.shift(asia_l_lines))
            label.delete(array.shift(asia_l_labels))

// =============================================================================
// LIQUIDITY POOLS -- SWING HIGHS (BSL) AND SWING LOWS (SSL)
// Every confirmed swing high = Buy-Side Liquidity (stop orders cluster above).
// Every confirmed swing low  = Sell-Side Liquidity (stop orders cluster below).
// SWEEP: price wicks through the level but body closes back on the correct side.
//   BSL sweep = wick above + close below -> bearish reversal signal.
//   SSL sweep = wick below + close above -> bullish reversal signal.
// INVALIDATED: body closes through the level -> level removed.
// This is London Viking's core framework: price hunts liquidity to fuel the
// real move in the opposite direction. Wait for the sweep, then the MSS/CISD.
// =============================================================================
ph_eql = ta.pivothigh(high, eql_lb, eql_lb)
pl_eql = ta.pivotlow(low,   eql_lb, eql_lb)

var bsl_levels = array.new_float()
var bsl_lines  = array.new_line()
var bsl_labels = array.new_label()
var bsl_taken  = array.new_bool()
var ssl_levels = array.new_float()
var ssl_lines  = array.new_line()
var ssl_labels = array.new_label()
var ssl_taken  = array.new_bool()

// Add new BSL on confirmed swing high
// Line is drawn from the pivot bar. Label exists but with EMPTY TEXT (invisible)
// until the level is taken (swept or broken). When taken, the line FREEZES at the
// take-bar and the label becomes visible -- BOS-style horizontal line connecting
// the swing high to the candle that took it.
if not na(ph_eql) and show_eql
    bsl_ln  = line.new(bar_index[eql_lb], ph_eql, bar_index + 50, ph_eql, color=col_bsl, width=w_eql, style=sty_eql)
    bsl_lbl = label.new(bar_index[eql_lb], ph_eql, "", style=label.style_none, textcolor=col_bsl, size=eql_sz)
    array.push(bsl_levels, ph_eql)
    array.push(bsl_lines,  bsl_ln)
    array.push(bsl_labels, bsl_lbl)
    array.push(bsl_taken,  false)
    if array.size(bsl_levels) > eql_max
        line.delete(array.shift(bsl_lines))
        label.delete(array.shift(bsl_labels))
        array.shift(bsl_levels)
        array.shift(bsl_taken)

// Add new SSL on confirmed swing low
if not na(pl_eql) and show_eql
    ssl_ln  = line.new(bar_index[eql_lb], pl_eql, bar_index + 50, pl_eql, color=col_ssl, width=w_eql, style=sty_eql)
    ssl_lbl = label.new(bar_index[eql_lb], pl_eql, "", style=label.style_none, textcolor=col_ssl, size=eql_sz)
    array.push(ssl_levels, pl_eql)
    array.push(ssl_lines,  ssl_ln)
    array.push(ssl_labels, ssl_lbl)
    array.push(ssl_taken,  false)
    if array.size(ssl_levels) > eql_max
        line.delete(array.shift(ssl_lines))
        label.delete(array.shift(ssl_labels))
        array.shift(ssl_levels)
        array.shift(ssl_taken)

// BSL update -- extend active lines, freeze taken ones, fire alerts on sweep
var bool bsl_swept = false
bsl_swept := false
if show_eql and array.size(bsl_levels) > 0
    for i = array.size(bsl_levels) - 1 to 0
        lvl    = array.get(bsl_levels, i)
        ln     = array.get(bsl_lines,  i)
        lbl    = array.get(bsl_labels, i)
        taken  = array.get(bsl_taken,  i)
        if not taken
            if close > lvl
                // Body closed above BSL -- LEVEL TAKEN by break
                // Freeze line at this bar, reveal label centered on the now-static line
                line.set_x2(ln, bar_index)
                label.set_x(lbl, math.round((line.get_x1(ln) + bar_index) / 2))
                label.set_text(lbl, txt_bsl)
                array.set(bsl_taken, i, true)
            else if high > lvl and close <= lvl
                // Wick above BSL, body closed back -- LEVEL TAKEN by sweep (bearish reversal)
                bsl_swept := true
                line.set_x2(ln, bar_index)
                label.set_x(lbl, math.round((line.get_x1(ln) + bar_index) / 2))
                label.set_text(lbl, txt_bsl)
                array.set(bsl_taken, i, true)
            else
                // Still active -- extend line right, label stays invisible (empty text)
                line.set_x2(ln, bar_index + 50)

// SSL update -- extend active lines, freeze taken ones, fire alerts on sweep
var bool ssl_swept = false
ssl_swept := false
if show_eql and array.size(ssl_levels) > 0
    for i = array.size(ssl_levels) - 1 to 0
        lvl    = array.get(ssl_levels, i)
        ln     = array.get(ssl_lines,  i)
        lbl    = array.get(ssl_labels, i)
        taken  = array.get(ssl_taken,  i)
        if not taken
            if close < lvl
                // Body closed below SSL -- LEVEL TAKEN by break
                line.set_x2(ln, bar_index)
                label.set_x(lbl, math.round((line.get_x1(ln) + bar_index) / 2))
                label.set_text(lbl, txt_ssl)
                array.set(ssl_taken, i, true)
            else if low < lvl and close >= lvl
                // Wick below SSL, body closed back -- LEVEL TAKEN by sweep (bullish reversal)
                ssl_swept := true
                line.set_x2(ln, bar_index)
                label.set_x(lbl, math.round((line.get_x1(ln) + bar_index) / 2))
                label.set_text(lbl, txt_ssl)
                array.set(ssl_taken, i, true)
            else
                // Still active -- extend line right, label stays invisible (empty text)
                line.set_x2(ln, bar_index + 50)

// =============================================================================
// POI -- POINTS OF INTEREST (MACRO STRUCTURAL LEVELS)
// Two-tier system: BSL/SSL = micro intraday sweeps (short-term).
//                  POI     = macro structure pivots (days to weeks).
// POI levels persist -- they are NOT removed on first body-close-through.
// When price body-closes through a POI it changes to the "tested/flipped" colour
// to indicate SR flip potential, but stays on the chart for ongoing reference.
// The combination: use POI to frame the bigger picture (where is price heading
// in the macro), then use BSL/SSL sweeps to time the micro entries within it.
// =============================================================================
ph_poi = ta.pivothigh(high, poi_lb, poi_lb)
pl_poi = ta.pivotlow(low,   poi_lb, poi_lb)

var poi_h_levels = array.new_float()
var poi_h_lines  = array.new_line()
var poi_h_labels = array.new_label()
var poi_h_flip   = array.new_bool()   // true once price body-closed above (SR flip)

var poi_l_levels = array.new_float()
var poi_l_lines  = array.new_line()
var poi_l_labels = array.new_label()
var poi_l_flip   = array.new_bool()   // true once price body-closed below (SR flip)

// Add new POI resistance (swing high)
if not na(ph_poi) and show_poi
    p_ln  = line.new(bar_index[poi_lb], ph_poi, bar_index + 200, ph_poi, color=col_poi, width=w_poi, style=sty_poi)
    p_lbl = label.new(bar_index[poi_lb], ph_poi, txt_poi, style=label.style_label_right, color=col_poi, textcolor=color.white, size=poi_sz)
    array.push(poi_h_levels, ph_poi)
    array.push(poi_h_lines,  p_ln)
    array.push(poi_h_labels, p_lbl)
    array.push(poi_h_flip,   false)
    if array.size(poi_h_levels) > poi_max
        line.delete(array.shift(poi_h_lines))
        label.delete(array.shift(poi_h_labels))
        array.shift(poi_h_levels)
        array.shift(poi_h_flip)

// Add new POI support (swing low)
if not na(pl_poi) and show_poi
    p_ln  = line.new(bar_index[poi_lb], pl_poi, bar_index + 200, pl_poi, color=col_poi, width=w_poi, style=sty_poi)
    p_lbl = label.new(bar_index[poi_lb], pl_poi, txt_poi, style=label.style_label_right, color=col_poi, textcolor=color.white, size=poi_sz)
    array.push(poi_l_levels, pl_poi)
    array.push(poi_l_lines,  p_ln)
    array.push(poi_l_labels, p_lbl)
    array.push(poi_l_flip,   false)
    if array.size(poi_l_levels) > poi_max
        line.delete(array.shift(poi_l_lines))
        label.delete(array.shift(poi_l_labels))
        array.shift(poi_l_levels)
        array.shift(poi_l_flip)

// POI resistance update -- extend and flip colour if price closes above
if show_poi and array.size(poi_h_levels) > 0
    for i = array.size(poi_h_levels) - 1 to 0
        lvl      = array.get(poi_h_levels, i)
        ln       = array.get(poi_h_lines,  i)
        lbl      = array.get(poi_h_labels, i)
        flipped  = array.get(poi_h_flip,   i)
        line.set_x2(ln, bar_index + 100)
        // Body closed above resistance POI -- SR flip (was resistance, now potential support)
        if not flipped and close > lvl
            line.set_color(ln,    col_poi_flip)
            label.set_color(lbl,  col_poi_flip)
            label.set_text(lbl,   txt_poi + " (flip)")
            array.set(poi_h_flip, i, true)

// POI support update -- extend and flip colour if price closes below
if show_poi and array.size(poi_l_levels) > 0
    for i = array.size(poi_l_levels) - 1 to 0
        lvl      = array.get(poi_l_levels, i)
        ln       = array.get(poi_l_lines,  i)
        lbl      = array.get(poi_l_labels, i)
        flipped  = array.get(poi_l_flip,   i)
        line.set_x2(ln, bar_index + 100)
        // Body closed below support POI -- SR flip (was support, now potential resistance)
        if not flipped and close < lvl
            line.set_color(ln,    col_poi_flip)
            label.set_color(lbl,  col_poi_flip)
            label.set_text(lbl,   txt_poi + " (flip)")
            array.set(poi_l_flip, i, true)

// =============================================================================
// ALERTS
// =============================================================================
// alert() fires automatically on every signal - no manual reset required.
// HOW TO SET UP IN TRADINGVIEW (one-time only):
//   Add Alert - select this indicator - Condition: "Any alert() function call"
//   Trigger: Once Per Bar Close - Save. Done. All signals fire through it.
//
// alertcondition() entries are kept below for the TradingView dropdown picker.
// Use those only if you want a separate per-signal alert with custom frequency.
// =============================================================================

// -- Primary crossover ---------------------------------------------------------
if bullCross
    alert(" LONG | " + syminfo.ticker + " | EMA 9 crossed above 21 | Price: " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
if bearCross
    alert(" SHORT | " + syminfo.ticker + " | EMA 9 crossed below 21 | Price: " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)

// -- 1-2-3 pattern -------------------------------------------------------------
if bull_123
    alert(" 1-2-3 LONG | " + syminfo.ticker + " | Price: " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
if bear_123
    alert(" 1-2-3 SHORT | " + syminfo.ticker + " | Price: " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)

// -- Secondary entries ---------------------------------------------------------
if ema9_bounce_bull
    alert(" ENTRY 1 LONG | " + syminfo.ticker + " | 9 EMA Pullback at: " + str.tostring(ema9, "#.##"), alert.freq_once_per_bar_close)
if ema9_bounce_bear
    alert(" ENTRY 1 SHORT | " + syminfo.ticker + " | 9 EMA Pullback at: " + str.tostring(ema9, "#.##"), alert.freq_once_per_bar_close)
if ema21_bounce_bull
    alert(" ENTRY 2 LONG | " + syminfo.ticker + " | 21 EMA Pullback at: " + str.tostring(ema21, "#.##"), alert.freq_once_per_bar_close)
if ema21_bounce_bear
    alert(" ENTRY 2 SHORT | " + syminfo.ticker + " | 21 EMA Pullback at: " + str.tostring(ema21, "#.##"), alert.freq_once_per_bar_close)
if ema9_reclaim_bull
    alert(" ENTRY 3 LONG | " + syminfo.ticker + " | 9 EMA Reclaim at: " + str.tostring(ema9, "#.##"), alert.freq_once_per_bar_close)
if ema9_reclaim_bear
    alert(" ENTRY 3 SHORT | " + syminfo.ticker + " | 9 EMA Reclaim at: " + str.tostring(ema9, "#.##"), alert.freq_once_per_bar_close)

// -- Liquidity sweeps ----------------------------------------------------------
if bsl_swept
    alert(" SWEEP BSL | " + syminfo.ticker + " | Buy-Side swept. Watch for bearish MSS + iFVG | " + str.tostring(high, "#.##"), alert.freq_once_per_bar_close)
if ssl_swept
    alert(" SWEEP SSL | " + syminfo.ticker + " | Sell-Side swept. Watch for bullish MSS + iFVG | " + str.tostring(low, "#.##"), alert.freq_once_per_bar_close)

// -- alertcondition (TradingView dropdown - kept for manual per-signal setup) --
alertcondition(bullCross,         " - LONG crossover",      "EMA 9 crossed above EMA 21")
alertcondition(bearCross,         " - SHORT crossover",     "EMA 9 crossed below EMA 21")
alertcondition(bull_123,          " - 1-2-3 LONG",          "Bullish 1-2-3 pattern confirmed")
alertcondition(bear_123,          " - 1-2-3 SHORT",         "Bearish 1-2-3 pattern confirmed")
alertcondition(ema9_bounce_bull,  " - Entry 1 LONG",        "9 EMA pullback bounce long")
alertcondition(ema9_bounce_bear,  " - Entry 1 SHORT",       "9 EMA pullback bounce short")
alertcondition(ema21_bounce_bull, " - Entry 2 LONG",        "21 EMA pullback bounce long")
alertcondition(ema21_bounce_bear, " - Entry 2 SHORT",       "21 EMA pullback bounce short")
alertcondition(ema9_reclaim_bull, " - Entry 3 LONG",        "9 EMA reclaim long")
alertcondition(ema9_reclaim_bear, " - Entry 3 SHORT",       "9 EMA reclaim short")
alertcondition(bsl_swept,         " - BSL Sweep",            "Buy-side liquidity swept. Watch for bearish reversal.")
alertcondition(ssl_swept,         " - SSL Sweep",            "Sell-side liquidity swept. Watch for bullish reversal.")
````
