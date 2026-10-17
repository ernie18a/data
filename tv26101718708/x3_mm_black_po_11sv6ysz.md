# x3 mm black po

- url: https://www.tradingview.com/script/11SV6ysz/
- type: indicator
- pine_id: PUB;c5ec1c245fb5422c97258ad43c5792ed
- version: 1.0

## Description

x3 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// BTMM TDI (Traders Dynamic Index) - TradingView port
// Specifiche da "How to Setup BTMM EMAs and TDI on Mobile mt4 and mt5.pdf"
// (Steve Mauro / Dean Malone setup)
//
// Layer del TDI:
//   - RSI 13 close (alcuni 21)        → nascosto (color background)
//   - SMA(RSI, 2)                     → GREEN  (Price/Signal line)
//   - SMA(RSI, 7)                     → RED    (Signal/Trade line)
//   - BB(RSI, 34, dev 1.619)          → BLUE   (Volatility band)
//   - SMA(RSI, 34)                    → YELLOW (Market Base Line / MBL)
//   - Livelli 32 / 50 / 68            → GREY
// =============================================================================
indicator("x3 mm black po", overlay=false, max_labels_count=500, precision=2)

// ---- Inputs ----
// Default da BTMM New.tpl di Steve Mauro: RSI=21, fast=2, signal=7, BB=34, deviation 1.619
rsiLen      = input.int(21, "RSI period",   minval=2, maxval=100, tooltip="21 = setup Steve Mauro (BTMM Installer / btmm_TDI_Plus); 13 = Dean Malone classico (PDF Mobile)")
src         = input.source(close, "RSI source")
fastMaLen   = input.int(2,  "Green (fast) MA period",  minval=1)
slowMaLen   = input.int(7,  "Red (signal) MA period",  minval=1)
mblLen      = input.int(34, "Yellow MBL / BB period",  minval=2)
bbDev       = input.float(1.619, "BB deviation", step=0.001)

// Levels — Steve Mauro usa 5 livelli (20/30/50/70/80), Dean Malone solo 3 (32/50/68)
useFiveLevels = input.bool(true,  "Usa 5 levels Steve Mauro (20/30/50/70/80)", tooltip="Off = solo 3 levels classici 32/50/68")
lvExHi  = input.int(80, "Extreme High", minval=50, maxval=100, group="Levels (5)")
lvHi    = input.int(70, "High",         minval=50, maxval=100, group="Levels (5)")
lvMid   = input.int(50, "Middle",       minval=0,  maxval=100, group="Levels (5)")
lvLo    = input.int(30, "Low",          minval=0,  maxval=50,  group="Levels (5)")
lvExLo  = input.int(20, "Extreme Low",  minval=0,  maxval=50,  group="Levels (5)")

colGreen    = input.color(color.new(color.green, 0),  "Green line")
colRed      = input.color(color.new(color.red, 0),    "Red line")
colYellow   = input.color(color.new(color.yellow, 0), "Yellow MBL")
colBlue     = input.color(color.new(color.blue, 0),   "Blue bands")
colLevel    = input.color(color.new(color.gray, 50),  "Level lines")

showRsi     = input.bool(false, "Mostra RSI raw (di solito nascosto)")
showFill    = input.bool(true,  "Riempi banda blu")
showLabels  = input.bool(true,  "Label segnali su chart")
alertOnX    = input.bool(true,  "Alert su cross Green/Red")

// ---- Compute ----
rsi    = ta.rsi(src, rsiLen)
gline  = ta.sma(rsi, fastMaLen)         // GREEN — fast / price line
rline  = ta.sma(rsi, slowMaLen)         // RED — slow / signal line
mbl    = ta.sma(rsi, mblLen)            // YELLOW — Market Base Line (anche basis BB)
bbDev_ = ta.stdev(rsi, mblLen) * bbDev
bbUp   = mbl + bbDev_
bbLo   = mbl - bbDev_

// ---- Plots ----
// Linewidth da PDF Steve Mauro: Green/Red 2px, Blue BB 2px, Yellow MBL 3px
plot(showRsi ? rsi : na, "RSI", color=color.new(color.gray, 70), display=display.pane)
plot(gline, "Green (price)", color=colGreen,  linewidth=2)
plot(rline, "Red (signal)",  color=colRed,    linewidth=2)
plot(mbl,   "Yellow (MBL)",  color=colYellow, linewidth=3)
pUp = plot(bbUp, "BB Upper", color=colBlue, linewidth=2)
pLo = plot(bbLo, "BB Lower", color=colBlue, linewidth=2)
fill(pUp, pLo, color=showFill ? color.new(colBlue, 92) : na, title="BB fill")

