# Supertrend Oscillator Pro | TR

- url: https://www.tradingview.com/script/mBVXwXzl-Supertrend-Oscillator-Pro-TR/
- type: indicator
- pine_id: PUB;d8a9281b5e9c42fe8e59d2e956f64a6c
- version: 1.0

## Description

🎯 Overview
Supertrend Oscillator Pro transforms the classic Supertrend into a versatile, dual‑mode oscillator. It measures price distance from the Supertrend line either as a signed percentage (-100% to +100%) or as a raw ATR ratio. The indicator adds a powerful smoothing engine (11 moving average types), dynamic momentum‑based transparency, two independent signal systems (level crosses and reversal diamonds), plus comprehensive visual enhancements – gradient candles, trend fills, a persistent trend table, and nine color themes. It turns the simple Supertrend into a complete trend‑momentum trading system.

⚙️ Core Calculations
1. Base Supertrend (Classic Pine Logic)
Source: hl2 (high+low)/2

ATR Period: user defined (default 10)

Factor: user defined (default 3.0)

Outputs: stLine (Supertrend line), stDir (trend direction: -1 = uptrend, +1 = downtrend), atrValue

2. Raw Oscillator (rawOsc)

3. Oscillator Mode (User Selectable)
Mode A – Percentage (0‑100)
oscValue = (rawOsc / bandWidth) * 100
Then clamped to [-100, +100].

Mode B – Ratio (ATR)
oscValue = rawOsc / bandWidth (unbounded ratio, typically between -3 and +3)
Then normalised over last 70 bars to a [-3, +3] range:
norm = (smoothOsc - minRatio) / rangeRatio → oscPlot := norm * 6 - 3.

4. Smoothing (Moving Average Engine)
The raw oscillator is passed through one of 11 moving averages (user choice):
EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA, T3 (with adjustable T3 factor).
Default: HMA(25).

5. Normalisation for Gradient Coloring (normOsc)
Over the last 70 bars, oscPlot is re‑scaled to a [0,1] range → used for smooth candle color interpolation.

6. Momentum & Dynamic Fill Transparency
Momentum = absolute 5‑bar change of oscPlot

Max momentum over 50 bars → normalised normMomentum

Fill transparency = 35 - (normMomentum × 25), clamped 0‑100 (user can disable dynamic transparency).
→ Higher momentum = less transparent (more vivid fill).

🎨 Visual Features
9 Color Themes
Same palette as the classic version:
Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic.
Each defines upColor (bullish) and dnColor (bearish).

Gradient Candles (Overlay on Price)
Candle color interpolates between dnColor and upColor based on normOsc.
Plotted via plotcandle directly on the price chart.

Dynamic Fills (Oscillator Pane)
Positive area (osc > 0) – gradient from solid upColor (at upper level) to transparent (at zero), with momentum‑based transparency.

Negative area (osc < 0) – gradient from transparent (zero) to solid dnColor (at lower level).

Two separate fill pairs handle Percentage vs Ratio modes (levels differ).

Supertrend Overlay (Optional)
When Plot Supertrend Line is true, the classic Supertrend line is drawn on the price pane:

Uptrend (stDir < 0) → green (upColor)

Downtrend (stDir > 0) → red (dnColor)

Signal Markers
Triangles (level crosses) – user toggles showTriangles

LONG (bull cross) → green triangle below bar

SHORT (bear cross) → red triangle above bar

Diamonds (reversal signals) – user toggles showReversals

Reversal Up (price reverses from downtrend to uptrend) → diamond above/below bar with semi‑transparent upColor

Reversal Down → diamond with dnColor

Background Tint (Zone Background)
When bgZone enabled, the chart background gets a very light bullish or bearish tint matching the current trend (trendST).

Trend Table (Middle‑Right Corner)
Shows ⬆️ BULLISH or ⬇️ BEARISH in large colored text. Updates on trend changes.

