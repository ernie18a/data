# Xuong

- url: https://www.tradingview.com/script/QeRE69bq-Xuong/
- type: indicator
- pine_id: PUB;248a40126ec045c6ba62567752999b48
- version: 1.0

## Description

Testing Crossover Signals
- The indicator uses EMA13 and SMA25 to identify buy and sell signals.  EMA89 and EMA200 are included to establish the trend of the stock.

$ means to buy
X means to sell

- The top $ and X indicate when price crosses the SMA25.
The bottom $ and X indicate when EMA13 crosses the SMA25.  The bottom are higher priority signals.

## Source Code

````pine
//@version=6
indicator("Xuong", overlay = true)



// --- User Inputs ---
// Multiplier Logic: 1 Day = 2x 4-hour bars (Standard Session)
ema13Len      = input.int(13, "EMA 13 (1D Equiv) Length")  
sma25Len      = input.int(25, "SMA 25 (1D Equiv) Length") 
ema89Len      = input.int(89, "EMA 89 (1D Equiv) Length") 
ema200Len     = input.int(200, "EMA 25 (1D Equiv) Length")



// --- Technical Calculations ---
// EMA 13, 89 and SMA 25 Calculations 
ema13 = ta.ema(close, ema13Len)
sma25 = ta.sma(close, sma25Len)
ema89 = ta.ema(close, ema89Len)
ema200 = ta.ema(close, ema200Len)

// Global Cross Calculations (Preventing v6 Execution Errors)
// These must be outside of 'if' blocks to maintain historical memory
priceCrossSMA25  = ta.crossover(close, sma25)
ema13CrossSMA25  = ta.crossover(ema13, sma25)
priceUnderSMA25  = ta.crossunder(close, sma25)
ema13UnderSMA25  = ta.crossunder(ema13, sma25)

// Simplified Volume Calculation (on chart or 4h)
// Native v6 approach comparing current volume to a 20-period average
volAvg      = ta.sma(volume, 20)
relVolRatio = volume / volAvg



// --- Visualization ---
// Plot indicators for visual confirmation 
plot(ema13, "EMA 13", color=color.white, style=plot.style_stepline)
plot(sma25, "SMA 25", color=color.orange)
plot(ema89, "EMA 89", color=color.green, style=plot.style_line, linewidth = 1, linestyle = plot.linestyle_dashed)
plot(ema200, "EMA 200", color=color.blue, style=plot.style_line, linewidth = 1, linestyle = plot.linestyle_dashed)

// Technical Trigger Labels
plotchar(ema13CrossSMA25, title="Buy Cross", char="$", location=location.bottom, color=color.rgb(18, 200, 24), size=size.small)
plotchar(ema13UnderSMA25, title="Sell Cross", char="X", location=location.bottom, color=color.red, size=size.small)

plotchar(priceCrossSMA25, title="CrossSMA25", char="$", location=location.top, color=color.rgb(18, 200, 24), size=size.tiny)
plotchar(priceUnderSMA25, title="UnderSMA25", char="X", location=location.top, color=color.yellow, size=size.tiny)




// UI Price Table
//var table entryTable = table.new(position.top_center, 4, 3, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

//if barstate.islast
    // Header Row
//    table.cell(entryTable, 0, 0, "Buy Price", text_color=color.white, text_size=size.small)
//    table.cell(entryTable, 0, 1, "Stop (1h)", text_color=color.white, text_size=size.small)
//    table.cell(entryTable, 2, 0, "EMA13", text_color=color.white, text_size=size.small)
 //   table.cell(entryTable, 2, 1, "SMA25", text_color=color.white, text_size=size.small)
 //   table.cell(entryTable, 0, 2, "Sell Price", text_color=color.white, text_size=size.small)
//    table.cell(entryTable, 2, 2, "EMA200 Slope", text_color=color.white, text_size=size.small)

    // Data Row (Shows 'N/A' if no position is active)
//    string entryTxt = not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "N/A"
//    string stopTxt = not na(currentStopPrice) ? str.tostring(currentStopPrice, format.mintick) : "N/A"
 //   string ema13Txt = not na(ema13) ? str.tostring(ema13, format.mintick) : "N/A"
//    string sma25Txt = not na(sma25) ? str.tostring(sma25, format.mintick) : "N/A"
 //   string exitTxt = not na(exitPrice) ? str.tostring(exitPrice, format.mintick) : "N/A"
 //   string ema200Txt = not na(emaAngle) ? str.tostring(emaAngle, format.mintick) : "N/A"

 //   table.cell(entryTable, 1, 0, entryTxt, text_color=color.aqua, text_size=size.small)
 //   table.cell(entryTable, 1, 1, stopTxt, text_color=color.yellow, text_size=size.small)
 //   table.cell(entryTable, 3, 0, ema13Txt, text_color=color.orange, text_size=size.small)
//    table.cell(entryTable, 3, 1, sma25Txt, text_color=color.white, text_size=size.small)
 //   table.cell(entryTable, 1, 2, exitTxt, text_color=color.red, text_size=size.small)
 //   table.cell(entryTable, 3, 2, ema200Txt, text_color=color.yellow, text_size=size.small)
````
