# Smart Money Confluence Panel [Jayadev Rana]

- url: https://www.tradingview.com/script/L89ndk4H-Smart-Money-Confluence-Panel-Jayadev-Rana/
- type: indicator
- pine_id: PUB;3ab2e2f2d3ec486d9904f2d84742b228
- version: 2.0

## Description

Smart Money Confluence Panel is an all-in-one Smart Money Concepts (SMC) overlay that brings market structure, a Fibonacci golden zone, imbalance and liquidity mapping, a higher-timeframe checklist panel, a multi-symbol scanner and a risk-based position sizer onto a single chart.

MARKET STRUCTURE
Pivot-based swing detection labels Higher Highs, Higher Lows, Lower Highs and Lower Lows. A Break of Structure is confirmed when price closes beyond the last swing, with an optional strong-close body filter and a bias switch (Both, Bullish or Bearish). A Sensitivity setting (High, Medium, Low) controls the pivot lookback.

FIBONACCI GOLDEN ZONE
From the most recent confirmed swing the tool projects Fibonacci levels and shades the golden zone between two configurable ratios (default 50 and 71), plus an extension level. The 0 and 1 anchors mark the swing extremes.

IMBALANCE AND LIQUIDITY
Three-bar fair value gaps are drawn as boxes. Liquidity sweeps are flagged when price wicks beyond a prior swing and closes back inside. Previous Day High and Previous Day Low are plotted as reference levels.

CHECKLIST PANEL
A configurable panel grades the current setup against four conditions: higher-timeframe alignment, liquidity sweep, break of structure plus imbalance, and a 71 percent retracement. Each met condition adds to a Trade Score, and a premium or discount read is derived from the higher-timeframe dealing range. Every checklist line can be toggled on or off.

MULTI-SYMBOL SCANNER
The scanner reads a configurable list of symbols on the bias timeframe and reports a directional read and a confluence score for each, so several markets can be watched at once.

AUTO LOT SIZER
Given an account risk amount, a pip value per lot and an ATR-based stop distance, the panel estimates a position size in lots together with the stop in pips.

NOTES
Calculations use confirmed bars and the higher-timeframe reads use lookahead off. This is an analysis and charting tool, not a signal service and not financial advice. Test any approach on your own data and manage risk before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bluealgocapital

