# MACD + RSI + MFI + A/D by Ismael

- url: https://www.tradingview.com/script/jDwMEDrz/
- type: indicator
- pine_id: PUB;3c42e68c40a74f7ca8f395e82c078a93
- version: 1.0

## Description

█ OVERVIEW

A 4-in-1 oscillator panel combining MACD, RSI with Bollinger Bands and 
custom Buy/Sell signals, Money Flow Index (MFI), and Accumulation/Distribution. 
Each module can be toggled on/off independently from a single "Toggle 
Indicators" group, so the user can display only what they need instead of 
loading four separate scripts.

═══════════════════════════════════════════════════════════════════════

█ ORIGINALITY

This script does not invent new math — it integrates four well-known 
built-in indicators into a single pane and adds three conveniences:

 - A unified toggle system to show/hide each indicator on demand.
 - A custom RSI signal layer based on Bollinger Band breakouts of the 
   RSI itself, combined with the classic overbought/oversold zones.
 - An A/D module that replicates the configuration style of the 
   MetaTrader 5 implementation (Tick/Real volume option and configurable 
   horizontal levels).

═══════════════════════════════════════════════════════════════════════

█ WHAT IT INCLUDES

 ▪ MACD (default: ON)
   Standard MACD with configurable fast/slow lengths, signal smoothing, 
   and choice of SMA or EMA for both the oscillator and signal line. 
   Includes alerts for histogram polarity changes.

 ▪ RSI with Bollinger Bands and Buy/Sell signals (default: ON)
   Classic RSI with optional smoothing MA (SMA, EMA, WMA, VWMA, SMMA, 
   or SMA + Bollinger Bands). When "SMA + Bollinger Bands" is selected:
     - Buy signal: RSI closes below its lower Bollinger Band AND below 30.
     - Sell signal: RSI closes above its upper Bollinger Band AND above 70.
   Signals are plotted as arrows and include alert conditions.

 ▪ MFI (default: OFF)
   Standard Money Flow Index with 80/50/20 horizontal levels.

 ▪ Accumulation/Distribution (default: OFF)
   Classic cumulative A/D line. Configurable like the MT5 version:
     - Volume mode: Real or Tick (1 per bar, useful for FX).
     - 3 user-defined horizontal levels with individual visibility/color.
     - Color and line width.
   Includes alerts for crossovers against its own SMA(20).

═══════════════════════════════════════════════════════════════════════

█ HOW TO USE

 1. Activate from "Toggle Indicators" only the modules you need.
 2. RSI Buy/Sell signals are intended as confluence — not standalone 
    entries. They mark statistically rare conditions (extreme RSI combined 
    with a Bollinger Band breakout on the RSI) and should be confirmed 
    with price action, structure, or trend context.
 3. MACD histogram polarity alerts can be paired with RSI signals.
 4. The A/D line is most useful when watched for divergences against price, 
    not for its absolute value.

═══════════════════════════════════════════════════════════════════════

█ LIMITATIONS

 - The A/D line uses cumulative values that produce very large numbers. 
   When combined with MACD/RSI/MFI in the same pane, auto-scale will 
   compress the smaller-range indicators. Workaround: right-click the 
   A/D plot → "Pin to scale" → assign it to a separate scale.
 - "Tick" volume here is approximated as 1 per bar; Pine Script does not 
   expose the tick-volume data used by MetaTrader 5. For instruments with 
   reliable real volume, use "Real".
 - RSI Buy/Sell signals only fire when the smoothing MA type is set to 
   "SMA + Bollinger Bands". Other MA types disable the signal layer.
 - This is an aggregator/utility script. It does not predict market 
   direction and is not a complete trading system.

═══════════════════════════════════════════════════════════════════════

█ DISCLAIMER

This script is shared for educational purposes only and is not financial 
advice. Indicator signals do not guarantee future results. Always perform 
your own analysis and apply proper risk management.

═══════════════════════════════════════════════════════════════════════

█ DESCRIPCIÓN (Español)

Panel de osciladores 4-en-1 que combina MACD, RSI con Bandas de Bollinger 
y señales de compra/venta, MFI y Acumulación/Distribución. Cada módulo se 
activa o desactiva de forma independiente desde el grupo "Toggle 
Indicators".

Incluye:
 - MACD estándar con alertas de cambio de polaridad del histograma.
 - RSI con MA opcional (SMA, EMA, WMA, VWMA, SMMA o SMA+BB). Cuando 
   se elige "SMA + Bandas de Bollinger", aparecen señales:
     - Compra: RSI por debajo de la banda inferior Y menor a 30.
     - Venta: RSI por encima de la banda superior Y mayor a 70.
 - MFI estándar con niveles 80/50/20.
 - Acumulación/Distribución estilo MT5: volumen Real/Tick, 3 niveles 
   horizontales configurables, color y grosor ajustables, alertas de 
   cruce contra su SMA(20).

