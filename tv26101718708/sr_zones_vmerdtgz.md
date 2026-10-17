# SR Zones

- url: https://www.tradingview.com/script/vMERdTGZ-SR-Zones/
- type: indicator
- pine_id: PUB;46b23361627d4e79b835046da9fb234d
- version: 1.0

## Description

SR zones published for the bullpen only for bullpen members accessing lives.

## Source Code

````pine
//@version=6
indicator("SR Zones", overlay=true, max_lines_count=500, max_boxes_count=500)

// ─── Inputs ───────────────────────────────────────────────────────────────────
swingLen   = input.int(40,    "Pivot Strength",        minval=5,   maxval=100)
lookback   = input.int(2000,  "Lookback Bars",         minval=100, maxval=5000)
minTouches = input.int(3,     "Min Touches",           minval=2,   maxval=15)
tolerance  = input.float(0.50,"Zone Tolerance",        minval=0.05,maxval=5.0,  step=0.05)
proxPct    = input.float(5.0, "Price Proximity %",     minval=1.0, maxval=50.0, step=0.5)
extRight   = input.int(100,   "Extend Right",          minval=0,   maxval=500)
showLabels = input.bool(true, "Show Labels")
freshBars  = input.int(150,   "Fresh Zone (bars)",     minval=10,  maxval=1000)
brokenLB   = input.int(20,    "Broken Level Lookback", minval=5,   maxval=100)

sup3      = input.color(color.new(color.teal,   55), "Support 3-4T",    group="Colors")
sup5      = input.color(color.new(color.green,  35), "Support 5+T",     group="Colors")
res3      = input.color(color.new(color.orange, 55), "Resistance 3-4T", group="Colors")
res5      = input.color(color.new(color.red,    35), "Resistance 5+T",  group="Colors")
brokenCol = input.color(color.new(color.purple, 50), "Broken Level",    group="Colors")

showRound = input.bool(true,  "Show Round Numbers",    group="Round Numbers")
roundStep = input.float(5.0,  "Round Number Interval", group="Round Numbers", minval=0.5, maxval=100.0, step=0.5)
roundCol  = input.color(color.new(color.white, 75),   "Round Number Color",  group="Round Numbers")

showOR = input.bool(true, "Show Opening Range",  group="Opening Range")
orLen  = input.int(15,    "Opening Range (min)", group="Opening Range", options=[5, 15, 30])
orCol  = input.color(color.new(color.white, 30), "Opening Range Color", group="Opening Range")

showTodayHL = input.bool(true, "Show Today High/Low",  group="Intraday")
todayHLCol  = input.color(color.new(color.silver, 30), "Today H/L Color", group="Intraday")

// ─── Helpers ──────────────────────────────────────────────────────────────────
getColor(t, isSupp) =>
    isSupp ? (t >= 5 ? sup5 : sup3) : (t >= 5 ? res5 : res3)

getWidth(t) =>
    t >= 7 ? 3 : t >= 5 ? 2 : 1

getAlpha(t) =>
    t >= 5 ? 65 : t >= 3 ? 78 : 88

// ─── Session tracking (must come before wick collection) ──────────────────────
var int sessionOpenBar = 0
var int sessionOpenDy  = -1

if session.ismarket and dayofmonth != sessionOpenDy
    sessionOpenBar := bar_index
    sessionOpenDy  := dayofmonth

// ─── S/R pivot collection ─────────────────────────────────────────────────────
var float[] pPrices = array.new_float()
var int[]   pBars   = array.new_int()
var float[] pWicks  = array.new_float()

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

