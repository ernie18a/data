# (ORB) Opening Range and Fib Pullback

- url: https://www.tradingview.com/script/mI9Emxw9-ORB-Opening-Range-and-Fib-Pullback/
- type: indicator
- pine_id: PUB;300e8e9561304e40ab4db2a5649f2a11
- version: 1.0

## Description

Opening Range — Fib Pullback + ORB    

The indicator is provide Buy or sell indication based on the below settings:
                                                                                                                                                                                                        
  - FIB BUY 50% — pullback to the 50% Fib level with rejection                                                                                                                                          
  - FIB BUY 70% — deeper pullback to 70% Fib level                                                                                                                                                      
  - ORB SELL — breakout below OR Low at 1.9× average volume                                                                                                                                             
  - ORB BUY 11.6× — breakout above OR High on very heavy volume (11.6× avg)                                                                                                                             
  - Info table (bottom right): 15min OR, Bearish direction, OR High/Low levels, ORB Status = Intact

## Source Code

````pine

//@version=6
indicator("Opening Range — Fib Pullback + ORB", overlay=true, max_lines_count=20, max_labels_count=300)

// ━━━━━━━━━━━━━━━━━━━━ INPUTS ━━━━━━━━━━━━━━━━━━━━

grp_t = "── Session & Window ──"
sess_h    = input.int(9,  "Session Start Hour",     minval=0, maxval=23, group=grp_t)
sess_m    = input.int(15, "Session Start Minute",   minval=0, maxval=59, group=grp_t)
or_dur    = input.int(15, "Opening Range Duration (min)", minval=1, maxval=240, step=5, group=grp_t,
            tooltip="15 = first 15min candle | 30 = first 30min | 60 = first 1hr")
win_end_h = input.int(12, "Signal Window End Hour", minval=0, maxval=23, group=grp_t)
win_end_m = input.int(0,  "Signal Window End Min",  minval=0, maxval=59, group=grp_t)
i_tz      = input.string("Asia/Kolkata", "Timezone",
            options=["Asia/Kolkata","America/New_York","Europe/London","Asia/Tokyo","Australia/Sydney","UTC"],
            group=grp_t)

grp_f = "── Fibonacci Pullback ──"
enable_fib = input.bool(true,  "Enable Fib Pullback Signals", group=grp_f)
use_50     = input.bool(true,  "50.0% Zone",  group=grp_f)
use_618    = input.bool(true,  "61.8% Zone",  group=grp_f)
use_70     = input.bool(true,  "70.0% Zone",  group=grp_f)
zone_m     = input.float(0.25, "Zone Tolerance (ATR×)", step=0.05, minval=0.05, group=grp_f)
wick_r     = input.float(1.0,  "Min Wick:Body Ratio",   step=0.1,  minval=0.3,  group=grp_f,
             tooltip="Lower/upper wick must be >= body x this value to confirm rejection")

grp_o = "── ORB — Open Range Breakout ──"
enable_orb  = input.bool(true,  "Enable ORB Signals",           group=grp_o)
vol_mult    = input.float(1.5,  "Heavy Volume Multiplier",       step=0.1, minval=1.0, group=grp_o,
              tooltip="Volume must be > avg_volume × this value to qualify as heavy")
vol_lb      = input.int(20,     "Volume Avg Lookback (bars)",    minval=5,  group=grp_o)
orb_once    = input.bool(true,  "Signal Once Per Direction/Day", group=grp_o,
              tooltip="Fire ORB signal only on the first breakout each direction per day")

grp_d = "── Display ──"
show_lines = input.bool(true,  "Show OR Lines & Fib Levels", group=grp_d)
show_box   = input.bool(true,  "Show Opening Range Box",     group=grp_d)
show_lbls  = input.bool(true,  "Show Price Labels",          group=grp_d)

// ━━━━━━━━━━━━━━━━━━━━ TIME HELPERS ━━━━━━━━━━━━━━━━━━━━

bar_h  = hour(time,       i_tz)
bar_m  = minute(time,     i_tz)
bar_d  = dayofmonth(time, i_tz)
bar_mo = month(time,      i_tz)
bar_yr = year(time,       i_tz)

day_id = bar_yr * 10000 + bar_mo * 100 + bar_d

sess_mins   = sess_h * 60 + sess_m
or_end_mins = sess_mins + or_dur
bar_mins    = bar_h  * 60 + bar_m

in_or   = bar_mins >= sess_mins and bar_mins < or_end_mins
in_win  = bar_h < win_end_h or (bar_h == win_end_h and bar_m <= win_end_m)