// ---- Levels (Steve Mauro 5 lv 20/30/50/70/80 oppure Dean Malone 3 lv 32/50/68) ----
hline(useFiveLevels ? lvExHi : 68, "Extreme High / OB", color=color.new(color.red, 30),    linestyle=hline.style_dotted)
hline(useFiveLevels ? lvHi   : 68, "High",              color=color.new(color.gray, 30),   linestyle=hline.style_dashed)
hline(useFiveLevels ? lvMid  : 50, "Middle",            color=color.new(color.gray, 50),   linestyle=hline.style_dashed)
hline(useFiveLevels ? lvLo   : 32, "Low",               color=color.new(color.gray, 30),   linestyle=hline.style_dashed)
hline(useFiveLevels ? lvExLo : 32, "Extreme Low / OS",  color=color.new(color.green, 30),  linestyle=hline.style_dotted)
hline(0,   "0",   color=color.new(color.gray, 80))
hline(100, "100", color=color.new(color.gray, 80))

// ---- Signals ----
crossUp   = ta.crossover(gline,  rline)
crossDown = ta.crossunder(gline, rline)

// Filtro MBL: trend "vero" se Green & Red sopra/sotto Yellow
bullTrend = gline > mbl and rline > mbl
bearTrend = gline < mbl and rline < mbl

// Strong signals (cross + MBL agreement + BB position)
strongBuy  = crossUp   and gline < 50 and gline < bbLo + (bbUp - bbLo) * 0.3
strongSell = crossDown and gline > 50 and gline > bbUp - (bbUp - bbLo) * 0.3

plotshape(showLabels and crossUp,   "Buy cross",  shape.triangleup,   location.bottom, color=color.new(color.green, 30), size=size.tiny)
plotshape(showLabels and crossDown, "Sell cross", shape.triangledown, location.top,    color=color.new(color.red, 30),   size=size.tiny)
plotshape(showLabels and strongBuy, "Strong buy", shape.circle,       location.bottom, color=color.new(color.lime, 0),   size=size.small)
plotshape(showLabels and strongSell,"Strong sell",shape.circle,       location.top,    color=color.new(color.fuchsia, 0),size=size.small)

// ---- Background tint per trend ----
bgcolor(bullTrend ? color.new(color.green, 95) : bearTrend ? color.new(color.red, 95) : na, title="Trend tint")

// ---- Alerts ----
alertcondition(alertOnX and crossUp,   "TDI Buy cross",   "TDI: Green crossed above Red")
alertcondition(alertOnX and crossDown, "TDI Sell cross",  "TDI: Green crossed below Red")
alertcondition(strongBuy,              "TDI Strong Buy",  "TDI: Strong Buy (cross + oversold zone)")
alertcondition(strongSell,             "TDI Strong Sell", "TDI: Strong Sell (cross + overbought zone)")
alertcondition(ta.crossover(gline, useFiveLevels ? lvExHi : 68),  "TDI Overbought", "TDI: Green crossed above extreme high")
alertcondition(ta.crossunder(gline, useFiveLevels ? lvExLo : 32), "TDI Oversold",   "TDI: Green crossed below extreme low")

// ---- Stato corrente in tabella ----
var table t = table.new(position=position.top_right, columns=2, rows=4, border_width=1)
if barstate.islast
    trendTxt = bullTrend ? "BULL" : bearTrend ? "BEAR" : "MIXED"
    trendCol = bullTrend ? color.new(color.green, 30) : bearTrend ? color.new(color.red, 30) : color.new(color.gray, 30)
    obLvl    = useFiveLevels ? lvExHi : 68
    osLvl    = useFiveLevels ? lvExLo : 32
    zoneTxt  = gline > obLvl ? "OB" : gline < osLvl ? "OS" : "MID"
    zoneCol  = gline > obLvl ? color.new(color.red, 30) : gline < osLvl ? color.new(color.green, 30) : color.new(color.gray, 30)
    bbTxt    = gline > bbUp ? "ABOVE BB" : gline < bbLo ? "BELOW BB" : "INSIDE BB"
    table.cell(t, 0, 0, "TDI",    bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(t, 1, 0, str.tostring(gline, "#.0"), bgcolor=color.new(color.black, 0), text_color=colGreen)
    table.cell(t, 0, 1, "Trend",  bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, 1, trendTxt, bgcolor=trendCol, text_color=color.white)
    table.cell(t, 0, 2, "Zone",   bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, 2, zoneTxt,  bgcolor=zoneCol, text_color=color.white)
    table.cell(t, 0, 3, "BB",     bgcolor=color.new(color.gray, 70))
    table.cell(t, 1, 3, bbTxt,    bgcolor=color.new(color.blue, 50), text_color=color.white)
````
