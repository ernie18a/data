# Support & Resistance Zones

- url: https://www.tradingview.com/script/m2rutBHW-Support-Resistance-Zones/
- type: indicator
- pine_id: PUB;67421b18a592494d8855f83a34849fd7
- version: 1.0

## Description

[b]Support & Resistance Zones[/b]
This indicator detects pivot highs and lows and draws price zones (bands) around each confirmed level. Zones extend to the right and update dynamically as price interacts with them.

[b]How it works[/b]
Pivot highs and lows are detected using a configurable lookback period. When a pivot is confirmed, a zone box is drawn anchored to that bar and extended rightward. Two filters are applied before drawing: a proximity check to avoid overlapping zones, and a strength check to exclude weak pivots where price did not move significantly away from the level.
As price evolves, each zone is re-evaluated on every bar. If price closes inside a zone, it is highlighted as active. If price closes decisively beyond the zone in the opposite direction (support broken below, resistance broken above), the zone flips its classification and recolors accordingly.

[b]Settings[/b]
[list]
[*]Pivot Lookback — number of bars on each side required to confirm a pivot (default: 15)
[*]Zone Width (%) — height of each zone band as a percentage of price (default: 0.15%)
[*]Max Zones to Show — maximum number of zones kept on chart at one time (default: 20)
[*]Min Pivot Strength (%) — minimum percentage move away from the pivot required before a zone is drawn (default: 0.3%)
[*]Colors — individually configurable for support zones, resistance zones, and the active/inside state
[/list]

[b]Zone colors[/b]
[list]
[*]Green — support zone; price previously bounced from this level
[*]Red — resistance zone; price previously rejected from this level
[*]Gray — price is currently inside this zone
[/list]

[b]Works on all timeframes and instruments.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © lazyhacker

//@version=6
indicator("Support & Resistance Zones", overlay=true, max_boxes_count=500)

// --- Inputs ---
lookback       = input.int(15,    title="Pivot Lookback",         minval=5,   maxval=100,  group="General")
zonePct        = input.float(0.15,title="Zone Width (%)",         minval=0.05,maxval=1.0,  step=0.05, group="General")
maxZones       = input.int(20,    title="Max Zones to Show",      minval=5,   maxval=50,   group="General")
filterStrength = input.float(0.3, title="Min Pivot Strength (%)", minval=0.0, maxval=2.0,  step=0.05, group="General",
                             tooltip="Minimum % move away from pivot to qualify as significant. Higher values produce fewer, stronger zones.")

colorSupport  = input.color(color.new(color.green, 80), title="Support Zone Color",      group="Colors")
colorResist   = input.color(color.new(color.red,   80), title="Resistance Zone Color",   group="Colors")
colorFlipped  = input.color(color.new(color.gray,  75), title="Price Inside Zone Color", group="Colors")
borderSupport = input.color(color.new(color.green, 30), title="Support Border Color",    group="Colors")
borderResist  = input.color(color.new(color.red,   30), title="Resistance Border Color", group="Colors")

// --- Pivot Detection ---
ph = ta.pivothigh(high, lookback, lookback)
pl = ta.pivotlow(low,   lookback, lookback)

// --- Arrays to track drawn zones ---
var box[]   drawnBoxes  = array.new<box>()
var float[] drawnLevels = array.new<float>()
var bool[]  drawnIsSup  = array.new<bool>()

// --- Helper: skip new zone if too close to an existing one ---
isTooClose(price) =>
    result = false
    n = array.size(drawnLevels)
    if n > 0
        for i = 0 to n - 1
            if math.abs(price - array.get(drawnLevels, i)) < close * zonePct / 100 * 2.0
                result := true
    result

// --- Helper: confirm the pivot has a meaningful move away from it ---
isStrongPivot(price, isSup) =>
    move = isSup ? (close - price) / price * 100 : (price - close) / price * 100
    move >= filterStrength

// --- Draw zone box at confirmed pivot bar ---
pivotBarIdx = bar_index - lookback

if not na(ph)
    if not isTooClose(ph) and isStrongPivot(ph, false)
        half = ph * zonePct / 200
        b = box.new(
             left         = pivotBarIdx,
             top          = ph + half,
             right        = bar_index,
             bottom       = ph - half,
             border_color = borderResist,
             border_width = 1,
             bgcolor      = colorResist,
             extend       = extend.right,
             xloc         = xloc.bar_index)
        array.push(drawnBoxes,  b)
        array.push(drawnLevels, ph)
        array.push(drawnIsSup,  false)

if not na(pl)
    if not isTooClose(pl) and isStrongPivot(pl, true)
        half = pl * zonePct / 200
        b = box.new(
             left         = pivotBarIdx,
             top          = pl + half,
             right        = bar_index,
             bottom       = pl - half,
             border_color = borderSupport,
             border_width = 1,
             bgcolor      = colorSupport,
             extend       = extend.right,
             xloc         = xloc.bar_index)
        array.push(drawnBoxes,  b)
        array.push(drawnLevels, pl)
        array.push(drawnIsSup,  true)

// --- Update zone colors based on price interaction ---
n = array.size(drawnBoxes)
if n > 0
    for i = 0 to n - 1
        lvl   = array.get(drawnLevels, i)
        isSup = array.get(drawnIsSup,  i)
        b     = array.get(drawnBoxes,  i)
        half  = lvl * zonePct / 200

        isInsideZone = close >= lvl - half and close <= lvl + half
        brokeBelow   = isSup     and close < lvl - half * 3
        brokeAbove   = not isSup and close > lvl + half * 3

        if isInsideZone
            box.set_bgcolor(b,      colorFlipped)
            box.set_border_color(b, color.gray)
        else if brokeBelow
            array.set(drawnIsSup, i, false)
            box.set_bgcolor(b,      colorResist)
            box.set_border_color(b, borderResist)
        else if brokeAbove
            array.set(drawnIsSup, i, true)
            box.set_bgcolor(b,      colorSupport)
            box.set_border_color(b, borderSupport)

// --- Remove oldest zone when limit is exceeded ---
if array.size(drawnBoxes) > maxZones
    box.delete(array.shift(drawnBoxes))
    array.shift(drawnLevels)
    array.shift(drawnIsSup)
````
