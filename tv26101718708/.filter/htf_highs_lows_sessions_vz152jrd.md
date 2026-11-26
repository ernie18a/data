# HTF Highs & Lows + Sessions

- url: https://www.tradingview.com/script/vz152JrD-HTF-Highs-Lows-Sessions/
- type: indicator
- pine_id: PUB;9f27c3a04cc24f7393107360e7084f62
- version: 3.0

## Description

[b]HTF Highs & Lows + Sessions
[/b]This indicator plots two categories of information on your chart: higher timeframe swing levels and session highs/lows.
[b]HTF Swing Levels
[/b]Scans 1H, 4H, and 1D candles for a specific two-bar reversal pattern — a bullish candle followed by a bearish candle (for swing highs) or a bearish candle followed by a bullish candle (for swing lows). When that pattern is found, it marks the extreme of those two candles as a significant price level. It then checks if that level has already been taken out by a subsequent candle — if it has, the level is ignored. If it hasn't, it draws a horizontal ray extending to the right from that price. Each timeframe has its own color (light red for 1H, bright red for 4H, dark red for 1D) so you can quickly identify which timeframe a level belongs to.
If price takes out one of these levels during the sweep window (8am–12pm ET), the ray converts to a dotted line and stops extending, marking it as swept rather than deleting it entirely.
[b]Session Highs & Lows
[/b]Tracks the high and low of four sessions in real time — New York (9:30–5pm ET), London (3–8am ET), Asia (6pm–3am ET), and Pre Market (8–9:30am ET). Each session gets a live horizontal line at its current high and low that updates as price moves. When price breaks a session level outside the sweep window the line is deleted. When price breaks it inside the sweep window (8am–12pm ET) it converts to a dotted line instead, preserving the swept level visually. Session lines only display on intraday timeframes and are hidden on the daily and above.
[b]Intended Use
[/b]Designed for traders who use higher timeframe liquidity levels as context for intraday entries — particularly identifying which HTF swing points have been swept during the early New York session window, which is a core concept in smart money / ICT-based trading frameworks.

## Source Code

````pine
//@version=6
indicator("HTF Highs & Lows + Sessions", overlay=true, max_lines_count=500)

// ── Timeframe Guard ───────────────────────────────────────────────────────────
isBelowHour = timeframe.in_seconds() < 3600

// ── HTF Inputs ────────────────────────────────────────────────────────────────
show_1h = input.bool(true, "1H",           group="HTF Levels")
show_4h = input.bool(true, "4H",           group="HTF Levels")
show_1d = input.bool(true, "1D",           group="HTF Levels")
lb_1h   = input.int(48,   "1H Lookback",  group="HTF Levels", minval=3, maxval=200)
lb_4h   = input.int(12,   "4H Lookback",  group="HTF Levels", minval=3, maxval=100)

// ── Session Inputs ────────────────────────────────────────────────────────────
show_ny   = input.bool(true, "New York    09:30–17:00 ET", group="Sessions")
show_lon  = input.bool(true, "London      03:00–08:00 ET", group="Sessions")
show_asia = input.bool(true, "Asia        18:00–03:00 ET", group="Sessions")
show_pre  = input.bool(true, "Pre Market  08:00–09:30 ET", group="Sessions")

// ── Colors ────────────────────────────────────────────────────────────────────
color COL_1H   = color.rgb(255, 120, 120)
color COL_4H   = color.rgb(220, 0,   0)
color COL_1D   = color.rgb(120, 0,   0)
color COL_NY   = color.rgb(255, 153, 51)
color COL_LON  = color.rgb(51,  102, 255)
color COL_ASIA = color.rgb(255, 105, 180)
color COL_PRE  = color.rgb(80,  200, 80)

// ── HTF Data ──────────────────────────────────────────────────────────────────
[sec1h_o, sec1h_h, sec1h_l, sec1h_c, sec1h_t] = request.security(syminfo.tickerid, "60",  [open, high, low, close, time], lookahead=barmerge.lookahead_on)
[sec4h_o, sec4h_h, sec4h_l, sec4h_c, sec4h_t] = request.security(syminfo.tickerid, "240", [open, high, low, close, time], lookahead=barmerge.lookahead_on)