Value Label (Last Bar)
Floating label showing the current oscillator value (e.g., 42.35% or 1.24). Positioned near the oscillator line with a semi‑transparent background matching the trend color.

Upper / Lower Level Lines
Percentage mode → user‑defined overbought (default 70) and oversold (default -70)

Ratio mode → automatically scaled to [-3, +3] equivalents (e.g., 70% → 2.1, -70% → -2.1)
Plotted as gray circle‑style lines.

📈 Signal System
1. Level Cross Signals (Triangles)
LONG (Bull_Cross) – ta.crossover(oscPlot, lowerLevel) OR ta.crossover(oscPlot, upperLevel)
(Entering oversold or overbought zone from below)

SHORT (Bear_Cross) – ta.crossunder(oscPlot, lowerLevel) OR ta.crossunder(oscPlot, upperLevel)

Debouncing logic:
lastSignal stores the direction (1 = long, -1 = short). A new signal is only generated if it differs from the last one.

2. Reversal Signals (Diamonds)
Reversal Up (Bullish reversal) – ta.crossover(oscPlot, oscPlot[1]) AND oscPlot < -thresholdForSignal
(Oscillator turns up from deep negative territory)

Reversal Down (Bearish reversal) – ta.crossunder(oscPlot, oscPlot[1]) AND oscPlot > thresholdForSignal

Cooldown mechanism:
Reversals are only plotted if the last reversal bar was more than 10 bars ago (prevents clustered signals).

3. Trend Persistence (trendST)
Set to 1 (bullish) on any LONG signal (level cross)

Set to -1 (bearish) on any SHORT signal

Used for background tint, table text, and fill reference colors.

4. Interpretation Guide (Percentage Mode)
+100 → price is exactly one full ATR‑bandwidth above Supertrend (very strong uptrend)

-100 → price is exactly one full ATR‑bandwidth below Supertrend (very strong downtrend)

Crossing zero → price crosses the Supertrend line (classic trend change)

Oversold / Overbought zones (e.g., ±70) → potential exhaustion / reversal areas.

5. Divergence Possibility (Not Coded, But Usable)
The raw oscPlot value (especially in Ratio mode) can be used for divergences:

Price makes higher high, oscillator makes lower high → bearish divergence

Price makes lower low, oscillator makes higher low → bullish divergence.

🚨 Alert System
Four alert conditions available (user‑toggleable):

LONG (Cross) – level cross triggers a bullish entry

SHORT (Cross) – level cross triggers a bearish entry

LONG (Reversal) – reversal diamond (bullish)

SHORT (Reversal) – reversal diamond (bearish)

