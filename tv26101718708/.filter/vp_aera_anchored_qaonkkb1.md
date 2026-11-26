# VP AERA ANCHORED 

- url: https://www.tradingview.com/script/qAONkkB1-VP-AERA-ANCHORED/
- type: indicator
- pine_id: PUB;a23d9e88557e4f1ca763df8bc3a1ca75
- version: 1.0

## Description

vp aera anchored

vp aera anchored is an anchored volume profile tool designed to display a fixed market profile from a selected anchor point, with value area levels, poc, vah, val, anchored vwap levels, market structure context, liquidity information, bull versus bear pressure, dominance, projection and a compact institutional dashboard.

the goal of this tool is to help traders read where volume has been accepted, where price is reacting around value, and whether current conditions are showing more bullish, bearish or neutral pressure.

this indicator is designed for market analysis. it does not place trades, does not predict the future and does not guarantee any result. every signal and level should be confirmed with price action, market structure, liquidity, session context and risk management.

main concept

the script builds a volume profile from a chosen anchor window.

the profile shows where volume was concentrated inside the selected range.

the poc marks the highest volume price area.

the vah marks the upper boundary of the value area.

the val marks the lower boundary of the value area.

the anchored vwap levels show the average traded price of the selected window and multiple deviation levels around it.

the dashboard summarizes useful information such as price location, structure, order book proxy, bull versus bear balance, dominance, projection, liquidity, vwap distance, value area width, window size and last signal.

anchor modes

screen left lock

this mode anchors the profile to the left side of the visible chart.

when you move or zoom the chart, the profile recalculates from the visible left edge.

this is useful for active chart reading and discretionary analysis.

bars back

this mode uses a fixed number of bars.

for example, if bars back is set to 300, the profile uses the last 300 bars.

this is useful when you want a stable rolling profile.

date

this mode starts the profile from a selected date.

this is useful for anchored analysis from a major high, major low, news event, session start, weekly open, monthly open or important market turning point.

profile settings

rows

controls the resolution of the volume profile.

more rows create a more detailed profile with thinner price levels.

fewer rows create a smoother and simpler profile.

max profile width

controls the visual width of the profile on the chart.

higher values make the profile extend further to the right.

lower values keep the profile compact.

high-resolution volume distribution

when enabled, volume is distributed across the full candle range.

this gives a more refined profile than assigning all candle volume to one price area.

delta coloring

when enabled, the profile colors rows using a buy versus sell split proxy.

when disabled, the profile uses a volume intensity gradient.

value area settings

value area percentage

sets how much volume is included in the value area.

the default value is commonly used to represent the main area of volume acceptance.

poc

shows the point of control.

the poc is the price area with the highest traded volume inside the selected profile window.

vah

shows the upper value area boundary.

price above vah can indicate that price is trading above the main accepted value area.

val

shows the lower value area boundary.

price below val can indicate that price is trading below the main accepted value area.

extend levels to current bar

when enabled, poc, vah, val and vwap levels extend toward the current bar.

this makes the levels easier to use as active reference zones.

anchored vwap levels

the anchored vwap is calculated from the same window as the volume profile.

this makes it aligned with the selected anchor instead of using a standard session-only vwap.

vwap

the central anchored vwap line shows the volume-weighted average price of the selected profile window.

vwap plus 1 sigma and vwap minus 1 sigma

these are the first deviation levels around anchored vwap.

they can act as normal reaction zones during balanced market conditions.

vwap plus 2 sigma and vwap minus 2 sigma

these are wider deviation levels.

they can help identify stronger extension from the anchored average.

vwap plus 3 sigma and vwap minus 3 sigma

these are extreme deviation levels.

they can help identify stretched market conditions, but they should not be used alone as reversal signals.

how to use vwap levels

when price is above anchored vwap, the window is generally showing stronger bullish positioning.

when price is below anchored vwap, the window is generally showing stronger bearish positioning.

when price returns to anchored vwap after an extension, the level can act as a balance or reaction zone.

when price holds above vwap and rejects lower deviation levels, buyers may still be defending value.

when price holds below vwap and rejects upper deviation levels, sellers may still be defending value.

dashboard guide

price loc

shows whether price is above value, below value or inside value.

above value can show bullish expansion.

below value can show bearish expansion.

inside value can show balance or consolidation.

structure

shows the current structural bias based on market structure logic.

bullish means price has recently shown bullish structure.

bearish means price has recently shown bearish structure.

neutral means no clear structural bias is active.

order book

this is a proxy reading based on volume and candle range behavior.

it is not direct exchange order book data.

bid means the proxy is leaning toward buyer pressure.

ask means the proxy is leaning toward seller pressure.

bull vs bear

shows a simple pressure gauge.

the gauge stays in the original bar style.

green means bull pressure is dominant.

red means bear pressure is dominant.

the numbers show the estimated bull and bear balance.

dominance

shows which side currently dominates the pressure model.

bull dominance means buyer pressure is stronger.

bear dominance means seller pressure is stronger.

neutral means neither side has a strong advantage.

projection

summarizes the current read from signal, structure, value and pressure context.

