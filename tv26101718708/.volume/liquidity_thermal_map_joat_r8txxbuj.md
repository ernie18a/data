# Liquidity Thermal Map [JOAT]

- url: https://www.tradingview.com/script/R8txXbUj-Liquidity-Thermal-Map-JOAT/
- type: indicator
- pine_id: PUB;b2a6b9d37e2c478bbc18d42ffa0bc059
- version: 1.0

## Description

[b]Liquidity Thermal Map [JOAT][/b]

[b]Introduction[/b]

The Liquidity Thermal Map is an overlay indicator that identifies and visualizes [i]liquidity pockets[/i] — price zones where trapped participants are likely clustered — and ranks their significance using a heat-mapped color scale driven by volume and price range data. Rather than treating all swing highs and lows equally, it weights each zone by the liquidity activity present at that pivot bar, then applies power-law contrast stretching so that the most significant zones immediately stand out from background noise.

The goal is not to predict where price will go. The goal is to surface which untested zones carry the most liquidity weight, so a trader can make their own informed decisions about potential targets or areas of interest.

[image]https://www.tradingview.com/x/P5PNdCQ6/[/image]
---

[b]Core Concepts[/b]

[b]1. Pivot Detection[/b]

Zones are seeded at confirmed swing pivots using Pine Script's built-in pivot functions:

[pine]
pivH = ta.pivothigh(high, leftPiv, rightPiv)
pivL = ta.pivotlow(low, leftPiv, rightPiv)
[/pine]

A pivot high marks a bar where bears may have been trapped above — price reached that level, reversed, and left unfilled orders behind. A pivot low marks the mirror situation for trapped bulls. The [b]left bars[/b] and [b]right bars[/b] inputs control how many confirming bars are required on each side, balancing sensitivity against noise.

[b]2. Liquidity Metric and Heat Normalization[/b]

Each pivot is scored using one of three selectable metrics:

[list]
[*][b]Vol x Range (default):[/b] volume * (high - low) * 100 — rewards bars with both high volume and wide price movement
[*][b]Volume only:[/b] raw volume at the pivot bar
[*][b]Range only:[/b] the high-low spread at the pivot bar
[/list]

Raw scores are normalized across all active pockets using a rolling min-max calculation:

[pine]
norm = (metric - min) / (max - min)
heat = math.pow(norm, heatContrast)
[/pine]

The power-law contrast stretch (controlled by the [b]Heat Contrast[/b] input) compresses lower-significance pockets toward zero and expands higher-significance ones toward one. A contrast value below 1.0 spreads pockets more evenly; above 1.0, only the highest-scoring pockets register strong color.

[b]3. Zone Construction[/b]

Each pocket is drawn as a box:

[list]
[*][b]Short liquidity pocket[/b] (at a pivot HIGH, bears trapped above): top = pivotHigh + ATR * bandWidth, bottom = pivotHigh
[*][b]Long liquidity pocket[/b] (at a pivot LOW, bulls trapped below): top = pivotLow, bottom = pivotLow - ATR * bandWidth
[/list]

ATR scaling ensures band width adapts to current volatility rather than using a fixed pip or point value. Short pockets color from yellow (low heat) through deeper yellows. Long pockets color from a faded cyan through solid cyan-blue. Both gradients are computed with [pine]color.from_gradient(heat, 0, 1, faded_base, solid_base)[/pine], making the heat ranking immediately readable at a glance.

[b]4. Three-State Lifecycle[/b]

Every pocket passes through a defined state machine:

[list]
[*][b]Active:[/b] The zone is untested. The box extends rightward each bar by the [b]Extend Bars[/b] amount, keeping it visible on the current chart.
[*][b]Hit (Frozen):[/b] Triggered when price sweeps through the midpoint of the zone (high >= midpoint AND low <= midpoint on the same bar). The box stops extending, color fades, and the label is removed — signaling that the pocket has been swept and liquidity likely absorbed.
[*][b]Expired:[/b] When a pocket's age exceeds the [b]Lookback[/b] setting without being hit, it is removed entirely and all associated arrays are cleaned up.
[/list]

This lifecycle gives real-time feedback: solid, bright zones are intact and untested; faded zones have been swept; only the most recent, significant pockets within your lookback window are visible.

[b]5. Scale Legend[/b]

