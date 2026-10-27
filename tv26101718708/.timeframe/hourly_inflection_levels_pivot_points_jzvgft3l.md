# Hourly Inflection Levels/ pivot points

- url: https://www.tradingview.com/script/JzVGft3l-Hourly-Inflection-Levels-pivot-points/
- type: indicator
- pine_id: PUB;e7f7ede5309447f192c3232df355a85a
- version: 3.0

## Description

This indicator finds the price levels where the hourly chart has repeatedly turned, and draws them as support/resistance zones — regardless of what timeframe your chart is on. It pulls 1-hour data via request.security, so the same zones appear whether you're viewing a 5-minute, 1-hour, or 4-hour chart.

How it works
1. Pivot detection. On the hourly series it locates two kinds of turning points:

Wick pivots — pivot highs/lows based on candle high/low (where price actually reached).
Body pivots — pivot highs/lows based on max(open, close) / min(open, close) (where price closed the swing).
2. Intensity filter. Each pivot is scored by how far price travelled inside its pivot window (the displacement between the pivot and the opposite extreme). Weak, shallow pivots are discarded via the Min Inflection Intensity threshold, so only meaningful inflections survive.

3. Cross-type merging into zones. Every qualified pivot — wick or body, high or low — is pooled together, sorted by price, and merged: any pivots within the Merge / Zone Tolerance of each other collapse into a single zone. The zone's boundaries become the highest and lowest merged price; each merge adds one to the zone's touch count, and the zone keeps the strongest intensity of its members.

4. Display. Zones that have been touched at least Min Touch Count times are drawn as boxes, optionally extended to the right, with a label showing the level's mid-price, touch count, and intensity %. Levels touched fewer times are hidden.

Inputs
Lookback Period — how many days of hourly history to scan (rolling window; old levels are pruned automatically).
Pivot Left/Right Bars — sensitivity of pivot detection.
Min Touch Count — how many pivots must fall in a zone for it to be shown.
Min Inflection Intensity — minimum swing strength for a pivot to count.
Merge / Zone Tolerance — how close pivots must be to merge into one zone.
Wick / Body toggles — choose which pivot types feed the zones.
Display — extend zones right, show labels, zone color, border width.
Reading the zones
A zone with a high touch count and high intensity marks a price area the market has reacted to strongly and repeatedly over the past month — prime candidates for support, resistance, and reaction levels.

Note: Zones are confluence levels built from past hourly pivots, not signals. They don't repaint historically (pivots are confirmed), but the active set updates as new hourly bars form and old ones age out of the lookback window.

## Source Code

