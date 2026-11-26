# Williams %R - %R | TR

- url: https://www.tradingview.com/script/x5E5Il5P-Williams-R-R-TR/
- type: indicator
- pine_id: PUB;7857c70730384e9b8151dfea2df81deb
- version: 1.0

## Description

🎯 Overview
Williams %R – %R | TR is a modernised version of Larry Williams’ classic momentum oscillator. It measures the closing price relative to the highest high over a lookback period, producing values from -100 (oversold) to 0 (overbought). This implementation adds dynamic entry levels (either fixed 50 or a moving average of %R), gradient candle coloring, momentum‑based fill transparency, and nine color themes – turning a traditional indicator into a highly visual, adaptable trading tool.

Key Features
📐 Core Oscillator
Williams %R – Standard formula: (HighestHigh - Close) / (HighestHigh - LowestLow) * -100.

Values typically range from -100 (oversold) to 0 (overbought).

Reversed scale – Lower values indicate selling pressure, higher values indicate buying pressure.

🎯 Flexible Entry/Exit Signal
Option 1: Fixed 50 Level – Classic approach: cross above -50 = bullish, below -50 = bearish.

Option 2: %R Moving Average – Uses a smoothed line (many MA types available) as the dynamic threshold. Crosses of %R above/below its own MA generate signals.

🎨 Advanced Visualization
9 Color Themes – Same palette as TQI and SVZO (Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic).

Dynamic Fill Zones – Three fills: overbought zone (above entry), oversold zone (below entry), and a trend‑direction fill. Transparency changes with %R momentum.

Gradient Candle Coloring – Candles smoothly transition between bearish and bullish colors based on normalised %R.

Signal Markers – Triangles below/above bars on entry crosses.

Trend Table – Shows “Bullish” or “Bearish” in large coloured text.

Floating Value Label – Displays current %R value near the oscillator line.

📈 Signal System
Zero‑line cross? – No, Williams %R normally uses -50 or a dynamic MA as the threshold.

Entry signals – Bullish cross above the threshold, bearish cross below.

Persistent trend state – Remembers last direction until a crossover occurs.

Real‑time updates – Calculated on every bar.

How It Works
Calculation Logic
Williams %R – ta.wpr(Length_WillR) (TradingView’s built‑in function).
%R = (highest_high - close) / (highest_high - lowest_low) * -100

Entry Threshold – User chooses:

'50' → fixed -50 level

'%R MA' → moving average of %R (configurable length and type)

Moving Average Engine – Supports 12 types: EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA, T3 (with T‑Factor).

Normalised %R – Rescaled 0‑1 range using 70‑period min/max. Used for gradient colors.

Momentum – 5‑bar absolute change of %R, normalised against 50‑period max.
Fill transparency = 35 - (norm_momentum * 25) clamped 0‑100.
→ Higher momentum = less transparency (more visible fill).

Trend State Persistence
Trend_WillR = 1 (bullish) when %R > threshold, -1 (bearish) when %R < threshold.

Holds until a crossover happens – prevents flickering near the threshold.

Display Options
Visual Components
%R Line – Coloured by trend state (bullish/bearish) with 50% opacity.

Entry Line – Yellow horizontal line (fixed -50 or dynamic MA).

Fills:

Above entry → overbought zone (bullish fill with momentum‑based transparency).

Below entry → oversold zone (bearish fill with transparency).

Third fill → only in the current trend direction, adding emphasis.

Gradient Candles – Price bars change colour smoothly between down‑color and up‑color based on normalised %R.

Entry Signals – Triangles below (long) or above (short) bars on crossover.

Background – Very light tint matching the trend direction.

Value Label – Floating label near the %R line showing current value.

Trend Table – Middle‑right corner displays “Bullish” or “Bearish”.

Trading Signals
Entry Signals
LONG – %R crosses above the entry threshold (fixed -50 or %R MA).
→ Triangle below the price bar.
→ Candles turn bullish (gradient).
→ Background tints bullish.

SHORT – %R crosses below the entry threshold.
→ Triangle above the bar.
→ Candles turn bearish.
→ Background tints bearish.

Trend Confirmation
Strong Bullish – %R well above entry, rising, with low fill transparency (high momentum).

Strong Bearish – %R well below entry, falling.

Overbought zone – > -20 (approx). May precede a reversal; use with caution.

Oversold zone – < -80 (approx). May precede a reversal.

Divergence – Price makes a lower low but %R makes a higher low (bullish divergence) or vice versa.

Customization Settings
Technical Parameters
Length %R – Lookback period for Williams %R (default 14).

Entry/Exit Signal – Choose '50' (fixed -50) or '%R MA' (dynamic MA).

Length MA – Period for %R moving average (default 365 – very long, effectively a trend filter).

Moving Average – 12 types (EMA, SMA, RMA, WMA, VWMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA, T3).

T3 Factor – Only for T3 moving average (0.7 default).

Visual Parameters
Color Choice – 9 themes (all fills, candles, background, signals follow the theme).

Alert System
LONG – Triggered on bullish cross (above entry).