// ── Previous Day High/Low ─────────────────────────────────────────────────────
[pd_h, pd_l] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

// ── HTF OHLC Storage ──────────────────────────────────────────────────────────
var float[] arr1h_o = array.new<float>()
var float[] arr1h_h = array.new<float>()
var float[] arr1h_l = array.new<float>()
var float[] arr1h_c = array.new<float>()
var int[]   arr1h_t = array.new<int>()
var float[] arr4h_o = array.new<float>()
var float[] arr4h_h = array.new<float>()
var float[] arr4h_l = array.new<float>()
var float[] arr4h_c = array.new<float>()
var int[]   arr4h_t = array.new<int>()
var line[]  gLines  = array.new<line>()

// ── HTF Swept Level Storage ───────────────────────────────────────────────────
var float[] htf_swept_price = array.new<float>()
var int[]   htf_swept_start = array.new<int>()
var int[]   htf_swept_end   = array.new<int>()
var color[] htf_swept_col   = array.new<color>()
var line[]  htf_swept_lns   = array.new<line>()

// ── Previous Day Line State ───────────────────────────────────────────────────
var line  pd_h_ln        = na
var line  pd_l_ln        = na
var bool  pd_h_swept     = false
var bool  pd_l_swept     = false
var int   pd_h_found_bar = na
var int   pd_l_found_bar = na

// ── HTF Accumulation ──────────────────────────────────────────────────────────
if ta.change(sec1h_t) != 0
    array.push(arr1h_o, sec1h_o[1]), array.push(arr1h_h, sec1h_h[1])
    array.push(arr1h_l, sec1h_l[1]), array.push(arr1h_c, sec1h_c[1])
    array.push(arr1h_t, sec1h_t[1])
    while array.size(arr1h_o) > lb_1h
        array.shift(arr1h_o), array.shift(arr1h_h), array.shift(arr1h_l)
        array.shift(arr1h_c), array.shift(arr1h_t)

if ta.change(sec4h_t) != 0
    array.push(arr4h_o, sec4h_o[1]), array.push(arr4h_h, sec4h_h[1])
    array.push(arr4h_l, sec4h_l[1]), array.push(arr4h_c, sec4h_c[1])
    array.push(arr4h_t, sec4h_t[1])
    while array.size(arr4h_o) > lb_4h
        array.shift(arr4h_o), array.shift(arr4h_h), array.shift(arr4h_l)
        array.shift(arr4h_c), array.shift(arr4h_t)

// ── Helper: Check if already recorded as swept ────────────────────────────────
alreadySwept(price, startT) =>
    found = false
    n = array.size(htf_swept_price)
    if n > 0
        for si = 0 to n - 1
            if array.get(htf_swept_price, si) == price and array.get(htf_swept_start, si) == startT
                found := true
                break
    found

// ── Find intraday bar where price printed ─────────────────────────────────────
findHighBar(price) =>
    result = bar_index
    for i = 0 to 500
        if high[i] == price
            result := bar_index - i
            break
    result

findLowBar(price) =>
    result = bar_index
    for i = 0 to 500
        if low[i] == price
            result := bar_index - i
            break
    result

// ── HTF Draw Function ─────────────────────────────────────────────────────────
drawLevel(price, isHigh, col) =>
    anchorBar = isHigh ? findHighBar(price) : findLowBar(price)
    ln = line.new(anchorBar, price, anchorBar + 500, price,
        color=col, width=1, extend=extend.right)
    array.push(gLines, ln)

