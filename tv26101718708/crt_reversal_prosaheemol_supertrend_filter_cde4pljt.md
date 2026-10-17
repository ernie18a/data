# CRT Reversal PRO@Saheemol + SuperTrend Filter

- url: https://www.tradingview.com/script/Cde4PLJt-CRT-Reversal-PRO-Saheemol-SuperTrend-Filter/
- type: indicator
- pine_id: PUB;c6452023ab4c4f6d8cc238d7f2dfd570
- version: 1.0

## Description

# CRT Reversal PRO + SuperTrend Filter

CRT Reversal PRO + SuperTrend Filter is a price action-based reversal indicator designed to identify high-probability reversal opportunities using the Mother-Daughter candle concept combined with trend confirmation from SuperTrend.

### Key Features

* Detects bullish and bearish liquidity sweep reversals using Mother-Daughter candle formations.
* Filters setups using a configurable Mother Candle body strength requirement.
* Integrates SuperTrend confirmation to trade only in the direction of the prevailing trend.
* Includes 9 EMA and 21 EMA for additional trend analysis.
* Automatically plots:

  * Entry level
  * Stop Loss (based on Daughter Candle extremes)
  * TP1 and TP2 targets using customizable Risk:Reward ratios
* Fully customizable line colors, styles, widths, and lengths.
* Visual BUY and SELL labels for quick trade identification.
* Built-in alert conditions for automated notifications.

### Bullish Setup

A bullish setup is created when price sweeps below the Mother Candle low, closes back inside the Mother Candle range, and later breaks above the Mother Candle high while the SuperTrend remains bullish.

### Bearish Setup

A bearish setup is created when price sweeps above the Mother Candle high, closes back inside the Mother Candle range, and later breaks below the Mother Candle low while the SuperTrend remains bearish.

This indicator is designed for traders who combine price action, liquidity sweeps, and trend-following concepts to identify potential reversal opportunities with predefined risk and reward levels.

### Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Trading financial markets involves substantial risk and may not be suitable for all investors. Past performance does not guarantee future results. Always perform your own analysis and risk management before making any trading decisions.

## Source Code

````pine
//@version=6
indicator('CRT Reversal PRO@Saheemol + SuperTrend Filter', overlay = true, max_lines_count = 500, max_labels_count = 500)

//====================================================
// INPUTS
//====================================================

// EMA Inputs
ema9_length = input.int(9, 'EMA 9 Length')
ema21_length = input.int(21, 'EMA 21 Length')
ema9_color = input.color(color.new(color.blue, 0), 'EMA 9 Color')
ema21_color = input.color(color.new(color.red, 0), 'EMA 21 Color')

// Calculate EMAs
ema9 = ta.ema(close, ema9_length)
ema21 = ta.ema(close, ema21_length)

// Plot EMAs
plot(ema9, 'EMA 9', ema9_color, linewidth = 2)
plot(ema21, 'EMA 21', ema21_color, linewidth = 2)

//====================================================
// SUPERTREND FILTER
//====================================================
stAtrPeriod = input.int(10, 'SuperTrend ATR Period')
stFactor = input.float(2.0, 'SuperTrend Factor', step = 0.1)

[stValue, stDirection] = ta.supertrend(stFactor, stAtrPeriod)

plot(stValue, 'SuperTrend', stDirection < 0 ? color.green : color.red, linewidth = 2)

stBullish = stDirection < 0
stBearish = stDirection > 0

//====================================================
// MOTHER CANDLE FILTER
//====================================================
bodyRatioMin = input.float(60.0, 'Minimum Mother Body Ratio (%)', minval = 1, maxval = 100, step = 1)

// Daughter Candle Colors
daughterBullColor = input.color(color.lime, 'Bullish Daughter Color')
daughterBearColor = input.color(color.red, 'Bearish Daughter Color')

// TP Ratios
tp1RR = input.float(2.0, 'TP1 Risk Reward', minval = 0.1, step = 0.1)
tp2RR = input.float(4.0, 'TP2 Risk Reward', minval = 0.1, step = 0.1)

