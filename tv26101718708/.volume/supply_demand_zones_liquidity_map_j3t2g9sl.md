# Supply & Demand Zones + Liquidity Map

- url: https://www.tradingview.com/script/J3t2G9sl-Supply-Demand-Zones-Liquidity-Map/
- type: indicator
- pine_id: PUB;d002cd82199241328f8783601274c7d5
- version: 1.0

## Description

Overview

Supply & Demand Zones + Liquidity Map plots the two halves of the intraday order-flow map on one chart: where imbalance originated (supply/demand zones) and where resting stop liquidity sits now (equal highs/lows and prior-day extremes). Its signature signal fires when a liquidity run terminates inside a fresh opposing zone — the classic institutional entry footprint.

How It Works

Zones. A zone is born from base-and-departure structure: two to six consecutive tight-range candles (each under a configurable ATR fraction) followed by an impulse bar exceeding 1.5× ATR with a dominant body. The base range becomes the zone. Departure volume above the volume-SMA multiplier marks the zone strong (● tag, heavier border).

Lifecycle. Every zone is a state machine: FRESH (full color) → TESTED (faded on first touch) → BROKEN (removed, or greyed if "Keep Broken Zones" is enabled, when price closes through). Zones expire after a configurable age so the chart never accumulates stale levels.

Liquidity. Equal highs and equal lows — two pivots within an ATR-scaled tolerance — are drawn as dotted stop-pool lines with EQH/EQL tags. Prior-day high and low are plotted as session reference levels.

Confluence. A triangle prints only when sell-side liquidity (prior-day low or an equal-lows pool) is swept and reclaimed while price is inside a fresh demand zone — mirrored for buy-side liquidity into fresh supply.

Signals


Teal/red boxes — demand and supply zones with FRESH/tested/broken states
Dotted orange lines + EQH/EQL tags — resting stop pools
Red/teal horizontal lines — prior-day high and low
Green triangle up / red triangle down — liquidity run terminating inside a fresh zone
Alerts for zone tests, confluence events, and new equal-high/low formation


Recommended Use

Designed for 1-minute to 15-minute intraday trading. Treat fresh strong zones as locations, liquidity pools as targets and traps, and the confluence triangle as the highest-quality context the script can identify. On low-volatility sessions, raise Impulse Range toward 1.8× ATR to filter marginal zones. Pairs naturally with an exhaustion or order-flow confirmation tool for entries.

Limitations

Zone detection is a structural heuristic on OHLCV — it approximates institutional activity and cannot see actual resting orders. Volume profile nodes are intentionally excluded for performance. Signals mark context, not guaranteed reversals. Not financial advice.

## Source Code

````pine
//@version=6
//  Supply & Demand Zones + Liquidity Map v1.0  ("pinescript3")
//  - S/D ZONES: base (2–6 tight candles) + impulse departure (>1.5x ATR, dominant body) → zone box
//    Strong zones require departure volume > multiplier x SMA. Zones track FRESH → TESTED → BROKEN.
//  - LIQUIDITY: equal highs / equal lows (stop pools), prior-day high/low
//  - CONFLUENCE: flags when an equal-low pool sits inside a fresh demand zone (and mirror for supply)

