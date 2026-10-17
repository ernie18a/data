# Doji  Structure  Psych Levels Supply and Demand 

- url: https://www.tradingview.com/script/VoaQlu5w-Doji-Structure-Psych-Levels-Supply-and-Demand/
- type: indicator
- pine_id: PUB;fb00fbb73fcb480b9d98a941bb21a7db
- version: 1.0

## Description

An All in one indicator showing psychological level 000 500  doji engulfing  candles  HH HL LL HL supply and demand zones.

## Source Code

````pine
//@version=6
indicator("Doji · Structure · Psych Levels", overlay=true,
          max_lines_count=500, max_labels_count=500, max_boxes_count=10)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Candlestick Patterns
// ════════════════════════════════════════════════════════════════════
G1 = "── Candlestick Patterns ──"
show_doji   = input.bool(true,  "Doji Star",               group=G1, inline="p1")
col_doji    = input.color(#ff1744, "",                     group=G1, inline="p1")
show_grave  = input.bool(true,  "Gravestone Doji",         group=G1, inline="p2")
col_grave   = input.color(#ff1744, "",                     group=G1, inline="p2")
show_dragon = input.bool(true,  "Dragonfly Doji",          group=G1, inline="p3")
col_dragon  = input.color(#00e676, "",                     group=G1, inline="p3")
show_hammer = input.bool(true,  "Hammer",                  group=G1, inline="p4")
col_hammer  = input.color(#00e676, "",                     group=G1, inline="p4")
show_shoot  = input.bool(true,  "Shooting / Falling Star", group=G1, inline="p5")
col_shoot   = input.color(#ff1744, "",                     group=G1, inline="p5")
doji_pct   = input.float(0.10, "Doji Body %",  group=G1, minval=0.01, maxval=0.40, step=0.01)
wick_ratio = input.float(2.0,  "Wick Ratio",   group=G1, minval=1.0,  maxval=6.0,  step=0.1)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Engulfing Candles
// ════════════════════════════════════════════════════════════════════
G1B = "── Engulfing Candles ──"
show_bull_eng = input.bool(true,  "Bullish Engulfing", group=G1B, inline="e1")
col_bull_eng  = input.color(#00e676, "",               group=G1B, inline="e1")
show_bear_eng = input.bool(true,  "Bearish Engulfing", group=G1B, inline="e2")
col_bear_eng  = input.color(#ff1744, "",               group=G1B, inline="e2")
eng_body_mult = input.float(1.2, "Body Multiplier",    group=G1B, minval=1.0, maxval=4.0, step=0.1)
eng_curr_min  = input.float(0.50, "Min Current Body %",group=G1B, minval=0.10, maxval=0.95, step=0.05)
eng_prev_min  = input.float(0.30, "Min Prev Body %",   group=G1B, minval=0.05, maxval=0.90, step=0.05)
show_eng_bg   = input.bool(false, "Highlight Background", group=G1B)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Supply & Demand Zones
// ════════════════════════════════════════════════════════════════════
G_SD = "── Supply & Demand Zones (Last Only) ──"
show_sd      = input.bool(true,  "Show S&D Zones",      group=G_SD)
col_supply   = input.color(color.new(#ff1744, 70), "Supply Color", group=G_SD, inline="sd1")
col_supply_b = input.color(color.new(#ff1744, 40), "Border",       group=G_SD, inline="sd1")
col_demand   = input.color(color.new(#00e676, 70), "Demand Color", group=G_SD, inline="sd2")
col_demand_b = input.color(color.new(#00e676, 40), "Border",       group=G_SD, inline="sd2")
sd_impulse   = input.float(0.60, "Impulse Body % of Range",
     group=G_SD, minval=0.30, maxval=0.95, step=0.05,
     tooltip="Body must be >= this % of its candle range to qualify as an impulse. Raise for stronger zones.")
sd_atr_mult  = input.float(0.80, "Min ATR Multiplier",
     group=G_SD, minval=0.10, maxval=3.0, step=0.10,
     tooltip="Impulse body must also be >= this multiple of ATR(14). Filters low-volatility noise candles.")
sd_base_bars = input.int(2, "Base Candles to Look Back",
     group=G_SD, minval=1, maxval=5,
     tooltip="How many candles before the impulse define the zone. 1-2 = tight zone, 3-5 = wider zone.")
show_sd_lbl  = input.bool(true, "Show Zone Labels", group=G_SD)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Market Structure
// ════════════════════════════════════════════════════════════════════
G2 = "── Market Structure  (HH · HL · LH · LL) ──"
show_HH  = input.bool(true, "HH", group=G2, inline="ms")
show_HL  = input.bool(true, "HL", group=G2, inline="ms")
show_LH  = input.bool(true, "LH", group=G2, inline="ms")
show_LL  = input.bool(true, "LL", group=G2, inline="ms")
ms_lb    = input.int(10, "Pivot Lookback", group=G2, minval=3, maxval=50)
col_bull = input.color(#00e676, "Bullish Label", group=G2, inline="msc")
col_bear = input.color(#ff1744, "Bearish Label", group=G2, inline="msc")

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Psychological Levels
// ════════════════════════════════════════════════════════════════════
G3 = "── Psychological Levels  (.000 · .500) ──"
show_000 = input.bool(true, "Show .000 Levels", group=G3)
col_000  = input.color(color.new(#ffffff, 50), ".000 Color", group=G3, inline="c1")
sty_000  = input.string("Dotted", ".000 Style", group=G3, inline="c1", options=["Solid","Dashed","Dotted"])
show_500 = input.bool(true, "Show .500 Levels", group=G3)
col_500  = input.color(color.new(#ffd700, 50), ".500 Color", group=G3, inline="c2")
sty_500  = input.string("Dashed", ".500 Style", group=G3, inline="c2", options=["Solid","Dashed","Dotted"])
n_above    = input.int(5, "Levels Above", group=G3, minval=1, maxval=30, inline="nl")
n_below    = input.int(5, "Levels Below", group=G3, minval=1, maxval=30, inline="nl")
p_lw       = input.int(1, "Line Width",   group=G3, minval=1, maxval=4)
show_plbls = input.bool(true, "Show Price Labels", group=G3)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Trend Display
// ════════════════════════════════════════════════════════════════════
G4 = "── Trend Display (Top Right) ──"
show_trend   = input.bool(true, "Show Trend Label", group=G4)
trend_fast   = input.int(20,  "Fast EMA",  group=G4, inline="te")
trend_slow   = input.int(50,  "Slow EMA",  group=G4, inline="te")
trend_filter = input.int(200, "Trend EMA", group=G4, inline="te")
range_band   = input.float(0.10, "Range Sensitivity %", group=G4, minval=0.01, maxval=1.0, step=0.01)

// ════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ════════════════════════════════════════════════════════════════════
f_lstyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

f_step(float p) =>
    if p >= 1000.0
        100.0
    else if p >= 100.0
        10.0
    else if p >= 10.0
        1.0
    else
        0.01

// ════════════════════════════════════════════════════════════════════
//  CANDLE MEASUREMENTS
// ════════════════════════════════════════════════════════════════════
body = math.abs(close - open)
rng  = high - low
up_w = high - math.max(close, open)
dn_w = math.min(close, open) - low

// ── Doji ──────────────────────────────────────────────────────────
doji_base  = rng > 0 and body <= rng * doji_pct
doji_star  = doji_base and up_w > rng * 0.15 and dn_w > rng * 0.15 and
             not (up_w >= rng * 0.65) and not (dn_w >= rng * 0.65)
gravestone = doji_base and up_w >= rng * 0.65 and dn_w <= rng * 0.10
dragonfly  = doji_base and dn_w >= rng * 0.65 and up_w <= rng * 0.10

// ── Hammer & Star ─────────────────────────────────────────────────
hammer   = not doji_base and body > 0 and dn_w >= body * wick_ratio and up_w <= body * 0.5
shooting = not doji_base and body > 0 and up_w >= body * wick_ratio and dn_w <= body * 0.5

// ════════════════════════════════════════════════════════════════════
//  ENGULFING DETECTION
// ════════════════════════════════════════════════════════════════════
prev_body      = math.abs(close[1] - open[1])
prev_rng_e     = high[1] - low[1]
prev_has_body  = prev_rng_e > 0 and prev_body >= prev_rng_e * eng_prev_min
curr_is_strong = rng > 0 and body >= rng * eng_curr_min
body_bigger    = body >= prev_body * eng_body_mult

bull_eng = prev_has_body and curr_is_strong and body_bigger and
           close[1] < open[1] and close > open and
           open <= close[1] and close >= open[1]

bear_eng = prev_has_body and curr_is_strong and body_bigger and
           close[1] > open[1] and close < open and
           open >= close[1] and close <= open[1]

plotshape(show_bull_eng and bull_eng,
     title="Bullish Engulfing", style=shape.labelup, location=location.belowbar,
     color=col_bull_eng, textcolor=color.black, text="Engulf", size=size.small)
plotshape(show_bear_eng and bear_eng,
     title="Bearish Engulfing", style=shape.labeldown, location=location.abovebar,
     color=col_bear_eng, textcolor=color.white, text="Engulf", size=size.small)
bgcolor(show_eng_bg and show_bull_eng and bull_eng ? color.new(col_bull_eng, 88) : na)
bgcolor(show_eng_bg and show_bear_eng and bear_eng ? color.new(col_bear_eng, 88) : na)

// ════════════════════════════════════════════════════════════════════
//  CANDLESTICK PATTERN PLOTS
// ════════════════════════════════════════════════════════════════════
plotshape(show_doji  and doji_star,
     title="Doji Star",      style=shape.triangledown, location=location.abovebar,
     color=col_doji,  textcolor=col_doji,   text="Doji star",   size=size.small)
plotshape(show_grave and gravestone,
     title="Gravestone",     style=shape.triangledown, location=location.abovebar,
     color=col_grave, textcolor=col_grave,  text="Gravestone",  size=size.small)
plotshape(show_dragon and dragonfly,
     title="Dragonfly",      style=shape.triangleup,   location=location.belowbar,
     color=col_dragon, textcolor=col_dragon, text="Dragonfly",  size=size.small)
plotshape(show_hammer and hammer,
     title="Hammer",         style=shape.triangleup,   location=location.belowbar,
     color=col_hammer, textcolor=col_hammer, text="Hammer",     size=size.small)
plotshape(show_shoot and shooting,
     title="Shooting Star",  style=shape.triangledown, location=location.abovebar,
     color=col_shoot,  textcolor=col_shoot,  text="Falling star", size=size.small)

// ════════════════════════════════════════════════════════════════════
//  SUPPLY & DEMAND ZONES  (last one only)
// ════════════════════════════════════════════════════════════════════
sd_atr = ta.atr(14)

// Impulse candle: large body relative to range AND relative to ATR
bear_impulse = close < open and body >= rng * sd_impulse and body >= sd_atr * sd_atr_mult
bull_impulse = close > open and body >= rng * sd_impulse and body >= sd_atr * sd_atr_mult

// Base zone = the candles BEFORE the impulse (sd_base_bars candles back)
// Top of zone = highest high of the base candles
// Bot of zone = lowest low of the base candles
f_zone_top(int n) =>
    t = high[1]
    if n >= 2
        t := math.max(t, high[2])
    if n >= 3
        t := math.max(t, high[3])
    if n >= 4
        t := math.max(t, high[4])
    if n >= 5
        t := math.max(t, high[5])
    t

f_zone_bot(int n) =>
    b = low[1]
    if n >= 2
        b := math.min(b, low[2])
    if n >= 3
        b := math.min(b, low[3])
    if n >= 4
        b := math.min(b, low[4])
    if n >= 5
        b := math.min(b, low[5])
    b

// Persistent boxes — only one supply and one demand kept at a time
var box  supply_box = na
var box  demand_box = na
var label supply_lbl = na
var label demand_lbl = na

// Supply zone: price fell sharply OUT of this area → last bearish impulse base
if show_sd and bear_impulse
    box.delete(supply_box)
    label.delete(supply_lbl)
    z_top = f_zone_top(sd_base_bars)
    z_bot = f_zone_bot(sd_base_bars)
    supply_box := box.new(
         bar_index - sd_base_bars, z_top,
         bar_index + 500,          z_bot,
         border_color=col_supply_b, bgcolor=col_supply,
         border_width=1, extend=extend.none)
    if show_sd_lbl
        supply_lbl := label.new(
             bar_index - sd_base_bars, z_top,
             "Supply", xloc=xloc.bar_index,
             style=label.style_label_right,
             color=color.new(#ff1744, 60),
             textcolor=color.white, size=size.small)

// Demand zone: price rallied sharply OUT of this area → last bullish impulse base
if show_sd and bull_impulse
    box.delete(demand_box)
    label.delete(demand_lbl)
    z_top = f_zone_top(sd_base_bars)
    z_bot = f_zone_bot(sd_base_bars)
    demand_box := box.new(
         bar_index - sd_base_bars, z_top,
         bar_index + 500,          z_bot,
         border_color=col_demand_b, bgcolor=col_demand,
         border_width=1, extend=extend.none)
    if show_sd_lbl
        demand_lbl := label.new(
             bar_index - sd_base_bars, z_bot,
             "Demand", xloc=xloc.bar_index,
             style=label.style_label_right,
             color=color.new(#00e676, 60),
             textcolor=color.black, size=size.small)

// Extend boxes to current bar on every tick
if not na(supply_box)
    box.set_right(supply_box, bar_index + 50)
if not na(demand_box)
    box.set_right(demand_box, bar_index + 50)

// ════════════════════════════════════════════════════════════════════
//  MARKET STRUCTURE
// ════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, ms_lb, ms_lb)
pl = ta.pivotlow (low,  ms_lb, ms_lb)

var float last_ph = na,  var float prev_ph = na
var float last_pl = na,  var float prev_pl = na

if not na(ph)
    prev_ph := last_ph
    last_ph  := ph
if not na(pl)
    prev_pl := last_pl
    last_pl  := pl

is_HH = not na(ph) and not na(prev_ph) and ph > prev_ph
is_LH = not na(ph) and not na(prev_ph) and ph < prev_ph
is_HL = not na(pl) and not na(prev_pl) and pl > prev_pl
is_LL = not na(pl) and not na(prev_pl) and pl < prev_pl

plotshape(show_HH and is_HH, title="HH",
     style=shape.labeldown, location=location.abovebar,
     color=col_bull, textcolor=color.black, text="HH", size=size.small, offset=-ms_lb)
plotshape(show_LH and is_LH, title="LH",
     style=shape.labeldown, location=location.abovebar,
     color=col_bear, textcolor=color.white, text="LH", size=size.small, offset=-ms_lb)
plotshape(show_HL and is_HL, title="HL",
     style=shape.labelup,   location=location.belowbar,
     color=col_bull, textcolor=color.black, text="HL", size=size.small, offset=-ms_lb)
plotshape(show_LL and is_LL, title="LL",
     style=shape.labelup,   location=location.belowbar,
     color=col_bear, textcolor=color.white, text="LL", size=size.small, offset=-ms_lb)

// ════════════════════════════════════════════════════════════════════
//  TREND DISPLAY — Top Right Table
// ════════════════════════════════════════════════════════════════════
ema_f = ta.ema(close, trend_fast)
ema_s = ta.ema(close, trend_slow)
ema_t = ta.ema(close, trend_filter)

spread_pct = math.abs(ema_f - ema_s) / ema_s * 100
t_up   = ema_f > ema_s and ema_s > ema_t and spread_pct > range_band
t_down = ema_f < ema_s and ema_s < ema_t and spread_pct > range_band

trend_txt = t_up ? "▲  UPTREND" : t_down ? "▼  DOWNTREND" : "◆  RANGING"
trend_col = t_up ? #00e676 : t_down ? #ff1744 : #ffd700
trend_bg  = t_up ? color.new(#00e676, 80) : t_down ? color.new(#ff1744, 80) : color.new(#ffd700, 80)

var table tbl = table.new(position.top_right, 1, 2,
     border_color=color.new(color.white, 70), border_width=1,
     frame_color=color.new(color.white, 70),  frame_width=1)

if barstate.islast and show_trend
    table.cell(tbl, 0, 0, "TREND",
         text_color=color.new(color.white, 30), text_size=size.small,
         bgcolor=color.new(color.black, 60))
    table.cell(tbl, 0, 1, trend_txt,
         text_color=trend_col, text_size=size.normal,
         bgcolor=trend_bg)

// ════════════════════════════════════════════════════════════════════
//  PSYCHOLOGICAL LEVELS  (.000 / .500)
// ════════════════════════════════════════════════════════════════════
var line[]  _lines  = array.new_line()
var label[] _labels = array.new_label()

if barstate.islast
    for ln in _lines
        line.delete(ln)
    array.clear(_lines)
    for lb in _labels
        label.delete(lb)
    array.clear(_labels)

    price = close
    step  = f_step(price)
    hstep = step * 0.5
    ls000 = f_lstyle(sty_000)
    ls500 = f_lstyle(sty_500)
    base000 = math.floor(price / step) * step
    base500 = math.floor((price - hstep) / step) * step + hstep

    if show_000
        for i = -n_below to n_above
            lvl = base000 + step * i
            array.push(_lines, line.new(bar_index - 1, lvl, bar_index, lvl,
                 color=col_000, width=p_lw, style=ls000, extend=extend.both))
            if show_plbls
                array.push(_labels, label.new(bar_index + 2, lvl,
                     str.tostring(lvl, format.mintick),
                     style=label.style_none, textcolor=col_000,
                     size=size.tiny, xloc=xloc.bar_index))

    if show_500
        for i = -n_below to n_above
            lvl = base500 + step * i
            array.push(_lines, line.new(bar_index - 1, lvl, bar_index, lvl,
                 color=col_500, width=p_lw, style=ls500, extend=extend.both))
            if show_plbls
                array.push(_labels, label.new(bar_index + 2, lvl,
                     str.tostring(lvl, format.mintick),
                     style=label.style_none, textcolor=col_500,
                     size=size.tiny, xloc=xloc.bar_index))
````
