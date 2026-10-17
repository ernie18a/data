# CirisAshley CRT

- url: https://www.tradingview.com/script/Qofdmg7V-CirisAshley-CRT/
- type: indicator
- pine_id: PUB;ee62888c5261404b99020e887f3c4bef
- version: 10.0

## Description

Candle Range Theory indicator - The colors are already fully customizable with hex in the current script! TradingView's input.color() fields support hex natively

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CirisAshley

//@version=6
indicator("Candle Range Theory (CRT)", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ══════════════════════════════════════════════════════════════════════════════
//  ① ORIGINAL CRT SETTINGS  (unchanged)
// ══════════════════════════════════════════════════════════════════════════════
grp1 = "① CRT — HTF Settings"
htfChoice   = input.string("1H", "HTF Timeframe", options=["15m","30m","1H","2H","4H","Daily","Weekly"], group=grp1)
insideBars  = input.int(2, "Consecutive Bars Inside Range Before Sweep", group=grp1, minval=1, maxval=5)

grp2 = "① CRT — Displacement Filter"
useDisp     = input.bool(true,  "Require Displacement Candle",  group=grp2)
dispBodyPct = input.float(60.0, "Min Body % of Candle Range",   group=grp2, minval=20.0, maxval=95.0)
dispAtrMult = input.float(1.0,  "Min Size vs ATR (multiplier)", group=grp2, minval=0.1,  maxval=5.0)

grp3 = "① CRT — FVG Entry"
showFVG  = input.bool(true, "Show Fair Value Gap", group=grp3)
fvgColor = input.color(color.new(#9C27B0, 75), "FVG Zone Color", group=grp3)

grp4 = "① CRT — Display"
showBox     = input.bool(true, "Show HTF Range Box",       group=grp4)
showTarget  = input.bool(true, "Show Target Line",         group=grp4)
showSL      = input.bool(true, "Show Stop Loss Line",      group=grp4)
showMid     = input.bool(true, "Show Midline (50%)",       group=grp4)
extendBars  = input.int(60,    "Extend Lines (bars right)",group=grp4, minval=5, maxval=500)
labelOffset = input.int(40,    "Label Offset (bars right)",group=grp4, minval=5, maxval=300)
slBuffer    = input.float(0.0, "Stop Loss Buffer (ticks)", group=grp4, minval=0, maxval=100)
signalExpiry= input.int(10,    "Signal Expiry (bars)",     group=grp4, minval=3, maxval=50,
             tooltip="Entry label and line disappear after this many bars — keeps chart clean")

grp5 = "① CRT — Colors"
boxBullCol    = input.color(color.new(#2196F3, 80), "Bull Range Box",  group=grp5)
boxBearCol    = input.color(color.new(#F44336, 80), "Bear Range Box",  group=grp5)
highLineCol   = input.color(#00E676,                "HTF High Line",   group=grp5)
lowLineCol    = input.color(#FF1744,                "HTF Low Line",    group=grp5)
midLineCol    = input.color(#FFD600,                "Midline",         group=grp5)
entryLineCol  = input.color(#FF9800,                "CRT Entry Line",  group=grp5)
targetLineCol = input.color(#00BCD4,                "Target Line",     group=grp5)
slLineCol     = input.color(#FF1744,                "Stop Loss Line",  group=grp5)

// ══════════════════════════════════════════════════════════════════════════════
//  ② PDH/PDL SETTINGS
// ══════════════════════════════════════════════════════════════════════════════
grp6 = "② PDH/PDL Sweep"
usePDHL        = input.bool(true,  "Enable PDH/PDL Signal",          group=grp6)
pdhlExpiry     = input.int(10,     "Signal Expiry (bars)",            group=grp6, minval=3, maxval=50)
pdhlLabelCol   = input.color(#E91E63, "PDH/PDL Label Color",          group=grp6)
pdhlLineCol    = input.color(#E91E63, "PDH/PDL Entry Line Color",     group=grp6)

// ══════════════════════════════════════════════════════════════════════════════
//  ③ ASIA RANGE SWEEP SETTINGS
// ══════════════════════════════════════════════════════════════════════════════
grp7 = "③ Asia Range Sweep"
useAsia        = input.bool(true,  "Enable Asia Sweep Signal",        group=grp7)
asiaOpenHr     = input.int(19,     "Asia Open Hour (UTC)",            group=grp7, minval=0, maxval=23)
asiaCloseHr    = input.int(0,      "Asia Close Hour (UTC)",           group=grp7, minval=0, maxval=23,
                 tooltip="Use 0 for midnight UTC (end of Asia session)")
asiaExpiry     = input.int(10,     "Signal Expiry (bars)",            group=grp7, minval=3, maxval=50)
asiaLabelCol   = input.color(#00BFA5, "Asia Label Color",             group=grp7)
asiaLineCol    = input.color(#00BFA5, "Asia Entry Line Color",        group=grp7)

// ══════════════════════════════════════════════════════════════════════════════
//  ④ ORB CRT SETTINGS
// ══════════════════════════════════════════════════════════════════════════════
grp8 = "④ ORB CRT (Opening Range)"
useORB         = input.bool(true,  "Enable ORB CRT Signal",           group=grp8)
orbOpenHr      = input.int(13,     "Market Open Hour (UTC)",          group=grp8, minval=0, maxval=23,
                 tooltip="9:30 AM EST = 13:30 UTC / 14:30 UTC during daylight saving — adjust to your broker")
orbMins        = input.int(30,     "Opening Range Duration (mins)",   group=grp8, minval=5, maxval=60)
orbExpiry      = input.int(10,     "Signal Expiry (bars)",            group=grp8, minval=3, maxval=50)
orbLabelCol    = input.color(#FF6F00, "ORB Label Color",              group=grp8)
orbLineCol     = input.color(#FF6F00, "ORB Entry Line Color",         group=grp8)

// ══════════════════════════════════════════════════════════════════════════════
//  ⑤ SESSIONS / KILLZONE
// ══════════════════════════════════════════════════════════════════════════════
grp9 = "⑤ Sessions"
useKillzone  = input.bool(true,  "Only Trade During Killzones (CRT)", group=grp9)
showKZBg     = input.bool(true,  "Highlight Killzone Sessions",       group=grp9)
londonOpen   = input.int(7,  "London Open Hour (UTC)",  group=grp9, minval=0, maxval=23)
londonClose  = input.int(10, "London Close Hour (UTC)", group=grp9, minval=0, maxval=23)
nyOpen       = input.int(13, "NY Open Hour (UTC)",      group=grp9, minval=0, maxval=23)
nyClose      = input.int(16, "NY Close Hour (UTC)",     group=grp9, minval=0, maxval=23)
kzColor      = input.color(color.new(#2196F3, 90), "Killzone Background", group=grp9)

// ══════════════════════════════════════════════════════════════════════════════
//  ⑥ DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
grpD = "⑥ Dashboard"
showDash     = input.bool(true, "Show Dashboard", group=grpD)

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED DATA
// ══════════════════════════════════════════════════════════════════════════════
atr = ta.atr(14)

currentHour = hour(time, "UTC")
currentMin  = minute(time, "UTC")
inLondon    = currentHour >= londonOpen and currentHour < londonClose
inNY        = currentHour >= nyOpen     and currentHour < nyClose
inKillzone  = inLondon or inNY
inAsiaSess  = currentHour >= asiaOpenHr or currentHour < asiaCloseHr

bgcolor(showKZBg and inLondon ? color.new(kzColor, 92)           : na, title="London KZ")
bgcolor(showKZBg and inNY     ? color.new(color.orange, 92)      : na, title="NY KZ")
bgcolor(showKZBg and inAsiaSess ? color.new(color.teal, 95)      : na, title="Asia Session")

// ── Daily trend bias (for caution/checkmark) ─────────────────────────────────
dailyClose  = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)
dailyOpen   = request.security(syminfo.tickerid, "D", open[1],  lookahead=barmerge.lookahead_off)
dailyBull   = dailyClose >= dailyOpen   // true = daily candle is bullish

f_trendTag(isBull) =>
    // isBull = direction of THIS signal (true=buy, false=sell)
    withTrend = (isBull and dailyBull) or (not isBull and not dailyBull)
    withTrend ? "✅" : "⚠️"

// ── HTF timeframe map ─────────────────────────────────────────────────────────
htf = htfChoice == "15m"    ? "15"  :
      htfChoice == "30m"    ? "30"  :
      htfChoice == "1H"     ? "60"  :
      htfChoice == "2H"     ? "120" :
      htfChoice == "4H"     ? "240" :
      htfChoice == "Daily"  ? "D"   :
      htfChoice == "Weekly" ? "W"   : "60"

// ── Original CRT HTF data ─────────────────────────────────────────────────────
[htfHigh, htfLow, htfOpen, htfClose, htfTime] = request.security(
     syminfo.tickerid, htf,
     [high[1], low[1], open[1], close[1], time[1]],
     lookahead=barmerge.lookahead_off)
isNewHTF = ta.change(htfTime) != 0

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════
f_isDisplacement(o, c, h, l) =>
    totalRange = h - l
    bodySize   = math.abs(c - o)
    bodyPct    = totalRange > 0 ? (bodySize / totalRange) * 100 : 0
    totalRange >= (dispAtrMult * atr) and bodyPct >= dispBodyPct

f_consecutiveInside(rHigh, rLow, n) =>
    allIn = true
    for i = 1 to n
        if close[i] > rHigh or close[i] < rLow
            allIn := false
    allIn

// FVG detection (evaluated each bar, used at point of signal)
bullFVG    = low > high[2]
bullFVGTop = low
bullFVGBot = high[2]
bearFVG    = high < low[2]
bearFVGTop = low[2]
bearFVGBot = high

// Generic signal-expiry cleaner — called each bar per module
f_delLine(l) =>
    if not na(l)
        line.delete(l)
f_delBox(b) =>
    if not na(b)
        box.delete(b)
f_delLabel(l) =>
    if not na(l)
        label.delete(l)

// ══════════════════════════════════════════════════════════════════════════════
//  SIGNAL COUNT TRACKER  (dashboard)
// ══════════════════════════════════════════════════════════════════════════════
var int crtCount  = 0
var int pdhlCount = 0
var int asiaCount = 0
var int orbCount  = 0

// Active signal slots — each holds the label string while that signal is live
// Clears automatically when the signal expires (mirrors chart visibility)
var string activeCRT   = "—"
var string activePDHL  = "—"
var string asiaActive  = "—"
var string orbActive   = "—"

// Reset daily
var int lastDayReset = na
if na(lastDayReset) or dayofweek != dayofweek[1]
    lastDayReset := dayofweek
    crtCount  := 0
    pdhlCount := 0
    asiaCount := 0
    orbCount  := 0

// ══════════════════════════════════════════════════════════════════════════════
//  ══ MODULE 1: ORIGINAL CRT ══
// ══════════════════════════════════════════════════════════════════════════════
var float crtHigh         = na
var float crtLow          = na
var float crtMid          = na
var bool  crtIsBull       = false
var int   sweepDir        = 0
var float sweepCandleHigh = na
var float sweepCandleLow  = na
var bool  confirmed       = false
var float fvgTop          = na
var float fvgBot          = na
var bool  hasFVG          = false
var int   crtSignalBar    = na   // bar when signal fired (for expiry)

var box   crtBox     = na
var box   fvgBox     = na
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

// Expiry — delete entry signal after N bars
if not na(crtSignalBar) and (bar_index - crtSignalBar) >= signalExpiry
    f_delLine(lineEntry)
    f_delLine(lineTick)
    f_delLabel(lblEntry)
    crtSignalBar := na
    activeCRT    := "—"

if isNewHTF
    crtHigh   := htfHigh
    crtLow    := htfLow
    crtMid    := (htfHigh + htfLow) / 2.0
    crtIsBull := htfClose >= htfOpen
    sweepDir        := 0
    sweepCandleHigh := na
    sweepCandleLow  := na
    confirmed       := false
    activeCRT       := "—"
    fvgTop := na
    fvgBot := na
    hasFVG := false

    f_delBox(crtBox)
    f_delBox(fvgBox)
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
        crtBox := box.new(bar_index, crtHigh, bar_index + extendBars, crtLow,
             border_color = crtIsBull ? color.new(#2196F3, 50) : color.new(#F44336, 50),
             border_width = 1, bgcolor = crtIsBull ? boxBullCol : boxBearCol)

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

if not na(crtHigh) and not confirmed
    kzOk = not useKillzone or inKillzone
    if kzOk
        wasConsolidating = f_consecutiveInside(crtHigh, crtLow, insideBars)
        isHighSweep = high > crtHigh and close <= crtHigh and wasConsolidating
        isLowSweep  = low  < crtLow  and close >= crtLow  and wasConsolidating

        if isHighSweep
            sweepDir := 1
            sweepCandleHigh := high
            sweepCandleLow  := low
        if isLowSweep
            sweepDir := 2
            sweepCandleHigh := high
            sweepCandleLow  := low

        if sweepDir == 1 and not isHighSweep and close < crtHigh
            dispOk = not useDisp or (f_isDisplacement(open, close, high, low) and close < open)
            if dispOk
                confirmed    := true
                crtCount := crtCount + 1
                crtSignalBar := bar_index
                entryPx       = sweepCandleLow
                targetPx      = crtLow
                slPx          = crtHigh + (slBuffer * syminfo.mintick)
                if showFVG and bearFVG
                    hasFVG  := true
                    fvgTop  := bearFVGTop
                    fvgBot  := bearFVGBot
                    entryPx := fvgBot
                    f_delBox(fvgBox)
                    fvgBox := box.new(bar_index - 2, fvgTop, bar_index + extendBars, fvgBot,
                         border_color=color.new(fvgColor, 30), border_width=1, bgcolor=fvgColor)

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
                fvgTag    = hasFVG ? " [FVG]" : ""
                trend     = f_trendTag(false)
                kzTag     = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
                lblEntry := label.new(tickX, entryPx - tickRange,
                     text=trend + " ▼ CRT Entry" + fvgTag + kzTag + "\n" + str.tostring(entryPx, format.mintick) + "  R:R 1:" + rr,
                     color=color.new(entryLineCol, 5), textcolor=color.white,
                     style=label.style_label_upper_right, size=size.normal)
                if showTarget
                    lineTarget := line.new(bar_index, targetPx, bar_index + extendBars, targetPx,
                         color=targetLineCol, width=1, style=line.style_dashed)
                    lblTarget := label.new(tickX, targetPx,
                         text="🎯 " + str.tostring(targetPx, format.mintick),
                         color=color.new(targetLineCol, 10), textcolor=color.white,
                         style=label.style_label_upper_right, size=size.small)
                if showSL
                    lineSL := line.new(bar_index, slPx, bar_index + extendBars, slPx,
                         color=slLineCol, width=1, style=line.style_dotted)
                    lblSL := label.new(tickX, slPx,
                         text="🛑 " + str.tostring(slPx, format.mintick),
                         color=color.new(slLineCol, 10), textcolor=color.white,
                         style=label.style_label_lower_right, size=size.small)

        if sweepDir == 2 and not isLowSweep and close > crtLow
            dispOk = not useDisp or (f_isDisplacement(open, close, high, low) and close > open)
            if dispOk
                confirmed    := true
                crtCount := crtCount + 1
                crtSignalBar := bar_index
                entryPx       = sweepCandleHigh
                targetPx      = crtHigh
                slPx          = crtLow - (slBuffer * syminfo.mintick)
                if showFVG and bullFVG
                    hasFVG  := true
                    fvgTop  := bullFVGTop
                    fvgBot  := bullFVGBot
                    entryPx := fvgBot
                    f_delBox(fvgBox)
                    fvgBox := box.new(bar_index - 2, fvgTop, bar_index + extendBars, fvgBot,
                         border_color=color.new(fvgColor, 30), border_width=1, bgcolor=fvgColor)

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
                fvgTag    = hasFVG ? " [FVG]" : ""
                trend     = f_trendTag(true)
                kzTag     = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
                lblEntry := label.new(tickX, entryPx + tickRange,
                     text=trend + " ▲ CRT Entry" + fvgTag + kzTag + "\n" + str.tostring(entryPx, format.mintick) + "  R:R 1:" + rr,
                     color=color.new(entryLineCol, 5), textcolor=color.white,
                     style=label.style_label_lower_right, size=size.normal)
                if showTarget
                    lineTarget := line.new(bar_index, targetPx, bar_index + extendBars, targetPx,
                         color=targetLineCol, width=1, style=line.style_dashed)
                    lblTarget := label.new(tickX, targetPx,
                         text="🎯 " + str.tostring(targetPx, format.mintick),
                         color=color.new(targetLineCol, 10), textcolor=color.white,
                         style=label.style_label_lower_right, size=size.small)
                if showSL
                    lineSL := line.new(bar_index, slPx, bar_index + extendBars, slPx,
                         color=slLineCol, width=1, style=line.style_dotted)
                    lblSL := label.new(tickX, slPx,
                         text="🛑 " + str.tostring(slPx, format.mintick),
                         color=color.new(slLineCol, 10), textcolor=color.white,
                         style=label.style_label_upper_right, size=size.small)

// Extend CRT lines
if not na(lineHigh)
    line.set_x2(lineHigh,   bar_index + extendBars)
if not na(lineLow)
    line.set_x2(lineLow,     bar_index + extendBars)
if not na(lineMid)
    line.set_x2(lineMid,     bar_index + extendBars)
if not na(lineEntry)
    line.set_x2(lineEntry,   bar_index + extendBars)
if not na(lineTarget)
    line.set_x2(lineTarget,  bar_index + extendBars)
if not na(lineSL)
    line.set_x2(lineSL,      bar_index + extendBars)
if showBox and not na(crtBox)
    box.set_right(crtBox,  bar_index + extendBars)
if showFVG and not na(fvgBox)
    box.set_right(fvgBox,  bar_index + extendBars)
if not na(lineTick)
    line.set_x1(lineTick, bar_index + labelOffset)
    line.set_x2(lineTick, bar_index + labelOffset)
if not na(lblEntry)
    label.set_x(lblEntry,  bar_index + labelOffset)
if not na(lblTarget)
    label.set_x(lblTarget, bar_index + labelOffset)
if not na(lblSL)
    label.set_x(lblSL,     bar_index + labelOffset)

// ══════════════════════════════════════════════════════════════════════════════
//  ══ MODULE 2: PDH/PDL SWEEP ══
//  Logic: previous day high/low swept by a wick, close back inside, reversal entry
// ══════════════════════════════════════════════════════════════════════════════
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

var int   pdhlSweepDir  = 0
var float pdhlSweepHigh = na
var float pdhlSweepLow  = na
var bool  pdhlConfirmed = false
var int   pdhlSignalBar = na
var line  pdhlLine      = na
var line  pdhlTick      = na
var label pdhlLbl       = na

// Reset on new day
isNewDay = ta.change(time("D")) != 0
if isNewDay
    pdhlSweepDir  := 0
    pdhlSweepHigh := na
    pdhlSweepLow  := na
    pdhlConfirmed := false
    activePDHL    := "—"
    f_delLine(pdhlLine)
    f_delLine(pdhlTick)
    f_delLabel(pdhlLbl)

// Expiry
if not na(pdhlSignalBar) and (bar_index - pdhlSignalBar) >= pdhlExpiry
    f_delLine(pdhlLine)
    f_delLine(pdhlTick)
    f_delLabel(pdhlLbl)
    pdhlSignalBar := na
    activePDHL    := "—"

if usePDHL and not pdhlConfirmed and not na(pdHigh)
    pdMid = (pdHigh + pdLow) / 2.0   // midpoint of previous day range

    // Sweep of PDH: wick MUST exceed PDH, candle MUST close back below PDH, must be bearish
    // Also require close below PDH by at least 1 tick to avoid false touches
    isPDHSweep = high > pdHigh and close < pdHigh and close < open and (pdHigh - close) > syminfo.mintick

    // Sweep of PDL: wick MUST go below PDL, candle MUST close back above PDL, must be bullish
    isPDLSweep = low < pdLow and close > pdLow and close > open and (close - pdLow) > syminfo.mintick

    if isPDHSweep
        pdhlSweepDir  := 1
        pdhlSweepHigh := high
        pdhlSweepLow  := low

    if isPDLSweep
        pdhlSweepDir  := 2
        pdhlSweepHigh := high
        pdhlSweepLow  := low

    // Sell entry: PDH swept, NEXT bar must be:
    //   - bearish candle (close < open)
    //   - close back below PDH (still inside the daily range)
    //   - close below the daily midpoint (real displacement, not just a doji)
    //   - impulsive body (uses same displacement filter as CRT module)
    //   - NOT the sweep bar itself
    pdSellDispOk = f_isDisplacement(open, close, high, low) and close < open
    if pdhlSweepDir == 1 and not isPDHSweep and close < pdHigh and close < pdMid and pdSellDispOk
        pdhlConfirmed := true
        pdhlCount := pdhlCount + 1
        pdhlSignalBar := bar_index
        entryPx        = close
        trend          = f_trendTag(false)
        kzTag          = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(pdhlLine)
        f_delLine(pdhlTick)
        f_delLabel(pdhlLbl)
        pdhlLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=pdhlLineCol, width=2, style=line.style_solid)
        tickX    = bar_index + labelOffset
        tR       = (pdHigh - pdLow) * 0.012
        pdhlTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=pdhlLineCol, width=2)
        pdhlLbl  := label.new(tickX, entryPx - tR,
             text=trend + " ▼ PDH/PDL Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(pdhlLabelCol, 5), textcolor=color.white,
             style=label.style_label_upper_right, size=size.normal)

    // Buy entry: PDL swept, NEXT bar must be:
    //   - bullish candle (close > open)
    //   - close above PDL (back inside daily range)
    //   - close above daily midpoint (real reversal momentum confirmed)
    //   - impulsive body (same displacement filter as CRT)
    //   - NOT the sweep bar itself
    pdBuyDispOk = f_isDisplacement(open, close, high, low) and close > open
    if pdhlSweepDir == 2 and not isPDLSweep and close > pdLow and close > pdMid and pdBuyDispOk
        pdhlConfirmed := true
        pdhlCount := pdhlCount + 1
        pdhlSignalBar := bar_index
        entryPx        = close
        trend          = f_trendTag(true)
        kzTag          = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(pdhlLine)
        f_delLine(pdhlTick)
        f_delLabel(pdhlLbl)
        pdhlLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=pdhlLineCol, width=2, style=line.style_solid)
        tickX    = bar_index + labelOffset
        tR       = (pdHigh - pdLow) * 0.012
        pdhlTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=pdhlLineCol, width=2)
        pdhlLbl  := label.new(tickX, entryPx + tR,
             text=trend + " ▲ PDH/PDL Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(pdhlLabelCol, 5), textcolor=color.white,
             style=label.style_label_lower_right, size=size.normal)

if not na(pdhlLine)
    line.set_x2(pdhlLine, bar_index + extendBars)
if not na(pdhlTick)
    line.set_x1(pdhlTick, bar_index + labelOffset)
    line.set_x2(pdhlTick, bar_index + labelOffset)
if not na(pdhlLbl)
    label.set_x(pdhlLbl, bar_index + labelOffset)

// ══════════════════════════════════════════════════════════════════════════════
//  ══ MODULE 3: ASIA RANGE SWEEP ══
//  Logic: track Asia session high/low, detect sweep by London/NY, signal on reversal
// ══════════════════════════════════════════════════════════════════════════════
var float asiaHigh      = na
var float asiaLow       = na
var bool  asiaBuildDone = false   // true once Asia session ends and range is locked
var int   asiaSweepDir  = 0
var float asiaSweepH    = na
var float asiaSweepL    = na
var bool  asiaConfirmed = false
var int   asiaSignalBar = na
var line  asiaLine      = na
var line  asiaTick      = na
var label asiaLbl       = na

// Build Asia range during Asia hours; lock it when Asia closes
if inAsiaSess
    asiaHigh      := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow       := na(asiaLow)  ? low  : math.min(asiaLow,  low)
    asiaBuildDone := false

if not inAsiaSess and not asiaBuildDone and not na(asiaHigh)
    asiaBuildDone := true  // range now locked for London/NY to sweep
    asiaSweepDir  := 0
    asiaConfirmed := false

// Reset Asia range each new Asia session
if inAsiaSess and not inAsiaSess[1]
    asiaHigh      := na
    asiaLow       := na
    asiaBuildDone := false
    asiaSweepDir  := 0
    asiaConfirmed := false
    asiaActive    := "—"
    f_delLine(asiaLine)
    f_delLine(asiaTick)
    f_delLabel(asiaLbl)

// Expiry
if not na(asiaSignalBar) and (bar_index - asiaSignalBar) >= asiaExpiry
    f_delLine(asiaLine)
    f_delLine(asiaTick)
    f_delLabel(asiaLbl)
    asiaSignalBar := na
    asiaActive    := "—"

if useAsia and asiaBuildDone and not asiaConfirmed and not na(asiaHigh)
    // Sweep of Asia high: wick above, close back below — bearish
    isAsiaHighSweep = high > asiaHigh and close < asiaHigh and close < open
    // Sweep of Asia low: wick below, close back above — bullish
    isAsiaLowSweep  = low  < asiaLow  and close > asiaLow  and close > open

    if isAsiaHighSweep
        asiaSweepDir := 1
        asiaSweepH   := high
        asiaSweepL   := low

    if isAsiaLowSweep
        asiaSweepDir := 2
        asiaSweepH   := high
        asiaSweepL   := low

    // Sell: Asia high swept, next bar displaces down
    if asiaSweepDir == 1 and not isAsiaHighSweep and close < asiaHigh and close < open
        asiaConfirmed := true
        asiaCount := asiaCount + 1
        asiaSignalBar := bar_index
        entryPx        = close
        trend          = f_trendTag(false)
        kzTag          = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(asiaLine)
        f_delLine(asiaTick)
        f_delLabel(asiaLbl)
        asiaLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=asiaLineCol, width=2, style=line.style_solid)
        tickX    = bar_index + labelOffset
        tR       = (asiaHigh - asiaLow) * 0.012
        asiaTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=asiaLineCol, width=2)
        asiaLbl  := label.new(tickX, entryPx - tR,
             text=trend + " ▼ Asia Sweep Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(asiaLabelCol, 5), textcolor=color.white,
             style=label.style_label_upper_right, size=size.normal)

    // Buy: Asia low swept, next bar displaces up
    if asiaSweepDir == 2 and not isAsiaLowSweep and close > asiaLow and close > open
        asiaConfirmed := true
        asiaCount := asiaCount + 1
        asiaSignalBar := bar_index
        entryPx        = close
        trend          = f_trendTag(true)
        kzTag          = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(asiaLine)
        f_delLine(asiaTick)
        f_delLabel(asiaLbl)
        asiaLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=asiaLineCol, width=2, style=line.style_solid)
        tickX    = bar_index + labelOffset
        tR       = (asiaHigh - asiaLow) * 0.012
        asiaTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=asiaLineCol, width=2)
        asiaLbl  := label.new(tickX, entryPx + tR,
             text=trend + " ▲ Asia Sweep Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(asiaLabelCol, 5), textcolor=color.white,
             style=label.style_label_lower_right, size=size.normal)

if not na(asiaLine)
    line.set_x2(asiaLine, bar_index + extendBars)
if not na(asiaTick)
    line.set_x1(asiaTick, bar_index + labelOffset)
    line.set_x2(asiaTick, bar_index + labelOffset)
if not na(asiaLbl)
    label.set_x(asiaLbl, bar_index + labelOffset)

// ══════════════════════════════════════════════════════════════════════════════
//  ══ MODULE 4: ORB CRT ══
//  Logic: build opening range for first N minutes, detect false breakout + reversal
// ══════════════════════════════════════════════════════════════════════════════
var float orbHigh      = na
var float orbLow       = na
var bool  orbLocked    = false   // true once OR window closes
var int   orbSweepDir  = 0
var float orbSweepH    = na
var float orbSweepL    = na
var bool  orbConfirmed = false
var int   orbSignalBar = na
var line  orbLine      = na
var line  orbTick      = na
var label orbLbl       = na

// Is current bar inside the opening range window?
orbMinutes  = (currentHour * 60 + currentMin) - (orbOpenHr * 60)
inORBWindow = orbMinutes >= 0 and orbMinutes < orbMins

// Build ORB during the opening range window
if inORBWindow
    orbHigh   := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow    := na(orbLow)  ? low  : math.min(orbLow,  low)
    orbLocked := false

// Lock ORB once window closes
if not inORBWindow and not orbLocked and not na(orbHigh)
    orbLocked   := true
    orbSweepDir := 0
    orbConfirmed:= false

// Reset on new session (new day)
if isNewDay
    orbHigh      := na
    orbLow       := na
    orbLocked    := false
    orbSweepDir  := 0
    orbConfirmed := false
    orbActive    := "—"
    f_delLine(orbLine)
    f_delLine(orbTick)
    f_delLabel(orbLbl)

// Expiry
if not na(orbSignalBar) and (bar_index - orbSignalBar) >= orbExpiry
    f_delLine(orbLine)
    f_delLine(orbTick)
    f_delLabel(orbLbl)
    orbSignalBar := na
    orbActive    := "—"

if useORB and orbLocked and not orbConfirmed and not na(orbHigh)
    // False breakout above ORB high: wick above, close back inside, bearish
    isORBHighSweep = high > orbHigh and close < orbHigh and close < open
    // False breakout below ORB low: wick below, close back inside, bullish
    isORBLowSweep  = low  < orbLow  and close > orbLow  and close > open

    if isORBHighSweep
        orbSweepDir := 1
        orbSweepH   := high
        orbSweepL   := low

    if isORBLowSweep
        orbSweepDir := 2
        orbSweepH   := high
        orbSweepL   := low

    // Sell: ORB high false break confirmed
    if orbSweepDir == 1 and not isORBHighSweep and close < orbHigh and close < open
        orbConfirmed := true
        orbCount := orbCount + 1
        orbSignalBar := bar_index
        entryPx       = close
        trend         = f_trendTag(false)
        kzTag         = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(orbLine)
        f_delLine(orbTick)
        f_delLabel(orbLbl)
        orbLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=orbLineCol, width=2, style=line.style_solid)
        tickX   = bar_index + labelOffset
        tR      = (orbHigh - orbLow) * 0.012
        orbTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=orbLineCol, width=2)
        orbLbl  := label.new(tickX, entryPx - tR,
             text=trend + " ▼ ORB CRT Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(orbLabelCol, 5), textcolor=color.white,
             style=label.style_label_upper_right, size=size.normal)

    // Buy: ORB low false break confirmed
    if orbSweepDir == 2 and not isORBLowSweep and close > orbLow and close > open
        orbConfirmed := true
        orbCount := orbCount + 1
        orbSignalBar := bar_index
        entryPx       = close
        trend         = f_trendTag(true)
        kzTag         = inLondon ? " 🇬🇧" : inNY ? " 🗽" : ""
        f_delLine(orbLine)
        f_delLine(orbTick)
        f_delLabel(orbLbl)
        orbLine := line.new(bar_index, entryPx, bar_index + extendBars, entryPx,
             color=orbLineCol, width=2, style=line.style_solid)
        tickX   = bar_index + labelOffset
        tR      = (orbHigh - orbLow) * 0.012
        orbTick := line.new(tickX, entryPx + tR, tickX, entryPx - tR, color=orbLineCol, width=2)
        orbLbl  := label.new(tickX, entryPx + tR,
             text=trend + " ▲ ORB CRT Entry\n" + str.tostring(entryPx, format.mintick) + kzTag,
             color=color.new(orbLabelCol, 5), textcolor=color.white,
             style=label.style_label_lower_right, size=size.normal)

if not na(orbLine)
    line.set_x2(orbLine, bar_index + extendBars)
if not na(orbTick)
    line.set_x1(orbTick, bar_index + labelOffset)
    line.set_x2(orbTick, bar_index + labelOffset)
if not na(orbLbl)
    label.set_x(orbLbl, bar_index + labelOffset)

// ══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD HELPER  (must be top-level in Pine v5)
// ══════════════════════════════════════════════════════════════════════════════
f_row(tb, r, k, v, vc) =>
    table.cell(tb, 0, r, k,
         text_color=color.new(#ffffff, 20), text_size=size.small,
         bgcolor=color.new(#1a1a2e, 10))
    table.cell(tb, 1, r, v,
         text_color=vc, text_size=size.small,
         bgcolor=color.new(#1a1a2e, 10))

// ══════════════════════════════════════════════════════════════════════════════
//  ══ DASHBOARD ══  (bottom-left corner)
// ══════════════════════════════════════════════════════════════════════════════
var table dash = na

if showDash
    if na(dash)
        dash := table.new(position.bottom_left, 3, 6,
             bgcolor     = color.new(#1a1a2e, 10),
             border_color= color.new(#ffffff, 70),
             border_width = 1)

    // (f_row defined at top level)

    sessStr   = inLondon ? "🇬🇧 London" : inNY ? "🗽 NY" : inAsiaSess ? "🌏 Asia" : "Off Hours"
    trendStr  = dailyBull ? "▲ Bullish" : "▼ Bearish"
    trendCol  = dailyBull ? #00E676 : #FF1744
    totalSigs = crtCount + pdhlCount + asiaCount + orbCount
    volStr    = str.tostring(math.round(volume, 0))

    f_row(dash, 0, "Session",    sessStr,                        #90CAF9)
    f_row(dash, 1, "Daily Bias", trendStr,                       trendCol)
    f_row(dash, 2, "Volume",     volStr,                         #FFD600)
    f_row(dash, 3, "CRT Signals",str.tostring(crtCount),         entryLineCol)
    f_row(dash, 4, "PDH/PDL",   str.tostring(pdhlCount),         pdhlLabelCol)
    f_row(dash, 5, "Total Today",str.tostring(totalSigs),        #ffffff)

    // ── 3rd column: Active signals only (clears when signal expires) ──
    table.cell(dash, 2, 0, "Active Now",
         text_color=#FFD600, text_size=size.small,
         bgcolor=color.new(#1a1a2e, 10))
    table.cell(dash, 2, 1, activeCRT,
         text_color=activeCRT  != "—" ? #FF9800 : color.new(#ffffff, 60),
         text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dash, 2, 2, activePDHL,
         text_color=activePDHL != "—" ? #E91E63 : color.new(#ffffff, 60),
         text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dash, 2, 3, asiaActive,
         text_color=asiaActive != "—" ? #00BFA5 : color.new(#ffffff, 60),
         text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dash, 2, 4, orbActive,
         text_color=orbActive  != "—" ? #FF6F00 : color.new(#ffffff, 60),
         text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))
    table.cell(dash, 2, 5, "—",
         text_color=color.new(#ffffff, 60),
         text_size=size.tiny, bgcolor=color.new(#1a1a2e, 10))

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(confirmed and not confirmed[1],
     title="CRT Entry Signal", message="⚡ CRT Entry on {{ticker}} — {{interval}}")
alertcondition(pdhlConfirmed and not pdhlConfirmed[1],
     title="PDH/PDL Entry Signal", message="⚡ PDH/PDL Sweep Entry on {{ticker}} — {{interval}}")
alertcondition(asiaConfirmed and not asiaConfirmed[1],
     title="Asia Sweep Entry Signal", message="⚡ Asia Range Sweep Entry on {{ticker}} — {{interval}}")
alertcondition(orbConfirmed and not orbConfirmed[1],
     title="ORB CRT Entry Signal", message="⚡ ORB False Breakout Entry on {{ticker}} — {{interval}}")
alertcondition((confirmed and not confirmed[1]) or (pdhlConfirmed and not pdhlConfirmed[1]) or (asiaConfirmed and not asiaConfirmed[1]) or (orbConfirmed and not orbConfirmed[1]),
     title="Any CRT Signal", message="⚡ CRT Signal on {{ticker}} — check chart for entry details.")
````