A 24-cell gradient table is drawn on-chart running from the short liquidity color to the long liquidity color, providing a continuous reference for the heat scale being applied to all visible pockets.

---

[b]Features[/b]

[list]
[*]Pivot-anchored liquidity zones for both long and short trapped-participant scenarios
[*]Three selectable liquidity metrics: Vol x Range, Volume only, Range only
[*]Power-law contrast stretching for visual prioritization of high-significance zones
[*]ATR-scaled zone width that adapts to current market volatility
[*]Three-state lifecycle (Active → Hit → Expired) per pocket with visual state changes
[*]Dual-color gradient system — cyan-blue for long pockets, yellow for short pockets
[*]On-chart 24-cell heat scale legend
[*]Configurable max pocket count to manage chart performance
[*]Visual toggles for boxes, labels, and the legend table
[/list]

---
[image]https://www.tradingview.com/x/0bHcwve8/[/image]

[b]Input Parameters[/b]

[list]
[*][b]Pivot Left Bars (default 10):[/b] Bars required to the left of a pivot for confirmation. Higher values = fewer, more significant pivots.
[*][b]Pivot Right Bars (default 5):[/b] Bars required to the right of a pivot for confirmation. Increasing this delays detection but improves pivot quality.
[*][b]Lookback / Max Age (default 200):[/b] Maximum bar age before a pocket expires and is removed.
[*][b]Max Pockets (default 50):[/b] Upper limit on simultaneous active pockets. Reducing this improves performance on lower-end charts.
[*][b]ATR Length (default 14):[/b] Period for the ATR calculation used in band width scaling.
[*][b]ATR Band Width (default 0.5):[/b] Multiplier applied to ATR to set zone height. Higher values create wider zones.
[*][b]Extend Bars (default 50):[/b] How many bars ahead each active pocket box extends on each update.
[*][b]Heat Contrast (default 0.5):[/b] Power-law exponent for contrast stretching. Values below 1.0 spread pockets more evenly; above 1.0 increases contrast between high and low scoring zones.
[*][b]Metric Mode:[/b] Selects the liquidity scoring metric — Vol x Range, Volume, or Range.
[*][b]Show Boxes / Show Labels / Show Legend:[/b] Individual visibility toggles for each visual component.
[/list]

---

[b]How to Use[/b]

[b]Identifying high-priority zones:[/b] Bright, fully saturated boxes represent the highest-scoring untested liquidity pockets within your lookback window. These are the zones where the most volume-weighted trapped participants may be present.

[b]Tracking swept zones:[/b] When a box fades, the pocket has been hit — price moved through its midpoint. Faded zones can serve as reference for areas that have already seen liquidity absorption.

[b]Adjusting sensitivity:[/b] Increasing the left/right pivot bars reduces the total number of pivots detected, focusing only on more structurally significant swing points. Decreasing them creates a denser map suitable for shorter timeframes.

[b]Interpreting the legend:[/b] The 24-cell scale legend in the corner maps the full gradient range, from the lowest-heat short pocket color to the highest-heat long pocket color.

[b]Timeframe considerations:[/b] On higher timeframes (4H, Daily), fewer pivots form and each carries more weight. On lower timeframes, tightening the ATR band width and increasing heat contrast helps reduce visual clutter.

---

[b]Limitations[/b]

[list]
[*]Pivot detection is inherently lagging — a pivot is only confirmed after the right-side bars have closed, meaning the zone is plotted some bars after the pivot actually formed.
[*]The liquidity metric scores a pocket by activity at the [i]pivot bar itself[/i], not the full swing sequence leading to it. A pivot formed on a single high-volume bar will score higher than one formed over a gradual, multi-bar move.
[*]Volume data quality varies by broker and data feed. On instruments with unreliable or synthetic volume (some forex pairs, CFDs), the Vol x Range metric may not reflect true market participation.
[*]The indicator does not account for partial fills or iceberg orders. A zone being "hit" means price swept through the midpoint — it does not confirm full liquidity absorption.
[*]No indicator, including this one, predicts future price movement. A high-heat untested zone is an area of potential interest, not a guaranteed reversal or reaction point.
[*]Performance may degrade on very active charts with high Max Pocket settings. Reduce Max Pockets if chart rendering slows.
[*]The heat scale is relative to the current set of visible pockets. Adding more historical data (longer lookback) changes the normalization range and will recolor all currently visible pockets.
[/list]

