# GCC : MACD MTF Dashboard [Horizontal Clean] + Dynamic MACD

- url: https://www.tradingview.com/script/229VVSdE/
- type: indicator
- pine_id: PUB;93b11f200a404bb3ae79c2f4ee311442
- version: 1.0

## Description

macd multitimefram +macd pourn uen meilleur vsions

## Source Code

````pine
//@version=6
//==============================================================================
//  MACD MTF Dashboard [Horizontal Clean] + Dynamic Current TF MACD
//  Histogramme : barre plus foncée si elle est PLUS FORTE que la précédente
//==============================================================================

indicator("MACD MTF Dashboard [Horizontal Clean] + Dynamic MACD", 
     shorttitle="MTF MACD", 
     overlay=false, 
     max_lines_count=500, 
     max_labels_count=500, 
     max_boxes_count=500)

// === INPUTS ===
fastLength     = input.int(12, "MACD Fast Length", minval=1, group="MACD Settings")
slowLength     = input.int(26, "MACD Slow Length", minval=1, group="MACD Settings")
signalLength   = input.int(9,  "MACD Signal Length", minval=1, group="MACD Settings")
src            = input.source(close, "Source", group="MACD Settings")

showMACDPlot   = input.bool(true, "Afficher la MACD du timeframe courant", group="Affichage")
plotMACDColor  = input.color(color.new(#2196F3, 0), "Couleur ligne MACD", group="Affichage")
plotSignalColor= input.color(color.new(#FF9800, 0), "Couleur ligne Signal", group="Affichage")
bullColor      = input.color(color.new(#00C853, 0), "Couleur BULL", group="Couleurs")
bearColor      = input.color(color.new(#FF1744, 0), "Couleur BEAR", group="Couleurs")

// === TIMEFRAMES DU DASHBOARD (ordre inversé) ===
var string[] dashboardTFs = array.from("W", "3D", "D", "720", "240", "60", "30", "15", "10", "5", "1")

// === FONCTION MACD MTF ===
f_getMACD(string tf) =>
    request.security(syminfo.tickerid, tf, ta.macd(src, fastLength, slowLength, signalLength))

// === CALCULS ===
[macdCurr, signalCurr, histCurr] = ta.macd(src, fastLength, slowLength, signalLength)

// === TABLEAU HORIZONTAL CLEAN ===
var int numTFs = array.size(dashboardTFs)
var table macdTable = table.new(position.top_right, columns = numTFs + 1, rows = 3,
     bgcolor = color.new(color.black, 15), frame_color = color.new(color.gray, 30),
     frame_width = 1, border_color = color.new(color.gray, 40), border_width = 1)

if barstate.islast
    table.cell(macdTable, 0, 0, "TF",     bgcolor=color.new(color.black,0), text_color=color.white, text_halign=text.align_center, text_size=size.small)
    table.cell(macdTable, 0, 1, "MACD",   bgcolor=color.new(color.black,0), text_color=color.white, text_halign=text.align_center, text_size=size.small)
    table.cell(macdTable, 0, 2, "SIGNAL", bgcolor=color.new(color.black,0), text_color=color.white, text_halign=text.align_center, text_size=size.small)

    for i = 0 to numTFs - 1
        string tf = array.get(dashboardTFs, i)
        [mLine, sLine, hLine] = f_getMACD(tf)
        
        bool isBull     = mLine > sLine
        bool isBullHist = hLine > 0
        
        string macdText = isBull ? "BULL" : "BEAR"
        color  macdBg   = isBull ? bullColor : bearColor
        color  sigColor = isBullHist ? bullColor : bearColor

        table.cell(macdTable, i + 1, 0, tf,     bgcolor=color.new(color.black,0), text_color=color.white, text_halign=text.align_center, text_size=size.small)
        table.cell(macdTable, i + 1, 1, macdText, bgcolor=macdBg, text_color=color.white, text_halign=text.align_center, text_size=size.small)
        table.cell(macdTable, i + 1, 2, "●",    bgcolor=color.new(color.black,0), text_color=sigColor, text_halign=text.align_center, text_size=size.normal)

// === MACD DYNAMIQUE ===
plot(macdCurr, color=plotMACDColor, linewidth=2, title="MACD Line",
     display = showMACDPlot ? display.all : display.none)

plot(signalCurr, color=plotSignalColor, linewidth=2, title="Signal Line",
     display = showMACDPlot ? display.all : display.none)

// === HISTOGRAMME : plus foncé si la barre est plus forte que la précédente ===
h = histCurr
h_prev = histCurr[1]

bull_color = h > h_prev ? color.new(#009688, 0) : color.new(#4DB6AC, 45)
bear_color = h < h_prev ? color.new(#E53935, 0) : color.new(#EF9A9A, 45)

plot(h >= 0 ? h : na, style=plot.style_histogram, 
     color = bull_color, title="Histogram Bull", 
     display = showMACDPlot ? display.all : display.none)

plot(h < 0 ? h : na, style=plot.style_histogram, 
     color = bear_color, title="Histogram Bear", 
     display = showMACDPlot ? display.all : display.none)

hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
````
