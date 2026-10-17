# CONTINO - ICT Market Structure with FVG

- url: https://www.tradingview.com/script/chHOIQHi-CONTINO-ICT-Market-Structure-with-FVG/
- type: indicator
- pine_id: PUB;a2dc15635c744ac49de3f0f263a86046
- version: 1.0

## Description

CONTINO – ICT Market Structure with FVG
Short description
ICT market structure with swing labels (HH/HL/LH/LL) and BoS/MSS breaks, plus Fair Value Gaps filtered by volatility (ATR) that are removed automatically once mitigated. Lightweight, clean, with FVG alerts.
Long description
CONTINO – ICT Market Structure with FVG is an overlay indicator that combines two of the most important ICT / Smart Money Concepts readings into a single tool — market structure and Fair Value Gaps — without cluttering your chart.
It works on any market and timeframe: indices and futures (MNQ, ES, NQ…), forex, crypto and equities.
1. Market Structure
HH / HL / LH / LL swing labels plotted on pivots, so the structural sequence is readable at a glance. Configurable swing length (default 14).
BoS and MSS on the main structure (configurable length, default 5):
Dotted line = BoS → break of structure in the direction of the prevailing trend: continuation.
Solid line = MSS → Market Structure Shift: the break goes against the prior trend, signalling a potential change of character.
Two drawing modes:
Historic → keeps every BoS/MSS line and label already plotted.
Present → keeps only the latest structure (deletes the previous one). Ideal if you prefer a clean chart.
Separate colours for bullish and bearish structure.
2. Fair Value Gaps (FVG)
Detects three-candle FVGs, bullish and bearish, and projects them to the right for the number of candles you choose (20 by default).
Double quality filter, so only meaningful imbalances are plotted:
Displacement: the middle candle must close outside the gap (close[1] above candle 1's high for bullish, below its low for bearish). This discards gaps with no real impulse behind them.
Volatility filter: the gap size must exceed a multiple of ATR (200-period ATR × 0.25 by default). Raise or lower that multiplier to show fewer or more zones.
Automatic removal on mitigation: a bullish zone is deleted when price touches its bottom; a bearish zone, when price touches its top. No stale, already-filled boxes left occupying space.
Configurable zone limit (50 per side by default; the oldest is dropped once exceeded).
Fully configurable styling: bullish/bearish fill, centre line (colour, solid/dashed/dotted, width), fill and line transparency.
3. Included alerts
Bullish FVG — bullish Fair Value Gap detected (only if it passes the volatility filter)
Bearish FVG — bearish Fair Value Gap detected (only if it passes the volatility filter)
How to use it
Read the structure first: identify the HH/HL sequence (bullish) or LH/LL sequence (bearish) and note the latest structure event. A BoS confirms continuation; an MSS warns of a possible reversal.
Trade the FVGs in line with that structure: unmitigated bullish gaps act as demand zones to look for continuation higher; bearish gaps act as supply zones for continuation lower.
Each zone's centre line is a useful reference for partial entries or for judging whether price respects the zone (reaction at the midpoint = strength; a close through it = zone compromised).
Use the FVG alerts so you don't have to watch the chart: the script only notifies you about gaps that passed the volatility filter — i.e. imbalances worth your attention.
Notes
Overlay indicator (Pine v6). Drawing limits are set to 500 lines, 500 labels and 500 boxes.
Swing, BoS and MSS detection is pivot-based, so signals confirm with a delay relative to the pivot: they depend on the swing length (14) and the structure length (5). It does not repaint on a closed bar, but the label appears a few candles after the extreme.
FVGs are calculated on the current bar; with Remove Mitigated FVG enabled, a zone can disappear the same session if price fills it.
The volatility filter is the key to keeping the chart uncluttered: if you see too many zones, increase the ATR multiplier; if too few, decrease it.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("CONTINO - ICT Market Structure with FVG", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// --- Constants ---
const string STYLE_GROUP = "Style"
const string FVG_GROUP = "Fair Value Gaps"
const string FVG_STYLE_GROUP = "FVG Style"
const int DEFAULT_FVG_TRANSPARENCY = 88

// --- Inputs ---
swingLength = input.int(14, "Swing Length (Labels)", minval = 1, tooltip = "Longitud para identificar los HH/HL/LH/LL (swings menores).")
structLength = input.int(5, "Structure Length (BOS/MSS)", minval = 1, tooltip = "Longitud para la estructura principal y sus rompimientos.")

showSwingsInput = input.bool(true, "Show Swings (HH/HL/LH/LL)", group = STYLE_GROUP, tooltip = "Muestra u oculta las etiquetas de swings menores.")
structureModeInput = input.string("Histórico", "Structure Mode", options = ["Histórico", "Presente"], group = STYLE_GROUP, tooltip = "'Histórico' conserva todas las líneas de BOS/MSS. 'Presente' solo muestra la última estructura, borrando la anterior.")

showFvgInput = input.bool(true, "Show FVG", group = FVG_GROUP, tooltip = "Muestra las zonas de Fair Value Gap de tres velas.")
fvgVolatilityThresholdInput = input.float(0.25, "Volatility Threshold (ATR Multiplier)", minval = 0.0, step = 0.05, group = FVG_GROUP, tooltip = "Filtra los FVG comparando el tamaño del gap con el ATR. Un valor de 0.25 exige que el gap sea mayor que el 25% del ATR.")
fvgAtrLengthInput = input.int(200, "Volatility Length", minval = 1, group = FVG_GROUP, tooltip = "Longitud del ATR utilizado para calcular el umbral de volatilidad.")
fvgContinuationInput = input.int(20, "Continuation Candles", minval = 1, maxval = 500, group = FVG_GROUP, tooltip = "Número de velas hacia la derecha durante las que se proyecta cada zona FVG.")
removeMitigatedInput = input.bool(true, "Remove Mitigated FVG", group = FVG_GROUP, tooltip = "Elimina la zona cuando el precio la rellena completamente.")
maxFvgZonesInput = input.int(50, "Maximum FVG Zones", minval = 1, maxval = 150, group = FVG_GROUP, tooltip = "Máximo de zonas alcistas y bajistas que se mantienen en el gráfico.")

bullColor = input.color(#089981, "Bullish Color", group = STYLE_GROUP, tooltip = "Color usado para estructura y swings alcistas.")
bearColor = input.color(#f23645, "Bearish Color", group = STYLE_GROUP, tooltip = "Color usado para estructura y swings bajistas.")

fvgBullColorInput = input.color(#089981, "Bullish FVG Fill", group = FVG_STYLE_GROUP, tooltip = "Color del relleno de las zonas FVG alcistas.")
fvgBearColorInput = input.color(#f23645, "Bearish FVG Fill", group = FVG_STYLE_GROUP, tooltip = "Color del relleno de las zonas FVG bajistas.")
fvgBullLineColorInput = input.color(#089981, "Bullish FVG Midline", group = FVG_STYLE_GROUP, tooltip = "Color de la línea central de los FVG alcistas.")
fvgBearLineColorInput = input.color(#f23645, "Bearish FVG Midline", group = FVG_STYLE_GROUP, tooltip = "Color de la línea central de los FVG bajistas.")
fvgFillTransparencyInput = input.int(DEFAULT_FVG_TRANSPARENCY, "Fill Transparency", minval = 0, maxval = 100, group = FVG_STYLE_GROUP, tooltip = "Transparencia del relleno de las zonas FVG. Valores altos producen un estilo más limpio.")
fvgLineTransparencyInput = input.int(20, "Midline Transparency", minval = 0, maxval = 100, group = FVG_STYLE_GROUP, tooltip = "Transparencia de la línea central de cada zona FVG.")
fvgLineStyleInput = input.string("Solid", "Midline Style", options = ["Solid", "Dashed", "Dotted"], group = FVG_STYLE_GROUP, tooltip = "Estilo de la línea central de las zonas FVG.")
fvgLineWidthInput = input.int(1, "Midline Width", minval = 1, maxval = 3, group = FVG_STYLE_GROUP, tooltip = "Grosor de la línea central de las zonas FVG.")

// --- User-defined functions ---
f_getLineStyle(string styleInput) =>
    switch styleInput
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_deleteOldestZone(array<box> zonesArray, array<line> midLinesArray, int maxZones) =>
    if array.size(zonesArray) > maxZones
        oldestZone = array.shift(zonesArray)
        oldestMidLine = array.shift(midLinesArray)
        box.delete(oldestZone)
        line.delete(oldestMidLine)

// --- Variables: Structure ---
var int trend = 0
var float lastStructPh = na
var int lastStructPhLoc = na
var bool phBroken = true
var float lastStructPl = na
var int lastStructPlLoc = na
var bool plBroken = true

// --- Variables: Structure drawing (para modo "Presente") ---
var line lastStructureLine = na
var label lastStructureLabel = na

// --- Variables: Swings ---
var float prevSwingPh = na
var float lastSwingPh = na
var float prevSwingPl = na
var float lastSwingPl = na

// --- Variables: FVG storage ---
var array<box> bullishFvgBoxes = array.new<box>()
var array<line> bullishFvgMidLines = array.new<line>()
var array<box> bearishFvgBoxes = array.new<box>()
var array<line> bearishFvgMidLines = array.new<line>()

// --- Pivot calculations ---
swingPh = ta.pivothigh(high, swingLength, swingLength)
swingPl = ta.pivotlow(low, swingLength, swingLength)
structPh = ta.pivothigh(high, structLength, structLength)
structPl = ta.pivotlow(low, structLength, structLength)

// --- Swing logic: HH / HL / LH / LL ---
if showSwingsInput and not na(swingPh)
    prevSwingPh := lastSwingPh
    lastSwingPh := swingPh
    isHh = na(prevSwingPh) or swingPh > prevSwingPh
    label.new(bar_index[swingLength], swingPh, isHh ? "HH" : "LH", color = #00000000, textcolor = isHh ? bullColor : bearColor, style = label.style_label_down, size = size.small)

if showSwingsInput and not na(swingPl)
    prevSwingPl := lastSwingPl
    lastSwingPl := swingPl
    isHl = na(prevSwingPl) or swingPl > prevSwingPl
    label.new(bar_index[swingLength], swingPl, isHl ? "HL" : "LL", color = #00000000, textcolor = isHl ? bullColor : bearColor, style = label.style_label_up, size = size.small)

// --- Structure logic: BOS / MSS ---
if not na(structPh)
    lastStructPh := structPh
    lastStructPhLoc := bar_index[structLength]
    phBroken := false

if not na(structPl)
    lastStructPl := structPl
    lastStructPlLoc := bar_index[structLength]
    plBroken := false

if not na(lastStructPh) and not phBroken and close > lastStructPh
    isMss = trend == -1
    trend := 1
    structureText = isMss ? "MSS" : "BOS"
    structureLineStyle = isMss ? line.style_solid : line.style_dotted
    if structureModeInput == "Presente"
        line.delete(lastStructureLine)
        label.delete(lastStructureLabel)
    newStructureLine = line.new(lastStructPhLoc, lastStructPh, bar_index, lastStructPh, color = bullColor, style = structureLineStyle)
    midX = math.round(math.avg(lastStructPhLoc, bar_index))
    newStructureLabel = label.new(midX, lastStructPh, structureText, color = #00000000, textcolor = bullColor, style = label.style_label_down, size = size.small)
    lastStructureLine := newStructureLine
    lastStructureLabel := newStructureLabel
    phBroken := true

if not na(lastStructPl) and not plBroken and close < lastStructPl
    isMss = trend == 1
    trend := -1
    structureText = isMss ? "MSS" : "BOS"
    structureLineStyle = isMss ? line.style_solid : line.style_dotted
    if structureModeInput == "Presente"
        line.delete(lastStructureLine)
        label.delete(lastStructureLabel)
    newStructureLine = line.new(lastStructPlLoc, lastStructPl, bar_index, lastStructPl, color = bearColor, style = structureLineStyle)
    midX = math.round(math.avg(lastStructPlLoc, bar_index))
    newStructureLabel = label.new(midX, lastStructPl, structureText, color = #00000000, textcolor = bearColor, style = label.style_label_up, size = size.small)
    lastStructureLine := newStructureLine
    lastStructureLabel := newStructureLabel
    plBroken := true

// --- FVG detection ---
// El filtro de PAC se basa en volatilidad: el gap debe superar un múltiplo del ATR.
fvgAtr = nz(ta.atr(fvgAtrLengthInput) * fvgVolatilityThresholdInput, ta.cum(high - low) / (bar_index + 1))
// Se exige también desplazamiento en la vela central para evitar gaps débiles.
bullishFvg = low > high[2] and close[1] > high[2]
bearishFvg = high < low[2] and close[1] < low[2]
bullishGapSize = bullishFvg ? math.abs(low - high[2]) : na
bearishGapSize = bearishFvg ? math.abs(low[2] - high) : na
validBullishFvg = showFvgInput and bullishFvg and bullishGapSize > fvgAtr
validBearishFvg = showFvgInput and bearishFvg and bearishGapSize > fvgAtr
fvgLineStyle = f_getLineStyle(fvgLineStyleInput)

if validBullishFvg
    bullishTop = low
    bullishBottom = high[2]
    bullishMid = math.avg(bullishTop, bullishBottom)
    bullishZone = box.new(left = bar_index - 2, top = bullishTop, right = bar_index + fvgContinuationInput, bottom = bullishBottom, border_color = #00000000, border_width = 0, bgcolor = color.new(fvgBullColorInput, fvgFillTransparencyInput))
    bullishMidLine = line.new(x1 = bar_index - 2, y1 = bullishMid, x2 = bar_index + fvgContinuationInput, y2 = bullishMid, xloc = xloc.bar_index, color = color.new(fvgBullLineColorInput, fvgLineTransparencyInput), style = fvgLineStyle, width = fvgLineWidthInput)
    array.push(bullishFvgBoxes, bullishZone)
    array.push(bullishFvgMidLines, bullishMidLine)
    f_deleteOldestZone(bullishFvgBoxes, bullishFvgMidLines, maxFvgZonesInput)

if validBearishFvg
    bearishTop = low[2]
    bearishBottom = high
    bearishMid = math.avg(bearishTop, bearishBottom)
    bearishZone = box.new(left = bar_index - 2, top = bearishTop, right = bar_index + fvgContinuationInput, bottom = bearishBottom, border_color = #00000000, border_width = 0, bgcolor = color.new(fvgBearColorInput, fvgFillTransparencyInput))
    bearishMidLine = line.new(x1 = bar_index - 2, y1 = bearishMid, x2 = bar_index + fvgContinuationInput, y2 = bearishMid, xloc = xloc.bar_index, color = color.new(fvgBearLineColorInput, fvgLineTransparencyInput), style = fvgLineStyle, width = fvgLineWidthInput)
    array.push(bearishFvgBoxes, bearishZone)
    array.push(bearishFvgMidLines, bearishMidLine)
    f_deleteOldestZone(bearishFvgBoxes, bearishFvgMidLines, maxFvgZonesInput)

// --- FVG mitigation management ---
if removeMitigatedInput and array.size(bullishFvgBoxes) > 0
    int bullishIndex = array.size(bullishFvgBoxes) - 1
    while bullishIndex >= 0
        bullishZone = array.get(bullishFvgBoxes, bullishIndex)
        bullishBottom = box.get_bottom(bullishZone)
        if low <= bullishBottom
            box.delete(bullishZone)
            line.delete(array.get(bullishFvgMidLines, bullishIndex))
            array.remove(bullishFvgBoxes, bullishIndex)
            array.remove(bullishFvgMidLines, bullishIndex)
        bullishIndex -= 1

if removeMitigatedInput and array.size(bearishFvgBoxes) > 0
    int bearishIndex = array.size(bearishFvgBoxes) - 1
    while bearishIndex >= 0
        bearishZone = array.get(bearishFvgBoxes, bearishIndex)
        bearishTop = box.get_top(bearishZone)
        if high >= bearishTop
            box.delete(bearishZone)
            line.delete(array.get(bearishFvgMidLines, bearishIndex))
            array.remove(bearishFvgBoxes, bearishIndex)
            array.remove(bearishFvgMidLines, bearishIndex)
        bearishIndex -= 1

// --- Alerts ---
alertcondition(validBullishFvg, "Bullish FVG", "Bullish Fair Value Gap detected")
alertcondition(validBearishFvg, "Bearish FVG", "Bearish Fair Value Gap detected")
````
