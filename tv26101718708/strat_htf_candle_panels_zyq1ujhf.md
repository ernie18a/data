# Strat HTF Candle Panels

- url: https://www.tradingview.com/script/zYq1uJhf-Strat-HTF-Candle-Panels/
- type: indicator
- pine_id: PUB;eac998ad14914fddbf95d153c041b967
- version: 1.0

## Description

CRT is apart of my trading strategy , I created this indicator as sort of a higher time frame overlay. I just recently modified it to time travel and go back in time to show me what the selected timeframe was sorta looking like at a specific time, not as a directional bias but for a CRT bias (s/o to nitro trades on yt).


This indicator displays miniature candlestick "panels" for six timeframes at once, pinned to the right side of your chart (I recommend moving it to a new pane below), so you can scan multiple timeframes' recent price action without switching charts. Each panel shows the last several candles of its timeframe, classified using "Strat" candle typing (1, 2U, 2D, 3) with the type printed under each candle.

Key features:

Six configurable timeframe panels, arranged in two rows of three (defaults: 5m, 15m, 1H on top; 4H, Daily, Weekly on bottom), each fully customizable via the Timeframes group.

Strat candle classification — every candle is automatically labeled 1 (inside bar), 2U/2D (directional break), or 3 (outside bar), using the same logic as the Strat Research Matrix.

Time Travel mode — pick any past date and time, and every panel redraws to show what its candles looked like as of that exact moment, on that panel's own timeframe. Useful for reviewing how each timeframe's Strat pattern looked at a specific point in history. Includes an adjustable search range for timeframes that need to look further back to find your chosen date.

Hover tooltips — hovering near any candle reveals its exact date and time down to the minute, in your chart's timezone (its a bit hard to hover over the right spot on the candle to view this feature but if you hover over the candle it's a spot where the tooltip will pop up)

Date/time labels — each panel shows the date/time of its most recent visible candle along the bottom, so you always know what period you're looking at especially useful with Time Travel on (If it gives you any problems with lining up the exact time and date, the candles disappear or it times out adjust the search range *200* to a higher or lower number, sorry for the inconvenience).

Fully adjustable layout and style — candle width/spacing, panel size and vertical offset from price, panel height as a % of price, bull/bear colors, and toggles for titles, Strat number labels, date/time labels, and tooltips.

How it works: the script pulls each timeframe's OHLC and Strat classification via request.security, then draws the candles as scaled boxes/lines positioned to the right of the current bar — they're drawing objects, not real chart data, so they only render on the most recent bar and update live.

## Source Code