---

[b]Originality Statement[/b]

Most liquidity mapping tools mark swing highs and lows with equal visual weight — every pivot gets the same line, box, or label. This indicator departs from that approach in three ways:

[b]First[/b], each pocket is scored by the product of volume and price range at its pivot bar (or volume/range alone as alternatives), producing a liquidity significance score rather than a binary present/absent mark.

[b]Second[/b], power-law contrast stretching is applied to the normalized scores, which means the visual encoding (color saturation) is non-linear. Minor pockets compress toward the faded end of the gradient; truly significant pockets expand toward the saturated end. This is a deliberate perceptual design choice — not simply coloring zones by value, but stretching the gradient to maximize discriminability at the high end.

[b]Third[/b], the three-state lifecycle (Active → Hit → Expired) treats each pocket as a dynamic object that responds to price action in real time. The visual state change on hit provides immediate feedback without requiring the trader to manually track which levels have been tested. The combination of significance scoring, contrast-stretched heat mapping, and lifecycle state management in a single overlay tool is the core contribution of this indicator.

---

[b]Disclaimer[/b]

[i]This indicator is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any asset. Past behavior of price around liquidity zones does not guarantee future behavior. All trading involves risk. You are solely responsible for your own trading decisions.[/i]

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Liquidity Thermal Map [JOAT]", shorttitle="LTM [JOAT]", overlay=true, max_boxes_count=500, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpPiv   = "Pivot Detection"
leftPiv  = input.int(10, "Pivot Left Bars",  minval=2, maxval=50, group=grpPiv)
rightPiv = input.int(5,  "Pivot Right Bars", minval=1, maxval=20, group=grpPiv)
lookback = input.int(200, "Lookback / Max Pockets", minval=50, maxval=500, group=grpPiv)

grpZone  = "Zone Geometry"
atrLen   = input.int(14, "ATR Length", minval=1, maxval=50, group=grpZone)
atrBand  = input.float(0.5, "ATR Band Width", minval=0.1, maxval=3.0, step=0.05, group=grpZone)
extendBars = input.int(50, "Default Extend (bars)", minval=5, maxval=300, group=grpZone)

grpHeat  = "Heat Coloring"
heatContrast = input.float(0.5, "Heat Contrast (power-law)", minval=0.1, maxval=3.0, step=0.05, group=grpHeat)
metricMode   = input.string("VolxRange", "Metric Mode", options=["VolxRange","Volume","Range"], group=grpHeat)

grpVis   = "Visual"
showLong  = input.bool(true, "Show Long Liq Pockets", group=grpVis)
showShort = input.bool(true, "Show Short Liq Pockets", group=grpVis)
showLegend = input.bool(true, "Show Scale Legend", group=grpVis)
showLabels = input.bool(true, "Show Pocket Labels", group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
longColor  = color.rgb(1, 196, 254)    // cyan-blue for long liquidation
shortColor = color.rgb(255, 230, 0)    // yellow for short liquidation
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)
neutralCol = color.rgb(130, 140, 160)

// ─────────────────────────────────────────────────────────────────────────────
// LIQUIDITY METRIC CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
liqMetric = switch metricMode
    "VolxRange" => volume * (high - low) * 100.0
    "Volume"    => volume * 1.0
    "Range"     => (high - low) * 10000.0
    => volume * (high - low) * 100.0

vMax = ta.highest(liqMetric, lookback)
vMin = ta.lowest(liqMetric, lookback)

// Normalized heat value with power-law contrast
get_heat(weight) =>
    rangeW = math.max(vMax - vMin, syminfo.mintick)
    norm   = math.max(0.0, math.min(1.0, (weight - vMin) / rangeW))
    math.pow(norm, heatContrast)

// Color from gradient using heat value
get_pocket_color(isLong, heat) =>
    baseCol = isLong ? longColor : shortColor
    color.from_gradient(heat, 0.0, 1.0, color.new(baseCol, 90), color.new(baseCol, 5))

// ─────────────────────────────────────────────────────────────────────────────
// PIVOT DETECTION
// ─────────────────────────────────────────────────────────────────────────────
atr14    = ta.atr(atrLen)
band     = atr14 * atrBand