// ── HTF Scan + Draw ───────────────────────────────────────────────────────────
scanAndDraw(oArr, hArr, lArr, cArr, tArr, col, show) =>
    if barstate.islast and show
        n = array.size(oArr)
        if n >= 3
            priceMin = close * 0.70
            priceMax = close * 1.30
            for i = 0 to n - 2
                oi = array.get(oArr, i),  ci = array.get(cArr, i)
                hi = array.get(hArr, i),  li = array.get(lArr, i)
                ti = array.get(tArr, i)
                oj = array.get(oArr, i+1), cj = array.get(cArr, i+1)
                hj = array.get(hArr, i+1), lj = array.get(lArr, i+1)
                tj = array.get(tArr, i+1)
                if ci > oi and cj < oj
                    swP    = math.max(hi, hj)
                    startT = hi >= hj ? ti : tj
                    if swP < priceMin or swP > priceMax
                        continue
                    swept  = false
                    if i + 2 <= n - 1
                        for k = i + 2 to n - 1
                            if array.get(hArr, k) >= swP
                                swept := true
                                break
                    if not swept
                        if high < swP
                            drawLevel(swP, true, col)
                        else
                            if not alreadySwept(swP, startT)
                                array.push(htf_swept_price, swP)
                                array.push(htf_swept_start, startT)
                                array.push(htf_swept_end,   time)
                                array.push(htf_swept_col,   col)
                if ci < oi and cj > oj
                    swP    = math.min(li, lj)
                    startT = li <= lj ? ti : tj
                    if swP < priceMin or swP > priceMax
                        continue
                    swept  = false
                    if i + 2 <= n - 1
                        for k = i + 2 to n - 1
                            if array.get(lArr, k) <= swP
                                swept := true
                                break
                    if not swept
                        if low > swP
                            drawLevel(swP, false, col)
                        else
                            if not alreadySwept(swP, startT)
                                array.push(htf_swept_price, swP)
                                array.push(htf_swept_start, startT)
                                array.push(htf_swept_end,   time)
                                array.push(htf_swept_col,   col)

// ── barstate.islast: Cleanup + Redraw ─────────────────────────────────────────
if barstate.islast and isBelowHour
    for ln in gLines
        line.delete(ln)
    array.clear(gLines)

    for ln in htf_swept_lns
        line.delete(ln)
    array.clear(htf_swept_lns)

    n_sw = array.size(htf_swept_price)
    if n_sw > 0
        for si = 0 to n_sw - 1
            p  = array.get(htf_swept_price, si)
            st = array.get(htf_swept_start, si)
            et = array.get(htf_swept_end,   si)
            c  = array.get(htf_swept_col,   si)
            ln = line.new(st, p, et, p,
                xloc=xloc.bar_time, color=c, width=1, style=line.style_dotted)
            array.push(htf_swept_lns, ln)

    scanAndDraw(arr1h_o, arr1h_h, arr1h_l, arr1h_c, arr1h_t, COL_1H, show_1h)
    scanAndDraw(arr4h_o, arr4h_h, arr4h_l, arr4h_c, arr4h_t, COL_4H, show_4h)

// ── Previous Day H/L ─────────────────────────────────────────────────────────
pd_h_changed = ta.change(pd_h) != 0
pd_l_changed = ta.change(pd_l) != 0

if isBelowHour and show_1d and not na(pd_h) and not na(pd_l)
    if pd_h_changed or pd_l_changed
        line.delete(pd_h_ln)
        line.delete(pd_l_ln)
        pd_h_ln        := na
        pd_l_ln        := na
        pd_h_swept     := false
        pd_l_swept     := false
        pd_h_found_bar := na
        pd_l_found_bar := na

    if na(pd_h_found_bar)
        for i = 0 to 500
            if high[i] == pd_h
                pd_h_found_bar := bar_index - i
                break

    if na(pd_l_found_bar)
        for i = 0 to 500
            if low[i] == pd_l
                pd_l_found_bar := bar_index - i
                break

    if not na(pd_h_found_bar) and na(pd_h_ln)
        pd_h_ln := line.new(pd_h_found_bar, pd_h, pd_h_found_bar + 500, pd_h,
            color=COL_1D, width=1, extend=extend.right)

    if not na(pd_l_found_bar) and na(pd_l_ln)
        pd_l_ln := line.new(pd_l_found_bar, pd_l, pd_l_found_bar + 500, pd_l,
            color=COL_1D, width=1, extend=extend.right)

    if not na(pd_h_ln) and not pd_h_swept and high >= pd_h
        pd_h_swept := true
        line.set_style(pd_h_ln,  line.style_dotted)
        line.set_extend(pd_h_ln, extend.none)
        line.set_x2(pd_h_ln,     bar_index)

    if not na(pd_l_ln) and not pd_l_swept and low <= pd_l
        pd_l_swept := true
        line.set_style(pd_l_ln,  line.style_dotted)
        line.set_extend(pd_l_ln, extend.none)
        line.set_x2(pd_l_ln,     bar_index)

