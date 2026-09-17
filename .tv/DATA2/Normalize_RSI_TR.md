<!-- tradingview-pine-id: PUB;ece9bfe7066d46cda028b546b401cffd -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Normalize RSI | TR

Source: https://www.tradingview.com/script/G6doUSCg-Normalize-RSI-TR/

## Description

📊 Normalize RSI | TR – Smart RSI Oscillator with Adaptive Normalization & Trend Signals

This indicator transforms the classic RSI into a dynamic, normalized oscillator that adapts to market conditions. It applies a multi-stage smoothing and normalization process to filter out noise, highlight true momentum shifts, and generate clear trend signals.

🔧 Key Features:
RSI Normalization – Centers RSI around 50 and normalizes it over a user-defined lookback period, creating a clean, bounded oscillator.

Dual Smoothing – Applies an exponential smoothing factor twice, allowing you to control responsiveness and reduce false signals.

Trend Detection – Automatically identifies bullish and bearish trends based on crossing customizable overbought/oversold levels.

Dynamic Color Palette – Choose from 9 color themes (Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic) to match your chart aesthetic.

Visual Signals – Displays colored candlesticks, background zones, entry shapes (triangles), and a real-time table with the current trend direction.

Momentum-Based Fill Transparency – The fill area between the zero line and the oscillator adapts to momentum strength, giving you visual cues on volatility.

Multi-Plot Display – Plots the normalized RSI, zero line, overbought/oversold levels, and includes a floating label with the latest value.

⚙️ Customizable Inputs:
RSI Length & Smoothing MA Type (EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA)

Normalization Length & Smoothing Factor

Clipping Factor to preserve extreme moves

Overbought / Oversold Levels (adjustable from -50 to +50)

🚨 Alerts Built-In:
Bullish / Bearish crossover of zero

Entry into Overbought / Oversold zones

📈 Ideal For:
Swing traders and scalpers looking for a refined RSI-based edge

Traders who prefer visual clarity and customizable color schemes

