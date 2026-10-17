# FVGs Spotter by MoneyK

- url: https://www.tradingview.com/script/bZcuwss1/
- type: indicator
- pine_id: PUB;85b45bb12e504610ab2ded939b686c36
- version: 1.0

## Description

FVGs Spotter by MoneyK

Fair Value Gaps can help traders understand areas where price moved with strong imbalance, leaving inefficiently traded zones behind. These areas often become relevant again when price revisits them, making FVGs useful for reading market context rather than looking at price movement in isolation.

One of the main advantages of having FVGs clearly visible is that they can help explain why price may be pulling back, slowing down, reacting, continuing higher, or continuing lower. What may otherwise look like a random retracement can sometimes be understood more clearly when price is interacting with a previously created imbalance.

The indicator displays both bullish and bearish FVGs and keeps the chart intentionally simple. Each active FVG includes its 50% level, helping traders quickly identify the midpoint of the imbalance without manually measuring the zone.

This can be especially useful for scalpers, who often need to understand short-term price behavior quickly. When combined with market structure, trend direction, liquidity, support/resistance, order flow, or an existing trading setup, FVGs can provide an additional layer of context for evaluating pullbacks, continuations, reactions, and potential areas of interest.

Key features

Automatic detection of bullish and bearish Fair Value Gaps

Clear visualization of active imbalance zones

50% FVG midpoint displayed directly on the chart

Optional tiny price label showing the exact 50% level

Optional historical FVG visualization

Historical zones can show whether the 50% mitigation level was reached

Different visual treatment for stronger and weaker FVG structures

Configurable bullish and bearish colors

Clean default configuration designed to reduce chart clutter

English and Spanish interface support

Particularly useful for scalping and short-term intraday analysis

Why FVGs matter

FVGs are not simply boxes on a chart. They represent areas where price moved quickly enough to leave an imbalance between buyers and sellers.

Keeping those areas visible can help answer questions such as:

Why is price retracing here?

Why did a pullback stop at this level?

Why is price reacting before reaching a previous high or low?

Is price returning to rebalance an earlier move?

Is the current move interacting with an important imbalance from a previous impulse?

For a scalper, having this information immediately available can make the chart easier to read and help place short-term price movement into context.

Designed for confirmation, not prediction

FVGs Spotter by MoneyK is intended as a context and confirmation tool, not as a standalone BUY or SELL system.

A Fair Value Gap alone does not guarantee that price will reverse, continue, or react. Its value increases when it aligns with other elements of a trading thesis, such as trend, structure, liquidity, momentum, support/resistance, or another validated setup.

The goal of FVGs Spotter is simple:

Show the imbalance clearly so the trader can better understand what price is doing — and why it may be doing it.

## Source Code

