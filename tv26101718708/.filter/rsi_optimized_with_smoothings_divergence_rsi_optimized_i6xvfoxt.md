# RSI Optimized with Smoothings & Divergence (RSI Optimized)

- url: https://www.tradingview.com/script/i6XvFOXt/
- type: indicator
- pine_id: PUB;e79ffcebc8384cb186a495b704ef3adf
- version: 1.0

## Description

This indicator enhances the classic RSI by adding multiple smoothing layers, a dynamic background based on the average of six smoothings, an info table, and regular divergence detection.

🔹 **Core RSI**
Standard RSI calculation (Wilder) with fully adjustable length and source. Overbought/oversold levels (70/30) are highlighted with a gradient fill.

🔹 **Smoothing MA**
Optionally apply a moving average to the RSI line (SMA, EMA, SMMA, WMA, VWMA). The "SMA + Bollinger Bands" mode adds Bollinger Bands around the smoothed RSI.

🔹 **Six Smoothings (instead of a ribbon)**
Six independent moving averages of the RSI (customizable type and lengths) are plotted. Useful to visualise multiple timeframes or sensitivities at once.

🔹 **Background color (RSI vs Avg of 6 Smoothings)**
Compares the RSI value to the simple average of the six smoothings. Green background when RSI > average (bullish bias), red when RSI < average (bearish bias).

🔹 **Info Table**
Displays in real time:
- Current RSI value (color‑coded by overbought/oversold)
- Average of the six smoothings
- Ratio = (RSI + Avg)/2
- Trend direction (based on RSI vs average)
- Zone (Oversold / Overbought / Bull / Bear / Neutral)
- Smooth trend (fast smoothing 1 vs upper smoothing 6)

🔹 **Regular Divergences**
Detects regular bullish and bearish divergences between price and RSI. Pivot lookback is fixed to 5 bars left/right. An alert is available for each divergence type.

🔹 **All options are configurable via the Settings tab** – from lengths, colors, smoothing types to enabling/disabling the table or divergences.

📌 **How to use**
- Use the six smoothings to identify trend alignment (e.g., all above 50 = strong uptrend).
- The background turns green when RSI stays above the average of all smoothings.
- Watch for divergence signals (labelled "Bull" / "Bear") for potential reversals.
- The info table gives a quick snapshot of momentum and trend state.

This tool is ideal for traders who want a richer RSI experience without cluttering the chart.

NOTE PERSO :THANK TRADING VIEW FOR YOU WORKS , YOU ARE BEST !!! & ENJOY TEAM TRADING VIEW MAKE PEACE NOT WARS !!! STAY TUNED !!

## Source Code

````pine
//@version=6
indicator(title="RSI Optimized", shorttitle="RSI Optimized ", format=format.price, precision=2)

// ─── RSI Settings ───────────────────────────────────────────────────────────
rsiLengthInput      = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput      = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display=display.none, tooltip="Calculating divergences is needed in order for divergence alerts to fire.")

change = ta.change(rsiSourceInput)
up     = ta.rma(math.max(change, 0), rsiLengthInput)
down   = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi    = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// ─── RSI Plots ───────────────────────────────────────────────────────────────
rsiPlot      = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline      = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot  = plot(50, color=na, editable=false, display=display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color=color.new(color.green, 0),  bottom_color=color.new(color.green, 100), title="Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30,  0,  top_color=color.new(color.red, 100),  bottom_color=color.new(color.red, 0),     title="Oversold Gradient Fill")

// ─── Smoothing MA (original) ─────────────────────────────────────────────────
GRP           = "Smoothing"
TT_BB         = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput   = input.string("SMA", "Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group=GRP, display=display.none)
var isBB      = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group=GRP, display=display.none, active=maTypeInput != "None")
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, tooltip=TT_BB, group=GRP, display=display.none, active=isBB)
var enableMA  = maTypeInput != "None"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA    = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na