//====================================================
// LINE SETTINGS
//====================================================

// Mother High / Low
motherLineLength = input.int(10, 'Mother Line Length', minval = 1)
motherLineWidth = input.int(2, 'Mother Line Width', minval = 1, maxval = 5)
motherLineColor = input.color(color.orange, 'Mother Line Color')
motherLineStyleInput = input.string('Solid', 'Mother Line Style', options = ['Solid', 'Dashed', 'Dotted'])

// Entry
entryLineLength = input.int(5, 'Entry Line Length', minval = 1)
entryLineWidth = input.int(2, 'Entry Line Width', minval = 1, maxval = 5)
entryLineColor = input.color(color.green, 'Entry Line Color')
entryLineStyleInput = input.string('Solid', 'Entry Line Style', options = ['Solid', 'Dashed', 'Dotted'])

// SL
slLineLength = input.int(5, 'SL Line Length', minval = 1)
slLineWidth = input.int(2, 'SL Line Width', minval = 1, maxval = 5)
slLineColor = input.color(color.red, 'SL Line Color')
slLineStyleInput = input.string('Solid', 'SL Line Style', options = ['Solid', 'Dashed', 'Dotted'])

// TP
tpLineLength = input.int(5, 'TP Line Length', minval = 1)
tpLineWidth = input.int(2, 'TP Line Width', minval = 1, maxval = 5)
tpLineColor = input.color(color.blue, 'TP Line Color')
tpLineStyleInput = input.string('Solid', 'TP Line Style', options = ['Solid', 'Dashed', 'Dotted'])

// Labels
showLabels = input.bool(true, 'Show Labels')

//====================================================
// STYLE CONVERTERS
//====================================================
motherStyle = motherLineStyleInput == 'Solid' ? line.style_solid : motherLineStyleInput == 'Dashed' ? line.style_dashed : line.style_dotted
entryStyle = entryLineStyleInput == 'Solid' ? line.style_solid : entryLineStyleInput == 'Dashed' ? line.style_dashed : line.style_dotted
slStyle = slLineStyleInput == 'Solid' ? line.style_solid : slLineStyleInput == 'Dashed' ? line.style_dashed : line.style_dotted
tpStyle = tpLineStyleInput == 'Solid' ? line.style_solid : tpLineStyleInput == 'Dashed' ? line.style_dashed : line.style_dotted

//====================================================
// MOTHER CANDLE CALCULATION
//====================================================
motherRange = high[1] - low[1]
motherBody = math.abs(close[1] - open[1])
motherBodyRatio = motherRange > 0 ? motherBody / motherRange * 100 : 0

validMother = motherBodyRatio >= bodyRatioMin

//====================================================
// DAUGHTER CANDLE DETECTION
//====================================================

// Low Sweep
bullDaughter = validMother and low < low[1] and close > close[1] and close < high[1]

// High Sweep
bearDaughter = validMother and high > high[1] and close < close[1] and close > low[1]

// Daughter Candle Coloring
barcolor(bullDaughter ? daughterBullColor : na)
barcolor(bearDaughter ? daughterBearColor : na)

//====================================================
// STATE VARIABLES
//====================================================
var bool waitingBull = false
var bool waitingBear = false

var float motherHigh = na
var float motherLow = na
var int motherBar = na
var float daughterHigh = na
var float daughterLow = na
var int daughterBar = na

//====================================================
// STORE MOTHER DAUGHTER PAIR
//====================================================
if bullDaughter
    waitingBull := true
    waitingBear := false
    motherHigh := high[1]
    motherLow := low[1]
    motherBar := bar_index - 1
    daughterHigh := high
    daughterLow := low
    daughterBar := bar_index
    daughterBar

if bearDaughter
    waitingBear := true
    waitingBull := false
    motherHigh := high[1]
    motherLow := low[1]
    motherBar := bar_index - 1
    daughterHigh := high
    daughterLow := low
    daughterBar := bar_index
    daughterBar

//====================================================
// INVALIDATION
//====================================================
if waitingBull and close < motherLow
    waitingBull := false
    waitingBull

