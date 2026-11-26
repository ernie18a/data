# TACT 3-Candle Buy/Sell Pattern with MTF Signal Box BY OMOSEDE

- url: https://www.tradingview.com/script/ImlT8hp2-TACT-3-Candle-Buy-Sell-Pattern-with-MTF-Signal-Box-BY-OMOSEDE/
- type: indicator
- pine_id: PUB;2d59d98175d54efc9b33964a49c0eccb
- version: 2.0

## Description

this is a pattern that occurs every time mostly on one minute timeframe.

## Source Code

````pine
//@version=5
indicator("HTF Levels + Trendlines (D/W/M) – Stable No-NA", overlay=true, max_lines_count=500, max_labels_count=500)

//──────────────────── Inputs ────────────────────
group_tf   = "Timeframe Toggles"
showDaily   = input.bool(true,  "Show Daily",   group=group_tf)
showWeekly  = input.bool(true,  "Show Weekly",  group=group_tf)
showMonthly = input.bool(true,  "Show Monthly", group=group_tf)

group_type = "Line Types"
showLevels = input.bool(true, "Horizontal Levels (O/H/L/C)", group=group_type)
showTrends = input.bool(true, "Sloped Trendlines (High/Low)", group=group_type)

// Colors
colD = color.new(color.teal,   0)
colW = color.new(color.orange, 0)
colM = color.new(color.purple, 0)

//──────────────────── HTF data (previous completed candle) ────────────────────
getHTF(tf) =>
    o = request.security(syminfo.tickerid, tf, open[1])
    h = request.security(syminfo.tickerid, tf, high[1])
    l = request.security(syminfo.tickerid, tf, low[1])
    c = request.security(syminfo.tickerid, tf, close[1])
    t = request.security(syminfo.tickerid, tf, time)
    [o, h, l, c, t]

[dO, dH, dL, dC, dT] = getHTF("D")
[wO, wH, wL, wC, wT] = getHTF("W")
[mO, mH, mL, mC, mT] = getHTF("M")

newD = ta.change(dT)
newW = ta.change(wT)
newM = ta.change(mT)

//──────────────────── Horizontal levels ────────────────────
makeLevel(price, col, txt) =>
    line.new(bar_index - 1, price, bar_index, price, extend=extend.right, color=col, width=1)
    label.new(bar_index, price, txt, style=label.style_label_left, textcolor=color.white, color=color.new(col, 70))

if showLevels
    if showDaily and newD
        makeLevel(dO, colD, "D Open")
        makeLevel(dH, colD, "D High")
        makeLevel(dL, colD, "D Low")
        makeLevel(dC, colD, "D Close")

    if showWeekly and newW
        makeLevel(wO, colW, "W Open")
        makeLevel(wH, colW, "W High")
        makeLevel(wL, colW, "W Low")
        makeLevel(wC, colW, "W Close")

    if showMonthly and newM
        makeLevel(mO, colM, "M Open")
        makeLevel(mH, colM, "M High")
        makeLevel(mL, colM, "M Low")
        makeLevel(mC, colM, "M Close")

//──────────────────── Trendline state (no NA) ────────────────────
var float dH1 = 0.0, dH2 = 0.0, dL1 = 0.0, dL2 = 0.0
var int   dB1 = 0,   dB2 = 0,   dBL1 = 0,  dBL2 = 0

var float wH1 = 0.0, wH2 = 0.0, wL1 = 0.0, wL2 = 0.0
var int   wB1 = 0,   wB2 = 0,   wBL1 = 0,  wBL2 = 0

var float mH1 = 0.0, mH2 = 0.0, mL1 = 0.0, mL2 = 0.0
var int   mB1 = 0,   mB2 = 0,   mBL1 = 0,  mBL2 = 0

barIndexForTime(t) =>
    ta.valuewhen(time == t, bar_index, 0)

// update daily
if newD
    dH2 := dH1
    dB2 := dB1
    dH1 := dH
    dB1 := barIndexForTime(dT)

    dL2 := dL1
    dBL2 := dBL1
    dL1 := dL
    dBL1 := barIndexForTime(dT)

// update weekly
if newW
    wH2 := wH1
    wB2 := wB1
    wH1 := wH
    wB1 := barIndexForTime(wT)

    wL2 := wL1
    wBL2 := wBL1
    wL1 := wL
    wBL1 := barIndexForTime(wT)

// update monthly
if newM
    mH2 := mH1
    mB2 := mB1
    mH1 := mH
    mB1 := barIndexForTime(mT)

    mL2 := mL1
    mBL2 := mBL1
    mL1 := mL
    mBL1 := barIndexForTime(mT)

//──────────────────── Trendlines draw ────────────────────
makeTrend(x1, y1, x2, y2, col, txt) =>
    line.new(x1, y1, x2, y2, extend=extend.right, color=col, width=2)
    label.new(x2, y2, txt, style=label.style_label_left, textcolor=color.white, color=color.new(col, 60))

if showTrends
    // daily
    if showDaily
        if dH1 != 0.0 and dH2 != 0.0
            makeTrend(dB2, dH2, dB1, dH1, colD, "D High TL")
        if dL1 != 0.0 and dL2 != 0.0
            makeTrend(dBL2, dL2, dBL1, dL1, colD, "D Low TL")

    // weekly
    if showWeekly
        if wH1 != 0.0 and wH2 != 0.0
            makeTrend(wB2, wH2, wB1, wH1, colW, "W High TL")
        if wL1 != 0.0 and wL2 != 0.0
            makeTrend(wBL2, wL2, wBL1, wL1, colW, "W Low TL")

    // monthly
    if showMonthly
        if mH1 != 0.0 and mH2 != 0.0
            makeTrend(mB2, mH2, mB1, mH1, colM, "M High TL")
        if mL1 != 0.0 and mL2 != 0.0
            makeTrend(mBL2, mL2, mBL1, mL1, colM, "M Low TL")

//──────────────────── Alerts: levels ────────────────────
tol = syminfo.mintick * 1.5

touch(p) =>
    math.abs(close - p) <= tol

dTouch = showDaily   and (touch(dO) or touch(dH) or touch(dL) or touch(dC))
wTouch = showWeekly  and (touch(wO) or touch(wH) or touch(wL) or touch(wC))
mTouch = showMonthly and (touch(mO) or touch(mH) or touch(mL) or touch(mC))

alertcondition(dTouch, "Daily Level Touched",   "Price touched a Daily O/H/L/C level")
alertcondition(wTouch, "Weekly Level Touched",  "Price touched a Weekly O/H/L/C level")
alertcondition(mTouch, "Monthly Level Touched", "Price touched a Monthly O/H/L/C level")
````