Alerts include the ticker symbol in the message.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tiagorocha1989
//                              ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗
//                              ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║
//                                 ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║
//                                 ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║
//                                 ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║
//@version=6
indicator('Supertrend Oscillator Pro | TR', 'Supertrend Osc Pro | TR →', false)
import TradingView/ta/12
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
colorMode =         input.string('Classic', 'Color Scheme', options=['Classic','Modern','Heat','Robust','Accented','Monochrome','Moderate','Aqua','Cosmic'], group='🎨 Colors')
atrPeriod =         input.int(10, 'ATR Period', minval=1, group='⚙️ Supertrend')
factor =            input.float(3.0, 'Factor', minval=0.5, step=0.1, group='⚙️ Supertrend')
showSuperTrend =    input.bool(true, 'Plot Supertrend Line', group='⚙️ Supertrend')
oscType =           input.string('Percentage (0-100)', 'Oscillator Mode', options=['Percentage (0-100)', 'Ratio (ATR)'], group='📊 Oscillator')
overbought =        input.float(70, 'Overbought', minval=0, maxval=100, step=5, group='📊 Oscillator')
oversold =          input.float(-70, 'Oversold', minval=-100, maxval=0, step=5, group='📊 Oscillator')
ma_type =           input.string('HMA', 'Moving Average', group='📊 Supertrend MA', inline='MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA', 'T3'])
ma_length =         input.int(25, 'MA Length', minval=1, group='📊 Supertrend MA', inline='MA')
t3_factor =         input.float(0.7, 'T3 Factor', minval=0, maxval=1, step=0.05, group='📊 Supertrend MA', tooltip='Only for T3')
showTriangles =     input.bool(true, 'Triangles (level cross)', group='🔔 Signals')
showReversals =     input.bool(true, 'Diamonds (reversal)', group='🔔 Signals')
alertCross =        input.bool(false, 'Level cross alerts', group='🚨 Alerts')
alertReversal =     input.bool(false, 'Reversal alerts', group='🚨 Alerts')
fillTransparency =  input.bool(true, 'Dynamic transparency (momentum)', group='👁️ Visual')
bgZone =            input.bool(true, 'Zone background (trend)', group='👁️ Visual')
showTable =         input.bool(true, 'Trend table', group='👁️ Visual')
showLabel =         input.bool(true, 'Value label', group='👁️ Visual')
//╔═════════════════════════════════╗
//║     MOVING AVERAGE ENGINE       ║
//╚═════════════════════════════════╝
ma(source, length, factor, type) =>
     type == 'EMA'   ? ta.ema(source, length) :
     type == 'SMA'   ? ta.sma(source, length) :
     type == 'RMA'   ? ta.rma(source, length) :
     type == 'WMA'   ? ta.wma(source, length) :
     type == 'VWMA'  ? ta.vwma(source, length) :
     type == 'HMA'   ? ta.hma(source, length) :
     type == 'DEMA'  ? ta.dema(source, length) :
     type == 'TEMA'  ? ta.tema(source, length) :
     type == 'TRIMA' ? ta.trima(source, length) :
     type == 'FRAMA' ? ta.frama(source, length) :
     type == 'SWMA'  ? ta.swma(source) :
     type == 'T3'    ? ta.t3(source, length, factor) :
     na
//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[upColor, dnColor] = switch colorMode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]
//╔════════════════════════╗
//║      Calculation       ║
//╚════════════════════════╝
pine_supertrend(factor, atrPeriod) =>
    src = hl2
    atr = ta.atr(atrPeriod)
    upperBand = src + factor * atr
    lowerBand = src - factor * atr
    prevLowerBand = nz(lowerBand[1])
    prevUpperBand = nz(upperBand[1])
    lowerBand := lowerBand > prevLowerBand or close[1] < prevLowerBand ? lowerBand : prevLowerBand
    upperBand := upperBand < prevUpperBand or close[1] > prevUpperBand ? upperBand : prevUpperBand
    var float superTrend = na
    var int direction = na
    if barstate.isfirst
        direction := close > upperBand ? -1 : 1
        superTrend := direction == -1 ? lowerBand : upperBand
    else
        if nz(superTrend[1]) == nz(upperBand[1])
            direction := close > upperBand ? -1 : 1
        else
            direction := close < lowerBand ? 1 : -1
        superTrend := direction == -1 ? lowerBand : upperBand
    [superTrend, direction, atr]

[stLine, stDir, atrValue] = pine_supertrend(factor, atrPeriod)
bandWidth = factor * atrValue
safeBW = math.max(bandWidth, 1e-10)
rawOsc = close - stLine
oscValue = switch oscType
    'Percentage (0-100)' => (rawOsc / safeBW) * 100
    => rawOsc / safeBW

smoothOsc = ma(oscValue, ma_length, t3_factor, ma_type)
var float oscPlot = na
if oscType == 'Percentage (0-100)'
    oscPlot := math.min(100, math.max(-100, smoothOsc))