if waitingBear and close > motherHigh
    waitingBear := false
    waitingBear

//====================================================
// CONFIRMATION WITH SUPERTREND FILTER
//====================================================
bullConfirm = waitingBull and close > motherHigh and stBullish
bearConfirm = waitingBear and close < motherLow and stBearish

//====================================================
// BUY SIGNAL
//====================================================
if bullConfirm

    entry = motherHigh
    //sl = motherLow
    sl = daughterLow
    risk = entry - sl

    tp1 = entry + risk * tp1RR
    tp2 = entry + risk * tp2RR

    line.new(motherBar, motherHigh, motherBar + motherLineLength, motherHigh, color = motherLineColor, width = motherLineWidth, style = motherStyle)
    line.new(motherBar, motherLow, motherBar + motherLineLength, motherLow, color = motherLineColor, width = motherLineWidth, style = motherStyle)

    line.new(motherBar, entry, motherBar + entryLineLength, entry, color = entryLineColor, width = entryLineWidth, style = entryStyle)
    line.new(motherBar, sl, motherBar + slLineLength, sl, color = slLineColor, width = slLineWidth, style = slStyle)
    line.new(motherBar, tp1, motherBar + tpLineLength, tp1, color = tpLineColor, width = tpLineWidth, style = tpStyle)
    line.new(motherBar, tp2, motherBar + tpLineLength, tp2, color = tpLineColor, width = tpLineWidth, style = tpStyle)

    if showLabels
        label.new(motherBar + entryLineLength, entry, 'ENTRY', style = label.style_label_left, color = entryLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + slLineLength, sl, 'SL', style = label.style_label_left, color = slLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + tpLineLength, tp1, 'TP1', style = label.style_label_left, color = tpLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + tpLineLength, tp2, 'TP2', style = label.style_label_left, color = tpLineColor, textcolor = color.white, size = size.small)
        label.new(bar_index, low, 'BUY', style = label.style_label_up, color = color.green, textcolor = color.white, size = size.small)

    waitingBull := false
    waitingBull

//====================================================
// SELL SIGNAL
//====================================================
if bearConfirm

    entry = motherLow
    sl = daughterHigh

    risk = sl - entry

    tp1 = entry - risk * tp1RR
    tp2 = entry - risk * tp2RR

    line.new(motherBar, motherHigh, motherBar + motherLineLength, motherHigh, color = motherLineColor, width = motherLineWidth, style = motherStyle)
    line.new(motherBar, motherLow, motherBar + motherLineLength, motherLow, color = motherLineColor, width = motherLineWidth, style = motherStyle)

    line.new(motherBar, entry, motherBar + entryLineLength, entry, color = entryLineColor, width = entryLineWidth, style = entryStyle)
    line.new(motherBar, sl, motherBar + slLineLength, sl, color = slLineColor, width = slLineWidth, style = slStyle)
    line.new(motherBar, tp1, motherBar + tpLineLength, tp1, color = tpLineColor, width = tpLineWidth, style = tpStyle)
    line.new(motherBar, tp2, motherBar + tpLineLength, tp2, color = tpLineColor, width = tpLineWidth, style = tpStyle)

    if showLabels
        label.new(motherBar + entryLineLength, entry, 'ENTRY', style = label.style_label_left, color = entryLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + slLineLength, sl, 'SL', style = label.style_label_left, color = slLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + tpLineLength, tp1, 'TP1', style = label.style_label_left, color = tpLineColor, textcolor = color.white, size = size.small)
        label.new(motherBar + tpLineLength, tp2, 'TP2', style = label.style_label_left, color = tpLineColor, textcolor = color.white, size = size.small)
        label.new(bar_index, high, 'SELL', style = label.style_label_down, color = color.red, textcolor = color.white, size = size.small)

    waitingBear := false
    waitingBear

//====================================================
// ALERTS
//====================================================
alertcondition(bullConfirm, title = 'BUY Signal', message = 'Mother Daughter BUY setup confirmed')
alertcondition(bearConfirm, title = 'SELL Signal', message = 'Mother Daughter SELL setup confirmed')
````
