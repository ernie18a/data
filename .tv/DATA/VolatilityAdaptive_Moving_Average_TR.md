<!-- tradingview-pine-id: PUB;40e0d8959b3f42658ffb18e3407803d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 📊 Volatility-Adaptive Moving Average | TR 

Source: https://www.tradingview.com/script/iT95bxFg-Volatility-Adaptive-Moving-Average-TR/

## Description

📝 Overview
This indicator combines a volatility-adaptive moving average with dynamic period adjustment, creating a responsive trend-following system that automatically adjusts to changing market conditions.

The core concept is simple yet powerful: when volatility increases, the moving average becomes more responsive; when volatility decreases, it smooths out – reducing lag while filtering out noise.

⚙️ Key Features
📊 Smart Moving Average Engine
Choose from 15 different MA types:

Standard: EMA, SMA, RMA, WMA, VWMA

Advanced: HMA, SWMA, ALMA, DEMA, FRAMA, KAMA

Complex: T3, T3ALT, TEMA, TRIMA

🔄 Dynamic Period Adjustment
Period changes automatically based on volatility ratio

Uses ATR (Average True Range) to measure current market volatility

Can be smoothed for more stable period transitions

🎯 Visual Signals
Clear BUY/SELL labels on price crossovers

Volatility bands that expand/contract with market conditions

Real-time info label showing key metrics

Statistics table with all important values

🎨 Color Customization
9 different color schemes to match your chart style:

Classic, Modern, Heat, Robust, Accented, Monochrome, Moderate, Aqua, Cosmic

🔧 How It Works
ATR Calculation: Measures current market volatility

Average ATR: Establishes baseline volatility

Volatility Ratio: Compares current vs average volatility

Dynamic Period: Adjusts MA length based on this ratio

Adaptive MA: Plots the volatility-adjusted moving average

📈 Use Cases
✅ Trend Following – Capture trends early without excessive whipsaws
✅ Volatility Trading – Adjust position sizing based on market conditions
✅ Entry/Exit Signals – Get clear crossover signals with minimal lag
✅ Market Analysis – Visualize volatility expansion/contraction in real-time

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
indicator('📊 Volatility-Adaptive Moving Average | TR ','VAMA | TR →', true, precision=4)
import TradingView/ta/14
//╔═════════════════╗
//║     Input's     ║
//╚═════════════════╝
// 🎨 Color
Color_Mode =    input.string('Classic', 'Color Choice', group='🎨 Color', options=['Classic', 'Modern', 'Heat', 'Robust', 'Accented', 'Monochrome', 'Moderate', 'Aqua', 'Cosmic'])
// 📊 MOVING AVERAGE PRINCIPAL
ATR_Length =    input.int(14, 'ATR Length', group='📊 MA')
MA_Length =     input.int(50, 'MA Length', group='📊 MA')
MA_Type =       input.string('SMA', 'Moving Average', group='📊 MA', options=['EMA', 'SMA', 'RMA', 'WMA', 'VWMA', 'HMA', 'SWMA', 'ALMA', 'DEMA', 'FRAMA', 'KAMA', 'T3', 'T3ALT', 'TEMA', 'TRIMA'])
Factor =        input.float(0.7, 'Factor', minval=0, maxval=1, step=0.05, group='📊 MA', tooltip='For ALMA / T3 / T3ALT')
Kama =          input.int(2, 'KAMA Factor', minval=2, maxval=10, group='📊 MA', tooltip='For KAMA')
Sigma =         input.float(6, 'Sigma', minval=1, maxval=20, step=0.5, group='📊 MA', tooltip='For ALMA / KAMA')
// 🔄 MA Dynamics
Dinamic_Length =        input.int(50, 'Dinamic Length', minval=5, maxval=100, group='🔄 Dynamic')
Ratio_length =          input.int(20, 'Dinamic Ratio', minval=1, maxval=50, group='🔄 Dynamic')
Ratio_Volatilidade =    input.int(5, 'Min Period', minval=2, maxval=20, group='🔄 Dynamic')
MA_Dinamic =            input.string('EMA2', 'Dinamic MA', group='🔄 Dynamic', options=['EMA2', 'DEMA2', 'RMA2', 'TEMA2'])
smooth_dynamic =        input.bool(true, 'Smooth Dynamic Period', group='🔄 Dynamic')
smooth_len =            input.int(3, 'Smoothing Length', minval=2, maxval=10, group='🔄 Dynamic')
// 📊 DISPLAY
show_base_ma =      input.bool(false, 'Show Base MA', group='📊 Display')
show_bands =        input.bool(true, 'Show Volatility Bands', group='📊 Display')
band_mult =         input.float(1.5, 'Band Multiplier', minval=0.5, maxval=3, step=0.1, group='📊 Display')
show_signals =      input.bool(true, 'Show Buy/Sell Signals', group='📊 Display')
show_period_pane =  input.bool(true, 'Show Period in Pane', group='📊 Display')
show_info_label =   input.bool(true, 'Show Info Label', group='📊 Display')
show_stats_table =  input.bool(true, 'Show Stats Table', group='📊 Display')
//╔═════════════════════════════════╗
//║     MOVING AVERAGE ENGINE       ║
//╚═════════════════════════════════╝
ma(source, length, factor, sigma, kama, type) =>
     type == 'EMA'   ? ta.ema(source, length) :
     type == 'SMA'   ? ta.sma(source, length) :
     type == 'RMA'   ? ta.rma(source, length) :
     type == 'WMA'   ? ta.wma(source, length) :
     type == 'VWMA'  ? ta.vwma(source, length) :
     type == 'HMA'   ? ta.hma(source, length) :
     type == 'SWMA'  ? ta.swma(source) :
     type == 'ALMA'  ? ta.alma(source, length, factor, sigma) :
     type == 'DEMA'  ? ta.dema(source, length) :
     type == 'FRAMA' ? ta.frama(source, length) :
     type == 'KAMA'  ? ta.kama(source, math.round(length), kama, sigma) :
     type == 'T3'    ? ta.t3(source, length, factor) :
     type == 'T3ALT' ? ta.t3Alt(source, length, factor) :
     type == 'TEMA'  ? ta.tema(source, length) :
     type == 'TRIMA' ? ta.trima(source, length) :
     na