bullish projection means conditions are leaning upward.

bearish projection means conditions are leaning downward.

neutral projection means conditions are not clearly directional.

liquidity

shows whether a recent liquidity sweep is detected.

low sweep can show downside liquidity being taken before a possible recovery.

high sweep can show upside liquidity being taken before a possible rejection.

no sweep means no active sweep is detected.

vwap

shows the anchored vwap value when vwap levels are enabled.

vwap dist

shows how far price is from anchored vwap in percentage terms.

positive distance means price is above anchored vwap.

negative distance means price is below anchored vwap.

va width

shows the width of the value area as a percentage of price.

a narrow value area can suggest compression.

a wide value area can suggest broader distribution.

window

shows how many bars are used in the current profile calculation.

last signal

shows the most recent buy or sell signal generated by the script logic.

buy and sell engine

the signal engine combines several filters.

liquidity sweep

the script can require price to sweep a previous swing before triggering.

bos or choch confirmation

the script can require structural confirmation.

test at va edge or poc

the script can require price to react near val, vah or poc.

ema trend filter

the script can optionally require price to align with an ema trend filter.

signal cooldown

the cooldown prevents too many signals from appearing too close together.

beginner tutorial

step 1: start with screen left lock

use screen left lock when learning.

zoom the chart so the visible window starts from an important swing high, swing low or consolidation.

the profile will build from the left visible edge.

step 2: read poc first

find the poc.

if price is above poc, buyers may have control of the current profile window.

if price is below poc, sellers may have control of the current profile window.

if price is moving around poc, the market may be balanced.

step 3: read vah and val

vah is the upper value boundary.

val is the lower value boundary.

inside vah and val, price is inside accepted value.

outside vah and val, price is outside the main accepted value area.

step 4: enable anchored vwap levels

turn on anchored vwap levels when you want an extra institutional reference.

watch how price reacts to vwap, plus 1 sigma, minus 1 sigma, plus 2 sigma and minus 2 sigma.

step 5: use the dashboard

check price loc, structure, order book, bull vs bear, dominance and projection.

do not use one line alone.

look for agreement between several dashboard rows.

step 6: confirm with the chart

before using any signal, check:

trend direction

support and resistance

market structure

candle close

volume reaction

session context

risk to reward

step 7: avoid blind entries

a buy signal near val or vwap support can be stronger than a buy signal in the middle of nowhere.

a sell signal near vah or vwap resistance can be stronger than a sell signal in the middle of nowhere.

example 1: bullish value reaction

price trades near val.

liquidity shows a low sweep.

structure turns bullish.

bull vs bear becomes green.

price reclaims anchored vwap.

this can suggest that buyers are defending value and that downside liquidity was absorbed.

a beginner should still wait for a candle close and define invalidation below the reaction zone.

example 2: bearish value rejection

price trades near vah.

liquidity shows a high sweep.

structure turns bearish.

bull vs bear becomes red.

price rejects anchored vwap or an upper vwap deviation level.

this can suggest that sellers are defending the upper value area.

a beginner should still wait for price confirmation and define invalidation above the rejection zone.

example 3: balanced market

price is inside the value area.

price is close to poc.

dashboard projection is neutral.

dominance is neutral.

bull vs bear is close to 50 and 50.

this means the market is not clearly directional.

a beginner should avoid forcing trades and wait for price to leave value or react at a stronger level.

example 4: trend continuation above value

price is above vah.

structure is bullish.

bull pressure is dominant.

price holds above anchored vwap.

pullbacks to vah or vwap may become continuation areas.

a beginner should avoid shorting only because price looks high.

example 5: bearish continuation below value

price is below val.

structure is bearish.

bear pressure is dominant.

price holds below anchored vwap.

pullbacks toward val or vwap may become rejection areas.

a beginner should avoid buying only because price looks low.

example 6: vwap extension

price moves far above vwap plus 2 sigma or plus 3 sigma.

this shows strong upside extension.

it can continue during strong trends.

wait for loss of structure, rejection or dashboard shift before assuming reversal.

example 7: vwap mean reversion

price moves away from anchored vwap and later returns to it.

anchored vwap can become a reaction zone.

if price accepts above it, buyers may regain control.

if price rejects below it, sellers may remain in control.

suggested beginner settings

anchor mode: screen left lock

rows: default

value area: default

show poc: on

show vah and val: on

extend levels: on

anchored vwap levels: off at first, then on when comfortable

vwap deviation levels: 3

enable signals: on

require liquidity sweep: on

require bos or choch confirmation: on

require va edge or poc: on

ema trend filter: optional

practical workflow

choose the anchor mode.

identify the current poc, vah and val.

check if price is inside value, above value or below value.

enable anchored vwap levels if needed.

watch the dashboard for structure, dominance and bull versus bear pressure.

wait for price to react at poc, vah, val, anchored vwap or vwap deviation levels.

confirm with candle close and market structure.

plan risk before any trade idea.

best use cases

anchored volume profile analysis

value area trading

poc reaction analysis

anchored vwap confluence

bull versus bear pressure reading

liquidity sweep context

trend continuation analysis

reversal preparation

range and balance identification

