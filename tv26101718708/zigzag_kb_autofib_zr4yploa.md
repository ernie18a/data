# ZigZag KB AutoFib

- url: https://www.tradingview.com/script/Zr4YPloA-ZigZag-KB-AutoFib/
- type: indicator
- pine_id: PUB;d7ed1e9b4f524ac9be5f149b7d9558ae
- version: 1.0

## Description

Auto fibonacci using the logic from zig zag movements and auto plotting it to find more accurate fibonacci trade setups

## Source Code

````pine
//@version=6
indicator("ZigZag KB AutoFib", "ZZ KB AFib", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================================
// ZigZag KB AutoFib — v2.0 (fresh build)
// ============================================================================
//
// PURPOSE
//   Automate KB's custom Fibonacci Golden Pocket strategy on NSE daily charts.
//
// DETECTION
//   Uses TradingView's official ZigZag library with FIXED-PERCENTAGE price
//   deviation (default 35%). A new swing pivot confirms only when price moves
//   ≥ deviation% from the previous pivot. Simple, predictable, stable.
//
// SETUPS SHOWN
//   • RECENT — the most recent confirmed A→B down-swing.        (full color)
//   • LARGEST — the biggest A→B down-swing in the visible range. (dimmed gray)
//   If RECENT and LARGEST are the same swing, only one box is drawn.
//
// STRATEGY MATH (B = swing low, A = swing high)
//   Entry Zone  =  [ B + 0.32   × (A−B) ,  B + 0.382 × (A−B) ]
//   TP Zone     =  [ B + 0.618  × (A−B) ,  B + 0.68  × (A−B) ]
//
// TRADE RULES
//   Entry  ▲   close > entryZoneHigh AND close > EMA9 AND close > EMA21
//   TP     ▼   high ≥ tpZoneLow
//   SL     ✕   close < EMA9 AND close < EMA21  (while in trade)
//
// LIFECYCLE
//   A setup is archived to history (dim gray) when:
//     (a) price reaches its TP zone (played out), OR
//     (b) a newer B forms (superseded by a fresher swing)
//   If price is already past TP when first detected → start dimmed.
//
// PARKED (NOT IN THIS VERSION)
//   × Reverse fib (B→A retracement levels)
//   × Drag-and-drop override
//   × Nested A1/A2/A3
//   × Manual A/B input
// ============================================================================

import TradingView/ZigZag/7 as zigzag

// =============== INPUTS ===============

grpDetection = "Pivot Detection"
pricePctDeviation = input.float(5.0, "Price Deviation (%)", minval=0.1, maxval=80.0, step=0.5,
     group=grpDetection,
     tooltip="A new swing pivot confirms only when price moves at least this % from the previous pivot. Lower = more swings detected. Higher = only the biggest moves. ZigZag library's typical range is 3-10%. Tune by toggling debug ZigZag line on and matching what you see with the standard ZigZag indicator.")
zigDepth = input.int(10, "Min Bars Between Pivots", minval=2, maxval=50,
     group=grpDetection,
     tooltip="Minimum bar separation between pivots. Default 10 = same as TradingView's Auto Fib.")

grpFib = "Fibonacci Levels (KB strategy)"
entryLo = input.float(0.32,  "Entry Zone — Low",       minval=0.1, maxval=0.5,  step=0.01, group=grpFib)
entryHi = input.float(0.382, "Entry Zone — High",      minval=0.1, maxval=0.5,  step=0.01, group=grpFib)
tpLo    = input.float(0.618, "TP Zone — Low",          minval=0.5, maxval=0.95, step=0.01, group=grpFib)
tpHi    = input.float(0.68,  "TP Zone — High",         minval=0.5, maxval=0.95, step=0.01, group=grpFib)

grpEMA = "Moving Averages"
showEMAs = input.bool(true, "Show EMA 9 / EMA 21", group=grpEMA)

grpFilter = "Entry Filters"
useEmaFilter = input.bool(true, "Require Close > EMA 9 AND EMA 21", group=grpFilter)
useVolFilter = input.bool(false, "Require Volume > 1.2× 20-bar Avg", group=grpFilter)

grpLargest = "Largest Swing Display"
showLargest = input.bool(true, "Show Largest Swing (dimmed)", group=grpLargest,
     tooltip="Show the largest A→B down-swing in the chart as a dimmed gray reference, behind the active recent setup.")

grpHistory = "History"
showHistory = input.bool(true, "Show Past Setups (dimmed)", group=grpHistory)
maxHistory  = input.int(5, "Max Past Setups", minval=0, maxval=20, group=grpHistory)

grpStyle = "Display"
zoneTransp     = input.int(75, "Active Zone Transparency", minval=0, maxval=100, group=grpStyle)
histTransp     = input.int(92, "Dimmed (History/Largest) Transparency", minval=70, maxval=100, group=grpStyle)
extendBars     = input.int(30, "Extend Zones Right (bars)", minval=5, maxval=200, group=grpStyle)
showInfoTable  = input.bool(true, "Show Info Table", group=grpStyle)
showABLabels   = input.bool(true, "Show A / B Labels", group=grpStyle)
showZigZagDbg  = input.bool(true, "Show ZigZag Line (debug)", group=grpStyle,
     tooltip="Yellow dashed lines showing every pivot the algorithm detects. Turn off once tuned. If you see lines but Status says 'Waiting for valid swing' — it means the latest swing is UP, not DOWN.")

// =============== ZIGZAG ENGINE ===============
// Fixed-percentage threshold (NOT ATR-adaptive). Predictable across stocks.
var settings = zigzag.Settings.new(pricePctDeviation, zigDepth, color(na), false, false, false, false, "Absolute", true)
var zigzag.ZigZag zigZag = zigzag.newInstance(settings)
settings.devThreshold := pricePctDeviation
settings.depth := zigDepth
zigZag.update()

// =============== EMAs ===============
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
plot(ema9,  "EMA 9",  color = showEMAs ? color.blue : color.new(color.blue, 100), linewidth=2)
plot(ema21, "EMA 21", color = showEMAs ? color.red  : color.new(color.red,  100), linewidth=2)

// =============== STATE: RECENT and LARGEST setup ===============
// A setup is fully described by (A_price, A_time, B_price, B_time).
var float recentA_price = na
var int   recentA_time  = na
var float recentB_price = na
var int   recentB_time  = na

var float largestA_price = na
var int   largestA_time  = na
var float largestB_price = na
var int   largestB_time  = na
var float largestRange   = 0.0

// History (past setups that have been archived)
var array<float> hist_A_price = array.new<float>()
var array<int>   hist_A_time  = array.new<int>()
var array<float> hist_B_price = array.new<float>()
var array<int>   hist_B_time  = array.new<int>()

// =============== DETECTION LOOP ===============
// Walk through all pivots, find the most-recent down-swing (RECENT) and the
// largest down-swing (LARGEST). Runs on every bar so the latest A/B are
// always available even before the current bar confirms.
if zigZag.pivots.size() >= 1
    sz = zigZag.pivots.size()

    // ---- Scan for RECENT (latest down-swing) ----
    // Pine has no descending loops; iterate forward and keep overwriting so
    // the final assignment holds the LATEST down-swing.
    int   foundRecent_idx = na
    float foundRecent_A   = na
    int   foundRecent_At  = na
    float foundRecent_B   = na
    int   foundRecent_Bt  = na

    for i = 0 to sz - 1
        p = zigZag.pivots.get(i)
        if p.end.price < p.start.price  // down-swing
            foundRecent_idx := i
            foundRecent_A   := p.start.price
            foundRecent_At  := p.start.time
            foundRecent_B   := p.end.price
            foundRecent_Bt  := p.end.time

    // ---- Scan for LARGEST (biggest down-swing by absolute range) ----
    float foundLargest_A   = na
    int   foundLargest_At  = na
    float foundLargest_B   = na
    int   foundLargest_Bt  = na
    float foundLargest_Rng = 0.0

    for i = 0 to sz - 1
        p = zigZag.pivots.get(i)
        if p.end.price < p.start.price
            r = p.start.price - p.end.price
            if r > foundLargest_Rng
                foundLargest_Rng := r
                foundLargest_A   := p.start.price
                foundLargest_At  := p.start.time
                foundLargest_B   := p.end.price
                foundLargest_Bt  := p.end.time

    // ---- Apply: did the recent setup change? Archive the old if so ----
    // Bug fix: na != na evaluates to na (falsy), so the first-ever assignment
    // would be skipped. Explicitly check for first-run AND for changed-B cases.
    isFirstAssignment = not na(foundRecent_Bt) and na(recentB_time)
    isChangedSetup    = not na(foundRecent_Bt) and not na(recentB_time) and foundRecent_Bt != recentB_time

    if isFirstAssignment or isChangedSetup
        // Inline archive: push current recent (if any) into history arrays
        if not na(recentB_price)
            array.push(hist_A_price, recentA_price)
            array.push(hist_A_time,  recentA_time)
            array.push(hist_B_price, recentB_price)
            array.push(hist_B_time,  recentB_time)
        recentA_price := foundRecent_A
        recentA_time  := foundRecent_At
        recentB_price := foundRecent_B
        recentB_time  := foundRecent_Bt

    // ---- Apply: update LARGEST if a bigger one appeared ----
    if not na(foundLargest_Bt)
        largestA_price := foundLargest_A
        largestA_time  := foundLargest_At
        largestB_price := foundLargest_B
        largestB_time  := foundLargest_Bt
        largestRange   := foundLargest_Rng

// =============== ZONE CALCULATIONS ===============
calc_zones(float aPrice, float bPrice) =>
    rng = aPrice - bPrice
    eLow  = bPrice + entryLo * rng
    eHigh = bPrice + entryHi * rng
    tLow  = bPrice + tpLo    * rng
    tHigh = bPrice + tpHi    * rng
    [eLow, eHigh, tLow, tHigh]

hasRecent = not na(recentA_price) and not na(recentB_price)

float r_eLow = na
float r_eHigh = na
float r_tLow = na
float r_tHigh = na
if hasRecent
    [el, eh, tl, th] = calc_zones(recentA_price, recentB_price)
    r_eLow  := el
    r_eHigh := eh
    r_tLow  := tl
    r_tHigh := th

// =============== PLAYED-OUT DETECTION ===============
// If price has already run past the TP zone (high ≥ tpLow at any point since B),
// the recent setup is considered "played" — show it dimmed instead of active.
var bool recentPlayed     = false
var int  recentPlayed_for = na

if hasRecent
    // Reset the played flag whenever recent setup changes
    if recentB_time != recentPlayed_for
        recentPlayed     := false
        recentPlayed_for := recentB_time

    // Check if any bar since B (inclusive) reached TP zone
    if barstate.isconfirmed and not recentPlayed
        if high >= r_tLow and time >= recentB_time
            recentPlayed := true

// Check if price was ALREADY past TP on first detection (gap-up case)
// — handled by the check above sweeping from B forward as bars confirm.

// =============== TRADE LOGIC (only on the LIVE recent setup) ===============
isLiveRecent = hasRecent and not recentPlayed

volAvg = ta.sma(volume, 20)
volOK  = not useVolFilter or volume > volAvg * 1.2
emaOK  = not useEmaFilter or (close > ema9 and close > ema21)

priceTrigger = isLiveRecent and close > r_eHigh and close[1] <= r_eHigh
entryFired   = priceTrigger and volOK and emaOK and barstate.isconfirmed

var bool inTrade = false
if entryFired
    inTrade := true

tpHit = inTrade and high >= r_tLow and barstate.isconfirmed
if tpHit
    inTrade := false

slHit = inTrade and close < ema21 and close < ema9 and barstate.isconfirmed
if slHit
    inTrade := false

plotshape(entryFired, "Entry", style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime,    0), size=size.small, text="Entry", textcolor=color.white)
plotshape(tpHit,      "TP",    style=shape.triangledown, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small, text="TP",    textcolor=color.white)
plotshape(slHit,      "SL",    style=shape.xcross,       location=location.abovebar, color=color.new(color.red,     0), size=size.small, text="SL",    textcolor=color.white)