````pine
//@version=6
indicator("FVGs Spotter by MoneyK", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)
// FVGs Spotter by MoneyK · v1.0.1 · Default Clean Visuals
//──────────────────────────────────────────────────────────────────────────────
// USER-FACING CONFIGURATION
//──────────────────────────────────────────────────────────────────────────────
groupGeneral = "GENERAL"
groupVisual = "VISUAL"
lang = input.string("English", "Language / Idioma", options=["English", "Español"], group=groupGeneral, display=display.none, tooltip="English: Selects the language used in tooltips. Detection settings stay internal to keep the scanner consistent and clean.\n\nEspañol: Selecciona el idioma usado en tooltips. Los ajustes del motor quedan internos para mantener el scanner consistente y limpio.")
showHistoricalFvgs = input.bool(false, "Show Historical FVGs", group=groupVisual, display=display.none, tooltip="English: Keeps resolved FVGs on the chart in a faded state. A faded directional FVG with ✓ reached its 50% mitigation level. A gray FVG with × expired before reaching that level. Outcome marks are printed at the original FVG area, away from the live edge.\n\nEspañol: Conserva los FVG resueltos en el gráfico de forma atenuada. Un FVG direccional atenuado con ✓ alcanzó su nivel de mitigación del 50%. Un FVG gris con × expiró antes de alcanzarlo. Las marcas de resultado se imprimen en el área original del FVG, lejos del borde vivo.")
showFvg50Price = input.bool(true, "Show FVG 50% Price", group=groupVisual, display=display.none, tooltip="English: Shows a tiny price label at the active 50% level of each FVG. Turn it off for a cleaner chart.\n\nEspañol: Muestra una etiqueta tiny con el precio del 50% activo de cada FVG. Apágalo para limpiar más el gráfico.")
bullFvgBaseColor = input.color(color.rgb(66, 133, 244), "Bullish FVG Color", group=groupVisual, display=display.none, tooltip="English: Base color for bullish / demand FVGs. The scanner keeps internal transparency levels for active and historical zones.\n\nEspañol: Color base para FVGs alcistas / de demanda. El scanner conserva transparencias internas para zonas activas e históricas.")
bearFvgBaseColor = input.color(color.rgb(233, 117, 165), "Bearish FVG Color", group=groupVisual, display=display.none, tooltip="English: Base color for bearish / supply FVGs. The scanner keeps internal transparency levels for active and historical zones.\n\nEspañol: Color base para FVGs bajistas / de oferta. El scanner conserva transparencias internas para zonas activas e históricas.")
isSpanish = lang == "Español"
watermarkText = "Trading MoneyK's Way"
//──────────────────────────────────────────────────────────────────────────────
// INTERNAL SETTINGS
//──────────────────────────────────────────────────────────────────────────────
atrLen = 55
atrMult = 1.00
validBars = 160
mitigationLevel = "50%"
showCE = true
maxActiveZones = 35
maxHistoricalFvgs = 60
//──────────────────────────────────────────────────────────────────────────────
// COLORS
//──────────────────────────────────────────────────────────────────────────────
bullFill = color.new(bullFvgBaseColor, 80)
bullBorder = color.new(bullFvgBaseColor, 35)
bearFill = color.new(bearFvgBaseColor, 80)
bearBorder = color.new(bearFvgBaseColor, 35)
rawBullFill = color.new(bullFvgBaseColor, 88)
rawBullBorder = color.new(bullFvgBaseColor, 55)
rawBearFill = color.new(bearFvgBaseColor, 88)
rawBearBorder = color.new(bearFvgBaseColor, 55)
ceBullColor = color.new(bullFvgBaseColor, 20)
ceBearColor = color.new(bearFvgBaseColor, 20)
ceRawBullColor = color.new(bullFvgBaseColor, 45)
ceRawBearColor = color.new(bearFvgBaseColor, 45)
//──────────────────────────────────────────────────────────────────────────────
// FVG DETECTION
//──────────────────────────────────────────────────────────────────────────────
atr = ta.atr(atrLen)
rawDemandFVG = low > high[2]
rawSupplyFVG = high < low[2]
qualityDemandFVG = rawDemandFVG and (high - low[2]) > atr * atrMult and low[2] < low[1] and high[1] < high
qualitySupplyFVG = rawSupplyFVG and (high[2] - low) > atr * atrMult and high[2] > high[1] and low[1] > low
drawDemand = rawDemandFVG
drawSupply = rawSupplyFVG
demandTop = low
demandBottom = high[2]
demandMid = (demandTop + demandBottom) * 0.5
supplyTop = low[2]
supplyBottom = high
supplyMid = (supplyTop + supplyBottom) * 0.5
//──────────────────────────────────────────────────────────────────────────────
// ACTIVE + HISTORICAL FVG ARRAYS
//──────────────────────────────────────────────────────────────────────────────
var box[] fvgBoxes = array.new_box()
var line[] fvgMids = array.new_line()
var label[] fvgPriceLabels = array.new_label()
var int[] fvgDirs = array.new_int()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var int[] fvgBorn = array.new_int()
var bool[] fvgQualities = array.new_bool()
var box[] historicalFvgBoxes = array.new_box()
var line[] historicalFvgMids = array.new_line()
var label[] historicalFvgStatusLabels = array.new_label()
//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_removeActiveRefs(_idx) =>
    array.remove(fvgBoxes, _idx)
    array.remove(fvgMids, _idx)
    array.remove(fvgPriceLabels, _idx)
    array.remove(fvgDirs, _idx)
    array.remove(fvgTops, _idx)
    array.remove(fvgBottoms, _idx)
    array.remove(fvgBorn, _idx)
    array.remove(fvgQualities, _idx)
    true