````pine
//@version=6
indicator("Strat HTF Candle Panels", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//──────────────────────────────────────
// Inputs
//──────────────────────────────────────
grp1 = "Timeframes"
tf1 = input.timeframe("5",   "Row 1 - Panel 1", group=grp1)
tf2 = input.timeframe("15",  "Row 1 - Panel 2", group=grp1)
tf3 = input.timeframe("60",  "Row 1 - Panel 3", group=grp1)
tf4 = input.timeframe("240", "Row 2 - Panel 1", group=grp1)
tf5 = input.timeframe("D",   "Row 2 - Panel 2", group=grp1)
tf6 = input.timeframe("W",   "Row 2 - Panel 3", group=grp1)

grp2 = "Layout"
numCandles   = input.int(5, "Candles per Panel", minval=1, maxval=5, group=grp2)
candleW      = input.int(2, "Candle Width (bars)", minval=1, group=grp2)
candleGap    = input.int(1, "Gap Between Candles (bars)", minval=0, group=grp2)
panelGap     = input.int(3, "Gap Between Panels (bars)", minval=0, group=grp2)
startOffset  = input.int(3, "Bars to Right of Last Bar", minval=1, group=grp2)
panelHtPct   = input.float(4.0, "Panel Height (% of price)", minval=0.5, group=grp2)
row1Off      = input.float(2.0, "Row 1 Offset Above Price (%)", minval=0, group=grp2)
row2Off      = input.float(2.0, "Row 2 Offset Below Price (%)", minval=0, group=grp2)

grp3 = "Style"
upColor      = input.color(color.black, "Bull Body", group=grp3)
dnColor      = input.color(color.red,   "Bear Body", group=grp3)
showLabels   = input.bool(true, "Show Strat Numbers", group=grp3)
showTitles   = input.bool(true, "Show Panel Titles", group=grp3)
showDateTime = input.bool(true, "Show Date/Time Labels", group=grp3)
showTooltips = input.bool(true, "Show Hover Tooltips (Exact Candle Time)", group=grp3)

// ──────────────────────────────────────
// Time Travel (view panels as of a chosen date/time)
// ──────────────────────────────────────
grp4 = "Time Travel"
useReplay   = input.bool(false, "Enable Time Travel (View As Of Date/Time)", group=grp4)
targetTime  = input.time(timestamp("2024-01-01 00:00 +0000"), "Go To Date/Time", group=grp4)
searchRange = input.int(200, "Search Range (bars per timeframe)", minval=10, maxval=2000, group=grp4, tooltip="How far back (in bars of that timeframe) to search for your chosen date/time. Increase if your target date isn't being found on higher timeframes.")

//──────────────────────────────────────
// Strat classification (identical to Strat Research Matrix) + color
//──────────────────────────────────────
f_type() =>
    string t = ""
    if high > high[1] and low < low[1]
        t := "3"
    else if high <= high[1] and low >= low[1]
        t := "1"
    else if high > high[1]
        t := close > high[1] ? "2CU" : "2FU"
    else if low < low[1]
        t := close < low[1] ? "2CD" : "2FD"
    else
        t := "-"
    t

f_color(t) =>
    switch t
        "1"   => color.black
        "2CU" => color.black
        "2FU" => color.black
        "2CD" => color.black
        "2FD" => color.black
        "3"   => color.black
        =>       color.black

//──────────────────────────────────────
// Finds how many bars back (within THIS timeframe's own context) the
// chosen date/time sits. Must be called from inside a request.security
// expression for the timeframe in question, since it reads that TF's `time`.
// Returns 0 (i.e. "the current/latest bar") when Time Travel is off.
//──────────────────────────────────────
f_findOffset(int searchRange, int targetTime) =>
    int off = 0
    if not na(targetTime)
        for i = 0 to searchRange - 1
            if not na(time[i]) and time[i] <= targetTime
                off := i
                break
    off

//──────────────────────────────────────
// Fetch OHLC shape (6 offsets, one bundled call per TF)
// Now also returns each candle's own bar-open timestamp (`time[off+k]`)
// so we can show an exact hover tooltip per candle, not just per panel.
//──────────────────────────────────────
f_ohlc(int off) =>
    [open[off],   high[off],   low[off],   close[off],   time[off],
     open[off+1], high[off+1], low[off+1], close[off+1], time[off+1],
     open[off+2], high[off+2], low[off+2], close[off+2], time[off+2],
     open[off+3], high[off+3], low[off+3], close[off+3], time[off+3],
     open[off+4], high[off+4], low[off+4], close[off+4], time[off+4],
     open[off+5], high[off+5], low[off+5], close[off+5], time[off+5]]

f_getOHLC(tf, bool replay, int tTime, int rng) =>
    [o0,h0,l0,c0,tm0, o1,h1,l1,c1,tm1, o2,h2,l2,c2,tm2, o3,h3,l3,c3,tm3, o4,h4,l4,c4,tm4, o5,h5,l5,c5,tm5] =
         request.security(syminfo.tickerid, tf, f_ohlc(replay ? f_findOffset(rng, tTime) : 0), lookahead=barmerge.lookahead_off)
    oA  = array.from(o0,o1,o2,o3,o4,o5)
    hA  = array.from(h0,h1,h2,h3,h4,h5)
    lA  = array.from(l0,l1,l2,l3,l4,l5)
    cA  = array.from(c0,c1,c2,c3,c4,c5)
    tmA = array.from(tm0,tm1,tm2,tm3,tm4,tm5)
    [oA, hA, lA, cA, tmA]

//──────────────────────────────────────
// Fetch Strat type — IDENTICAL call pattern to Strat Research Matrix:
// one dedicated request.security call per offset, kept separate from
// the shape fetch above so nothing gets bundled/misaligned.
// Each call applies the same computed Time Travel offset.
//──────────────────────────────────────
f_getTypes(tf, bool replay, int tTime, int rng) =>
    t0 = request.security(syminfo.tickerid, tf, f_type()[(replay ? f_findOffset(rng, tTime) : 0)],       lookahead=barmerge.lookahead_off)
    t1 = request.security(syminfo.tickerid, tf, f_type()[(replay ? f_findOffset(rng, tTime) : 0) + 1],   lookahead=barmerge.lookahead_off)
    t2 = request.security(syminfo.tickerid, tf, f_type()[(replay ? f_findOffset(rng, tTime) : 0) + 2],   lookahead=barmerge.lookahead_off)
    t3 = request.security(syminfo.tickerid, tf, f_type()[(replay ? f_findOffset(rng, tTime) : 0) + 3],   lookahead=barmerge.lookahead_off)
    t4 = request.security(syminfo.tickerid, tf, f_type()[(replay ? f_findOffset(rng, tTime) : 0) + 4],   lookahead=barmerge.lookahead_off)
    array.from(t0,t1,t2,t3,t4)

f_get(tf, bool replay, int tTime, int rng) =>
    [oA, hA, lA, cA, tmA] = f_getOHLC(tf, replay, tTime, rng)
    tA = f_getTypes(tf, replay, tTime, rng)
    [oA, hA, lA, cA, tA, tmA]

[o1a,h1a,l1a,c1a,t1a,tm1a] = f_get(tf1, useReplay, targetTime, searchRange)
[o2a,h2a,l2a,c2a,t2a,tm2a] = f_get(tf2, useReplay, targetTime, searchRange)
[o3a,h3a,l3a,c3a,t3a,tm3a] = f_get(tf3, useReplay, targetTime, searchRange)
[o4a,h4a,l4a,c4a,t4a,tm4a] = f_get(tf4, useReplay, targetTime, searchRange)
[o5a,h5a,l5a,c5a,t5a,tm5a] = f_get(tf5, useReplay, targetTime, searchRange)
[o6a,h6a,l6a,c6a,t6a,tm6a] = f_get(tf6, useReplay, targetTime, searchRange)

//──────────────────────────────────────
// Drawing object storage (cleared/redrawn each realtime tick)
//──────────────────────────────────────
var line[]  allLines  = array.new<line>()
var box[]   allBoxes  = array.new<box>()
var label[] allLabels = array.new<label>()

f_clearAll() =>
    for ln in allLines
        line.delete(ln)
    for bx in allBoxes
        box.delete(bx)
    for lb in allLabels
        label.delete(lb)
    array.clear(allLines)
    array.clear(allBoxes)
    array.clear(allLabels)

panelWidth = numCandles*candleW + (numCandles-1)*candleGap

f_drawPanel(nm, row, col, array<float> o, array<float> h, array<float> l, array<float> c, array<string> t, array<int> tm) =>
    n = numCandles
    float mn = 1e10
    float mx = -1e10
    for k = 0 to n-1
        lv = array.get(l, k)
        hv = array.get(h, k)
        if not na(lv)
            mn := math.min(mn, lv)
        if not na(hv)
            mx := math.max(mx, hv)

    if not na(mn) and not na(mx) and mn < 1e10 and mx > -1e10
        height = close * panelHtPct / 100
        base = row == 0 ? close * (1 + row1Off/100) : close * (1 - row2Off/100 - panelHtPct/100)
        rng = (mx - mn) == 0 ? syminfo.mintick : (mx - mn)
        colStart = startOffset + col * (panelWidth + panelGap)

        if showTitles
            titleLbl = label.new(bar_index + colStart + math.round(panelWidth/2.0), base + height*1.2, nm,
                 style=label.style_label_down, color=color.new(color.black,100), textcolor=color.black, size=size.normal)
            array.push(allLabels, titleLbl)

        for k = 0 to n-1
            offset = n-1-k
            op = array.get(o, offset)
            hi = array.get(h, offset)
            lo = array.get(l, offset)
            cl = array.get(c, offset)
            typ = array.get(t, offset)
            tCandle = array.get(tm, offset)

            // Skip drawing a candle if Time Travel pushed us past the
            // available history for this timeframe (avoids na errors)
            if not na(op) and not na(hi) and not na(lo) and not na(cl)
                xL = bar_index + colStart + k*(candleW+candleGap)
                xR = xL + candleW
                xC = math.round((xL+xR)/2.0)

                yHi = base + (hi-mn)/rng*height
                yLo = base + (lo-mn)/rng*height
                yOp = base + (op-mn)/rng*height
                yCl = base + (cl-mn)/rng*height

                bodyColor = cl >= op ? upColor : dnColor

                wick = line.new(xC, yLo, xC, yHi, xloc.bar_index, extend.none, bodyColor, width=1)
                array.push(allLines, wick)

                body = box.new(xL, math.max(yOp,yCl), xR, math.min(yOp,yCl), border_color=bodyColor, bgcolor=bodyColor, border_width=1)
                array.push(allBoxes, body)

                if showLabels
                    numLbl = label.new(xC, base - height*0.15, typ, style=label.style_label_down,
                         color=color.new(color.black,100), textcolor=f_color(typ), size=size.normal)
                    array.push(allLabels, numLbl)

                // NEW: separate, invisible label positioned over the middle of
                // the candle itself, purely to carry the hover tooltip (exact
                // date/time to the minute). Only label.new supports tooltips
                // in Pine v6 — line.new/box.new do not — so this is a dedicated
                // invisible hover target rather than being attached to the
                // strat-number label.
                if showTooltips and not na(tCandle)
                    tipTxt = str.format_time(tCandle, "yyyy-MM-dd HH:mm", syminfo.timezone)
                    hoverLbl = label.new(xC, (yHi+yLo)/2, "", style=label.style_label_down,
                         color=color.new(color.black,100), textcolor=color.new(color.black,100), size=size.normal, tooltip=tipTxt)
                    array.push(allLabels, hoverLbl)

        // Date/time of the panel's most recent (rightmost) candle, shown
        // along the bottom of the panel.
        panelTime = array.get(tm, 0)
        if showDateTime and not na(panelTime)
            dtLbl = label.new(bar_index + colStart + math.round(panelWidth/2.0), base - height*0.4, str.format_time(panelTime, "yyyy-MM-dd HH:mm", syminfo.timezone),
                 style=label.style_label_down, color=color.new(color.black,100), textcolor=color.gray, size=size.small)
            array.push(allLabels, dtLbl)

//──────────────────────────────────────
// Render (last bar only)
//──────────────────────────────────────
if barstate.islast
    f_clearAll()
    f_drawPanel(str.tostring(tf1), 1, 0, o1a, h1a, l1a, c1a, t1a, tm1a)
    f_drawPanel(str.tostring(tf2), 1, 1, o2a, h2a, l2a, c2a, t2a, tm2a)
    f_drawPanel(str.tostring(tf3), 1, 2, o3a, h3a, l3a, c3a, t3a, tm3a)
    f_drawPanel(str.tostring(tf4), 0, 0, o4a, h4a, l4a, c4a, t4a, tm4a)
    f_drawPanel(str.tostring(tf5), 0, 1, o5a, h5a, l5a, c5a, t5a, tm5a)
    f_drawPanel(str.tostring(tf6), 0, 2, o6a, h6a, l6a, c6a, t6a, tm6a)
````
