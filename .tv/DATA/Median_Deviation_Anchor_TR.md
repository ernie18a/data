<!-- tradingview-pine-id: PUB;1634f00344d343c7a00330178eef43b0 -->
<!-- tradingviewscripts-format: 1 -->
# Median Deviation Anchor | TR

Source: https://www.tradingview.com/script/tmkLumz4-Median-Deviation-Anchor-TR/

## Description

🎯 Overview
Median Deviation Anchor | TR is a trend‑detection oscillator that uses a percentile‑based median of a chosen moving average as its central anchor. It measures price deviation relative to this median, scaled by ATR bands and standard deviation zones, to generate bullish/bearish signals. The oscillator is smoothed, normalized, and presented with rich visual feedback including gradient candles, dynamic fills, reversal markers, and a persistent trend table. It’s designed to capture trend strength and reversals with a robust statistical foundation.

⚙️ Core Calculations
1. Moving Average Baseline
The indicator first computes a moving average of the Source (default close) using one of 13 moving average types (EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA, ALMA, T3).

User‑adjustable: Length (default 8), Factor/Sigma for ALMA/T3.

2. Median Anchor
Median_Val = ta.percentile_nearest_rank(MA, Median_Length, Median_per)
– This returns the value at the given percentile (default 50ᵗʰ percentile, i.e., the median) of the MA over Median_Length (default 61) bars.
→ This median acts as the dynamic “center” of the trend.

3. Deviation Bands (Upper/Lower Anchors)
ATR Band (based on ta.atr(ATR_Length)):

Upper_ATR = Median_Val + ATR_Mult * ATR

Lower_ATR = Median_Val - ATR_Mult * ATR

Standard Deviation Band (based on ta.stdev(Median_Val, Length_SD)):

SD_L = Median_Val + ST_Dev (upper +1σ)

SD_S = Median_Val - ST_Dev (lower -1σ)

4. Raw Oscillator (rawOsc)
Two conditions decide the raw value:

Bullish condition (L_Bull_MDA): (Source > Lower_ATR) and (Source >= SD_L)

Then bullForce = (Source - Median_Val) / (Median_Val - Lower_ATR) * 100
→ positive values (0 to +∞)

Bearish condition (S_Bear_MDA): (Source < Upper_ATR) and (Source <= SD_S)

Then bearForce = (Source - Median_Val) / (Upper_ATR - Median_Val) * 100
→ negative values (0 to –∞)

Otherwise rawOsc = 0.

5. Smoothing & Clamping
oscValue = ta.ema(rawOsc, smoothOsc) (user‑defined smoothOsc length, default 5).

osc = math.min(math.max(oscValue, -2000), 2000) – clamps extreme values.

📊 Normalisation & Dynamic Styling
Momentum for Fill Transparency:
absOsc = math.abs(osc) → maxAbsOsc = ta.highest(absOsc, 50) → normalised normAbsOsc → Fill_Transp_OSC = int(math.max(0, math.min(100, 35 - (normAbsOsc * 25))))
→ higher oscillator magnitude ⇒ less transparency (more vivid fills).

Gradient Coloring for Candles:
oscNorm is re‑scaled over the last 50 bars to [0,1] → candle color interpolates between DnC (bearish) and UpC (bullish) using color.from_gradient.

Color Themes: 9 predefined schemes (Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic) with custom bullish/bearish colours.

📈 Signal System
1. Trend Determination (Trend_MDA)
Bullish when osc > Upper_Band (user‑defined Long Threshold, default 50). Sets Trend_MDA = 1.

Bearish when osc < Lower_Band (user‑defined Short Threshold, default -50). Sets Trend_MDA = -1.

Otherwise holds previous value.

2. Reversal Signals (plot as triangles)
Bullish Reversal (reversalBull): Trend_MDA == 1 and Trend_MDA[1] == -1 → green triangle below bar.

Bearish Reversal (reversalBear): Trend_MDA == -1 and Trend_MDA[1] == 1 → red triangle above bar.

3. Alerts (4 conditions)
Bullish MDA – triggered when isBull_MDA (osc > Upper_Band)

Bearish MDA – triggered when isBear_MDA (osc < Lower_Band)

Bullish Cross – ta.crossover(osc, 0)

Bearish Cross – ta.crossunder(osc, 0)

🎨 Visual Features
Trend Table Displays “⬆️ Bullish” or “⬇️ Bearish” (or “➖ Neutral”)

