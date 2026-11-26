# NQ HOD/LOD Hunter

- url: https://www.tradingview.com/script/kqMJm9ml-NQ-HOD-LOD-Hunter/
- type: indicator
- pine_id: PUB;606cd978613f431caa8d156d0021e26b
- version: 1.0

## Description

finds hod and lod with decent accuracy if not hod or lod youll still catch a good move

## Source Code

````pine
//@version=5
indicator("NQ HOD/LOD Hunter", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
atr_len       = input.int(14,   "ATR Length")
atr_mult_1    = input.float(1.0, "Target 1 — ATR multiplier", step=0.1)
atr_mult_2    = input.float(1.5, "Target 2 — ATR multiplier", step=0.1)
show_targets  = input.bool(true, "Show Pre-Open Target Zones")
show_signals  = input.bool(true, "Show HOD/LOD Signals")
show_labels   = input.bool(true, "Show Labels")

// ─────────────────────────────────────────
// SESSION — forced ET so PST charts work
// ─────────────────────────────────────────
is_rth        = not na(time("1", "0930-1600", "America/New_York"))
is_premarket  = not na(time("1", "0400-0930", "America/New_York"))
is_globex     = not na(time("1", "1800-0930", "America/New_York"))
is_rth_open   = is_rth and not is_rth[1]
is_rth_close  = is_rth[1] and not is_rth

// ─────────────────────────────────────────
// PREV DAY DATA
// ─────────────────────────────────────────
[pdh, pdl, pdc] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

atr_daily = request.security(syminfo.tickerid, "D",
     ta.atr(atr_len)[1], lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────
// GLOBEX HIGH / LOW
// ─────────────────────────────────────────
var float g_high        = na
var float g_low         = na
var float g_high_frozen = na
var float g_low_frozen  = na

if is_rth_open
    g_high_frozen := g_high
    g_low_frozen  := g_low
    g_high        := na
    g_low         := na

if is_globex
    g_high := na(g_high) ? high : math.max(g_high, high)
    g_low  := na(g_low)  ? low  : math.min(g_low,  low)

// ─────────────────────────────────────────
// PRE-OPEN TARGET ZONES
// calculated from PDC + ATR and globex extension
// drawn before open, frozen for the day
// ─────────────────────────────────────────
var float hod_t1 = na
var float hod_t2 = na
var float lod_t1 = na
var float lod_t2 = na
var float g_ext_up   = na
var float g_ext_down = na

if is_rth_open
    g_range      = not na(g_high_frozen) and not na(g_low_frozen) ? g_high_frozen - g_low_frozen : atr_daily * 0.5
    hod_t1      := pdc + atr_daily * atr_mult_1
    hod_t2      := pdc + atr_daily * atr_mult_2
    lod_t1      := pdc - atr_daily * atr_mult_1
    lod_t2      := pdc - atr_daily * atr_mult_2
    g_ext_up    := not na(g_high_frozen) ? g_high_frozen + g_range * 1.0 : na
    g_ext_down  := not na(g_low_frozen)  ? g_low_frozen  - g_range * 1.0 : na

// ─────────────────────────────────────────
// DRAW TARGET ZONE LINES
// ─────────────────────────────────────────
var line ln_hod1 = na
var line ln_hod2 = na
var line ln_lod1 = na
var line ln_lod2 = na
var line ln_gup  = na
var line ln_gdn  = na

var label lb_hod1 = na
var label lb_hod2 = na
var label lb_lod1 = na
var label lb_lod2 = na
var label lb_gup  = na
var label lb_gdn  = na

if is_rth_open and show_targets
    line.delete(ln_hod1)
    line.delete(ln_hod2)
    line.delete(ln_lod1)
    line.delete(ln_lod2)
    line.delete(ln_gup)
    line.delete(ln_gdn)
    label.delete(lb_hod1)
    label.delete(lb_hod2)
    label.delete(lb_lod1)
    label.delete(lb_lod2)
    label.delete(lb_gup)
    label.delete(lb_gdn)

    c_up   = color.new(color.black, 30)
    c_down = color.new(color.black, 30)
    c_ext  = color.new(color.black, 55)
    c_lbg  = color.new(color.black, 88)

    ln_hod1 := line.new(bar_index, hod_t1, bar_index+1, hod_t1,
         extend=extend.right, color=c_up, width=1, style=line.style_dashed)
    ln_hod2 := line.new(bar_index, hod_t2, bar_index+1, hod_t2,
         extend=extend.right, color=c_up, width=2, style=line.style_solid)
    ln_lod1 := line.new(bar_index, lod_t1, bar_index+1, lod_t1,
         extend=extend.right, color=c_down, width=1, style=line.style_dashed)
    ln_lod2 := line.new(bar_index, lod_t2, bar_index+1, lod_t2,
         extend=extend.right, color=c_down, width=2, style=line.style_solid)

    if show_labels
        lb_hod1 := label.new(bar_index, hod_t1,
             "HOD T1  " + str.tostring(hod_t1, "#.0"),
             color=c_lbg, textcolor=c_up, style=label.style_label_right, size=size.small)
        lb_hod2 := label.new(bar_index, hod_t2,
             "HOD T2  " + str.tostring(hod_t2, "#.0"),
             color=c_lbg, textcolor=c_up, style=label.style_label_right, size=size.small)
        lb_lod1 := label.new(bar_index, lod_t1,
             "LOD T1  " + str.tostring(lod_t1, "#.0"),
             color=c_lbg, textcolor=c_down, style=label.style_label_right, size=size.small)
        lb_lod2 := label.new(bar_index, lod_t2,
             "LOD T2  " + str.tostring(lod_t2, "#.0"),
             color=c_lbg, textcolor=c_down, style=label.style_label_right, size=size.small)

    if not na(g_ext_up)
        ln_gup := line.new(bar_index, g_ext_up, bar_index+1, g_ext_up,
             extend=extend.right, color=c_ext, width=1, style=line.style_dotted)
        if show_labels
            lb_gup := label.new(bar_index, g_ext_up,
                 "GLOBEX EXT UP  " + str.tostring(g_ext_up, "#.0"),
                 color=c_lbg, textcolor=c_ext, style=label.style_label_right, size=size.small)

    if not na(g_ext_down)
        ln_gdn := line.new(bar_index, g_ext_down, bar_index+1, g_ext_down,
             extend=extend.right, color=c_ext, width=1, style=line.style_dotted)
        if show_labels
            lb_gdn := label.new(bar_index, g_ext_down,
                 "GLOBEX EXT DN  " + str.tostring(g_ext_down, "#.0"),
                 color=c_lbg, textcolor=c_ext, style=label.style_label_right, size=size.small)

// stop lines at close
if is_rth_close
    line.set_extend(ln_hod1, extend.none)
    line.set_extend(ln_hod2, extend.none)
    line.set_extend(ln_lod1, extend.none)
    line.set_extend(ln_lod2, extend.none)
    line.set_extend(ln_gup,  extend.none)
    line.set_extend(ln_gdn,  extend.none)

// ─────────────────────────────────────────
// VWAP — anchored to RTH open
// ─────────────────────────────────────────
var float vwap_sum  = 0.0
var float vwap_sum2 = 0.0
var float vol_sum   = 0.0

if is_rth_open
    vwap_sum  := 0.0
    vwap_sum2 := 0.0
    vol_sum   := 0.0

if is_rth
    tp        = (high + low + close) / 3
    vwap_sum  := vwap_sum  + tp * volume
    vwap_sum2 := vwap_sum2 + tp * tp * volume
    vol_sum   := vol_sum   + volume

vwap_val = vol_sum > 0 ? vwap_sum  / vol_sum : na
vwap_std = vol_sum > 0 ? math.sqrt(math.max(vwap_sum2 / vol_sum - vwap_val * vwap_val, 0)) : na
v2u      = vwap_val + 2 * vwap_std
v2l      = vwap_val - 2 * vwap_std

plot(is_rth ? vwap_val : na, "VWAP",    color=color.new(color.black, 10), linewidth=2)
plot(is_rth ? v2u      : na, "VWAP +2", color=color.new(color.black, 45), linewidth=1, style=plot.style_line)
plot(is_rth ? v2l      : na, "VWAP -2", color=color.new(color.black, 45), linewidth=1, style=plot.style_line)

// ─────────────────────────────────────────
// REAL TIME HOD/LOD SIGNAL
// fires when price reaches a target zone
// AND shows rejection (wick + momentum shift)
// ─────────────────────────────────────────

// track session high/low so far
var float sess_high = na
var float sess_low  = na

if is_rth_open
    sess_high := high
    sess_low  := low

if is_rth
    sess_high := math.max(sess_high, high)
    sess_low  := math.min(sess_low,  low)

// ATR on current timeframe for wick size check
atr_cur = ta.atr(atr_len)

// rejection candle = upper or lower wick is at least 40% of ATR
upper_wick   = high - math.max(open, close)
lower_wick   = math.min(open, close) - low
big_up_wick  = upper_wick  >= atr_cur * 0.4
big_dn_wick  = lower_wick  >= atr_cur * 0.4

// momentum shift = close opposite side of candle to the wick
bearish_bar  = close < open
bullish_bar  = close > open

// near target = within 0.3x ATR of the level
near_hod1    = math.abs(high - hod_t1) <= atr_cur * 0.3
near_hod2    = math.abs(high - hod_t2) <= atr_cur * 0.3
near_lod1    = math.abs(low  - lod_t1) <= atr_cur * 0.3
near_lod2    = math.abs(low  - lod_t2) <= atr_cur * 0.3
near_vwap2u  = math.abs(high - v2u)    <= atr_cur * 0.3
near_vwap2l  = math.abs(low  - v2l)    <= atr_cur * 0.3

// also fire if price hits session high near any target (confluence)
at_sess_high = high >= sess_high and high == ta.highest(high, 5)
at_sess_low  = low  <= sess_low  and low  == ta.lowest(low,   5)

// HOD signal: near a target + big upper wick + bearish close + at session high
hod_signal = is_rth and show_signals and
     (near_hod1 or near_hod2 or near_vwap2u) and
     big_up_wick and bearish_bar and at_sess_high

// LOD signal: near a target + big lower wick + bullish close + at session low
lod_signal = is_rth and show_signals and
     (near_lod1 or near_lod2 or near_vwap2l) and
     big_dn_wick and bullish_bar and at_sess_low

// ─────────────────────────────────────────
// PAINT SIGNALS ON CHART
// ─────────────────────────────────────────
plotshape(hod_signal, "HOD Signal",
     shape.labeldown, location.abovebar,
     color.new(color.black, 0), text="HOD?", textcolor=color.white, size=size.normal)

plotshape(lod_signal, "LOD Signal",
     shape.labelup, location.belowbar,
     color.new(color.black, 0), text="LOD?", textcolor=color.white, size=size.normal)

// subtle bar color when signal fires
barcolor(hod_signal ? color.new(color.black, 60) : na)
barcolor(lod_signal ? color.new(color.black, 60) : na)
````
