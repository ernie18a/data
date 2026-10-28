# Average RSI | TR

- url: https://www.tradingview.com/script/QJIczgLk-Average-RSI-TR/
- type: indicator
- pine_id: PUB;ed400f148e424533ac9a2e941c1b8a70
- version: 1.0

## Description

🔍 OVERVIEW
The Average RSI is a next-generation momentum oscillator that goes beyond the standard Relative Strength Index. Instead of relying on a single timeframe, it calculates the RSI across three distinct daily cycles (1 Day, 2 Days, and 3 Days) and averages them into one smooth, highly responsive signal.

This multi-timeframe averaging drastically reduces market noise, filters out false divergences, and provides a holistic view of the short-to-medium term momentum structure. Combined with a dedicated dynamic moving average, it acts as both a trend filter and an early entry/exit system.

⚙️ HOW IT WORKS
1.  RSI Computation:
    The script calculates the classic RSI of your chosen source (default: Close) for the 1D, 2D, and 3D timeframes.

2.  The Average (AVG_RSI):
    It takes the arithmetic mean of these three values. This "composite RSI" is the core line you see plotted on the chart.

3.  The Trend Filter (MA_AVG_RSI):
    A fully customizable Moving Average (default: EMA, Length: 275) is applied to the AVG_RSI. This acts as the "Zero Line" of the indicator:
    • AVG_RSI > MA_AVG_RSI → Bullish Bias
    • AVG_RSI < MA_AVG_RSI → Bearish Bias

🎨 VISUAL FEATURES & SIGNALS
• Dynamic Trend Coloring:
  The main line, candles, and chart background dynamically shift colors based on a normalized gradient of the AVG_RSI, making trend strength instantly recognizable.

• Smart Gradient Fills:
  Ribbon Fill: The area between the AVG_RSI and its Moving Average is filled with the trend color. Its transparency adjusts automatically based on price momentum—more opaque during strong trends and faint during consolidation.
  
  Overbought/Sold Zones: Gradient fills between the AVG_RSI and the 50-level are activated only when the AVG_RSI extends beyond the Moving Average. This unique logic prevents misleading extreme-zone signals during trend reversals.

• Entry/Exit Signals (Triangles):
  LONG (⬆️): A green triangle appears below the bar when AVG_RSI crosses ABOVE the MA_AVG_RSI.
  SHORT (⬇️): A red triangle appears above the bar when AVG_RSI crosses BELOW the MA_AVG_RSI.

• Heads-Up Display (HUD):
  At the last bar, a large table displays the current market bias (Bullish/Bearish), and a floating label shows the precise AVG_RSI value.

🎛️ INPUT CONFIGURATIONS
• RSI Length: Adjust the sensitivity of the RSI calculation (Default: 44).
• Source: Choose the base source for the RSI (Default: Close).
• Moving Average Engine: Select from 12 different MA types, including EMA, SMA, WMA, HMA, DEMA, TEMA, TRIMA, FRAMA, SWMA, and T3 (with adjustable T3 Factor).
• MA Length: Set the smoothing period for the trend filter (Default: 275).
• Color Palettes: Choose from 9 distinct visual themes—Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, or Cosmic—to match your charting style.

🚨 ALERTS
Built-in alert conditions are ready to use:
• LONG: Triggered on a Bullish crossover.
• SHORT: Triggered on a Bearish crossunder.

💡 BEST USE CASES
• Swing Trading: Identify shifts in mid-term momentum.
• Trend Confirmation: Use the MA filter to avoid entering trades against the dominant flow.
• Divergence Spotting: The smoothed nature of AVG_RSI makes chart patterns and divergences much clearer than with standard RSI.