else
    lookback = 70
    minRatio = ta.lowest(smoothOsc, lookback)
    maxRatio = ta.highest(smoothOsc, lookback)
    rangeRatio = maxRatio - minRatio
    if rangeRatio > 0
        norm = (smoothOsc - minRatio) / rangeRatio
        oscPlot := norm * 6 - 3
    else
        oscPlot := 0
minOsc = ta.lowest(oscPlot, 70)
maxOsc = ta.highest(oscPlot, 70)
rangeOsc = maxOsc - minOsc
normOsc = rangeOsc != 0 ? (oscPlot - minOsc) / rangeOsc : 0.5
momentum = math.abs(oscPlot - nz(oscPlot[5], oscPlot))
maxMomentum = ta.highest(momentum, 50)
normMomentum = maxMomentum > 0 ? math.min(momentum / maxMomentum, 1) : 0
fillAlpha = fillTransparency ? int(math.max(0, math.min(100, 35 - (normMomentum * 25)))) : 80
overbought_ratio = (overbought / 100) * 3
oversold_ratio   = (oversold / 100) * 3
revThreshold_ratio = (50 / 100) * 3
upperLevel = oscType == 'Percentage (0-100)' ? overbought : overbought_ratio
lowerLevel = oscType == 'Percentage (0-100)' ? oversold : oversold_ratio
bullCrossOS = ta.crossover(oscPlot, lowerLevel)
bullCrossOB = ta.crossover(oscPlot, upperLevel)
bearCrossOS = ta.crossunder(oscPlot, lowerLevel)
bearCrossOB = ta.crossunder(oscPlot, upperLevel)

var int lastSignal = 0
var bool buySignal = false
var bool sellSignal = false

bool rawBuy = bullCrossOS or bullCrossOB
bool rawSell = bearCrossOS or bearCrossOB
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
if rawBuy and lastSignal != 1
    buySignal := true
    lastSignal := 1
else
    buySignal := false

if rawSell and lastSignal != -1
    sellSignal := true
    lastSignal := -1
else
    sellSignal := false

var int trendST = 0
if buySignal
    trendST := 1
else if sellSignal
    trendST := -1

thresholdForSignal = oscType == 'Percentage (0-100)' ? 50 : revThreshold_ratio

revDownRaw = ta.crossunder(oscPlot, oscPlot[1]) and oscPlot > thresholdForSignal
revUpRaw   = ta.crossover(oscPlot, oscPlot[1]) and oscPlot < -thresholdForSignal

var int lastSignalBar = na
if (revDownRaw or revUpRaw) and (nz(lastSignalBar) == 0 or bar_index - lastSignalBar > 10)
    lastSignalBar := bar_index

validRevDown = revDownRaw and bar_index - nz(lastSignalBar[1], -100) > 10
validRevUp   = revUpRaw   and bar_index - nz(lastSignalBar[1], -100) > 10
//╔════════════════════════╗
//║          Plot          ║
//╚════════════════════════╝
barColor = color.from_gradient(normOsc, 0, 1, dnColor, upColor)
trendFillColor = trendST == 1 ? upColor : dnColor