// ━━━━━━━━━━━━━━━━━━━━ OPENING RANGE TRACKER ━━━━━━━━━━━━━━━━━━━━

var float or_high     = na
var float or_low      = na
var float or_open     = na
var float or_close    = na
var bool  or_done     = false
var bool  or_bull     = false
var int   or_day      = 0
var int   or_bar_x    = -1   // bar_index of first OR bar

// Reset on new trading day
if day_id != or_day
    or_high  := na
    or_low   := na
    or_open  := na
    or_close := na
    or_done  := false
    or_bull  := false
    or_day   := day_id
    or_bar_x := -1

// Accumulate OR high/low across all bars inside the OR window
if in_or
    if na(or_high)
        or_open  := open
        or_bar_x := bar_index
    or_high  := na(or_high) ? high   : math.max(or_high, high)
    or_low   := na(or_low)  ? low    : math.min(or_low,  low)
    or_close := close

// Mark OR complete on the first bar that exits the OR window
if not or_done and not na(or_high) and not in_or
    or_done := true
    or_bull := or_close > or_open

// ━━━━━━━━━━━━━━━━━━━━ FIBONACCI LEVELS (on OR range) ━━━━━━━━━━━━━━━━━━━━

or_rng  = or_done and not na(or_high) ? or_high - or_low : float(na)

fib_50  = float(na)
fib_618 = float(na)
fib_70  = float(na)

if not na(or_rng) and or_rng > 0
    if or_bull
        fib_50  := or_high - or_rng * 0.500
        fib_618 := or_high - or_rng * 0.618
        fib_70  := or_high - or_rng * 0.700
    else
        fib_50  := or_low  + or_rng * 0.500
        fib_618 := or_low  + or_rng * 0.618
        fib_70  := or_low  + or_rng * 0.700

// ━━━━━━━━━━━━━━━━━━━━ CANDLE REJECTION PATTERNS ━━━━━━━━━━━━━━━━━━━━

atr   = ta.atr(14)
zone  = atr * zone_m

c_hi  = math.max(open, close)
c_lo  = math.min(open, close)
body  = math.max(c_hi - c_lo, syminfo.mintick)
rng   = high - low
wk_lo = c_lo  - low
wk_hi = high  - c_hi

bull_rej = close > open and wk_lo >= body * wick_r
bear_rej = close < open and wk_hi >= body * wick_r
bull_eng = close > open and close >= open[1] and open <= close[1] and close[1] < open[1]
bear_eng = close < open and close <= open[1] and open >= close[1] and close[1] > open[1]
confirm_bull = bull_rej or bull_eng
confirm_bear = bear_rej or bear_eng

// ━━━━━━━━━━━━━━━━━━━━ FIB PULLBACK SIGNALS ━━━━━━━━━━━━━━━━━━━━

can_trade = or_done and in_win and not in_or

touch_50_b  = use_50  and not na(fib_50)  and low <= fib_50  + zone and low  >= fib_50  - zone
touch_618_b = use_618 and not na(fib_618) and low <= fib_618 + zone and low  >= fib_618 - zone
touch_70_b  = use_70  and not na(fib_70)  and low <= fib_70  + zone and low  >= fib_70  - zone

touch_50_s  = use_50  and not na(fib_50)  and high >= fib_50  - zone and high <= fib_50  + zone
touch_618_s = use_618 and not na(fib_618) and high >= fib_618 - zone and high <= fib_618 + zone
touch_70_s  = use_70  and not na(fib_70)  and high >= fib_70  - zone and high <= fib_70  + zone

fib_buy = enable_fib and can_trade and or_bull     and (touch_50_b or touch_618_b or touch_70_b) and confirm_bull
fib_sel = enable_fib and can_trade and not or_bull and (touch_50_s or touch_618_s or touch_70_s) and confirm_bear

fib_buy_lvl = touch_50_b ? "50%" : touch_618_b ? "61.8%" : "70%"
fib_sel_lvl = touch_50_s ? "50%" : touch_618_s ? "61.8%" : "70%"

// ━━━━━━━━━━━━━━━━━━━━ ORB — OPEN RANGE BREAKOUT ━━━━━━━━━━━━━━━━━━━━

avg_vol    = ta.sma(volume, vol_lb)
heavy_vol  = volume > avg_vol * vol_mult

// One-per-day flags
var bool orb_buy_done = false
var bool orb_sel_done = false
var int  orb_day      = 0