if bar_index >= last_bar_index - lookback
    if not na(ph)
        rng  = high[swingLen] - low[swingLen]
        wick = rng > 0 ? (high[swingLen] - math.max(open[swingLen], close[swingLen])) / rng : 0.0
        array.push(pPrices, ph)
        array.push(pBars,   bar_index - swingLen)
        array.push(pWicks,  wick)
    if not na(pl)
        rng  = high[swingLen] - low[swingLen]
        wick = rng > 0 ? (math.min(open[swingLen], close[swingLen]) - low[swingLen]) / rng : 0.0
        array.push(pPrices, pl)
        array.push(pBars,   bar_index - swingLen)
        array.push(pWicks,  wick)

// ─── Today's high/low ─────────────────────────────────────────────────────────
var float todayH  = na
var float todayL  = na
var int   todayDy = -1

if session.ismarket
    if dayofmonth != todayDy
        todayH  := high
        todayL  := low
        todayDy := dayofmonth
    else
        todayH := math.max(todayH, high)
        todayL := math.min(todayL, low)

// ─── Opening range ────────────────────────────────────────────────────────────
var float orH  = na
var float orL  = na
var int   orDy = -1

sessionMin = 9 * 60 + 30
curMin     = hour * 60 + minute
isInOR     = session.ismarket and curMin >= sessionMin and curMin < sessionMin + orLen

if session.ismarket
    if dayofmonth != orDy
        orH  := na
        orL  := na
        orDy := dayofmonth
    if isInOR
        orH := na(orH) ? high : math.max(orH, high)
        orL := na(orL) ? low  : math.min(orL, low)

// ─── Alerts ───────────────────────────────────────────────────────────────────
var float lastPH_alert = na
var float lastPL_alert = na

if not na(ph)
    lastPH_alert := ph
if not na(pl)
    lastPL_alert := pl

alertcondition(not na(ph), "New Resistance Pivot", "New pivot high formed — potential resistance zone developing")
alertcondition(not na(pl), "New Support Pivot",    "New pivot low formed — potential support zone developing")
alertcondition(not na(lastPH_alert) and ta.crossunder(close, lastPH_alert), "Price Into Resistance", "Price crossed into a recent resistance pivot")
alertcondition(not na(lastPL_alert) and ta.crossover(close,  lastPL_alert), "Price Into Support",    "Price crossed into a recent support pivot")

