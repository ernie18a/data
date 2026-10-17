# Psychological Round Levels by potuzhniy(UA)

- url: https://www.tradingview.com/script/bN0gNoVS-Psychological-Round-Levels-by-potuzhniy-UA/
- type: indicator
- pine_id: PUB;ee8eafba779041fba7376d01b7d19f51
- version: 2.0

## Description

XAUUSD 20.0 
XAGUSD 1.0
EURUSD etc. 0.005
JPY 0.10
Crypto 1000

## Source Code

````pine
//@version=6
indicator('Round Levels — Forex, Metals, Indices & Crypto', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================
//  SETTINGS
// ============================================================
autoStep       = input.bool(true, 'Auto step (recommended)', group = 'Step', tooltip = 'Automatically picks a grid step based on the chart symbol. See the AUTO STEP comments below for the exact rules. Turn off to enter a fixed step manually.')
manualStep     = input.float(0.0050, 'Manual step (used when Auto step is OFF)', minval = 0.00000001, group = 'Step')
stepMult       = input.float(1.0, 'Auto step multiplier', minval = 0.1, step = 0.1, group = 'Step', tooltip = 'Scales the auto-detected step: 0.5 = twice as many levels, 2 = half as many. Ignored when Auto step is OFF.')

levelsCount    = input.int(30, 'Levels above / below price', minval = 10, maxval = 80, group = 'Display', tooltip = 'Up to 2x this many lines (and labels) are drawn in total.')
showLabels     = input.bool(true, 'Show price labels', group = 'Display')
lineColor      = input.color(color.new(color.black, 65), 'Line color', group = 'Display')
lineWidth      = input.int(1, 'Line width', minval = 1, maxval = 4, group = 'Display')
lineStyleInput = input.string('Dashed', 'Line style', options = ['Solid', 'Dashed', 'Dotted'], group = 'Display')

lineStyle = switch lineStyleInput
    'Solid'  => line.style_solid
    'Dotted' => line.style_dotted
    => line.style_dashed

// ============================================================
//  AUTO STEP — recommended grid step per symbol
// ------------------------------------------------------------
//  FOREX (7 majors + 27 crosses)
//    One rule covers every pair via its quote currency:
//      - ...JPY pairs    (2-decimal quotes)   -> step 0.50
//      - all other pairs (4-5 decimal quotes) -> step 0.0050
//    (roughly a 50-pip "big figure" grid either way)
//
//  METALS
//      - Gold   (XAU) -> 10    e.g. 3300 / 3310 / ... / 3350 / ... / 3400
//      - Silver (XAG) -> 0.50  e.g. 32.00 / 32.50 / 33.00 ...
//
//  INDICES, CRYPTO, STOCKS & ANYTHING ELSE
//    The step is scaled to the instrument's own price so the grid stays
//    "round" no matter the price level, e.g.:
//      BTC ~65 000 -> step 1000   |   ETH ~3 000 -> step 100
//      SPX ~5 400  -> step 100    |   US30 ~39 000 -> step 1000
// ============================================================
getAutoStep() =>
    string tkr   = syminfo.ticker
    string base  = syminfo.basecurrency
    string quote = syminfo.currency
    string typ   = syminfo.type

    float step = na

    // Metals
    if base == 'XAU' or str.contains(tkr, 'XAU') or str.contains(tkr, 'GOLD')
        step := 10.0
    else if base == 'XAG' or str.contains(tkr, 'XAG') or str.contains(tkr, 'SILVER')
        step := 0.50

    // Forex majors & crosses
    if na(step) and typ == 'forex'
        step := quote == 'JPY' ? 0.50 : 0.0050

    // Indices / crypto / everything else -> scale to price magnitude
    if na(step)
        float p   = math.max(close, syminfo.mintick)
        float mag = math.pow(10, math.floor(math.log10(p)))
        step := mag / 10

    step

stepSize = autoStep ? getAutoStep() * stepMult : manualStep

// ============================================================
//  DRAWING
// ============================================================
var array<line>  linesArr  = array.new_line()
var array<label> labelsArr = array.new_label()
var float lastBase = 0.0

float baseLevel   = stepSize * math.floor(close / stepSize)
bool  needsRedraw = array.size(linesArr) == 0 or baseLevel != lastBase

if barstate.islast and needsRedraw
    for ln in linesArr
        line.delete(ln)
    array.clear(linesArr)

    for lb in labelsArr
        label.delete(lb)
    array.clear(labelsArr)

    lastBase := baseLevel
    int startX = math.max(0, bar_index - 2500)
    int endX   = bar_index + 50

    for i = -levelsCount to levelsCount by 1
        float lvl = baseLevel + i * stepSize
        if lvl > 0
            line newLine = line.new(x1 = startX, y1 = lvl, x2 = endX, y2 = lvl, color = lineColor, width = lineWidth, style = lineStyle, extend = extend.both)
            array.push(linesArr, newLine)
            if showLabels
                label newLabel = label.new(x = endX, y = lvl, text = str.tostring(lvl, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = lineColor, size = size.small)
                array.push(labelsArr, newLabel)
````
