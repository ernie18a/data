# Fib 1-2-3-4 Vol/Delta/Proj

- url: https://www.tradingview.com/script/DGg7sSti-Fib-1-2-3-4-Vol-Delta-Proj/
- type: indicator
- pine_id: PUB;49793f7ad56748289304070ffa4ed60a
- version: 1.0

## Description

Overview
This indicator automates a practical Fib 1–2–3–4 workflow on the chart: fractal-style swings define point 1 and point 2, retracements mark the discount/premium zone, and negative extensions mark take-profit style targets. It is built for fast markets (e.g. MNQ / NQ) but works on any symbol the chart supports.

Purpose
The goal is to keep the chart readable while still showing:

Where the active leg is (swing line + optional zone fill)
Key retracements (defaults favor 61.8%–88.6%; extras optional)
Extension levels (e.g. −12.7% / −27.2% / −61.8% style targets — toggles available)
Stop reference beyond point 1 (optional plot + buffer in ticks)
Optional BUY / SELL markers driven by a zone reclaim rule, plus matching alerts
Fib levels are treated as framework for stops and limits; entries are a heuristic (reclaim), not a guarantee.

Structure timeframe (2-minute friendly)
Swing & fib timeframe lets you anchor pivots and fib math to a chosen TF (default 2). On a 1m chart with structure set to 2, swings come from 2m while signals still use the chart’s closes for timing. When structure TF ≠ chart, built-in volume profile / delta / projection blocks stay off so bar math stays honest.

Zeiierman-style add-ons (optional, CC BY-NC-SA)
If enabled, optional Fib volume profile, Fib-band delta, and projection segments are adapted from Zeiierman’s published concept — non-commercial use only for those portions; see script header for license note.

Main features

Fractal pivots — configurable left/right bars (Fractals-style lag).
Clean preset — fewer lines; zone fill; optional swing leg.
Entry zone — configurable deep/shallow bounds (default 78.6%–88.6% style band).
BUY / SELL — label shapes + alerts on zone reclaim (deep touch + confirmed close through shallow edge); cooldown to reduce noise.
Optional mapping — swing labels, zone edge plots, fractal marks (mostly off by default).
Compact table — optional snapshot of bias, points, stop, targets.
How to use

Set Swing & fib timeframe to Chart on a 2m chart, or keep 2 on 1m for 2m legs with 1m entries.
Tune Left / Right bars to match how “noisy” you want swings.
Turn on Show targets / Show stop when you want full framework on chart.
Create alerts from the indicator’s Alerts tab (BUY / SELL, optional zone/extensions).
Disclaimer
This tool is for education and research only. It is not financial advice. Past behavior of any heuristic does not predict future results. You are responsible for your own risk, sizing, and compliance with your jurisdiction.

If your published script has a different name or you want this shorter (TradingView sometimes truncates), say the exact title and I’ll compress it to one tight block.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Fib 1–2–3–4: fractal swings → retracements + extensions. Default swing/fib TF = 2m (change in settings or use Chart = current TF).
// Entries/exits use this chart’s closes; if chart is 1m and structure is 2m, pivots come from 2m (no lookahead).
//
// Volume profile, Fib-band volume delta, and projection segments: adapted from
// "Fibonacci Projection with Volume & Delta Profile (Zeiierman)" © Zeiierman,
// licensed under CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/).
// Those portions are for non-commercial use; share alike if you modify and redistribute them.

//@version=6
indicator("Fib 1-2-3-4 · Clean + Vol/Delta/Proj", shorttitle="Fib 1234+", overlay=true, max_bars_back=5000, max_lines_count=300, max_boxes_count=500, max_labels_count=100)

// ── Groups ───────────────────────────────────────────────────────────────────
const string G_SWING = "Swing (Fractal)"
const string G_LEVELS = "Fib levels"
const string G_ZONE = "Entry zone"
const string G_RISK = "Risk / validity"
const string G_VIS = "Visuals"
const string G_ALR = "Alerts"
const string G_ZEI = "Zeiierman-style (CC BY-NC-SA)"
const string G_ZVIP = "Z · Fib volume profile"
const string G_ZDEL = "Z · Fib delta profile"
const string G_ZPRJ = "Z · Projection"
const string G_MAP = "Chart mapping"
const string G_SIG = "Buy / sell signals"

structMode = input.string("2", "Swing & fib timeframe", options=["Chart", "2", "3", "5", "15", "60"], group=G_SWING, tooltip="Pivots, fibs, zone, BUY/SELL use this timeframe. Chart = match open chart (e.g. set chart to 2m). Pick 2 on a 1m chart for 2m legs with 1m entry timing.")
leftBars  = input.int(2, "Left bars", minval=1, maxval=20, group=G_SWING, tooltip="Fractal half-width on the structure timeframe (2+2 ≈ Fractals-2 on 2m).")
rightBars = input.int(2, "Right bars", minval=1, maxval=20, group=G_SWING)