````pine
//@version=6
indicator("Hourly Inflection Levels - 1 Month", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// === Inputs ===
lookbackDays    = input.int(30,   "Lookback Period (Days)", minval=1, maxval=90)
leftBars        = input.int(10,    "Pivot Left Bars",  minval=1)
rightBars       = input.int(10,    "Pivot Right Bars", minval=1)
minTouches      = input.int(1,    "Min Touch Count",  minval=1,
     tooltip="Number of pivots that must fall inside a zone. Each pivot counts as 1 touch.")

autoIntensity   = input.bool(true, "Auto Intensity via ATR%", group="Intensity",
     tooltip="Auto-sets the intensity threshold from the hourly ATR%: ATR%<3 → 3, ATR% 3–6 → 6, ATR%>6 → 10.")
minIntensityPct = input.float(3.0, "Min Inflection Intensity (%) — manual", minval=0.0, step=0.05, group="Intensity",
     tooltip="Used only when Auto Intensity is disabled. Displacement between the pivot and the opposite extreme inside its pivot window.")
minTolPct       = input.float(0.12, "Merge / Zone Tolerance (%)", minval=0.0, step=0.05,
     tooltip="Pivots within this distance of each other are merged into one zone.")

showWickPivots  = input.bool(true,  "Use Wick Pivots (High/Low)",  group="Wick Pivots")
showPHs         = input.bool(true,  "  Pivot Highs (Resistance)",   group="Wick Pivots")
showPLs         = input.bool(true,  "  Pivot Lows (Support)",       group="Wick Pivots")

showBodyPivots  = input.bool(true,  "Use Body Pivots (Open/Close)", group="Body Pivots")
showBodyPHs     = input.bool(true,  "  Body Pivot Highs",            group="Body Pivots")
showBodyPLs     = input.bool(true,  "  Body Pivot Lows",             group="Body Pivots")

extendRight     = input.bool(true, "Extend Zones to Right", group="Display")
showLabels      = input.bool(true, "Show Price Labels",     group="Display")
zoneColor       = input.color(color.new(#f450f4, 80), "Zone Fill Color", group="Display")
lineWidth       = input.int(1, "Border Width", minval=1, maxval=4, group="Display")

MS_HOUR = 60 * 60 * 1000
winLen  = leftBars + rightBars + 1

// === ATR%-based intensity threshold ===
[h1Close, h1ATR14] = request.security(syminfo.tickerid, "60",
     [close, ta.atr(14)], lookahead=barmerge.lookahead_off)

atrPct = not na(h1ATR14) and not na(h1Close) and h1Close != 0
     ? h1ATR14 / h1Close * 100
     : float(na)

// ATR% < 3 → 3 | ATR% 3–6 → 6 | ATR% > 6 → 10
atrThreshold(ap) =>
    ap > 6.0 ? 10.0 : ap >= 3.0 ? 6.0 : 3.0

effectiveIntensity = autoIntensity and not na(atrPct)
     ? atrThreshold(atrPct)
     : minIntensityPct

// === Helper functions ===
addLevel(prices, times, ints, p, t, ity) =>
    array.push(prices, p)
    array.push(times, t)
    array.push(ints, ity)

pruneRaw(prices, times, ints, cutoff) =>
    if array.size(prices) > 0
        k = 0
        while k < array.size(prices)
            if array.get(times, k) < cutoff
                array.remove(prices, k)
                array.remove(times, k)
                array.remove(ints, k)
            else
                k += 1

sortByPrice(prices, times, ints) =>
    n = array.size(prices)
    if n > 1
        for i = 1 to n - 1
            p = array.get(prices, i)
            t = array.get(times, i)
            v = array.get(ints, i)
            j = i - 1
            while j >= 0 and array.get(prices, j) > p
                array.set(prices, j + 1, array.get(prices, j))
                array.set(times,  j + 1, array.get(times, j))
                array.set(ints,   j + 1, array.get(ints, j))
                j -= 1
            array.set(prices, j + 1, p)
            array.set(times,  j + 1, t)
            array.set(ints,   j + 1, v)

clearLabels(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

clearBoxes(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
        array.clear(arr)

drawZone(zMin, zMax, cnt, ity, t, xEnd, minTch, col, showLbl, lw, boxes, labels) =>
    if cnt >= minTch
        bx = box.new(left=t, top=zMax, right=xEnd, bottom=zMin, xloc=xloc.bar_time,
             bgcolor=col, border_color=color.new(col, 30), border_width=lw)
        array.push(boxes, bx)
        if showLbl
            mid = (zMin + zMax) / 2
            txt = str.tostring(mid, format.mintick) + "  " + str.tostring(cnt) + "x  " + str.tostring(ity, "#.##") + "%"
            lb = label.new(x=xEnd, y=zMax, text=txt, xloc=xloc.bar_time, style=label.style_label_left,
                 color=color.new(col, 60), textcolor=color.white, size=size.small)
            array.push(labels, lb)

// === Hourly data (works on any chart TF) ===
[h1High, h1Low, h1Time] = request.security(syminfo.tickerid, "60", [high, low, time], lookahead=barmerge.lookahead_off)

// Wick pivots
ph = request.security(syminfo.tickerid, "60", ta.pivothigh(high, leftBars, rightBars), lookahead=barmerge.lookahead_off)
pl = request.security(syminfo.tickerid, "60", ta.pivotlow(low,  leftBars, rightBars), lookahead=barmerge.lookahead_off)
phWinLow  = request.security(syminfo.tickerid, "60",
     not na(ta.pivothigh(high, leftBars, rightBars)) ? ta.lowest(low, winLen) : float(na),
     lookahead=barmerge.lookahead_off)
plWinHigh = request.security(syminfo.tickerid, "60",
     not na(ta.pivotlow(low, leftBars, rightBars)) ? ta.highest(high, winLen) : float(na),
     lookahead=barmerge.lookahead_off)

// Body pivots
bph = request.security(syminfo.tickerid, "60",
     ta.pivothigh(math.max(open, close), leftBars, rightBars), lookahead=barmerge.lookahead_off)
bpl = request.security(syminfo.tickerid, "60",
     ta.pivotlow(math.min(open, close),  leftBars, rightBars), lookahead=barmerge.lookahead_off)
bphWinLow  = request.security(syminfo.tickerid, "60",
     not na(ta.pivothigh(math.max(open, close), leftBars, rightBars)) ? ta.lowest(math.min(open, close), winLen) : float(na),
     lookahead=barmerge.lookahead_off)
bplWinHigh = request.security(syminfo.tickerid, "60",
     not na(ta.pivotlow(math.min(open, close), leftBars, rightBars)) ? ta.highest(math.max(open, close), winLen) : float(na),
     lookahead=barmerge.lookahead_off)

pivotTime  = h1Time - rightBars * MS_HOUR
cutoffTime = timenow - lookbackDays * 24 * MS_HOUR

phIntensity  = not na(ph)  and not na(phWinLow)   ? (ph  - phWinLow)   / ph  * 100 : float(na)
plIntensity  = not na(pl)  and not na(plWinHigh)  ? (plWinHigh  - pl)  / pl  * 100 : float(na)
bphIntensity = not na(bph) and not na(bphWinLow)  ? (bph - bphWinLow)  / bph * 100 : float(na)
bplIntensity = not na(bpl) and not na(bplWinHigh) ? (bplWinHigh - bpl) / bpl * 100 : float(na)

// === Storage ===
var array<float> rawPrice  = array.new<float>()
var array<int>   rawTime   = array.new<int>()
var array<float> rawInt    = array.new<float>()

var array<box>   zoneBoxes  = array.new<box>()
var array<label> zoneLabels = array.new<label>()

// === On each new hourly bar: register qualified pivots ===
if ta.change(h1Time) != 0

    if showWickPivots and showPHs and not na(ph) and pivotTime >= cutoffTime and not na(phIntensity) and phIntensity >= effectiveIntensity
        addLevel(rawPrice, rawTime, rawInt, ph, int(pivotTime), phIntensity)
    if showWickPivots and showPLs and not na(pl) and pivotTime >= cutoffTime and not na(plIntensity) and plIntensity >= effectiveIntensity
        addLevel(rawPrice, rawTime, rawInt, pl, int(pivotTime), plIntensity)
    if showBodyPivots and showBodyPHs and not na(bph) and pivotTime >= cutoffTime and not na(bphIntensity) and bphIntensity >= effectiveIntensity
        addLevel(rawPrice, rawTime, rawInt, bph, int(pivotTime), bphIntensity)
    if showBodyPivots and showBodyPLs and not na(bpl) and pivotTime >= cutoffTime and not na(bplIntensity) and bplIntensity >= effectiveIntensity
        addLevel(rawPrice, rawTime, rawInt, bpl, int(pivotTime), bplIntensity)

    pruneRaw(rawPrice, rawTime, rawInt, cutoffTime)

// === Render on the last bar ===
if barstate.islast
    clearBoxes(zoneBoxes)
    clearLabels(zoneLabels)

    xEnd = extendRight ? timenow + MS_HOUR * 200 : timenow

    sortByPrice(rawPrice, rawTime, rawInt)
    n = array.size(rawPrice)
    if n > 0
        cMin  = array.get(rawPrice, 0)
        cMax  = array.get(rawPrice, 0)
        cCnt  = 1
        cInt  = array.get(rawInt, 0)
        cTime = array.get(rawTime, 0)
        i = 1
        while i <= n - 1
            v  = array.get(rawPrice, i)
            ti = array.get(rawTime, i)
            if cMax == 0 or (v - cMax) / cMax * 100 <= minTolPct
                cMax := v
                cCnt += 1
                cInt := math.max(cInt, array.get(rawInt, i))
                if ti < cTime
                    cTime := ti
            else
                drawZone(cMin, cMax, cCnt, cInt, cTime, xEnd, minTouches, zoneColor, showLabels, lineWidth, zoneBoxes, zoneLabels)
                cMin  := v
                cMax  := v
                cCnt  := 1
                cInt  := array.get(rawInt, i)
                cTime := ti
            i += 1
        drawZone(cMin, cMax, cCnt, cInt, cTime, xEnd, minTouches, zoneColor, showLabels, lineWidth, zoneBoxes, zoneLabels)
````