Las señales del RSI son herramientas de confluencia, no entradas 
automáticas. La línea A/D se interpreta principalmente por divergencias 
con el precio, no por su valor absoluto. Al activar A/D junto con los 
demás osciladores, conviene moverla a una escala separada (clic derecho 
sobre la línea → "Fijar a escala" → escala nueva).

Este script tiene fines educativos. No constituye asesoría financiera.


█ HOW TO USE

The RSI Buy/Sell signals (with their attached alerts) are the main 
actionable element of this script and can be used to anticipate potential 
entries — long on Buy signals, short on Sell signals. They fire under 
statistically rare conditions (RSI breaking out of its own Bollinger Band 
envelope while also being in extreme oversold/overbought territory), 
which often precede a reversion or a meaningful move.

However, these signals should NOT be taken as standalone entries. They 
work best as an early-warning system that must be confirmed before 
acting on them. Recommended workflow:

 1. RSI Buy/Sell signal fires → set alert and prepare the trade idea.

 2. Look at the MACD for confirmation:
      - For a Buy: histogram should be turning from falling to rising, 
        or MACD line crossing above Signal.
      - For a Sell: histogram turning from rising to falling, or MACD 
        line crossing below Signal.

 3. Check the MFI (if enabled): values pulling back from oversold (<20) 
    on Buys, or pulling back from overbought (>80) on Sells, add 
    confluence by confirming a money-flow shift.

 4. Check the A/D line for divergences with price:
      - Bullish divergence (price makes lower low, A/D makes higher low) 
        strongly supports a Buy signal.
      - Bearish divergence (price makes higher high, A/D makes lower 
        high) strongly supports a Sell signal.
    Divergences on RSI itself against price work the same way and are 
    one of the most reliable confirmation tools in this panel.

 5. Always combine with price-action context: trend direction on higher 
    timeframes, key support/resistance, and your own risk management.

In short: the RSI signals are designed to ANTICIPATE trades, not to 
trigger them automatically. The other modules (MACD, MFI, A/D) and 
divergence analysis exist to filter the false positives and validate 
the ones worth taking.

═══════════════════════════════════════════════════════════════════════

█ CÓMO USAR (Español)

Las señales de Compra/Venta del RSI (con sus alertas configuradas) son 
el elemento principal accionable de este script y pueden usarse para 
anticipar entradas — largos en señales de Compra, cortos en señales de 
Venta. Se activan en condiciones estadísticamente poco frecuentes 
(el RSI rompe su propia envolvente de Bandas de Bollinger mientras 
está en zona de sobreventa o sobrecompra extrema), que suelen preceder 
una reversión o un movimiento significativo.

Sin embargo, NO deben tomarse como entradas automáticas. Funcionan 
mejor como un sistema de alerta temprana que debe confirmarse antes 
de operar. Flujo recomendado:

 1. Se dispara la señal del RSI → preparar la idea de trade.

 2. Confirmar con MACD:
      - Compra: histograma pasando de bajista a alcista, o cruce 
        del MACD por encima de la Signal.
      - Venta: histograma pasando de alcista a bajista, o cruce 
        del MACD por debajo de la Signal.

 3. Confirmar con MFI (si está activo): valores saliendo de 
    sobreventa (<20) en Compras o saliendo de sobrecompra (>80) 
    en Ventas indican un cambio en el flujo de dinero.

 4. Buscar divergencias en la línea A/D contra el precio:
      - Divergencia alcista (precio hace mínimo más bajo, A/D hace 
        mínimo más alto) refuerza una señal de Compra.
      - Divergencia bajista (precio hace máximo más alto, A/D hace 
        máximo más bajo) refuerza una señal de Venta.
    Las divergencias del propio RSI contra el precio funcionan igual 
    y son una de las confirmaciones más fiables de este panel.

 5. Siempre combinar con contexto de price action: tendencia en 
    temporalidades superiores, soportes/resistencias clave y gestión 
    de riesgo propia.

En resumen: las señales del RSI están diseñadas para ANTICIPAR 
trades, no para dispararlos automáticamente. Los otros módulos 
(MACD, MFI, A/D) y el análisis de divergencias existen para filtrar 
los falsos positivos y validar las entradas que realmente valen 
la pena.

## Source Code