discretionary trading confirmation

important limitations

the order book row is a proxy, not direct order book data.

vwap levels are based on the selected profile window.

signals are based on historical chart data.

strong trends can stay above value or below value for a long time.

a level is not a trade by itself.

no indicator can guarantee direction, win rate or profit.

risk note

this tool is made for technical analysis and educational market study. it should be used with independent confirmation, proper position sizing and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("VP AERA ANCHORED ", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 50)
gA = "⚓ ANCHOR"
anchorMode = input.string("Screen Left Lock", "Anchor Mode", options = ["Screen Left Lock", "Bars Back", "Date"], group = gA)
barsBack   = input.int(300, "Bars Back", minval = 10, maxval = 5000, group = gA)
anchorDate = input.time(timestamp("01 Jan 2025 00:00 +0000"), "Anchor Date", group = gA)
gP = "📊 PROFILE"
rows      = input.int(180, "Rows (resolution)", minval = 24, maxval = 240, group = gP, tooltip = "Higher = thinner rows. Box/line layer count is auto-clamped against the 500-object cap.")
profWidth = input.int(160, "Max Profile Width (bars)", minval = 20, maxval = 500, group = gP)
hiRes     = input.bool(true, "High-Resolution Volume Distribution", group = gP)
useDelta  = input.bool(false, "Delta Coloring (Buy/Sell split)", group = gP)
gVA = "🎯 VALUE AREA"
vaPct        = input.float(70, "Value Area %", minval = 30, maxval = 95, group = gVA)
showPOC      = input.bool(true, "Show POC", group = gVA)
showVA       = input.bool(true, "Show VAH / VAL", group = gVA)
extendLevels = input.bool(true, "Extend levels to current bar", group = gVA)
gVW = "📈 VWAP"
showVWAP = input.bool(false, "Show Anchored VWAP Levels", group = gVW)
vwapSrc  = input.source(hlc3, "VWAP Source", group = gVW)
vwapLevels = input.int(3, "VWAP Deviation Levels", minval = 1, maxval = 3, group = gVW)
vwapMult1 = input.float(1.0, "VWAP Band 1 σ", minval = 0.1, step = 0.1, group = gVW)
vwapMult2 = input.float(2.0, "VWAP Band 2 σ", minval = 0.1, step = 0.1, group = gVW)
vwapMult3 = input.float(3.0, "VWAP Band 3 σ", minval = 0.1, step = 0.1, group = gVW)
gL = "✨ VISUAL LAYERS"
layers    = input.int(1, "Glow Layers", minval = 1, maxval = 5, group = gL)
glowBoost = input.float(0.2, "Glow Intensity", minval = 0.2, maxval = 2.0, step = 0.1, group = gL)
hvnLvn    = input.bool(true, "HVN / LVN Emphasis", group = gL)
gS = "⚡ BUY / SELL ENGINE"
enableSignals = input.bool(true, "Enable Signals", group = gS)
pivLen        = input.int(8, "Structure Pivot Length", minval = 2, maxval = 50, group = gS)
needSweep     = input.bool(true, "Require Liquidity Sweep", group = gS)
needChoch     = input.bool(true, "Require BOS / CHoCH Confirmation", group = gS)
needVAedge    = input.bool(true, "Require Test at VA Edge / POC", group = gS)
vaTol         = input.float(0.18, "Level Tolerance (× VA height)", minval = 0.0, maxval = 1.0, step = 0.02, group = gS)
useTrend      = input.bool(false, "EMA Trend Filter", group = gS)
trendLen      = input.int(50, "EMA Length", minval = 5, group = gS)
sigCooldown   = input.int(4, "Signal Cooldown (bars)", minval = 0, group = gS)
gT = "🎨 THEME"
theme = input.string("Wizard", "Color Theme", options = ["Wizard", "Ice", "Inferno", "Toxic"], group = gT)
gD = "🧭 DASHBOARD"
showDash = input.bool(true, "Show Dashboard", group = gD)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gD)
themeColors() =>
    cHvn  = color.rgb(0, 255, 209)
    cLvn  = color.rgb(255, 59, 92)
    cPoc  = color.rgb(255, 210, 63)
    cBull = color.rgb(0, 255, 209)
    cBear = color.rgb(255, 59, 92)
    if theme == "Ice"
        cHvn  := color.rgb(120, 220, 255)
        cLvn  := color.rgb(40, 90, 160)
        cPoc  := color.rgb(235, 245, 255)
        cBull := color.rgb(120, 220, 255)
        cBear := color.rgb(80, 120, 200)
    else if theme == "Inferno"
        cHvn  := color.rgb(255, 210, 63)
        cLvn  := color.rgb(120, 20, 30)
        cPoc  := color.rgb(255, 255, 255)
        cBull := color.rgb(255, 170, 40)
        cBear := color.rgb(255, 60, 60)
    else if theme == "Toxic"
        cHvn  := color.rgb(170, 255, 0)
        cLvn  := color.rgb(120, 0, 200)
        cPoc  := color.rgb(220, 255, 120)
        cBull := color.rgb(170, 255, 0)
        cBear := color.rgb(190, 60, 255)
    [cHvn, cLvn, cPoc, cBull, cBear]
