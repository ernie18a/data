# Confluence  FVG + Fibo + VWAP

- url: https://www.tradingview.com/script/C62RhZ7n-Confluence-FVG-Fibo-VWAP/
- type: indicator
- pine_id: PUB;08c2144dd204433f9a5a12b8026c833e
- version: 1.0

## Description

A precision confluence indicator that combines three institutional concepts into a single, high-conviction signal engine.

How it works:

The indicator uses a Higher Timeframe (HTF) swing structure to automatically draw Fibonacci retracement levels (0.236 / 0.382 / 0.5 / 0.618) from the most recent pivot high/low pair. A signal fires only when all three conditions align:

FVG forms inside the golden pocket (0.382–0.618) — A Fair Value Gap (imbalance candle) appears while price is retracing into the Fibonacci zone
Swing direction is validated — Bullish signals only trigger during a bullish retracement (high pivot after low pivot); bearish signals only during a bearish retracement
Price is on the correct side of VWAP — Long signals require price above VWAP; shorts below
Visual output:

Fibonacci levels drawn automatically from HTF pivots (default 1H, adjustable to 4H or Daily)
FVG boxes highlight the imbalance zones (auto-hidden on mitigation)
Signal triangles (▲ long / ▼ short) mark confirmed confluence entries
TP/SL boxes drawn at signal: TP at the swing extreme, SL just beyond the swing low/high
Filters are strict by design — this indicator is built to show fewer, higher-quality setups rather than constant noise.

Inputs:

FVG minimum size filter (%)
HTF pivot timeframe
VWAP filter toggle
TP/SL box width
Built-in alerts for long, short, and any signal.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © EVLabs — 

//@version=6
indicator("Confluence — FVG + Fibo + VWAP", overlay=true, max_boxes_count=500, max_lines_count=20, max_labels_count=10)