if day_id != orb_day
    orb_buy_done := false
    orb_sel_done := false
    orb_day      := day_id

// ORB: close breaks beyond OR boundary on heavy volume
orb_buy_raw = enable_orb and can_trade and not na(or_high) and close > or_high and heavy_vol
orb_sel_raw = enable_orb and can_trade and not na(or_low)  and close < or_low  and heavy_vol

orb_buy = orb_buy_raw and (not orb_once or not orb_buy_done)
orb_sel = orb_sel_raw and (not orb_once or not orb_sel_done)

if orb_buy
    orb_buy_done := true
if orb_sel
    orb_sel_done := true

// ━━━━━━━━━━━━━━━━━━━━ DRAW OR LINES & FIB (current day) ━━━━━━━━━━━━━━━━━━━━

var line ln_orh  = na
var line ln_orl  = na
var line ln_50   = na
var line ln_618  = na
var line ln_70   = na
var box  bx_or   = na
var label lb_orh = na
var label lb_orl = na
var label lb_50  = na
var label lb_618 = na
var label lb_70  = na

if show_lines and or_done and barstate.islast and or_bar_x >= 0
    line.delete(ln_orh)
    line.delete(ln_orl)
    line.delete(ln_50)
    line.delete(ln_618)
    line.delete(ln_70)
    box.delete(bx_or)
    label.delete(lb_orh)
    label.delete(lb_orl)
    label.delete(lb_50)
    label.delete(lb_618)
    label.delete(lb_70)

    x1 = or_bar_x
    x2 = bar_index + 8
    ccol = or_bull ? color.green : color.red

    // Opening range box
    if show_box
        or_end_bar = or_bar_x + math.round(or_dur / timeframe.in_seconds() * 60)
        bx_or := box.new(x1, or_high, math.max(x1 + 1, or_end_bar), or_low,
                         bgcolor=color.new(ccol, 82),
                         border_color=color.new(ccol, 30), border_width=2)

    // OR High / Low horizontal lines
    ln_orh := line.new(x1, or_high, x2, or_high, color=color.new(ccol, 10), width=2, style=line.style_solid)
    ln_orl := line.new(x1, or_low,  x2, or_low,  color=color.new(ccol, 10), width=2, style=line.style_solid)

    if show_lbls
        lb_orh := label.new(x2, or_high, "OR High  " + str.tostring(math.round(or_high, 2)),
                            style=label.style_label_left, size=size.small,
                            color=color.new(ccol, 75), textcolor=ccol)
        lb_orl := label.new(x2, or_low, "OR Low  " + str.tostring(math.round(or_low, 2)),
                            style=label.style_label_left, size=size.small,
                            color=color.new(ccol, 75), textcolor=ccol)

    // Fib levels
    if use_50 and not na(fib_50)
        ln_50 := line.new(x1, fib_50, x2, fib_50, color=color.new(color.orange, 0), width=1, style=line.style_dashed)
        if show_lbls
            lb_50 := label.new(x2, fib_50, "50.0%  " + str.tostring(math.round(fib_50, 2)),
                               style=label.style_label_left, size=size.small,
                               color=color.new(color.orange, 75), textcolor=color.orange)

    if use_618 and not na(fib_618)
        ln_618 := line.new(x1, fib_618, x2, fib_618, color=color.new(color.blue, 0), width=1, style=line.style_dashed)
        if show_lbls
            lb_618 := label.new(x2, fib_618, "61.8%  " + str.tostring(math.round(fib_618, 2)),
                                style=label.style_label_left, size=size.small,
                                color=color.new(color.blue, 75), textcolor=color.blue)

    if use_70 and not na(fib_70)
        ln_70 := line.new(x1, fib_70, x2, fib_70, color=color.new(color.purple, 0), width=1, style=line.style_dashed)
        if show_lbls
            lb_70 := label.new(x2, fib_70, "70.0%  " + str.tostring(math.round(fib_70, 2)),
                               style=label.style_label_left, size=size.small,
                               color=color.new(color.purple, 75), textcolor=color.purple)

// ━━━━━━━━━━━━━━━━━━━━ SIGNAL LABELS (all history) ━━━━━━━━━━━━━━━━━━━━

// Fib Pullback BUY
if fib_buy
    label.new(bar_index, low - zone * 2,
              "FIB BUY\n" + fib_buy_lvl,
              style=label.style_label_up,
              color=color.new(color.green, 0),
              textcolor=color.white, size=size.normal)