pivotH   = ta.pivothigh(high, leftPiv, rightPiv)
pivotL   = ta.pivotlow(low,  leftPiv, rightPiv)

// ─────────────────────────────────────────────────────────────────────────────
// POCKET STORAGE ARRAYS
// ─────────────────────────────────────────────────────────────────────────────
var box[]   pockets       = array.new<box>()
var int[]   pocketSide    = array.new<int>()      // 1=long, -1=short
var bool[]  pocketHit     = array.new<bool>()
var bool[]  pocketFrozen  = array.new<bool>()
var float[] pocketW       = array.new<float>()
var int[]   pocketLeft    = array.new<int>()
var float[] pocketTop     = array.new<float>()
var float[] pocketBot     = array.new<float>()
var label[] pocketLabels  = array.new<label>()

// ─────────────────────────────────────────────────────────────────────────────
// ADD NEW POCKETS
// ─────────────────────────────────────────────────────────────────────────────
// Short liq pocket at pivot high (bears trapped above)
if not na(pivotH) and showShort
    pivH      = pivotH
    pivBar    = bar_index - rightPiv
    heatVal   = get_heat(liqMetric[rightPiv])
    pktColor  = get_pocket_color(false, heatVal)
    topPrice  = pivH + band
    botPrice  = pivH

    bx = box.new(
      pivBar, topPrice, bar_index, botPrice,
      border_color=color.new(shortColor, 45),
      border_width=1,
      bgcolor=color.new(shortColor, 88))

    array.push(pockets,      bx)
    array.push(pocketSide,   -1)
    array.push(pocketHit,    false)
    array.push(pocketFrozen, false)
    array.push(pocketW,      heatVal)
    array.push(pocketLeft,   pivBar)
    array.push(pocketTop,    topPrice)
    array.push(pocketBot,    botPrice)

    label lbl = na
    if showLabels
        lbl := label.new(pivBar, topPrice,
          text="SLiq " + str.tostring(heatVal, "#.##"),
          style=label.style_label_down,
          color=color.new(shortColor, 30),
          textcolor=bgDark,
          size=size.tiny)
    array.push(pocketLabels, lbl)

// Long liq pocket at pivot low (longs trapped below)
if not na(pivotL) and showLong
    pivL      = pivotL
    pivBar    = bar_index - rightPiv
    heatVal   = get_heat(liqMetric[rightPiv])
    pktColor  = get_pocket_color(true, heatVal)
    topPrice  = pivL
    botPrice  = pivL - band

    bx = box.new(
      pivBar, topPrice, bar_index, botPrice,
      border_color=color.new(longColor, 45),
      border_width=1,
      bgcolor=color.new(longColor, 88))

    array.push(pockets,      bx)
    array.push(pocketSide,   1)
    array.push(pocketHit,    false)
    array.push(pocketFrozen, false)
    array.push(pocketW,      heatVal)
    array.push(pocketLeft,   pivBar)
    array.push(pocketTop,    topPrice)
    array.push(pocketBot,    botPrice)

    label lbl = na
    if showLabels
        lbl := label.new(pivBar, botPrice,
          text="LLiq " + str.tostring(heatVal, "#.##"),
          style=label.style_label_up,
          color=color.new(longColor, 30),
          textcolor=bgDark,
          size=size.tiny)
    array.push(pocketLabels, lbl)

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE POCKET LIFECYCLE (extend, hit-detect, expire)
// ─────────────────────────────────────────────────────────────────────────────
extendRight = math.min(extendBars, 499)