Those who want to combine momentum, trend, and volatility into one indicator

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 01010100 01101001 01100001 01100111 01101111 00100000 01010010 01101111 01100011 01101000 01100001 00100000 1011001
//           ╔══════╗       ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗       ╔══════╗
//           ║ ████ ║       ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║       ║ ████ ║
//          ╔╝██████╚╗         ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║      ╔╝██████╚╗
//          ║║      ║║         ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║      ║║      ║║
//           ╚╦════╦╝          ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║       ╚╦════╦╝
//@version=6
indicator('Normalize RSI | TR', 'Normalize RSI | TR →', false, precision=2)
import TradingView/ta/14
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =    input.string('Classic', 'Color Choice', group = '🎨 Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
RSI_Length =    input.int(42, 'RSI Length', minval=2, maxval=200, step=1, group='RSI Settings')
Source_MA_RSI = input.string('SMA', 'Moving Average', group='📊 RSI MA', inline = 'RSI MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA'])
RSI_MA_Length = input.int(34, 'RSI Smoothing Length', minval=1, maxval=100, step=1, group='RSI Settings')
Norm_Length =   input.int(34, 'Normalization Length', minval=5, maxval=200, step=1, group='Normalization')
smoothFact =    input.float(0.20, 'Smoothing Factor', minval=0.01, maxval=1.0, step=0.01, group='Normalization', tooltip='Higher values = faster response')
Clipping_RSI =  input.int(10, 'Clipping Factor', minval=1, maxval=40, group='Normalization', tooltip='Higher values preserve more extreme RSI movements')
obLevel =       input.int(40, 'Overbought Level', minval=-50, maxval=50, step=1, group='Levels')
osLevel =       input.int(-40, 'Oversold Level', minval=-50, maxval=50, step=1, group='Levels')
//╔═════════════════╗
//║     Color       ║
//╚═════════════════╝
[UpC, DnC] = switch Color_Mode
    'Classic'       => [#008800, #ff0000]
    'Modern'        => [#ffffff, #b721ff]
    'Heat'          => [#ff0000, #87cefb]
    'Robust'        => [#ffbb00, #770737]
    'Accented'      => [#8c5cf7, #e83e8c]
    'Monochrome'    => [#e9ecef, #495057]
    'Moderate'      => [#43a047, #e53935]
    'Aqua'          => [#00a8e8, #f18f01]
    'Cosmic'        => [#e83e8c, #6f2da8]
//╔═════════════════════════════════╗
//║     MOVING AVERAGE ENGINE       ║
//╚═════════════════════════════════╝
ma(source, length, type) =>
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
     na
//╔═════════════════════╗
//║     Calculation     ║
//╚═════════════════════╝
smoothExp(src, factor) =>
    var float smoothed = na
    smoothed := na(smoothed[1]) ? src : smoothed[1] + factor * (src - smoothed[1])
    smoothed

normalize(src, length) =>
    lowVal  = ta.lowest(src, length)
    highVal = ta.highest(src, length)
    rangeVal = highVal - lowVal
    rangeVal > 0 ? (src - lowVal) / rangeVal * 100 : nz(src[1])

Normalize_RSI = ta.rsi(close, RSI_Length) - 50
Normalize_RSI := ma(Normalize_RSI, RSI_MA_Length, Source_MA_RSI)
Normalize_RSI := math.max(Normalize_RSI, -Clipping_RSI)
Normalize_RSI := math.min(Normalize_RSI, Clipping_RSI)
normRSI = normalize(Normalize_RSI, Norm_Length)
smooth1 = smoothExp(normRSI, smoothFact)
norm2 = normalize(smooth1, Norm_Length)
smooth2 = smoothExp(norm2, smoothFact)
Final_RSI = smooth2 - 50
isRising = Final_RSI >= Final_RSI[1]
isFalling = Final_RSI < Final_RSI[1]
isBull_normalize_RSI = isRising and Final_RSI > osLevel
isBear_normalize_RSI = isFalling and Final_RSI < obLevel
Bull_normalize_RSI = ta.crossover(Final_RSI, osLevel)
Bear_normalize_RSI= ta.crossunder(Final_RSI, obLevel)
Min_normalize_RSI = ta.lowest(Final_RSI, 70)
Max_normalize_RSI = ta.highest(Final_RSI, 70)
Range_normalize_RSI = Max_normalize_RSI - Min_normalize_RSI
Norm_normalize_RSI = Range_normalize_RSI != 0 ? (Final_RSI - Min_normalize_RSI) / Range_normalize_RSI : 0.5
Trend_Color = color.from_gradient(Norm_normalize_RSI, 0, 1, DnC, UpC)
Momentum = math.abs(Final_RSI - Final_RSI[5])
Max_Momentum = ta.highest(Momentum, 50)
Norm_Momentum = Max_Momentum > 0 ? math.min(Momentum / Max_Momentum, 1) : 0
Fill_Transp = int(math.max(0, math.min(100, 35 - (Norm_Momentum * 25))))
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
var Trend_Normalize_RSI = 0
Trend_Normalize_RSI := isBull_normalize_RSI ? 1 : isBear_normalize_RSI ? -1 : nz(Trend_Normalize_RSI[1])
//╔═════════════════╗
//║     Plot        ║
//╚═════════════════╝
Plot_Normalize_RSI =    plot(Final_RSI, 'Normalize RSI', Trend_Color, linewidth = 2, display = display.pane)
plotZero =              plot(0, 'Zero RSI', Trend_Color, display = display.pane)
fill(Plot_Normalize_RSI, plotZero, 80, 0, top_color = color.new(UpC, Fill_Transp), bottom_color = color.new(UpC, 100), title = 'Overbought Fill')
fill(Plot_Normalize_RSI, plotZero, 0, -80, top_color = color.new(DnC, 100), bottom_color = color.new(DnC, Fill_Transp), title = 'Oversold Fill')
plotcandle(open, high, low, close, 'Bar Color', Trend_Color, Trend_Color, bordercolor = Trend_Color, force_overlay = true)
plotshape(Bull_normalize_RSI, 'LONG', shape.triangleup, location.belowbar, UpC, 0, size = size.small, force_overlay = true)
plotshape(Bear_normalize_RSI, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size = size.small, force_overlay = true)
bgcolor(Trend_Normalize_RSI == 1 ? color.new(UpC, 90) : Trend_Normalize_RSI == -1 ? color.new(DnC, 90) : color.gray, title='Zone Background', force_overlay=true)

hline(obLevel,  'Overbought', color=color.new(color.red, 70), linestyle=hline.style_dashed)
hline(osLevel,  'Oversold',   color=color.new(color.green, 70), linestyle=hline.style_dashed)
//╔═════════════════╗
//║     VIEW        ║
//╚═════════════════╝
var table Table_Normalize_RSI = table.new(position.middle_right, 1, 1, border_width = 1)
var label Label_Normalize_RSI = na
if barstate.islast
    table.cell(Table_Normalize_RSI, 0, 0, text = Trend_Normalize_RSI == 1 ? '⬆️ ＢＵＬＬＩＳＨ' : Trend_Normalize_RSI == -1 ? '⬇️ ＢＥＡＲＩＳＨ' : na, text_color = Trend_Normalize_RSI == 1 ? UpC : Trend_Normalize_RSI == -1 ? DnC : na, text_size = size.huge)
    if not na(Label_Normalize_RSI)
        label.delete(Label_Normalize_RSI)
    Label_Normalize_RSI := label.new(bar_index + 5, Final_RSI, text = str.tostring(Final_RSI, '#.##'), color = Trend_Normalize_RSI == 1 ? color.new(UpC, 20) : Trend_Normalize_RSI == -1 ? color.new(DnC, 20) : color.gray, style = label.style_label_left, size = size.large, textcolor = #000000)
//╔═════════════════╗
//║     Alerts      ║
//╚═════════════════╝
alertcondition(ta.crossover(Final_RSI, 0), title='Bullish Crossover', message='Normalize RSI crossed above zero')
alertcondition(ta.crossunder(Final_RSI, 0), title='Bearish Crossover', message='Normalize RSI crossed below zero')
alertcondition(ta.crossover(Final_RSI, obLevel), title='Overbought', message='Normalize RSI entered overbought zone')
alertcondition(ta.crossunder(Final_RSI, osLevel), title='Oversold', message='Normalize RSI entered oversold zone')
````
