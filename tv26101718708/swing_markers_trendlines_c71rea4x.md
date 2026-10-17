# Swing Markers + Trendlines

- url: https://www.tradingview.com/script/c71reA4X-Swing-Markers-Trendlines/
- type: indicator
- pine_id: PUB;92f51b647bba445c9d02c497648f5218
- version: 1.0

## Description

// ============================================================================
// SWING HIGH / LOW MARKER + AUTO TRENDLINES  |  Pine Script v6
// ============================================================================
// Green ▲ = confirmed lowest candle before market went UP  (buy zone)
// Red   ▼ = confirmed highest candle before market went DOWN (sell zone)
// Only significant turning points are marked — no noise on every candle.
// ============================================================================

## Source Code

````pine
// ============================================================================
// SWING HIGH / LOW MARKER + AUTO TRENDLINES  |  Pine Script v6
// ============================================================================
// Green ▲ = confirmed lowest candle before market went UP  (buy zone)
// Red   ▼ = confirmed highest candle before market went DOWN (sell zone)
// Only significant turning points are marked — no noise on every candle.
// ============================================================================
//@version=6
indicator("Swing Markers + Trendlines",
     shorttitle       = "SwingTL",
     overlay          = true,
     max_lines_count  = 10,
     max_labels_count = 20,
     max_bars_back    = 500)

// ─────────────────────────────── INPUTS ──────────────────────────────────────
grpSwing  = "Swing Detection"
swingLen  = input.int(10, "Swing Lookback (bars)", minval=3, maxval=50,
     tooltip = "Number of bars required on EACH side to confirm a turning point.\nHigher = fewer, more significant markers.",
     group   = grpSwing)
maxSwings = input.int(6,  "Max recent swings for trendlines", minval=3, maxval=10, group=grpSwing)

grpMark   = "Marker Style"
showHigh  = input.bool(true,  "Show Swing High markers (Red ▼)",  group=grpMark)
showLow   = input.bool(true,  "Show Swing Low  markers (Green ▲)", group=grpMark)

grpLine   = "Trendlines"
showLines = input.bool(true,  "Draw support & resistance trendlines", group=grpLine)
tolPct    = input.float(0.3,  "Violation tolerance (%)", minval=0.1, maxval=2.0, step=0.1, group=grpLine)
extRight  = input.bool(true,  "Extend lines to the right", group=grpLine)
showZone  = input.bool(true,  "Show ±tol% zone shading",  group=grpLine)
showLabels= input.bool(true,  "Show trendline labels",     group=grpLine)
showPrice = input.bool(true,  "Show price at right edge",  group=grpLine)