[cHvn, cLvn, cPoc, cBull, cBear] = themeColors()
pPanelBg = color.rgb(5, 7, 12)
pPanelHead = color.rgb(24, 29, 39)
pPanelLine = color.rgb(72, 80, 94)
pPanelText = color.rgb(220, 226, 235)
pPanelMuted = color.rgb(150, 158, 170)
pPanelAccent = color.rgb(196, 170, 110)
pPanelBull = color.rgb(38, 132, 110)
pPanelBear = color.rgb(142, 62, 68)
pPanelNeutral = color.rgb(88, 96, 110)
pBullBg = color.new(pPanelBull, 86)
pBearBg = color.new(pPanelBear, 86)
pNeutralBg = color.new(pPanelNeutral, 88)
pAccentBg = color.new(pPanelAccent, 88)
clampT(x) => int(math.max(0, math.min(100, x)))
f_gauge(float _pct) =>
    int filled = int(math.round(math.max(0.0, math.min(100.0, _pct)) / 10.0))
    string g = ""
    for i = 1 to 10
        g += i <= filled ? "█" : "░"
    g
var box[]   boxPool   = array.new<box>()
var line[]  linePool  = array.new<line>()
var label[] labelPool = array.new<label>()
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl
bosUp = not na(lastPH) and close > lastPH
bosDn = not na(lastPL) and close < lastPL
var int bias = 0
chochUp = bias <= 0 and bosUp
chochDn = bias >= 0 and bosDn
if bosUp
    bias := 1
if bosDn
    bias := -1
var int lastBosUpBar = na
var int lastBosDnBar = na
if bosUp
    lastBosUpBar := bar_index
if bosDn
    lastBosDnBar := bar_index
