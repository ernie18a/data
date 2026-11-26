#  AUTO TRENDLINE PRO

- url: https://www.tradingview.com/script/DKBPDNGj-AUTO-TRENDLINE-PRO/
- type: indicator
- pine_id: PUB;bdab11ec3c1747a5b3f007fe96998bf5
- version: 1.0

## Description

auto trendline pro

auto trendline pro is an automatic trendline indicator designed to display multiple degrees of market structure at the same time: live trendlines, confirmed trendlines, and higher timeframe trendlines.

the purpose of the tool is to help traders identify dynamic support and resistance lines, projected levels, confirmed breaks, and higher timeframe structure directly on the chart.

the indicator uses pivot points, wick or body anchors, atr-based validation, touch detection, duplicate filtering, forward projection, optional channels, and a dashboard for fast market reading.

it can be used for scalping, intraday trading, swing trading, and macro analysis depending on the selected settings.

---

inputs guide

degrees

live degree
enables live trendlines. this mode reacts faster to recent price action, but it can repaint because the pivots are still developing. it is useful for short-term market reading and early structure detection.

confirmed degree
enables confirmed trendlines. this mode is more stable because it uses confirmed pivots. it is recommended for cleaner analysis and more reliable structural levels.

htf degree
enables higher timeframe trendlines. this mode brings larger market structure into the current chart and helps identify major dynamic support and resistance levels.

anchor source
selects how the trendline anchors are calculated.
wick uses candle highs and lows.
body uses candle open and close extremes.
wick is more aggressive and reacts to full price extremes. body is cleaner and can reduce noise.

---

pivot strength

live pivot l/r
controls the strength of live pivots. a lower value creates more reactive trendlines. a higher value creates fewer but cleaner lines.

confirmed pivot l/r
controls the strength of confirmed pivots. a higher value makes the confirmed trendlines more selective and more structural.

htf pivot l/r
controls the pivot strength used on the higher timeframe. higher values create more macro-level lines.

---

htf source

htf timeframe
selects the higher timeframe used for htf trendlines. examples: 4h, 1d, 1w. higher timeframes provide stronger macro structure.

htf ath/atl window
defines the lookback window used to detect higher timeframe highs and lows. a larger value allows the indicator to anchor lines to more important historical extremes.

anchor htf line at ath / atl
allows htf lines to be anchored from the highest high or lowest low inside the selected htf window. this is useful for long-term trendlines and cycle analysis.

htf compute in log space
calculates htf trendlines using logarithmic logic. this is useful for assets with large percentage moves, such as crypto, because it gives a more balanced macro structure.

---

structure and validation

lines per side chart degrees
defines how many chart-degree lines are displayed per side. increasing this value shows more trendlines but can make the chart busier.

lines per side htf
defines how many higher timeframe lines are displayed per side. a lower value keeps the chart cleaner. a higher value gives more macro context.

new-anchor candidates
defines how many recent pivots are tested as possible new anchors. higher values test more combinations.

older-anchor window
defines how many older pivots can be used with a recent pivot to create a valid trendline.

min bars between anchors
defines the minimum distance between two trendline anchors. a low value creates shorter lines. a higher value creates more meaningful structural lines.

allowed pierces
defines how many times price is allowed to pierce a line during validation. zero means strict validation.

pierce tolerance atr
defines the atr-based tolerance used when checking if price has pierced a line. a lower value is stricter. a higher value allows more flexibility.

touch tolerance atr
defines the atr-based tolerance used to count touches on a trendline. a higher value detects more touches. a lower value keeps only precise touches.

dedupe distance atr
filters trendlines that are too close to each other. a higher value removes more duplicate lines.

max validation span
defines the maximum number of bars used when validating a trendline. this prevents the indicator from validating lines across an excessive historical distance.

---

channels, break and extension

show channels
enables channels around the dominant trendline. channels help visualize the reaction area around a trendline instead of focusing only on a single line.

break = n consecutive closes beyond
defines how many consecutive candle closes are required to confirm a break. a value of 1 is faster. a value of 2 or more is stricter.

forward projection bars
defines how far the trendlines are projected into the future.

infinite extension
extends the lines continuously to the right. this is useful when using trendlines as ongoing dynamic support and resistance.

---

display

price projection label
shows the projected price at the end of a trendline. this helps identify the current reaction level quickly.

show trendline labels
enables or disables labels on trendlines. keeping this off gives a cleaner chart.

strength rating
shows a visual strength rating based on the number of valid touches. more touches generally mean a more important line.

show dashboard
enables the dashboard. the dashboard summarizes confirmed support, confirmed resistance, htf support, htf resistance, htf extremes, and validation status.

dashboard position
selects the position of the dashboard on the chart.

---

aesthetics

support
sets the color of support trendlines.

resistance
sets the color of resistance trendlines.

htf glow / accent
sets the accent color used for higher timeframe emphasis.

broken
sets the color used when a trendline is broken.

atr length
defines the atr length used for tolerances, validation, touch detection, break detection, and duplicate filtering.

---

how to use the indicator

start by using confirmed degree and htf degree. these two modes give the cleanest structure.

live degree is useful for faster market reading, but beginners should understand that live pivots can repaint while they are forming.

support lines are usually below price and can act as dynamic reaction zones.

resistance lines are usually above price and can act as dynamic rejection zones.

