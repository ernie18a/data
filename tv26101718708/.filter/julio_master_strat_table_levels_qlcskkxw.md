# Julio Master Strat Table + Levels

- url: https://www.tradingview.com/script/QlcskkXw-Julio-Master-Strat-Table-Levels/
- type: indicator
- pine_id: PUB;d4a073d0262441f4943aa86e744f54b0
- version: 1.0

## Description

The Strat is a comprehensive trading strategy focusing on candlestick patterns and market trends analysis for recognizing potential market movements.
It emphasizes the importance of inside and outside bars, time frame continuity, and broadening formations for predicting market trends and reversals.
By offering a structured, non-emotional approach to trading, the Strat charting system is ideal for beginner traders.
Emotional trading is one of the major reasons why most traders struggle to become profitable. Thankfully, Rob Smith discovered how to read price action in a logical and non-emotional way and dubbed it “The Strat.” This trading technique has gained some popularity over the past few years. In this latest version I had included the 50% Rules for the daily , weekly and monthly as well as the ATR Value for each stock and Opening line value. If price is above the 50% it will be green and if below it will turn red. I have also included the ES and NQ Value to calculate its volatility between Asia and London session a 0.90 % or more at Market open represent a good standard Volatility. If below this Value it will be a Choppy day and price will rely on a News event to activate the movement of price throughout the day.

## Source Code

````pine
//@version=6
indicator("Julio Master Strat Table + Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. FUNCTIONS
// ==========================================
f_strat(o, h, l, c, ph, pl) =>
    inside  = h <= ph and l >= pl
    outside = h > ph and l < pl
    bullish = c > o
    bearish = c < o
    inside ? 1 : outside ? 3 : bullish ? 2 : bearish ? -2 : 0

f_stratColor(v) =>
    v == 1 ? color.yellow : v == 2 ? #00c853 : v == -2 ? color.red : v == 3 ? color.purple : color.gray

f_stratText(v) =>
    v == 1 ? "1" : v == 2 ? "2U" : v == -2 ? "2D" : v == 3 ? "3" : ""

render(val, col, txt, style, start_bar, offset_val) =>
    var line l = na
    var label lbl = na
    line.delete(l)
    label.delete(lbl)
    if not na(val)
        l := line.new(start_bar, val, bar_index, val, color=col, style=style, width=1)
        lbl := label.new(bar_index + offset_val, val, txt + ": " + str.tostring(val, "#.##"), style=label.style_none, textcolor=col, size=size.small, textalign=text.align_left)

// ==========================================
// 2. DATA FETCH & ATR
// ==========================================
c_orange = #f4980a, c_green = #00c853, c_red = #ff1744, c_white = #ffffff, c_cyan = #00bcd4
c_bright_blue = #00e5ff, c_brown = #8d6e63
label_off = 10 

float d_atr = request.security(syminfo.tickerid, "D", ta.atr(14), barmerge.gaps_off, barmerge.lookahead_on)

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "M", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)
[pqh, pql] = request.security(syminfo.tickerid, "3M", [high[1], low[1]], barmerge.gaps_off, barmerge.lookahead_on)

pd_mid = (pdh + pdl) / 2
pw_mid = (pwh + pwl) / 2
pm_mid = (pmh + pml) / 2
pq_mid = (pqh + pql) / 2

// Session Logic
isPM  = not na(time("D", "0400-0930", "America/New_York"))
isRTH = not na(time("D", "0930-1600", "America/New_York"))
var float pmH = na, var float pmL = na
var int pmStart = na
var float openPrice = na
var int rthStart = na

if ta.change(time("D")) != 0
    pmH := high, pmL := low, pmStart := bar_index
    openPrice := na, rthStart := na

if isPM
    pmH := math.max(high, nz(pmH, high))
    pmL := math.min(low, nz(pmL, low))

if isRTH and na(openPrice)
    openPrice := open, rthStart := bar_index