ma_dinamic(source, length, type) =>
     type == 'EMA2'  ? ta.ema2(source, length) :
     type == 'DEMA2' ? ta.dema2(source, length) :
     type == 'RMA2'  ? ta.rma2(source, length) :
     type == 'TEMA2' ? ta.tema2(source, length) :
     na
//╔═════════════════════════╗
//║         COLORS          ║
//╚═════════════════════════╝
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
atr_current = ta.atr(ATR_Length)
atr_media = ma(atr_current, MA_Length, Factor, Sigma, Kama, MA_Type)
volatility_ratio = atr_media != 0 ? atr_current / atr_media : 1.0
dynamic_period_raw = Dinamic_Length - (volatility_ratio * Ratio_length)
dynamic_clamped_period = math.max(volatility_ratio, math.min(Dinamic_Length, dynamic_period_raw))
mild_period = smooth_dynamic ? ta.sma(dynamic_clamped_period, smooth_len) : dynamic_clamped_period
dynamic_period = math.max(volatility_ratio, math.min(Dinamic_Length, mild_period))
ema_dynamic = ma_dinamic(close, dynamic_period, MA_Dinamic)
spot = ema_dynamic - close
ma_base = ma(close, MA_Length, Factor, Sigma, Kama, MA_Type)
banda_sup = ema_dynamic + (atr_current * band_mult)
banda_inf = ema_dynamic - (atr_current * band_mult)
purchase_crossover = ta.crossover(close, ema_dynamic)
selling_crossover = ta.crossunder(close, ema_dynamic)
//╔════════════════════════╗
//║          Plot          ║
//╚════════════════════════╝
plot(ema_dynamic, color=ema_dynamic > close ? DnC : UpC, linewidth=4, title='Dynamic EMA')
plot(show_base_ma ? ma_base : na, color=color.new(color.gray, 70), linewidth=1, title='Base MA', style=plot.style_line)
plot(show_bands ? banda_sup : na, color=color.new(DnC, 40), linewidth=1, title='Upper Band', style=plot.style_circles)
plot(show_bands ? banda_inf : na, color=color.new(UpC, 40), linewidth=1, title='Lower Band', style=plot.style_circles)
plotshape(show_signals and purchase_crossover, title="Buy Signal", location=location.belowbar, color=UpC, style=shape.labelup, text="BUY", textcolor=#000000, size=size.small)
plotshape(show_signals and selling_crossover, title="Sell Signal", location=location.abovebar, color=DnC, style=shape.labeldown, text="SELL", textcolor=#000000, size=size.small)
//╔════════════════════════╗
//║          VIEW          ║
//╚════════════════════════╝
if barstate.islast and show_info_label
    label_text = "📊 Period: " + str.tostring(math.round(dynamic_period)) + "\n💵 Spot: " + str.tostring(math.round(spot)) + " $" + "\n📈 ATR: " + str.tostring(math.round(atr_current, 2)) + "\n🔄 Ratio: " + str.tostring(math.round(volatility_ratio, 2))
    
    label.new(bar_index + 5, ema_dynamic, label_text, color=ema_dynamic > close ? DnC : UpC, textcolor=#000000, style=label.style_label_left, size=size.normal)

if barstate.islast and show_stats_table
    var table statsTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 80), border_color=color.gray, border_width=1)
    
    table.cell(statsTable, 0, 0, "📊 Statistics", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue, 50))
    table.merge_cells(statsTable, 0, 0, 1, 0)
    table.cell(statsTable, 0, 1, "Period:", text_color=color.white, text_size=size.normal)
    table.cell(statsTable, 1, 1, str.tostring(math.round(dynamic_period)), text_color=color.orange, text_size=size.normal)
    table.cell(statsTable, 0, 2, "Spot:", text_color=color.white, text_size=size.normal)
    spot_color = spot > 0 ? UpC : DnC
    table.cell(statsTable, 1, 2, str.tostring(math.round(spot)) + " $", text_color=spot_color, text_size=size.normal)
    table.cell(statsTable, 0, 3, "ATR:", text_color=color.white, text_size=size.normal)
    table.cell(statsTable, 1, 3, str.tostring(math.round(atr_current, 2)), text_color=color.purple, text_size=size.normal)
    table.cell(statsTable, 0, 4, "Ratio:", text_color=color.white, text_size=size.normal)
    ratio_color = volatility_ratio > 1 ? color.yellow : color.lime
    table.cell(statsTable, 1, 4, str.tostring(math.round(volatility_ratio, 2)), text_color=ratio_color, text_size=size.normal)
    table.cell(statsTable, 0, 5, "Signal:", text_color=color.white, text_size=size.normal)
    signal_text = ema_dynamic > close ? "🔻 LOW" : "🔺 HIGH"
    signal_color = ema_dynamic > close ? UpC : DnC
    table.cell(statsTable, 1, 5, signal_text, text_color=signal_color, text_size=size.normal)

linha_nivel = input.bool(false, "Show Level Line", group="📊 Display")
if linha_nivel and barstate.islast
    line.new(bar_index[1], ema_dynamic, bar_index, ema_dynamic, color=color.new(color.white, 30), width=1, style=line.style_dashed)
````