when price approaches a confirmed or htf trendline, watch how it reacts. price can reject the line, break through it, or compress near it before a stronger move.

a break is cleaner when price closes beyond the line. this is why the break confirmation input is important.

---

beginner tutorial

1. choose your trading timeframe, such as 15m, 1h, 4h, or 1d.

2. enable confirmed degree to display stable trendlines.

3. enable htf degree to display higher timeframe structure.

4. keep live degree enabled only if you want more reactive lines.

5. wait for price to approach a support or resistance trendline.

6. observe the candle reaction near the line.

7. a rejection can indicate that the line is still respected.

8. a confirmed close beyond the line can indicate a structural break.

9. use the dashboard to monitor the main confirmed and htf levels.

10. never use a trendline alone as a full trade signal. combine it with market structure, volume, candles, liquidity, and risk management.

---

simple beginner setup

live degree: off
confirmed degree: on
htf degree: on
anchor source: wick
confirmed pivot l/r: 10
htf pivot l/r: 8
allowed pierces: 0
break = n consecutive closes beyond: 2
show channels: on
show trendline labels: off
show dashboard: on

this setup keeps the chart clean and focuses on confirmed structure.

---

scalping setup

live degree: on
confirmed degree: on
htf degree: on
live pivot l/r: 3 to 5
confirmed pivot l/r: 8 to 12
break = n consecutive closes beyond: 1 to 2
forward projection bars: 10 to 30
show trendline labels: off

this setup gives faster signals and more reactive structure, but it should be used with more caution.

---

swing trading setup

live degree: off
confirmed degree: on
htf degree: on
confirmed pivot l/r: 10 to 20
htf pivot l/r: 8 to 15
htf timeframe: 1d or 1w
htf compute in log space: on for crypto
break = n consecutive closes beyond: 2 or 3
infinite extension: on

this setup focuses on larger trendlines and reduces short-term noise.

---

dashboard guide

conf resist
shows the main confirmed resistance trendline level.

conf support
shows the main confirmed support trendline level.

htf resist
shows the main higher timeframe resistance trendline level.

htf support
shows the main higher timeframe support trendline level.

htf ath / atl
shows the higher timeframe extreme levels used for macro context.

validation
shows that the lines are built using structure and validation logic.

---

important notes

a trendline is not an automatic buy or sell signal.

a trendline is a decision zone.

the more clean touches a line has, the more important it becomes.

a close beyond a line is usually more important than a wick through the line.

higher timeframe lines should always be respected because they represent larger market structure.

this tool is designed to organize chart structure, but risk management remains essential.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator(" AUTO TRENDLINE PRO", shorttitle=" AUTO TL", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100, max_bars_back=5000)

gDeg = "═══ DEGREES (shown together) ═══"
showLive = input.bool(true, "LIVE degree (reactive, repaints)", group=gDeg)
showConf = input.bool(true, "CONFIRMED degree (locked)",        group=gDeg)
showHtf  = input.bool(true, "HTF degree (higher timeframe)",    group=gDeg)
anchorSrc= input.string("Wick", "Anchor Source (chart degrees)", options=["Wick","Body"], group=gDeg, tooltip="Wick = high/low extremes (default). Body = open/close extremes.")

gPiv = "═══ PIVOT STRENGTH ═══"
liveL = input.int(3,  "Live Pivot L/R",      minval=2, maxval=50,  group=gPiv)
confL = input.int(10, "Confirmed Pivot L/R", minval=2, maxval=100, group=gPiv)
htfL  = input.int(8,  "HTF Pivot L/R (in HTF bars)", minval=2, maxval=50, group=gPiv)

gHtf = "═══ HTF SOURCE ═══"
htfTF      = input.timeframe("1W", "HTF Timeframe", group=gHtf, tooltip="The higher timeframe whose structure is pulled via request.security.")
htfLB      = input.int(300, "HTF ATH/ATL Window (HTF bars)", minval=20, group=gHtf, tooltip="Weekly 300 ≈ 5.7y -> reaches the cycle ATH.")
htfAnchor  = input.bool(true, "Anchor HTF line at ATH / ATL", group=gHtf)
htfLog     = input.bool(true, "HTF: compute in Log space",   group=gHtf, tooltip="Straight macro line on a LOG-scaled chart (BTC power-law).")

gSel = "═══ STRUCTURE & VALIDATION ═══"
maxChartLines = input.int(2, "Lines per side (chart degrees)", minval=1, maxval=5, group=gSel)
maxHtfLines   = input.int(2, "Lines per side (HTF)",           minval=1, maxval=5, group=gSel)
nNew      = input.int(3,    "New-anchor candidates", minval=1, maxval=8, group=gSel)
olderWin  = input.int(10,   "Older-anchor window",   minval=2, maxval=18, group=gSel)
minSpan   = input.int(5,    "Min Bars Between Anchors", minval=2, group=gSel)
maxPierce = input.int(0,    "Allowed Pierces", minval=0, maxval=5, group=gSel, tooltip="0 = strict (nothing may pierce the line between anchors).")
piercePct = input.float(0.5,"Pierce Tolerance (× ATR)", minval=0.0, step=0.1, group=gSel)
touchPct  = input.float(0.6,"Touch Tolerance (× ATR)",  minval=0.1, step=0.1, group=gSel)
dedupeMult= input.float(1.5,"Dedupe Distance (× ATR)",  minval=0.1, step=0.1, group=gSel)
maxValSpan= input.int(1200, "Max Validation Span (bars)", minval=50, group=gSel)

