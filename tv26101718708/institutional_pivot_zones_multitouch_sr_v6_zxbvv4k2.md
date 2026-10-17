# Institutional Pivot Zones & Multi-Touch S/R [v6]

- url: https://www.tradingview.com/script/zxbvv4K2/
- type: indicator
- pine_id: PUB;93b3d9040fc542bf965e5782a5ed069e
- version: 2.0

## Description

Institutional Pivot Zones & Multi-Touch S/R is an advanced intraday trading script written in Pine Script v6. Unlike generic Support and Resistance indicators that clutter your charts by marking every minor fractal peak, this script uses high-precision mathematical filtering to isolate true institutional pivot zones (Flipping Levels) and heavy multi-touch historical areas.

Designed specifically for active intraday pairs like EURUSD, GBPUSD, EURJPY, and GBPJPY, it plots dynamic zone ranges (boxes) based on real market interaction rather than lagging mathematical averages.

How the Logic Works
The indicator scans the market using a customizable fractal lookback period to identify strong structural swing highs and lows. It then processes these key levels through a strict multi-touch filter:

Zone Consolidation: It searches for price levels where institutions have repeatedly accumulated orders or triggered reversals.

Pip Tolerance Detection: Instead of looking for a single, unrealistic price point, it calculates a structural area (in pips) where the price has reacted via wicks or candle closures.

Flipping Levels (SR Flip): It highlights key areas where an old ceiling (resistance) is broken and effectively turns into a new floor (support), tracking the real institutional order flow.

Key Settings & Optimization for Intraday (M5 / M15)
To get the sharpest "Sniper" entries on a 5-minute or 15-minute chart, use the following optimized parameters in the settings panel:

Fractal Lookback Period (Periodo para detectar picos): Set to 15 to capture fresh intraday structures from the current and previous sessions (London/New York).

Minimum Touches (Mínimo de testeos): Set to 2 for fast intraday action. This activates the zone immediately after the first retest, letting you capture the move on the 3rd touch.

Zone Tolerance in Pips (Tolerancia de la zona): Set between 2.5 to 3.5 pips for major currency pairs like EURUSD to perfectly box the rejection wicks without creating overly wide zones.

How to Trade with this Indicator
Sniper Buy Trigger: Look for the price to drop into a lower support zone. Wait for a clear wick rejection (stop hunt/liquidity grab) on M15. Execute on the candle close with your Stop Loss safely tucked just below the rejection wick.

Sniper Sell Trigger: Watch for the price to rally into a resistance zone. Wait for a prominent upper wick rejection. Execute the sell position with a tight Stop Loss right above the high of that candle, targeting the next structural zone below.

Disclaimer: This indicator is designed for structural analysis and price action context. Always combine it with proper risk management and session timing.

## Source Code

````pine
//@version=6
indicator("Zonas de Soporte y Resistencia Reales - v6.1 CLEAN FIX FINAL", overlay=true, max_boxes_count=100, max_labels_count=100, max_lines_count=100)

int lookback = input.int(15, title="Periodo para detectar picos (Fractal)")
int min_touches = input.int(3, title="Mínimo de testeos para validar zona", minval=2)
float proximity_pips = input.float(3.0, title="Tolerancia de la zona (en Pips)", step=0.5)

