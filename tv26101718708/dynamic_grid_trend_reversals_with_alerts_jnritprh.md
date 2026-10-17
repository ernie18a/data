# Dynamic Grid Trend Reversals with alerts

- url: https://www.tradingview.com/script/JNRItPrh-Dynamic-Grid-Trend-Reversals-with-alerts/
- type: indicator
- pine_id: PUB;b67aef67acc54fdd86b906b1059e6597
- version: 1.0

## Description

Dynamic Grid Trend Reversals with alerts

OVERVIEW
This indicator finds pullbacks that are likely to snap back in the direction of the trend. It draws a volatility grid around a trend baseline and marks the moment price turns back toward the baseline. Signals only appear in the trend direction, and each one is graded by how far price stretched before turning.

CREDITS
This script is a modified version of Dynamic Grid Indicator [BigBeluga] by BigBeluga,  Full credit goes to BigBeluga for the baseline, the volatility grid and the dashboard concept.

HOW IT WORKS

Baseline: a 150-period Hull Moving Average. It turns green while rising (uptrend) and red while falling (downtrend).
Grid: lines above (+1, +2, +3) and below (-1, -2, -3) the baseline, spaced by ATR. They widen in volatile markets and tighten in quiet ones.
Dashboard: shows where price sits on the grid right now.

SIGNALS

Buy (green ▲): the baseline is green, price has dipped below it, and a candle closes back above a lower grid line.
Sell (red ▼): the baseline is red, price has rallied above it, and a candle closes back below an upper grid line.

Each signal is graded by how far price stretched (wicks included) over the recent candles before it turned:

Reached ±1 → Buy / Sell
Reached ±2 → Buy Buy / Sell Sell
Reached ±3 or further → Must Buy / Must Sell

The further price stretches from its average, the stronger the pull back toward it tends to be.

HOW TO USE IT

Read the baseline colour first. Only look for buys when it's green and sells when it's red.
Wait for the signal. Signals print only after the candle closes, so they never repaint.
Use the grade to size your conviction. Must Buy / Must Sell signals come from the most stretched moves.
A natural profit target is the baseline itself, the "fair value" price is returning to. Place the stop beyond the extreme of the stretch.
Works best in trending or gently ranging markets. In very choppy conditions, raise the Minimum Bar Gap to filter noise.

ALERTS & OUTPUTS
Six alerts are included: Buy, Buy Buy, Must Buy, Sell, Sell Sell and Must Sell. Create them with "Once Per Bar Close". Each grade is also exposed as a 1/0 output in the Data Window, so you can use the signals in other tools and automations.

CHANGES FROM THE ORIGINAL

Signals filtered to the trend direction only: buys below a rising baseline, sells above a falling one.
Signals graded into three strengths by how far price stretched, using wicks over recent candles.
Signal labels show their grade (Buy / Buy Buy / Must Buy, Sell / Sell Sell / Must Sell).
Oscillator pane removed; everything is shown on the price chart.
Calculates on the full chart history instead of the last 3,000 candles.
Six graded alerts and six 1/0 outputs added for automation.
Non-repainting: signals are confirmed on candle close.

SETTINGS
Same defaults as the original: HMA 150, ATR 100, ATR step 1.6, 3 grid levels, proximity 0.5, minimum gap of 10 candles between signals. Colours, label sizes and dashboard position can be adjusted.

DISCLAIMER
This indicator is for educational purposes only and is not financial advice. No indicator is right every time. Always confirm signals with your own analysis and use proper risk management.

## Source Code

