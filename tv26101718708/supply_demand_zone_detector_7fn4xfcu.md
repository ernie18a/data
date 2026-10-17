# Supply & Demand Zone Detector

- url: https://www.tradingview.com/script/7Fn4xfCU-Supply-Demand-Zone-Detector/
- type: indicator
- pine_id: PUB;e9cb44702ee7435f836994a12bde275f
- version: 1.0

## Description

Automatically detects and marks Supply & Demand zones using price-action structure, rather than fixed pivot lookbacks.

How it works: the script flags a "breakout" candle when its range exceeds a multiple of ATR and its body makes up most of that range (a strong, low-wick move). It then scans backward for the tight consolidation ("base") immediately preceding that candle — candles whose range stays below a smaller ATR multiple. The high/low envelope of that base becomes the zone: a bullish breakout marks Demand, a bearish breakout marks Supply.

Each zone tracks its own state: it draws solid while fresh, and the first time price trades back into it, the zone is marked tested (dashed, faded) and an alert fires. If price later closes cleanly through the far side, the zone is invalidated and removed — so the chart only shows zones that are still structurally valid.

Inputs: ATR length, breakout/base ATR multipliers, max base candles to scan, optional max zone width (in points), max zones kept on chart.

Limitations: this version detects and manages zones only — it does not generate buy/sell entries. [Zone-touch alerts are provided for you to build your own entry rules around.]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sachinlanke


