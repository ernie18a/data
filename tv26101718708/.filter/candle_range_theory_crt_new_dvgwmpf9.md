# Candle Range Theory (CRT) New

- url: https://www.tradingview.com/script/dVgWmPF9-Candle-Range-Theory-CRT-New/
- type: indicator
- pine_id: PUB;b1ab34e2e82440faa370549dcc5ed9a8
- version: 1.0

## Description

There's a new setting called "Bars Inside Range Before Sweep" (default: 3) in the HTF Settings group. You can tune this:

Higher (5-10) = stricter, requires more consolidation inside the range before a sweep counts
Lower (1-2) = looser, just needs one recent close inside

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CirisAshley

//@version=6
indicator("Candle Range Theory (CRT)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)


// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grp1 = "HTF Settings"
htfChoice  = input.string("1H", "HTF Timeframe", options=["15m","30m","1H","2H","4H","Daily","Weekly"], group=grp1)
insideBars = input.int(3, "Bars Inside Range Before Sweep", group=grp1, minval=1, maxval=10, tooltip="How many of the recent candles must have closed inside the HTF range before a sweep is valid. Prevents false signals when price crashes through from outside.")

grp2 = "Display"
showBox    = input.bool(true, "Show HTF Range Box",        group=grp2)
showTarget = input.bool(true, "Show Target Line",          group=grp2)
showSL     = input.bool(true, "Show Stop Loss Line",       group=grp2)
showMid    = input.bool(true, "Show Midline (50%)",        group=grp2)
extendBars = input.int(60,    "Extend Lines (bars right)", group=grp2, minval=5, maxval=500)
labelOffset= input.int(40,    "Label Offset (bars right)", group=grp2, minval=5, maxval=300)
slBuffer   = input.float(0.0, "Stop Loss Buffer (ticks)",  group=grp2, minval=0, maxval=100, tooltip="Extra ticks beyond HTF high/low for the stop loss")

grp3 = "Colors"
boxBullCol    = input.color(color.new(#2196F3, 80), "Bull Range Box",  group=grp3)
boxBearCol    = input.color(color.new(#F44336, 80), "Bear Range Box",  group=grp3)
highLineCol   = input.color(#00E676,                "HTF High Line",   group=grp3)
lowLineCol    = input.color(#FF1744,                "HTF Low Line",    group=grp3)
midLineCol    = input.color(#FFD600,                "Midline",         group=grp3)
entryLineCol  = input.color(#FF9800,                "CRT Entry Line",  group=grp3)
targetLineCol = input.color(#00BCD4,                "Target Line",     group=grp3)
slLineCol     = input.color(#FF1744,                "Stop Loss Line",  group=grp3)

// ══════════════════════════════════════════════════════════════════════════════
//  MAP TIMEFRAME
// ══════════════════════════════════════════════════════════════════════════════
htf = htfChoice == "15m"   ? "15"  :
      htfChoice == "30m"   ? "30"  :
      htfChoice == "1H"    ? "60"  :
      htfChoice == "2H"    ? "120" :
      htfChoice == "4H"    ? "240" :
      htfChoice == "Daily" ? "D"   :
      htfChoice == "Weekly"? "W"   : "60"

// ══════════════════════════════════════════════════════════════════════════════
//  HTF DATA
// ══════════════════════════════════════════════════════════════════════════════
[htfHigh, htfLow, htfOpen, htfClose, htfTime] = request.security(
     syminfo.tickerid, htf,
     [high[1], low[1], open[1], close[1], time[1]],
     lookahead = barmerge.lookahead_on)

isNewHTF = ta.change(htfTime) != 0

// ══════════════════════════════════════════════════════════════════════════════
//  HELPER — check that enough recent bars closed INSIDE the range
//  This filters out breakdowns/breakouts where price crashes through from outside
// ══════════════════════════════════════════════════════════════════════════════
f_priceWasInside(float rangeHigh, float rangeLow, int barsBack) =>
    count = 0
    for i = 1 to barsBack
        if close[i] <= rangeHigh and close[i] >= rangeLow
            count += 1
    count >= 1   // at least 1 of the last N bars closed inside the range

// ══════════════════════════════════════════════════════════════════════════════
//  STATE
// ══════════════════════════════════════════════════════════════════════════════
var float crtHigh   = na
var float crtLow    = na
var float crtMid    = na
var bool  crtIsBull = false
var int   sweepDir        = 0
var float sweepCandleHigh = na
var float sweepCandleLow  = na
var bool  confirmed       = false

var box   crtBox     = na
var line  lineHigh   = na
var line  lineLow    = na
var line  lineMid    = na
var line  lineEntry  = na
var line  lineTarget = na
var line  lineSL     = na
var line  lineTick   = na
var label lblHigh    = na
var label lblLow     = na
var label lblEntry   = na
var label lblTarget  = na
var label lblSL      = na

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_delLine(line l) =>
    if not na(l)
        line.delete(l)

f_delBox(box b) =>
    if not na(b)
        box.delete(b)

f_delLabel(label l) =>
    if not na(l)
        label.delete(l)

// ══════════════════════════════════════════════════════════════════════════════
//  NEW HTF CANDLE → reset and draw fresh range
// ══════════════════════════════════════════════════════════════════════════════
if isNewHTF
    crtHigh   := htfHigh
    crtLow    := htfLow
    crtMid    := (htfHigh + htfLow) / 2.0
    crtIsBull := htfClose >= htfOpen
    sweepDir        := 0
    sweepCandleHigh := na
    sweepCandleLow  := na
    confirmed       := false

    f_delBox(crtBox)
    f_delLine(lineHigh)
    f_delLine(lineLow)
    f_delLine(lineMid)
    f_delLine(lineEntry)
    f_delLine(lineTarget)
    f_delLine(lineSL)
    f_delLine(lineTick)
    f_delLabel(lblHigh)
    f_delLabel(lblLow)
    f_delLabel(lblEntry)
    f_delLabel(lblTarget)
    f_delLabel(lblSL)

    if showBox
        crtBox := box.new(
             bar_index, crtHigh, bar_index + extendBars, crtLow,
             border_color = crtIsBull ? color.new(#2196F3, 50) : color.new(#F44336, 50),
             border_width = 1,
             bgcolor      = crtIsBull ? boxBullCol : boxBearCol)

    lineHigh := line.new(bar_index, crtHigh, bar_index + extendBars, crtHigh,
         color=highLineCol, width=2, style=line.style_dashed)
    lblHigh := label.new(bar_index, crtHigh,
         text="HTF High  " + str.tostring(crtHigh, format.mintick),
         color=color.new(highLineCol, 85), textcolor=highLineCol,
         style=label.style_label_right, size=size.small)

    lineLow := line.new(bar_index, crtLow, bar_index + extendBars, crtLow,
         color=lowLineCol, width=2, style=line.style_dashed)
    lblLow := label.new(bar_index, crtLow,
         text="HTF Low  " + str.tostring(crtLow, format.mintick),
         color=color.new(lowLineCol, 85), textcolor=lowLineCol,
         style=label.style_label_right, size=size.small)

    if showMid
        lineMid := line.new(bar_index, crtMid, bar_index + extendBars, crtMid,
             color=midLineCol, width=1, style=line.style_dotted)

// ══════════════════════════════════════════════════════════════════════════════
//  CRT LOGIC — every bar
// ══════════════════════════════════════════════════════════════════════════════
if not na(crtHigh) and not confirmed

    // ── Context check: was price trading inside the range recently? ──────────
    // This is the key filter — prevents false signals when price breaks through
    // the range from outside (e.g. a sell-off that crashes through the HTF low)
    priceWasInside = f_priceWasInside(crtHigh, crtLow, insideBars)

    isHighSweep = high > crtHigh and close <= crtHigh and priceWasInside
    isLowSweep  = low  < crtLow  and close >= crtLow  and priceWasInside

    // Always update to most recent valid sweep candle
    if isHighSweep
        sweepDir        := 1
        sweepCandleHigh := high
        sweepCandleLow  := low

    if isLowSweep
        sweepDir        := 2
        sweepCandleHigh := high
        sweepCandleLow  := low

    // ── SELL confirmation ───────────────────────────────────────────────────
    if sweepDir == 1 and not isHighSweep and close < crtHigh
        confirmed := true
        entryPx   = sweepCandleLow
        targetPx  = crtLow
        slPx      = crtHigh + (slBuffer * syminfo.mintick)

        f_delLine(lineEntry)
        f_delLine(lineTarget)
        f_delLine(lineSL)
        f_delLine(lineTick)
        f_delLabel(lblEntry)
        f_delLabel(lblTarget)
        f_delLabel(lblSL)

        lineEntry := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=entryLineCol, width=2, style=line.style_solid)

        tickX     = bar_index + labelOffset
        tickRange = (crtHigh - crtLow) * 0.015
        lineTick  := line.new(tickX, entryPx + tickRange, tickX, entryPx - tickRange,
             color=entryLineCol, width=2)

        riskPts   = slPx - entryPx
        rewardPts = entryPx - targetPx
        rr        = riskPts > 0 ? str.tostring(math.round(rewardPts / riskPts, 1)) : "?"

        lblEntry := label.new(tickX, entryPx - tickRange,
             text="▼ CRT Sell  " + str.tostring(entryPx, format.mintick) + "\nR:R  1:" + rr,
             color=color.new(entryLineCol, 5), textcolor=color.white,
             style=label.style_label_upper_right, size=size.normal)

        if showTarget
            lineTarget := line.new(bar_index, targetPx, bar_index + extendBars, targetPx,
                 color=targetLineCol, width=1, style=line.style_dashed)
            lblTarget := label.new(tickX, targetPx,
                 text="🎯 Target  " + str.tostring(targetPx, format.mintick),
                 color=color.new(targetLineCol, 10), textcolor=color.white,
                 style=label.style_label_upper_right, size=size.small)

        if showSL
            lineSL := line.new(bar_index, slPx, bar_index + extendBars, slPx,
                 color=slLineCol, width=1, style=line.style_dotted)
            lblSL := label.new(tickX, slPx,
                 text="🛑 Stop  " + str.tostring(slPx, format.mintick),
                 color=color.new(slLineCol, 10), textcolor=color.white,
                 style=label.style_label_lower_right, size=size.small)

    // ── BUY confirmation ────────────────────────────────────────────────────
    if sweepDir == 2 and not isLowSweep and close > crtLow
        confirmed := true
        entryPx   = sweepCandleHigh
        targetPx  = crtHigh
        slPx      = crtLow - (slBuffer * syminfo.mintick)

        f_delLine(lineEntry)
        f_delLine(lineTarget)
        f_delLine(lineSL)
        f_delLine(lineTick)
        f_delLabel(lblEntry)
        f_delLabel(lblTarget)
        f_delLabel(lblSL)

        lineEntry := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=entryLineCol, width=2, style=line.style_solid)

        tickX     = bar_index + labelOffset
        tickRange = (crtHigh - crtLow) * 0.015
        lineTick  := line.new(tickX, entryPx + tickRange, tickX, entryPx - tickRange,
             color=entryLineCol, width=2)

        riskPts   = entryPx - slPx
        rewardPts = targetPx - entryPx
        rr        = riskPts > 0 ? str.tostring(math.round(rewardPts / riskPts, 1)) : "?"

        lblEntry := label.new(tickX, entryPx + tickRange,
             text="▲ CRT Buy  " + str.tostring(entryPx, format.mintick) + "\nR:R  1:" + rr,
             color=color.new(entryLineCol, 5), textcolor=color.white,
             style=label.style_label_lower_right, size=size.normal)

        if showTarget
            lineTarget := line.new(bar_index, targetPx, bar_index + extendBars, targetPx,
                 color=targetLineCol, width=1, style=line.style_dashed)
            lblTarget := label.new(tickX, targetPx,
                 text="🎯 Target  " + str.tostring(targetPx, format.mintick),
                 color=color.new(targetLineCol, 10), textcolor=color.white,
                 style=label.style_label_lower_right, size=size.small)

        if showSL
            lineSL := line.new(bar_index, slPx, bar_index + extendBars, slPx,
                 color=slLineCol, width=1, style=line.style_dotted)
            lblSL := label.new(tickX, slPx,
                 text="🛑 Stop  " + str.tostring(slPx, format.mintick),
                 color=color.new(slLineCol, 10), textcolor=color.white,
                 style=label.style_label_upper_right, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  EXTEND LINES + FLOAT LABELS
// ══════════════════════════════════════════════════════════════════════════════
if not na(lineHigh)
    line.set_x2(lineHigh, bar_index + extendBars)
if not na(lineLow)
    line.set_x2(lineLow, bar_index + extendBars)
if not na(lineMid)
    line.set_x2(lineMid, bar_index + extendBars)
if not na(lineEntry)
    line.set_x2(lineEntry, bar_index + extendBars)
if not na(lineTarget)
    line.set_x2(lineTarget, bar_index + extendBars)
if not na(lineSL)
    line.set_x2(lineSL, bar_index + extendBars)
if showBox and not na(crtBox)
    box.set_right(crtBox, bar_index + extendBars)

if not na(lineTick)
    newX = bar_index + labelOffset
    line.set_x1(lineTick, newX)
    line.set_x2(lineTick, newX)
if not na(lblEntry)
    label.set_x(lblEntry, bar_index + labelOffset)
if not na(lblTarget)
    label.set_x(lblTarget, bar_index + labelOffset)
if not na(lblSL)
    label.set_x(lblSL, bar_index + labelOffset)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(confirmed and not confirmed[1],
     title   = "CRT Entry Signal",
     message = "CRT Setup confirmed — CRT Buy/Sell entry level plotted on chart.")
````