f_deleteZone(_idx) =>
    box bx = array.get(fvgBoxes, _idx)
    line ml = array.get(fvgMids, _idx)
    label lb = array.get(fvgPriceLabels, _idx)
    box.delete(bx)
    if not na(ml)
        line.delete(ml)
    if not na(lb)
        label.delete(lb)
    f_removeActiveRefs(_idx)
    true
f_trimHistoricalFvgs() =>
    while array.size(historicalFvgBoxes) > maxHistoricalFvgs
        box.delete(array.shift(historicalFvgBoxes))
        line oldMid = array.shift(historicalFvgMids)
        label oldStatus = array.shift(historicalFvgStatusLabels)
        if not na(oldMid)
            line.delete(oldMid)
        if not na(oldStatus)
            label.delete(oldStatus)
    true
f_archiveZone(_idx, _mitigated) =>
    box bx = array.get(fvgBoxes, _idx)
    line ml = array.get(fvgMids, _idx)
    label lb = array.get(fvgPriceLabels, _idx)
    int dir = array.get(fvgDirs, _idx)
    float top = array.get(fvgTops, _idx)
    float bottom = array.get(fvgBottoms, _idx)
    float mid = (top + bottom) * 0.5
    int born = array.get(fvgBorn, _idx)
    int statusX = math.max(born - 1, 0)
    bool isDemand = dir == 1
    if not na(lb)
        label.delete(lb)
    if _mitigated
        box.set_bgcolor(bx, isDemand ? color.new(bullFvgBaseColor, 94) : color.new(bearFvgBaseColor, 94))
        box.set_border_color(bx, isDemand ? color.new(bullFvgBaseColor, 78) : color.new(bearFvgBaseColor, 78))
        if not na(ml)
            line.set_color(ml, isDemand ? color.new(bullFvgBaseColor, 75) : color.new(bearFvgBaseColor, 75))
        label status = label.new(statusX, mid, "✓", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(isDemand ? bullFvgBaseColor : bearFvgBaseColor, 82), textcolor=color.new(color.white, 20), size=size.tiny, tooltip=isSpanish ? "FVG histórico: mitigación del 50% alcanzada." : "Historical FVG: 50% mitigation reached.")
        array.push(historicalFvgStatusLabels, status)
    else
        box.set_bgcolor(bx, color.new(color.gray, 95))
        box.set_border_color(bx, color.new(color.gray, 84))
        if not na(ml)
            line.set_color(ml, color.new(color.gray, 78))
        label status = label.new(statusX, mid, "×", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.gray, 86), textcolor=color.new(color.white, 28), size=size.tiny, tooltip=isSpanish ? "FVG histórico: expiró antes de alcanzar la mitigación del 50%." : "Historical FVG: expired before reaching 50% mitigation.")
        array.push(historicalFvgStatusLabels, status)
    box.set_right(bx, bar_index)
    if not na(ml)
        line.set_x2(ml, bar_index)
    array.push(historicalFvgBoxes, bx)
    array.push(historicalFvgMids, ml)
    f_removeActiveRefs(_idx)
    f_trimHistoricalFvgs()
    true
f_trimZones() =>
    while array.size(fvgBoxes) > maxActiveZones
        f_deleteZone(0)
    true