// Fib Pullback SELL
if fib_sel
    label.new(bar_index, high + zone * 2,
              "FIB SELL\n" + fib_sel_lvl,
              style=label.style_label_down,
              color=color.new(color.red, 0),
              textcolor=color.white, size=size.normal)

// ORB BUY — breakout above OR High on heavy volume
if orb_buy
    label.new(bar_index, low - zone * 3,
              "ORB BUY\n" + str.tostring(math.round(volume / avg_vol, 1)) + "x Vol",
              style=label.style_label_up,
              color=color.new(color.lime, 0),
              textcolor=color.black, size=size.normal)

// ORB SELL — breakdown below OR Low on heavy volume
if orb_sel
    label.new(bar_index, high + zone * 3,
              "ORB SELL\n" + str.tostring(math.round(volume / avg_vol, 1)) + "x Vol",
              style=label.style_label_down,
              color=color.new(color.fuchsia, 0),
              textcolor=color.white, size=size.normal)

// ━━━━━━━━━━━━━━━━━━━━ SESSION INFO TABLE ━━━━━━━━━━━━━━━━━━━━

if barstate.islast
    var table info = table.new(position.bottom_right, 2, 9,
                               bgcolor=color.new(color.black, 20),
                               border_color=color.new(color.gray, 50), border_width=1,
                               frame_color=color.gray, frame_width=1)

    hbg  = color.new(#0d47a1, 10)
    str_dur = str.tostring(or_dur) + "min OR"

    table.cell(info, 0, 0, str_dur, bgcolor=hbg, text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, or_done ? (or_bull ? "BULLISH" : "BEARISH") : "Building...",
               bgcolor=or_done ? (or_bull ? color.new(color.green, 30) : color.new(color.red, 30)) : color.new(color.gray, 50),
               text_color=color.white, text_size=size.small)

    table.cell(info, 0, 1, "OR High", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 1, not na(or_high) ? str.tostring(math.round(or_high, 2)) : "--",
               text_color=color.white, text_size=size.small)

    table.cell(info, 0, 2, "OR Low", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 2, not na(or_low) ? str.tostring(math.round(or_low, 2)) : "--",
               text_color=color.white, text_size=size.small)

    table.cell(info, 0, 3, "50%", text_color=color.orange, text_size=size.small)
    table.cell(info, 1, 3, not na(fib_50) ? str.tostring(math.round(fib_50, 2)) : "--",
               text_color=color.orange, text_size=size.small)

    table.cell(info, 0, 4, "61.8%", text_color=color.blue, text_size=size.small)
    table.cell(info, 1, 4, not na(fib_618) ? str.tostring(math.round(fib_618, 2)) : "--",
               text_color=color.blue, text_size=size.small)

    table.cell(info, 0, 5, "70%", text_color=color.purple, text_size=size.small)
    table.cell(info, 1, 5, not na(fib_70) ? str.tostring(math.round(fib_70, 2)) : "--",
               text_color=color.purple, text_size=size.small)

    orb_status = orb_buy_done ? "Broken UP" : orb_sel_done ? "Broken DOWN" : or_done ? "Intact" : "--"
    orb_col    = orb_buy_done ? color.new(color.lime, 20) : orb_sel_done ? color.new(color.fuchsia, 20) : color.new(color.gray, 50)

    table.cell(info, 0, 6, "ORB Status", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 6, orb_status, bgcolor=orb_col, text_color=color.white, text_size=size.small)

    cur_vol_x = avg_vol > 0 ? math.round(volume / avg_vol * 10) / 10 : 0.0
    table.cell(info, 0, 7, "Vol x Avg", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 7, str.tostring(cur_vol_x) + "x",
               text_color=cur_vol_x >= vol_mult ? color.lime : color.gray, text_size=size.small)

    table.cell(info, 0, 8, "Signal Window", text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 8, in_win ? "ACTIVE" : "CLOSED",
               text_color=in_win ? color.lime : color.red, text_size=size.small)

// ━━━━━━━━━━━━━━━━━━━━ ALERTS ━━━━━━━━━━━━━━━━━━━━

alertcondition(fib_buy, "Fib Pullback BUY",  "Opening range Fib pullback BUY signal")
alertcondition(fib_sel, "Fib Pullback SELL", "Opening range Fib pullback SELL signal")
alertcondition(orb_buy, "ORB BUY — Heavy Volume",  "ORB breakout above OR High on heavy volume")
alertcondition(orb_sel, "ORB SELL — Heavy Volume", "ORB breakdown below OR Low on heavy volume")
````
