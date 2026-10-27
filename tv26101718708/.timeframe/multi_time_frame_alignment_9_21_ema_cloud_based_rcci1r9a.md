# Multi Time Frame Alignment ( 9 / 21 EMA cloud based )

- url: https://www.tradingview.com/script/rCCI1r9A-Multi-Time-Frame-Alignment-9-21-EMA-cloud-based/
- type: indicator
- pine_id: PUB;4a55d148049c4b97bfa947245fbb3b0e
- version: 2.0

## Description

This indicator is a complete, multi-timeframe trend alignment tool built around the classic 9 and 21 Exponential Moving Averages (EMA). It is designed to keep your charts clean while providing instant, at-a-glance confirmation of market structure across macro and micro timeframes.

Perfect for day traders and swing traders who require strict higher-timeframe confluence before executing a setup.

Key Features:

Multi-Timeframe Dashboard: A fully customizable on-screen table that tracks the 9/21 EMA trend across the Weekly, Daily, 4H, 1H, 15m, and 5m timeframes.

Fractal Alignment Warnings: The dashboard automatically calculates two distinct alignment modules:

Swing/Macro Alignment: Weekly / 4H / 15m

Intraday Alignment: Daily / 1H / 5m

"NO TRADE ZONE" Alerts: If your selected timeframes are not completely in sync (e.g., the 1H is bullish but the 5m is bearish), the alignment row will distinctly flag a "NO TRADE ZONE" to help prevent entering during choppy or corrective price action.

Toggleable Chart Cloud: Visually plots the 9/21 EMA lines and fills the cloud between them directly on your current chart. This can be easily toggled off in the settings if you prefer naked price action.

Integrated Session VWAP: Includes a built-in, toggleable VWAP line with customizable thickness for intraday liquidity and mean-reversion references.

Highly Customizable UI: Every visual element can be adjusted. You can change the table position, text size, and independently adjust the colors and transparencies of the table clouds versus the chart clouds.

## Source Code

````pine
//@version=6
indicator("9/21 EMA Cloud Dashboard", overlay=true)

// --- EMA Inputs ---
emaFastLen = input.int(9, title="Fast EMA", group="EMA Settings")
emaSlowLen = input.int(21, title="Slow EMA", group="EMA Settings")