// ─── Draw on last bar ─────────────────────────────────────────────────────────
if barstate.islast
    curPrice = close
    proxHigh = curPrice * (1.0 + proxPct / 100.0)
    proxLow  = curPrice * (1.0 - proxPct / 100.0)
    x2       = last_bar_index + extRight

    if showRound
        firstRound = math.ceil(proxLow / roundStep) * roundStep
        maxIter    = int(math.ceil((proxHigh - proxLow) / roundStep)) + 2
        for ri = 0 to maxIter
            rnPrice = firstRound + ri * roundStep
            if rnPrice > proxHigh
                break
            line.new(last_bar_index - 3, rnPrice, x2, rnPrice, color=roundCol, style=line.style_dotted, width=1)

    if showOR and not na(orH)
        box.new(sessionOpenBar, orH, x2, orL, bgcolor=color.new(orCol, 92), border_color=orCol, border_width=1)
        if showLabels
            tbl = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 55), border_color=color.new(color.gray, 70), border_width=1)
            table.cell(tbl, 0, 0, "ORH", text_color=orCol, text_size=size.tiny)
            table.cell(tbl, 1, 0, str.tostring(math.round(orH, 2)), text_color=orCol, text_size=size.tiny)
            table.cell(tbl, 0, 1, "ORL", text_color=orCol, text_size=size.tiny)
            table.cell(tbl, 1, 1, str.tostring(math.round(orL, 2)), text_color=orCol, text_size=size.tiny)

    if showTodayHL and not na(todayH)
        line.new(sessionOpenBar, todayH, x2, todayH, color=todayHLCol, width=1, style=line.style_solid)
        line.new(sessionOpenBar, todayL, x2, todayL, color=todayHLCol, width=1, style=line.style_solid)
        if showLabels
            label.new(x2, todayH, "HOD", xloc=xloc.bar_index, color=color.new(todayHLCol, 85), textcolor=todayHLCol, style=label.style_label_left, size=size.tiny)
            label.new(x2, todayL, "LOD", xloc=xloc.bar_index, color=color.new(todayHLCol, 85), textcolor=todayHLCol, style=label.style_label_left, size=size.tiny)

    if array.size(pPrices) > 0
        int   n        = array.size(pPrices)
        int[] idx      = array.sort_indices(pPrices, order.ascending)
        float cLow     = array.get(pPrices, array.get(idx, 0))
        float cHigh    = cLow
        int   touches  = 1
        int   firstBar = array.get(pBars, array.get(idx, 0))
        int   lastBar  = firstBar
        float wickSum  = array.get(pWicks, array.get(idx, 0))

        for i = 1 to n
            float p    = i < n ? array.get(pPrices, array.get(idx, i)) : na
            int   pBar = i < n ? array.get(pBars,   array.get(idx, i)) : 0
            float pW   = i < n ? array.get(pWicks,  array.get(idx, i)) : 0.0
            bool  flush = na(p) or p - cLow > tolerance

            if flush
                float mid = (cHigh + cLow) / 2.0
                if touches >= minTouches and mid >= proxLow and mid <= proxHigh
                    bool isSupp    = mid < curPrice
                    broken         = false
                    bodyBreaks     = 0
                    for k = 1 to brokenLB
                        if isSupp     and close[k] < cLow  and open[k] < cLow
                            bodyBreaks += 1
                        if not isSupp and close[k] > cHigh and open[k] > cHigh
                            bodyBreaks += 1
                    if bodyBreaks >= 1
                        broken := true

                    barsSince  = last_bar_index - lastBar
                    freshLabel = barsSince < freshBars / 3 ? "HOT"   :
                                 barsSince < freshBars     ? "FRESH" :
                                 barsSince < freshBars * 2 ? "AGING" : ""

                    avgWick   = wickSum / touches
                    strongRej = avgWick > 0.35
                    nearRound = showRound and math.abs(mid - math.round(mid / roundStep) * roundStep) < tolerance
                    nearOR    = showOR and not na(orH) and mid >= orL and mid <= orH
                    confCount = (nearRound ? 1 : 0) + (nearOR ? 1 : 0) + (strongRej ? 1 : 0)

                    c   = broken ? brokenCol : getColor(touches, isSupp)
                    w   = broken ? 1 : math.min(getWidth(touches) + (confCount >= 2 ? 1 : 0), 4)
                    alp = broken ? 60 : math.max(getAlpha(touches) - confCount * 5, 20)
                    x1  = math.max(0, firstBar)

                    tag = str.tostring(math.round(mid, 2)) + "  " + str.tostring(touches) + "T"
                    tag := freshLabel != "" ? tag + "  " + freshLabel : tag
                    tag := nearRound        ? tag + "  [RN]"          : tag
                    tag := nearOR           ? tag + "  [OR]"          : tag
                    tag := strongRej        ? tag + "  [REJ]"         : tag
                    tag := broken           ? tag + "  BROKEN"        : tag

                    if cHigh - cLow >= 0.01
                        box.new(x1, cHigh, x2, cLow, bgcolor=color.new(c, alp), border_color=c, border_width=w)
                    else
                        line.new(x1, cLow, x2, cLow, color=c, width=w)
                    if showLabels
                        label.new(x2, mid, tag, xloc=xloc.bar_index, color=color.new(c, 85), textcolor=c, style=label.style_label_left, size=size.small)

                if not na(p)
                    cLow     := p
                    cHigh    := p
                    touches  := 1
                    firstBar := pBar
                    lastBar  := pBar
                    wickSum  := pW
            else
                cHigh    := p
                touches  += 1
                firstBar := math.min(firstBar, pBar)
                lastBar  := math.max(lastBar, pBar)
                wickSum  += pW
````