// =============== DRAWING ===============
// Storage for boxes/lines/labels — recreated each barstate.islast
var box   bxR_E   = na
var box   bxR_TP  = na
var line  lnR_A   = na
var line  lnR_B   = na
var label lbR_A   = na
var label lbR_B   = na
var label lbR_E   = na
var label lbR_TP  = na

var box   bxL_E   = na
var box   bxL_TP  = na
var line  lnL_A   = na
var line  lnL_B   = na
var label lbL_A   = na
var label lbL_B   = na

var array<box> hist_boxes_E  = array.new<box>()
var array<box> hist_boxes_TP = array.new<box>()

// True only if largest is a different swing from recent
isLargestDifferent = not na(largestB_time) and not na(recentB_time) and largestB_time != recentB_time

if barstate.islast
    // ---- Clean previous drawings ----
    box.delete(bxR_E)
    box.delete(bxR_TP)
    line.delete(lnR_A)
    line.delete(lnR_B)
    label.delete(lbR_A)
    label.delete(lbR_B)
    label.delete(lbR_E)
    label.delete(lbR_TP)
    box.delete(bxL_E)
    box.delete(bxL_TP)
    line.delete(lnL_A)
    line.delete(lnL_B)
    label.delete(lbL_A)
    label.delete(lbL_B)
    while array.size(hist_boxes_E)  > 0
        box.delete(array.pop(hist_boxes_E))
    while array.size(hist_boxes_TP) > 0
        box.delete(array.pop(hist_boxes_TP))

    rightTime = int(time + extendBars * (time - time[1]))

    // ---- Draw the LARGEST swing first (so it sits BEHIND recent) ----
    if showLargest and isLargestDifferent and not na(largestA_price)
        [l_eL, l_eH, l_tL, l_tH] = calc_zones(largestA_price, largestB_price)
        bxL_E  := box.new(largestB_time, l_eH, rightTime, l_eL, xloc=xloc.bar_time, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, histTransp), border_width=1)
        bxL_TP := box.new(largestA_time, l_tH, rightTime, l_tL, xloc=xloc.bar_time, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, histTransp), border_width=1)
        lnL_A  := line.new(largestA_time, largestA_price, rightTime, largestA_price, xloc=xloc.bar_time, color=color.new(color.gray, 60), style=line.style_dotted, width=1)
        lnL_B  := line.new(largestB_time, largestB_price, rightTime, largestB_price, xloc=xloc.bar_time, color=color.new(color.gray, 60), style=line.style_dotted, width=1)
        if showABLabels
            lbL_A := label.new(largestA_time, largestA_price, "A (large)  " + str.tostring(largestA_price, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.gray, 40), textcolor=color.white, size=size.small)
            lbL_B := label.new(largestB_time, largestB_price, "B (large)  " + str.tostring(largestB_price, format.mintick), xloc=xloc.bar_time, style=label.style_label_up,   color=color.new(color.gray, 40), textcolor=color.white, size=size.small)

    // ---- Draw the RECENT setup (active OR played-dimmed) ----
    if hasRecent
        recentTransp = isLiveRecent ? zoneTransp : histTransp
        eColor = isLiveRecent ? color.orange : color.new(color.gray, 60)
        tColor = isLiveRecent ? color.lime   : color.new(color.gray, 60)
        eBg    = isLiveRecent ? color.new(color.orange, recentTransp) : color.new(color.gray, histTransp)
        tBg    = isLiveRecent ? color.new(color.lime,   recentTransp) : color.new(color.gray, histTransp)
        aLabelColor = isLiveRecent ? color.new(color.red,   20) : color.new(color.gray, 40)
        bLabelColor = isLiveRecent ? color.new(color.green, 20) : color.new(color.gray, 40)

        midTime = int(recentB_time + (rightTime - recentB_time) / 2)

        bxR_E  := box.new(recentB_time, r_eHigh, rightTime, r_eLow,  xloc=xloc.bar_time, border_color=eColor, bgcolor=eBg, border_width=1)
        bxR_TP := box.new(recentA_time, r_tHigh, rightTime, r_tLow,  xloc=xloc.bar_time, border_color=tColor, bgcolor=tBg, border_width=1)

        lnR_A := line.new(recentA_time, recentA_price, rightTime, recentA_price, xloc=xloc.bar_time, color=isLiveRecent ? color.new(color.white, 30) : color.new(color.gray, 60), style=line.style_dotted, width=1)
        lnR_B := line.new(recentB_time, recentB_price, rightTime, recentB_price, xloc=xloc.bar_time, color=isLiveRecent ? color.new(color.white, 30) : color.new(color.gray, 60), style=line.style_dotted, width=1)

        if showABLabels
            lbR_A := label.new(recentA_time, recentA_price, "A  " + str.tostring(recentA_price, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=aLabelColor, textcolor=color.white, size=size.small)
            lbR_B := label.new(recentB_time, recentB_price, "B  " + str.tostring(recentB_price, format.mintick), xloc=xloc.bar_time, style=label.style_label_up,   color=bLabelColor, textcolor=color.white, size=size.small)

        if isLiveRecent
            lbR_E  := label.new(midTime, (r_eLow + r_eHigh) / 2, "Entry Zone",  xloc=xloc.bar_time, style=label.style_none, textcolor=color.orange, size=size.normal)
            lbR_TP := label.new(midTime, (r_tLow + r_tHigh) / 2, "Take Profit", xloc=xloc.bar_time, style=label.style_none, textcolor=color.lime,   size=size.normal)

    // ---- Draw past history (all dimmed) ----
    if showHistory
        histSize = array.size(hist_A_price)
        if histSize > 0
            start    = math.max(0, histSize - maxHistory)
            for i = start to histSize - 1
                hA  = array.get(hist_A_price, i)
                hAt = array.get(hist_A_time,  i)
                hB  = array.get(hist_B_price, i)
                hBt = array.get(hist_B_time,  i)
                [h_eL, h_eH, h_tL, h_tH] = calc_zones(hA, hB)
                hRight = i + 1 < histSize ? array.get(hist_B_time, i + 1) : recentB_time
                bxE_h  = box.new(hBt, h_eH, hRight, h_eL, xloc=xloc.bar_time, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, histTransp), border_width=1)
                bxTP_h = box.new(hAt, h_tH, hRight, h_tL, xloc=xloc.bar_time, border_color=color.new(color.gray, 60), bgcolor=color.new(color.gray, histTransp), border_width=1)
                array.push(hist_boxes_E,  bxE_h)
                array.push(hist_boxes_TP, bxTP_h)

    // ---- Optional debug: yellow zigzag ----
    if showZigZagDbg and zigZag.pivots.size() >= 1
        for i = 0 to zigZag.pivots.size() - 1
            p = zigZag.pivots.get(i)
            line.new(p.start.time, p.start.price, p.end.time, p.end.price, xloc=xloc.bar_time, color=color.new(color.yellow, 50), width=1, style=line.style_dashed)