// --- Table Cloud Colors ---
tableBullColor = input.color(color.new(#26a69a, 70), title="Table Bullish Color", group="Table Cloud Colors")
tableBearColor = input.color(color.new(#ef5350, 70), title="Table Bearish Color", group="Table Cloud Colors")
neutralColor   = input.color(color.new(color.yellow, 50), title="No Trade Zone Bg Color", group="Table Cloud Colors")

// --- Chart Cloud Settings ---
showChartCloud = input.bool(true, title="Show EMA Cloud on Chart", group="Chart Cloud Settings")
chartBullColor = input.color(color.new(#26a69a, 80), title="Chart Bullish Cloud Color", group="Chart Cloud Settings")
chartBearColor = input.color(color.new(#ef5350, 80), title="Chart Bearish Cloud Color", group="Chart Cloud Settings")

// --- VWAP Settings ---
showVwap  = input.bool(true, title="Show VWAP", group="VWAP Settings")
vwapStyle = input.string("Solid", title="VWAP Line Style", options=["Solid", "Circles (Dotted)", "Crosses"], group="VWAP Settings")
vwapColor = input.color(color.orange, title="VWAP Line Color", group="VWAP Settings")
vwapWidth = input.int(2, title="VWAP Line Thickness", minval=1, maxval=4, group="VWAP Settings")

// --- Table Settings ---
tablePosStr  = input.string("Top Right", title="Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right", "Middle Left", "Top Center", "Bottom Center"], group="Table Settings")
textSizeStr  = input.string("Normal", title="Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group="Table Settings")

// Standard text colors for the headers and timeframe names
textColor    = input.color(color.white, title="Standard Text Color", group="Table Settings")

// Dynamic text colors for the trend/alignment cells
bullTextColor = input.color(color.white, title="Bullish Text Color", group="Table Settings")
bearTextColor = input.color(color.white, title="Bearish Text Color", group="Table Settings")
neutralTextColor = input.color(color.black, title="No Trade Zone Text Color", group="Table Settings")

headerBg     = input.color(color.new(color.gray, 80), title="Header Background", group="Table Settings")
tableBg      = input.color(color.new(color.black, 80), title="Table Background", group="Table Settings")
tableBorder  = input.color(color.new(color.gray, 50), title="Border Color", group="Table Settings")

// --- Position and Size Mapping ---
var string tPos = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Bottom Right" ? position.bottom_right : tablePosStr == "Top Left" ? position.top_left : tablePosStr == "Bottom Left" ? position.bottom_left : tablePosStr == "Middle Right" ? position.middle_right : tablePosStr == "Middle Left" ? position.middle_left : tablePosStr == "Top Center" ? position.top_center : position.bottom_center

var string tSize = textSizeStr == "Auto" ? size.auto : textSizeStr == "Tiny" ? size.tiny : textSizeStr == "Small" ? size.small : textSizeStr == "Normal" ? size.normal : textSizeStr == "Large" ? size.large : size.huge

// --- Fetch EMA Values from HTFs ---
fastEma = ta.ema(close, emaFastLen)
slowEma = ta.ema(close, emaSlowLen)

[fW, sW]     = request.security(syminfo.tickerid, "W", [fastEma, slowEma])
[fD, sD]     = request.security(syminfo.tickerid, "D", [fastEma, slowEma])
[f4H, s4H]   = request.security(syminfo.tickerid, "240", [fastEma, slowEma])
[f1H, s1H]   = request.security(syminfo.tickerid, "60", [fastEma, slowEma])
[f15m, s15m] = request.security(syminfo.tickerid, "15", [fastEma, slowEma])
[f5m, s5m]   = request.security(syminfo.tickerid, "5", [fastEma, slowEma])

// --- Determine Trends ---
trendW   = fW > sW ? 1 : fW < sW ? -1 : 0
trendD   = fD > sD ? 1 : fD < sD ? -1 : 0
trend4H  = f4H > s4H ? 1 : f4H < s4H ? -1 : 0
trend1H  = f1H > s1H ? 1 : f1H < s1H ? -1 : 0
trend15m = f15m > s15m ? 1 : f15m < s15m ? -1 : 0
trend5m  = f5m > s5m ? 1 : f5m < s5m ? -1 : 0

// --- Alignment Logic ---
alignA = (trendW == 1 and trend4H == 1 and trend15m == 1) ? 1 : (trendW == -1 and trend4H == -1 and trend15m == -1) ? -1 : 0
alignB = (trendD == 1 and trend1H == 1 and trend5m == 1) ? 1 : (trendD == -1 and trend1H == -1 and trend5m == -1) ? -1 : 0

// --- Color Logic for Table Backgrounds ---
colorW   = trendW == 1 ? tableBullColor : tableBearColor
colorD   = trendD == 1 ? tableBullColor : tableBearColor
color4H  = trend4H == 1 ? tableBullColor : tableBearColor
color1H  = trend1H == 1 ? tableBullColor : tableBearColor
color15m = trend15m == 1 ? tableBullColor : tableBearColor
color5m  = trend5m == 1 ? tableBullColor : tableBearColor

colorAlignA = alignA == 1 ? tableBullColor : alignA == -1 ? tableBearColor : neutralColor
colorAlignB = alignB == 1 ? tableBullColor : alignB == -1 ? tableBearColor : neutralColor

// --- Text Logic for Alignments ---
textAlignA = alignA == 1 ? "Bullish" : alignA == -1 ? "Bearish" : "NO TRADE ZONE"
textAlignB = alignB == 1 ? "Bullish" : alignB == -1 ? "Bearish" : "NO TRADE ZONE"

// --- Text Color Logic for Cells ---
textW = trendW == 1 ? bullTextColor : bearTextColor
textD = trendD == 1 ? bullTextColor : bearTextColor
text4H = trend4H == 1 ? bullTextColor : bearTextColor
text1H = trend1H == 1 ? bullTextColor : bearTextColor
text15m = trend15m == 1 ? bullTextColor : bearTextColor
text5m = trend5m == 1 ? bullTextColor : bearTextColor

textColAlignA = alignA == 1 ? bullTextColor : alignA == -1 ? bearTextColor : neutralTextColor
textColAlignB = alignB == 1 ? bullTextColor : alignB == -1 ? bearTextColor : neutralTextColor

// --- VWAP Plotting ---
vwapValue = ta.vwap

// Plotting is split because Pine Script requires 'style' to be a constant
plot(showVwap and vwapStyle == "Solid" ? vwapValue : na, title="VWAP Solid", color=vwapColor, linewidth=vwapWidth, style=plot.style_line)
plot(showVwap and vwapStyle == "Circles (Dotted)" ? vwapValue : na, title="VWAP Dotted", color=vwapColor, linewidth=vwapWidth, style=plot.style_circles)
plot(showVwap and vwapStyle == "Crosses" ? vwapValue : na, title="VWAP Crosses", color=vwapColor, linewidth=vwapWidth, style=plot.style_cross)


// --- Current Timeframe Chart Cloud Plotting ---
pFast = plot(showChartCloud ? fastEma : na, title="Fast EMA Line", color=color.new(color.gray, 50))
pSlow = plot(showChartCloud ? slowEma : na, title="Slow EMA Line", color=color.new(color.gray, 50))
chartCloudFillColor = fastEma > slowEma ? chartBullColor : chartBearColor
fill(pFast, pSlow, color=showChartCloud ? chartCloudFillColor : na, title="EMA Chart Cloud Fill")

// --- Table Setup ---
var table emaTable = table.new(tPos, 2, 9, bgcolor=tableBg, border_width=1, border_color=tableBorder)

// --- Populate Table on the Last Bar ---
if barstate.islast
    table.cell(emaTable, 0, 0, "Timeframe", text_color=textColor, text_halign=text.align_center, bgcolor=headerBg, text_size=tSize)
    table.cell(emaTable, 1, 0, "9/21 Cloud", text_color=textColor, text_halign=text.align_center, bgcolor=headerBg, text_size=tSize)

    table.cell(emaTable, 0, 1, "Weekly", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 1, trendW == 1 ? "Bullish" : "Bearish", bgcolor=colorW, text_color=textW, text_size=tSize)

    table.cell(emaTable, 0, 2, "Daily", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 2, trendD == 1 ? "Bullish" : "Bearish", bgcolor=colorD, text_color=textD, text_size=tSize)

    table.cell(emaTable, 0, 3, "4H", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 3, trend4H == 1 ? "Bullish" : "Bearish", bgcolor=color4H, text_color=text4H, text_size=tSize)

    table.cell(emaTable, 0, 4, "1H", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 4, trend1H == 1 ? "Bullish" : "Bearish", bgcolor=color1H, text_color=text1H, text_size=tSize)

    table.cell(emaTable, 0, 5, "15m", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 5, trend15m == 1 ? "Bullish" : "Bearish", bgcolor=color15m, text_color=text15m, text_size=tSize)

    table.cell(emaTable, 0, 6, "5m", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 6, trend5m == 1 ? "Bullish" : "Bearish", bgcolor=color5m, text_color=text5m, text_size=tSize)

    table.cell(emaTable, 0, 7, "W/4H/15m Align", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 7, textAlignA, bgcolor=colorAlignA, text_color=textColAlignA, text_size=tSize)

    table.cell(emaTable, 0, 8, "D/1H/5m Align", text_color=textColor, text_halign=text.align_left, text_size=tSize)
    table.cell(emaTable, 1, 8, textAlignB, bgcolor=colorAlignB, text_color=textColAlignB, text_size=tSize)
````