cleanPreset = input.bool(true, "Clean preset (recommended)", group=G_VIS, tooltip="Fewer lines, swing leg only, soft zone fill.")
showSwing   = input.bool(true, "Draw swing leg (1 → 2)", group=G_VIS)
showExtras  = input.bool(false, "Show extra retracements (23.6 / 38.2 / 50)", group=G_VIS, tooltip="Off in clean preset; turn on for full grid.")
showExt     = input.bool(false, "Show targets (ext 1–3)", group=G_VIS)
showStopLn  = input.bool(false, "Show stop level", group=G_VIS)
showDash    = input.bool(false, "Compact stats table", group=G_VIS)
showLabs    = input.bool(false, "Price labels on right (SL / targets)", group=G_VIS)

r236 = input.bool(false, "23.6%", group=G_LEVELS)
r382 = input.bool(false, "38.2%", group=G_LEVELS)
r500 = input.bool(false, "50%", group=G_LEVELS)
r618 = input.bool(true, "61.8%", group=G_LEVELS)
r786 = input.bool(true, "78.6%", group=G_LEVELS)
r886 = input.bool(true, "88.6%", group=G_LEVELS)

extA = input.float(0.127, "Extension 1 (~−12.7%)", minval=0.0, step=0.001, group=G_LEVELS)
extB = input.float(0.272, "Extension 2 (~−27.2%)", minval=0.0, step=0.001, group=G_LEVELS)
extC = input.float(0.618, "Extension 3 (~−61.8%)", minval=0.0, step=0.001, group=G_LEVELS)

useZoneFill = input.bool(true, "Fill 78.6–88.6 zone", group=G_ZONE)
zoneTop = input.float(0.886, "Zone — deeper bound", minval=0.0, maxval=1.0, step=0.001, group=G_ZONE)
zoneBot = input.float(0.786, "Zone — shallower bound", minval=0.0, maxval=1.0, step=0.001, group=G_ZONE)

tickBuf  = input.int(1, "Stop buffer (ticks past point 1)", minval=0, maxval=50, group=G_RISK, tooltip="MNQ: 1 tick = 0.25.")
mustHold = input.bool(true, "Hide setup if point 1 violated (close)", group=G_RISK)

alZone = input.bool(false, "Alert: entry zone (first bar)", group=G_ALR)
alT1   = input.bool(false, "Alert: ext 1", group=G_ALR)
alT2   = input.bool(false, "Alert: ext 2", group=G_ALR)
alT3   = input.bool(false, "Alert: ext 3 (LIMIT)", group=G_ALR)

showAnchorLabels = input.bool(false, "Labels at swing 1 & 2", group=G_MAP, tooltip="Optional; can clutter. Anchors still drive logic.")
showZoneEdges = input.bool(false, "Plot zone boundary lines", group=G_MAP)
showPivotMarks = input.bool(false, "Mark fractal pivot prints", group=G_MAP)

