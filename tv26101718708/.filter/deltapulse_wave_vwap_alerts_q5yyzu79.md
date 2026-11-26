# DeltaPulse Wave + VWAP Alerts

- url: https://www.tradingview.com/script/q5YYzu79-DeltaPulse-Wave-VWAP-Alerts/
- type: indicator
- pine_id: PUB;51cf372b9ce547f0a8301696583b1433
- version: 1.0

## Description

Delta Pulse movement confluence alert.

The Delta Pulse is already an incredible indicator for catching divergence from aggression, especially for markets with real volume like NQ, ES, GC, and WIN. Now, with the alert in the right place, it helps to avoid missing these great opportunities.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime (Modificado com Filtro VWAP)

//@version=6
indicator("DeltaPulse Wave + VWAP Alerts", "DeltaPulse Osc [VWAP]", overlay = false, precision = 2)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

int   waveLen     = input.int(20, "Wave Lookback", minval = 5, tooltip = "Period for calculating the relative delta strength.")
int   smoothLen   = input.int(5, "Smoothing", minval = 1, tooltip = "Smoothing period for the final wave.")
float obThreshold = input.float(25.0, "Upper Threshold (OB)", minval = 1.0, group = "Levels")
float osThreshold = input.float(-25.0, "Lower Threshold (OS)", maxval = -1.0, group = "Levels")
int   minGap      = input.int(5, "Min Divergence Gap", minval = 2, group = "Analysis", tooltip = "Minimum number of bars required between two peaks or troughs to confirm a divergence.")
bool  showLines   = input.bool(true, "Show Divergence Lines", group = "Analysis")