````pine
//@version=6
indicator(title="MACD + RSI + MFI + A/D by Ismael", shorttitle="Indicator ISRS", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// ==================================================================
// 🔹 TOGGLE INDICATORS
// ==================================================================
enable_macd = input.bool(true,  title="Enable MACD", group="Toggle Indicators")
enable_rsi  = input.bool(true,  title="Enable RSI",  group="Toggle Indicators")
enable_mfi  = input.bool(false, title="Enable MFI",  group="Toggle Indicators")
enable_ad   = input.bool(false, title="Enable A/D",  group="Toggle Indicators")


// ==================================================================
// 🔹 MACD SECTION
// ==================================================================
fast_length = input(title = "Fast Length", defval = 12, group="MACD Settings")
slow_length = input(title = "Slow Length", defval = 26, group="MACD Settings")
src = input(title = "Source", defval = close, group="MACD Settings")
signal_length = input.int(title = "Signal Smoothing", minval = 1, maxval = 50, defval = 9, group="MACD Settings")
sma_source = input.string(title = "Oscillator MA Type", defval = "EMA", options = ["SMA", "EMA"], group="MACD Settings")
sma_signal = input.string(title = "Signal Line MA Type", defval = "EMA", options = ["SMA", "EMA"], group="MACD Settings")

// Calculating
fast_ma = sma_source == "SMA" ? ta.sma(src, fast_length) : ta.ema(src, fast_length)
slow_ma = sma_source == "SMA" ? ta.sma(src, slow_length) : ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = sma_signal == "SMA" ? ta.sma(macd, signal_length) : ta.ema(macd, signal_length)
hist = macd - signal

// Alerts
alertcondition(hist[1] >= 0 and hist < 0, title = 'MACD: Rising to falling', message = 'The MACD histogram switched from a rising to falling state')
alertcondition(hist[1] <= 0 and hist > 0, title = 'MACD: Falling to rising', message = 'The MACD histogram switched from a falling to rising state')

// Plots
hline(enable_macd ? 0 : na, "Zero Line", color = color.new(#787B86, 50), display = enable_macd ? display.all : display.none)
plot(enable_macd ? hist : na, title = "Histogram", style = plot.style_columns, color = (hist >= 0 ? (hist[1] < hist ? #26A69A : #B2DFDB) : (hist[1] < hist ? #FFCDD2 : #FF5252)), display = enable_macd ? display.all : display.none)
plot(enable_macd ? macd : na, title = "MACD", color = #2962FF, display = enable_macd ? display.all : display.none)
plot(enable_macd ? signal : na, title = "Signal", color = #FF6D00, display = enable_macd ? display.all : display.none)

// ==================================================================
// 🔹 RSI SECTION
// ==================================================================
rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")

change = ta.change(rsiSourceInput)
up = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot = plot(enable_rsi ? rsi : na, "RSI", color=#facc15, display = enable_rsi ? display.all : display.none)

rsiUpperBand = 70
rsiLowerBand = 30

upperBandPlot = plot(enable_rsi ? rsiUpperBand : na, "RSI Upper Band", color=#787b8600, style=plot.style_linebr, linewidth=1, display = enable_rsi ? display.all : display.none)
lowerBandPlot = plot(enable_rsi ? rsiLowerBand : na, "RSI Lower Band", color=color.new(#787b86, 100), style=plot.style_linebr, linewidth=1, display = enable_rsi ? display.all : display.none)
midlinePlot = plot(enable_rsi ? 50 : na, "RSI Middle Band", color=color.new(#787b86, 84), display = enable_rsi ? display.all : display.none)

fill(upperBandPlot, lowerBandPlot, color=color.rgb(84, 138, 255, 95), title="RSI Background Fill", display=enable_rsi ? display.all : display.none)
fill(rsiPlot, midlinePlot, color=color.new(#4caf4f, 100), title="Overbought Gradient Fill", display=enable_rsi ? display.all : display.none)
fill(rsiPlot, midlinePlot, color=color.new(#ff5252, 100), title="Oversold Gradient Fill", display=enable_rsi ? display.all : display.none)

GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput = input.string("SMA + Bollinger Bands", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.data_window)
maLengthInput = input.int(14, "Length", group = GRP, display = display.data_window)
bbMultInput = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.data_window)

enableMA = enable_rsi and (maTypeInput != "None")
isBB = enable_rsi and (maTypeInput == "SMA + Bollinger Bands")

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(enableMA ? smoothingMA : na, "RSI-based MA", color=color.rgb(255, 235, 59, 100), display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBandPlot = plot(isBB ? smoothingMA + smoothingStDev : na, title = "Upper Bollinger Band", color=color.rgb(76, 175, 79, 100), display = isBB ? display.all : display.none, editable = isBB)
bbLowerBandPlot = plot(isBB ? smoothingMA - smoothingStDev : na, title = "Lower Bollinger Band", color=color.rgb(76, 175, 79, 100), display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBandPlot, bbLowerBandPlot, color= isBB ? #5555551a : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

buyCondition = enable_rsi ? (rsi < smoothingMA - smoothingStDev and rsi < rsiLowerBand) : false
sellCondition = enable_rsi ? (rsi > smoothingMA + smoothingStDev and rsi > rsiUpperBand) : false

plotshape(series=buyCondition ? rsi : na, title="Buy Signal", location=location.top, color=#19191a, style=shape.arrowdown, size=size.small, text="", display = enable_rsi ? display.all : display.none)
plotshape(series=sellCondition ? rsi : na, title="Sell Signal", location=location.bottom, color=#19191a, style=shape.arrowup, size=size.small, text="", display = enable_rsi ? display.all : display.none)

alertcondition(buyCondition, title="RSI Buy Signal Alert", message="RSI Buy Signal Detected!")
alertcondition(sellCondition, title="RSI Sell Signal Alert", message="RSI Sell Signal Detected!")

// ==================================================================
// 🔹 MFI SECTION
// ==================================================================
mfiLengthInput = input.int(14, title="MFI Length", group="MFI Settings")
mfiSourceInput = input.source(hlc3, title="Source", group="MFI Settings")

mf = ta.mfi(mfiSourceInput, mfiLengthInput)

mfPlot = plot(enable_mfi ? mf : na, title="Money Flow Index", color=#26A69A, display = enable_mfi ? display.all : display.none)

overbought = hline(enable_mfi ? 80 : na, title="Overbought", color=#787B86, display = enable_mfi ? display.all : display.none)
midlineMFI = hline(enable_mfi ? 50 : na, title="Middle Band", color=color.new(#787B86, 50), display = enable_mfi ? display.all : display.none)
oversold = hline(enable_mfi ? 20 : na, title="Oversold", color=#787B86, display = enable_mfi ? display.all : display.none)

fill(overbought, oversold, color=color.rgb(38, 166, 154, 90), title="MFI Background Fill", display=enable_mfi ? display.all : display.none)

// // ==================================================================
// 🔹 ACCUMULATION / DISTRIBUTION SECTION (estilo MetaTrader 5)
// ==================================================================

// --- ACCUMULATION/DISTRIBUTION ---
adVolumeType = input.string("Real", title="Volúmenes", options=["Tick", "Real"], group="A/D Settings", tooltip="Real: usa el volumen real del activo. Tick: cuenta cada barra como 1 unidad (equivalente al volumen tick de MT5, útil cuando no hay volumen real, ej. Forex).")

// --- NIVELES ---
adLevel1On    = input.bool(false, title="",         inline="lvl1", group="A/D Niveles")
adLevel1Val   = input.float(0,    title="Nivel 1",  inline="lvl1", group="A/D Niveles")
adLevel1Color = input.color(color.gray, title="",   inline="lvl1", group="A/D Niveles")

adLevel2On    = input.bool(false, title="",         inline="lvl2", group="A/D Niveles")
adLevel2Val   = input.float(0,    title="Nivel 2",  inline="lvl2", group="A/D Niveles")
adLevel2Color = input.color(color.gray, title="",   inline="lvl2", group="A/D Niveles")

adLevel3On    = input.bool(false, title="",         inline="lvl3", group="A/D Niveles")
adLevel3Val   = input.float(0,    title="Nivel 3",  inline="lvl3", group="A/D Niveles")
adLevel3Color = input.color(color.gray, title="",   inline="lvl3", group="A/D Niveles")

// --- ESTILO ---
adColor     = input.color(#26A69A, title="Color",  group="A/D Estilo")
adLineWidth = input.int(1, title="Grosor", minval=1, maxval=5, group="A/D Estilo")

// --- Cálculo ---
adVol = adVolumeType == "Real" ? volume : 1.0
ad = ta.cum(close == high and close == low or high == low ? 0 : ((2 * close - low - high) / (high - low)) * adVol)

// --- Plots ---
plot(enable_ad ? ad : na, title="Accumulation/Distribution", color=adColor, linewidth=adLineWidth, display=enable_ad ? display.all : display.none)

// --- Niveles horizontales ---
hline(adLevel1Val, title="A/D Nivel 1", color=adLevel1Color, linestyle=hline.style_dashed, display=enable_ad and adLevel1On ? display.all : display.none)
hline(adLevel2Val, title="A/D Nivel 2", color=adLevel2Color, linestyle=hline.style_dashed, display=enable_ad and adLevel2On ? display.all : display.none)
hline(adLevel3Val, title="A/D Nivel 3", color=adLevel3Color, linestyle=hline.style_dashed, display=enable_ad and adLevel3On ? display.all : display.none)

// --- Alertas ---
alertcondition(enable_ad and ta.crossover(ad, ta.sma(ad, 20)),  title="A/D Cross Above MA20", message="A/D Line crossed above its 20-period average")
alertcondition(enable_ad and ta.crossunder(ad, ta.sma(ad, 20)), title="A/D Cross Below MA20", message="A/D Line crossed below its 20-period average")
````