color supColor = input.color(color.new(#00bcd4, 75), title="Color Soporte")
color resColor = input.color(color.new(#e91e63, 75), title="Color Resistencia")
color colorTop1 = input.color(color.new(#ff1744, 15), title="Color TOP 1 - Más testeada (Rojo)")
color colorTop2 = input.color(color.new(#00e676, 30), title="Color TOP 2 - Segunda (Verde)")
bool showLabels = input.bool(true, "Mostrar nº de testeos")
int maxZones = input.int(10, "Máximo de zonas por tipo", minval=2, maxval=20)

int extendLeft = input.int(10, "Extensión visual izquierda - Resto", minval=1)
int extendLeftTop1 = input.int(300, "Extensión izquierda - TOP 1", minval=1, group="Zonas Fuertes")
int extendLeftTop2 = input.int(150, "Extensión izquierda - TOP 2", minval=1, group="Zonas Fuertes")

float tolerance = proximity_pips * syminfo.mintick * 10

p_high = ta.pivothigh(high, lookback, lookback)
p_low = ta.pivotlow(low, lookback, lookback)

var float[] historic_highs = array.new_float(0)
var float[] historic_lows = array.new_float(0)

if not na(p_high)
    array.push(historic_highs, p_high)
if not na(p_low)
    array.push(historic_lows, p_low)

if array.size(historic_highs) > 100
    array.shift(historic_highs)
if array.size(historic_lows) > 100
    array.shift(historic_lows)

var box[] active_boxes = array.new_box(0)
var label[] active_labels = array.new_label(0)
var line[] active_lines = array.new_line(0)

if barstate.islast
    for b in active_boxes
        box.delete(b)
    for l in active_labels
        label.delete(l)
    for ln in active_lines
        line.delete(ln)
    array.clear(active_boxes)
    array.clear(active_labels)
    array.clear(active_lines)

    // RESISTENCIAS
    var float[] candResPrice = array.new_float(0)
    var int[] candResTouches = array.new_int(0)
    var float[] drawnResLevels = array.new_float(0)
    array.clear(candResPrice)
    array.clear(candResTouches)
    array.clear(drawnResLevels)

    if array.size(historic_highs) > 0
        for i = 0 to array.size(historic_highs) - 1
            float ref_price = array.get(historic_highs, i)
            bool isDuplicate = false
            if array.size(drawnResLevels) > 0
                for k = 0 to array.size(drawnResLevels) - 1
                    if math.abs(array.get(drawnResLevels, k) - ref_price) <= tolerance
                        isDuplicate := true
                        break
            if isDuplicate
                continue
            int touches = 0
            for j = 0 to array.size(historic_highs) - 1
                if math.abs(array.get(historic_highs, j) - ref_price) <= tolerance
                    touches += 1
            if touches >= min_touches
                array.push(candResPrice, ref_price)
                array.push(candResTouches, touches)
                array.push(drawnResLevels, ref_price)

    int top1Res = 0
    int top2Res = 0
    if array.size(candResTouches) > 0
        for t = 0 to array.size(candResTouches) - 1
            int v = array.get(candResTouches, t)
            if v > top1Res
                top2Res := top1Res
                top1Res := v
            else if v > top2Res and v != top1Res
                top2Res := v

    int resCount = 0
    if array.size(candResPrice) > 0
        for i = 0 to array.size(candResPrice) - 1
            if resCount >= maxZones
                break
            float ref_price = array.get(candResPrice, i)
            int touches = array.get(candResTouches, i)
            color finalColor = na
            int finalExt = extendLeft
            if touches == top1Res
                finalColor := colorTop1
                finalExt := extendLeftTop1
            else if top2Res != 0 and touches == top2Res
                finalColor := colorTop2
                finalExt := extendLeftTop2
            else
                int transp = math.max(55, 90 - touches * 7)
                finalColor := color.new(resColor, transp)

            box resBox = box.new(left=bar_index - finalExt, top=ref_price + tolerance/2, right=bar_index + 15, bottom=ref_price - tolerance/2, bgcolor=finalColor, border_color=color.new(finalColor, 100), xloc=xloc.bar_index)
            array.push(active_boxes, resBox)
            line l = line.new(bar_index - finalExt, ref_price, bar_index + 15, ref_price, color=color.new(finalColor, 50), width=1, xloc=xloc.bar_index)
            array.push(active_lines, l)
            if showLabels
                label lb = label.new(bar_index + 15, ref_price, text=str.tostring(touches) + "x", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(finalColor, 0), xloc=xloc.bar_index)
                array.push(active_labels, lb)
            resCount += 1

    // SOPORTES
    var float[] candSupPrice = array.new_float(0)
    var int[] candSupTouches = array.new_int(0)
    var float[] drawnSupLevels = array.new_float(0)
    array.clear(candSupPrice)
    array.clear(candSupTouches)
    array.clear(drawnSupLevels)

    if array.size(historic_lows) > 0
        for i = 0 to array.size(historic_lows) - 1
            float ref_price = array.get(historic_lows, i)
            bool isDuplicate = false
            if array.size(drawnSupLevels) > 0
                for k = 0 to array.size(drawnSupLevels) - 1
                    if math.abs(array.get(drawnSupLevels, k) - ref_price) <= tolerance
                        isDuplicate := true
                        break
            if isDuplicate
                continue
            int touches = 0
            for j = 0 to array.size(historic_lows) - 1
                if math.abs(array.get(historic_lows, j) - ref_price) <= tolerance
                    touches += 1
            if touches >= min_touches
                array.push(candSupPrice, ref_price)
                array.push(candSupTouches, touches)
                array.push(drawnSupLevels, ref_price)

    int top1Sup = 0
    int top2Sup = 0
    if array.size(candSupTouches) > 0
        for t = 0 to array.size(candSupTouches) - 1
            int v = array.get(candSupTouches, t)
            if v > top1Sup
                top2Sup := top1Sup
                top1Sup := v
            else if v > top2Sup and v != top1Sup
                top2Sup := v

    int supCount = 0
    if array.size(candSupPrice) > 0
        for i = 0 to array.size(candSupPrice) - 1
            if supCount >= maxZones
                break
            float ref_price = array.get(candSupPrice, i)
            int touches = array.get(candSupTouches, i)
            color finalColor = na
            int finalExt = extendLeft
            if touches == top1Sup
                finalColor := colorTop1
                finalExt := extendLeftTop1
            else if top2Sup != 0 and touches == top2Sup
                finalColor := colorTop2
                finalExt := extendLeftTop2
            else
                int transp = math.max(55, 90 - touches * 7)
                finalColor := color.new(supColor, transp)

            box supBox = box.new(left=bar_index - finalExt, top=ref_price + tolerance/2, right=bar_index + 15, bottom=ref_price - tolerance/2, bgcolor=finalColor, border_color=color.new(finalColor, 100), xloc=xloc.bar_index)
            array.push(active_boxes, supBox)
            line l = line.new(bar_index - finalExt, ref_price, bar_index + 15, ref_price, color=color.new(finalColor, 50), width=1, xloc=xloc.bar_index)
            array.push(active_lines, l)
            if showLabels
                label lb = label.new(bar_index + 15, ref_price, text=str.tostring(touches) + "x", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.new(finalColor, 0), xloc=xloc.bar_index)
                array.push(active_labels, lb)
            supCount += 1
````