//@version=6
indicator("Supply & Demand Zone Detector", shorttitle="S&D Zones",
     overlay=true, max_boxes_count=500, max_labels_count=500, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ USER INPUTS ═══════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

// ── Breakout (Momentum / Marubozu) Candle Detection ────────────────────────────
atrLength           = input.int(14, "ATR Length", minval=1, group="Breakout Detection")
momentumMultiplier  = input.float(1.5, "Breakout Candle: Min Range (x ATR)", minval=0.5, step=0.1, group="Breakout Detection")
bodyRatioMin        = input.float(0.6, "Breakout Candle: Min Body/Range Ratio", minval=0.1, maxval=1.0, step=0.05, group="Breakout Detection")

// ── Base Detection ──────────────────────────────────────────────────────────────
baseRangeMultiplier = input.float(0.7, "Base Candle: Max Range (x ATR)", minval=0.1, step=0.1, group="Base Detection")
maxBaseCandles      = input.int(3,   "Max Base Candles to Scan Back", minval=1, maxval=10, group="Base Detection")

// ── Zone Rules ───────────────────────────────────────────────────────────────────
maxZoneWidthPoints = input.float(0, "Max Zone Width (points, 0 = no limit)", minval=0, group="Zone Rules")
maxZonesToShow     = input.int(15,  "Max Zones to Keep on Chart", minval=1, maxval=100, group="Zone Rules")
invalidateOnClose  = input.bool(true, "Invalidate Zone on Close Through It", group="Zone Rules")

// ── Display ──────────────────────────────────────────────────────────────────────
showLabels    = input.bool(true, "Show Zone Labels", group="Display")
color DEMAND_FRESH_COLOR  = input.color(#2962ff, "Demand Zone (Fresh)",  group="Display")
color DEMAND_TESTED_COLOR = input.color(#9db8ff, "Demand Zone (Tested)", group="Display")
color SUPPLY_FRESH_COLOR  = input.color(#ff1744, "Supply Zone (Fresh)",  group="Display")
color SUPPLY_TESTED_COLOR = input.color(#ffb3bd, "Supply Zone (Tested)", group="Display")

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ CORE CALCULATIONS ═════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

atrVal        = ta.atr(atrLength)
candleRange   = high - low
candleBody    = math.abs(close - open)
bodyRatio     = candleRange != 0 ? candleBody / candleRange : 0.0

isMomentumCandle = candleRange > momentumMultiplier * atrVal and bodyRatio > bodyRatioMin
isBullMomentum    = isMomentumCandle and close > open
isBearMomentum    = isMomentumCandle and close < open

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ZONE STORAGE (persistent arrays) ══════════════════
// ═══════════════════════════════════════════════════════════════════════════════

var box[]   zoneBoxes    = array.new_box()
var label[] zoneLabels   = array.new_label()
var float[] zoneTop      = array.new_float()
var float[] zoneBottom   = array.new_float()
var bool[]  zoneIsDemand = array.new_bool()
var bool[]  zoneFresh    = array.new_bool()

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ BASE SCAN (find the Base behind a breakout) ═══════
// ═══════════════════════════════════════════════════════════════════════════════

float baseHigh = high[1]
float baseLow  = low[1]
int   baseCount = 0

if isMomentumCandle and barstate.isconfirmed
    for i = 1 to maxBaseCandles
        float rng = high[i] - low[i]
        if rng < baseRangeMultiplier * atrVal
            baseHigh := math.max(baseHigh, high[i])
            baseLow  := math.min(baseLow, low[i])
            baseCount += 1
        else
            break

bool baseFound      = baseCount >= 1
float zoneWidthNow  = baseHigh - baseLow
bool  zoneWidthOK   = maxZoneWidthPoints <= 0 or zoneWidthNow <= maxZoneWidthPoints

bool createDemandZone = isBullMomentum and barstate.isconfirmed and baseFound and zoneWidthOK
bool createSupplyZone = isBearMomentum and barstate.isconfirmed and baseFound and zoneWidthOK

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ZONE CREATION ═════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

if createDemandZone or createSupplyZone
    int leftBar  = bar_index - baseCount
    int rightBar = bar_index
    color boxColor    = createDemandZone ? color.new(DEMAND_FRESH_COLOR, 82) : color.new(SUPPLY_FRESH_COLOR, 82)
    color borderColor = createDemandZone ? DEMAND_FRESH_COLOR : SUPPLY_FRESH_COLOR

    newBox = box.new(leftBar, baseHigh, rightBar, baseLow,
      border_color=borderColor, border_width=1, border_style=line.style_solid,
      bgcolor=boxColor, extend=extend.none)

    array.push(zoneBoxes, newBox)
    array.push(zoneTop, baseHigh)
    array.push(zoneBottom, baseLow)
    array.push(zoneIsDemand, createDemandZone)
    array.push(zoneFresh, true)

    if showLabels
        newLabel = label.new(rightBar, createDemandZone ? baseLow : baseHigh,
          text      = createDemandZone ? "Demand" : "Supply",
          yloc      = createDemandZone ? yloc.belowbar : yloc.abovebar,
          style     = createDemandZone ? label.style_label_up : label.style_label_down,
          color     = color.new(borderColor, 15),
          textcolor = #ffffff,
          size      = size.tiny)
        array.push(zoneLabels, newLabel)
    else
        array.push(zoneLabels, label.new(rightBar, baseLow, text="", size=size.tiny))
        label.delete(array.get(zoneLabels, array.size(zoneLabels) - 1))

    // Cap total zones kept on chart — drop the oldest when over the limit
    if array.size(zoneBoxes) > maxZonesToShow
        box.delete(array.shift(zoneBoxes))
        label.delete(array.shift(zoneLabels))
        array.shift(zoneTop)
        array.shift(zoneBottom)
        array.shift(zoneIsDemand)
        array.shift(zoneFresh)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ZONE MAINTENANCE (freshness / mitigation) ═════════
// ═══════════════════════════════════════════════════════════════════════════════

bool enteredFreshDemand = false
bool enteredFreshSupply = false

if array.size(zoneBoxes) > 0
    for idx = array.size(zoneBoxes) - 1 to 0
        float top    = array.get(zoneTop, idx)
        float bottom = array.get(zoneBottom, idx)
        bool  isDem  = array.get(zoneIsDemand, idx)
        bool  fresh  = array.get(zoneFresh, idx)
        box   b      = array.get(zoneBoxes, idx)

        bool invalidated = false

        if isDem
            // Price traded into the zone
            if fresh and low <= top
                if enteredFreshDemand == false
                    enteredFreshDemand := true
                array.set(zoneFresh, idx, false)
                box.set_border_style(b, line.style_dashed)
                box.set_bgcolor(b, color.new(DEMAND_TESTED_COLOR, 88))
                box.set_border_color(b, DEMAND_TESTED_COLOR)
            // Price closed clean through the bottom — zone is broken
            if invalidateOnClose and close < bottom
                invalidated := true
        else
            if fresh and high >= bottom
                if enteredFreshSupply == false
                    enteredFreshSupply := true
                array.set(zoneFresh, idx, false)
                box.set_border_style(b, line.style_dashed)
                box.set_bgcolor(b, color.new(SUPPLY_TESTED_COLOR, 88))
                box.set_border_color(b, SUPPLY_TESTED_COLOR)
            if invalidateOnClose and close > top
                invalidated := true

        if invalidated
            box.delete(b)
            label.delete(array.get(zoneLabels, idx))
            array.remove(zoneBoxes, idx)
            array.remove(zoneLabels, idx)
            array.remove(zoneTop, idx)
            array.remove(zoneBottom, idx)
            array.remove(zoneIsDemand, idx)
            array.remove(zoneFresh, idx)
        else
            // Extend the box's right edge to the current bar while still active
            box.set_right(b, bar_index)

// ═══════════════════════════════════════════════════════════════════════════════
// ═══════════════════════════ ALERTS ════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(enteredFreshDemand, title="Price Entered Fresh Demand Zone",
  message="SND Zone Engine: price entered a FRESH Demand zone ({{ticker}} {{interval}})")
alertcondition(enteredFreshSupply, title="Price Entered Fresh Supply Zone",
  message="SND Zone Engine: price entered a FRESH Supply zone ({{ticker}} {{interval}})")
````
