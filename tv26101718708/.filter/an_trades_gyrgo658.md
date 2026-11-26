# AN Trades

- url: https://www.tradingview.com/script/GyRgo658-AN-Trades/
- type: indicator
- pine_id: PUB;feb0d4b938694d878709263180053d4c
- version: 1.0

## Description

IFVG indicator custom made by AN trades using full Strategy with a setup rating

## Source Code

````pine



// This Pine Script® code is subject to the Mozilla Public License 2.0
// © AN Trades — Entry Signal Indicator
// IFVG (mitigated/unmitigated) + Liquidity Sweep + CISD + SMT
// DOL filter + Data Wick filter + Dynamic RR + Setup Rating
//@version=6
indicator("AN Trades", shorttitle="AN Trades", overlay=true,
          max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
var G1 = "── HTF Bias ──"
htf_tf       = input.timeframe("5",   "HTF Timeframe (5m+)",         group=G1)
htf_show     = input.bool(true,        "Show HTF FVG Zones",          group=G1)

var G2 = "── Entry Filters ──"
require_cisd = input.bool(true,  "Require CISD",                      group=G2)
require_smt  = input.bool(false, "Require SMT (extra confluence)",    group=G2)
smt_sym      = input.symbol("NQ1!", "SMT Comparison Symbol",          group=G2)
smt_len      = input.int(5,  "SMT Lookback",  minval=2, maxval=30,    group=G2)
filter_dol   = input.bool(true,  "Block trade if opposing DOL nearby",group=G2)
filter_wick  = input.bool(true,  "Block trade on opposing data wick", group=G2)
wick_mult    = input.float(2.5,  "Data Wick Threshold (× avg range)", minval=1.0, step=0.5, group=G2)

var G3 = "── Risk / Reward ──"
show_sl_tp   = input.bool(true,  "Show SL / TP Lines",                group=G3)
rr_default   = input.float(1.0,  "Default RR (used unless DOL farther)", minval=0.5, step=0.5, group=G3)
rr_max       = input.float(3.0,  "Max RR cap",                        minval=1.0, step=0.5,   group=G3)

var G4 = "── Structure & Sweeps ──"
swing_len    = input.int(10, "Swing Lookback",    minval=3, maxval=50, group=G4)
sweep_bars   = input.int(10, "Sweep Valid (bars)", minval=1, maxval=50,group=G4)
show_sweeps  = input.bool(true, "Show Sweep Labels",                  group=G4)

var G5 = "── FVG / IFVG Zones ──"
show_ifvg    = input.bool(true,  "Show IFVG Zones",                   group=G5)
show_fvg_raw = input.bool(true,  "Show Unmitigated FVGs",             group=G5)
fvg_extend   = input.int(40,     "Extend Zones Right (bars)", minval=5, maxval=500, group=G5)
max_fvgs     = input.int(15,     "Max FVGs to Track",         minval=5, maxval=50,  group=G5)

// ═══════════════════════════════════════════════════════════════════════════
// COLOURS
// ═══════════════════════════════════════════════════════════════════════════
c_long    = #00e676
c_short   = #ff1744
c_htf_b   = color.new(#00bcd4, 82)
c_htf_s   = color.new(#f44336, 82)
c_ifvg_b  = color.new(#69f0ae, 72)
c_ifvg_s  = color.new(#ff6d00, 72)
c_fvg_b   = color.new(color.green, 88)
c_fvg_s   = color.new(color.red,   88)
c_itl     = color.new(#ffeb3b, 60)   // ITL/ITH midpoint line colour

// ═══════════════════════════════════════════════════════════════════════════
// HTF FVG  (bias layer)
// ═══════════════════════════════════════════════════════════════════════════
htf_h0  = request.security(syminfo.tickerid, htf_tf, high,      lookahead=barmerge.lookahead_off)
htf_l0  = request.security(syminfo.tickerid, htf_tf, low,       lookahead=barmerge.lookahead_off)
htf_h2  = request.security(syminfo.tickerid, htf_tf, high[2],   lookahead=barmerge.lookahead_off)
htf_l2  = request.security(syminfo.tickerid, htf_tf, low[2],    lookahead=barmerge.lookahead_off)
htf_bi  = request.security(syminfo.tickerid, htf_tf, bar_index,  lookahead=barmerge.lookahead_off)

new_htf      = ta.change(htf_bi) != 0
htf_bull_fvg = htf_show and new_htf and htf_h2 < htf_l0
htf_bear_fvg = htf_show and new_htf and htf_l2 > htf_h0

var int htf_bias = 0
if htf_bull_fvg
    htf_bias := 1
if htf_bear_fvg
    htf_bias := -1

if htf_bull_fvg
    box.new(bar_index, htf_l0, bar_index + fvg_extend, htf_h2,
            bgcolor=c_htf_b, border_color=color.new(#00bcd4,40), border_width=1)
    label.new(bar_index, htf_l0, "HTF FVG ▲",
              style=label.style_label_down, color=color.new(#00bcd4,20),
              textcolor=color.white, size=size.tiny)
if htf_bear_fvg
    box.new(bar_index, htf_l2, bar_index + fvg_extend, htf_h0,
            bgcolor=c_htf_s, border_color=color.new(#f44336,40), border_width=1)
    label.new(bar_index, htf_h0, "HTF FVG ▼",
              style=label.style_label_up, color=color.new(#f44336,20),
              textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// CURRENT TF FVG TRACKING
// ═══════════════════════════════════════════════════════════════════════════
var float[] bfvg_top     = array.new_float()
var float[] bfvg_bot     = array.new_float()
var float[] bfvg_mid     = array.new_float()
var bool[]  bfvg_touched = array.new_bool()
var box[]   bfvg_box     = array.new_box()

var float[] sfvg_top     = array.new_float()
var float[] sfvg_bot     = array.new_float()
var float[] sfvg_mid     = array.new_float()
var bool[]  sfvg_touched = array.new_bool()
var box[]   sfvg_box     = array.new_box()

var float[] bifvg_top = array.new_float()
var float[] bifvg_bot = array.new_float()
var float[] bifvg_mid = array.new_float()
var bool[]  bifvg_itl_only = array.new_bool()

var float[] sifvg_top = array.new_float()
var float[] sifvg_bot = array.new_float()
var float[] sifvg_mid = array.new_float()
var bool[]  sifvg_ith_only = array.new_bool()

bull_fvg_new = high[2] < low[0]
bear_fvg_new = low[2]  > high[0]

if bull_fvg_new
    ft = low[0]
    fb = high[2]
    if ft > fb
        if array.size(bfvg_top) >= max_fvgs
            old_bx = array.shift(bfvg_box)
            box.delete(old_bx)
            array.shift(bfvg_top)
            array.shift(bfvg_bot)
            array.shift(bfvg_mid)
            array.shift(bfvg_touched)
        mid = (ft + fb) / 2.0
        b = show_fvg_raw ?
             box.new(bar_index-2, fb, bar_index+fvg_extend, ft,
                     bgcolor=c_fvg_b, border_color=color.new(color.green,60), border_width=1) :
             box.new(bar_index, fb, bar_index, ft,
                     bgcolor=color.new(color.green,100), border_color=color.new(color.green,100))
        if show_fvg_raw
            line.new(bar_index-2, mid, bar_index+fvg_extend, mid,
                     color=c_itl, style=line.style_dotted, width=1)
        array.push(bfvg_top,     ft)
        array.push(bfvg_bot,     fb)
        array.push(bfvg_mid,     mid)
        array.push(bfvg_touched, false)
        array.push(bfvg_box,     b)

if bear_fvg_new
    ft = low[2]
    fb = high[0]
    if ft > fb
        if array.size(sfvg_top) >= max_fvgs
            old_bx = array.shift(sfvg_box)
            box.delete(old_bx)
            array.shift(sfvg_top)
            array.shift(sfvg_bot)
            array.shift(sfvg_mid)
            array.shift(sfvg_touched)
        mid = (ft + fb) / 2.0
        b = show_fvg_raw ?
             box.new(bar_index-2, fb, bar_index+fvg_extend, ft,
                     bgcolor=c_fvg_s, border_color=color.new(color.red,60), border_width=1) :
             box.new(bar_index, fb, bar_index, ft,
                     bgcolor=color.new(color.red,100), border_color=color.new(color.red,100))
        if show_fvg_raw
            line.new(bar_index-2, mid, bar_index+fvg_extend, mid,
                     color=c_itl, style=line.style_dotted, width=1)
        array.push(sfvg_top,     ft)
        array.push(sfvg_bot,     fb)
        array.push(sfvg_mid,     mid)
        array.push(sfvg_touched, false)
        array.push(sfvg_box,     b)

// ── Update FVG mitigation status and detect IFVG inversions ──
var bool ifvg_bull_formed  = false
var bool ifvg_bear_formed  = false
var float ifvg_bull_top    = na
var float ifvg_bull_bot    = na
var float ifvg_bull_mid    = na
var bool ifvg_bull_itl_only = false
var float ifvg_bear_top    = na
var float ifvg_bear_bot    = na
var float ifvg_bear_mid    = na
var bool ifvg_bear_ith_only = false

ifvg_bull_formed := false
ifvg_bear_formed := false

for i = array.size(bfvg_top) - 1 to 0
    ft      = array.get(bfvg_top,     i)
    fb      = array.get(bfvg_bot,     i)
    mid_val = array.get(bfvg_mid,     i)
    touched = array.get(bfvg_touched, i)
    bx      = array.get(bfvg_box,     i)

    wick_in_zone = high >= fb and low <= ft

    if wick_in_zone
        if close < fb
            box.delete(bx)
            if show_ifvg
                box.new(bar_index, fb, bar_index+fvg_extend, ft,
                        bgcolor=c_ifvg_s, border_color=color.new(#ff6d00,20), border_width=2)
                line.new(bar_index, mid_val, bar_index+fvg_extend, mid_val,
                         color=c_itl, style=line.style_dotted, width=1)
                label.new(bar_index, ft, touched ? "IFVG ▼ (ITH)" : "IFVG ▼",
                          style=label.style_label_down,
                          color=color.new(#ff6d00,10), textcolor=color.white, size=size.tiny)
            array.push(sifvg_top,      ft)
            array.push(sifvg_bot,      fb)
            array.push(sifvg_mid,      mid_val)
            array.push(sifvg_ith_only, touched)
            ifvg_bear_formed  := true
            ifvg_bear_top     := ft
            ifvg_bear_bot     := fb
            ifvg_bear_mid     := mid_val
            ifvg_bear_ith_only := touched
            array.remove(bfvg_top,     i)
            array.remove(bfvg_bot,     i)
            array.remove(bfvg_mid,     i)
            array.remove(bfvg_touched, i)
            array.remove(bfvg_box,     i)
        else if close > ft
            box.delete(bx)
            array.remove(bfvg_top,     i)
            array.remove(bfvg_bot,     i)
            array.remove(bfvg_mid,     i)
            array.remove(bfvg_touched, i)
            array.remove(bfvg_box,     i)
        else
            array.set(bfvg_touched, i, true)

for i = array.size(sfvg_top) - 1 to 0
    ft      = array.get(sfvg_top,     i)
    fb      = array.get(sfvg_bot,     i)
    mid_val = array.get(sfvg_mid,     i)
    touched = array.get(sfvg_touched, i)
    bx      = array.get(sfvg_box,     i)

    wick_in_zone = high >= fb and low <= ft

    if wick_in_zone
        if close > ft
            box.delete(bx)
            if show_ifvg
                box.new(bar_index, fb, bar_index+fvg_extend, ft,
                        bgcolor=c_ifvg_b, border_color=color.new(#69f0ae,20), border_width=2)
                line.new(bar_index, mid_val, bar_index+fvg_extend, mid_val,
                         color=c_itl, style=line.style_dotted, width=1)
                label.new(bar_index, fb, touched ? "IFVG ▲ (ITL)" : "IFVG ▲",
                          style=label.style_label_up,
                          color=color.new(#69f0ae,10), textcolor=color.white, size=size.tiny)
            array.push(bifvg_top,      ft)
            array.push(bifvg_bot,      fb)
            array.push(bifvg_mid,      mid_val)
            array.push(bifvg_itl_only, touched)
            ifvg_bull_formed   := true
            ifvg_bull_top      := ft
            ifvg_bull_bot      := fb
            ifvg_bull_mid      := mid_val
            ifvg_bull_itl_only := touched
            array.remove(sfvg_top,     i)
            array.remove(sfvg_bot,     i)
            array.remove(sfvg_mid,     i)
            array.remove(sfvg_touched, i)
            array.remove(sfvg_box,     i)
        else if close < fb
            box.delete(bx)
            array.remove(sfvg_top,     i)
            array.remove(sfvg_bot,     i)
            array.remove(sfvg_mid,     i)
            array.remove(sfvg_touched, i)
            array.remove(sfvg_box,     i)
        else
            array.set(sfvg_touched, i, true)

// ── Check if price is currently touching an IFVG zone ──
var bool  price_in_bull_ifvg  = false
var bool  price_in_bear_ifvg  = false
var float cur_bifvg_top       = na
var float cur_bifvg_bot       = na
var float cur_bifvg_mid       = na
var bool  cur_bifvg_itl_only  = false
var float cur_sifvg_top       = na
var float cur_sifvg_bot       = na
var float cur_sifvg_mid       = na
var bool  cur_sifvg_ith_only  = false

price_in_bull_ifvg := false
price_in_bear_ifvg := false

for i = array.size(bifvg_top) - 1 to 0
    ft       = array.get(bifvg_top,      i)
    fb       = array.get(bifvg_bot,      i)
    mid_val  = array.get(bifvg_mid,      i)
    itl_only = array.get(bifvg_itl_only, i)
    entry_ceiling = itl_only ? mid_val : ft
    if low <= entry_ceiling and high >= fb
        price_in_bull_ifvg := true
        cur_bifvg_top      := ft
        cur_bifvg_bot      := fb
        cur_bifvg_mid      := mid_val
        cur_bifvg_itl_only := itl_only
    if close > ft
        array.remove(bifvg_top,      i)
        array.remove(bifvg_bot,      i)
        array.remove(bifvg_mid,      i)
        array.remove(bifvg_itl_only, i)

for i = array.size(sifvg_top) - 1 to 0
    ft       = array.get(sifvg_top,      i)
    fb       = array.get(sifvg_bot,      i)
    mid_val  = array.get(sifvg_mid,      i)
    ith_only = array.get(sifvg_ith_only, i)
    entry_floor = ith_only ? mid_val : fb
    if high >= entry_floor and low <= ft
        price_in_bear_ifvg := true
        cur_sifvg_top      := ft
        cur_sifvg_bot      := fb
        cur_sifvg_mid      := mid_val
        cur_sifvg_ith_only := ith_only
    if close < fb
        array.remove(sifvg_top,      i)
        array.remove(sifvg_bot,      i)
        array.remove(sifvg_mid,      i)
        array.remove(sifvg_ith_only, i)

// ═══════════════════════════════════════════════════════════════════════════
// LIQUIDITY SWEEP
// ═══════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

var float last_ph = na
var float last_pl = na

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

if not na(ph)
    line.new(bar_index[swing_len], ph, bar_index, ph,
             color=color.new(color.red,60), style=line.style_dashed, width=1)
if not na(pl)
    line.new(bar_index[swing_len], pl, bar_index, pl,
             color=color.new(color.green,60), style=line.style_dashed, width=1)

bearish_sweep = not na(last_ph) and high > last_ph and close < last_ph
bullish_sweep = not na(last_pl) and low  < last_pl and close > last_pl

plotshape(show_sweeps and bearish_sweep, "SSL Swept", shape.triangledown, location.abovebar,
          color=color.new(#e91e63,0), size=size.small, text="SSL↑")
plotshape(show_sweeps and bullish_sweep, "BSL Swept",  shape.triangleup, location.belowbar,
          color=color.new(#00e5ff,0), size=size.small, text="BSL↓")

var int bars_since_bull_sweep = 999
var int bars_since_bear_sweep = 999

if bullish_sweep
    bars_since_bull_sweep := 0
else
    bars_since_bull_sweep += 1

if bearish_sweep
    bars_since_bear_sweep := 0
else
    bars_since_bear_sweep += 1

recent_bull_sweep = bars_since_bull_sweep <= sweep_bars
recent_bear_sweep = bars_since_bear_sweep <= sweep_bars

// ═══════════════════════════════════════════════════════════════════════════
// DOL — Draw On Liquidity
// ═══════════════════════════════════════════════════════════════════════════
var float[] dol_highs = array.new_float()
var float[] dol_lows  = array.new_float()

if not na(ph)
    if array.size(dol_highs) >= 5
        array.shift(dol_highs)
    array.push(dol_highs, ph)

if not na(pl)
    if array.size(dol_lows) >= 5
        array.shift(dol_lows)
    array.push(dol_lows, pl)

var float nearest_dol_up   = na
var float nearest_dol_down = na
nearest_dol_up   := na
nearest_dol_down := na

for i = array.size(dol_highs) - 1 to 0
    lvl = array.get(dol_highs, i)
    if lvl > close
        if na(nearest_dol_up) or lvl < nearest_dol_up
            nearest_dol_up := lvl

for i = array.size(dol_lows) - 1 to 0
    lvl = array.get(dol_lows, i)
    if lvl < close
        if na(nearest_dol_down) or lvl > nearest_dol_down
            nearest_dol_down := lvl

dol_dist_up   = not na(nearest_dol_up)   ? nearest_dol_up   - close : na
dol_dist_down = not na(nearest_dol_down) ? close - nearest_dol_down : na

opp_dol_long  = filter_dol and not na(dol_dist_up) and not na(dol_dist_down) and dol_dist_down < dol_dist_up
opp_dol_short = filter_dol and not na(dol_dist_up) and not na(dol_dist_down) and dol_dist_up < dol_dist_down

// ═══════════════════════════════════════════════════════════════════════════
// CISD — Change In State of Delivery
// ═══════════════════════════════════════════════════════════════════════════
body_sz  = math.abs(close - open)
bar_rng  = high - low
is_deliv = bar_rng > 0 and (body_sz / bar_rng) >= 0.3

var float last_bull_open = na
var float last_bear_open = na

if is_deliv
    if close > open
        last_bull_open := open
    if close < open
        last_bear_open := open

cisd_bear = not na(last_bull_open) and close < last_bull_open
cisd_bull = not na(last_bear_open) and close > last_bear_open

if cisd_bear
    last_bull_open := na
    label.new(bar_index, high, "CISD ▼",
              style=label.style_label_down, color=color.new(#f44336,10),
              textcolor=color.white, size=size.small)
if cisd_bull
    last_bear_open := na
    label.new(bar_index, low, "CISD ▲",
              style=label.style_label_up, color=color.new(#4caf50,10),
              textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// DATA WICK FILTER
// ═══════════════════════════════════════════════════════════════════════════
avg_rng = ta.atr(20)

upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

data_wick_up   = upper_wick > avg_rng * wick_mult
data_wick_down = lower_wick > avg_rng * wick_mult

block_long_wick  = filter_wick and data_wick_down
block_short_wick = filter_wick and data_wick_up

// ═══════════════════════════════════════════════════════════════════════════
// SMT DIVERGENCE
// ═══════════════════════════════════════════════════════════════════════════
smt_h = request.security(smt_sym, timeframe.period, high)
smt_l = request.security(smt_sym, timeframe.period, low)

main_new_hh = high > ta.highest(high, smt_len)[1]
main_new_ll = low  < ta.lowest(low,   smt_len)[1]
smt_at_hh   = smt_h >= ta.highest(smt_h, smt_len)[1]
smt_at_ll   = smt_l <= ta.lowest(smt_l,  smt_len)[1]

smt_bear_div = main_new_hh and not smt_at_hh
smt_bull_div = main_new_ll and not smt_at_ll

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════
cisd_long_ok  = require_cisd ? cisd_bull : true
cisd_short_ok = require_cisd ? cisd_bear : true
smt_long_ok   = require_smt  ? smt_bull_div : true
smt_short_ok  = require_smt  ? smt_bear_div : true

ifvg_long_ok  = ifvg_bull_formed or price_in_bull_ifvg
ifvg_short_ok = ifvg_bear_formed or price_in_bear_ifvg

long_signal  = recent_bull_sweep and ifvg_long_ok and cisd_long_ok and smt_long_ok and not opp_dol_long and not block_long_wick

short_signal = recent_bear_sweep and ifvg_short_ok and cisd_short_ok and smt_short_ok and not opp_dol_short and not block_short_wick

// ═══════════════════════════════════════════════════════════════════════════
// DYNAMIC RR
// ═══════════════════════════════════════════════════════════════════════════
var float entry_price = na
var float sl_price    = na
var float tp1_price   = na
var float tp2_price   = na

if long_signal
    entry_price := close
    sl_price    := not na(last_pl) ? last_pl - syminfo.mintick * 5 : low - avg_rng * 0.5
    risk         = entry_price - sl_price
    if risk <= 0
        risk    := avg_rng
    dol_rr       = not na(dol_dist_up) ? dol_dist_up / risk : rr_default
    final_rr     = math.max(rr_default, math.min(dol_rr, rr_max))
    tp1_price   := entry_price + risk * 1.0
    tp2_price   := entry_price + risk * final_rr

if short_signal
    entry_price := close
    sl_price    := not na(last_ph) ? last_ph + syminfo.mintick * 5 : high + avg_rng * 0.5
    risk         = sl_price - entry_price
    if risk <= 0
        risk    := avg_rng
    dol_rr       = not na(dol_dist_down) ? dol_dist_down / risk : rr_default
    final_rr     = math.max(rr_default, math.min(dol_rr, rr_max))
    tp1_price   := entry_price - risk * 1.0
    tp2_price   := entry_price - risk * final_rr

if (long_signal or short_signal) and show_sl_tp
    sl_c   = color.new(color.red,    20)
    tp1_c  = color.new(color.yellow, 20)
    tp2_c  = long_signal ? color.new(c_long, 20) : color.new(c_short, 20)
    ext    = bar_index + fvg_extend

    line.new(bar_index, sl_price,    ext, sl_price,   color=sl_c,  width=1, style=line.style_dashed)
    line.new(bar_index, tp1_price,   ext, tp1_price,  color=tp1_c, width=1, style=line.style_dashed)
    line.new(bar_index, tp2_price,   ext, tp2_price,  color=tp2_c, width=1, style=line.style_dashed)

    label.new(bar_index+1, sl_price,  "SL",  style=label.style_label_right, color=sl_c,  textcolor=color.white, size=size.tiny)
    label.new(bar_index+1, tp1_price, "1:1", style=label.style_label_right, color=tp1_c, textcolor=color.white, size=size.tiny)
    label.new(bar_index+1, tp2_price, "DOL", style=label.style_label_right, color=tp2_c, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY ARROWS
// ═══════════════════════════════════════════════════════════════════════════
plotshape(long_signal,  "LONG Entry",  shape.labelup,   location.belowbar,
          color=c_long,  size=size.normal, text="BUY",  textcolor=color.black)
plotshape(short_signal, "SHORT Entry", shape.labeldown, location.abovebar,
          color=c_short, size=size.normal, text="SELL", textcolor=color.white)

bgcolor(long_signal  ? color.new(c_long,  92) : na, title="Long BG")
bgcolor(short_signal ? color.new(c_short, 92) : na, title="Short BG")

// ═══════════════════════════════════════════════════════════════════════════
// SETUP RATING  D → C → B → A → A+
// ═══════════════════════════════════════════════════════════════════════════
f_rating(is_long) =>
    score = 0

    htf_aligned = is_long ? htf_bias == 1 : htf_bias == -1
    if htf_aligned
        score += 2
    else if htf_bias == 0
        score -= 1

    sweep_ok = is_long ? recent_bull_sweep : recent_bear_sweep
    if sweep_ok
        score += 2

    ifvg_formed  = is_long ? ifvg_bull_formed  : ifvg_bear_formed
    ifvg_in_zone = is_long ? price_in_bull_ifvg : price_in_bear_ifvg
    itl_only     = is_long ? cur_bifvg_itl_only : cur_sifvg_ith_only
    if ifvg_formed or ifvg_in_zone
        if itl_only
            score += 1
        else
            score += 2

    cisd_ok = is_long ? cisd_bull : cisd_bear
    if cisd_ok
        score += 1

    smt_ok = is_long ? smt_bull_div : smt_bear_div
    if smt_ok
        score += 1

    has_dol_target = is_long ? not na(nearest_dol_up) : not na(nearest_dol_down)
    if has_dol_target
        score += 1

    opp_dol = is_long ? opp_dol_long : opp_dol_short
    if opp_dol
        score -= 2

    bad_wick = is_long ? data_wick_down : data_wick_up
    if bad_wick
        score -= 1

    score

long_score  = f_rating(true)
short_score = f_rating(false)
active_score = long_signal ? long_score : short_signal ? short_score : math.max(long_score, short_score)
active_long  = long_signal or (not short_signal and long_score >= short_score)

grade = active_score >= 8 ? "A+" : active_score >= 6 ? "A" : active_score >= 4 ? "B" : active_score >= 2 ? "C" : "D"

grade_clr = active_score >= 8 ? color.new(#00e676, 0) : active_score >= 6 ? color.new(#69f0ae, 0) : active_score >= 4 ? color.new(#ffeb3b, 0) : active_score >= 2 ? color.new(#ff9800, 0) : color.new(#f44336, 0)

grade_bg = active_score >= 8 ? color.new(#00e676, 75) : active_score >= 6 ? color.new(#69f0ae, 80) : active_score >= 4 ? color.new(#ffeb3b, 80) : active_score >= 2 ? color.new(#ff9800, 80) : color.new(#f44336, 80)

// ═══════════════════════════════════════════════════════════════════════════
// CONFLUENCE TABLE  (top-right)
// ═══════════════════════════════════════════════════════════════════════════
var table tbl = table.new(position.top_right, 2, 11,
                          bgcolor=color.new(color.black,78),
                          border_color=color.new(color.gray,50), border_width=1,
                          frame_color=color.gray, frame_width=1)

tick_yes = "✔"
tick_no  = "✘"
tick_na  = "—"

if barstate.islast
    table.cell(tbl, 0, 0, "CONDITION",  text_color=color.gray,   text_size=size.tiny)
    table.cell(tbl, 1, 0, "STATUS",     text_color=color.gray,   text_size=size.tiny)

    htf_txt = htf_bias == 1 ? tick_yes + " Bullish ▲" : htf_bias == -1 ? tick_yes + " Bearish ▼" : tick_na + " Neutral"
    htf_clr = htf_bias == 1 ? color.aqua : htf_bias == -1 ? color.red : color.gray
    table.cell(tbl, 0, 1, "HTF Bias", text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 1, htf_txt,    text_color=htf_clr,      text_size=size.tiny)

    sw_txt = recent_bull_sweep ? tick_yes + " BSL Swept ▲" : recent_bear_sweep ? tick_yes + " SSL Swept ▼" : tick_no + " None"
    sw_clr = recent_bull_sweep ? color.aqua : recent_bear_sweep ? color.fuchsia : color.gray
    table.cell(tbl, 0, 2, "Sweep", text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 2, sw_txt,  text_color=sw_clr,       text_size=size.tiny)

    ifvg_bull_itl = price_in_bull_ifvg and cur_bifvg_itl_only
    ifvg_bear_ith = price_in_bear_ifvg and cur_sifvg_ith_only
    ifvg_txt = ifvg_bull_formed ? tick_yes + " Bull (full)" : price_in_bull_ifvg and not ifvg_bull_itl ? tick_yes + " Bull IFVG ▲" : ifvg_bull_itl ? "△ Bull ITL only" : ifvg_bear_formed ? tick_yes + " Bear (full)" : price_in_bear_ifvg and not ifvg_bear_ith ? tick_yes + " Bear IFVG ▼" : ifvg_bear_ith ? "△ Bear ITH only" : tick_no + " None"
    ifvg_clr = (ifvg_bull_formed or price_in_bull_ifvg) ? color.lime : (ifvg_bear_formed or price_in_bear_ifvg) ? color.red : color.gray
    table.cell(tbl, 0, 3, "IFVG",   text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 3, ifvg_txt, text_color=ifvg_clr,     text_size=size.tiny)

    cisd_txt = cisd_bull ? tick_yes + " Bullish ▲" : cisd_bear ? tick_yes + " Bearish ▼" : tick_no + " None"
    cisd_clr = cisd_bull ? color.lime : cisd_bear ? color.red : color.gray
    table.cell(tbl, 0, 4, "CISD",   text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 4, cisd_txt, text_color=cisd_clr,     text_size=size.tiny)

    smt_txt = smt_bull_div ? tick_yes + " Bullish ▲" : smt_bear_div ? tick_yes + " Bearish ▼" : tick_no + " None"
    smt_clr = smt_bull_div ? color.lime : smt_bear_div ? color.red : color.gray
    table.cell(tbl, 0, 5, "SMT",   text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 5, smt_txt, text_color=smt_clr,      text_size=size.tiny)

    dol_up_txt   = not na(nearest_dol_up)   ? str.tostring(nearest_dol_up,   format.mintick) : "-"
    dol_down_txt = not na(nearest_dol_down) ? str.tostring(nearest_dol_down, format.mintick) : "-"
    dol_txt = "Up:" + dol_up_txt + " Dn:" + dol_down_txt
    dol_clr = opp_dol_long or opp_dol_short ? color.orange : color.silver
    table.cell(tbl, 0, 6, "DOL",   text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 6, dol_txt, text_color=dol_clr,      text_size=size.tiny)

    wick_txt = data_wick_up ? "Warn Up wick" : data_wick_down ? "Warn Down wick" : tick_yes + " Clean"
    wick_clr = (data_wick_up or data_wick_down) ? color.orange : color.lime
    table.cell(tbl, 0, 7, "Data Wick", text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 7, wick_txt,    text_color=wick_clr,     text_size=size.tiny)

    sig_txt = long_signal ? "BUY NOW" : short_signal ? "SELL NOW" : "Watching..."
    sig_clr = long_signal ? color.lime : short_signal ? color.red : color.gray
    sig_bg  = long_signal ? color.new(color.lime, 72) : short_signal ? color.new(color.red, 72) : color.new(color.black, 78)
    table.cell(tbl, 0, 8, "SIGNAL", text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 8, sig_txt,  text_color=sig_clr,      text_size=size.tiny, bgcolor=sig_bg)

    lvl_txt = (long_signal or short_signal) and not na(sl_price) ? "SL " + str.tostring(sl_price, format.mintick) + " | 1:1 " + str.tostring(tp1_price, format.mintick) : "-"
    table.cell(tbl, 0, 9, "Levels", text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 9, lvl_txt,  text_color=color.white,  text_size=size.tiny)

    score_txt = "Score: " + str.tostring(active_score) + "/9"
    table.cell(tbl, 0, 10, score_txt,         text_color=color.silver, text_size=size.tiny)
    table.cell(tbl, 1, 10, "Grade: " + grade, text_color=grade_clr,    text_size=size.small, bgcolor=grade_bg)

// ═══════════════════════════════════════════════════════════════════════════
// SETUP RATING PANEL  (left side)
// ═══════════════════════════════════════════════════════════════════════════
var table rating_panel = table.new(position.middle_left, 1, 5,
                                   bgcolor=color.new(color.black, 72),
                                   border_color=color.new(color.gray, 40), border_width=1,
                                   frame_color=color.gray, frame_width=1)

if barstate.islast
    table.cell(rating_panel, 0, 0, grade,
               text_color=grade_clr, text_size=size.huge, bgcolor=grade_bg)

    table.cell(rating_panel, 0, 1, str.tostring(active_score) + " / 9",
               text_color=color.white, text_size=size.small)

    dir_txt = long_signal ? "LONG ▲" : short_signal ? "SHORT ▼" : active_long ? "BIAS ▲" : "BIAS ▼"
    dir_clr = long_signal ? color.lime : short_signal ? color.red : active_long ? color.new(color.lime,30) : color.new(color.red,30)
    table.cell(rating_panel, 0, 2, dir_txt,
               text_color=dir_clr, text_size=size.small)

    grade_desc = grade == "A+" ? "Max confluence" : grade == "A" ? "High quality" : grade == "B" ? "Moderate" : grade == "C" ? "Weak setup" : "Skip trade"
    table.cell(rating_panel, 0, 3, grade_desc,
               text_color=color.silver, text_size=size.tiny)

    missing_long =
         (not recent_bull_sweep ? "Need sweep | " : "") +
         (not ifvg_long_ok      ? "Need IFVG | "  : "") +
         (not cisd_bull         ? "Need CISD | "  : "") +
         (opp_dol_long          ? "Opp DOL! | "   : "") +
         (block_long_wick       ? "Data wick! "   : "")
    missing_short =
         (not recent_bear_sweep ? "Need sweep | " : "") +
         (not ifvg_short_ok     ? "Need IFVG | "  : "") +
         (not cisd_bear         ? "Need CISD | "  : "") +
         (opp_dol_short         ? "Opp DOL! | "   : "") +
         (block_short_wick      ? "Data wick! "   : "")
    missing_txt = long_signal or active_long ? missing_long : missing_short
    table.cell(rating_panel, 0, 4, missing_txt == "" ? "All clear" : missing_txt,
               text_color=color.new(color.orange, 0), text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(long_signal,  "LONG ENTRY — AN Trades",
               "BUY: Sweep + IFVG + CISD confirmed. Check chart for SL/TP.")
alertcondition(short_signal, "SHORT ENTRY — AN Trades",
               "SELL: Sweep + IFVG + CISD confirmed. Check chart for SL/TP.")
alertcondition(long_signal  and active_score >= 8, "A+ LONG — AN Trades",
               "A+ BUY: Maximum confluence. All conditions met.")
alertcondition(short_signal and active_score >= 8, "A+ SHORT — AN Trades",
               "A+ SELL: Maximum confluence. All conditions met.")
````