📖 Interpretation Guide
Positive values (osc > 0) indicate price is above the median anchor (bullish bias).

Negative values (osc < 0) indicate price below the median (bearish bias).

Crossing ±50 (default thresholds) signals a confirmed trend change (bullish >50, bearish < -50).

Crossing zero may be used as an early warning of trend shift (alerts available).

Reversal triangles appear when the oscillator crosses a threshold in the opposite direction after being in the other regime – these are potential entry/exit signals.

The dynamic fill transparency highlights momentum: intense colour = strong price deviation.

🚨 Alert Summary
Four alert conditions are ready for automation:

Bullish MDA – enters long zone (osc > Upper_Band)

Bearish MDA – enters short zone (osc < Lower_Band)

Bullish Cross – oscillator crosses above zero

Bearish Cross – oscillator crosses below zero

All alerts can be enabled via the TradingView alerts panel.

---

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
indicator('Median Deviation Anchor | TR', 'MDA | TR →', false)
import TradingView/ta/12
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
colorMode =     input.string('Heat', 'Color Scheme', options=['Classic','Modern','Heat','Robust','Accented','Monochrome','Moderate','Aqua','Cosmic'], group='🎨 Colors')
MA_Type =       input.string('EMA', 'Moving Average', group='⚙️ Median Deviation Anchor', inline='Choice', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA', 'T3', 'ALMA'])
Source =        input.source(close, group = '⚙️ Median Deviation Anchor', inline='Choice')
Length =        input.int(8, 'Length', 1, group = '⚙️ Median Deviation Anchor')
Median_Length = input.int(61, 'Median Length', 1, group = '⚙️ Median Deviation Anchor')
Median_per =    input.int(50, 'Median Percentile', 1, 100, group = '⚙️ Median Deviation Anchor')
Length_SD =     input.int(30, 'Length SD', 1, group = '⚙️ Median Deviation Anchor')
ATR_Length =    input.int(10, 'ATR Length', 1, group = '⚙️ Median Deviation Anchor')
ATR_Mult =      input.float(0.5, 'ATR Multiplier', 0, step = 0.1, group = '⚙️ Median Deviation Anchor')
Sigma =         input.float(6.0,  'Sigma ALMA',  1.0, 15.0, 0.5, group='⚙️ Moving Average Setup', tooltip='Only for ALMA')
Factor =        input.float(0.7, 'Factor', 0, 1, 0.01, group='⚙️ Moving Average Setup', tooltip='For T3 and ALMA')
smoothOsc =     input.int(5, 'Smooth', 0, 20, group='📈 Oscillator')
Upper_Band =    input.float(50, 'Long Threshold', step=5, group='📈 Oscillator')
Lower_Band =    input.float(-50, 'Short Threshold', step=5, group='📈 Oscillator')
//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[UpC, DnC] = switch colorMode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]
//╔══════════════════════════════════╗
//║     MOVING AVERAGE ENGINE        ║
//╚══════════════════════════════════╝
ma(source, length, factor, sigma,  type) =>
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
     type == 'ALMA'  ? ta.alma(source, length, Factor, Sigma) :
     type == 'T3'    ? ta.t3(source, length, Factor) :
     na
//╔════════════════════════╗
//║      Calculation       ║
//╚════════════════════════╝
MA = ma(Source, Length, Factor, Sigma, MA_Type)
Median_Val = ta.percentile_nearest_rank(MA, Median_Length, Median_per)
ATR_Band   = ATR_Mult * ta.atr(ATR_Length)
Upper_ATR  = Median_Val + ATR_Band
Lower_ATR  = Median_Val - ATR_Band
ST_Dev = ta.stdev(Median_Val, Length_SD)
SD_L = Median_Val + ST_Dev
SD_S = Median_Val - ST_Dev
L_Bull_MDA = (Source > Lower_ATR) and (Source >= SD_L)
S_Bear_MDA = (Source < Upper_ATR) and (Source <= SD_S)

rawOsc = 0.0
if L_Bull_MDA
    bullForce = (Source - Median_Val) / (Median_Val - Lower_ATR) * 100
    rawOsc := bullForce
else if S_Bear_MDA
    bearForce = (Source - Median_Val) / (Upper_ATR - Median_Val) * 100
    rawOsc := bearForce
else
    rawOsc := 0.0

oscValue = ta.ema(rawOsc, smoothOsc)
osc = math.min(math.max(oscValue, -2000), 2000)
absOsc = math.abs(osc)
maxAbsOsc = ta.highest(absOsc, 50)
normAbsOsc = maxAbsOsc > 0 ? math.min(absOsc / maxAbsOsc, 1) : 0
Fill_Transp_OSC = int(math.max(0, math.min(100, 35 - (normAbsOsc * 25))))
minOsc = ta.lowest(osc, 50)
maxOsc = ta.highest(osc, 50)
rangeOsc = maxOsc - minOsc
oscNorm = rangeOsc != 0 ? (osc - minOsc) / rangeOsc : 0.5
Trend_Color = color.from_gradient(oscNorm, 0, 1, DnC, UpC)
isBull_MDA = osc > Upper_Band
isBear_MDA = osc < Lower_Band
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
var Trend_MDA = 0
Trend_MDA := isBear_MDA ? -1 : isBull_MDA ? 1 : nz(Trend_MDA[1])

reversalBull = Trend_MDA == 1 and Trend_MDA[1] == -1
reversalBear = Trend_MDA == -1 and Trend_MDA[1] == 1
//╔═════════════════╗
//║     Plot        ║
//╚═════════════════╝
oscPlot =       plot(osc, 'MDA Signal', color = Trend_MDA == 1 ? color.new(UpC, 50) : Trend_MDA == -1 ? color.new(DnC, 50) : na, linewidth = 3)
Upper_Plot =    plot(Upper_Band, color=#008800, linestyle= plot.linestyle_dotted, linewidth = 3)
Lower_Plot =    plot(Lower_Band, color=#ff0000, linestyle=plot.linestyle_dotted, linewidth = 3)
fill(oscPlot, Upper_Plot, 1000, Upper_Band, top_color = color.new(UpC, Fill_Transp_OSC), bottom_color = color.new(UpC, 100), title = 'Overbought Fill')
fill(oscPlot, Lower_Plot, Lower_Band, -1000, top_color = color.new(DnC, 100), bottom_color = color.new(DnC, Fill_Transp_OSC), title = 'Oversold Fill')
plotshape(reversalBull, 'LONG', shape.triangleup, location.belowbar, UpC, 0, size=size.small, force_overlay=true)
plotshape(reversalBear, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size=size.small, force_overlay=true)
bgcolor(Trend_MDA == 1 ? color.new(UpC, 95) : Trend_MDA == -1 ? color.new(DnC, 95) : na, title='Zone Background', force_overlay=true)
plotcandle(open, high, low, close, title='Candle Color', color=Trend_Color, wickcolor=Trend_Color, bordercolor=Trend_Color, force_overlay=true)
//╔═════════════════╗
//║     VIEW        ║
//╚═════════════════╝
var table MDATable = na
var label MDALabel = na

if barstate.islast
    if na(MDATable)
        MDATable := table.new(position.middle_right, 1, 1, border_width = 1)
    directionText = Trend_MDA == 1 ? '⬆️ Bullish' : Trend_MDA == -1 ? '⬇️ Bearish' : '➖ Neutral'
    tableColor = Trend_MDA == 1 ? UpC : Trend_MDA == -1 ? DnC : color.gray
    table.cell(MDATable, 0, 0, text=directionText, text_color=tableColor, text_size=size.huge)
else
    if not na(MDATable)
        table.delete(MDATable)
        MDATable := na
        labelText = str.tostring(osc, '#.##')
        labelColor = Trend_MDA == 1 ? UpC : Trend_MDA == -1 ? DnC : color.gray
        if na(MDALabel)
            MDALabel := label.new(bar_index + 5, osc, text = labelText, color = color.new(labelColor, 20), style = label.style_label_left, size = size.large, textcolor = #000000)
        else
            label.set_xy(MDALabel, bar_index + 5, osc)
            label.set_text(MDALabel, labelText)
            label.set_color(MDALabel, color.new(labelColor, 20))
    else
        if not na(MDALabel)
            label.delete(MDALabel)
            MDALabel := na
//╔═════════════════════════╗
//║         ALERTAS         ║
//╚═════════════════════════╝
alertcondition(isBull_MDA, title="Bullish MDA",  message="MDA Signal LONG")
alertcondition(isBear_MDA, title="Bearish MDA",  message="MDA Signal SHORT")
alertcondition(ta.crossover(osc, 0), title="Bullish Cross", message="MDA Osc: Bullish cross")
alertcondition(ta.crossunder(osc, 0), title="Bearish Cross", message="MDA Osc: Bearish cross")
````
