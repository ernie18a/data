# The Blueprint by RossenHouse

- url: https://www.tradingview.com/script/g9o6u9G9-The-Blueprint-by-RossenHouse/
- type: indicator
- pine_id: PUB;8c375f4ff3bb4b66bf108421d9b0fb62
- version: 1.0

## Description

The Blueprint by RossenHouse is a precision‑built market structure tool designed to track 4‑Hour sweep setups and project their key levels onto any lower timeframe, from 1H all the way down to 1‑minute charts.

This script automatically detects both forming and confirmed 4H sweeps using wick‑based logic and body‑validation rules. Once a sweep is identified, the indicator anchors:

A 4H sweep line at the exact wick of the swept candle

25% / 50% / 75% fib levels derived from the 4H range

All levels projected forward with perfect time alignment using bar‑time anchoring

The result is a clean, non‑repainting multi‑TF view of higher‑timeframe liquidity events, allowing traders to zoom into lower timeframes while maintaining full awareness of the dominant 4H structure.

Ideal for traders who rely on liquidity sweeps, premium/discount zones, and HTF‑to‑LTF execution

## Source Code

````pine
//@version=6
indicator("The Blueprint — RossenHouse", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ===================== INPUTS =====================
showBull = input.bool(true, "Show Bullish Setups")
showBear = input.bool(true, "Show Bearish Setups")

show25          = input.bool(true,  "Show 25%")
show50          = input.bool(true,  "Show 50%")
show75          = input.bool(false, "Show 75%")
fibDistanceBars = input.int(0,  "Fib Distance From Current TF Candle (Bars)", minval = 0)
fibLengthBars   = input.int(3,  "Fib Segment Length (Bars)", minval = 1)

range25Color = input.color(color.new(#000000, 0), "25% Color")
range50Color = input.color(color.new(#000000, 0), "50% Color")
range75Color = input.color(color.new(#000000, 0), "75% Color")

sweepColor = input.color(color.red, "Sweep Line Color")

// ===================== HELPERS =====================
msPerTF(tfHours) => tfHours * 60 * 60 * 1000
transparentBg = color.new(color.black, 100)

// ===================== LOCAL SWEEP TEST (wick-only + close vs body) =====================
// returns 2 = bull, 1 = none, 0 = bear
f_sweep_state_local() =>
    prev1_o = open[1]
    prev1_h = high[1]
    prev1_l = low[1]
    prev1_c = close[1]

    prev2_o = open[2]
    prev2_h = high[2]
    prev2_l = low[2]
    prev2_c = close[2]

    prev2_body_high = math.max(prev2_o, prev2_c)
    prev2_body_low  = math.min(prev2_o, prev2_c)

    bull_cond = (prev1_l < prev2_l) and (prev1_c > prev2_body_high)
    bear_cond = (prev1_h > prev2_h) and (prev1_c < prev2_body_low)

    bull_cond ? 2 : bear_cond ? 0 : 1

// ===================== 4H SERIES FOR DRAWING & FORMING DETECTION =====================
getTF(tf) =>
    o = request.security(syminfo.tickerid, tf, open,  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    h = request.security(syminfo.tickerid, tf, high,  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    l = request.security(syminfo.tickerid, tf, low,   gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    c = request.security(syminfo.tickerid, tf, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    t = request.security(syminfo.tickerid, tf, time,  gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
    [o,h,l,c,t]

[h4o,h4h,h4l,h4c,h4t] = getTF("240")

// compute prev1/prev2 for 4H
f_prev_vals(o,h,l,c,t) =>
    p1_o = o[1]
    p1_h = h[1]
    p1_l = l[1]
    p1_c = c[1]
    p1_t = t[1]
    p2_o = o[2]
    p2_h = h[2]
    p2_l = l[2]
    p2_c = c[2]
    p2_t = t[2]
    [p1_o,p1_h,p1_l,p1_c,p1_t,p2_o,p2_h,p2_l,p2_c,p2_t]

[p1o4,p1h4,p1l4,p1c4,p1t4,p2o4,p2h4,p2l4,p2c4,p2t4] = f_prev_vals(h4o,h4h,h4l,h4c,h4t)

// ===================== CLOSED 4H SWEEPS =====================
prev2_body_high_4 = math.max(p2o4, p2c4)
prev2_body_low_4  = math.min(p2o4, p2c4)

closedBull4 = (p1l4 < p2l4) and (p1c4 > prev2_body_high_4)
closedBear4 = (p1h4 > p2h4) and (p1c4 < prev2_body_low_4)

// ===================== FORMING 4H SWEEPS =====================
curr_l4 = h4l[0]
curr_h4 = h4h[0]
curr_c4 = h4c[0]

prev_body_high_curr_4 = math.max(h4o[1], h4c[1])
prev_body_low_curr_4  = math.min(h4o[1], h4c[1])

formingBull4 = (curr_l4 < h4l[1]) and (curr_c4 > prev_body_high_curr_4) and not closedBull4
formingBear4 = (curr_h4 > h4h[1]) and (curr_c4 < prev_body_low_curr_4) and not closedBear4

// ===================== NEW 4H CANDLE (strict TF-open trigger) =====================
new4 = ta.change(h4t) != 0

// ===================== OBJECT MANAGEMENT =====================
var line[]  linesArr  = array.new_line()
var label[] labelsArr = array.new_label()
maxObjects = 40

f_store_line(l) =>
    array.push(linesArr, l)
    while array.size(linesArr) > maxObjects
        ln = array.shift(linesArr)
        if not na(ln)
            line.delete(ln)

f_store_label(lb) =>
    array.push(labelsArr, lb)
    while array.size(labelsArr) > maxObjects
        lbp = array.shift(labelsArr)
        if not na(lbp)
            label.delete(lbp)

f_clear_all() =>
    while array.size(linesArr) > 0
        ln = array.pop(linesArr)
        if not na(ln)
            line.delete(ln)
    while array.size(labelsArr) > 0
        lb = array.pop(labelsArr)
        if not na(lb)
            label.delete(lb)

// ===================== DRAWING FUNCTION (4H sweep + fibs, visible on all TFs) =====================
f_draw_for_tf(isBull, isBear, p1_h, p1_l, p1_t, p2_h, p2_l, p2_t) =>
    // clear previous objects when a new trigger occurs
    f_clear_all()

    sweeperHigh = p1_h
    sweeperLow  = p1_l
    r_sweeper   = sweeperHigh - sweeperLow

    float lvl25 = na
    float lvl50 = na
    float lvl75 = na

    if isBull
        lvl25 := sweeperHigh - r_sweeper * 0.25
        lvl50 := sweeperLow  + r_sweeper * 0.50
        lvl75 := sweeperLow  + r_sweeper * 0.25
    else
        lvl25 := sweeperLow  + r_sweeper * 0.25
        lvl50 := sweeperLow  + r_sweeper * 0.50
        lvl75 := sweeperLow  + r_sweeper * 0.75

    // Sweep line anchored to swept candle (prev2 wick), using 4H time
    sweepPrice = isBull ? p2_l : p2_h
    sweepLine = line.new(
        x1 = p2_t,
        y1 = sweepPrice,
        x2 = p2_t + fibLengthBars * msPerTF(4),
        y2 = sweepPrice,
        xloc = xloc.bar_time,
        color = sweepColor,
        width = 2
    )
    f_store_line(sweepLine)

    // Fib lines starting at current chart bar_index (visible on any TF)
    startBar = bar_index + fibDistanceBars
    endBar   = startBar + fibLengthBars

    if show25
        l1 = line.new(x1 = startBar, y1 = lvl25, x2 = endBar, y2 = lvl25, xloc = xloc.bar_index, color = range25Color, width = 1)
        lineY1 = line.get_price(l1, 0)
        lineX1 = line.get_x2(l1)
        lb1 = label.new(lineX1, lineY1, "25%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textalign = text.align_right, size = size.tiny, color = transparentBg, textcolor = range25Color)
        f_store_line(l1)
        f_store_label(lb1)

    if show50
        l2 = line.new(x1 = startBar, y1 = lvl50, x2 = endBar, y2 = lvl50, xloc = xloc.bar_index, color = range50Color, width = 1)
        lineY2 = line.get_price(l2, 0)
        lineX2 = line.get_x2(l2)
        lb2 = label.new(lineX2, lineY2, "50%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textalign = text.align_right, size = size.tiny, color = transparentBg, textcolor = range50Color)
        f_store_line(l2)
        f_store_label(lb2)

    if show75
        l3 = line.new(x1 = startBar, y1 = lvl75, x2 = endBar, y2 = lvl75, xloc = xloc.bar_index, color = range75Color, width = 1)
        lineY3 = line.get_price(l3, 0)
        lineX3 = line.get_x2(l3)
        lb3 = label.new(lineX3, lineY3, "75%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, textalign = text.align_right, size = size.tiny, color = transparentBg, textcolor = range75Color)
        f_store_line(l3)
        f_store_label(lb3)

// ===================== 4H SETUPS VISIBLE ON ALL LOWER TIMEFRAMES =====================
// No timeframe gate: this runs on any chart TF (1m → 1H → 4H+)

if (formingBull4 and showBull) or (formingBear4 and showBear)
    f_draw_for_tf(formingBull4, formingBear4, h4h[0], h4l[0], h4t[0], h4h[1], h4l[1], h4t[1])

if new4 and ((closedBull4 and showBull) or (closedBear4 and showBear))
    f_draw_for_tf(closedBull4, closedBear4, p1h4, p1l4, p1t4, p2h4, p2l4, p2t4)
````