// ── Session Detection ─────────────────────────────────────────────────────────
inNY   = not na(time(timeframe.period, "0930-1700:23456", "America/New_York"))
inLon  = not na(time(timeframe.period, "0300-0800:23456", "America/New_York"))
inAsia = not na(time(timeframe.period, "1800-0300:23456", "America/New_York"))
inPre  = not na(time(timeframe.period, "0800-0930:23456", "America/New_York"))

// ── Session H/L – New York ────────────────────────────────────────────────────
var float ny_h     = na
var float ny_l     = na
var int   ny_h_bar = na
var int   ny_l_bar = na
var bool  prev_ny  = false
var line  ny_h_ln  = na
var line  ny_l_ln  = na

if isBelowHour and show_ny
    if inNY and not prev_ny
        line.delete(ny_h_ln)
        line.delete(ny_l_ln)
        ny_h := high, ny_l := low
        ny_h_bar := bar_index, ny_l_bar := bar_index
        ny_h_ln := line.new(bar_index, high, bar_index + 500, high, color=COL_NY, width=1, extend=extend.right)
        ny_l_ln := line.new(bar_index, low,  bar_index + 500, low,  color=COL_NY, width=1, extend=extend.right)
    else if inNY
        if high > ny_h
            ny_h := high
            ny_h_bar := bar_index
            line.set_x1(ny_h_ln, bar_index)
            line.set_y1(ny_h_ln, ny_h)
            line.set_y2(ny_h_ln, ny_h)
        if low < ny_l
            ny_l := low
            ny_l_bar := bar_index
            line.set_x1(ny_l_ln, bar_index)
            line.set_y1(ny_l_ln, ny_l)
            line.set_y2(ny_l_ln, ny_l)
    else
        if not na(ny_h_ln) and high >= ny_h
            line.set_style(ny_h_ln,  line.style_dotted)
            line.set_extend(ny_h_ln, extend.none)
            line.set_x2(ny_h_ln,     bar_index)
            ny_h_ln := na
        if not na(ny_l_ln) and low <= ny_l
            line.set_style(ny_l_ln,  line.style_dotted)
            line.set_extend(ny_l_ln, extend.none)
            line.set_x2(ny_l_ln,     bar_index)
            ny_l_ln := na
prev_ny := inNY

// ── Session H/L – London ──────────────────────────────────────────────────────
var float lon_h     = na
var float lon_l     = na
var int   lon_h_bar = na
var int   lon_l_bar = na
var bool  prev_lon  = false
var line  lon_h_ln  = na
var line  lon_l_ln  = na

if isBelowHour and show_lon
    if inLon and not prev_lon
        line.delete(lon_h_ln)
        line.delete(lon_l_ln)
        lon_h := high, lon_l := low
        lon_h_bar := bar_index, lon_l_bar := bar_index
        lon_h_ln := line.new(bar_index, high, bar_index + 500, high, color=COL_LON, width=1, extend=extend.right)
        lon_l_ln := line.new(bar_index, low,  bar_index + 500, low,  color=COL_LON, width=1, extend=extend.right)
    else if inLon
        if high > lon_h
            lon_h := high
            lon_h_bar := bar_index
            line.set_x1(lon_h_ln, bar_index)
            line.set_y1(lon_h_ln, lon_h)
            line.set_y2(lon_h_ln, lon_h)
        if low < lon_l
            lon_l := low
            lon_l_bar := bar_index
            line.set_x1(lon_l_ln, bar_index)
            line.set_y1(lon_l_ln, lon_l)
            line.set_y2(lon_l_ln, lon_l)
    else
        if not na(lon_h_ln) and high >= lon_h
            line.set_style(lon_h_ln,  line.style_dotted)
            line.set_extend(lon_h_ln, extend.none)
            line.set_x2(lon_h_ln,     bar_index)
            lon_h_ln := na
        if not na(lon_l_ln) and low <= lon_l
            line.set_style(lon_l_ln,  line.style_dotted)
            line.set_extend(lon_l_ln, extend.none)
            line.set_x2(lon_l_ln,     bar_index)
            lon_l_ln := na