f_addFVG(_dir, _top, _bottom, _isQuality) =>
    bool isDemand = _dir == 1
    float mid = (_top + _bottom) * 0.5
    color fillColor = _isQuality ? (isDemand ? bullFill : bearFill) : (isDemand ? rawBullFill : rawBearFill)
    color borderColor = _isQuality ? (isDemand ? bullBorder : bearBorder) : (isDemand ? rawBullBorder : rawBearBorder)
    color ceColor = _isQuality ? (isDemand ? ceBullColor : ceBearColor) : (isDemand ? ceRawBullColor : ceRawBearColor)
    box bx = box.new(left=bar_index - 2, top=_top, right=bar_index, bottom=_bottom, xloc=xloc.bar_index, bgcolor=fillColor, border_color=borderColor, border_width=1)
    line ml = showCE ? line.new(bar_index - 2, mid, bar_index, mid, xloc=xloc.bar_index, extend=extend.none, color=ceColor, style=line.style_dotted, width=1) : na
    label lb = na
    if showFvg50Price
        string txt = str.tostring(mid, format.mintick)
        color lblTxt = isDemand ? color.new(bullFvgBaseColor, 0) : color.new(bearFvgBaseColor, 0)
        string tip = isSpanish ? "Precio del 50% del FVG." : "FVG 50% price."
        lb := label.new(bar_index, mid, txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(color.black, 100), textcolor=lblTxt, size=size.tiny, tooltip=tip)
    array.push(fvgBoxes, bx)
    array.push(fvgMids, ml)
    array.push(fvgPriceLabels, lb)
    array.push(fvgDirs, _dir)
    array.push(fvgTops, _top)
    array.push(fvgBottoms, _bottom)
    array.push(fvgBorn, bar_index)
    array.push(fvgQualities, _isQuality)
    f_trimZones()
    true
f_mitigationLevel(_dir, _top, _bottom) =>
    float mid = (_top + _bottom) * 0.5
    float level = na
    if _dir == 1
        level := mitigationLevel == "Proximal" ? _top : mitigationLevel == "50%" ? mid : _bottom
    else
        level := mitigationLevel == "Proximal" ? _bottom : mitigationLevel == "50%" ? mid : _top
    level
f_updateZones() =>
    int zoneCount = array.size(fvgBoxes)
    if zoneCount > 0
        for k = 0 to zoneCount - 1
            int i = zoneCount - 1 - k
            if i >= 0 and i < array.size(fvgBoxes)
                box bx = array.get(fvgBoxes, i)
                line ml = array.get(fvgMids, i)
                label lb = array.get(fvgPriceLabels, i)
                int dir = array.get(fvgDirs, i)
                float top = array.get(fvgTops, i)
                float bottom = array.get(fvgBottoms, i)
                int born = array.get(fvgBorn, i)
                float mid = (top + bottom) * 0.5
                float level = f_mitigationLevel(dir, top, bottom)
                box.set_right(bx, bar_index)
                if not na(ml)
                    line.set_x2(ml, bar_index)
                if not na(lb)
                    label.set_x(lb, bar_index)
                    label.set_y(lb, mid)
                bool canCheckMitigation = bar_index > born
                bool mitigated = canCheckMitigation and (dir == 1 ? low <= level : high >= level)
                bool expired = bar_index - born > validBars
                if mitigated
                    if showHistoricalFvgs
                        f_archiveZone(i, true)
                    else
                        f_deleteZone(i)
                else if expired
                    if showHistoricalFvgs
                        f_archiveZone(i, false)
                    else
                        f_deleteZone(i)
    true
//──────────────────────────────────────────────────────────────────────────────
// DRAW FVGS
//──────────────────────────────────────────────────────────────────────────────
if drawDemand
    f_addFVG(1, demandTop, demandBottom, qualityDemandFVG)
if drawSupply
    f_addFVG(-1, supplyTop, supplyBottom, qualitySupplyFVG)
f_updateZones()
//──────────────────────────────────────────────────────────────────────────────
// WATERMARK
//──────────────────────────────────────────────────────────────────────────────
var table watermarkTable = table.new(position.bottom_right, 1, 1, border_width=0, frame_color=color.new(color.white, 100), border_color=color.new(color.white, 100))
if barstate.islast
    table.cell(watermarkTable, 0, 0, watermarkText, text_color=color.new(color.white, 65), bgcolor=color.new(color.black, 100), text_size=size.tiny)
````
