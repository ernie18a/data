# AMD Box Entry Pro - Clean

- url: https://www.tradingview.com/script/pLJoQC0Y-AMD-Box-Entry-Pro-Clean/
- type: indicator
- pine_id: PUB;ed7f813e3c9d43848d0010e00d405ae0
- version: 1.0

## Description

A clean FVG-based visual tool that detects bullish and bearish imbalances, draws entry zones, SL/TP boxes and projects Risk/Reward targets directly on the chart.

## Source Code

````pine
//@version=6
indicator("AMD Box Entry Pro - Clean", overlay=true, max_boxes_count=100, max_lines_count=100)

//==================================================
// SETĂRI
//==================================================
rr              = input.float(3.0, "Risk Reward", step=0.5)
boxWidth        = input.int(12, "FVG Box Width")
extendBars      = input.int(20, "Extend Trade Box")
minGapPercent   = input.float(0.05, "Min Gap Percent (%)", step=0.01)

showFVG         = input.bool(true, "Show FVG")
showEntryBox    = input.bool(true, "Show Entry Box")

bullColor       = input.color(color.green, "Bullish FVG Color")
bearColor       = input.color(color.red, "Bearish FVG Color")

//==================================================
// VARIABILE PENTRU A LIMITA SEMNALELE
//==================================================
var int lastSignalBar = -100

//==================================================
// FUNCȚIE VERIFICARE GAP SEMNIFICATIV
//==================================================
isSignificantGap(gapSize, priceLevel) =>
    (gapSize / priceLevel) * 100 >= minGapPercent

//==================================================
// FVG (Fair Value Gap)
//==================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

// Filtrare gap semnificativ
bullFVGSignificant = bullFVG and isSignificantGap(low - high[2], high[2])
bearFVGSignificant = bearFVG and isSignificantGap(low[2] - high, high)

//==================================================
// DESENEAZĂ FVG (DOAR CELE RECENTE)
//==================================================
if showFVG and bullFVGSignificant and bar_index - lastSignalBar > 10
    box.new(
         left = bar_index-2,
         right = bar_index + boxWidth,
         top = low,
         bottom = high[2],
         bgcolor = color.new(bullColor, 85),
         border_color = bullColor)

if showFVG and bearFVGSignificant and bar_index - lastSignalBar > 10
    box.new(
         left = bar_index-2,
         right = bar_index + boxWidth,
         top = low[2],
         bottom = high,
         bgcolor = color.new(bearColor, 85),
         border_color = bearColor)

//==================================================
// SEMNAL DE INTRARE (DOAR CEL MAI RECENT)
//==================================================
buySignal  = bullFVGSignificant and close > open
sellSignal = bearFVGSignificant and close < open

// Previne semnale multiple în aceeași zonă
validBuySignal  = buySignal and bar_index - lastSignalBar > 10
validSellSignal = sellSignal and bar_index - lastSignalBar > 10

//==================================================
// DESENEAZĂ ENTRY/SL/TP (DOAR LA SEMNAL VALID)
//==================================================
if showEntryBox and validBuySignal
    lastSignalBar := bar_index
    
    entry = (low + high[2]) / 2
    sl = low[2]
    risk = math.abs(entry - sl)
    tp = entry + (risk * rr)

    // ENTRY ZONE (ALBASTRU)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = entry + (risk * 0.15),
         bottom = entry - (risk * 0.15),
         bgcolor = color.new(color.blue, 70),
         border_color = color.blue)

    // TP BOX (VERDE)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = tp,
         bottom = entry,
         bgcolor = color.new(color.green, 80),
         border_color = color.green)

    // SL BOX (ROSU)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = entry,
         bottom = sl,
         bgcolor = color.new(color.red, 80),
         border_color = color.red)

    // ENTRY LINE (MOV PUNCTAT)
    line.new(
         x1 = bar_index,
         y1 = entry,
         x2 = bar_index + extendBars,
         y2 = entry,
         color = color.purple,
         style = line.style_dashed)

if showEntryBox and validSellSignal
    lastSignalBar := bar_index
    
    entry = (high + low[2]) / 2
    sl = high[2]
    risk = math.abs(sl - entry)
    tp = entry - (risk * rr)

    // ENTRY ZONE (PORTOCALIU)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = entry + (risk * 0.15),
         bottom = entry - (risk * 0.15),
         bgcolor = color.new(color.orange, 70),
         border_color = color.orange)

    // SL BOX (ROSU)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = sl,
         bottom = entry,
         bgcolor = color.new(color.red, 80),
         border_color = color.red)

    // TP BOX (VERDE)
    box.new(
         left = bar_index,
         right = bar_index + extendBars,
         top = entry,
         bottom = tp,
         bgcolor = color.new(color.green, 80),
         border_color = color.green)

    // ENTRY LINE (MOV PUNCTAT)
    line.new(
         x1 = bar_index,
         y1 = entry,
         x2 = bar_index + extendBars,
         y2 = entry,
         color = color.purple,
         style = line.style_dashed)
````