color bullColor  = input.color(#00ffbb, "Aggressive Buying", group = "Style")
color bearColor  = input.color(#ff0055, "Aggressive Selling", group = "Style")
color neutColor  = input.color(#6b7b8f, "Neutral Line", group = "Style")

// Dashboard Settings
bool   showDash     = input.bool(true, "Show Dashboard", group = "Dashboard")
string dashPos      = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = "Dashboard")
string dashSize     = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Dashboard")

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝘾Á𝙇𝘾𝙐𝙇𝙊 𝘿𝘼 𝙑𝙒𝘼𝙋 𝙀 𝘽𝘼𝙉𝘿𝘼𝙎 (1 𝙎𝘿)
// --------------------------------------------------------------------------------------------------------------------{

var float sumSrcVol   = 0.0
var float sumVol      = 0.0
var float sumSrcSqVol = 0.0

// CORREÇÃO: Reseta a VWAP a cada nova sessão (diária). timeframe.change já devolve true/false.
bool isNewDay = timeframe.change("D")

if isNewDay
    sumSrcVol   := 0.0
    sumVol      := 0.0
    sumSrcSqVol := 0.0

float src = hlc3
sumSrcVol   += src * volume
sumVol      += volume
sumSrcSqVol += math.pow(src, 2) * volume

float vwapVal  = sumSrcVol / sumVol
float variance = (sumSrcSqVol / sumVol) - math.pow(vwapVal, 2)
float stdev    = math.sqrt(math.max(0, variance))

float vwapUpper1 = vwapVal + stdev
float vwapLower1 = vwapVal - stdev

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎 (DeltaPulse Original)
// --------------------------------------------------------------------------------------------------------------------{

// 1. Calculate Relative Delta Strength (RDS)
float buyVol      = close > open ? volume : 0.0
float sellVol     = close < open ? volume : 0.0
float smoothedBuy  = ta.ema(buyVol, waveLen)
float smoothedSell = ta.ema(sellVol, waveLen)
float smoothedTot  = ta.ema(volume > 0 ? volume : 1, waveLen)

float rdsRaw    = (smoothedBuy - smoothedSell) / (smoothedTot > 0 ? smoothedTot : 1) * 100
float deltaWave = ta.ema(rdsRaw, smoothLen)

// 2. Divergence Logic (Detection of local peaks)
bool isWaveHigh = deltaWave < deltaWave[1] and deltaWave[1] > deltaWave[2] and deltaWave[1] > (obThreshold * 0.2)
bool isWaveLow  = deltaWave > deltaWave[1] and deltaWave[1] < deltaWave[2] and deltaWave[1] < (osThreshold * 0.2)

// State Tracking for Divergences
var float lastPH     = 0.0
var int   lastPH_Idx = 0
var float lastWH     = 0.0
var int   lastWH_Idx = 0

var float lastPL     = 0.0
var int   lastPL_Idx = 0
var float lastWL     = 0.0
var int   lastWL_Idx = 0

bool bearDiv = false
bool bullDiv = false

// Bearish Divergence (Price HH, Wave LH with Min Gap)
if isWaveHigh
    if high[1] > lastPH and deltaWave[1] < lastWH and (bar_index[1] - lastPH_Idx) >= minGap
        bearDiv := true
        if showLines
            line.new(lastPH_Idx, lastPH, bar_index[1], high[1], xloc.bar_index, extend.none, bearColor, line.style_solid, 2, force_overlay = true)
            line.new(lastWH_Idx, lastWH, bar_index[1], deltaWave[1], xloc.bar_index, extend.none, bearColor, line.style_solid, 2)
    
    // Update anchors only if current peak is significant or enough gap has passed
    lastPH := high[1]
    lastPH_Idx := bar_index[1]
    lastWH := deltaWave[1]
    lastWH_Idx := bar_index[1]

// Bullish Divergence (Price LL, Wave HL with Min Gap)
if isWaveLow
    if low[1] < lastPL and deltaWave[1] > lastWL and (bar_index[1] - lastPL_Idx) >= minGap
        bullDiv := true
        if showLines
            line.new(lastPL_Idx, lastPL, bar_index[1], low[1], xloc.bar_index, extend.none, bullColor, line.style_solid, 2, force_overlay = true)
            line.new(lastWL_Idx, lastWL, bar_index[1], deltaWave[1], xloc.bar_index, extend.none, bullColor, line.style_solid, 2)

    lastPL := low[1]
    lastPL_Idx := bar_index[1]
    lastWL := deltaWave[1]
    lastWL_Idx := bar_index[1]

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙉𝙊𝙑𝘼𝙎 𝙍𝙀𝙂𝙍𝘼𝙎 𝘿𝙀 𝙎𝙄𝙉𝘼𝙇 (VWAP BANDS)
// --------------------------------------------------------------------------------------------------------------------{

// Compra: Divergência Bull, Fechamento abaixo da Banda Superior (1 SD) e acima da VWAP.
bool finalBuySignal = bullDiv and (close < vwapUpper1) and (close > vwapVal)

// Venda: Divergência Bear, Fechamento acima da Banda Inferior (1 SD) e abaixo da VWAP.
bool finalSellSignal = bearDiv and (close > vwapLower1) and (close < vwapVal)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝘼𝙇𝙀𝙍𝙏𝘼𝙎 (PUSH, SOM, POP-UP)
// --------------------------------------------------------------------------------------------------------------------{

alertcondition(finalBuySignal,  title="🟢 Compra: DeltaPulse + VWAP", message="Sinal de COMPRA: Divergência detectada, preço fechou acima da VWAP e abaixo da banda superior de 1 SD.")
alertcondition(finalSellSignal, title="🔴 Venda: DeltaPulse + VWAP",  message="Sinal de VENDA: Divergência detectada, preço fechou abaixo da VWAP e acima da banda inferior de 1 SD.")

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{

// Zero Line & Thresholds
plot(0, "Baseline", color = color.new(neutColor, 50), style = plot.style_linebr)
plot(obThreshold, "OB Level", color = color.new(neutColor, 80), style = plot.style_linebr)
plot(osThreshold, "OS Level", color = color.new(neutColor, 80), style = plot.style_linebr)

// Main Wave
color waveColor = deltaWave > 0 ? bullColor : bearColor
wavePlot  = plot(deltaWave, "DeltaPulse Wave", color = waveColor, linewidth = 2)

// Centered Fill
fill(wavePlot, plot(0, display = display.none, editable = false),
     top_value    = deltaWave > 0 ? deltaWave : 0,
     bottom_value = deltaWave < 0 ? deltaWave : 0,
     top_color    = deltaWave > 0 ? color.new(bullColor, 40) : color.new(bullColor, 100),
     bottom_color = deltaWave < 0 ? color.new(bearColor, 40) : color.new(bearColor, 100))

// SINAIS ORIGINAIS (Circulos discretos no oscilador e chart)
plotshape(bullDiv, "Bull Div Circle", shape.circle, location.bottom, bullColor, size = size.tiny, offset = -1)
plotshape(bearDiv, "Bear Div Circle", shape.circle, location.top, bearColor, size = size.tiny, offset = -1)

// NOVOS SINAIS VALIDADOS PELA VWAP (No gráfico principal)
plotshape(finalBuySignal,  "Sinal Compra VWAP", shape.triangleup,   location.belowbar, bullColor, text = "C", textcolor = bullColor, force_overlay = true, size = size.normal, offset = -1)
plotshape(finalSellSignal, "Sinal Venda VWAP",  shape.triangledown, location.abovebar, bearColor, text = "V", textcolor = bearColor, force_overlay = true, size = size.normal, offset = -1)

barcolor(waveColor)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝘿𝘼𝙎𝙃𝘽𝙊𝘼𝙍𝘿
// --------------------------------------------------------------------------------------------------------------------{

var table dashTable = na
// Last Divergence
var string lastDivType = "None"
var color lastDivCol = chart.fg_color
if finalBuySignal
    lastDivType := "Bull (VWAP)"
    lastDivCol := bullColor
else if bullDiv
    lastDivType := "Bullish"
    lastDivCol := bullColor

if finalSellSignal
    lastDivType := "Bear (VWAP)"
    lastDivCol := bearColor
else if bearDiv
    lastDivType := "Bearish"
    lastDivCol := bearColor

if showDash and barstate.islast
    string pos = switch dashPos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

    string tSize = switch dashSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

    dashTable := table.new(pos, 2, 4, color.new(chart.bg_color, 10), chart.fg_color, 1, chart.fg_color, 1)
    
    // Header
    table.cell(dashTable, 0, 0, "DeltaPulse", text_color = chart.fg_color, text_size = tSize, bgcolor = color.new(neutColor, 80))
    table.cell(dashTable, 1, 0, "Value",     text_color = chart.fg_color, text_size = tSize, bgcolor = color.new(neutColor, 80))
    
    // Wave Value
    table.cell(dashTable, 0, 1, "Wave",      text_color = chart.fg_color, text_halign = text.align_left, text_size = tSize)
    table.cell(dashTable, 1, 1, str.format("{0,number,#.##}", deltaWave), text_color = waveColor, text_size = tSize)
    
    // Trend
    table.cell(dashTable, 0, 2, "Trend",     text_color = chart.fg_color, text_halign = text.align_left, text_size = tSize)
    table.cell(dashTable, 1, 2, deltaWave > 0 ? "Bullish" : "Bearish", text_color = waveColor, text_size = tSize)
 
    table.cell(dashTable, 0, 3, "Last Div",  text_color = chart.fg_color, text_halign = text.align_left, text_size = tSize)
    table.cell(dashTable, 1, 3, lastDivType, text_color = lastDivCol, text_size = tSize)
````