//@version=6
indicator("Smart Money Confluence Panel [Jayadev Rana]", "SMC Panel", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

gMS         = "Market Structure"
marketBias  = input.string("Both", "Market Bias", options = ["Both", "Bullish", "Bearish"], group = gMS)
sensitivity = input.string("High", "Sensitivity", options = ["High", "Medium", "Low"], group = gMS)
useStrong   = input.bool(true, "Strong Close", inline = "sc", group = gMS)
strongClose = input.int(50, "", minval = 0, maxval = 100, inline = "sc", group = gMS)
showHL      = input.bool(false, "Show High/Lows", group = gMS)
showBOS     = input.bool(true, "Show BOS", group = gMS)
bosCol      = input.color(color.new(#787b86, 0), "BOS Line", group = gMS)
hhCol       = input.color(#26a69a, "HH", inline = "hhhl", group = gMS)
hlCol       = input.color(#26a69a, "HL", inline = "hhhl", group = gMS)
llCol       = input.color(#ef5350, "LL", inline = "llll", group = gMS)
lhCol       = input.color(#ef5350, "LH", inline = "llll", group = gMS)

gFib        = "Fib Levels"
showFib     = input.bool(true, "Show Fib Levels", group = gFib)
showFibPr   = input.bool(false, "Show Fib Price", group = gFib)
fib1On      = input.bool(false, "Fib Level (1)", inline = "f1", group = gFib)
fib1Val     = input.float(50, "", inline = "f1", group = gFib)
fib2On      = input.bool(true, "Fib Level (2)", inline = "f2", group = gFib)
fib2Val     = input.float(71, "", inline = "f2", group = gFib)
extensionV  = input.float(30, "Extension", group = gFib)
outFibCol   = input.color(color.new(#787b86, 0), "Outside Fib Colors", group = gFib)
fibCol      = input.color(#d4af37, "Fib Colors", group = gFib)

gSMC        = "Imbalance & Liquidity"
showFVG     = input.bool(true, "Show FVG / Imbalance", group = gSMC)
fvgUp       = input.color(color.new(#26a69a, 82), "Bullish FVG", group = gSMC)
fvgDn       = input.color(color.new(#ef5350, 82), "Bearish FVG", group = gSMC)
showLiq     = input.bool(true, "Show Liquidity Sweeps", group = gSMC)
showPD      = input.bool(true, "Show PDH / PDL", group = gSMC)

gPanel      = "Trading Panel"
showPanel   = input.bool(true, "Show Panel", group = gPanel)
panelTitle  = input.string("Smart Money 🔥", "Panel Title", group = gPanel)
htfTF       = input.timeframe("1D", "HTF Bias Timeframe", group = gPanel)
ckHTF       = input.bool(true, "HTF Alignment", group = gPanel)
ckBOS       = input.bool(true, "Break of Structure", group = gPanel)
ckLiq       = input.bool(true, "Liquidity Sweep", group = gPanel)
ckFVG       = input.bool(true, "Imbalance", group = gPanel)
panelPos    = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gPanel)

gScan       = "Scanner"
showScan    = input.bool(true, "Show Scanner", group = gScan)
scanMaLen   = input.int(50, "Scanner MA Length", minval = 5, group = gScan)
s1          = input.symbol("FX:AUDUSD", "Symbol 1", group = gScan)
s2          = input.symbol("FX:EURUSD", "Symbol 2", group = gScan)
s3          = input.symbol("FX:GBPUSD", "Symbol 3", group = gScan)
s4          = input.symbol("FX:USDCAD", "Symbol 4", group = gScan)
s5          = input.symbol("FX:USDCHF", "Symbol 5", group = gScan)
s6          = input.symbol("FX:CHFJPY", "Symbol 6", group = gScan)
s7          = input.symbol("FX:EURCHF", "Symbol 7", group = gScan)
s8          = input.symbol("FX:NZDCHF", "Symbol 8", group = gScan)
s9          = input.symbol("OANDA:XAUUSD", "Symbol 9", group = gScan)

gSig        = "Reversal Trades"
showSig     = input.bool(true, "Show Reversal Trades", group = gSig)
slBufAtr    = input.float(0.2, "SL Buffer (ATR x)", minval = 0, step = 0.1, group = gSig)
tp1R        = input.float(1, "Target 1 (R)", minval = 0.1, step = 0.5, group = gSig)
tp2R        = input.float(2, "Target 2 (R)", minval = 0.1, step = 0.5, group = gSig)
tp3R        = input.float(3, "Target 3 (R)", minval = 0.1, step = 0.5, group = gSig)

gLot        = "Auto Lot"
showLot     = input.bool(true, "Show Auto Lot", group = gLot)
riskUSD     = input.float(100, "Risk (USD)", minval = 0, group = gLot)
pipValue    = input.float(10, "Pip Value / Lot (USD)", minval = 0.01, group = gLot)
stopAtrMult = input.float(1.5, "Stop = ATR x", minval = 0.1, group = gLot)

piv = switch sensitivity
    "High"   => 5
    "Medium" => 8
    => 13

allowBull = marketBias != "Bearish"
allowBear = marketBias != "Bullish"

ph = ta.pivothigh(high, piv, piv)
pl = ta.pivotlow(low, piv, piv)

var float lastPH   = na
var int   lastPHx  = na
var float prevPH   = na
var float lastPL   = na
var int   lastPLx  = na
var float prevPL   = na

body      = math.abs(close - open)
rangeHL   = high - low
strongOk  = not useStrong or (rangeHL > 0 and body >= rangeHL * strongClose / 100)

if not na(ph)
    prevPH := lastPH
    lastPH := ph
    lastPHx := bar_index - piv
    if showHL
        isHH = na(prevPH) or ph >= prevPH
        label.new(bar_index - piv, ph, isHH ? "HH" : "LH", style = label.style_label_down, color = color.new(isHH ? hhCol : lhCol, 20), textcolor = color.white, size = size.tiny)

if not na(pl)
    prevPL := lastPL
    lastPL := pl
    lastPLx := bar_index - piv
    if showHL
        isHL = na(prevPL) or pl >= prevPL
        label.new(bar_index - piv, pl, isHL ? "HL" : "LL", style = label.style_label_up, color = color.new(isHL ? hlCol : llCol, 20), textcolor = color.white, size = size.tiny)

var int   structBias = 0
var int   lastBOSx   = na
bosUp = not na(lastPH) and close > lastPH and close[1] <= lastPH and strongOk and allowBull
bosDn = not na(lastPL) and close < lastPL and close[1] >= lastPL and strongOk and allowBear

if bosUp
    structBias := 1
    lastBOSx := bar_index
    if showBOS
        line.new(lastPHx, lastPH, bar_index, lastPH, color = bosCol, style = line.style_dashed, width = 1)
        label.new(bar_index, lastPH, "BOS", style = label.style_label_down, color = color.new(bosCol, 30), textcolor = color.white, size = size.tiny)
if bosDn
    structBias := -1
    lastBOSx := bar_index
    if showBOS
        line.new(lastPLx, lastPL, bar_index, lastPL, color = bosCol, style = line.style_dashed, width = 1)
        label.new(bar_index, lastPL, "BOS", style = label.style_label_up, color = color.new(bosCol, 30), textcolor = color.white, size = size.tiny)

var int lastFVGx = na
bullFVG = low > high[2]
bearFVG = high < low[2]
if showFVG and bullFVG
    box.new(bar_index - 2, low, bar_index, high[2], border_color = color.new(#26a69a, 40), bgcolor = fvgUp, text = "FVG", text_size = size.tiny, text_color = color.new(#26a69a, 0))
if showFVG and bearFVG
    box.new(bar_index - 2, low[2], bar_index, high, border_color = color.new(#ef5350, 40), bgcolor = fvgDn, text = "FVG", text_size = size.tiny, text_color = color.new(#ef5350, 0))
if (bullFVG or bearFVG)
    lastFVGx := bar_index

var int lastSweepx  = na
var int lastSweepDir = 0
sweepHigh = not na(lastPH) and high > lastPH and close < lastPH
sweepLow  = not na(lastPL) and low  < lastPL and close > lastPL
if sweepHigh
    lastSweepx := bar_index
    lastSweepDir := -1
    if showLiq
        label.new(bar_index, high, "✧", style = label.style_label_down, color = color.new(#ef5350, 10), textcolor = color.white, size = size.tiny, tooltip = "Sell-side liquidity sweep")
if sweepLow
    lastSweepx := bar_index
    lastSweepDir := 1
    if showLiq
        label.new(bar_index, low, "✧", style = label.style_label_up, color = color.new(#26a69a, 10), textcolor = color.white, size = size.tiny, tooltip = "Buy-side liquidity sweep")

[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
var line pdhLine = na
var line pdlLine = na
var label pdhLab = na
var label pdlLab = na
if showPD and barstate.islast
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdhLab)
        label.delete(pdhLab)
    if not na(pdlLab)
        label.delete(pdlLab)
    pdhLine := line.new(bar_index - 60, pdh, bar_index + 5, pdh, color = color.new(#131722, 30), style = line.style_dashed, width = 1)
    pdlLine := line.new(bar_index - 60, pdl, bar_index + 5, pdl, color = color.new(#131722, 30), style = line.style_dashed, width = 1)
    pdhLab := label.new(bar_index - 10, pdh, "PDH", style = label.style_none, textcolor = color.new(#131722, 20), size = size.small)
    pdlLab := label.new(bar_index - 10, pdl, "PDL", style = label.style_none, textcolor = color.new(#131722, 20), size = size.small)

swingUp   = not na(lastPHx) and not na(lastPLx) and lastPHx > lastPLx
fibHi     = na(lastPH) ? high : lastPH
fibLo     = na(lastPL) ? low  : lastPL
fibRange  = fibHi - fibLo

g2 = fibHi - fibRange * fib2Val / 100
g1 = fibHi - fibRange * fib1Val / 100
gzTop = math.max(g1, g2)
gzBot = math.min(g1, g2)
extLevel = swingUp ? fibHi + fibRange * extensionV / 100 : fibLo - fibRange * extensionV / 100

inGolden = fibRange > 0 and close <= gzTop and close >= gzBot

var line fibHiL = na
var line fibLoL = na
var line fib2L  = na
var line fib1L  = na
var line fibExtL = na
var label fibHiLab = na
var label fibLoLab = na
var label fib2Lab  = na

if showFib and barstate.islast and fibRange > 0
    if not na(fibHiL)
        line.delete(fibHiL)
    if not na(fibLoL)
        line.delete(fibLoL)
    if not na(fib2L)
        line.delete(fib2L)
    if not na(fib1L)
        line.delete(fib1L)
    if not na(fibExtL)
        line.delete(fibExtL)
    if not na(fibHiLab)
        label.delete(fibHiLab)
    if not na(fibLoLab)
        label.delete(fibLoLab)
    if not na(fib2Lab)
        label.delete(fib2Lab)
    lx = math.min(nz(lastPHx, bar_index - 30), nz(lastPLx, bar_index - 30))
    topV = swingUp ? fibHi : fibLo
    botV = swingUp ? fibLo : fibHi
    fibHiL := line.new(lx, topV, bar_index + 5, topV, color = color.new(#131722, 40), width = 1)
    fibLoL := line.new(lx, botV, bar_index + 5, botV, color = color.new(#131722, 40), width = 1)
    fibHiLab := label.new(bar_index + 6, topV, "1", style = label.style_none, textcolor = color.new(#131722, 20), size = size.small)
    fibLoLab := label.new(bar_index + 6, botV, "0", style = label.style_none, textcolor = color.new(#131722, 20), size = size.small)
    if fib2On
        f2v = fib2Val / 100
        fib2L := line.new(lx, g2, bar_index + 5, g2, color = fibCol, width = 2)
        fib2Lab := label.new(bar_index + 6, g2, str.tostring(showFibPr ? g2 : f2v, showFibPr ? "#.#####" : "#.##"), style = label.style_none, textcolor = fibCol, size = size.small)
    if fib1On
        fib1L := line.new(lx, g1, bar_index + 5, g1, color = color.new(fibCol, 40), style = line.style_dotted, width = 1)
    fibExtL := line.new(lx, extLevel, bar_index + 5, extLevel, color = color.new(#131722, 60), style = line.style_dotted, width = 1)

atrSig   = ta.atr(14)
longSig  = showSig and sweepLow and allowBull
shortSig = showSig and sweepHigh and allowBear

var int   tDir   = 0
var int   tBar   = na
var float tEntry = na
var float tSL    = na
var float tTP1   = na
var float tTP2   = na
var float tTP3   = na

if longSig or shortSig
    tDir   := longSig ? 1 : -1
    tBar   := bar_index
    tEntry := close
    tSL    := longSig ? low - atrSig * slBufAtr : high + atrSig * slBufAtr
    risk    = math.abs(tEntry - tSL)
    tTP1   := tEntry + (longSig ? 1 : -1) * risk * tp1R
    tTP2   := tEntry + (longSig ? 1 : -1) * risk * tp2R
    tTP3   := tEntry + (longSig ? 1 : -1) * risk * tp3R
    label.new(bar_index, longSig ? low : high, longSig ? "BUY" : "SELL", style = longSig ? label.style_label_up : label.style_label_down, color = longSig ? color.new(#26a69a, 0) : color.new(#ef5350, 0), textcolor = color.white, size = size.small)

var line  eLn  = na
var line  slLn = na
var line  t1Ln = na
var line  t2Ln = na
var line  t3Ln = na
var label eLb  = na
var label slLb = na
var label t1Lb = na
var label t2Lb = na
var label t3Lb = na

if showSig and barstate.islast and tDir != 0
    if not na(eLn)
        line.delete(eLn)
    if not na(slLn)
        line.delete(slLn)
    if not na(t1Ln)
        line.delete(t1Ln)
    if not na(t2Ln)
        line.delete(t2Ln)
    if not na(t3Ln)
        line.delete(t3Ln)
    if not na(eLb)
        label.delete(eLb)
    if not na(slLb)
        label.delete(slLb)
    if not na(t1Lb)
        label.delete(t1Lb)
    if not na(t2Lb)
        label.delete(t2Lb)
    if not na(t3Lb)
        label.delete(t3Lb)
    x2 = bar_index + 12
    eLn  := line.new(tBar, tEntry, x2, tEntry, color = color.new(#787b86, 0), style = line.style_solid, width = 2)
    slLn := line.new(tBar, tSL, x2, tSL, color = color.new(#ef5350, 0), style = line.style_solid, width = 2)
    t1Ln := line.new(tBar, tTP1, x2, tTP1, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    t2Ln := line.new(tBar, tTP2, x2, tTP2, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    t3Ln := line.new(tBar, tTP3, x2, tTP3, color = color.new(#26a69a, 0), style = line.style_dashed, width = 2)
    eLb  := label.new(x2, tEntry, "Entry " + str.tostring(tEntry, format.mintick), style = label.style_label_left, color = color.new(#787b86, 20), textcolor = color.white, size = size.small)
    slLb := label.new(x2, tSL, "SL " + str.tostring(tSL, format.mintick), style = label.style_label_left, color = color.new(#ef5350, 20), textcolor = color.white, size = size.small)
    t1Lb := label.new(x2, tTP1, "TP1 " + str.tostring(tTP1, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)
    t2Lb := label.new(x2, tTP2, "TP2 " + str.tostring(tTP2, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)
    t3Lb := label.new(x2, tTP3, "TP3 " + str.tostring(tTP3, format.mintick), style = label.style_label_left, color = color.new(#26a69a, 20), textcolor = color.white, size = size.small)

alertcondition(longSig, "Buy reversal", "Buy reversal signal")
alertcondition(shortSig, "Sell reversal", "Sell reversal signal")

[htfClose, htfMA, htfHi, htfLo] = request.security(syminfo.tickerid, htfTF, [close, ta.sma(close, 50), ta.highest(high, 20), ta.lowest(low, 20)], lookahead = barmerge.lookahead_off)
htfBull  = htfClose > htfMA
htfMid   = (htfHi + htfLo) / 2
isPremium = close > htfMid

htfAlign = (structBias > 0 and htfBull) or (structBias < 0 and not htfBull)

recWin = 30
cHTF = ckHTF and htfAlign
cBOS = ckBOS and not na(lastBOSx) and (bar_index - lastBOSx <= recWin)
cLiq = ckLiq and not na(lastSweepx) and (bar_index - lastSweepx <= recWin)
cFVG = ckFVG and not na(lastFVGx) and (bar_index - lastFVGx <= recWin)

n25(b) => b ? 25 : 0
tradeScore = n25(cHTF) + n25(cBOS) + n25(cLiq) + n25(cFVG)
dirBuy = structBias >= 0
dirStr = dirBuy ? "BUY" : "SELL"

atr14    = ta.atr(14)
pipSize  = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
stopDist = atr14 * stopAtrMult
stopPips = pipSize > 0 ? stopDist / pipSize : na
lots     = (stopPips > 0 and pipValue > 0) ? riskUSD / (stopPips * pipValue) : na

f_scan(sym) =>
    [c, ma, atr, hi, lo] = request.security(sym, htfTF, [close, ta.sma(close, scanMaLen), ta.atr(14), ta.highest(high, 20), ta.lowest(low, 20)], lookahead = barmerge.lookahead_off)
    bull = c > ma
    strength = atr > 0 ? math.abs(c - ma) / atr : 0
    sc = strength >= 1.0 ? 100 : 75
    [bull ? "BUY" : "SELL", sc]

[d1, sc1] = f_scan(s1)
[d2, sc2] = f_scan(s2)
[d3, sc3] = f_scan(s3)
[d4, sc4] = f_scan(s4)
[d5, sc5] = f_scan(s5)
[d6, sc6] = f_scan(s6)
[d7, sc7] = f_scan(s7)
[d8, sc8] = f_scan(s8)
[d9, sc9] = f_scan(s9)

f_pos(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

GOLD    = color.new(#c9a227, 0)
INK     = color.new(#131722, 0)
CLEAR   = color.new(color.white, 100)
TEAL    = color.new(#26a69a, 0)
TEALROW = color.new(#8fd0c6, 35)
RED     = color.new(#ef5350, 15)

check(b) => b ? "✅" : ""

var table panel = table.new(f_pos(panelPos), 2, 8, bgcolor = CLEAR, border_color = GOLD, border_width = 1, frame_color = GOLD, frame_width = 1)
var table scan  = table.new(position.bottom_left, 3, 10, bgcolor = CLEAR, border_color = GOLD, border_width = 1, frame_color = GOLD, frame_width = 1)
var table lot   = table.new(position.bottom_right, 2, 4, bgcolor = CLEAR, border_color = GOLD, border_width = 1, frame_color = GOLD, frame_width = 1)

sym_short(s) =>
    p = str.pos(s, ":")
    na(p) ? s : str.substring(s, p + 1)

if barstate.islast
    if showPanel
        table.cell(panel, 0, 0, "[TF]", text_color = INK, text_size = size.small)
        table.cell(panel, 1, 0, panelTitle, text_color = INK, text_size = size.small)
        table.cell(panel, 0, 1, htfTF, text_color = INK, text_size = size.small)
        table.cell(panel, 1, 1, isPremium ? "Premium" : "Discount", text_color = isPremium ? INK : color.white, bgcolor = isPremium ? RED : TEAL, text_size = size.small)
        table.cell(panel, 0, 2, dirStr, text_color = INK, text_size = size.small)
        table.cell(panel, 1, 2, "Checklist 📝", text_color = INK, text_size = size.small)
        table.cell(panel, 0, 3, check(cHTF), text_size = size.small)
        table.cell(panel, 1, 3, "HTF Alignment", text_color = INK, text_size = size.small)
        table.cell(panel, 0, 4, check(cBOS), text_size = size.small)
        table.cell(panel, 1, 4, "Break of Structure", text_color = INK, text_size = size.small)
        table.cell(panel, 0, 5, check(cLiq), text_size = size.small)
        table.cell(panel, 1, 5, "Liquidity Sweep", text_color = INK, text_size = size.small)
        table.cell(panel, 0, 6, check(cFVG), text_size = size.small)
        table.cell(panel, 1, 6, "Imbalance", text_color = INK, text_size = size.small)
        table.cell(panel, 0, 7, str.tostring(tradeScore), text_color = INK, text_size = size.small)
        table.cell(panel, 1, 7, "Trade Score", text_color = INK, text_size = size.small)

    if showScan
        table.cell(scan, 0, 0, "CP Scanner 🐂", text_color = INK, text_size = size.small)
        table.cell(scan, 1, 0, "Dir", text_color = INK, text_size = size.small)
        table.cell(scan, 2, 0, "Score", text_color = INK, text_size = size.small)
        syms  = array.from(s1, s2, s3, s4, s5, s6, s7, s8, s9)
        dirs  = array.from(d1, d2, d3, d4, d5, d6, d7, d8, d9)
        scrs  = array.from(sc1, sc2, sc3, sc4, sc5, sc6, sc7, sc8, sc9)
        for i = 0 to 8
            r = i + 1
            di = array.get(dirs, i)
            si = array.get(scrs, i)
            hot = si == 100
            rowBg = hot ? TEALROW : CLEAR
            star = hot ? " ⭐" : ""
            table.cell(scan, 0, r, sym_short(array.get(syms, i)), text_color = INK, bgcolor = rowBg, text_size = size.small)
            table.cell(scan, 1, r, di, text_color = INK, bgcolor = rowBg, text_size = size.small)
            table.cell(scan, 2, r, str.tostring(si) + star, text_color = INK, bgcolor = rowBg, text_size = size.small)

    if showLot
        table.cell(lot, 0, 0, "Auto Lot 📐", text_color = INK, text_size = size.small)
        table.cell(lot, 1, 0, "", text_size = size.small)
        table.merge_cells(lot, 0, 0, 1, 0)
        table.cell(lot, 0, 1, str.tostring(na(lots) ? 0 : lots, "#.##"), text_color = INK, text_size = size.small)
        table.cell(lot, 1, 1, "Lots", text_color = INK, text_size = size.small)
        table.cell(lot, 0, 2, str.tostring(na(stopPips) ? 0 : stopPips, "#.#") + " pips", text_color = INK, text_size = size.small)
        table.cell(lot, 1, 2, "Stop", text_color = INK, text_size = size.small)
        table.cell(lot, 0, 3, str.tostring(riskUSD, "#") + " USD", text_color = INK, text_size = size.small)
        table.cell(lot, 1, 3, "Risk", text_color = INK, text_size = size.small)

plot(na, "anchor", display = display.none)
````