SHORT – Triggered on bearish cross (below entry).
Alerts include ticker symbol.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tiagorocha1989 
//                              ████████╗ ████████╗  ████████╗  ███████╗   ██████╗        ██████╗   ██████╗   ██████╗ ██╗   ██╗ ████████╗
//                              ╚══██╔══╝ ╚══██╔══╝  ██╔═══██║  ██╔════╝  ██╔═══██╗       ██╔══██╗ ██╔═══██╗ ██╔════╝ ██║   ██║ ██╔═══██║
//                                 ██║       ██║     ████████║  ██║ ███║  ██║   ██║       ██████╔╝ ██║   ██║ ██║      ████████║ ████████║
//                                 ██║       ██║     ██╔═══██║  ██║  ██║  ██║   ██║       ██╔══██╗ ██║   ██║ ██║      ██║   ██║ ██╔═══██║
//                                 ██║    ████████╗  ██║   ██║  ███████║  ╚██████╔╝       ██║  ██║ ╚██████╔╝ ╚██████╗ ██║   ██║ ██║   ██║
//@version=6
indicator('Williams %R - %R | TR', '%R | TR →', false)
import TradingView/ta/12
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =        input.string('Classic', 'Color Choice', group = '🎨 Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
Length_WillR =      input.int(14, title = 'Length %R:', group='⚙️ %R Setting', inline = '%R')
Signal_WillR =      input.string('-50', 'Entry/Exit Signal', group='⚙️ %R Setting', options = ['-50', '%R MA'],tooltip = 'Choose Entry/Exit Point')
Length_MA_WillR =   input.int(365, title = 'Length MA', group='📊 %R MA', inline = '%R MA')
Source_MA_WillR =   input.string('EMA', 'Moving Average', group='📊 %R MA', inline = '%R MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'DEMA', 'TEMA', 'TRIMA', 'FRAMA', 'SWMA', 'T3'])
T_Factor =          input.float(0.7, 'T3 Factor', minval=0, maxval=1, step=0.05, group='📊 %R MA', tooltip = 'For Moving Average = T3')
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
//╔════════════════════════╗
//║      Calculation       ║
//╚════════════════════════╝
WillR = ta.wpr(Length_WillR)
WillR_MA = ma(WillR, Length_MA_WillR, T_Factor, Source_MA_WillR)
float Entry_WillR = Signal_WillR == '%R MA' ? WillR_MA : -50.0
isBull_WillR = WillR > Entry_WillR
isBear_WillR = WillR < Entry_WillR
Bull_WillR = ta.crossover(WillR, Entry_WillR)
Bear_WillR = ta.crossunder(WillR, Entry_WillR)
min_WillR = ta.lowest(WillR, 70)
max_WillR = ta.highest(WillR, 70)
range_WillR = max_WillR - min_WillR
norm_WillR = range_WillR != 0 ? (WillR - min_WillR) / range_WillR : 0.5
Trend_Color = color.from_gradient(norm_WillR, 0, 1, DnC, UpC)
momentum = math.abs(WillR - WillR[5])
max_momentum = ta.highest(momentum, 50)
norm_momentum = max_momentum > 0 ? math.min(momentum / max_momentum, 1) : 0
Fill_Transp = int(math.max(0, math.min(100, 35 - (norm_momentum * 25))))
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
var Trend_WillR = 0
Trend_WillR := isBull_WillR ? 1 : isBear_WillR ? -1 : nz(Trend_WillR[1])
//╔════════════════════════╗
//║          Plot          ║
//╚════════════════════════╝
Plot_WillR =        plot(WillR, color = Trend_WillR == 1 ? color.new(UpC, 50) : Trend_WillR == -1 ? color.new(DnC, 50) : na, linewidth = 2)
Plot_Entry_WillR =    plot(Entry_WillR, color = color.yellow)
fill(Plot_WillR, Plot_Entry_WillR, -20, Entry_WillR, top_color = color.new(UpC, Fill_Transp), bottom_color = color.new(UpC, 100), title = 'Overbought Fill')
fill(Plot_WillR, Plot_Entry_WillR, Entry_WillR, -80, top_color = color.new(DnC, 100), bottom_color = color.new(DnC, Fill_Transp), title = 'Oversold Fill')
fill(Plot_WillR, Plot_Entry_WillR, Trend_WillR == -1 ? WillR : Entry_WillR, Trend_WillR == -1 ? Entry_WillR : WillR, Trend_WillR == -1 ? color.new(DnC, Fill_Transp) : #00000000, Trend_WillR == -1 ? #00000000 : color.new(UpC, Fill_Transp))
plotcandle(open, high, low, close, 'Bar Color', Trend_Color, Trend_Color, bordercolor = Trend_Color, force_overlay = true)
plotshape(Bull_WillR, 'LONG' , shape.triangleup  , location.belowbar, UpC, 0, size = size.small, force_overlay = true)
plotshape(Bear_WillR, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size = size.small, force_overlay = true)
bgcolor(Trend_WillR == 1 ? color.new(UpC, 95) : Trend_WillR == -1 ? color.new(DnC, 95) : na, title='Zone Background', force_overlay = true)
//╔════════════════════════╗
//║          VIEW          ║
//╚════════════════════════╝
var table Table_WillR = table.new(position.middle_right, 1, 1, border_width = 1)
var label WillRLabel = na
if barstate.islast
    table.cell(Table_WillR, 0, 0, text = Trend_WillR == 1 ? '⬆️ Bullish' : Trend_WillR == -1 ? '⬇️ Bearish' : na, text_color = Trend_WillR == 1 ? UpC : Trend_WillR == -1 ? DnC : na, text_size = size.huge)
    if not na(WillRLabel)
        label.delete(WillRLabel)
    WillRLabel := label.new(bar_index + 5, WillR, text =  str.tostring(WillR, '#.##'), color = Trend_WillR == 1 ? color.new(UpC, 20) : Trend_WillR == -1 ? color.new(DnC, 20) : color.gray, style = label.style_label_left, size = size.large, textcolor = #000000)
//╔════════════════════════╗
//║         Alerts         ║
//╚════════════════════════╝
alertcondition(Bull_WillR, title= 'LONG', message= '{{ticker}} LONG')
alertcondition(Bear_WillR, title= 'SHORT', message= '{{ticker}} SHORT')
````