prev_lon := inLon

// ── Session H/L – Asia ────────────────────────────────────────────────────────
var float asia_h     = na
var float asia_l     = na
var int   asia_h_bar = na
var int   asia_l_bar = na
var bool  prev_asia  = false
var line  asia_h_ln  = na
var line  asia_l_ln  = na

if isBelowHour and show_asia
    if inAsia and not prev_asia
        line.delete(asia_h_ln)
        line.delete(asia_l_ln)
        asia_h := high, asia_l := low
        asia_h_bar := bar_index, asia_l_bar := bar_index
        asia_h_ln := line.new(bar_index, high, bar_index + 500, high, color=COL_ASIA, width=1, extend=extend.right)
        asia_l_ln := line.new(bar_index, low,  bar_index + 500, low,  color=COL_ASIA, width=1, extend=extend.right)
    else if inAsia
        if high > asia_h
            asia_h := high
            asia_h_bar := bar_index
            line.set_x1(asia_h_ln, bar_index)
            line.set_y1(asia_h_ln, asia_h)
            line.set_y2(asia_h_ln, asia_h)
        if low < asia_l
            asia_l := low
            asia_l_bar := bar_index
            line.set_x1(asia_l_ln, bar_index)
            line.set_y1(asia_l_ln, asia_l)
            line.set_y2(asia_l_ln, asia_l)
    else
        if not na(asia_h_ln) and high >= asia_h
            line.set_style(asia_h_ln,  line.style_dotted)
            line.set_extend(asia_h_ln, extend.none)
            line.set_x2(asia_h_ln,     bar_index)
            asia_h_ln := na
        if not na(asia_l_ln) and low <= asia_l
            line.set_style(asia_l_ln,  line.style_dotted)
            line.set_extend(asia_l_ln, extend.none)
            line.set_x2(asia_l_ln,     bar_index)
            asia_l_ln := na
prev_asia := inAsia

// ── Session H/L – Pre Market ──────────────────────────────────────────────────
var float pre_h     = na
var float pre_l     = na
var int   pre_h_bar = na
var int   pre_l_bar = na
var bool  prev_pre  = false
var line  pre_h_ln  = na
var line  pre_l_ln  = na

if isBelowHour and show_pre
    if inPre and not prev_pre
        line.delete(pre_h_ln)
        line.delete(pre_l_ln)
        pre_h := high, pre_l := low
        pre_h_bar := bar_index, pre_l_bar := bar_index
        pre_h_ln := line.new(bar_index, high, bar_index + 500, high, color=COL_PRE, width=1, extend=extend.right)
        pre_l_ln := line.new(bar_index, low,  bar_index + 500, low,  color=COL_PRE, width=1, extend=extend.right)
    else if inPre
        if high > pre_h
            pre_h := high
            pre_h_bar := bar_index
            line.set_x1(pre_h_ln, bar_index)
            line.set_y1(pre_h_ln, pre_h)
            line.set_y2(pre_h_ln, pre_h)
        if low < pre_l
            pre_l := low
            pre_l_bar := bar_index
            line.set_x1(pre_l_ln, bar_index)
            line.set_y1(pre_l_ln, pre_l)
            line.set_y2(pre_l_ln, pre_l)
    else
        if not na(pre_h_ln) and high >= pre_h
            line.set_style(pre_h_ln,  line.style_dotted)
            line.set_extend(pre_h_ln, extend.none)
            line.set_x2(pre_h_ln,     bar_index)
            pre_h_ln := na
        if not na(pre_l_ln) and low <= pre_l
            line.set_style(pre_l_ln,  line.style_dotted)
            line.set_extend(pre_l_ln, extend.none)
            line.set_x2(pre_l_ln,     bar_index)
            pre_l_ln := na
prev_pre := inPre
````
