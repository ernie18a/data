# Doji  Structure  Psych Levels

- url: https://www.tradingview.com/script/Jz9ZTC8O-Doji-Structure-Psych-Levels/
- type: indicator
- pine_id: PUB;9ca1277b7bd648329403fb36a2d072a8
- version: 1.0

## Description

an indicator showing doji signal with hh hl ll lh    and psychological level of 000  and 500

## Source Code

````pine
//@version=6
indicator("Doji · Structure · Psych Levels", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Candlestick Patterns
// ════════════════════════════════════════════════════════════════════
G1 = "── Candlestick Patterns ──"

show_doji   = input.bool(true,  "Doji Star",              group=G1, inline="p1")
col_doji    = input.color(#ff1744, "",                    group=G1, inline="p1")
show_grave  = input.bool(true,  "Gravestone Doji",        group=G1, inline="p2")
col_grave   = input.color(#ff1744, "",                    group=G1, inline="p2")
show_dragon = input.bool(true,  "Dragonfly Doji",         group=G1, inline="p3")
col_dragon  = input.color(#00e676, "",                    group=G1, inline="p3")
show_hammer = input.bool(true,  "Hammer",                 group=G1, inline="p4")
col_hammer  = input.color(#00e676, "",                    group=G1, inline="p4")
show_shoot  = input.bool(true,  "Shooting / Falling Star",group=G1, inline="p5")
col_shoot   = input.color(#ff1744, "",                    group=G1, inline="p5")

doji_pct   = input.float(0.10, "Doji Body %",
     group=G1, minval=0.01, maxval=0.40, step=0.01,
     tooltip="Candle body must be ≤ this fraction of the full range to qualify as a doji")
wick_ratio = input.float(2.0,  "Hammer / Star Wick Ratio",
     group=G1, minval=1.0, maxval=6.0, step=0.1,
     tooltip="Wick must be at least this multiple of the body to qualify as hammer or shooting star")

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Market Structure
// ════════════════════════════════════════════════════════════════════
G2 = "── Market Structure  (HH · HL · LH · LL) ──"

show_HH  = input.bool(true, "HH", group=G2, inline="ms")
show_HL  = input.bool(true, "HL", group=G2, inline="ms")
show_LH  = input.bool(true, "LH", group=G2, inline="ms")
show_LL  = input.bool(true, "LL", group=G2, inline="ms")
ms_lb    = input.int(10, "Pivot Lookback", group=G2, minval=3, maxval=50,
     tooltip="Bars on each side required to confirm a swing high or swing low")
col_bull = input.color(#00e676, "Bullish Label", group=G2, inline="msc")
col_bear = input.color(#ff1744, "Bearish Label", group=G2, inline="msc")

// ════════════════════════════════════════════════════════════════════
//  INPUTS — Psychological Levels
// ════════════════════════════════════════════════════════════════════
G3 = "── Psychological Levels  (.000 · .500) ──"

show_000 = input.bool(true, "Show .000 Levels", group=G3)
col_000  = input.color(color.new(#ffffff, 50), ".000 Color", group=G3, inline="c1")
sty_000  = input.string("Dotted", ".000 Style", group=G3, inline="c1",
     options=["Solid","Dashed","Dotted"])

show_500 = input.bool(true, "Show .500 Levels", group=G3)
col_500  = input.color(color.new(#ffd700, 50), ".500 Color", group=G3, inline="c2")
sty_500  = input.string("Dashed", ".500 Style", group=G3, inline="c2",
     options=["Solid","Dashed","Dotted"])

n_above    = input.int(5, "Levels Above", group=G3, minval=1, maxval=30, inline="nl")
n_below    = input.int(5, "Levels Below", group=G3, minval=1, maxval=30, inline="nl")
p_lw       = input.int(1, "Line Width",   group=G3, minval=1, maxval=4)
show_plbls = input.bool(true, "Show Price Labels", group=G3)

// ════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ════════════════════════════════════════════════════════════════════

// Convert style string → Pine line style constant
f_lstyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        =>          line.style_dotted

// Determine big-figure step from price magnitude
//   EURCHF 0.912  → 0.01   (.000 = 0.900 / 0.910 / 0.920 …)
//   EURUSD 1.085  → 0.01   (.000 = 1.080 / 1.090 …)
//   USDJPY 150.1  → 1.0    (.000 = 150 / 151 …)
//   Gold   2 050  → 100.0  (.000 = 2000 / 2100 …)
f_step(float p) =>
    if p >= 1000.0
        100.0
    else if p >= 100.0
        10.0
    else if p >= 10.0
        1.0
    else
        0.01  // covers 0–10 (all forex majors/minors)

// ════════════════════════════════════════════════════════════════════
//  CANDLE MEASUREMENTS
// ════════════════════════════════════════════════════════════════════
body  = math.abs(close - open)
rng   = high - low
up_w  = high - math.max(close, open)
dn_w  = math.min(close, open) - low

// ── Doji classification ─────────────────────────────────────────────
doji_base  = rng > 0 and body <= rng * doji_pct

// Standard Doji Star — balanced wicks on both sides
doji_star  = doji_base and
             up_w > rng * 0.15 and dn_w > rng * 0.15 and
             not (up_w >= rng * 0.65) and not (dn_w >= rng * 0.65)

// Gravestone Doji — long upper wick, near-zero lower wick
gravestone = doji_base and up_w >= rng * 0.65 and dn_w <= rng * 0.10

// Dragonfly Doji — long lower wick, near-zero upper wick
dragonfly  = doji_base and dn_w >= rng * 0.65 and up_w <= rng * 0.10

// ── Hammer & Shooting Star ─────────────────────────────────────────
hammer   = not doji_base and body > 0 and
           dn_w >= body * wick_ratio and up_w <= body * 0.5

shooting = not doji_base and body > 0 and
           up_w >= body * wick_ratio and dn_w <= body * 0.5

// ════════════════════════════════════════════════════════════════════
//  PLOT — Candlestick Patterns
// ════════════════════════════════════════════════════════════════════
plotshape(show_doji  and doji_star,
     title="Doji Star",
     style=shape.triangledown, location=location.abovebar,
     color=col_doji,  textcolor=col_doji,  text="Doji star",  size=size.small)

plotshape(show_grave and gravestone,
     title="Gravestone Doji",
     style=shape.triangledown, location=location.abovebar,
     color=col_grave, textcolor=col_grave, text="Gravestone", size=size.small)

plotshape(show_dragon and dragonfly,
     title="Dragonfly Doji",
     style=shape.triangleup,   location=location.belowbar,
     color=col_dragon, textcolor=col_dragon, text="Dragonfly", size=size.small)

plotshape(show_hammer and hammer,
     title="Hammer",
     style=shape.triangleup,   location=location.belowbar,
     color=col_hammer, textcolor=col_hammer, text="Hammer",   size=size.small)

plotshape(show_shoot and shooting,
     title="Shooting / Falling Star",
     style=shape.triangledown, location=location.abovebar,
     color=col_shoot,  textcolor=col_shoot,  text="Falling star", size=size.small)

// ════════════════════════════════════════════════════════════════════
//  MARKET STRUCTURE  (HH / HL / LH / LL)
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

plotshape(show_HH and is_HH,
     title="HH", style=shape.labeldown, location=location.abovebar,
     color=col_bull, textcolor=color.black, text="HH",
     size=size.small, offset=-ms_lb)

plotshape(show_LH and is_LH,
     title="LH", style=shape.labeldown, location=location.abovebar,
     color=col_bear, textcolor=color.white, text="LH",
     size=size.small, offset=-ms_lb)

plotshape(show_HL and is_HL,
     title="HL", style=shape.labelup,   location=location.belowbar,
     color=col_bull, textcolor=color.black, text="HL",
     size=size.small, offset=-ms_lb)

plotshape(show_LL and is_LL,
     title="LL", style=shape.labelup,   location=location.belowbar,
     color=col_bear, textcolor=color.white, text="LL",
     size=size.small, offset=-ms_lb)

// ════════════════════════════════════════════════════════════════════
//  PSYCHOLOGICAL LEVELS  (.000 / .500)
// ════════════════════════════════════════════════════════════════════
var line[]  _lines  = array.new_line()
var label[] _labels = array.new_label()

if barstate.islast

    // ── Clear previous drawings every tick ────────────────────────
    for ln in _lines
        line.delete(ln)
    array.clear(_lines)
    for lb in _labels
        label.delete(lb)
    array.clear(_labels)

    price = close
    step  = f_step(price)
    hstep = step * 0.5          // half-step for .500 levels

    ls000 = f_lstyle(sty_000)
    ls500 = f_lstyle(sty_500)

    // Nearest .000 AT or BELOW current price
    base000 = math.floor(price / step) * step

    // Nearest .500 AT or BELOW current price
    base500 = math.floor((price - hstep) / step) * step + hstep

    // ── Draw .000 levels  (i loops from -n_below to +n_above) ─────
    if show_000
        for i = -n_below to n_above
            lvl = base000 + step * i
            array.push(_lines, line.new(
                 bar_index - 1, lvl, bar_index, lvl,
                 color=col_000, width=p_lw, style=ls000,
                 extend=extend.both))
            if show_plbls
                array.push(_labels, label.new(
                     bar_index + 2, lvl,
                     str.tostring(lvl, format.mintick),
                     style=label.style_none, textcolor=col_000,
                     size=size.tiny, xloc=xloc.bar_index))

    // ── Draw .500 levels ──────────────────────────────────────────
    if show_500
        for i = -n_below to n_above
            lvl = base500 + step * i
            array.push(_lines, line.new(
                 bar_index - 1, lvl, bar_index, lvl,
                 color=col_500, width=p_lw, style=ls500,
                 extend=extend.both))
            if show_plbls
                array.push(_labels, label.new(
                     bar_index + 2, lvl,
                     str.tostring(lvl, format.mintick),
                     style=label.style_none, textcolor=col_500,
                     size=size.tiny, xloc=xloc.bar_index))
````