grp_fvg       = "── Fair Value Gaps ──"
fvg_enabled   = input.bool(true,  "Show FVGs",          group=grp_fvg)
fvg_mitigated = input.bool(true,  "Hide on mitigation", group=grp_fvg)
fvg_max       = input.int(3,      "Max active FVGs",    group=grp_fvg, minval=1, maxval=10)
fvg_min_pct   = input.float(0.10, "Min FVG size (%)",   group=grp_fvg, minval=0.01, maxval=1.0, step=0.01)
fvg_bull_col  = input.color(color.new(#00c853, 85), "Bullish FVG", group=grp_fvg)
fvg_bear_col  = input.color(color.new(#ff1744, 85), "Bearish FVG", group=grp_fvg)

grp_fib       = "── Auto Fibonacci (HTF) ──"
fib_enabled   = input.bool(true,  "Show Fibonacci",     group=grp_fib)
fib_tf        = input.timeframe("60", "Pivot timeframe", group=grp_fib,
                 tooltip="Timeframe for swing pivots. 60 = 1H, 240 = 4H, D = Daily.")
fib_left      = input.int(10,     "Pivot left bars",    group=grp_fib, minval=3)
fib_right     = input.int(5,      "Pivot right bars",   group=grp_fib, minval=2)
fib_col       = input.color(#ffd600, "Fib color",       group=grp_fib)

grp_vwap      = "── VWAP ──"
vwap_enabled  = input.bool(true,  "Show VWAP",           group=grp_vwap)
vwap_filter   = input.bool(true,  "Filter by VWAP side", group=grp_vwap)
vwap_col      = input.color(#2962ff, "VWAP color",       group=grp_vwap)

grp_sig       = "── Signals ──"
sig_enabled   = input.bool(true,  "Show signals",     group=grp_sig)
sig_box_len   = input.int(20,     "Box width (bars)", group=grp_sig, minval=5, maxval=200)

atr_val = ta.atr(14)

var float _pv  = 0.0
var float _vol = 0.0
if ta.change(time("D")) != 0
    _pv  := 0.0
    _vol := 0.0
_pv  += hlc3 * volume
_vol += volume
vwap_val    = _vol > 0 ? _pv / _vol : hlc3
_vwap_reset = ta.change(time("D")) != 0
plot(vwap_enabled ? (_vwap_reset ? na : vwap_val) : na, "VWAP", color=vwap_col, linewidth=2)

_use_htf = fib_tf != ""
ph = _use_htf ? request.security(syminfo.tickerid, fib_tf, ta.pivothigh(high, fib_left, fib_right))
              : ta.pivothigh(high, fib_left, fib_right)
pl = _use_htf ? request.security(syminfo.tickerid, fib_tf, ta.pivotlow(low,   fib_left, fib_right))
              : ta.pivotlow(low,   fib_left, fib_right)

var float last_ph     = na
var float last_pl     = na
var int   last_ph_bar = na
var int   last_pl_bar = na
var bool  fib_active  = false

var line  l_618  = na
var line  l_500  = na
var line  l_382  = na
var line  l_236  = na
var line  l_sw   = na
var label lb_618 = na
var label lb_500 = na
var label lb_382 = na

new_pivot = false
if not na(ph)
    last_ph     := ph
    last_ph_bar := _use_htf ? bar_index : bar_index - fib_right
    new_pivot   := true
    fib_active  := true
if not na(pl)
    last_pl     := pl
    last_pl_bar := _use_htf ? bar_index : bar_index - fib_right
    new_pivot   := true
    fib_active  := true

fib_valid = not na(last_ph) and not na(last_pl) and fib_active
fib_range = fib_valid ? last_ph - last_pl : na
fib_618   = fib_valid ? last_pl + fib_range * 0.618 : na
fib_500   = fib_valid ? last_pl + fib_range * 0.500 : na
fib_382   = fib_valid ? last_pl + fib_range * 0.382 : na
fib_236   = fib_valid ? last_pl + fib_range * 0.236 : na

if fib_valid
    s_hi = math.max(last_ph, last_pl)
    s_lo = math.min(last_ph, last_pl)
    if close < s_lo or close > s_hi
        fib_active := false
        line.delete(l_618)
        line.delete(l_500)
        line.delete(l_382)
        line.delete(l_236)
        line.delete(l_sw)
        label.delete(lb_618)
        label.delete(lb_500)
        label.delete(lb_382)

if fib_enabled and fib_valid and new_pivot
    line.delete(l_618)
    line.delete(l_500)
    line.delete(l_382)
    line.delete(l_236)
    line.delete(l_sw)
    s = math.min(last_ph_bar, last_pl_bar)
    l_618 := line.new(s, fib_618, s + 1, fib_618, extend=extend.right, color=color.new(fib_col, 30), style=line.style_dashed, width=1)
    l_500 := line.new(s, fib_500, s + 1, fib_500, extend=extend.right, color=color.new(fib_col, 30), style=line.style_dashed, width=1)
    l_382 := line.new(s, fib_382, s + 1, fib_382, extend=extend.right, color=color.new(fib_col, 50), style=line.style_dotted, width=1)
    l_236 := line.new(s, fib_236, s + 1, fib_236, extend=extend.right, color=color.new(fib_col, 65), style=line.style_dotted, width=1)
    if not na(last_ph_bar) and not na(last_pl_bar)
        l_sw := last_pl_bar < last_ph_bar
             ? line.new(last_pl_bar, last_pl, last_ph_bar, last_ph, color=color.new(fib_col, 55), style=line.style_dotted, width=1)
             : line.new(last_ph_bar, last_ph, last_pl_bar, last_pl, color=color.new(fib_col, 55), style=line.style_dotted, width=1)

if fib_enabled and fib_valid and barstate.islast
    label.delete(lb_618)
    label.delete(lb_500)
    label.delete(lb_382)
    lb_618 := label.new(bar_index + 2, fib_618, "0.618", color=color.new(fib_col, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    lb_500 := label.new(bar_index + 2, fib_500, "0.5",   color=color.new(fib_col, 20), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    lb_382 := label.new(bar_index + 2, fib_382, "0.382", color=color.new(fib_col, 40), textcolor=color.white, style=label.style_label_left, size=size.tiny)

bull_fvg_formed = fvg_enabled and low > high[2] and (low - high[2]) / high[2] * 100 >= fvg_min_pct
bear_fvg_formed = fvg_enabled and high < low[2] and (low[2] - high) / low[2] * 100 >= fvg_min_pct

var float[] bull_top = array.new_float()
var float[] bull_bot = array.new_float()
var box[]   bull_box = array.new_box()
var float[] bear_top = array.new_float()
var float[] bear_bot = array.new_float()
var box[]   bear_box = array.new_box()

if bull_fvg_formed
    if array.size(bull_box) >= fvg_max
        box.delete(array.shift(bull_box))
        array.shift(bull_top)
        array.shift(bull_bot)
    b = box.new(bar_index - 2, high[2], bar_index, low,
        border_color=color.new(#00c853, 70), bgcolor=fvg_bull_col, extend=extend.right)
    array.push(bull_top, low)
    array.push(bull_bot, high[2])
    array.push(bull_box, b)

if bear_fvg_formed
    if array.size(bear_box) >= fvg_max
        box.delete(array.shift(bear_box))
        array.shift(bear_top)
        array.shift(bear_bot)
    b = box.new(bar_index - 2, high, bar_index, low[2],
        border_color=color.new(#ff1744, 70), bgcolor=fvg_bear_col, extend=extend.right)
    array.push(bear_top, low[2])
    array.push(bear_bot, high)
    array.push(bear_box, b)

if fvg_mitigated
    if array.size(bull_box) > 0
        for i = array.size(bull_box) - 1 to 0
            if close < array.get(bull_top, i)
                box.set_extend(array.get(bull_box, i), extend.none)
                box.set_right(array.get(bull_box, i), bar_index)
                array.remove(bull_box, i)
                array.remove(bull_top, i)
                array.remove(bull_bot, i)
    if array.size(bear_box) > 0
        for i = array.size(bear_box) - 1 to 0
            if close > array.get(bear_bot, i)
                box.set_extend(array.get(bear_box, i), extend.none)
                box.set_right(array.get(bear_box, i), bar_index)
                array.remove(bear_box, i)
                array.remove(bear_top, i)
                array.remove(bear_bot, i)

in_fib_zone   = fib_valid and not na(fib_382) and not na(fib_618) and close >= fib_382 and close <= fib_618

bullish_swing = fib_valid and not na(last_ph_bar) and not na(last_pl_bar) and last_ph_bar > last_pl_bar
bearish_swing = fib_valid and not na(last_ph_bar) and not na(last_pl_bar) and last_pl_bar > last_ph_bar

bull_signal = sig_enabled and bull_fvg_formed and in_fib_zone and bullish_swing and
              (not vwap_filter or close > vwap_val)

bear_signal = sig_enabled and bear_fvg_formed and in_fib_zone and bearish_swing and
              (not vwap_filter or close < vwap_val)

plotshape(bull_signal, "Long",  shape.triangleup,   location.belowbar,
          color=color.new(#00e676, 0), size=size.small)
plotshape(bear_signal, "Short", shape.triangledown, location.abovebar,
          color=color.new(#ff1744, 0), size=size.small)

if bull_signal
    _entry = (low + high[2]) / 2
    _sl    = last_pl - atr_val * 0.3
    _tp    = last_ph
    _r     = bar_index + sig_box_len
    box.new(bar_index - 2, _entry, _r, _sl,    border_color=color.new(#ff1744, 50), bgcolor=color.new(#ff1744, 88), extend=extend.none)
    box.new(bar_index - 2, _tp,    _r, _entry, border_color=color.new(#00c853, 50), bgcolor=color.new(#00c853, 88), extend=extend.none)

if bear_signal
    _entry = (high + low[2]) / 2
    _sl    = last_ph + atr_val * 0.3
    _tp    = last_pl
    _r     = bar_index + sig_box_len
    box.new(bar_index - 2, _sl,    _r, _entry, border_color=color.new(#ff1744, 50), bgcolor=color.new(#ff1744, 88), extend=extend.none)
    box.new(bar_index - 2, _entry, _r, _tp,    border_color=color.new(#00c853, 50), bgcolor=color.new(#00c853, 88), extend=extend.none)

alertcondition(bull_signal, "EV Long  — FVG+Fibo+VWAP", "EV Confluence LONG: FVG + Fibonacci + VWAP confluence")
alertcondition(bear_signal, "EV Short — FVG+Fibo+VWAP", "EV Confluence SHORT: FVG + Fibonacci + VWAP confluence")
alertcondition(bull_signal or bear_signal, "EV Any Signal", "EV Confluence signal fired")
````