indicator("Supply & Demand Zones + Liquidity Map", "SDZ", overlay = true, scale = scale.right, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────── INPUTS ───────────────────────────
grpZ = "Supply / Demand Zones"
baseMaxRange = input.float(0.75, "Base Candle Max Range (x ATR)", step = 0.05, group = grpZ)
baseMinBars  = input.int(2,   "Min Base Candles", minval = 1,  group = grpZ)
baseMaxBars  = input.int(6,   "Max Base Candles", minval = 2,  group = grpZ)
impulseMult  = input.float(1.5,"Impulse Range (x ATR)", step = 0.1, group = grpZ)
bodyDom      = input.float(0.6,"Impulse Body Dominance", step = 0.05, minval = 0.3, maxval = 0.95, group = grpZ)
volMult      = input.float(1.3,"Strong-Zone Volume Multiplier", step = 0.1, group = grpZ)
maxZones     = input.int(6,   "Max Zones Per Side", minval = 1, maxval = 15, group = grpZ)
zoneMaxAge   = input.int(300, "Zone Max Age (bars)", minval = 50, group = grpZ)
keepBroken   = input.bool(false, "Keep Broken Zones (grey)", group = grpZ)

grpL = "Liquidity"
pivLen  = input.int(10,  "Pivot Left/Right",  group = grpL)
eqTol   = input.float(0.15, "Equal H/L Tolerance (x ATR)", step = 0.05, group = grpL)
liqMaxAge = input.int(300, "Liquidity Line Max Age (bars)", minval = 50, group = grpL)
showEq  = input.bool(true, "Show Equal Highs/Lows", group = grpL)
showPD  = input.bool(true, "Show Prior Day High/Low", group = grpL)

grpUI = "Appearance"
demCss    = input.color(color.new(#26A69A, 78), "Demand Fill",  group = grpUI)
supCss    = input.color(color.new(#EF5350, 78), "Supply Fill",  group = grpUI)
txtSizeIn = input.string("Tiny", "Label Size", options = ["Tiny", "Small", "Normal"], group = grpUI)
txtSz = txtSizeIn == "Tiny" ? size.tiny : txtSizeIn == "Small" ? size.small : size.normal

// ─────────────────────────── CORE ───────────────────────────
atr    = ta.atr(14)
volSma = ta.sma(volume, 20)
rng    = high - low
bodyPct = rng > 0 ? math.abs(close - open) / rng : 0

bullImpulse = close > open and rng > impulseMult * atr and bodyPct > bodyDom
bearImpulse = close < open and rng > impulseMult * atr and bodyPct > bodyDom
strongVol   = volume > volMult * volSma

// Count consecutive tight-range candles immediately before this bar
f_baseBars() =>
    cnt = 0
    for i = 1 to baseMaxBars
        if high[i] - low[i] < baseMaxRange * atr
            cnt += 1
        else
            break
    cnt

f_baseExtremes(int bb) =>
    zt = high[1]
    zb = low[1]
    if bb > 1
        for i = 2 to bb
            zt := math.max(zt, high[i])
            zb := math.min(zb, low[i])
    [zt, zb]

// ─────────────────────────── ZONE STORES ───────────────────────────
// state: 0 = fresh, 1 = tested, 2 = broken
var array<box>   demBx    = array.new<box>()
var array<float> demTop   = array.new<float>()
var array<float> demBot   = array.new<float>()
var array<int>   demBirth = array.new<int>()
var array<int>   demState = array.new<int>()

var array<box>   supBx    = array.new<box>()
var array<float> supTop   = array.new<float>()
var array<float> supBot   = array.new<float>()
var array<int>   supBirth = array.new<int>()
var array<int>   supState = array.new<int>()

f_dropDem(int i) =>
    box.delete(array.get(demBx, i))
    array.remove(demBx, i), array.remove(demTop, i), array.remove(demBot, i), array.remove(demBirth, i), array.remove(demState, i)

f_dropSup(int i) =>
    box.delete(array.get(supBx, i))
    array.remove(supBx, i), array.remove(supTop, i), array.remove(supBot, i), array.remove(supBirth, i), array.remove(supState, i)

// ─────────────────────────── ZONE CREATION ───────────────────────────
if bullImpulse
    bb = f_baseBars()
    if bb >= baseMinBars
        [zt, zb] = f_baseExtremes(bb)
        b = box.new(bar_index - bb, zt, bar_index, zb, border_color = color.new(#26A69A, 40), border_width = strongVol ? 2 : 1, bgcolor = demCss, text = strongVol ? "DEMAND ●" : "DEMAND", text_color = color.new(#26A69A, 20), text_size = txtSz, text_halign = text.align_left)
        array.unshift(demBx, b), array.unshift(demTop, zt), array.unshift(demBot, zb), array.unshift(demBirth, bar_index), array.unshift(demState, 0)
        if array.size(demBx) > maxZones
            f_dropDem(array.size(demBx) - 1)

if bearImpulse
    bb = f_baseBars()
    if bb >= baseMinBars
        [zt, zb] = f_baseExtremes(bb)
        b = box.new(bar_index - bb, zt, bar_index, zb, border_color = color.new(#EF5350, 40), border_width = strongVol ? 2 : 1, bgcolor = supCss, text = strongVol ? "SUPPLY ●" : "SUPPLY", text_color = color.new(#EF5350, 20), text_size = txtSz, text_halign = text.align_left)
        array.unshift(supBx, b), array.unshift(supTop, zt), array.unshift(supBot, zb), array.unshift(supBirth, bar_index), array.unshift(supState, 0)
        if array.size(supBx) > maxZones
            f_dropSup(array.size(supBx) - 1)

// ─────────────────────────── ZONE LIFECYCLE ───────────────────────────
demandTouched = false
supplyTouched = false

if array.size(demBx) > 0
    for i = array.size(demBx) - 1 to 0
        // age expiry
        if bar_index - array.get(demBirth, i) > zoneMaxAge
            f_dropDem(i)
            continue
        b  = array.get(demBx, i)
        zt = array.get(demTop, i)
        zb = array.get(demBot, i)
        st = array.get(demState, i)
        box.set_right(b, bar_index)
        if st < 2
            if close < zb                                  // broken
                if keepBroken
                    array.set(demState, i, 2)
                    box.set_bgcolor(b, color.new(#787B86, 88))
                    box.set_border_color(b, color.new(#787B86, 60))
                    box.set_text(b, "broken")
                else
                    f_dropDem(i)
                    continue
            else if low <= zt and bar_index - array.get(demBirth, i) > 1   // touched (skip creation bar)
                demandTouched := true
                if st == 0
                    array.set(demState, i, 1)
                    box.set_bgcolor(b, color.new(#26A69A, 88))
                    box.set_text(b, "tested")

if array.size(supBx) > 0
    for i = array.size(supBx) - 1 to 0
        if bar_index - array.get(supBirth, i) > zoneMaxAge
            f_dropSup(i)
            continue
        b  = array.get(supBx, i)
        zt = array.get(supTop, i)
        zb = array.get(supBot, i)
        st = array.get(supState, i)
        box.set_right(b, bar_index)
        if st < 2
            if close > zt
                if keepBroken
                    array.set(supState, i, 2)
                    box.set_bgcolor(b, color.new(#787B86, 88))
                    box.set_border_color(b, color.new(#787B86, 60))
                    box.set_text(b, "broken")
                else
                    f_dropSup(i)
                    continue
            else if high >= zb and bar_index - array.get(supBirth, i) > 1
                supplyTouched := true
                if st == 0
                    array.set(supState, i, 1)
                    box.set_bgcolor(b, color.new(#EF5350, 88))
                    box.set_text(b, "tested")

// ─────────────────────────── EQUAL HIGHS / LOWS (stop pools) ───────────────────────────
var array<line> eqLn    = array.new<line>()
var array<int>  eqBirth = array.new<int>()

while array.size(eqBirth) > 0 and bar_index - array.get(eqBirth, array.size(eqBirth) - 1) > liqMaxAge
    line.delete(array.pop(eqLn))
    array.pop(eqBirth)

pl = ta.pivotlow(low, pivLen, pivLen)
ph = ta.pivothigh(high, pivLen, pivLen)

var float lastPl = na
var int   lastPlBar = na
var float lastPh = na
var int   lastPhBar = na

eqLowNow  = false
eqHighNow = false

if not na(pl)
    if showEq and not na(lastPl) and math.abs(pl - lastPl) <= eqTol * atr
        eqLowNow := true
        array.unshift(eqLn, line.new(lastPlBar, (pl + lastPl) / 2, bar_index - pivLen, (pl + lastPl) / 2, color = color.new(#FF9800, 20), style = line.style_dotted, width = 2))
        array.unshift(eqBirth, bar_index)
        label.new(bar_index - pivLen, pl, "EQL", style = label.style_label_up, color = color.new(#FF9800, 70), textcolor = color.white, size = size.tiny, tooltip = "Equal lows — resting sell-stop pool")
    lastPl := pl
    lastPlBar := bar_index - pivLen

if not na(ph)
    if showEq and not na(lastPh) and math.abs(ph - lastPh) <= eqTol * atr
        eqHighNow := true
        array.unshift(eqLn, line.new(lastPhBar, (ph + lastPh) / 2, bar_index - pivLen, (ph + lastPh) / 2, color = color.new(#FF9800, 20), style = line.style_dotted, width = 2))
        array.unshift(eqBirth, bar_index)
        label.new(bar_index - pivLen, ph, "EQH", style = label.style_label_down, color = color.new(#FF9800, 70), textcolor = color.white, size = size.tiny, tooltip = "Equal highs — resting buy-stop pool")
    lastPh := ph
    lastPhBar := bar_index - pivLen

// ─────────────────────────── PRIOR DAY HIGH / LOW ───────────────────────────
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
plot(showPD ? pdh : na, "Prior Day High", color.new(#EF5350, 45), 1, plot.style_line, display = display.pane)
plot(showPD ? pdl : na, "Prior Day Low",  color.new(#26A69A, 45), 1, plot.style_line, display = display.pane)

// ─────────────────────────── CONFLUENCE: liquidity run INTO a zone ───────────────────────────
// Sell-side liquidity taken (new EQL break or PDL wick) while inside a fresh demand zone → high-quality long context. Mirror for supply.
inFreshDemand = false
if array.size(demBx) > 0
    for i = 0 to array.size(demBx) - 1
        if array.get(demState, i) == 0 and low <= array.get(demTop, i) and close >= array.get(demBot, i)
            inFreshDemand := true
            break
inFreshSupply = false
if array.size(supBx) > 0
    for i = 0 to array.size(supBx) - 1
        if array.get(supState, i) == 0 and high >= array.get(supBot, i) and close <= array.get(supTop, i)
            inFreshSupply := true
            break

pdlRun = showPD and low < pdl and close > pdl
pdhRun = showPD and high > pdh and close < pdh

demandConfluence = inFreshDemand and (pdlRun or eqLowNow)
supplyConfluence = inFreshSupply and (pdhRun or eqHighNow)

plotshape(demandConfluence, "Liquidity Demand", shape.triangleup,   location.belowbar, color.new(#26A69A, 0), size = size.small, display = display.pane)
plotshape(supplyConfluence, "Liquidity Supply", shape.triangledown, location.abovebar, color.new(#EF5350, 0), size = size.small, display = display.pane)

// ─────────────────────────── ALERTS ───────────────────────────
alertcondition(demandTouched,     "Demand Zone Tested",  "SDZ: Price tested a demand zone")
alertcondition(supplyTouched,     "Supply Zone Tested",  "SDZ: Price tested a supply zone")
alertcondition(demandConfluence,  "Liquidity → Demand",  "SDZ: Liquidity run terminated inside fresh demand")
alertcondition(supplyConfluence,  "Liquidity → Supply",  "SDZ: Liquidity run terminated inside fresh supply")
alertcondition(eqLowNow,          "Equal Lows Formed",   "SDZ: Equal lows — sell-stop pool marked")
alertcondition(eqHighNow,         "Equal Highs Formed",  "SDZ: Equal highs — buy-stop pool marked")
````