// =============== INFO TABLE ===============
var table info = table.new(position.top_right, 2, 14, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast and showInfoTable
    table.cell(info, 0, 0, "ZigZag KB AutoFib", text_color=color.orange, text_size=size.small)
    table.cell(info, 1, 0, timeframe.period, text_color=color.orange, text_size=size.small)

    // Count down-swings and up-swings for diagnostics
    int dnCount = 0
    int upCount = 0
    if zigZag.pivots.size() >= 1
        for di = 0 to zigZag.pivots.size() - 1
            pd = zigZag.pivots.get(di)
            if pd.end.price < pd.start.price
                dnCount += 1
            else
                upCount += 1

    if not hasRecent
        table.cell(info, 0, 1, "Status", text_color=color.gray, text_size=size.small)
        table.cell(info, 1, 1, "Waiting for valid swing", text_color=color.aqua, text_size=size.small)
        table.cell(info, 0, 2, "ZigZag pivots", text_color=color.gray, text_size=size.small)
        table.cell(info, 1, 2, str.tostring(zigZag.pivots.size()) + " (down=" + str.tostring(dnCount) + ", up=" + str.tostring(upCount) + ")", text_color=color.aqua, text_size=size.small)
        table.cell(info, 0, 3, "Detection", text_color=color.gray, text_size=size.small)
        table.cell(info, 1, 3, "Dev=" + str.tostring(pricePctDeviation, "#.#") + "%  Depth=" + str.tostring(zigDepth), text_color=color.gray, text_size=size.small)
        table.cell(info, 0, 4, "Hint", text_color=color.gray, text_size=size.small)
        hintText = zigZag.pivots.size() == 0 ? "Lower the Deviation %" : (dnCount == 0 ? "No down-swings yet" : "Detected but not assigned (bug)")
        table.cell(info, 1, 4, hintText, text_color=color.aqua, text_size=size.small)
    else
        dropPct = (recentA_price - recentB_price) / recentA_price * 100.0
        rr = close > recentB_price ? (r_tLow - close) / (close - recentB_price) : na
        triggered = close > r_eHigh
        emaCheck  = close > ema9 and close > ema21

        table.cell(info, 0, 1, "A (Peak)", text_color=color.red, text_size=size.small)
        table.cell(info, 1, 1, str.tostring(recentA_price, format.mintick), text_color=color.red, text_size=size.small)

        table.cell(info, 0, 2, "B (Low)", text_color=color.green, text_size=size.small)
        table.cell(info, 1, 2, str.tostring(recentB_price, format.mintick), text_color=color.green, text_size=size.small)

        table.cell(info, 0, 3, "Drop %", text_color=color.white, text_size=size.small)
        table.cell(info, 1, 3, str.tostring(dropPct, "#.##") + "%", text_color=color.white, text_size=size.small)

        table.cell(info, 0, 4, "Entry Zone", text_color=color.orange, text_size=size.small)
        table.cell(info, 1, 4, str.tostring(r_eLow, format.mintick) + " – " + str.tostring(r_eHigh, format.mintick), text_color=color.orange, text_size=size.small)

        table.cell(info, 0, 5, "TP Zone", text_color=color.lime, text_size=size.small)
        table.cell(info, 1, 5, str.tostring(r_tLow, format.mintick) + " – " + str.tostring(r_tHigh, format.mintick), text_color=color.lime, text_size=size.small)

        triggerColor = isLiveRecent ? (triggered ? color.lime : color.gray) : color.gray
        triggerText  = not isLiveRecent ? "PLAYED" : (triggered ? "ACTIVE ✓" : "Waiting")
        table.cell(info, 0, 6, "Trigger", text_color=color.white, text_size=size.small)
        table.cell(info, 1, 6, triggerText, text_color=triggerColor, text_size=size.small)

        table.cell(info, 0, 7, "R:R to TP", text_color=color.white, text_size=size.small)
        table.cell(info, 1, 7, na(rr) ? "—" : str.tostring(rr, "#.##"), text_color=color.white, text_size=size.small)

        table.cell(info, 0, 8, "Above EMAs", text_color=color.white, text_size=size.small)
        table.cell(info, 1, 8, emaCheck ? "Yes ✓" : "No", text_color=emaCheck ? color.lime : color.gray, text_size=size.small)

        table.cell(info, 0, 9, "Trade State", text_color=color.white, text_size=size.small)
        table.cell(info, 1, 9, inTrade ? "IN TRADE" : "Flat", text_color=inTrade ? color.lime : color.gray, text_size=size.small)

        if isLargestDifferent
            table.cell(info, 0, 10, "Largest A / B", text_color=color.gray, text_size=size.small)
            table.cell(info, 1, 10, str.tostring(largestA_price, format.mintick) + " / " + str.tostring(largestB_price, format.mintick), text_color=color.gray, text_size=size.small)

        table.cell(info, 0, 11, "Past Setups", text_color=color.gray, text_size=size.small)
        table.cell(info, 1, 11, str.tostring(array.size(hist_A_price)) + " archived", text_color=color.gray, text_size=size.small)

        table.cell(info, 0, 12, "Detection", text_color=color.gray, text_size=size.small)
        table.cell(info, 1, 12, "Dev=" + str.tostring(pricePctDeviation, "#.#") + "%  Depth=" + str.tostring(zigDepth), text_color=color.gray, text_size=size.small)

// =============== ALERTS ===============
alertcondition(entryFired, "ZigZag KB AutoFib — Entry",       "ENTRY triggered on {{ticker}}")
alertcondition(tpHit,      "ZigZag KB AutoFib — Take Profit", "TP HIT on {{ticker}}")
alertcondition(slHit,      "ZigZag KB AutoFib — Stop Loss",   "SL HIT on {{ticker}}")
````