📌 Note: This indicator works on any asset (Crypto, Forex, Stocks, Commodities) and any timeframe, as the underlying MTF logic is anchored to the daily RSI structure.

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
indicator('Average RSI | TR →', 'AVG RSI | TR →', false)
import TradingView/ta/12
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
Color_Mode =    input.string('Classic', 'Color Choice', group = '🎨 Color', options = ['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
RSI_Source =    input.source(close, 'Source:', group='⚙️ AVG RSI Setting')
RSI_Lenght =    input.int(44, 'Length:', group='⚙️ AVG RSI Setting')
MA_Length =     input.int(275, 'MA Length', group='⚙️ AVG RSI Setting')
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
//╔═════════════════════╗
//║     Calculation     ║
//╚═════════════════════╝
rsi = ta.rsi(RSI_Source,RSI_Lenght)

rsi1 = request.security(syminfo.tickerid, '1D', barstate.isconfirmed ? rsi : rsi[1])
rsi2 = request.security(syminfo.tickerid, '2D', barstate.isconfirmed ? rsi : rsi[1])
rsi3 = request.security(syminfo.tickerid, '3D', barstate.isconfirmed ? rsi : rsi[1])
AVG_RSI = math.avg(rsi1, rsi2, rsi3)
MA_AVG_RSI =  ta.sma(AVG_RSI, MA_Length)
isBull_AVG_RSI = AVG_RSI > MA_AVG_RSI
isBear_AVG_RSI = AVG_RSI < MA_AVG_RSI
Bull_AVG_RSI = ta.crossover(AVG_RSI, MA_AVG_RSI)
Bear_AVG_RSI= ta.crossunder(AVG_RSI, MA_AVG_RSI)
Min_AVG_RSI = ta.lowest(AVG_RSI, 70)
Max_AVG_RSI = ta.highest(AVG_RSI, 70)
Range_AVG_RSI = Max_AVG_RSI - Min_AVG_RSI
Norm_AVG_RSI = Range_AVG_RSI != 0 ? (AVG_RSI - Min_AVG_RSI) / Range_AVG_RSI : 0.5
Trend_Color = color.from_gradient(Norm_AVG_RSI, 0, 1, DnC, UpC)
Momentum = math.abs(AVG_RSI - AVG_RSI[5])
Max_Momentum = ta.highest(Momentum, 50)
Norm_Momentum = Max_Momentum > 0 ? math.min(Momentum / Max_Momentum, 1) : 0
Fill_Transp = int(math.max(0, math.min(100, 35 - (Norm_Momentum * 25))))
var string lastSignal = na
plotBull = Bull_AVG_RSI and (na(lastSignal) or lastSignal != 'Bull')
plotBear = Bear_AVG_RSI and (na(lastSignal) or lastSignal != 'Bear')
if plotBull
    lastSignal := 'Bull'
if plotBear
    lastSignal := 'Bear'
//╔═════════════════════════╗
//║     Trend Condition     ║
//╚═════════════════════════╝
var Trend_AVG_RSI = 0
Trend_AVG_RSI := isBull_AVG_RSI ? 1 : isBear_AVG_RSI ? -1 : nz(Trend_AVG_RSI[1])
//╔═════════════════╗
//║     Plot        ║
//╚═════════════════╝
Plot_AVG_RSI =  plot(AVG_RSI, color = Trend_AVG_RSI == 1 ? color.new(UpC, 20) : Trend_AVG_RSI == -1 ? color.new(DnC, 20) : color.gray, linewidth = 2, display = display.pane)
Plot_MA =       plot(MA_AVG_RSI, 'Average RSI', Trend_AVG_RSI == 1 ? color.new(UpC, Fill_Transp) : Trend_AVG_RSI == -1 ? color.new(DnC, Fill_Transp) : color.gray, display = display.pane)
fill(Plot_AVG_RSI, Plot_MA, 65, MA_AVG_RSI, top_color = color.new(UpC, Fill_Transp), bottom_color = color.new(UpC, 100), title = 'Overbought Fill')
fill(Plot_AVG_RSI, Plot_MA, MA_AVG_RSI, 40, top_color = color.new(DnC, 100), bottom_color = color.new(DnC, Fill_Transp), title = 'Oversold Fill')
plotcandle(open, high, low, close, 'Bar Color', Trend_Color, Trend_Color, bordercolor = Trend_Color, force_overlay = true)
plotshape(Bull_AVG_RSI, 'LONG', shape.triangleup, location.belowbar, UpC, 0, size = size.small, force_overlay = true)
plotshape(Bear_AVG_RSI, 'SHORT', shape.triangledown, location.abovebar, DnC, 0, size = size.small, force_overlay = true)
bgcolor(Trend_AVG_RSI == 1 ? color.new(UpC, 90) : Trend_AVG_RSI == -1 ? color.new(DnC, 90) : color.gray, title='Zone Background', force_overlay=true)
//╔═════════════════╗
//║     VIEW        ║
//╚═════════════════╝
var table Table_AVG_RSI = table.new(position.middle_right, 1, 1, border_width = 1)
var label Label_AVG_RSI = na
if barstate.islast
    table.cell(Table_AVG_RSI, 0, 0, text = Trend_AVG_RSI == 1 ? '⬆️ Bullish' : Trend_AVG_RSI == -1 ? '⬇️ Bearish' : na, text_color = Trend_AVG_RSI == 1 ? UpC : Trend_AVG_RSI == -1 ? DnC : na, text_size = size.huge)
    if not na(Label_AVG_RSI)
        label.delete(Label_AVG_RSI)
    Label_AVG_RSI := label.new(bar_index + 5, AVG_RSI, text = str.tostring(AVG_RSI, '#.##'), color = Trend_AVG_RSI == 1 ? color.new(UpC, 20) : Trend_AVG_RSI == -1 ? color.new(DnC, 20) : color.gray, style = label.style_label_left, size = size.large, textcolor = #000000)
//╔═════════════════╗
//║     Alerts      ║
//╚═════════════════╝
alertcondition(lastSignal == 'Bull', title= 'LONG', message= '{{ticker}} LONG')
alertcondition(lastSignal == 'Bear', title= 'SHORT', message= '{{ticker}} SHORT')
````
