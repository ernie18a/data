# Orange Flag

- url: https://www.tradingview.com/script/Zhu8wPMm-Orange-Flag/
- type: indicator
- pine_id: PUB;b7bba72447de4f7c9c6c8f6ee8553cfa
- version: 1.0

## Description

[b]How it works[/b]
The indicator pulls daily data from four market internals and assigns points based on whether each one is at an extreme reading:

YRHI-YRLO spread (52-week new highs minus new lows on NASDAQ): +3 points if ≥ 75
MMTW (Russell 2000 stocks above 50-day MA): +2 points if ≥ 55
S5FI (S&P 500 stocks above 50-day MA): +2 points if ≥ 65
VIX: +1 point if < 15

Maximum score is 8 points. When the total reaches 5 or higher, the chart background paints orange to flag a risk-on extreme.

[b]How to use it[/b]
The orange flag identifies conditions historically associated with frothy market tops — broad participation, lots of new highs, and complacent volatility all aligned. It is a context filter, not a trade signal. When the flag is on, consider tightening risk controls, fading new long entries on extension, or being more selective about chasing strength.
The flag should be relatively rare. If it fires often, the thresholds are too loose for current market structure.

[b]Display[/b]
A status table in the top-right corner shows each component's current value, threshold, and points contributed, plus the total risk score and flag state.

[b]Settings[/b]
All thresholds, the flag trigger level, and the underlying ticker symbols are configurable. Defaults use TVC, USI, and INDEX prefixes that resolve cleanly on TradingView.

[b]Alerts[/b]
Two alert conditions are available: orange flag triggered (score crosses up through threshold) and orange flag cleared (score drops back below threshold).

[b]Notes[/b]
Data is pulled at the daily timeframe regardless of chart timeframe, with lookahead_off to prevent intrabar repaint. The score updates only when the daily close prints. Built in Pine Script v6.

## Source Code

````pine
//@version=6
indicator("Orange Flag", "Orange Flag", overlay = true)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
grpThr = "Thresholds"
yrhiThr  = input.int(75, "YRHI-YRLO threshold (+3)", group = grpThr)
mmtwThr  = input.int(55, "MMTW threshold (+2)",     group = grpThr)
s5fiThr  = input.int(65, "S5FI threshold (+2)",     group = grpThr)
vixThr   = input.int(15, "VIX threshold, less-than (+1)", group = grpThr)
flagAt   = input.int(5,  "Orange flag at score >=", group = grpThr)

grpSym = "Symbols"
vixSym  = input.symbol("TVC:VIX",         "VIX",  group = grpSym)
yrhiSym = input.symbol("USI:YRHI.NQ",   "YRHI", group = grpSym)
yrloSym = input.symbol("USI:YRLO.NQ",   "YRLO", group = grpSym)
s5fiSym = input.symbol("INDEX:S5FI",       "S5FI", group = grpSym)
mmtwSym = input.symbol("INDEX:MMTW",       "MMTW", group = grpSym)

grpVis = "Visuals"
showTable = input.bool(true, "Show status table", group = grpVis)
bgColor   = input.color(color.new(color.orange, 75), "Orange flag background", group = grpVis)

// ─────────────────────────────────────────────
// Data — always pull daily closes regardless of chart timeframe
// lookahead_off + offset [1] avoids repaint on intrabar
// ─────────────────────────────────────────────
f_daily(sym) =>
    request.security(sym, "D", close, lookahead = barmerge.lookahead_off)

vix  = f_daily(vixSym)
yrhi = f_daily(yrhiSym)
yrlo = f_daily(yrloSym)
s5fi = f_daily(s5fiSym)
mmtw = f_daily(mmtwSym)

yrhiSpread = yrhi - yrlo

// ─────────────────────────────────────────────
// Scoring
// ─────────────────────────────────────────────
pYrhi = yrhiSpread >= yrhiThr ? 3 : 0
pMmtw = mmtw       >= mmtwThr ? 2 : 0
pS5fi = s5fi       >= s5fiThr ? 2 : 0
pVix  = vix        <  vixThr  ? 1 : 0

riskScore = pYrhi + pMmtw + pS5fi + pVix
orangeFlag = riskScore >= flagAt

// ─────────────────────────────────────────────
// Background paint
// ─────────────────────────────────────────────
bgcolor(orangeFlag ? bgColor : na, title = "Risk Signal BG")

// ─────────────────────────────────────────────
// Status table
// ─────────────────────────────────────────────
var table t = table.new(position.top_right, 3, 6, border_width = 1)

f_row(row, label, val, thr, pts, hit) =>
    txtCol = hit ? color.white : color.gray
    bgCol  = hit ? color.new(color.orange, 40) : color.new(color.gray, 80)
    table.cell(t, 0, row, label,                               text_color = txtCol, bgcolor = bgCol, text_size = size.small)
    table.cell(t, 1, row, str.tostring(val, "#.##") + " / " + str.tostring(thr), text_color = txtCol, bgcolor = bgCol, text_size = size.small)
    table.cell(t, 2, row, "+" + str.tostring(pts),             text_color = txtCol, bgcolor = bgCol, text_size = size.small)

if showTable and barstate.islast
    table.clear(t, 0, 0, 2, 5)
    table.cell(t, 0, 0, "Component", text_color = color.white, bgcolor = color.new(color.black, 30), text_size = size.small)
    table.cell(t, 1, 0, "Value",     text_color = color.white, bgcolor = color.new(color.black, 30), text_size = size.small)
    table.cell(t, 2, 0, "Pts",       text_color = color.white, bgcolor = color.new(color.black, 30), text_size = size.small)
    f_row(1, "YRHI-YRLO >= " + str.tostring(yrhiThr), yrhiSpread, yrhiThr, pYrhi, pYrhi > 0)
    f_row(2, "MMTW >= "      + str.tostring(mmtwThr), mmtw,       mmtwThr, pMmtw, pMmtw > 0)
    f_row(3, "S5FI >= "      + str.tostring(s5fiThr), s5fi,       s5fiThr, pS5fi, pS5fi > 0)
    f_row(4, "VIX < "        + str.tostring(vixThr),  vix,        vixThr,  pVix,  pVix  > 0)
    scoreCol = orangeFlag ? color.new(color.orange, 20) : color.new(color.green, 60)
    table.cell(t, 0, 5, "RISK SCORE", text_color = color.white, bgcolor = scoreCol, text_size = size.small)
    table.cell(t, 1, 5, str.tostring(riskScore) + " / 8", text_color = color.white, bgcolor = scoreCol, text_size = size.small)
    table.cell(t, 2, 5, orangeFlag ? "FLAG" : "—",        text_color = color.white, bgcolor = scoreCol, text_size = size.small)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(orangeFlag and not orangeFlag[1], "Orange flag triggered", "GHP Risk: orange flag triggered (score >= threshold)")
alertcondition(not orangeFlag and orangeFlag[1], "Orange flag cleared",   "GHP Risk: orange flag cleared")
````