plot(showSuperTrend and stDir < 0 ? stLine : na, 'Up Trend', upColor, 2, plot.style_linebr, force_overlay=true)
plot(showSuperTrend and stDir > 0 ? stLine : na, 'Down Trend', dnColor, 2, plot.style_linebr, force_overlay=true)
plot(upperLevel, 'Upper Level', color.gray, 1, plot.style_circles)
plot(lowerLevel, 'Lower Level', color.gray, 1, plot.style_circles)
oscPlotObj =    plot(oscPlot, 'Oscillator', color=trendFillColor, linewidth=2)
zeroObj =       plot(0, 'Zero', color.gray, 1, plot.style_line)
fill(oscPlotObj, zeroObj, top_color = oscPlot > 0 ? color.new(upColor, fillAlpha) : color.new(upColor, 100), bottom_color = oscPlot > 0 ? color.new(upColor, 100) : color.new(upColor, 100), title='Percentage Positive Fill')
fill(oscPlotObj, zeroObj, 3, 0, top_color   = oscType == 'Ratio (ATR)' ? color.new(upColor, fillAlpha) : color.new(color.white, 100), bottom_color = oscType == 'Ratio (ATR)' ? color.new(upColor, 100) : color.new(color.white, 100), title='Ratio Positive Fill')
fill(oscPlotObj, zeroObj, 0, -100, top_color = color.new(dnColor, 100), bottom_color = color.new(dnColor, fillAlpha), title='Percentage Negative Fill')
fill(oscPlotObj, zeroObj, 0, -3, top_color   = oscType == 'Ratio (ATR)' ? color.new(dnColor, 100) : color.new(color.white, 100), bottom_color = oscType == 'Ratio (ATR)' ? color.new(dnColor, fillAlpha) : color.new(color.white, 100), title='Ratio Negative Fill')
plotcandle(open, high, low, close, 'Candle Color', barColor, barColor, bordercolor=barColor, force_overlay=true)
plotshape(showTriangles and buySignal, 'LONG', shape.triangleup, location.belowbar, upColor, 0, size=size.small, force_overlay=true)
plotshape(showTriangles and sellSignal, 'SHORT', shape.triangledown, location.abovebar, dnColor, 0, size=size.small, force_overlay=true)
plotshape(showReversals and validRevDown, 'Rev Down Absolute', shape.diamond, location.absolute, color=color.new(dnColor, 70), size=size.small, offset=-1)
plotshape(showReversals and validRevUp,   'Rev Up Absolute',   shape.diamond, location.absolute, color=color.new(upColor, 70), size=size.small, offset=-1)
plotshape(showReversals and validRevDown, 'Rev Down Abovebar', shape.diamond, location.abovebar, color=color.new(dnColor, 70), size=size.tiny, offset=-1, force_overlay=true)
plotshape(showReversals and validRevUp,   'Rev Up Belowbar',   shape.diamond, location.belowbar, color=color.new(upColor, 70), size=size.tiny, offset=-1, force_overlay=true)
bgcolor(bgZone and trendST == 1 ? color.new(upColor, 95) : bgZone and trendST == -1 ? color.new(dnColor, 95) : na, force_overlay=true)
//╔════════════════════════╗
//║          VIEW          ║
//╚════════════════════════╝
var table trendTable = na
var label valueLabel = na

if barstate.islast
    if showTable
        if na(trendTable)
            trendTable := table.new(position.middle_right, 1, 1, border_width=1)
        table.cell(trendTable, 0, 0, text=trendST == 1 ? '⬆️ BULLISH' : (trendST == -1 ? '⬇️ BEARISH' : 'NEUTRAL'), text_color=trendFillColor, text_size=size.huge)
    if showLabel
        labelText = oscType == 'Percentage (0-100)' ? str.tostring(oscPlot, '#.##') + '%' : str.tostring(oscPlot, '#.##')
        if na(valueLabel)
            valueLabel := label.new(bar_index+5, oscPlot, labelText, color=color.new(trendFillColor, 20), style=label.style_label_left, size=size.large, textcolor=#000000)
        else
            label.set_xy(valueLabel, bar_index+5, oscPlot)
            label.set_text(valueLabel, labelText)
            label.set_color(valueLabel, color.new(trendFillColor, 20))
//╔════════════════════════╗
//║         Alerts         ║
//╚════════════════════════╝
alertcondition(alertCross and buySignal, title='LONG (Cross)', message='{{ticker}} LONG signal')
alertcondition(alertCross and sellSignal, title='SHORT (Cross)', message='{{ticker}} SHORT signal')
alertcondition(alertReversal and validRevUp, title='LONG (Reversal)', message='{{ticker}} LONG reversal')
alertcondition(alertReversal and validRevDown, title='SHORT (Reversal)', message='{{ticker}} SHORT reversal')
````
