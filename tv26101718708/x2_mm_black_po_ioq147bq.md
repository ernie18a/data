# x2 mm black po

- url: https://www.tradingview.com/script/iOq147Bq/
- type: indicator
- pine_id: PUB;b21693cf52f54fc89340e5c1579e5b5d
- version: 1.0

## Description

x2 mm black po by 221, Danimanipulation e Matte, based on mm model 4 black project

## Source Code

````pine
//@version=6
// =============================================================================
// BTMM Dashboard - TradingView port (Pine Script v6)
// Original: "! btmm dashboard.ex4" (Steve Mauro - Beat The Market Maker method)
// Mostra una dashboard multi-timeframe con:
//   - Trend EMAs 5/13/50/200/800 (colori standard BTMM)
//   - Posizione price vs EMA13 (cigarette)
//   - Stato Asian Range / London / New York
//   - TDI condition (overbought/oversold) [approx via RSI]
//   - M/W pattern flag base
// =============================================================================
indicator("x2 mm black po", overlay=true, max_labels_count=500)

// ---- Inputs ----
showDash      = input.bool(true,  "Show dashboard")
dashCorner    = input.string("top_right", "Corner",
                  options=["top_left","top_right","bottom_left","bottom_right"])
showAsianBox  = input.bool(true,  "Show Asian Range box")
asianStart    = input.int(0,  "Asian session start (broker hour)", minval=0, maxval=23)
asianEnd      = input.int(7,  "Asian session end (broker hour)",   minval=0, maxval=23)
londonStart   = input.int(7,  "London start", minval=0, maxval=23)
londonEnd     = input.int(15, "London end",   minval=0, maxval=23)
nyStart       = input.int(12, "NY start",     minval=0, maxval=23)
nyEnd         = input.int(20, "NY end",       minval=0, maxval=23)

// BTMM standard EMA palette
ema5  = ta.ema(close, 5)
ema13 = ta.ema(close, 13)
ema50 = ta.ema(close, 50)
ema200= ta.ema(close, 200)
ema800= ta.ema(close, 800)

// Colori e weight da "BTMM New.tpl" (template MT4 ufficiale di Steve Mauro):
//   5 Mustard #FFFF00 • 13 Ketchup #FF0000 • 50 Water #00FFFF
//   200 Mayonnaise #FFFFFF • 800 BlueBerry #0000FF  — weight=2 su tutti
plot(ema5,   "EMA 5 (Mustard)",      color=color.new(color.yellow, 0), linewidth=2)
plot(ema13,  "EMA 13 (Ketchup)",     color=color.new(color.red, 0),    linewidth=2)
plot(ema50,  "EMA 50 (Water)",       color=color.new(color.aqua, 0),   linewidth=2)
plot(ema200, "EMA 200 (Mayonnaise)", color=color.new(color.white, 0),  linewidth=2)
plot(ema800, "EMA 800 (BlueBerry)",  color=color.new(#0000FF, 0),      linewidth=2)

// ---- Asian Range ----
inAsia   = (hour >= asianStart and hour < asianEnd)
inLondon = (hour >= londonStart and hour < londonEnd)
inNY     = (hour >= nyStart and hour < nyEnd)

var float asianHi = na
var float asianLo = na
newAsia = inAsia and not inAsia[1]
asianHi := newAsia ? high : inAsia ? math.max(nz(asianHi, high), high) : asianHi
asianLo := newAsia ? low  : inAsia ? math.min(nz(asianLo, low),  low)  : asianLo

plot(showAsianBox ? asianHi : na, "Asia High", color=color.new(color.orange, 0), style=plot.style_linebr)
plot(showAsianBox ? asianLo : na, "Asia Low",  color=color.new(color.orange, 0), style=plot.style_linebr)

// ---- Trend logic (semplice gerarchia EMA) ----
bull = ema5 > ema13 and ema13 > ema50 and close > ema13
bear = ema5 < ema13 and ema13 < ema50 and close < ema13
trendTxt = bull ? "BULL" : bear ? "BEAR" : "RANGE"
trendCol = bull ? color.new(color.green, 0) : bear ? color.new(color.red, 0) : color.new(color.gray, 0)

// ---- TDI completo (Dean Malone / Steve Mauro setup, vedi btmm_tdi.pine) ----
// RSI 13 + Green SMA(2) + Red SMA(7) + Yellow MBL SMA(34) + BB(34, 1.619)
rsiVal = ta.rsi(close, 13)
gline  = ta.sma(rsiVal, 2)
rline  = ta.sma(rsiVal, 7)
mbl    = ta.sma(rsiVal, 34)
bbDev_ = ta.stdev(rsiVal, 34) * 1.619
bbUp   = mbl + bbDev_
bbLo   = mbl - bbDev_

tdiBull = gline > rline and gline > mbl and rline > mbl
tdiBear = gline < rline and gline < mbl and rline < mbl
tdiOB   = gline > 68 or gline > bbUp
tdiOS   = gline < 32 or gline < bbLo
tdiTxt = tdiBull and tdiOB ? "BULL+OB" : tdiBear and tdiOS ? "BEAR+OS" : tdiBull ? "BULL" : tdiBear ? "BEAR" : tdiOB ? "OB" : tdiOS ? "OS" : "MID"

// ---- M / W pattern flag (basico) ----
// ta.pivothigh/pivotlow ritornano il valore del pivot (na se non c'è) — usiamo not na() per bool
mPattern = not na(ta.pivothigh(high, 5, 5)) and high[5] < high[10]
wPattern = not na(ta.pivotlow(low, 5, 5))   and low[5]  > low[10]
patTxt   = mPattern ? "M" : wPattern ? "W" : "-"

// ---- Session text ----
sessTxt = inAsia ? "ASIA" : inLondon and inNY ? "LDN+NY" : inLondon ? "LDN" : inNY ? "NY" : "OFF"

// ---- Dashboard table ----
// position si definisce DENTRO il blocco barstate.islast per rispettare l'input dashCorner;
// table viene ricreata (table.delete della precedente per evitare leak)
posSel = dashCorner == "top_left" ? position.top_left : dashCorner == "top_right" ? position.top_right : dashCorner == "bottom_left" ? position.bottom_left : position.bottom_right
var table dash = na
if showDash and barstate.islast
    if not na(dash)
        table.delete(dash)
    dash := table.new(position=posSel, columns=2, rows=6, border_width=1)
    table.cell(dash, 0, 0, "BTMM",         bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(dash, 1, 0, syminfo.ticker, bgcolor=color.new(color.black, 0), text_color=color.white)
    table.cell(dash, 0, 1, "Trend",        bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 1, trendTxt,       bgcolor=trendCol, text_color=color.white)
    table.cell(dash, 0, 2, "Session",      bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 2, sessTxt,        bgcolor=color.new(color.blue, 50),  text_color=color.white)
    table.cell(dash, 0, 3, "TDI",          bgcolor=color.new(color.gray, 70))
    tdiBg = tdiBull ? color.new(color.green, 30) : tdiBear ? color.new(color.red, 30) : tdiOB ? color.new(color.red, 50) : tdiOS ? color.new(color.green, 50) : color.new(color.gray, 30)
    table.cell(dash, 1, 3, tdiTxt,  bgcolor=tdiBg, text_color=color.white)
    table.cell(dash, 0, 4, "Pattern",      bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 4, patTxt,         bgcolor=color.new(color.purple, 40), text_color=color.white)
    table.cell(dash, 0, 5, "Asia Hi",      bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 5, str.tostring(asianHi, format.mintick), bgcolor=color.new(color.orange, 50), text_color=color.white)
````