plot(smoothingMA, "RSI-based MA", color=color.yellow, display=enableMA ? display.all : display.none, editable=enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title="Upper Bollinger Band", color=color.green, display=isBB ? display.all : display.none, editable=isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title="Lower Bollinger Band", color=color.green, display=isBB ? display.all : display.none, editable=isBB)
fill(bbUpperBand, bbLowerBand, color=isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display=isBB ? display.all : display.none, editable=isBB)

// ─── Six Smoothings (instead of Ribbon) ──────────────────────────────────────
GRP_SMOOTH6   = "Six Smoothings (instead of Ribbon)"
showSmooth6   = input.bool(true, "Show Six Smoothings", group=GRP_SMOOTH6)
smoothType    = input.string("EMA", "Smoothing Type", options=["SMA","EMA","SMMA (RMA)","WMA","VWMA"], group=GRP_SMOOTH6)
smoothLen1    = input.int(1,  "Length 1 (Fast 1)",  minval=1, group=GRP_SMOOTH6)
smoothLen2    = input.int(16, "Length 2 (Fast 2)",  minval=1, group=GRP_SMOOTH6)
smoothLen3    = input.int(19,  "Length 3 (Fast 3)",  minval=1, group=GRP_SMOOTH6)
smoothLen4    = input.int(38, "Length 4 (Lower)",   minval=1, group=GRP_SMOOTH6)
smoothLen5    = input.int(50, "Length 5 (Medium)",  minval=1, group=GRP_SMOOTH6)
smoothLen6    = input.int(76, "Length 6 (Upper)",   minval=1, group=GRP_SMOOTH6)
colSmooth1    = input.color(color.new(#00BCD4, 0), "Color Smoothing 1", group=GRP_SMOOTH6)
colSmooth2    = input.color(color.new(#FF9800, 0), "Color Smoothing 2", group=GRP_SMOOTH6)
colSmooth3    = input.color(color.new(#E91E63, 0), "Color Smoothing 3", group=GRP_SMOOTH6)
colSmooth4    = input.color(color.new(#F44336, 0), "Color Smoothing 4", group=GRP_SMOOTH6)
colSmooth5    = input.color(color.new(#4CAF50, 0), "Color Smoothing 5", group=GRP_SMOOTH6)
colSmooth6    = input.color(color.new(#9C27B0, 0), "Color Smoothing 6", group=GRP_SMOOTH6)

maSmooth(src, len, type) =>
    switch type
        "SMA"        => ta.sma(src, len)
        "EMA"        => ta.ema(src, len)
        "SMMA (RMA)" => ta.rma(src, len)
        "WMA"        => ta.wma(src, len)
        "VWMA"       => ta.vwma(src, len)
        => ta.ema(src, len)

smooth1 = showSmooth6 ? maSmooth(rsi, smoothLen1, smoothType) : na
smooth2 = showSmooth6 ? maSmooth(rsi, smoothLen2, smoothType) : na
smooth3 = showSmooth6 ? maSmooth(rsi, smoothLen3, smoothType) : na
smooth4 = showSmooth6 ? maSmooth(rsi, smoothLen4, smoothType) : na
smooth5 = showSmooth6 ? maSmooth(rsi, smoothLen5, smoothType) : na
smooth6 = showSmooth6 ? maSmooth(rsi, smoothLen6, smoothType) : na

plot(smooth1, "Smoothing 1 (Fast 1)", color=colSmooth1, linewidth=1, display=showSmooth6 ? display.all : display.none)
plot(smooth2, "Smoothing 2 (Fast 2)", color=colSmooth2, linewidth=1, display=showSmooth6 ? display.all : display.none)
plot(smooth3, "Smoothing 3 (Fast 3)", color=colSmooth3, linewidth=1, display=showSmooth6 ? display.all : display.none)
plot(smooth4, "Smoothing 4 (Lower)",  color=colSmooth4, linewidth=1, display=showSmooth6 ? display.all : display.none)
plot(smooth5, "Smoothing 5 (Medium)", color=colSmooth5, linewidth=1, display=showSmooth6 ? display.all : display.none)
plot(smooth6, "Smoothing 6 (Upper)",  color=colSmooth6, linewidth=1, display=showSmooth6 ? display.all : display.none)

// ─── Bullish / Bearish Background basé sur la MOYENNE des 6 lissages ──────────
GRP_BG        = "Background Color (RSI vs Avg of 6 Smoothings)"
showBgColor   = input.bool(true, "Show Background Color", group=GRP_BG)
bullBgColor   = input.color(color.new(color.green, 85), "Bullish Color (RSI > Avg)", group=GRP_BG)
bearBgColor   = input.color(color.new(color.red,   85), "Bearish Color (RSI < Avg)", group=GRP_BG)

useSmoothBg = showSmooth6 and not na(smooth1) and not na(smooth2) and not na(smooth3) and not na(smooth4) and not na(smooth5) and not na(smooth6)
avgSmooth   = (smooth1 + smooth2 + smooth3 + smooth4 + smooth5 + smooth6) / 6
isBullishBg = useSmoothBg and rsi > avgSmooth
isBearishBg = useSmoothBg and rsi < avgSmooth

bgcolor(showBgColor and isBullishBg ? bullBgColor : na, title="Bullish Background (RSI > Avg Smoothing)")
bgcolor(showBgColor and isBearishBg ? bearBgColor : na, title="Bearish Background (RSI < Avg Smoothing)")

// ─── Info Table ───────────────────────────────────────────────────────────────
GRP_TBL       = "Info Table"
showTable     = input.bool(true, "Show Table", group=GRP_TBL)
tableLocInput = input.string("TOP RIGHT", "Location", options=["TOP LEFT","TOP RIGHT","BOTTOM LEFT","BOTTOM RIGHT"], group=GRP_TBL)
tableSzInput  = input.string("NORMAL", "Size", options=["TINY","SMALL","NORMAL","LARGE","HUGE"], group=GRP_TBL)

tablePos(loc) =>
    switch loc
        "TOP LEFT"     => position.top_left
        "TOP RIGHT"    => position.top_right
        "BOTTOM LEFT"  => position.bottom_left
        "BOTTOM RIGHT" => position.bottom_right
        => position.top_right

tableSize(sz) =>
    switch sz
        "TINY"   => size.tiny
        "SMALL"  => size.small
        "NORMAL" => size.normal
        "LARGE"  => size.large
        "HUGE"   => size.huge
        => size.normal

// Déclaration des variables pour la zone (correction erreur undeclared)
var string zoneLbl = ""
var color zoneCol = color.gray

var table infoTable = na

if showTable
    if na(infoTable)
        infoTable := table.new(tablePos(tableLocInput), 2, 7, bgcolor=color.new(color.black, 20), border_color=color.new(color.gray, 40), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

    rsiColor = rsi >= 70 ? color.red : rsi <= 30 ? color.green : color.white
    trendLbl = isBullishBg ? "▲ Bull (RSI > Avg)" : isBearishBg ? "▼ Bear (RSI < Avg)" : "— Neutral"
    trendCol = isBullishBg ? color.new(color.green, 20) : isBearishBg ? color.new(color.red, 20) : color.gray
    
    // Zone: priorité aux extrêmes avec couleurs inversées (Oversold rouge, Overbought vert)
    if rsi < 30
        zoneLbl := "Oversold"
        zoneCol := color.red
    else if rsi > 70
        zoneLbl := "Overbought"
        zoneCol := color.green
    else if rsi < 49
        zoneLbl := "Bear"
        zoneCol := color.red
    else if rsi > 51
        zoneLbl := "Bull"
        zoneCol := color.green
    else
        zoneLbl := "Neutral"
        zoneCol := color.gray

    smoothTrend = not na(smooth1) and not na(smooth6) ? (smooth1 > smooth6 ? "▲ Bull (F1>U)" : smooth1 < smooth6 ? "▼ Bear (F1<U)" : "— Neutral") : "OFF"
    smoothCol   = not na(smooth1) and not na(smooth6) ? (smooth1 > smooth6 ? color.new(color.green, 20) : smooth1 < smooth6 ? color.new(color.red, 20) : color.gray) : color.gray
    
    midValue = (rsi + avgSmooth) / 2
    midColor = midValue >= 50 ? color.new(color.green, 40) : color.new(color.red, 40)
    
    sz = tableSize(tableSzInput)

    table.cell(infoTable, 0, 0, "RSI INFO",        text_color=color.white,  text_size=sz, bgcolor=color.new(#7E57C2, 20), text_halign=text.align_center)
    table.cell(infoTable, 1, 0, "",                text_color=color.white,  text_size=sz, bgcolor=color.new(#7E57C2, 20))
    table.cell(infoTable, 0, 1, "RSI",             text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 1, str.tostring(rsi, "#.##"), text_color=rsiColor, text_size=sz, text_halign=text.align_right)
    table.cell(infoTable, 0, 2, "Avg Smooth",  text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 2, showSmooth6 ? str.tostring(avgSmooth, "#.##") : "OFF", text_color=color.yellow, text_size=sz, text_halign=text.align_right)
    table.cell(infoTable, 0, 3, "Ratio",  text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 3, str.tostring(midValue, "#.##"), text_color=midColor, text_size=sz, text_halign=text.align_right)
    table.cell(infoTable, 0, 4, "Trend", text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 4, trendLbl,          text_color=trendCol,     text_size=sz, text_halign=text.align_right)
    table.cell(infoTable, 0, 5, "Zone",            text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 5, zoneLbl,           text_color=zoneCol,      text_size=sz, text_halign=text.align_right)
    table.cell(infoTable, 0, 6, "Smooth trend", text_color=color.silver, text_size=sz)
    table.cell(infoTable, 1, 6, smoothTrend,       text_color=smoothCol,    text_size=sz, text_halign=text.align_right)

// ─── Divergence ───────────────────────────────────────────────────────────────
lookbackRight = 5
lookbackLeft  = 5
rangeUpper    = 60
rangeLower    = 5
bearColor     = color.red
bullColor     = color.green
textColor     = color.white
noneColor     = color.new(color.white, 100)

_inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound  = false
phFound  = false
bullCond = false
bearCond = false
rsiLBR   = rsi[lookbackRight]

if calculateDivergence
    plFound  := not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))
    phFound  := not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))
    
    // Calcul des conditions _inRange en dehors des conditions imbriquées pour éviter l'avertissement
    inRangePl = _inRange(plFound[1])
    inRangePh = _inRange(phFound[1])
    
    rsiHL     = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangePl
    lowLBR    = low[lookbackRight]
    priceLL   = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond  := priceLL and rsiHL and plFound

    rsiLH     = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangePh
    highLBR   = high[lookbackRight]
    priceHH   = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond  := priceHH and rsiLH and phFound

plot(plFound ? rsiLBR : na,  offset=-lookbackRight, title="Regular Bullish", linewidth=2, color=(bullCond ? bullColor : noneColor), display=display.pane, editable=calculateDivergence)
plotshape(bullCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bullish Label", text=" Bull ", style=shape.labelup,   location=location.absolute, color=bullColor, textcolor=textColor, display=display.pane, editable=calculateDivergence)
plot(phFound ? rsiLBR : na,  offset=-lookbackRight, title="Regular Bearish", linewidth=2, color=(bearCond ? bearColor : noneColor), display=display.pane, editable=calculateDivergence)
plotshape(bearCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor, display=display.pane, editable=calculateDivergence)

alertcondition(bullCond, title='Regular Bullish Divergence',  message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title='Regular Bearish Divergence',  message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')
````