````pine
//@version=6
indicator("Dynamic Grid with alerts", overlay = true, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

var string G_MA = 'Trend & Base Channel Settings'
hmaLength = input.int(150, 'HMA Length', minval = 1, group = G_MA, tooltip = 'Period length for the central Hull Moving Average baseline.')
atrLength = input.int(100, 'ATR Length', minval = 1, group = G_MA, tooltip = 'Period length used to measure average true range volatility.')
atrMult   = input.float(1.6, 'ATR Multiplier Step', minval = 0.1, step = 0.1, group = G_MA, tooltip = 'Multiplier step distance applied to each grid channel level.')

var string G_GRID = 'Grid Settings'
numLevels  = input.int(3, 'Grid Levels (Each Side)', minval = 1, maxval = 5, group = G_GRID, tooltip = 'Number of channel levels projected above and below the baseline (1 to 5).')
thresholdP = input.float(0.5, 'Proximity Sensitivity (% of Step)', minval = 0.01, maxval = 1.0, step = 0.1, group = G_GRID, tooltip = 'Defines proximity distance to hide line segment when price is near.')

var string G_SIG = 'Signal Settings'
minGap = input.int(10, 'Minimum Bar Gap Between Signals', minval = 1, group = G_SIG, tooltip = 'Minimum number of bars required between consecutive crossover signals.')

var string G_STYLE = 'Style Settings'
baseTeal   = input.color(#1ecc75, 'Bullish Color', group = G_STYLE, tooltip = 'Primary color used for bullish levels, and buy signals.')
baseMaroon = input.color(#c04020, 'Bearish Color', group = G_STYLE, tooltip = 'Primary color used for bearish levels, and sell signals.')

sigLblSizeInput = input.string('normal', 'Signal Label Size', options = ['auto', 'tiny', 'small', 'normal', 'large', 'huge'], group = G_STYLE, tooltip = 'Font size applied to signal crossover annotations on both chart and oscillator.')
edgeLblSizeInput = input.string('normal', 'Right-Edge Label Size', options = ['auto', 'tiny', 'small', 'normal', 'large', 'huge'], group = G_STYLE, tooltip = 'Font size for right-edge grid level indicators.')

var string G_DASH = 'Dashboard Settings'
showDash    = input.bool(true, 'Show Position Dashboard', group = G_DASH, tooltip = 'Toggle vertical scale dashboard visibility.')
dashPos     = input.string('middle_right', 'Dashboard Position', options = ['top_right', 'middle_right', 'bottom_right'], group = G_DASH)
dashSizeInput = input.string('normal', 'Dashboard Size', options = ['auto', 'tiny', 'small', 'normal', 'large', 'huge'], group = G_DASH, tooltip = 'Controls the text size of the dashboard.')

// Helper function to translate string input to Pine Script label/table size
getLabelSize(string sz) =>
    switch sz
        'auto'   => size.auto
        'tiny'   => size.tiny
        'small'  => size.small
        'normal' => size.normal
        'large'  => size.large
        'huge'   => size.huge
        => size.small

sigLblSize  = getLabelSize(sigLblSizeInput)
edgeLblSize = getLabelSize(edgeLblSizeInput)
dashSize    = getLabelSize(dashSizeInput)

// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Core Calculations
centerLine = ta.hma(close, hmaLength)
atrVal     = ta.atr(atrLength) * atrMult
proxDist   = atrVal * thresholdP
oscValue   = atrVal != 0 ? (close - centerLine) / atrVal : 0.0

// Dynamic Level Calculations
upper1 = centerLine + atrVal * 1
lower1 = centerLine - atrVal * 1
upper2 = centerLine + atrVal * 2
lower2 = centerLine - atrVal * 2
upper3 = centerLine + atrVal * 3
lower3 = centerLine - atrVal * 3
upper4 = centerLine + atrVal * 4
lower4 = centerLine - atrVal * 4
upper5 = centerLine + atrVal * 5
lower5 = centerLine - atrVal * 5

// Helper for upper vs lower channel overlay dynamic colors
getGridColor(float gridLevel, int levelIdx, bool isUpper) =>
    float diff  = math.abs(close - gridLevel)
    float diff1 = math.abs(open - gridLevel)
    float diff2 = math.abs(hl2 - gridLevel)
    float diff3 = math.abs(hlc3 - gridLevel)
    float diff4 = math.abs(hlcc4 - gridLevel)

    bool isClose = diff <= proxDist or diff1 <= proxDist or diff2 <= proxDist or diff3 <= proxDist or diff4 <= proxDist

    float stepNorm   = levelIdx / float(numLevels)
    color targetBase = isUpper ? baseTeal : baseMaroon
    color startColor = color.new(targetBase, 85)
    color endColor   = color.new(targetBase, 20)

    color computedColor = color.from_gradient(stepNorm, 0.0, 1.0, startColor, endColor)
    isClose ? color(na) : computedColor

// Right-Edge Label Management
drawOverlayLabel(float yVal, string labelText, color txtColor) =>
    var label lbl = na
    if barstate.islast
        lbl := label.new(bar_index + 2, yVal, labelText, xloc = xloc.bar_index, yloc = yloc.price, color = color(na), textcolor = txtColor, style = label.style_label_left, size = edgeLblSize, force_overlay = true)
        label.delete(lbl[1])

// --- Unconditional Cross Calculations ---
bool crossBear1 = ta.crossunder(close, upper1)
bool crossBear2 = ta.crossunder(close, upper2)
bool crossBear3 = ta.crossunder(close, upper3)
bool crossBear4 = ta.crossunder(close, upper4)
bool crossBear5 = ta.crossunder(close, upper5)

bool crossBull1 = ta.crossover(close, lower1)
bool crossBull2 = ta.crossover(close, lower2)
bool crossBull3 = ta.crossover(close, lower3)
bool crossBull4 = ta.crossover(close, lower4)
bool crossBull5 = ta.crossover(close, lower5)

// Level-filtered signals
bool rawBear1 = crossBear1 and numLevels >= 1
bool rawBear2 = crossBear2 and numLevels >= 2
bool rawBear3 = crossBear3 and numLevels >= 3
bool rawBear4 = crossBear4 and numLevels >= 4
bool rawBear5 = crossBear5 and numLevels >= 5

bool rawBull1 = crossBull1 and numLevels >= 1
bool rawBull2 = crossBull2 and numLevels >= 2
bool rawBull3 = crossBull3 and numLevels >= 3
bool rawBull4 = crossBull4 and numLevels >= 4
bool rawBull5 = crossBull5 and numLevels >= 5

bool rawBearSignal = rawBear1 or rawBear2 or rawBear3 or rawBear4 or rawBear5
bool rawBullSignal = rawBull1 or rawBull2 or rawBull3 or rawBull4 or rawBull5

// ── ChartsConnect: trend-aligned signals, sized by grid level ──
// Furthest grid level price turned back from on this bar (1–5)
int bearLvl = rawBear5 ? 5 : rawBear4 ? 4 : rawBear3 ? 3 : rawBear2 ? 2 : rawBear1 ? 1 : 0
int bullLvl = rawBull5 ? 5 : rawBull4 ? 4 : rawBull3 ? 3 : rawBull2 ? 2 : rawBull1 ? 1 : 0

// Baseline colour: green = rising, red = not rising (same rule as the plotted HMA colour)
bool baseGreen = centerLine > centerLine[1]
bool baseRed   = not baseGreen

// SELL: baseline red, price above the baseline, candle closes back below an upper grid line
bool qualBear = rawBearSignal and baseRed and close > centerLine
// BUY: baseline green, price below the baseline, candle closes back above a lower grid line
bool qualBull = rawBullSignal and baseGreen and close < centerLine

// Minimum bar spacing & bar confirmation filter (closed bars only = non-repainting)
var int lastSigBar = -999
bool bearSignal = false
bool bullSignal = false

if barstate.isconfirmed and (qualBear or qualBull) and (bar_index - lastSigBar >= minGap)
    bearSignal := qualBear
    bullSignal := qualBull
    lastSigBar := bar_index

// Strength tier = how far price STRETCHED before turning, measured with wicks (high/low)
// over the last "Minimum Bar Gap" candles, in grid steps from the baseline:
//   reached +1/-1 = small, reached +2/-2 = medium, reached +3/-3 (or further) = large
float hiReach = atrVal != 0 ? (high - centerLine) / atrVal : 0.0
float loReach = atrVal != 0 ? (centerLine - low) / atrVal : 0.0
float maxHiReach = ta.highest(hiReach, minGap)
float maxLoReach = ta.highest(loReach, minGap)

int bearReachLvl = int(math.floor(maxHiReach))
int bullReachLvl = int(math.floor(maxLoReach))

int bearTier = bearSignal ? math.max(1, math.min(math.max(bearLvl, bearReachLvl), 3)) : 0
int bullTier = bullSignal ? math.max(1, math.min(math.max(bullLvl, bullReachLvl), 3)) : 0

tierBuyName(int t) =>
    t == 1 ? 'Buy' : t == 2 ? 'Buy Buy' : 'Must Buy'

tierSellName(int t) =>
    t == 1 ? 'Sell' : t == 2 ? 'Sell Sell' : 'Must Sell'

// Triangles — price chart
// Signal tag: one small triangle + small text (Buy / Buy Buy / Must Buy, Sell / Sell Sell / Must Sell)
// Names match the ChartsConnect outputs and alerts.
if bearSignal
    label.new(bar_index, high, tierSellName(bearTier) + '\n▼', xloc = xloc.bar_index, yloc = yloc.abovebar, color = color(na), textcolor = baseMaroon, style = label.style_label_down, size = size.small, force_overlay = true)

if bullSignal
    label.new(bar_index, low, '▲\n' + tierBuyName(bullTier), xloc = xloc.bar_index, yloc = yloc.belowbar, color = color(na), textcolor = baseTeal, style = label.style_label_up, size = size.small, force_overlay = true)

// }

// ＤＡＳＨＢＯＡＲＤ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

getDashPos(string p) =>
    switch p
        'top_right'    => position.top_right
        'middle_right' => position.middle_right
        'bottom_right' => position.bottom_right
        => position.middle_right

var table dash = table.new(getDashPos(dashPos), 2, 12, bgcolor = color.new(#20273a, 10), border_width = 2, border_color = chart.bg_color, force_overlay = true)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "Level", text_color = color.gray, text_size = dashSize)
    table.cell(dash, 1, 0, "Scale", text_color = color.gray, text_size = dashSize)

    for i = numLevels to -numLevels by 1
        int rowIdx = 6 - i
        float levelVal = i
        bool isCurrentRow = math.round(oscValue) == levelVal or (i == 5 and oscValue >= 5) or (i == -5 and oscValue <= -5)

        // Hide unused levels based on numLevels input
        if math.abs(i) > numLevels
            table.cell(dash, 0, rowIdx, "", text_size = dashSize)
            table.cell(dash, 1, rowIdx, "", text_size = dashSize)
        else
            string lvlStr = i > 0 ? "+" + str.tostring(i) : str.tostring(i)
            color lvlColor = i > 0 ? baseTeal : i < 0 ? baseMaroon : color.gray

            // Format marker to include value inside brackets instead of NOW
            string valFormatted = str.tostring(oscValue, "#.##")
            string marker = isCurrentRow ? "◄ [" + valFormatted + "]" : "│"
            color markerColor = isCurrentRow ? (oscValue >= 0 ? baseTeal : baseMaroon) : color.new(color.gray, 60)

            table.cell(dash, 0, rowIdx, lvlStr, text_color = lvlColor, text_size = dashSize)
            table.cell(dash, 1, rowIdx, marker, text_color = markerColor, text_size = dashSize)

// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// OVERLAY PLOTS (force_overlay = true)
trendColor = centerLine > centerLine[1] ? baseTeal : baseMaroon
plot(centerLine, 'Central HMA', color = trendColor, linewidth = 2, force_overlay = true)
plot(centerLine, 'Central HMA Glow', color = color.new(trendColor, 80), linewidth = 10, force_overlay = true)

// Upper/Lower Overlay Levels
plot(numLevels >= 1 ? upper1 : na, 'Upper 1', color = getGridColor(upper1, 1, true), linewidth = 1, force_overlay = true)
plot(numLevels >= 1 ? lower1 : na, 'Lower 1', color = getGridColor(lower1, 1, false), linewidth = 1, force_overlay = true)
if numLevels >= 1
    drawOverlayLabel(upper1, '+1', baseTeal)
    drawOverlayLabel(lower1, '-1', baseMaroon)

plot(numLevels >= 2 ? upper2 : na, 'Upper 2', color = getGridColor(upper2, 2, true), linewidth = 1, force_overlay = true)
plot(numLevels >= 2 ? lower2 : na, 'Lower 2', color = getGridColor(lower2, 2, false), linewidth = 1, force_overlay = true)
if numLevels >= 2
    drawOverlayLabel(upper2, '+2', baseTeal)
    drawOverlayLabel(lower2, '-2', baseMaroon)

plot(numLevels >= 3 ? upper3 : na, 'Upper 3', color = getGridColor(upper3, 3, true), linewidth = 2, force_overlay = true)
plot(numLevels >= 3 ? lower3 : na, 'Lower 3', color = getGridColor(lower3, 3, false), linewidth = 2, force_overlay = true)
if numLevels >= 3
    drawOverlayLabel(upper3, '+3', baseTeal)
    drawOverlayLabel(lower3, '-3', baseMaroon)

plot(numLevels >= 4 ? upper4 : na, 'Upper 4', color = getGridColor(upper4, 4, true), linewidth = 2, force_overlay = true)
plot(numLevels >= 4 ? lower4 : na, 'Lower 4', color = getGridColor(lower4, 4, false), linewidth = 2, force_overlay = true)
if numLevels >= 4
    drawOverlayLabel(upper4, '+4', baseTeal)
    drawOverlayLabel(lower4, '-4', baseMaroon)

plot(numLevels >= 5 ? upper5 : na, 'Upper 5', color = getGridColor(upper5, 5, true), linewidth = 2, force_overlay = true)
plot(numLevels >= 5 ? lower5 : na, 'Lower 5', color = getGridColor(lower5, 5, false), linewidth = 2, force_overlay = true)
if numLevels >= 5
    drawOverlayLabel(upper5, '+5', baseTeal)
    drawOverlayLabel(lower5, '-5', baseMaroon)

// }

// ＣＨＡＲＴＳＣＯＮＮＥＣＴ ＯＵＴＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// Strategy Builder outputs: 1 on the closed candle of that signal, 0 otherwise.
// Shown in the Data Window only, so they don't distort the price scale.
plot(bullTier == 1 ? 1 : 0, 'Buy',       color = baseTeal,   display = display.data_window)
plot(bullTier == 2 ? 1 : 0, 'Buy Buy',   color = baseTeal,   display = display.data_window)
plot(bullTier == 3 ? 1 : 0, 'Must Buy',  color = baseTeal,   display = display.data_window)
plot(bearTier == 1 ? 1 : 0, 'Sell',      color = baseMaroon, display = display.data_window)
plot(bearTier == 2 ? 1 : 0, 'Sell Sell', color = baseMaroon, display = display.data_window)
plot(bearTier == 3 ? 1 : 0, 'Must Sell', color = baseMaroon, display = display.data_window)

// Alerts — create with "Once Per Bar Close"
alertcondition(bullTier == 1, 'Buy',       'Dynamic Grid BUY (small) on {{ticker}} ({{interval}}) at {{close}}')
alertcondition(bullTier == 2, 'Buy Buy',   'Dynamic Grid BUY BUY (medium) on {{ticker}} ({{interval}}) at {{close}}')
alertcondition(bullTier == 3, 'Must Buy',  'Dynamic Grid MUST BUY (large) on {{ticker}} ({{interval}}) at {{close}}')
alertcondition(bearTier == 1, 'Sell',      'Dynamic Grid SELL (small) on {{ticker}} ({{interval}}) at {{close}}')
alertcondition(bearTier == 2, 'Sell Sell', 'Dynamic Grid SELL SELL (medium) on {{ticker}} ({{interval}}) at {{close}}')
alertcondition(bearTier == 3, 'Must Sell', 'Dynamic Grid MUST SELL (large) on {{ticker}} ({{interval}}) at {{close}}')

// }
````