signalsEnabled = input.bool(true, "Buy/sell signals (logic + alerts)", group=G_SIG, tooltip="Zone reclaim: deep touch then confirmed close through shallow edge. Heuristic only; pivots lag Right bars.")
showBuySellLabels = input.bool(true, "BUY / SELL labels on chart", group=G_SIG, tooltip="Label shapes at signal bars. Turn off for alerts-only.")
reclaimLookback = input.int(10, "Deep touch lookback (bars)", minval=3, maxval=80, group=G_SIG, tooltip="Bars on this chart (not the structure TF). On 1m + 2m structure, 10 ≈ 10 minutes.")
signalCooldown = input.int(8, "Min bars between signals", minval=2, maxval=50, group=G_SIG)
colBuyShape = input.color(color.new(#26a69a, 0), "Marker: buy", group=G_SIG)
colSellShape = input.color(color.new(#ef5350, 0), "Marker: sell", group=G_SIG)

alBuy = input.bool(true, "Alert: BUY (reclaim)", group=G_ALR)
alSell = input.bool(true, "Alert: SELL (reclaim)", group=G_ALR)

// ── Zeiierman-style (optional; default off — enable per group) ───────────────
showZeiSwingHL = input.bool(false, "Swing H/L guide lines (horizontal)", group=G_ZEI, tooltip="Extends last swing high & low to current bar (Zeiierman-style guides).")
showFibProfile = input.bool(false, "Enable Fib volume profile", group=G_ZVIP, tooltip="Volume histogram between last swing high and low (within leg).")
zeiRows = input.int(10, "Profile rows", minval=2, maxval=100, group=G_ZVIP)
flipOrder = input.bool(false, "Flip bull/bear side", group=G_ZVIP)
bull_color = input.color(color.new(color.teal, 30), "Bull vol", group=G_ZVIP)
bear_color = input.color(color.new(color.orange, 30), "Bear vol", group=G_ZVIP)

showFibDelta = input.bool(false, "Enable Fib delta profile", group=G_ZDEL, tooltip="Per-band up vs down volume between Fib prices.")
deltaMaxWidth = input.int(30, "Delta max width (bars)", minval=5, maxval=200, group=G_ZDEL)
deltaBullColor = input.color(color.new(color.lime, 80), "Bullish delta", group=G_ZDEL)
deltaBearColor = input.color(color.new(color.red, 80), "Bearish delta", group=G_ZDEL)

showProjection = input.bool(false, "Enable projection paths", group=G_ZPRJ, tooltip="Projected swing segments + boxes (Zeiierman logic on this leg).")
zeiProjLvl = input.float(0.618, "Projection fib ratio", options=[0.236, 0.382, 0.5, 0.618, 0.786], group=G_ZPRJ)
projLineBullColor = input.color(color.new(color.green, 0), "Bull proj line", group=G_ZPRJ)
projLineBearColor = input.color(color.new(color.red, 0), "Bear proj line", group=G_ZPRJ)
projLineWidth = input.int(2, "Proj line width", 1, 5, group=G_ZPRJ)
projLineStyleStr = input.string("Arrow Right", "Proj line style", options=["Solid", "Dashed", "Dotted", "Arrow Left", "Arrow Right"], group=G_ZPRJ)
projPercBullColor = input.color(color.new(color.green, 0), "Bull label bg", group=G_ZPRJ)
projPercBearColor = input.color(color.new(color.red, 0), "Bear label bg", group=G_ZPRJ)
projPercTextColor = input.color(color.white, "Proj label text", group=G_ZPRJ)
projBoxBgOn = input.bool(true, "Projection box fill", group=G_ZPRJ)
projBoxBgColor = input.color(color.new(color.blue, 80), "Box bg", group=G_ZPRJ)
projBoxBorderOn = input.bool(true, "Box border", group=G_ZPRJ)
projBoxBorderCol = input.color(color.new(color.white, 0), "Box border col", group=G_ZPRJ)
projBoxBorderW = input.int(1, "Box border width", 1, 5, group=G_ZPRJ)
projBoxTextColor = input.color(color.white, "Box text", group=G_ZPRJ)
projBoxTextSizeStr = input.string("Small", "Box text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_ZPRJ)

// Clean preset hides shallow retracements unless "Show extra retracements" is on.
showMinorRet = showExtras or not cleanPreset
r236on = showMinorRet and r236
r382on = showMinorRet and r382
r500on = showMinorRet and r500
r618on = r618
r786on = r786
r886on = r886

projLineStyle =
     projLineStyleStr == "Solid" ? line.style_solid :
     projLineStyleStr == "Dashed" ? line.style_dashed :
     projLineStyleStr == "Dotted" ? line.style_dotted :
     projLineStyleStr == "Arrow Left" ? line.style_arrow_left :
     line.style_arrow_right

projBoxTextSize =
     projBoxTextSizeStr == "Tiny" ? size.tiny :
     projBoxTextSizeStr == "Small" ? size.small :
     projBoxTextSizeStr == "Large" ? size.large :
     projBoxTextSizeStr == "Huge" ? size.huge :
     size.normal

// ── Zeiierman drawing stores ─────────────────────────────────────────────────
var line hiLine = na
var line loLine = na
var array<line> forecastLines = array.new_line()
var array<box> areas = array.new_box()
var array<label> perc = array.new_label()
var array<box> fibProfileBoxes = array.new_box()
var array<box> fibDeltaBoxes = array.new_box()

// ── Fractal pivots (on structure TF; may differ from chart via request.security) ──
string structTF = structMode == "Chart" ? timeframe.period : structMode
bool useHTF = timeframe.in_seconds(structTF) != timeframe.in_seconds(timeframe.period)

pl = useHTF ? request.security(syminfo.tickerid, structTF, ta.pivotlow(low, leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off) : ta.pivotlow(low, leftBars, rightBars)
ph = useHTF ? request.security(syminfo.tickerid, structTF, ta.pivothigh(high, leftBars, rightBars), barmerge.gaps_off, barmerge.lookahead_off) : ta.pivothigh(high, leftBars, rightBars)

var float lastLow = na
var float lastHigh = na
var int lastLowBar = na
var int lastHighBar = na

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - rightBars

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - rightBars

bool bullStruct = not na(lastLow) and not na(lastHigh) and lastLowBar < lastHighBar and lastLow < lastHigh
bool bearStruct = not na(lastLow) and not na(lastHigh) and lastHighBar < lastLowBar and lastHigh > lastLow

float buf = tickBuf * syminfo.mintick

bool bullValid = bullStruct and (not mustHold or close >= lastLow - buf)
bool bearValid = bearStruct and (not mustHold or close <= lastHigh + buf)

bool bull = bullValid
bool bear = bearValid and not bull

float L = bull ? lastLow : bear ? lastLow : na
float H = bull ? lastHigh : bear ? lastHigh : na
float R = (bull or bear) and not na(L) and not na(H) ? H - L : na

// Map leg to Zeiierman-style names (always hi = swing high, lo = swing low of the leg)
float hiPrice = (bull or bear) ? H : na
float loPrice = (bull or bear) ? L : na
int hiBar = (bull or bear) ? lastHighBar : na
int loBar = (bull or bear) ? lastLowBar : na

fibRet(float r, float _R, float _H, float _L, bool _bull, bool _bear) =>
    if na(_R)
        na
    else if _bull
        _H - r * _R
    else if _bear
        _L + r * _R
    else
        na

fibExtUp(float r, float _R, float _H) =>
    na(_R) ? na : _H + r * _R

fibExtDn(float r, float _R, float _L) =>
    na(_R) ? na : _L - r * _R

// Zeiierman fib level: `last` true → anchor at high (retrace down), false → anchor at low (retrace up)
fibbFunc(float v, bool last, float h, float l) =>
    last ? h - (h - l) * v : l + (h - l) * v

zei_cleaner_line(array<line> a, int idx) =>
    if idx >= 0 and idx < array.size(a)
        el = array.get(a, idx)
        if not na(el)
            line.delete(el)
        array.remove(a, idx)

zei_cleaner_box(array<box> a, int idx) =>
    if idx >= 0 and idx < array.size(a)
        el = array.get(a, idx)
        if not na(el)
            box.delete(el)
        array.remove(a, idx)

zei_cleaner_label(array<label> a, int idx) =>
    if idx >= 0 and idx < array.size(a)
        el = array.get(a, idx)
        if not na(el)
            label.delete(el)
        array.remove(a, idx)

float f236 = fibRet(0.236, R, H, L, bull, bear)
float f382 = fibRet(0.382, R, H, L, bull, bear)
float f500 = fibRet(0.500, R, H, L, bull, bear)
float f618 = fibRet(0.618, R, H, L, bull, bear)
float f786 = fibRet(0.786, R, H, L, bull, bear)
float f886 = fibRet(0.886, R, H, L, bull, bear)

float e1 = bull ? fibExtUp(extA, R, H) : bear ? fibExtDn(extA, R, L) : na
float e2 = bull ? fibExtUp(extB, R, H) : bear ? fibExtDn(extB, R, L) : na
float e3 = bull ? fibExtUp(extC, R, H) : bear ? fibExtDn(extC, R, L) : na

float stopLvl = bull ? lastLow - buf : bear ? lastHigh + buf : na

float zDeep = na
float zShallow = na
if bull and not na(R)
    zDeep := H - math.max(zoneTop, zoneBot) * R
    zShallow := H - math.min(zoneTop, zoneBot) * R
else if bear and not na(R)
    zDeep := L + math.max(zoneTop, zoneBot) * R
    zShallow := L + math.min(zoneTop, zoneBot) * R

bool inZone = (bull or bear) and not na(zDeep) and not na(zShallow) and low <= zShallow and high >= zDeep
bool newZoneTouch = inZone and not inZone[1]

// ── Buy / sell heuristics (confirmed bar) ───────────────────────────────────
float lowestLB = ta.lowest(low, reclaimLookback)
float highestLB = ta.highest(high, reclaimLookback)
bool crossUpShallow = ta.crossover(close, zShallow)
bool crossDnShallow = ta.crossunder(close, zShallow)

touchedDeepLong = bull and not na(zDeep) and lowestLB <= zDeep
touchedDeepShort = bear and not na(zDeep) and highestLB >= zDeep

reclaimBuy = signalsEnabled and bull and not na(zShallow) and barstate.isconfirmed and crossUpShallow and touchedDeepLong
reclaimSell = signalsEnabled and bear and not na(zShallow) and barstate.isconfirmed and crossDnShallow and touchedDeepShort

rawBuy = reclaimBuy
rawSell = reclaimSell

var int lastSigBar = -100000000
bool buySig = rawBuy and bar_index - lastSigBar >= signalCooldown
bool sellSig = rawSell and bar_index - lastSigBar >= signalCooldown
if buySig or sellSig
    lastSigBar := bar_index

// ── Muted palette ───────────────────────────────────────────────────────────
colRetMinor = color.new(#787b86, 35)
colRetMain  = color.new(#5d606b, 15)
colExt      = color.new(#7e57c2, 45)
colExtLim   = color.new(#7e57c2, 25)
colStop     = color.new(#ef5350, 55)
colLeg      = color.new(chart.fg_color, 45)
colFillBull = color.new(#26a69a, 92)
colFillBear = color.new(#ef5350, 92)
hiLineColor = color.new(color.red, 0)
loLineColor = color.new(color.green, 0)

// Hidden plots for zone fill (must stay in scope for fill())
pZ1 = plot(useZoneFill and (bull or bear) ? zDeep : na, "z deep", display=display.none)
pZ2 = plot(useZoneFill and (bull or bear) ? zShallow : na, "z shallow", display=display.none)
fill(pZ1, pZ2, cleanPreset ? (bull ? colFillBull : colFillBear) : color.new(bull ? color.teal : color.red, 94), title="Zone")

// Retracements (thin)
plot(r236on and (bull or bear) ? f236 : na, "23.6%", colRetMinor, 1)
plot(r382on and (bull or bear) ? f382 : na, "38.2%", colRetMinor, 1)
plot(r500on and (bull or bear) ? f500 : na, "50%", colRetMinor, 1)
plot(r618on and (bull or bear) ? f618 : na, "61.8%", colRetMain, 1)
plot(r786on and (bull or bear) ? f786 : na, "78.6%", colRetMain, 2)
plot(r886on and (bull or bear) ? f886 : na, "88.6%", colRetMain, 1)

plot(showExt and bull ? e1 : showExt and bear ? e1 : na, "T1", colExt, 1)
plot(showExt and bull ? e2 : showExt and bear ? e2 : na, "T2", colExt, 1)
plot(showExt and bull ? e3 : showExt and bear ? e3 : na, "T3 LIMIT", colExtLim, 2)

plot(showStopLn and (bull or bear) ? stopLvl : na, "Stop", colStop, 1, plot.style_linebr)

plot(showZoneEdges and (bull or bear) ? zDeep : na, "Zone deep edge", color.new(color.teal, 40), 1, plot.style_linebr)
plot(showZoneEdges and (bull or bear) ? zShallow : na, "Zone shallow edge", color.new(color.teal, 65), 1, plot.style_linebr)

plotshape(showPivotMarks and not na(pl), title="Fractal L", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 30), size=size.tiny, offset=-rightBars)
plotshape(showPivotMarks and not na(ph), title="Fractal H", style=shape.triangledown, location=location.abovebar, color=color.new(color.orange, 30), size=size.tiny, offset=-rightBars)

plotshape(showBuySellLabels and buySig, title="Buy", style=shape.labelup, location=location.belowbar, color=colBuyShape, text="BUY", textcolor=color.white, size=size.small)
plotshape(showBuySellLabels and sellSig, title="Sell", style=shape.labeldown, location=location.abovebar, color=colSellShape, text="SELL", textcolor=color.white, size=size.small)

// ── Single swing leg ────────────────────────────────────────────────────────
var line lnLeg = na

if barstate.islast and showSwing
    if not na(lnLeg)
        line.delete(lnLeg)
        lnLeg := na
    if bull
        lnLeg := line.new(lastLowBar, lastLow, lastHighBar, lastHigh, xloc=xloc.bar_index, color=colLeg, width=2, style=line.style_solid)
    else if bear
        lnLeg := line.new(lastHighBar, lastHigh, lastLowBar, lastLow, xloc=xloc.bar_index, color=colLeg, width=2, style=line.style_solid)

// ── Zeiierman-style: swing guides + profile + delta + projection ───────────
lvls = array.from(0.236, 0.382, 0.5, 0.618, 0.786)

HB = not na(hiBar) ? bar_index - hiBar : na
LB = not na(loBar) ? bar_index - loBar : na

bool zeiLegOk = (bull or bear) and not na(hiPrice) and not na(loPrice) and not na(hiBar) and not na(loBar) and hiBar != loBar and not na(HB) and not na(LB)

if zeiLegOk
    if showZeiSwingHL
        if na(hiLine)
            hiLine := line.new(hiBar, hiPrice, bar_index, hiPrice, color=hiLineColor, width=2)
        else
            line.set_xy1(hiLine, hiBar, hiPrice)
            line.set_xy2(hiLine, bar_index, hiPrice)
            line.set_color(hiLine, hiLineColor)
        if na(loLine)
            loLine := line.new(loBar, loPrice, bar_index, loPrice, color=loLineColor, width=2)
        else
            line.set_xy1(loLine, loBar, loPrice)
            line.set_xy2(loLine, bar_index, loPrice)
            line.set_color(loLine, loLineColor)
    else
        if not na(hiLine)
            line.delete(hiLine)
            hiLine := na
        if not na(loLine)
            line.delete(loLine)
            loLine := na

    bars = math.abs(HB - LB)
    bool highRecent = HB < LB

    // ── Projection (forecast lines, boxes, % labels) ─────────────────────────
    if showProjection and not useHTF
        for i = array.size(forecastLines) - 1 to 0
            zei_cleaner_line(forecastLines, i)
        for i = array.size(areas) - 1 to 0
            zei_cleaner_box(areas, i)
        for i = array.size(perc) - 1 to 0
            zei_cleaner_label(perc, i)

        float fibb = fibbFunc(zeiProjLvl, LB > HB, hiPrice, loPrice)
        float fibb2 = LB < HB ? fibbFunc(zeiProjLvl, true, fibb, loPrice) : fibbFunc(zeiProjLvl, false, hiPrice, fibb)
        float trendfibb = LB > HB ? fibbFunc(1.272, true, hiPrice, loPrice) : fibbFunc(1.272, false, hiPrice, loPrice)

        forecast = array.from(HB < LB ? hiPrice : loPrice, fibb, fibb2, trendfibb)
        int fcN = array.size(forecast)
        int segment = int(math.min(bars, math.floor(500.0 / 4.0)))
        int future = bar_index

        for i = 0 to fcN - 2
            int x1 = int(math.min(future, bar_index + 500))
            int x2 = int(math.min(future + segment, bar_index + 500))
            float y1 = array.get(forecast, i)
            float y2 = array.get(forecast, i + 1)

            line lnForecast = line.new(x1, y1, x2, y2, color=y1 < y2 ? projLineBullColor : projLineBearColor, width=projLineWidth, style=projLineStyle)
            array.push(forecastLines, lnForecast)

            int midBoxLeft = x2 - int(math.round((x1 - x2) / 4.0))
            int midBoxRight = x2 + int(math.round((x1 - x2) / 4.0))
            float boxHeight = math.abs(y1 - y2) / 10.0

            string txtLevel = i == fcN - 2 ? "1.272" : str.tostring(zeiProjLvl * 100, "#.##")
            color boxBg = projBoxBgOn ? projBoxBgColor : color.new(projBoxBgColor, 100)
            color boxBord = projBoxBorderOn ? projBoxBorderCol : color.new(projBoxBorderCol, 100)

            box bx = box.new(midBoxLeft, y2 + boxHeight, midBoxRight, y2 - boxHeight, bgcolor=boxBg, border_color=boxBord, border_style=line.style_solid, border_width=projBoxBorderW, text=txtLevel, text_halign="center", text_valign="center", text_color=projBoxTextColor, text_size=projBoxTextSize)
            array.push(areas, bx)

            float change = (y2 - y1) / y1
            int midX = int(math.avg(x1, x2))
            float midY = line.get_price(lnForecast, midX)

            label lb = label.new(midX, midY, str.tostring(change * 100, format.percent), color=change > 0 ? projPercBullColor : projPercBearColor, style=i == 1 ? label.style_label_lower_right : label.style_label_lower_left, textcolor=projPercTextColor, size=size.small)
            array.push(perc, lb)
            future += segment
    else
        for i = array.size(forecastLines) - 1 to 0
            zei_cleaner_line(forecastLines, i)
        for i = array.size(areas) - 1 to 0
            zei_cleaner_box(areas, i)
        for i = array.size(perc) - 1 to 0
            zei_cleaner_label(perc, i)

    // ── Fib volume profile ─────────────────────────────────────────────────
    if showFibProfile and not useHTF
        for i = array.size(fibProfileBoxes) - 1 to 0
            zei_cleaner_box(fibProfileBoxes, i)

        float top = math.max(hiPrice, loPrice)
        float bottom = math.min(hiPrice, loPrice)

        if top != bottom
            float step = (top - bottom) / zeiRows
            levels = array.new_float()
            for ri = 0 to zeiRows
                array.push(levels, bottom + step * ri)

            volUp = array.new_float(zeiRows, 0.0)
            volDn = array.new_float(zeiRows, 0.0)

            int startBar = int(math.min(hiBar, loBar))
            int endBar = int(math.max(hiBar, loBar))

            for bi = startBar to endBar
                int offset = bar_index - bi
                if offset >= 0
                    float price = hlc3[offset]
                    float vol = volume[offset]
                    bool vBull = close[offset] > open[offset]
                    for r = 0 to zeiRows - 1
                        float dn = array.get(levels, r)
                        float up = array.get(levels, r + 1)
                        if price >= dn and price < up
                            if vBull
                                array.set(volUp, r, array.get(volUp, r) + vol)
                            else
                                array.set(volDn, r, array.get(volDn, r) + vol)
                            break

            float maxTot = 0.0
            for r = 0 to zeiRows - 1
                float tot = array.get(volUp, r) + array.get(volDn, r)
                maxTot := math.max(maxTot, tot)

            int span = endBar - startBar + 1

            if maxTot > 0
                int gradMax = math.max(zeiRows - 1, 1)
                for r = 0 to zeiRows - 1
                    float upVol = array.get(volUp, r)
                    float dnVol = array.get(volDn, r)

                    int normUp = upVol == 0 ? 0 : int((upVol / maxTot) * span)
                    int normDn = dnVol == 0 ? 0 : int((dnVol / maxTot) * span)

                    color bullRowCol = color.from_gradient(r, 0, gradMax, color.new(bull_color, 80), color.new(bull_color, 10))
                    color bearRowCol = color.from_gradient(r, 0, gradMax, color.new(bear_color, 80), color.new(bear_color, 10))

                    float yTop = array.get(levels, r + 1)
                    float yBottom = array.get(levels, r)

                    int leftBull = flipOrder ? startBar : startBar + normDn
                    int rightBull = flipOrder ? startBar + normUp : startBar + normDn + normUp

                    int leftBear = flipOrder ? startBar + normUp : startBar
                    int rightBear = flipOrder ? startBar + normUp + normDn : startBar + normDn

                    if normUp > 0
                        box bBull = box.new(leftBull, yTop, rightBull, yBottom, bgcolor=bullRowCol, border_color=color.new(bullRowCol, 0), border_style=line.style_dotted)
                        array.push(fibProfileBoxes, bBull)

                    if normDn > 0
                        box bBear = box.new(leftBear, yTop, rightBear, yBottom, bgcolor=bearRowCol, border_color=color.new(bearRowCol, 0), border_style=line.style_dotted)
                        array.push(fibProfileBoxes, bBear)
    else
        for i = array.size(fibProfileBoxes) - 1 to 0
            zei_cleaner_box(fibProfileBoxes, i)

    // ── Fib delta profile ───────────────────────────────────────────────────
    if showFibDelta and not useHTF
        for i = array.size(fibDeltaBoxes) - 1 to 0
            zei_cleaner_box(fibDeltaBoxes, i)

        fibPrices = array.new_float()
        array.push(fibPrices, hiPrice)
        for e in lvls
            float lvlPrice = fibbFunc(e, highRecent, hiPrice, loPrice)
            array.push(fibPrices, lvlPrice)
        array.push(fibPrices, loPrice)

        fibSorted = array.copy(fibPrices)
        array.sort(fibSorted)

        int bandsCount = array.size(fibSorted) - 1
        if bandsCount > 0
            bandBull = array.new_float(bandsCount, 0.0)
            bandBear = array.new_float(bandsCount, 0.0)

            int dStartBar = int(math.min(hiBar, loBar))
            int dEndBar = int(math.max(hiBar, loBar))

            for bi = dStartBar to dEndBar
                int offset = bar_index - bi
                if offset >= 0
                    float price = hlc3[offset]
                    float vol = volume[offset]
                    bool dBull = close[offset] > open[offset]
                    for b = 0 to bandsCount - 1
                        float bandLow = array.get(fibSorted, b)
                        float bandHigh = array.get(fibSorted, b + 1)
                        if price >= bandLow and price < bandHigh
                            if dBull
                                array.set(bandBull, b, array.get(bandBull, b) + vol)
                            else
                                array.set(bandBear, b, array.get(bandBear, b) + vol)
                            break

            float maxAbsDelta = 0.0
            for b = 0 to bandsCount - 1
                float delta = array.get(bandBull, b) - array.get(bandBear, b)
                maxAbsDelta := math.max(maxAbsDelta, math.abs(delta))

            if maxAbsDelta > 0
                int xStartBase = dStartBar
                for b = 0 to bandsCount - 1
                    float bandLow = array.get(fibSorted, b)
                    float bandHigh = array.get(fibSorted, b + 1)

                    float delta = array.get(bandBull, b) - array.get(bandBear, b)
                    if delta == 0
                        continue

                    float absDelta = math.abs(delta)
                    int widthBars = int((absDelta / maxAbsDelta) * deltaMaxWidth)
                    widthBars := math.max(widthBars, 1)

                    int xEnd = xStartBase
                    int xStart = xStartBase - widthBars
                    color col = delta >= 0 ? deltaBullColor : deltaBearColor

                    box dBox = box.new(xStart, bandHigh, xEnd, bandLow, bgcolor=col, border_color=color.new(col, 0), border_style=line.style_solid, text="Δ " + str.tostring(delta, format.volume), text_color=color.white, text_halign="center", text_valign="center")
                    array.push(fibDeltaBoxes, dBox)
    else
        for i = array.size(fibDeltaBoxes) - 1 to 0
            zei_cleaner_box(fibDeltaBoxes, i)
else
    // No valid leg: tear down Zeiierman drawings
    if not na(hiLine)
        line.delete(hiLine)
        hiLine := na
    if not na(loLine)
        line.delete(loLine)
        loLine := na
    for i = array.size(forecastLines) - 1 to 0
        zei_cleaner_line(forecastLines, i)
    for i = array.size(areas) - 1 to 0
        zei_cleaner_box(areas, i)
    for i = array.size(perc) - 1 to 0
        zei_cleaner_label(perc, i)
    for i = array.size(fibProfileBoxes) - 1 to 0
        zei_cleaner_box(fibProfileBoxes, i)
    for i = array.size(fibDeltaBoxes) - 1 to 0
        zei_cleaner_box(fibDeltaBoxes, i)

// ── Anchor labels (swing 1 & 2) ─────────────────────────────────────────────
var label labP1 = na
var label labP2 = na

if barstate.islast
    if not na(labP1)
        label.delete(labP1)
        labP1 := na
    if not na(labP2)
        label.delete(labP2)
        labP2 := na
    if showAnchorLabels and bull
        labP1 := label.new(lastLowBar, lastLow, "1 · " + str.tostring(lastLow, format.mintick), xloc=xloc.bar_index, style=label.style_label_up, color=color.new(color.green, 82), textcolor=color.white, size=size.tiny)
        labP2 := label.new(lastHighBar, lastHigh, "2 · " + str.tostring(lastHigh, format.mintick), xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.red, 82), textcolor=color.white, size=size.tiny)
    else if showAnchorLabels and bear
        labP1 := label.new(lastHighBar, lastHigh, "1 · " + str.tostring(lastHigh, format.mintick), xloc=xloc.bar_index, style=label.style_label_down, color=color.new(color.red, 82), textcolor=color.white, size=size.tiny)
        labP2 := label.new(lastLowBar, lastLow, "2 · " + str.tostring(lastLow, format.mintick), xloc=xloc.bar_index, style=label.style_label_up, color=color.new(color.green, 82), textcolor=color.white, size=size.tiny)

// ── Compact table ───────────────────────────────────────────────────────────
var table tb = table.new(position.bottom_right, 2, 8, border_width=1)

if barstate.islast and showDash
    table.clear(tb, 0, 0, 1, 7)
    table.cell(tb, 0, 0, "Fib 1234", text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 5))
    table.cell(tb, 1, 0, bull ? "Long" : bear ? "Short" : "—", text_size=size.small, text_color=color.white, bgcolor=bull ? color.new(#26a69a, 35) : bear ? color.new(#ef5350, 35) : color.new(color.gray, 50))

    table.cell(tb, 0, 1, "1", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    table.cell(tb, 1, 1, bull ? str.tostring(lastLow, format.mintick) : bear ? str.tostring(lastHigh, format.mintick) : "—", text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 2, "2", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    table.cell(tb, 1, 2, bull ? str.tostring(lastHigh, format.mintick) : bear ? str.tostring(lastLow, format.mintick) : "—", text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 3, "Stop", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    table.cell(tb, 1, 3, not na(stopLvl) ? str.tostring(stopLvl, format.mintick) : "—", text_size=size.small, text_color=color.new(#ef5350, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 4, "T1", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    table.cell(tb, 1, 4, not na(e1) ? str.tostring(e1, format.mintick) : "—", text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 5, "T2 / T3", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    string t23 = not na(e2) and not na(e3) ? str.tostring(e2, format.mintick) + " / " + str.tostring(e3, format.mintick) : "—"
    table.cell(tb, 1, 5, t23, text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 6, "Signals", text_size=size.small, text_color=color.new(chart.fg_color, 40), bgcolor=color.new(chart.bg_color, 0))
    string sigTxt = not signalsEnabled ? "Off" : "Reclaim"
    table.cell(tb, 1, 6, sigTxt, text_size=size.small, text_color=color.new(chart.fg_color, 0), bgcolor=color.new(chart.bg_color, 0))

    table.cell(tb, 0, 7, "Note", text_size=size.tiny, text_color=color.new(chart.fg_color, 55), bgcolor=color.new(chart.bg_color, 0))
    table.cell(tb, 1, 7, "Sigs=heuristic · Z=NC-SA", text_size=size.tiny, text_color=color.new(chart.fg_color, 45), bgcolor=color.new(chart.bg_color, 0))

// ── Optional right labels ─────────────────────────────────────────────────────
var label lbStop = na
var label lbT3 = na

if barstate.islast
    if not na(lbStop)
        label.delete(lbStop)
        lbStop := na
    if not na(lbT3)
        label.delete(lbT3)
        lbT3 := na

    if showLabs and not na(stopLvl)
        lbStop := label.new(bar_index, stopLvl, "SL " + str.tostring(stopLvl, format.mintick), style=label.style_label_left, color=color.new(color.red, 88), textcolor=color.new(chart.fg_color, 0), size=size.tiny)
    if showLabs and not na(e3)
        lbT3 := label.new(bar_index, e3, "LIM " + str.tostring(e3, format.mintick), style=label.style_label_left, color=color.new(#7e57c2, 85), textcolor=color.new(chart.fg_color, 0), size=size.tiny)

// ── Alerts ───────────────────────────────────────────────────────────────────
touchE1 = not na(e1) and ((low <= e1 and high >= e1) or (low <= e1[1] and high[1] >= e1[1]))
tapE1 = touchE1 and not touchE1[1]

touchE2 = not na(e2) and ((low <= e2 and high >= e2) or (low <= e2[1] and high[1] >= e2[1]))
tapE2 = touchE2 and not touchE2[1]

touchE3 = not na(e3) and ((low <= e3 and high >= e3) or (low <= e3[1] and high[1] >= e3[1]))
tapE3 = touchE3 and not touchE3[1]

alertcondition(alZone and newZoneTouch and (bull or bear), "Fib: entry zone (first bar)", "Fib 1234: first bar in retracement zone")
alertcondition(alT1 and tapE1, "Fib: T1", "Fib 1234: tapped extension 1")
alertcondition(alT2 and tapE2, "Fib: T2", "Fib 1234: tapped extension 2")
alertcondition(alT3 and tapE3, "Fib: LIMIT", "Fib 1234: tapped LIMIT")
alertcondition(alBuy and buySig, "Fib1234 BUY", "Fib1234 LONG — zone reclaim (confirmed bar). Not financial advice.")
alertcondition(alSell and sellSig, "Fib1234 SELL", "Fib1234 SHORT — zone reclaim (confirmed bar). Not financial advice.")
````