gBrk = "═══ CHANNELS / BREAK / EXTENSION ═══"
showCh     = input.bool(true, "Show Channels (dominant line)", group=gBrk)
breakBars  = input.int(2,    "Break = N consecutive closes beyond", minval=1, maxval=10, group=gBrk)
forwardBars= input.int(15,   "Forward Projection (bars)", minval=0, maxval=200, group=gBrk)
allowInf   = input.bool(false,"Infinite Extension", group=gBrk)

gDsp = "═══ DISPLAY ═══"
showProj  = input.bool(true, "Price Projection Label", group=gDsp)
showTlLabels = input.bool(false, "Show Trendline Labels", group=gDsp)
showStars = input.bool(true, "Strength Rating ✦", group=gDsp)
showDash  = input.bool(true, "Show Dashboard", group=gDsp)
showInteriorColors = input.bool(true, "Show Interior Colors", group=gDsp, tooltip="Disable panel interior backgrounds and channel fill interiors while keeping borders, text and trendline colors.")
dashPos   = input.string("Top Right", "Dashboard Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gDsp)

gUi = "═══ AESTHETICS ═══"
colBull = input.color(#00FFD1, "Support",    group=gUi)
colBear = input.color(#FF3B5C, "Resistance", group=gUi)
colGold = input.color(#FFD23F, "HTF Glow / Accent", group=gUi)
colBrk  = input.color(#9AB0C7, "Broken",     group=gUi)
atrLen  = input.int(50, "ATR Length", minval=2, group=gUi)

bodyAnchor = anchorSrc == "Body"
atr    = ta.atr(atrLen)
tolP   = atr * piercePct
touchP = atr * touchPct
dedupP = atr * dedupeMult
maxStore = 16

f2s(float x) => na(x) ? "—" : str.tostring(x, format.mintick)
srcHi(int off) => off < 0 ? na : (bodyAnchor ? math.max(open[off], close[off]) : high[off])
srcLo(int off) => off < 0 ? na : (bodyAnchor ? math.min(open[off], close[off]) : low[off])
stars(int t)   => t >= 4 ? "✦✦✦✦" : t == 3 ? "✦✦✦" : t == 2 ? "✦✦" : "✦"
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(nz(x, 0.0), hi))
f_powerColor(float v) => v < 0.0 ? color.from_gradient(v, -100.0, 0.0, colBear, colGold) : color.from_gradient(v, 0.0, 100.0, colGold, colBull)
f_powerText(float v) => v > 12.0 ? "bull " + str.tostring(math.round(v), "#") + "%" : v < -12.0 ? "bear " + str.tostring(math.round(math.abs(v)), "#") + "%" : "neutral"
panelBlue = #AEB7C2
panelBlue2 = #6F7A86
panelBg0 = #0E1116
panelBg1 = #151A21
panelBg2 = #1C222B
panelText = #E2E6EA

projX(int x1, float y1, int x2, float y2, int xq, bool lg) =>
    v1 = lg and y1 > 0 ? math.log(y1) : y1
    v2 = lg and y2 > 0 ? math.log(y2) : y2
    m  = (x2 - x1) != 0 ? (v2 - v1) / (x2 - x1) : 0.0
    vq = v1 + m * (xq - x1)
    lg ? math.exp(vq) : vq

clearLines(array<line> a) =>
    for x in a
        line.delete(x)
    array.clear(a)

clearLabels(array<label> a) =>
    for x in a
        label.delete(x)
    array.clear(a)

clearFills(array<linefill> a) =>
    for x in a
        linefill.delete(x)
    array.clear(a)

evalChart(int b1, float p1, int b2, float p2, bool isRes, array<int> pvB, array<float> pvP) =>
    span  = b2 - b1
    m     = span != 0 ? (p2 - p1) / span : 0.0
    valid = span >= minSpan and span <= maxValSpan
    pierces = 0
    if valid
        k = b1 + 1
        while k < b2
            off = bar_index - k
            if off >= 0
                lp = p1 + m * (k - b1)
                if isRes
                    if srcHi(off) > lp + tolP
                        pierces += 1
                else
                    if srcLo(off) < lp - tolP
                        pierces += 1
            k += 1
        if pierces > maxPierce
            valid := false
    touches = 0
    if valid
        np = array.size(pvB)
        for i = 0 to np - 1
            pb = array.get(pvB, i)
            pp = array.get(pvP, i)
            lp = p1 + m * (pb - b1)
            if math.abs(pp - lp) <= touchP
                touches += 1
    score = valid ? touches * 1000000.0 + span : -1.0
    [valid, touches, score]

evalHtf(int t1, float p1, int t2, float p2, bool isRes, bool lg, array<int> pvT, array<float> pvP, float tol, float tolt) =>
    valid = t2 > t1
    pierces = 0
    touches = 0
    np = array.size(pvT)
    for i = 0 to np - 1
        pt = array.get(pvT, i)
        pp = array.get(pvP, i)
        lp = projX(t1, p1, t2, p2, pt, lg)
        if pt > t1 and pt < t2
            if isRes
                if pp > lp + tol
                    pierces += 1
            else
                if pp < lp - tol
                    pierces += 1
        if math.abs(pp - lp) <= tolt
            touches += 1
    if pierces > maxPierce
        valid := false
    score = valid ? touches * 1000000.0 + (t2 - t1) / 1000.0 : -1.0
    [valid, touches, score]

selectChart(array<int> pvB, array<float> pvP, bool isRes, int K, array<int> oB1, array<float> oP1, array<int> oB2, array<float> oP2, array<int> oTc) =>
    array.clear(oB1)
    array.clear(oP1)
    array.clear(oB2)
    array.clear(oP2)
    array.clear(oTc)
    tSc = array.new<float>()
    tB1 = array.new<int>()
    tP1 = array.new<float>()
    tB2 = array.new<int>()
    tP2 = array.new<float>()
    tTc = array.new<int>()
    n = array.size(pvB)
    if n >= 2
        loN = math.max(0, n - nNew)
        for ni = loN to n - 1
            b2 = array.get(pvB, ni)
            p2 = array.get(pvP, ni)
            loO = math.max(0, ni - olderWin)
            if ni > loO
                for oj = loO to ni - 1
                    b1 = array.get(pvB, oj)
                    p1 = array.get(pvP, oj)
                    [v, t, sc] = evalChart(b1, p1, b2, p2, isRes, pvB, pvP)
                    if v
                        array.push(tSc, sc)
                        array.push(tB1, b1)
                        array.push(tP1, p1)
                        array.push(tB2, b2)
                        array.push(tP2, p2)
                        array.push(tTc, t)
    picked = 0
    guard = 0
    while picked < K and guard < 300
        guard += 1
        bestI = -1
        bestSc = -1.0
        candN = array.size(tSc)
        if candN == 0
            break
        for i = 0 to candN - 1
            if array.get(tSc, i) > bestSc
                bestI := i
                bestSc := array.get(tSc, i)
        if bestI < 0 or bestSc < 0
            break
        array.set(tSc, bestI, -2.0)
        cb1 = array.get(tB1, bestI)
        cp1 = array.get(tP1, bestI)
        cb2 = array.get(tB2, bestI)
        cp2 = array.get(tP2, bestI)
        projNew = projX(cb1, cp1, cb2, cp2, bar_index, false)
        dup = false
        pickedN = array.size(oB1)
        if pickedN > 0
            for j = 0 to pickedN - 1
                pj = projX(array.get(oB1, j), array.get(oP1, j), array.get(oB2, j), array.get(oP2, j), bar_index, false)
                if math.abs(projNew - pj) <= dedupP
                    dup := true
                    break
        if not dup
            array.push(oB1, cb1)
            array.push(oP1, cp1)
            array.push(oB2, cb2)
            array.push(oP2, cp2)
            array.push(oTc, array.get(tTc, bestI))
            picked += 1

selectHtf(array<int> pvT, array<float> pvP, bool isRes, bool lg, int K, int anchT, float anchP, bool useAnchor, float tol, float tolt, float dd, array<int> oT1, array<float> oP1, array<int> oT2, array<float> oP2, array<int> oTc) =>
    array.clear(oT1)
    array.clear(oP1)
    array.clear(oT2)
    array.clear(oP2)
    array.clear(oTc)
    tSc = array.new<float>()
    tT1 = array.new<int>()
    tP1 = array.new<float>()
    tT2 = array.new<int>()
    tP2 = array.new<float>()
    tTc = array.new<int>()
    n = array.size(pvT)
    if n >= 2
        loN = math.max(0, n - nNew)
        for ni = loN to n - 1
            t2 = array.get(pvT, ni)
            p2 = array.get(pvP, ni)
            if ni > 0
                for oj = 0 to ni - 1
                    t1 = array.get(pvT, oj)
                    p1 = array.get(pvP, oj)
                    [v, t, sc] = evalHtf(t1, p1, t2, p2, isRes, lg, pvT, pvP, tol, tolt)
                    if v
                        array.push(tSc, sc)
                        array.push(tT1, t1)
                        array.push(tP1, p1)
                        array.push(tT2, t2)
                        array.push(tP2, p2)
                        array.push(tTc, t)
    if useAnchor and not na(anchT) and n >= 1
        for ni = 0 to n - 1
            t2 = array.get(pvT, ni)
            p2 = array.get(pvP, ni)
            if anchT < t2
                [v, t, sc] = evalHtf(anchT, anchP, t2, p2, isRes, lg, pvT, pvP, tol, tolt)
                if v
                    array.push(tSc, sc + 500000.0)
                    array.push(tT1, anchT)
                    array.push(tP1, anchP)
                    array.push(tT2, t2)
                    array.push(tP2, p2)
                    array.push(tTc, t)
    picked = 0
    guard = 0
    while picked < K and guard < 300
        guard += 1
        bestI = -1
        bestSc = -1.0
        candN = array.size(tSc)
        if candN == 0
            break
        for i = 0 to candN - 1
            if array.get(tSc, i) > bestSc
                bestI := i
                bestSc := array.get(tSc, i)
        if bestI < 0 or bestSc < 0
            break
        array.set(tSc, bestI, -2.0)
        ct1 = array.get(tT1, bestI)
        cp1 = array.get(tP1, bestI)
        ct2 = array.get(tT2, bestI)
        cp2 = array.get(tP2, bestI)
        projNew = projX(ct1, cp1, ct2, cp2, int(time), lg)
        dup = false
        pickedN = array.size(oT1)
        if pickedN > 0
            for j = 0 to pickedN - 1
                pj = projX(array.get(oT1, j), array.get(oP1, j), array.get(oT2, j), array.get(oP2, j), int(time), lg)
                if math.abs(projNew - pj) <= dd
                    dup := true
                    break
        if not dup
            array.push(oT1, ct1)
            array.push(oP1, cp1)
            array.push(oT2, ct2)
            array.push(oP2, cp2)
            array.push(oTc, array.get(tTc, bestI))
            picked += 1

phSrc = bodyAnchor ? math.max(open, close) : high
plSrc = bodyAnchor ? math.min(open, close) : low
phLive = ta.pivothigh(phSrc, liveL, liveL)
plLive = ta.pivotlow(plSrc, liveL, liveL)
phConf = ta.pivothigh(phSrc, confL, confL)
plConf = ta.pivotlow(plSrc, confL, confL)

var array<float> phLiveP = array.new<float>()
var array<int>   phLiveB = array.new<int>()
var array<float> plLiveP = array.new<float>()
var array<int>   plLiveB = array.new<int>()
var array<float> phConfP = array.new<float>()
var array<int>   phConfB = array.new<int>()
var array<float> plConfP = array.new<float>()
var array<int>   plConfB = array.new<int>()

pushPv(array<float> aP, array<int> aB, float v, int b) =>
    array.push(aP, v)
    array.push(aB, b)
    if array.size(aP) > maxStore
        array.shift(aP)
        array.shift(aB)

if not na(phLive)
    pushPv(phLiveP, phLiveB, phLive, bar_index - liveL)
if not na(plLive)
    pushPv(plLiveP, plLiveB, plLive, bar_index - liveL)
if not na(phConf)
    pushPv(phConfP, phConfB, phConf, bar_index - confL)
if not na(plConf)
    pushPv(plConfP, plConfB, plConf, bar_index - confL)

htfStruct() =>
    _ph  = ta.pivothigh(htfL, htfL)
    _pl  = ta.pivotlow(htfL, htfL)
    _pht = na(_ph) ? na : time[htfL]
    _plt = na(_pl) ? na : time[htfL]
    _ath = ta.highest(high, htfLB)
    _atl = ta.lowest(low, htfLB)
    _att = time[int(math.abs(ta.highestbars(high, htfLB)))]
    _alt = time[int(math.abs(ta.lowestbars(low, htfLB)))]
    [_ph, _pht, _pl, _plt, _ath, _att, _atl, _alt]

[phHv, phHt, plHv, plHt, athV, athT, atlV, atlT] = request.security(syminfo.tickerid, htfTF, htfStruct(), lookahead=barmerge.lookahead_off)
htfAtr = request.security(syminfo.tickerid, htfTF, ta.atr(atrLen), lookahead=barmerge.lookahead_off)
tolHtf   = (na(htfAtr) ? atr : htfAtr) * piercePct
touchHtf = (na(htfAtr) ? atr : htfAtr) * touchPct
dedupHtf = (na(htfAtr) ? atr : htfAtr) * dedupeMult

var array<float> phHtfP = array.new<float>()
var array<int>   phHtfT = array.new<int>()
var array<float> plHtfP = array.new<float>()
var array<int>   plHtfT = array.new<int>()

pushHtf(array<float> aP, array<int> aT, float v, int t) =>
    if array.size(aT) == 0 or array.get(aT, array.size(aT) - 1) != t
        array.push(aP, v)
        array.push(aT, t)
        if array.size(aT) > maxStore
            array.shift(aP)
            array.shift(aT)

if not na(phHv) and not na(phHt)
    pushHtf(phHtfP, phHtfT, phHv, int(phHt))
if not na(plHv) and not na(plHt)
    pushHtf(plHtfP, plHtfT, plHv, int(plHt))

var array<line>     glLines  = array.new<line>()
var array<label>    glLabels = array.new<label>()
var array<linefill> glFills  = array.new<linefill>()

var int   cRb1 = na
var float cRp1 = na
var int   cRb2 = na
var float cRp2 = na
var int   cSb1 = na
var float cSp1 = na
var int   cSb2 = na
var float cSp2 = na
var int   hRt1 = na
var float hRp1 = na
var int   hRt2 = na
var float hRp2 = na
var int   hSt1 = na
var float hSp1 = na
var int   hSt2 = na
var float hSp2 = na

drawChartTL(int b1, float p1, int b2, float p2, int touches, bool isRes, int degree, bool withCh, array<line> LN, array<label> LB, array<linefill> LF) =>
    baseCol = isRes ? colBear : colBull
    cnt = 0
    ok = true
    for k = 0 to breakBars - 1
        lp = projX(b1, p1, b2, p2, bar_index - k, false)
        if ok and (isRes ? close[k] > lp + tolP : close[k] < lp - tolP)
            cnt += 1
        else
            ok := false
    broken = cnt >= breakBars
    col = broken ? colBrk : baseCol
    wdt = degree == 0 ? 1 : degree == 1 ? 2 : 3
    trp = degree == 0 ? 50 : 0
    sty = degree == 0 ? line.style_dotted : line.style_solid
    baseLen = b2 - b1
    endBar = int(allowInf ? bar_index + forwardBars : math.min(bar_index + forwardBars, b2 + baseLen * 2))
    pAt2 = projX(b1, p1, b2, p2, b2, false)
    pEnd = projX(b1, p1, b2, p2, endBar, false)
    lb = line.new(b1, p1, b2, pAt2, xloc=xloc.bar_index, color=color.new(col, trp), width=wdt, style=sty)
    array.push(LN, lb)
    le = line.new(b2, pAt2, endBar, pEnd, xloc=xloc.bar_index, color=color.new(col, broken ? 55 : trp + 15), width=1, style=broken ? line.style_dotted : line.style_dashed)
    array.push(LN, le)
    if withCh and showCh and not broken
        m = baseLen != 0 ? (p2 - p1) / baseLen : 0.0
        ext = float(na)
        kk = b1
        while kk <= b2
            off = bar_index - kk
            if off >= 0
                lv = p1 + m * (kk - b1)
                d = isRes ? lv - srcLo(off) : srcHi(off) - lv
                ext := na(ext) ? d : math.max(ext, d)
            kk += 1
        if not na(ext) and ext > 0
            sgn = isRes ? -1.0 : 1.0
            cb = line.new(b1, p1 + sgn * ext, b2, pAt2 + sgn * ext, xloc=xloc.bar_index, color=color.new(baseCol, 62), width=1)
            ce = line.new(b2, pAt2 + sgn * ext, endBar, pEnd + sgn * ext, xloc=xloc.bar_index, color=color.new(baseCol, 72), width=1, style=line.style_dotted)
            array.push(LN, cb)
            array.push(LN, ce)
            array.push(LF, linefill.new(lb, cb, color.new(baseCol, showInteriorColors ? 92 : 100)))
    if showTlLabels
        tag = degree == 0 ? "L" : "C"
        txt = (isRes ? "R" : "S") + "·" + tag + (showStars ? " " + stars(touches) : "") + (broken ? " BRK" : "") + (showProj ? " " + f2s(pEnd) : "")
        array.push(LB, label.new(endBar, pEnd, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(col, 80), textcolor=col, size=size.tiny))

drawHtfTL(int t1, float p1, int t2, float p2, int touches, bool isRes, bool lg, bool withCh, array<int> oppT, array<float> oppP, array<line> LN, array<label> LB, array<linefill> LF) =>
    baseCol = isRes ? colBear : colBull
    cnt = 0
    ok = true
    for k = 0 to breakBars - 1
        lp = projX(t1, p1, t2, p2, int(time[k]), lg)
        if ok and (isRes ? close[k] > lp + tolHtf : close[k] < lp - tolHtf)
            cnt += 1
        else
            ok := false
    broken = cnt >= breakBars
    col = broken ? colBrk : baseCol
    pAt2 = projX(t1, p1, t2, p2, t2, lg)
    extEndT = int(time)
    pEnd = projX(t1, p1, t2, p2, extEndT, lg)
    glow = line.new(t1, p1, t2, pAt2, xloc=xloc.bar_time, color=color.new(colGold, 82), width=6)
    array.push(LN, glow)
    lb = line.new(t1, p1, t2, pAt2, xloc=xloc.bar_time, color=color.new(col, 0), width=3)
    array.push(LN, lb)
    le = line.new(t2, pAt2, extEndT, pEnd, xloc=xloc.bar_time, color=color.new(col, broken ? 45 : 18), width=2, style=broken ? line.style_dotted : line.style_dashed, extend=broken ? extend.none : extend.right)
    array.push(LN, le)
    if withCh and showCh and not broken
        ext = float(na)
        no = array.size(oppT)
        if no > 0
            for i = 0 to no - 1
                pt = array.get(oppT, i)
                pp = array.get(oppP, i)
                if pt >= t1 and pt <= t2
                    lv = projX(t1, p1, t2, p2, pt, lg)
                    d = isRes ? lv - pp : pp - lv
                    ext := na(ext) ? d : math.max(ext, d)
        if not na(ext) and ext > 0
            sgn = isRes ? -1.0 : 1.0
            cb = line.new(t1, p1 + sgn * ext, t2, pAt2 + sgn * ext, xloc=xloc.bar_time, color=color.new(baseCol, 62), width=1)
            ce = line.new(t2, pAt2 + sgn * ext, extEndT, pEnd + sgn * ext, xloc=xloc.bar_time, color=color.new(baseCol, 72), width=1, style=line.style_dotted, extend=extend.right)
            array.push(LN, cb)
            array.push(LN, ce)
            array.push(LF, linefill.new(lb, cb, color.new(baseCol, showInteriorColors ? 92 : 100)))
    if showTlLabels
        txt = (isRes ? "R" : "S") + "·H" + (showStars ? " " + stars(touches) : "") + (broken ? " BRK" : "") + (showProj ? " " + f2s(pEnd) : "")
        array.push(LB, label.new(extEndT, pEnd, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, 70), textcolor=col, size=size.tiny))

if barstate.islast
    clearLines(glLines)
    clearLabels(glLabels)
    clearFills(glFills)
    cRb1 := na
    cSb1 := na
    hRt1 := na
    hSt1 := na

    oB1 = array.new<int>()
    oP1 = array.new<float>()
    oB2 = array.new<int>()
    oP2 = array.new<float>()
    oTc = array.new<int>()

    if showLive
        selectChart(phLiveB, phLiveP, true, maxChartLines, oB1, oP1, oB2, oP2, oTc)
        liveResN = array.size(oB1)
        if liveResN > 0
            for z = 0 to liveResN - 1
                drawChartTL(array.get(oB1, z), array.get(oP1, z), array.get(oB2, z), array.get(oP2, z), array.get(oTc, z), true, 0, false, glLines, glLabels, glFills)
        selectChart(plLiveB, plLiveP, false, maxChartLines, oB1, oP1, oB2, oP2, oTc)
        liveSupN = array.size(oB1)
        if liveSupN > 0
            for z = 0 to liveSupN - 1
                drawChartTL(array.get(oB1, z), array.get(oP1, z), array.get(oB2, z), array.get(oP2, z), array.get(oTc, z), false, 0, false, glLines, glLabels, glFills)

    if showConf
        selectChart(phConfB, phConfP, true, maxChartLines, oB1, oP1, oB2, oP2, oTc)
        confResN = array.size(oB1)
        if confResN > 0
            for z = 0 to confResN - 1
                drawChartTL(array.get(oB1, z), array.get(oP1, z), array.get(oB2, z), array.get(oP2, z), array.get(oTc, z), true, 1, z == 0, glLines, glLabels, glFills)
                if z == 0
                    cRb1 := array.get(oB1, z)
                    cRp1 := array.get(oP1, z)
                    cRb2 := array.get(oB2, z)
                    cRp2 := array.get(oP2, z)
        selectChart(plConfB, plConfP, false, maxChartLines, oB1, oP1, oB2, oP2, oTc)
        confSupN = array.size(oB1)
        if confSupN > 0
            for z = 0 to confSupN - 1
                drawChartTL(array.get(oB1, z), array.get(oP1, z), array.get(oB2, z), array.get(oP2, z), array.get(oTc, z), false, 1, z == 0, glLines, glLabels, glFills)
                if z == 0
                    cSb1 := array.get(oB1, z)
                    cSp1 := array.get(oP1, z)
                    cSb2 := array.get(oB2, z)
                    cSp2 := array.get(oP2, z)

    if showHtf
        hT1 = array.new<int>()
        hPP1 = array.new<float>()
        hT2 = array.new<int>()
        hPP2 = array.new<float>()
        hTc = array.new<int>()
        selectHtf(phHtfT, phHtfP, true, htfLog, maxHtfLines, int(athT), athV, htfAnchor, tolHtf, touchHtf, dedupHtf, hT1, hPP1, hT2, hPP2, hTc)
        hResN = array.size(hT1)
        if hResN > 0
            for z = 0 to hResN - 1
                drawHtfTL(array.get(hT1, z), array.get(hPP1, z), array.get(hT2, z), array.get(hPP2, z), array.get(hTc, z), true, htfLog, z == 0, plHtfT, plHtfP, glLines, glLabels, glFills)
                if z == 0
                    hRt1 := array.get(hT1, z)
                    hRp1 := array.get(hPP1, z)
                    hRt2 := array.get(hT2, z)
                    hRp2 := array.get(hPP2, z)
        selectHtf(plHtfT, plHtfP, false, htfLog, maxHtfLines, int(atlT), atlV, htfAnchor, tolHtf, touchHtf, dedupHtf, hT1, hPP1, hT2, hPP2, hTc)
        hSupN = array.size(hT1)
        if hSupN > 0
            for z = 0 to hSupN - 1
                drawHtfTL(array.get(hT1, z), array.get(hPP1, z), array.get(hT2, z), array.get(hPP2, z), array.get(hTc, z), false, htfLog, z == 0, phHtfT, phHtfP, glLines, glLabels, glFills)
                if z == 0
                    hSt1 := array.get(hT1, z)
                    hSp1 := array.get(hPP1, z)
                    hSt2 := array.get(hT2, z)
                    hSp2 := array.get(hPP2, z)

cRNow = not na(cRb1) ? projX(cRb1, cRp1, cRb2, cRp2, bar_index, false) : na
cSNow = not na(cSb1) ? projX(cSb1, cSp1, cSb2, cSp2, bar_index, false) : na
hRNow = not na(hRt1) ? projX(hRt1, hRp1, hRt2, hRp2, int(time), htfLog) : na
hSNow = not na(hSt1) ? projX(hSt1, hSp1, hSt2, hSp2, int(time), htfLog) : na

cRBrk = not na(cRNow) and close > cRNow + tolP
cSBrk = not na(cSNow) and close < cSNow - tolP
hRBrk = not na(hRNow) and close > hRNow + tolHtf
hSBrk = not na(hSNow) and close < hSNow - tolHtf


alertcondition(cRBrk and not cRBrk[1], " • Confirmed Resistance Break", " AUTO TL PRO — confirmed resistance broken")
alertcondition(cSBrk and not cSBrk[1], " • Confirmed Support Break",    " AUTO TL PRO — confirmed support broken")
alertcondition(hRBrk and not hRBrk[1], " • HTF Resistance Break",       " AUTO TL PRO — HTF resistance broken")
alertcondition(hSBrk and not hSBrk[1], " • HTF Support Break",          " AUTO TL PRO — HTF support broken")

posSel = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.middle_right
var table dash = table.new(posSel, 2, 14, bgcolor=showInteriorColors ? color.new(panelBg0, 4) : color.new(panelBg0, 100), frame_color=color.new(panelBlue, 0), frame_width=1, border_color=color.new(panelBlue2, 45), border_width=1)
pbg(color c, int tr) => showInteriorColors ? color.new(c, tr) : color.new(panelBg0, 100)
cell(int c, int r, string t, color tc, color bg) => table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=text.align_left)

if showDash and barstate.islast
    cRtxt = na(cRNow) ? "waiting" : f2s(cRNow) + (cRBrk ? "  BRK" : "")
    cStxt = na(cSNow) ? "waiting" : f2s(cSNow) + (cSBrk ? "  BRK" : "")
    hRtxt = na(hRNow) ? "waiting" : f2s(hRNow) + (hRBrk ? "  BRK" : "")
    hStxt = na(hSNow) ? "waiting" : f2s(hSNow) + (hSBrk ? "  BRK" : "")
    dCR = not na(cRNow) ? math.abs(close - cRNow) : 1e20
    dCS = not na(cSNow) ? math.abs(close - cSNow) : 1e20
    dHR = not na(hRNow) ? math.abs(close - hRNow) : 1e20
    dHS = not na(hSNow) ? math.abs(close - hSNow) : 1e20
    dMin = math.min(math.min(dCR, dCS), math.min(dHR, dHS))
    nearestTxt = dMin == 1e20 ? "waiting" : dMin == dCR ? "conf resist " + str.tostring(dCR / close * 100.0, "#.##") + "%" : dMin == dCS ? "conf support " + str.tostring(dCS / close * 100.0, "#.##") + "%" : dMin == dHR ? "htf resist " + str.tostring(dHR / close * 100.0, "#.##") + "%" : "htf support " + str.tostring(dHS / close * 100.0, "#.##") + "%"
    breakTxt = cRBrk ? "conf resistance" : cSBrk ? "conf support" : hRBrk ? "htf resistance" : hSBrk ? "htf support" : "no break"
    pivTxt = "L " + str.tostring(array.size(phLiveB) + array.size(plLiveB)) + " / C " + str.tostring(array.size(phConfB) + array.size(plConfB)) + " / H " + str.tostring(array.size(phHtfT) + array.size(plHtfT))
    atrTxt = f2s(atr) + " / " + str.tostring((atr / close) * 100.0, "#.##") + "%"
    rangeTxt = str.tostring(((high - low) / atr) * 100.0, "#.##") + "% atr"

    cell(0, 0, "📐 AUTO TL PRO", panelBlue, pbg(panelBg0, 0))
    cell(1, 0, "🧙 WIZARD", color.new(panelBlue, 0), pbg(panelBg0, 0))
    cell(0, 1, "💠 Price", panelBlue, pbg(panelBg2, 18))
    cell(1, 1, f2s(close), panelText, pbg(panelBg2, 18))
    cell(0, 2, "📏 ATR", colBrk, pbg(panelBg1, 18))
    cell(1, 2, atrTxt, panelText, pbg(panelBg1, 18))
    cell(0, 3, "📊 Bar Range", colBrk, pbg(panelBg2, 18))
    cell(1, 3, rangeTxt, panelText, pbg(panelBg2, 18))
    cell(0, 4, "🧬 Degrees", colBrk, pbg(panelBg1, 18))
    cell(1, 4, (showLive ? "L " : "") + (showConf ? "C " : "") + (showHtf ? "H" : ""), panelText, pbg(panelBg1, 18))
    cell(0, 5, "🧲 Stored Pivots", colBrk, pbg(panelBg2, 18))
    cell(1, 5, pivTxt, panelText, pbg(panelBg2, 18))
    cell(0, 6, "🎯 Nearest TL", panelBlue, pbg(panelBg1, 18))
    cell(1, 6, nearestTxt, panelText, pbg(panelBg1, 18))
    cell(0, 7, "⚡ Break Status", cRBrk or cSBrk or hRBrk or hSBrk ? colGold : colBrk, pbg(panelBg2, 18))
    cell(1, 7, breakTxt, cRBrk or cSBrk or hRBrk or hSBrk ? colGold : panelText, pbg(panelBg2, 18))
    cell(0, 8, "🔴 Conf Resist", colBear, pbg(panelBg1, 18))
    cell(1, 8, cRtxt, colBear, pbg(panelBg1, 18))
    cell(0, 9, "🟢 Conf Support", colBull, pbg(panelBg2, 18))
    cell(1, 9, cStxt, colBull, pbg(panelBg2, 18))
    cell(0, 10, "🔴 HTF Resist", colBear, pbg(panelBg1, 18))
    cell(1, 10, hRtxt, colBear, pbg(panelBg1, 18))
    cell(0, 11, "🟢 HTF Support", colBull, pbg(panelBg2, 18))
    cell(1, 11, hStxt, colBull, pbg(panelBg2, 18))
    cell(0, 12, "🏔 HTF ATH/ATL", panelBlue, pbg(panelBg1, 18))
    cell(1, 12, f2s(athV) + " / " + f2s(atlV), panelText, pbg(panelBg1, 18))
    cell(0, 13, "✅ Validation", colBrk, pbg(panelBg2, 18))
    cell(1, 13, "wick + structure ✓", colBull, pbg(panelBg2, 18))
````