// ==========================================
// 3. DRAWING ENGINE
// ==========================================
if barstate.islast
    back = 300
    render(openPrice, (close >= openPrice ? c_bright_blue : c_brown), "OPEN", line.style_dashed, rthStart, label_off)
    render(pmH, c_green, "PMH", line.style_dashed, pmStart, label_off)
    render(pmL, c_red, "PML", line.style_dashed, pmStart, label_off)

    // Daily
    render(pdh, c_orange, "PDH", line.style_solid, bar_index - back, label_off)
    render(pdl, c_orange, "PDL", line.style_solid, bar_index - back, label_off)
    render(pd_mid, (close >= pd_mid ? c_green : c_red), "50%", line.style_dotted, bar_index - back, label_off)

    // Weekly
    render(pwh, c_white, "PWH", line.style_solid, bar_index - back, label_off)
    render(pwl, c_white, "PWL", line.style_solid, bar_index - back, label_off)
    render(pw_mid, (close >= pw_mid ? c_green : c_red), "50%(W)", line.style_dotted, bar_index - back, label_off)

    // Monthly
    render(pmh, c_cyan, "PMH(M)", line.style_solid, bar_index - back, label_off)
    render(pml, c_cyan, "PML(M)", line.style_solid, bar_index - back, label_off)
    // FIXED: Added missing Monthly 50% render call
    render(pm_mid, (close >= pm_mid ? c_green : c_red), "50%(M)", line.style_dotted, bar_index - back, label_off)

// ==========================================
// 4. TABLE ENGINE
// ==========================================
f_getRowData(tf) =>
    request.security(syminfo.tickerid, tf, [f_strat(open, high, low, close, high[1], low[1]), f_strat(open[1], high[1], low[1], close[1], high[2], low[2]), f_strat(open[2], high[2], low[2], close[2], high[3], low[3]), f_strat(open[3], high[3], low[3], close[3], high[4], low[4])], barmerge.gaps_off)

if barstate.islast
    tbl = table.new(position.top_right, 6, 6, bgcolor=color.new(color.black, 100))
    headers = array.from("TF", "P3", "P2", "P1", "Now", "50%")
    for i = 0 to 5
        table.cell(tbl, i, 0, array.get(headers, i), text_color=color.white, text_size=size.small)

    tfs = array.from("D", "W", "M", "3M")
    mids = array.from(pd_mid, pw_mid, pm_mid, pq_mid)
    for r = 0 to 3
        curr_tf = array.get(tfs, r)
        [s0, s1, s2, s3] = f_getRowData(curr_tf)
        display_tf = curr_tf == "3M" ? "Q" : curr_tf
        table.cell(tbl, 0, r+1, display_tf, text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r+1, f_stratText(s3), text_color=f_stratColor(s3), text_size=size.small)
        table.cell(tbl, 2, r+1, f_stratText(s2), text_color=f_stratColor(s2), text_size=size.small)
        table.cell(tbl, 3, r+1, f_stratText(s1), text_color=f_stratColor(s1), text_size=size.small)
        table.cell(tbl, 4, r+1, f_stratText(s0), text_color=f_stratColor(s0), text_size=size.small)
        table.cell(tbl, 5, r+1, "●", text_color=(close >= array.get(mids, r) ? #00c853 : color.red), text_size=size.normal)

    table.cell(tbl, 0, 5, "ES %", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, 5, "9.691%", text_color=#00c853, text_size=size.small)
    table.cell(tbl, 2, 5, "NQ %", text_color=color.white, text_size=size.small)
    table.cell(tbl, 3, 5, "12.706%", text_color=#00c853, text_size=size.small)
    table.cell(tbl, 4, 5, "ATR", text_color=color.white, text_size=size.small)
    table.cell(tbl, 5, 5, str.tostring(d_atr, "#.##"), text_color=color.white, text_size=size.small)

barcolor(f_stratColor(f_strat(open, high, low, close, high[1], low[1])))
````
