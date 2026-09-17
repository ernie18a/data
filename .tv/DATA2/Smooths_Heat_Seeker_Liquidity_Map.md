<!-- tradingview-pine-id: PUB;c09aa09617f840e8abd6d17ee311a9f1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Smooths Heat Seeker Liquidity Map

Source: https://www.tradingview.com/script/wu2nTEtg-Smooths-Heat-Seeker-Liquidity-Map/

## Description

Overview
This indicator maps resting liquidity by detecting confirmed swing highs and lows at three independent lookback lengths, then rendering each one as a zone that visibly fades the longer it goes untouched. Instead of a static box that holds one shade until it's swept, each zone is built from small time-segments, and each segment locks in whatever color the zone's fade formula produces at the moment it's drawn — so a single zone shows a genuine gradient across its own lifetime, brightest where it formed and dimmer toward the present if nothing has happened to it since.

Concepts used

[*]Tiered pivot detection: ta.pivothigh()/ta.pivotlow() run at three separate lookback lengths (Fast/Mid/Slow). A pivot only confirms after "Confirmation Bars" bars have passed with no higher high / lower low, which is what prevents repainting the level's location after the fact.
[*]Age-based color decay: each level stores the bar index it was formed on. Every time a new segment is drawn, the indicator computes how many bars old the level is, runs that through a decay curve (fadeStrength input controls the curve's steepness), and converts the result into a transparency value for that segment only. Because past segments are never redrawn, the visual history of the fade is preserved rather than the whole zone jumping to one shade at once.
[*]Mitigation vs. retest: a level is deleted the instant price crosses it (wick or close, user's choice) — that's treated as the liquidity being consumed. If price merely touches the level without crossing it, and "Refresh Fade On Retest" is on, the level's age resets to zero, so a level that keeps getting defended stays bright while one that's simply being ignored keeps fading toward removal.
[*]Tier-priority merging: if a new pivot lands at the same price as an existing level, the indicator keeps the higher tier rather than creating a duplicate zone, so a level significant on the Slow lookback doesn't get visually diluted by a Fast-tier duplicate sitting on top of it.

How to use it
Add it to any chart/timeframe with default settings. Brighter zones are recent or actively-retested liquidity; dimmer zones are levels the market has drifted away from without touching. Use Fast/Mid/Slow tier colors to separate minor intraday levels from more structurally significant ones, and adjust Fade/Lifetime, Fade Strength, and Cell Width to control how far back the map looks and how coarse or smooth the fade appears.

Originality
This is not a combination of other publications — there's a single detection-and-rendering pipeline here (pivot detection → age tracking → per-segment decay → mitigation/retest handling), and every part of it was written for this script. No code, calculations, or visual techniques are reused from another publication.

Inputs

[*]Fast / Mid / Slow — pivot lookback lengths for the three liquidity tiers
[*]Confirmation Bars — bars required after a swing point before it's confirmed
[*]Mitigate On — wick or close removes a level
[*]Fade/Lifetime, Fade Strength, Cell Width — control how long a zone lives and how its decay curve is shaped
[*]Refresh Fade On Retest — restarts a zone's age on an unmitigated touch
[*]Box Height Multiplier — sets zone thickness as a multiple of ATR
[*]Weak / Mid / Strong colors — one color per tier

This indicator has no signals, alerts, or trade markers — it's a pure visualization of where liquidity currently sits on the chart, and how fresh or stale each level is.

---

## Source Code

````pine
//@version=6
indicator("Smooths Heat Seeker Liquidity Map", " Smooths Heat Seeker Liquidity Map", overlay = true, max_boxes_count = 500)

// ---------------- Inputs ----------------
grpLevels  = "Levels"
grpFade    = "Fade (Controls Lookback)"
grpVisuals = "Visuals"
grpColors  = "Colors"

fastLen     = input.int(14, "Fast", minval = 2, group = grpLevels, inline = "lb")
midLen      = input.int(42, "Mid", minval = 2, group = grpLevels, inline = "lb")
slowLen     = input.int(120, "Slow", minval = 2, group = grpLevels, inline = "lb", tooltip = "Pivot lookbacks for the three liquidity tiers. Longer lookback = more significant level = stronger tier color.")
confirmBars = input.int(3, "Confirmation Bars", minval = 1, group = grpLevels)
mitigateOn  = input.string("Wick", "Mitigate On", options = ["Wick", "Close"], group = grpLevels)

fadeBars        = input.int(400, "Fade / Lifetime (bars)", minval = 10, group = grpFade, tooltip = "Bars for a zone to fully fade out. Increase this to look back further in time.")
fadeStrength    = input.float(70, "Fade Strength", minval = 0.0, maxval = 100.0, step = 5.0, group = grpFade, tooltip = "0 = no fade. 100 = tail disappears fast.")
cellBars        = input.int(4, "Cell Width (bars)", minval = 1, maxval = 100, group = grpFade, tooltip = "Width of each segment. Lower = more boxes = smoother fade.")
refreshOnRetest = input.bool(true, "Refresh Fade On Retest", group = grpFade, tooltip = "If price wicks into a zone without mitigating it, restart that zone's fade clock. Only applies when Mitigate On = Close.")

boxHeightMult = input.float(0.08, "Box Height Multiplier (ATR)", minval = 0.01, step = 0.01, group = grpVisuals, tooltip = "Adjusts the thickness of the boxes.")

colorWeak   = input.color(color.rgb(140, 0, 255), "Weak (Fast)", inline = "cols", group = grpColors)
colorMid    = input.color(#00ffbb, "Mid", inline = "cols", group = grpColors)
colorStrong = input.color(#ff6a00, "Strong (Slow)", inline = "cols", group = grpColors, tooltip = "Colour applied per tier. Same-price pivots keep the strongest tier so Strong actually shows.")

// ---------------- Constants ----------------
const int ATR_LEN    = 14
const int POOL_LIMIT = 480

// ---------------- State ----------------
var float[] upPrice  = array.new_float()
var int[]   upBorn   = array.new_int()
var int[]   upTier   = array.new_int()
var int[]   upCellX  = array.new_int()
var float[] upHeight = array.new_float()

var float[] dnPrice  = array.new_float()
var int[]   dnBorn   = array.new_int()
var int[]   dnTier   = array.new_int()
var int[]   dnCellX  = array.new_int()
var float[] dnHeight = array.new_float()

var box[] boxPool = array.new_box()

// ---------------- Helpers ----------------
f_tierColor(int t) =>
    t == 3 ? colorStrong : t == 2 ? colorMid : colorWeak

f_fadeSpan() =>
    amt = fadeStrength / 100.0
    math.max(float(cellBars), float(fadeBars) * math.max(0.12, 1.0 - amt * 0.80))

f_fadeColor(color base, int born) =>
    if fadeStrength <= 0
        color.new(base, 8)
    else
        ageRatio = math.min(1.0, math.max(0.0, (bar_index - born) / f_fadeSpan()))
        fade     = math.pow(ageRatio, 1.15)
        color.new(base, math.round(4 + fade * 95))

f_addLevel(float[] prices, int[] borns, int[] tiers, int[] cellXs, float[] heights, float price, int tier, float h) =>
    int found = -1
    if array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            if math.abs(array.get(prices, i) - price) <= syminfo.mintick
                found := i
                break
    if found >= 0
        if tier > array.get(tiers, found)
            array.set(tiers, found, tier)
    else
        array.push(prices, price)
        array.push(borns, bar_index - confirmBars)
        array.push(tiers, tier)
        array.push(cellXs, bar_index - confirmBars)
        array.push(heights, h)

f_pushBox(box b) =>
    array.push(boxPool, b)
    if array.size(boxPool) > POOL_LIMIT
        box.delete(array.shift(boxPool))

// ---------------- ATR (height is frozen per level at birth) ----------------
atrVal     = ta.atr(ATR_LEN)
cellHeight = atrVal * boxHeightMult

// ---------------- Level detection ----------------
ph1 = ta.pivothigh(fastLen, confirmBars)
ph2 = ta.pivothigh(midLen, confirmBars)
ph3 = ta.pivothigh(slowLen, confirmBars)
pl1 = ta.pivotlow(fastLen, confirmBars)
pl2 = ta.pivotlow(midLen, confirmBars)
pl3 = ta.pivotlow(slowLen, confirmBars)

if not na(ph1)
    f_addLevel(upPrice, upBorn, upTier, upCellX, upHeight, ph1, 1, cellHeight)
if not na(ph2)
    f_addLevel(upPrice, upBorn, upTier, upCellX, upHeight, ph2, 2, cellHeight)
if not na(ph3)
    f_addLevel(upPrice, upBorn, upTier, upCellX, upHeight, ph3, 3, cellHeight)
if not na(pl1)
    f_addLevel(dnPrice, dnBorn, dnTier, dnCellX, dnHeight, pl1, 1, cellHeight)
if not na(pl2)
    f_addLevel(dnPrice, dnBorn, dnTier, dnCellX, dnHeight, pl2, 2, cellHeight)
if not na(pl3)
    f_addLevel(dnPrice, dnBorn, dnTier, dnCellX, dnHeight, pl3, 3, cellHeight)

// ---------------- Mitigation / retest / fade-out / cell drawing ----------------
mitigateHigh = mitigateOn == "Wick" ? high : close
mitigateLow  = mitigateOn == "Wick" ? low : close

// Process Upside Liquidity
if array.size(upPrice) > 0
    for i = array.size(upPrice) - 1 to 0
        p  = array.get(upPrice, i)
        b  = array.get(upBorn, i)
        t  = array.get(upTier, i)
        cx = array.get(upCellX, i)
        h  = array.get(upHeight, i)

        mitigated = mitigateHigh >= p
        retest    = not mitigated and high >= p and low <= p
        visGone   = fadeStrength > 0 and (bar_index - b >= f_fadeSpan())

        if mitigated or bar_index - b >= fadeBars or visGone
            array.remove(upPrice, i)
            array.remove(upBorn, i)
            array.remove(upTier, i)
            array.remove(upCellX, i)
            array.remove(upHeight, i)
        else
            if retest and refreshOnRetest
                array.set(upBorn, i, bar_index)
                b := bar_index
            if bar_index - cx >= cellBars
                c = f_fadeColor(f_tierColor(t), b)
                f_pushBox(box.new(cx, p + h, bar_index, p - h, border_color = na, bgcolor = c))
                array.set(upCellX, i, bar_index)

// Process Downside Liquidity
if array.size(dnPrice) > 0
    for i = array.size(dnPrice) - 1 to 0
        p  = array.get(dnPrice, i)
        b  = array.get(dnBorn, i)
        t  = array.get(dnTier, i)
        cx = array.get(dnCellX, i)
        h  = array.get(dnHeight, i)

        mitigated = mitigateLow <= p
        retest    = not mitigated and low <= p and high >= p
        visGone   = fadeStrength > 0 and (bar_index - b >= f_fadeSpan())

        if mitigated or bar_index - b >= fadeBars or visGone
            array.remove(dnPrice, i)
            array.remove(dnBorn, i)
            array.remove(dnTier, i)
            array.remove(dnCellX, i)
            array.remove(dnHeight, i)
        else
            if retest and refreshOnRetest
                array.set(dnBorn, i, bar_index)
                b := bar_index
            if bar_index - cx >= cellBars
                c = f_fadeColor(f_tierColor(t), b)
                f_pushBox(box.new(cx, p + h, bar_index, p - h, border_color = na, bgcolor = c))
                array.set(dnCellX, i, bar_index)
````
