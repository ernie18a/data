# 2min Bullish Confluence

- url: https://www.tradingview.com/script/w0SzWuUB-2min-Bullish-Confluence/
- type: indicator
- pine_id: PUB;5eaf4df837d7405ab3fede664b1375de
- version: 1.0

## Description

Turn green when RSI > 55 on 5,15,30min and MACD >0
Turns pink when RSI climbs > 60 on 5, 15, 30 and MACD >0

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quant

//@version=6
indicator("MTF Bullish Confluence", overlay = true)

// --- Inputs ---
grp_tf = "Timeframes"
tf1Input = input.timeframe("5",  "Timeframe 1", group = grp_tf)
tf2Input = input.timeframe("15", "Timeframe 2", group = grp_tf)
tf3Input = input.timeframe("30", "Timeframe 3", group = grp_tf)

grp_cond = "Conditions"
rsiLenInput     = input.int(14, "RSI Length", group = grp_cond)
macdFastInput   = input.int(12, "MACD Fast Length", group = grp_cond)
macdSlowInput   = input.int(26, "MACD Slow Length", group = grp_cond)
macdSignalInput = input.int(9,  "MACD Signal Length", group = grp_cond)

// --- Core Logic ---
// Function to evaluate bullish conditions and return the MACD status and RSI value
getConditions() =>
    rsiVal = ta.rsi(close, rsiLenInput)
    [macdLine, signalLine, histLine] = ta.macd(close, macdFastInput, macdSlowInput, macdSignalInput)
    bullishMacd = macdLine > 0
    [bullishMacd, rsiVal]

// Fetch conditions and RSI values from higher timeframes
[tf1MacdBull, tf1Rsi] = request.security(syminfo.tickerid, tf1Input, getConditions(), gaps = barmerge.gaps_off)
[tf2MacdBull, tf2Rsi] = request.security(syminfo.tickerid, tf2Input, getConditions(), gaps = barmerge.gaps_off)
[tf3MacdBull, tf3Rsi] = request.security(syminfo.tickerid, tf3Input, getConditions(), gaps = barmerge.gaps_off)

// Determine confluence trigger
// Trigger requires MACD > 0 on all three timeframes AND the 5m RSI to be over 55
confluenceTrigger = tf1MacdBull and tf2MacdBull and tf3MacdBull and (tf1Rsi > 55)

// --- Color Logic ---
// Determine the intensity of the green based on 15m and 30m RSI crossing 55
greenTransparency = 85 // Base low-intensity green when only 5m RSI > 55
if tf2Rsi > 55
    greenTransparency := 70 // Medium intensity when 15m RSI also > 55
if tf2Rsi > 55 and tf3Rsi > 55
    greenTransparency := 45 // High intensity when all three RSIs > 55

colorGreen = color.new(#089981, greenTransparency)
colorPink  = color.new(color.fuchsia, 50)

// Calculate average RSI to determine the pink gradient
avgRsi = (tf1Rsi + tf2Rsi + tf3Rsi) / 3

// If average RSI is > 60, start blending from the current green intensity into the pink
gradColor = avgRsi > 60 ? color.from_gradient(avgRsi, 60, 95, colorGreen, colorPink) : colorGreen

// --- Visual Elements ---
// Restrict visuals and alerts to only the 2-minute timeframe
is2MinChart = timeframe.period == "2"

// Highlight background when confluence is active and we are on the 2m chart
bgcolor((confluenceTrigger and is2MinChart) ? gradColor : na, title="Bullish Confluence BG")

// Plot a shape when confluence first begins
confluenceStart = confluenceTrigger and not confluenceTrigger[1]
plotshape(confluenceStart and is2MinChart, title="Confluence Signal", style=shape.triangleup, location=location.belowbar, color=color.new(#089981, 0), size=size.small)

// --- Alerts ---
if confluenceStart and is2MinChart
    alert("Bullish Confluence triggered: 5m RSI > 55 and MACDs are bullish!", alert.freq_once_per_bar_close)
````