recentBosUp = not na(lastBosUpBar) and (bar_index - lastBosUpBar) <= 12
recentBosDn = not na(lastBosDnBar) and (bar_index - lastBosDnBar) <= 12
sweepLow  = not na(lastPL) and low  < lastPL and close > lastPL
sweepHigh = not na(lastPH) and high > lastPH and close < lastPH
emaV = ta.ema(close, trendLen)
var float pocP = na
var float vahP = na
var float valP = na
var float vaH  = na
var float vwapP = na
var float vwapD = na
var int   winBars = 0
if barstate.islast
    for b in boxPool
        box.delete(b)
    array.clear(boxPool)
    for l in linePool
        line.delete(l)
    array.clear(linePool)
    for lb in labelPool
        label.delete(lb)
    array.clear(labelPool)
    int len = 0
    if anchorMode == "Bars Back"
        len := math.min(barsBack, bar_index)
    else
        anchorStart = anchorMode == "Date" ? anchorDate : chart.left_visible_bar_time
        maxScan = math.min(5000, bar_index)
        len := maxScan
        for k = 0 to maxScan
            if time[k] < anchorStart
                len := k
                break
    len := math.max(len, 1)
    winBars := len
    float rangeHi = high
    float rangeLo = low
    for k = 0 to len - 1
        rangeHi := math.max(rangeHi, high[k])
        rangeLo := math.min(rangeLo, low[k])
    step = (rangeHi - rangeLo) / rows
    if step <= 0
        step := syminfo.mintick
    vArr = array.new_float(rows, 0.0)
    vUp  = array.new_float(rows, 0.0)
    for k = 0 to len - 1
        bh = high[k]
        bl = low[k]
        bv = volume[k]
        up = close[k] >= open[k]
        if hiRes and bh > bl
            loI = int(math.floor((bl - rangeLo) / step))
            hiI = int(math.floor((bh - rangeLo) / step))
            loI := math.max(0, math.min(rows - 1, loI))
            hiI := math.max(0, math.min(rows - 1, hiI))
            spanN = hiI - loI + 1
            per = bv / spanN
            for bi = loI to hiI
                array.set(vArr, bi, array.get(vArr, bi) + per)
                if up
                    array.set(vUp, bi, array.get(vUp, bi) + per)
        else
            idx = int(math.floor((close[k] - rangeLo) / step))
            idx := math.max(0, math.min(rows - 1, idx))
            array.set(vArr, idx, array.get(vArr, idx) + bv)
            if up
                array.set(vUp, idx, array.get(vUp, idx) + bv)
    float volMax = 0.0
    int pocIdx = 0
    for bi = 0 to rows - 1
        v = array.get(vArr, bi)
        if v > volMax
            volMax := v
            pocIdx := bi
    if volMax <= 0
        volMax := 1.0
    totalVol = array.sum(vArr)
    target = totalVol * vaPct / 100.0
    float acc = array.get(vArr, pocIdx)
    int upI = pocIdx
    int dnI = pocIdx
    while acc < target and (upI < rows - 1 or dnI > 0)
        vU = upI < rows - 1 ? array.get(vArr, upI + 1) : -1.0
        vD = dnI > 0 ? array.get(vArr, dnI - 1) : -1.0
        if vU >= vD
            upI := upI + 1
            acc := acc + (vU > 0 ? vU : 0)
        else
            dnI := dnI - 1
            acc := acc + (vD > 0 ? vD : 0)
    pocP := rangeLo + (pocIdx + 0.5) * step
    vahP := rangeLo + (upI + 1) * step
    valP := rangeLo + dnI * step
    vaH  := vahP - valP
    float vwapNum = 0.0
    float vwapDen = 0.0
    for k = 0 to len - 1
        vw = nz(volume[k], 0.0)
        vp = vwapSrc[k]
        if vw > 0 and not na(vp)
            vwapNum := vwapNum + vp * vw
            vwapDen := vwapDen + vw
    vwapP := vwapDen > 0 ? vwapNum / vwapDen : na
    float devNum = 0.0
    if not na(vwapP)
        for k = 0 to len - 1
            vw = nz(volume[k], 0.0)
            vp = vwapSrc[k]
            if vw > 0 and not na(vp)
                devNum := devNum + math.pow(vp - vwapP, 2) * vw
    vwapD := vwapDen > 0 ? math.sqrt(devNum / vwapDen) : na
    leftX    = chart.left_visible_bar_time
    secs     = timeframe.in_seconds()
    barMs    = secs > 0 ? secs * 1000 : (time - time[1])
    maxLenMs = barMs * profWidth
    boxBudget  = 470
    lineBudget = 488
    maxBoxL  = math.max(1, int(math.floor(boxBudget  / rows)))
    maxLineL = math.max(0, int(math.floor(lineBudget / rows)))
    wantBox  = layers >= 5 ? 3 : (layers >= 3 ? 2 : 1)
    wantLine = layers <= 1 ? 0 : (layers >= 4 ? 2 : 1)
    nBox  = math.min(wantBox, maxBoxL)
    nLine = math.min(wantLine, maxLineL)
    for bi = 0 to rows - 1
        v = array.get(vArr, bi)
        if v <= 0
            continue
        t   = v / volMax
        yb  = rangeLo + bi * step
        yt  = rangeLo + (bi + 1) * step
        yc  = (yb + yt) / 2
        hgt = yt - yb
        x2  = leftX + int(maxLenMs * t)
        isPoc  = bi == pocIdx
        ratio  = array.get(vUp, bi) / v
        baseCol = useDelta ? color.from_gradient(ratio, 0, 1, cBear, cBull) : color.from_gradient(t, 0, 1, cLvn, cHvn)
        rowCol = isPoc ? cPoc : baseCol
        boost = 0.0
        if hvnLvn
            isHVN = bi > 0 and bi < rows - 1 and v >= array.get(vArr, bi - 1) and v >= array.get(vArr, bi + 1) and t > 0.6
            if isHVN
                boost := 12.0
        g = glowBoost
        if nBox >= 2
            tp = clampT(89 - 10 * t * g - boost)
            b = box.new(leftX, yt, x2, yb, border_width = 0, border_color = color.new(color.black, 100), bgcolor = color.new(rowCol, tp), xloc = xloc.bar_time)
            array.push(boxPool, b)
        if nBox >= 3
            ttop = yc + (hgt / 2) * 0.60
            tbot = yc - (hgt / 2) * 0.60
            tp = clampT(70 - 13 * t * g - boost)
            b = box.new(leftX, ttop, x2, tbot, border_width = 0, border_color = color.new(color.black, 100), bgcolor = color.new(rowCol, tp), xloc = xloc.bar_time)
            array.push(boxPool, b)
        f2   = nBox >= 2 ? 0.66 : 0.30
        ctop = yc + (hgt / 2) * (1 - f2)
        cbot = yc - (hgt / 2) * (1 - f2)
        tpc  = clampT((nBox >= 2 ? 46 : 52) - 16 * t * g - boost)
        bc = box.new(leftX, ctop, x2, cbot, border_width = 0, border_color = color.new(color.black, 100), bgcolor = color.new(rowCol, tpc), xloc = xloc.bar_time)
        array.push(boxPool, bc)
        if nLine >= 1
            tp = clampT(34 - 14 * t * g - boost)
            l = line.new(leftX, yc, x2, yc, xloc = xloc.bar_time, color = color.new(rowCol, tp), width = 2)
            array.push(linePool, l)
        if nLine >= 2
            tp = clampT(8 - 8 * t * g)
            l = line.new(leftX, yc, x2, yc, xloc = xloc.bar_time, color = color.new(rowCol, tp), width = 1)
            array.push(linePool, l)
    levRight = extendLevels ? time : (leftX + int(maxLenMs))
    if showPOC
        lp = line.new(leftX, pocP, levRight, pocP, xloc = xloc.bar_time, color = color.new(cPoc, 0), width = 2, style = line.style_solid)
        array.push(linePool, lp)
        labP = label.new(levRight, pocP, "POC " + str.tostring(pocP, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cPoc, 12), textcolor = color.black, size = size.tiny)
        array.push(labelPool, labP)
    if showVA
        lh = line.new(leftX, vahP, levRight, vahP, xloc = xloc.bar_time, color = color.new(cHvn, 25), width = 1, style = line.style_dashed)
        array.push(linePool, lh)
        ll = line.new(leftX, valP, levRight, valP, xloc = xloc.bar_time, color = color.new(cHvn, 25), width = 1, style = line.style_dashed)
        array.push(linePool, ll)
        labH = label.new(levRight, vahP, "VAH " + str.tostring(vahP, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cHvn, 35), textcolor = color.white, size = size.tiny)
        array.push(labelPool, labH)
        labL = label.new(levRight, valP, "VAL " + str.tostring(valP, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cHvn, 35), textcolor = color.white, size = size.tiny)
        array.push(labelPool, labL)
    if showVWAP and not na(vwapP)
        vwRight = extendLevels ? time : (leftX + int(maxLenMs))
        lvw = line.new(leftX, vwapP, vwRight, vwapP, xloc = xloc.bar_time, color = color.new(cPoc, 0), width = 2, style = line.style_solid)
        array.push(linePool, lvw)
        labV = label.new(vwRight, vwapP, "VWAP " + str.tostring(vwapP, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cPoc, 12), textcolor = color.black, size = size.tiny)
        array.push(labelPool, labV)
        if not na(vwapD) and vwapLevels >= 1
            u1 = vwapP + vwapD * vwapMult1
            d1 = vwapP - vwapD * vwapMult1
            lu1 = line.new(leftX, u1, vwRight, u1, xloc = xloc.bar_time, color = color.new(cBull, 15), width = 1, style = line.style_dashed)
            ld1 = line.new(leftX, d1, vwRight, d1, xloc = xloc.bar_time, color = color.new(cBear, 15), width = 1, style = line.style_dashed)
            array.push(linePool, lu1)
            array.push(linePool, ld1)
            labU1 = label.new(vwRight, u1, "VWAP +1σ " + str.tostring(u1, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBull, 35), textcolor = color.white, size = size.tiny)
            labD1 = label.new(vwRight, d1, "VWAP -1σ " + str.tostring(d1, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBear, 35), textcolor = color.white, size = size.tiny)
            array.push(labelPool, labU1)
            array.push(labelPool, labD1)
        if not na(vwapD) and vwapLevels >= 2
            u2 = vwapP + vwapD * vwapMult2
            d2 = vwapP - vwapD * vwapMult2
            lu2 = line.new(leftX, u2, vwRight, u2, xloc = xloc.bar_time, color = color.new(cBull, 25), width = 1, style = line.style_dotted)
            ld2 = line.new(leftX, d2, vwRight, d2, xloc = xloc.bar_time, color = color.new(cBear, 25), width = 1, style = line.style_dotted)
            array.push(linePool, lu2)
            array.push(linePool, ld2)
            labU2 = label.new(vwRight, u2, "VWAP +2σ " + str.tostring(u2, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBull, 45), textcolor = color.white, size = size.tiny)
            labD2 = label.new(vwRight, d2, "VWAP -2σ " + str.tostring(d2, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBear, 45), textcolor = color.white, size = size.tiny)
            array.push(labelPool, labU2)
            array.push(labelPool, labD2)
        if not na(vwapD) and vwapLevels >= 3
            u3 = vwapP + vwapD * vwapMult3
            d3 = vwapP - vwapD * vwapMult3
            lu3 = line.new(leftX, u3, vwRight, u3, xloc = xloc.bar_time, color = color.new(cBull, 35), width = 1, style = line.style_dotted)
            ld3 = line.new(leftX, d3, vwRight, d3, xloc = xloc.bar_time, color = color.new(cBear, 35), width = 1, style = line.style_dotted)
            array.push(linePool, lu3)
            array.push(linePool, ld3)
            labU3 = label.new(vwRight, u3, "VWAP +3σ " + str.tostring(u3, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBull, 55), textcolor = color.white, size = size.tiny)
            labD3 = label.new(vwRight, d3, "VWAP -3σ " + str.tostring(d3, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(cBear, 55), textcolor = color.white, size = size.tiny)
            array.push(labelPool, labU3)
            array.push(labelPool, labD3)
band = na(vaH) ? na : vaTol * vaH
nearLong  = (not needVAedge) or na(valP) or (low  <= valP + band and low  >= valP - band) or (low  <= pocP + band and low  >= pocP - band)
nearShort = (not needVAedge) or na(vahP) or (high <= vahP + band and high >= vahP - band) or (high <= pocP + band and high >= pocP - band)
trendLong  = (not useTrend) or close > emaV
trendShort = (not useTrend) or close < emaV
liqLong  = sweepLow  and close > open
liqShort = sweepHigh and close < open
momLong  = not na(lastPL) and close > lastPL and close > open and close > close[1]
momShort = not na(lastPH) and close < lastPH and close < open and close < close[1]
trigLong  = needSweep ? liqLong  : momLong
trigShort = needSweep ? liqShort : momShort
structLong  = (not needChoch) or recentBosUp or chochUp
structShort = (not needChoch) or recentBosDn or chochDn
confirmed = barstate.isconfirmed
longSig  = enableSignals and confirmed and trigLong  and structLong  and nearLong  and trendLong
shortSig = enableSignals and confirmed and trigShort and structShort and nearShort and trendShort
var int    lastSigBar = na
var string lastSig    = "—"
canSig    = na(lastSigBar) or (bar_index - lastSigBar) >= sigCooldown
longFire  = longSig and canSig
shortFire = shortSig and canSig and not longFire
if longFire
    lastSigBar := bar_index
    lastSig := "BUY"
if shortFire
    lastSigBar := bar_index
    lastSig := "SELL"
plotshape(longFire,  "BUY",       shape.triangleup,   location.belowbar, color = cBull, text = "BUY",  textcolor = color.new(cBull, 0), size = size.small)
plotshape(shortFire, "SELL",      shape.triangledown, location.abovebar, color = cBear, text = "SELL", textcolor = color.new(cBear, 0), size = size.small)
plotshape(longFire,  "BUY glow",  shape.circle,       location.belowbar, color = color.new(cBull, 65), size = size.tiny)
plotshape(shortFire, "SELL glow", shape.circle,       location.abovebar, color = color.new(cBear, 65), size = size.tiny)
alertcondition(longFire,  "APEX VP — BUY",  "APEX VP Left-Lock BUY signal")
alertcondition(shortFire, "APEX VP — SELL", "APEX VP Left-Lock SELL signal")
rangeNow = math.max(high - low, syminfo.mintick)
posInRange = math.max(0.0, math.min(1.0, (close - low) / rangeNow))
buyVolProxy = nz(volume, 0.0) * posInRange
sellVolProxy = nz(volume, 0.0) * (1.0 - posInRange)
buyFlow = ta.sma(buyVolProxy, 20)
sellFlow = ta.sma(sellVolProxy, 20)
totalFlowProxy = buyFlow + sellFlow
bullPct = totalFlowProxy > 0 ? buyFlow / totalFlowProxy * 100.0 : 50.0
bearPct = 100.0 - bullPct
dominanceSide = bullPct > 55 ? "bull" : bearPct > 55 ? "bear" : "neutral"
dominancePct = math.max(bullPct, bearPct)
vaWidthPct = not na(vaH) and close != 0 ? vaH / close * 100.0 : na
vwapDistPct = not na(vwapP) and vwapP != 0 ? (close - vwapP) / vwapP * 100.0 : na
vwapDistTxt = not showVWAP ? "off" : na(vwapDistPct) ? "—" : (vwapDistPct >= 0 ? "+" : "") + str.tostring(vwapDistPct, "#.##") + "%"
vwapTxt = not showVWAP ? "off" : na(vwapP) ? "—" : str.tostring(vwapP, format.mintick)
vwapState = not showVWAP or na(vwapP) ? "neutral" : close > vwapP ? "bull" : close < vwapP ? "bear" : "neutral"
projectionTxt = longFire ? "🚀 buy pressure" : shortFire ? "🩸 sell pressure" : bias > 0 and bullPct >= 55 and (na(pocP) or close >= pocP) ? "↗ bullish" : bias < 0 and bearPct >= 55 and (na(pocP) or close <= pocP) ? "↘ bearish" : "⟷ neutral"
projectionState = str.contains(projectionTxt, "bullish") or str.contains(projectionTxt, "buy") ? "bull" : str.contains(projectionTxt, "bearish") or str.contains(projectionTxt, "sell") ? "bear" : "neutral"
projectionCol = projectionState == "bull" ? pPanelBull : projectionState == "bear" ? pPanelBear : pPanelNeutral
bookTxt = bullPct >= bearPct ? "🟢 bid " + str.tostring(bullPct, "#") + "%" : "🔴 ask " + str.tostring(bearPct, "#") + "%"
bookCol = bullPct >= bearPct ? pPanelBull : pPanelBear
gaugeTxt = f_gauge(bullPct) + " bull " + str.tostring(bullPct, "#") + " / bear " + str.tostring(bearPct, "#")
liqTxt = sweepLow ? "🟢 low sweep" : sweepHigh ? "🔴 high sweep" : "⚪ no sweep"
liqState = sweepLow ? "bull" : sweepHigh ? "bear" : "neutral"
liqCol = liqState == "bull" ? pPanelBull : liqState == "bear" ? pPanelBear : pPanelNeutral
var table dash = na
if showDash and barstate.islast
    pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    if na(dash)
        dash := table.new(pos, 2, 16, border_width = 1, border_color = pPanelLine, frame_width = 1, frame_color = pPanelLine)
    bg = pPanelBg
    loc = na(vahP) ? "—" : close > vahP ? "ABOVE VA" : close < valP ? "BELOW VA" : "INSIDE VA"
    locState = loc == "ABOVE VA" ? "bull" : loc == "BELOW VA" ? "bear" : "neutral"
    locCol = locState == "bull" ? pPanelBull : locState == "bear" ? pPanelBear : pPanelNeutral
    biasStr = bias > 0 ? "🟢 BULLISH" : bias < 0 ? "🔴 BEARISH" : "⚪ NEUTRAL"
    biasState = bias > 0 ? "bull" : bias < 0 ? "bear" : "neutral"
    biasCol = biasState == "bull" ? pPanelBull : biasState == "bear" ? pPanelBear : pPanelNeutral
    sigState = lastSig == "BUY" ? "bull" : lastSig == "SELL" ? "bear" : "neutral"
    sigCol = sigState == "bull" ? pPanelBull : sigState == "bear" ? pPanelBear : pPanelNeutral
    domCol = dominanceSide == "bull" ? pPanelBull : dominanceSide == "bear" ? pPanelBear : pPanelNeutral
    domTxt = dominanceSide == "bull" ? "🟢 bull " + str.tostring(dominancePct, "#") + "%" : dominanceSide == "bear" ? "🔴 bear " + str.tostring(dominancePct, "#") + "%" : "⚪ neutral"
    pocBg = pAccentBg
    neutralBg = pNeutralBg
    locBg = locState == "bull" ? pBullBg : locState == "bear" ? pBearBg : pNeutralBg
    biasBg = biasState == "bull" ? pBullBg : biasState == "bear" ? pBearBg : pNeutralBg
    bookBg = bullPct >= bearPct ? pBullBg : pBearBg
    gaugeBg = bullPct > 55 ? pBullBg : bearPct > 55 ? pBearBg : pNeutralBg
    domBg = dominanceSide == "bull" ? pBullBg : dominanceSide == "bear" ? pBearBg : pNeutralBg
    projBg = projectionState == "bull" ? pBullBg : projectionState == "bear" ? pBearBg : pNeutralBg
    liqBg = liqState == "bull" ? pBullBg : liqState == "bear" ? pBearBg : pNeutralBg
    vwapBg = vwapState == "bull" ? pBullBg : vwapState == "bear" ? pBearBg : pNeutralBg
    sigBg = sigState == "bull" ? pBullBg : sigState == "bear" ? pBearBg : pNeutralBg
    table.cell(dash, 0, 0, "📊 VP AERA ANCHORED", text_color = pPanelText, bgcolor = pPanelHead, text_size = size.small)
    table.cell(dash, 1, 0, "⚓ LEFT LOCK", text_color = pPanelText, bgcolor = color.new(pPanelAccent, 25), text_size = size.small)
    table.cell(dash, 0, 1, "🟡 POC", text_color = pPanelAccent, bgcolor = pocBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, na(pocP) ? "—" : str.tostring(pocP, format.mintick), text_color = pPanelAccent, bgcolor = pocBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 2, "🔼 VAH", text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, na(vahP) ? "—" : str.tostring(vahP, format.mintick), text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 3, "🔽 VAL", text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, na(valP) ? "—" : str.tostring(valP, format.mintick), text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 4, "📍 Price Loc", text_color = locCol, bgcolor = locBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, loc, text_color = locCol, bgcolor = locBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 5, "🧭 Structure", text_color = biasCol, bgcolor = biasBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, biasStr, text_color = biasCol, bgcolor = biasBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 6, "📚 Order Book", text_color = bookCol, bgcolor = bookBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, bookTxt, text_color = bookCol, bgcolor = bookBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 7, "⚖️ Bull vs Bear", text_color = bullPct > 55 ? pPanelBull : bearPct > 55 ? pPanelBear : pPanelNeutral, bgcolor = gaugeBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, gaugeTxt, text_color = bullPct > 55 ? pPanelBull : bearPct > 55 ? pPanelBear : pPanelNeutral, bgcolor = gaugeBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 8, "👑 Dominance", text_color = domCol, bgcolor = domBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, domTxt, text_color = domCol, bgcolor = domBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 9, "🔮 Projection", text_color = projectionCol, bgcolor = projBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 9, projectionTxt, text_color = projectionCol, bgcolor = projBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 10, "💧 Liquidity", text_color = liqCol, bgcolor = liqBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 10, liqTxt, text_color = liqCol, bgcolor = liqBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 11, "📈 VWAP", text_color = vwapState == "bull" ? pPanelBull : vwapState == "bear" ? pPanelBear : pPanelNeutral, bgcolor = vwapBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 11, vwapTxt, text_color = vwapState == "bull" ? pPanelBull : vwapState == "bear" ? pPanelBear : pPanelNeutral, bgcolor = vwapBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 12, "📏 VWAP Dist", text_color = vwapState == "bull" ? pPanelBull : vwapState == "bear" ? pPanelBear : pPanelNeutral, bgcolor = vwapBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 12, vwapDistTxt, text_color = vwapState == "bull" ? pPanelBull : vwapState == "bear" ? pPanelBear : pPanelNeutral, bgcolor = vwapBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 13, "📐 VA Width", text_color = pPanelAccent, bgcolor = pocBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 13, na(vaWidthPct) ? "—" : str.tostring(vaWidthPct, "#.##") + "%", text_color = pPanelAccent, bgcolor = pocBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 14, "⏱ Window", text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 14, str.tostring(winBars) + " bars", text_color = pPanelMuted, bgcolor = neutralBg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 15, "⚡ Last Signal", text_color = sigCol, bgcolor = sigBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 15, lastSig, text_color = sigCol, bgcolor = sigBg, text_size = size.tiny, text_halign = text.align_right)
````