grpClr    = "Colors"
suppColor = input.color(color.new(#26a69a, 0), "Support / Low color",    group=grpClr)
resColor  = input.color(color.new(#ef5350, 0), "Resistance / High color", group=grpClr)
zoneAlpha = input.int(88, "Zone transparency", minval=50, maxval=99, group=grpClr)

grpAlert  = "Alerts"
alertBreak= input.bool(true, "Alert on trendline break", group=grpAlert)

// ──────────────────────── CONFIRMED PIVOT DETECTION ──────────────────────────
// ta.pivothigh / ta.pivotlow require swingLen bars on EACH side to confirm.
// A pivot high = highest bar in (swingLen + 1 + swingLen) window → true local top.
// A pivot low  = lowest  bar in that window → true local bottom.
// The value is emitted swingLen bars AFTER the pivot candle, so we back-plot
// using offset = -swingLen to place the marker exactly ON the pivot candle.

ph = ta.pivothigh(high, swingLen, swingLen)   // na unless confirmed swing high this bar
pl = ta.pivotlow (low,  swingLen, swingLen)   // na unless confirmed swing low  this bar

// ──────────────────────────── PLOT MARKERS ───────────────────────────────────
// Placed ON the actual pivot candle via offset = -swingLen.
// Red   ▼ sits ABOVE the highest candle  → "market topped here, came down after"
// Green ▲ sits BELOW the lowest  candle  → "market bottomed here, went up after"

plotshape(showHigh and not na(ph),
     title    = "Swing High ▼",
     style    = shape.triangledown,
     location = location.abovebar,
     color    = resColor,
     size     = size.normal,
     offset   = -swingLen)

plotshape(showLow and not na(pl),
     title    = "Swing Low ▲",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = suppColor,
     size     = size.normal,
     offset   = -swingLen)

// ──────────────────────── STORE PIVOTS FOR TRENDLINES ────────────────────────
var float[] ph_price = array.new_float(0)
var int[]   ph_bar   = array.new_int  (0)
var float[] pl_price = array.new_float(0)
var int[]   pl_bar   = array.new_int  (0)

if not na(ph)
    array.push(ph_price, ph)
    array.push(ph_bar,   bar_index - swingLen)
    if array.size(ph_price) > maxSwings
        array.shift(ph_price)
        array.shift(ph_bar)

if not na(pl)
    array.push(pl_price, pl)
    array.push(pl_bar,   bar_index - swingLen)
    if array.size(pl_price) > maxSwings
        array.shift(pl_price)
        array.shift(pl_bar)

// ─────────────────────────── TRENDLINE ENGINE ────────────────────────────────
tol = tolPct / 100.0

f_test_line(x1, y1, x2, y2, kind) =>
    slope       = (y2 - y1) / (x2 - x1)
    intercept   = y1 - slope * x1
    r_slope     = slope
    r_intercept = intercept
    r_touches   = 2
    for k = x1 to x2
        lv = slope * k + intercept
        h  = high[bar_index - k]
        l  = low [bar_index - k]
        if kind == 1  // support — line must stay below lows
            if l < lv * (1 - tol)
                r_slope     := float(na)
                r_intercept := float(na)
                r_touches   := 0
                break
            else if math.abs(l - lv) / lv < tol * 2
                r_touches += 1
        else          // resistance — line must stay above highs
            if h > lv * (1 + tol)
                r_slope     := float(na)
                r_intercept := float(na)
                r_touches   := 0
                break
            else if math.abs(h - lv) / lv < tol * 2
                r_touches += 1
    [r_slope, r_intercept, r_touches]

f_best(bars_arr, price_arr, kind) =>
    n              = array.size(bars_arr)
    best_slope     = float(na)
    best_intercept = float(na)
    best_touches   = 0
    best_x1        = 0
    if n >= 2
        for i = n - 1 to 1
            for j = i - 1 to int(math.max(i - 5, 0))
                x1 = array.get(bars_arr,  j)
                y1 = array.get(price_arr, j)
                x2 = array.get(bars_arr,  i)
                y2 = array.get(price_arr, i)
                if x1 == x2
                    continue
                [sl, ic, tc] = f_test_line(x1, y1, x2, y2, kind)
                if not na(sl) and tc >= best_touches
                    best_touches   := tc
                    best_slope     := sl
                    best_intercept := ic
                    best_x1        := x1
    [best_slope, best_intercept, best_touches, best_x1]

// ─────────────────────────── DRAW TRENDLINES ─────────────────────────────────
var line  supp_line  = na
var line  res_line   = na
var line  supp_zone1 = na
var line  supp_zone2 = na
var line  res_zone1  = na
var line  res_zone2  = na
var label supp_lbl   = na
var label res_lbl    = na
var label supp_price = na
var label res_price  = na

line .delete(supp_line)
line .delete(res_line)
line .delete(supp_zone1)
line .delete(supp_zone2)
line .delete(res_zone1)
line .delete(res_zone2)
label.delete(supp_lbl)
label.delete(res_lbl)
label.delete(supp_price)
label.delete(res_price)

extMode = extRight ? extend.right : extend.none

if showLines and barstate.islast and array.size(pl_bar) >= 2
    [s_sl, s_ic, s_tc, s_x1] = f_best(pl_bar, pl_price, 1)
    if not na(s_sl)
        s_y_now = s_sl * bar_index + s_ic
        s_y_x1  = s_sl * s_x1 + s_ic
        supp_line := line.new(s_x1, s_y_x1, bar_index, s_y_now,
             xloc=xloc.bar_index, extend=extMode,
             color=suppColor, width=2, style=line.style_dashed)
        if showZone
            supp_zone1 := line.new(s_x1, s_y_x1*(1+tol), bar_index, s_y_now*(1+tol),
                 xloc=xloc.bar_index, extend=extMode,
                 color=color.new(suppColor, zoneAlpha), width=1, style=line.style_dotted)
            supp_zone2 := line.new(s_x1, s_y_x1*(1-tol), bar_index, s_y_now*(1-tol),
                 xloc=xloc.bar_index, extend=extMode,
                 color=color.new(suppColor, zoneAlpha), width=1, style=line.style_dotted)
        if showLabels
            supp_lbl := label.new(
                 s_x1 + int((bar_index - s_x1) * 0.35),
                 s_y_x1 + s_sl * int((bar_index - s_x1) * 0.35),
                 (s_sl > 0 ? "Rising" : "Falling") + " Support\n" + str.tostring(s_tc) + " touches",
                 xloc=xloc.bar_index, color=color.new(suppColor, 75),
                 textcolor=suppColor, style=label.style_label_upper_right, size=size.small)
        if showPrice
            supp_price := label.new(bar_index + 3, s_y_now,
                 "S: " + str.tostring(math.round(s_y_now, 0)),
                 xloc=xloc.bar_index, color=color.new(suppColor, 80),
                 textcolor=suppColor, style=label.style_label_left, size=size.small)

if showLines and barstate.islast and array.size(ph_bar) >= 2
    [r_sl, r_ic, r_tc, r_x1] = f_best(ph_bar, ph_price, -1)
    if not na(r_sl)
        r_y_now = r_sl * bar_index + r_ic
        r_y_x1  = r_sl * r_x1 + r_ic
        res_line := line.new(r_x1, r_y_x1, bar_index, r_y_now,
             xloc=xloc.bar_index, extend=extMode,
             color=resColor, width=2, style=line.style_dashed)
        if showZone
            res_zone1 := line.new(r_x1, r_y_x1*(1+tol), bar_index, r_y_now*(1+tol),
                 xloc=xloc.bar_index, extend=extMode,
                 color=color.new(resColor, zoneAlpha), width=1, style=line.style_dotted)
            res_zone2 := line.new(r_x1, r_y_x1*(1-tol), bar_index, r_y_now*(1-tol),
                 xloc=xloc.bar_index, extend=extMode,
                 color=color.new(resColor, zoneAlpha), width=1, style=line.style_dotted)
        if showLabels
            res_lbl := label.new(
                 r_x1 + int((bar_index - r_x1) * 0.35),
                 r_y_x1 + r_sl * int((bar_index - r_x1) * 0.35),
                 (r_sl > 0 ? "Rising" : "Falling") + " Resistance\n" + str.tostring(r_tc) + " touches",
                 xloc=xloc.bar_index, color=color.new(resColor, 75),
                 textcolor=resColor, style=label.style_label_lower_right, size=size.small)
        if showPrice
            res_price := label.new(bar_index + 3, r_y_now,
                 "R: " + str.tostring(math.round(r_y_now, 0)),
                 xloc=xloc.bar_index, color=color.new(resColor, 80),
                 textcolor=resColor, style=label.style_label_left, size=size.small)

// ─────────────────────────── BREAK ALERTS ────────────────────────────────────
var float last_supp = na
var float last_res  = na

if barstate.islast
    if not na(supp_line)
        last_supp := line.get_y2(supp_line)
    if not na(res_line)
        last_res  := line.get_y2(res_line)

supp_broken = alertBreak and not na(last_supp) and close < last_supp * (1 - tol)
res_broken  = alertBreak and not na(last_res)  and close > last_res  * (1 + tol)

alertcondition(supp_broken, title="Support Trendline Break",
     message="⚠️ {{ticker}} broke BELOW support trendline at {{close}}")
alertcondition(res_broken,  title="Resistance Trendline Break",
     message="⚠️ {{ticker}} broke ABOVE resistance trendline at {{close}}")
alertcondition(supp_broken or res_broken, title="Any Trendline Break",
     message="⚠️ {{ticker}} trendline break at {{close}}")
````