if array.size(pockets) > 0
    i = 0
    while i < array.size(pockets)
        frozen = array.get(pocketFrozen, i)
        leftBI = array.get(pocketLeft, i)

        // Expire old pockets beyond lookback
        if bar_index - leftBI > lookback
            box.delete(array.get(pockets, i))
            lbl_exp = array.get(pocketLabels, i)
            if not na(lbl_exp)
                label.delete(lbl_exp)
            array.remove(pockets,      i)
            array.remove(pocketSide,   i)
            array.remove(pocketHit,    i)
            array.remove(pocketFrozen, i)
            array.remove(pocketW,      i)
            array.remove(pocketLeft,   i)
            array.remove(pocketTop,    i)
            array.remove(pocketBot,    i)
            array.remove(pocketLabels, i)
            continue

        topP = array.get(pocketTop, i)
        botP = array.get(pocketBot, i)
        mid  = (topP + botP) * 0.5
        side = array.get(pocketSide, i)
        bx   = array.get(pockets, i)

        if not frozen
            // Extend right by bar count
            box.set_right(bx, bar_index + extendRight)

            // Hit detection: price sweeps the pocket midpoint
            hit = high >= mid and low <= mid
            if hit
                array.set(pocketHit,    i, true)
                array.set(pocketFrozen, i, true)
                // Freeze and fade
                box.set_right(bx, bar_index)
                box.set_border_color(bx, color.new(side == 1 ? longColor : shortColor, 70))
                box.set_bgcolor(bx, color.new(side == 1 ? longColor : shortColor, 94))
                // Remove label on hit
                lbl_h = array.get(pocketLabels, i)
                if not na(lbl_h)
                    label.delete(lbl_h)
                    array.set(pocketLabels, i, na)
        i += 1

// ─────────────────────────────────────────────────────────────────────────────
// SCALE LEGEND TABLE (color gradient)
// ─────────────────────────────────────────────────────────────────────────────
var table legend = na
legendCells = 24

if showLegend
    if na(legend)
        legend := table.new(position.middle_right, 3, legendCells + 3,
          bgcolor=color.new(bgDark, 20),
          border_color=color.new(neutralCol, 70),
          border_width=1)

    table.cell(legend, 0, 0, "LTM [JOAT]", text_color=textLight,
      text_size=size.tiny, text_font_family=font.family_monospace,
      text_halign=text.align_center, bgcolor=color.new(bgDark, 5))
    table.cell(legend, 1, 0, "", bgcolor=color.new(bgDark, 5))
    table.cell(legend, 2, 0, "", bgcolor=color.new(bgDark, 5))

    table.cell(legend, 0, 1, "SHORT", text_color=shortColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(legend, 1, 1, "|", text_color=textDim, text_size=size.tiny)
    table.cell(legend, 2, 1, "LONG", text_color=longColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    for ci = 0 to legendCells - 1
        frac     = float(ci) / float(legendCells - 1)
        // Blend from shortColor (left) to longColor (right)
        r = int(float(color.r(shortColor)) + (float(color.r(longColor)) - float(color.r(shortColor))) * frac)
        g = int(float(color.g(shortColor)) + (float(color.g(longColor)) - float(color.g(shortColor))) * frac)
        b = int(float(color.b(shortColor)) + (float(color.b(longColor)) - float(color.b(shortColor))) * frac)
        cellCol = color.rgb(r, g, b)
        heatFrac = math.pow(frac, heatContrast)
        transp   = int(90.0 - heatFrac * 80.0)
        table.cell(legend, 0, ci + 2, "", bgcolor=color.new(cellCol, transp), text_size=size.tiny)
        table.cell(legend, 1, ci + 2, "", bgcolor=color.new(cellCol, transp), text_size=size.tiny)
        table.cell(legend, 2, ci + 2, "", bgcolor=color.new(cellCol, transp), text_size=size.tiny)

    table.cell(legend, 0, legendCells + 2, "LOW",  text_color=textDim,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(legend, 1, legendCells + 2, "HEAT", text_color=textDim, text_size=size.tiny)
    table.cell(legend, 2, legendCells + 2, "HIGH", text_color=textDim,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// COUNT ACTIVE / HIT POCKETS
// ─────────────────────────────────────────────────────────────────────────────
activeCount = 0
hitCount    = 0
if array.size(pockets) > 0
    for j = 0 to array.size(pockets) - 1
        if array.get(pocketFrozen, j)
            hitCount += 1
        else
            activeCount += 1

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
// Detect when any long liq pocket is swept (new hit this bar)
longHit  = array.size(pocketSide) > 0 and
  array.size(pocketHit) > 0 and
  barstate.isconfirmed and
  high >= ta.lowest(low, 5) and
  ta.crossover(close, ta.sma(close, 3))

alertcondition(not na(pivotL) and showLong,  title="LTM [JOAT] Long Pocket",  message="LTM [JOAT]: New long liquidation pocket formed on {{ticker}}.")
alertcondition(not na(pivotH) and showShort, title="LTM [JOAT] Short Pocket", message="LTM [JOAT]: New short liquidation pocket formed on {{ticker}}.")
````
