# YES RSI + BB Sniper

- url: https://www.tradingview.com/script/CUOvI39g-YES-RSI-BB-Sniper/
- type: indicator
- pine_id: PUB;d10c52ac4fd7416e9f3c42c69b9d47f3
- version: 2.0

## Description

YES RSI + BB Sniper — Mean-Reversion Setup Tool with Auto Entry/SL/Targets
What it does:
This indicator combines RSI and Bollinger Bands to identify mean-reversion setups, then automatically plots a complete trade plan — Entry, Stop Loss, and three Targets — with a live dashboard tracking every level.
Signal Logic:

LONG: Price tags the lower Bollinger Band AND RSI crosses back above the oversold level (default 30) — exhaustion + momentum shift confirmation
SHORT: Price tags the upper band AND RSI crosses back below overbought (default 70)
Optional EMA-200 trend filter to trade only with the larger trend

Auto Trade Levels:

Entry: Signal candle close
Stop Loss: Beyond the band/swing extreme with an ATR-based buffer (adjustable)
Target 1: BB Basis (the mean — natural magnet in mean-reversion), minimum 1R
Target 2: Opposite band, minimum 2R
Target 3: Configurable Risk:Reward runner (default 1:3)

Dashboard shows: Signal status with bar count, RSI value, %B, Bandwidth (squeeze detection below 4%), trend direction, all trade levels with real-time hit-tracking (✔/✖), and Risk:Reward ratios.
Alerts: Built-in alert conditions for both LONG and SHORT setups.
How to use: Works best on Daily and 1H timeframes for swing trades. Wait for the signal candle to close, verify the R:R on the dashboard suits your plan, and always size positions according to your risk management.
This is an educational tool, not financial advice. Always do your own analysis before trading.

## Source Code

````pine
//@version=6
// ============================================================================
//  YES RSI + BB SNIPER  —  by YES STOCK MARKET   (v1.3)
//  v1.3 : SL hit → target labels removed | Target hit → SL + lower target labels removed
//         No duplicate BUY/SELL while trade open | "SL HIT" / "✔ T HIT" markers on chart
//         T3 always placed beyond T2
//  Strategy logic : Mean-Reversion
//    LONG  : Price tags LOWER Bollinger Band + RSI exits OVERSOLD (cross above 30)
//    SHORT : Price tags UPPER Bollinger Band + RSI exits OVERBOUGHT (cross below 70)
//  Auto-plots      : Entry, Stop Loss, Target 1 (BB Basis), Target 2 (Opp. Band),
//                    Target 3 (R:R based)
//  Dashboard       : RSI, %B, Bandwidth, Trend, live trade levels & hit status
//  Educational tool only — not investment advice.
// ============================================================================
indicator("YES RSI + BB Sniper [YES STOCK MARKET]", shorttitle = "YES RSI-BB",
     overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─────────────────────────── INPUTS ───────────────────────────
grpR  = "① RSI Settings"
rsiLen  = input.int(14, "RSI Length",            minval = 2,  group = grpR)
rsiOB   = input.int(70, "Overbought Level",      minval = 50, group = grpR)
rsiOS   = input.int(30, "Oversold Level",        maxval = 50, group = grpR)

grpB  = "② Bollinger Band Settings"
bbLen   = input.int(20,    "BB Length",          minval = 5,  group = grpB)
bbMult  = input.float(2.0, "BB StdDev Multiplier", step = 0.1, group = grpB)

grpT  = "③ Trade Setup (Entry / SL / Targets)"
atrLen    = input.int(14,    "ATR Length (for SL buffer)",       group = grpT)
slBuf     = input.float(0.5, "SL Buffer  =  ATR ×", step = 0.25, group = grpT)
t3RR      = input.float(3.0, "Target-3 Risk:Reward", step = 0.5, group = grpT)
useTrendF = input.bool(false, "Trend Filter → Long only above EMA-200, Short only below", group = grpT)
oneTrade  = input.bool(true,  "No new signal while a trade is open (wait for SL / T3)", group = grpT)
showHits  = input.bool(true,  "Show SL HIT / Target HIT markers on chart", group = grpT)

grpD  = "④ Dashboard"
showDash = input.bool(true,        "Show Dashboard",  group = grpD)
dashPosS = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = grpD)
dashSzS  = input.string("Normal",    "Size",     options = ["Tiny","Small","Normal","Large"], group = grpD)

// ─────────────────────────── CALCULATIONS ───────────────────────────
rsiV   = ta.rsi(close, rsiLen)
basis  = ta.sma(close, bbLen)
dev    = bbMult * ta.stdev(close, bbLen)
upperB = basis + dev
lowerB = basis - dev
pctB   = (close - lowerB) / math.max(upperB - lowerB, syminfo.mintick)
bandW  = (upperB - lowerB) / basis * 100
atrV   = ta.atr(atrLen)
ema200 = ta.ema(close, 200)

// Band-tag conditions (current or previous bar touched the band)
tagLow  = low  <= lowerB  or low[1]  <= lowerB[1]
tagHigh = high >= upperB  or high[1] >= upperB[1]

// Trend filter
longOK  = not useTrendF or close > ema200
shortOK = not useTrendF or close < ema200

// ─────────────────────────── SIGNALS ───────────────────────────
rawBuy  = ta.crossover(rsiV,  rsiOS) and tagLow  and longOK
rawSell = ta.crossunder(rsiV, rsiOB) and tagHigh and shortOK

// ─────────────────────────── BRAND COLORS ───────────────────────────
cAmber = color.new(#FF8A1E, 0)
cGreen = color.new(#35E0A1, 0)
cRed   = color.new(#FF5A5A, 0)
cTeal  = color.new(#4DD0E1, 0)
cBgHdr = color.new(#0E1626, 0)
cBgRow = color.new(#101B2E, 15)
cTxt   = color.new(#EAF0F8, 0)
cMut   = color.new(#8A97AB, 0)

// ─────────────────────────── TRADE STATE ───────────────────────────
var int   dir     = 0        //  1 = long setup active, -1 = short, 0 = none
var int   sigBar  = na
var float entryP  = na
var float slP     = na
var float t1P     = na
var float t2P     = na
var float t3P     = na
var bool  t1Hit   = false
var bool  t2Hit   = false
var bool  t3Hit   = false
var bool  slHit   = false

// line / label handles (only latest setup is drawn)
var line  lnEntry = na
var line  lnSL    = na
var line  lnT1    = na
var line  lnT2    = na
var line  lnT3    = na
var label lbEntry = na
var label lbSL    = na
var label lbT1    = na
var label lbT2    = na
var label lbT3    = na

// ── Filter signals: skip new BUY/SELL while previous trade still open ──
tradeOpen  = dir != 0 and not slHit and not t3Hit
buySignal  = rawBuy  and (not oneTrade or not tradeOpen)
sellSignal = rawSell and (not oneTrade or not tradeOpen)

// ─────────────────────────── SETUP LOGIC ───────────────────────────
// ── New LONG setup : set state values ──
if buySignal
    dir    := 1
    sigBar := bar_index
    entryP := close
    slP    := math.min(low, lowerB) - atrV * slBuf
    riskL   = entryP - slP
    t1P    := math.max(basis,  entryP + riskL * 1.0)     // mean-reversion → basis
    t2P    := math.max(upperB, entryP + riskL * 2.0)     // opposite band
    t3P    := math.max(entryP + riskL * t3RR, t2P + riskL)  // runner target (always beyond T2)
    t1Hit  := false
    t2Hit  := false
    t3Hit  := false
    slHit  := false

// ── New SHORT setup : set state values ──
if sellSignal
    dir    := -1
    sigBar := bar_index
    entryP := close
    slP    := math.max(high, upperB) + atrV * slBuf
    riskS   = slP - entryP
    t1P    := math.min(basis,  entryP - riskS * 1.0)
    t2P    := math.min(lowerB, entryP - riskS * 2.0)
    t3P    := math.min(entryP - riskS * t3RR, t2P - riskS)  // always beyond T2
    t1Hit  := false
    t2Hit  := false
    t3Hit  := false
    slHit  := false

// ── Draw levels for the new setup (inline — no function needed) ──
if buySignal or sellSignal
    // wipe previous drawings
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)
    label.delete(lbEntry)
    label.delete(lbSL)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbT3)
    // draw new levels
    x1 = bar_index
    x2 = bar_index + 25
    lnEntry := line.new(x1, entryP, x2, entryP, color = cAmber, width = 2)
    lnSL    := line.new(x1, slP,    x2, slP,    color = cRed,   width = 2, style = line.style_dashed)
    lnT1    := line.new(x1, t1P,    x2, t1P,    color = cGreen, width = 1, style = line.style_dotted)
    lnT2    := line.new(x1, t2P,    x2, t2P,    color = cGreen, width = 1, style = line.style_dotted)
    lnT3    := line.new(x1, t3P,    x2, t3P,    color = cTeal,  width = 1, style = line.style_dotted)
    lbEntry := label.new(x2, entryP, "ENTRY  " + str.tostring(entryP, format.mintick), style = label.style_label_left, color = cAmber, textcolor = color.black, size = size.small)
    lbSL    := label.new(x2, slP,    "SL  "    + str.tostring(slP,    format.mintick), style = label.style_label_left, color = cRed,   textcolor = color.white, size = size.small)
    lbT1    := label.new(x2, t1P,    "T1  "    + str.tostring(t1P,    format.mintick), style = label.style_label_left, color = cGreen, textcolor = color.black, size = size.small)
    lbT2    := label.new(x2, t2P,    "T2  "    + str.tostring(t2P,    format.mintick), style = label.style_label_left, color = cGreen, textcolor = color.black, size = size.small)
    lbT3    := label.new(x2, t3P,    "T3  "    + str.tostring(t3P,    format.mintick), style = label.style_label_left, color = cTeal,  textcolor = color.black, size = size.small)

// ── Track hit status (from the bar AFTER the signal; stops once SL or T3 is hit) ──
bool newSL  = false
int  newTgt = 0          // highest target newly hit on this bar (0 = none)
if dir != 0 and bar_index > sigBar and not slHit and not t3Hit
    slNow = dir == 1 ? low  <= slP : high >= slP
    h1    = dir == 1 ? high >= t1P : low  <= t1P
    h2    = dir == 1 ? high >= t2P : low  <= t2P
    h3    = dir == 1 ? high >= t3P : low  <= t3P
    if slNow                           // SL gets priority if both touch on same bar
        slHit := true
        newSL := true
    else
        if h1 and not t1Hit
            t1Hit  := true
            newTgt := 1
        if h2 and not t2Hit
            t2Hit  := true
            newTgt := 2
        if h3 and not t3Hit
            t3Hit  := true
            newTgt := 3

// ── Permanent markers on the candle where SL / Target is hit ──
if showHits and newSL
    label.new(bar_index, dir == 1 ? low : high, "SL HIT",
         style = dir == 1 ? label.style_label_up : label.style_label_down,
         color = cRed, textcolor = color.white, size = size.small)
if showHits and newTgt > 0
    label.new(bar_index, dir == 1 ? high : low, "✔ T" + str.tostring(newTgt) + " HIT",
         style = dir == 1 ? label.style_label_down : label.style_label_up,
         color = newTgt == 3 ? cTeal : cGreen, textcolor = color.black, size = size.small)

// ── Clean up labels on hit ──
xLbl = sigBar + 25
// SL HIT → remove all target lines/labels, show "SL HIT"
if newSL
    line.delete(lnT1)
    line.delete(lnT2)
    line.delete(lnT3)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbT3)
    line.delete(lnSL)
    label.delete(lbSL)
    lnSL := line.new(sigBar, slP, xLbl, slP, color = cRed, width = 2, style = line.style_dashed)
    lbSL := label.new(xLbl, slP, "✖ SL HIT  " + str.tostring(slP, format.mintick), style = label.style_label_left, color = cRed, textcolor = color.white, size = size.small)

// TARGET HIT → remove SL line/label + earlier targets, mark hit target
if newTgt > 0
    line.delete(lnSL)
    label.delete(lbSL)
    if newTgt >= 2
        line.delete(lnT1)
        label.delete(lbT1)
    if newTgt >= 3
        line.delete(lnT2)
        label.delete(lbT2)
    if newTgt == 1
        label.set_text(lbT1, "✔ T1 HIT  " + str.tostring(t1P, format.mintick))
    if newTgt == 2
        label.set_text(lbT2, "✔ T2 HIT  " + str.tostring(t2P, format.mintick))
    if newTgt == 3
        label.set_text(lbT3, "✔ T3 HIT  " + str.tostring(t3P, format.mintick))

// ─────────────────────────── PLOTS ───────────────────────────
pU = plot(upperB, "BB Upper", color = color.new(#FF8A1E, 55))
pB = plot(basis,  "BB Basis", color = color.new(#8A97AB, 30), linewidth = 1)
pL = plot(lowerB, "BB Lower", color = color.new(#FF8A1E, 55))
fill(pU, pL, color = color.new(#FF8A1E, 93), title = "BB Fill")
plot(useTrendF ? ema200 : na, "EMA 200", color = color.new(#4DD0E1, 30), linewidth = 2)

plotshape(buySignal,  "BUY",  shape.triangleup,   location.belowbar, cGreen, size = size.small, text = "BUY",  textcolor = cGreen)
plotshape(sellSignal, "SELL", shape.triangledown, location.abovebar, cRed,   size = size.small, text = "SELL", textcolor = cRed)

// RSI zone background hint (subtle)
bgcolor(rsiV <= rsiOS ? color.new(#35E0A1, 92) : rsiV >= rsiOB ? color.new(#FF5A5A, 92) : na)

// ─────────────────────────── DASHBOARD ───────────────────────────
dashPos = dashPosS == "Top Right"     ? position.top_right     :
          dashPosS == "Top Left"      ? position.top_left      :
          dashPosS == "Bottom Right"  ? position.bottom_right  :
          dashPosS == "Bottom Left"   ? position.bottom_left   : position.middle_right
dashSz  = dashSzS == "Tiny" ? size.tiny : dashSzS == "Small" ? size.small : dashSzS == "Large" ? size.large : size.normal

// helper reads globals but modifies nothing global → allowed
f_row(_tbl, _r, _k, _v, _vc, _sz) =>
    table.cell(_tbl, 0, _r, _k, text_color = cMut, text_size = _sz, text_halign = text.align_left,  bgcolor = cBgRow)
    table.cell(_tbl, 1, _r, _v, text_color = _vc,  text_size = _sz, text_halign = text.align_right, bgcolor = cBgRow)

var table dash = table.new(dashPos, 2, 13, bgcolor = cBgRow, border_width = 1, border_color = color.new(#1E2A40, 0))

if showDash and barstate.islast
    // header
    table.cell(dash, 0, 0, "⚡ YES RSI-BB SNIPER", text_color = cAmber, text_size = dashSz, bgcolor = cBgHdr, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker,          text_color = cTxt,  text_size = dashSz, bgcolor = cBgHdr, text_halign = text.align_right)

    // signal row
    sigTxt = dir ==  1 ? "LONG  (" + str.tostring(bar_index - sigBar) + " bars ago)" :
             dir == -1 ? "SHORT (" + str.tostring(bar_index - sigBar) + " bars ago)" : "WAIT — no setup"
    sigCol = dir == 1 ? cGreen : dir == -1 ? cRed : cMut
    f_row(dash, 1, "SIGNAL", sigTxt, sigCol, dashSz)

    // indicator rows
    rsiCol = rsiV >= rsiOB ? cRed : rsiV <= rsiOS ? cGreen : cTxt
    f_row(dash, 2, "RSI (" + str.tostring(rsiLen) + ")", str.tostring(rsiV, "#.##"), rsiCol, dashSz)
    f_row(dash, 3, "%B",        str.tostring(pctB * 100, "#.#") + " %", pctB > 1 ? cRed : pctB < 0 ? cGreen : cTxt, dashSz)
    f_row(dash, 4, "Bandwidth", str.tostring(bandW, "#.##") + " %", bandW < 4 ? cAmber : cTxt, dashSz)   // squeeze hint
    trendTxt = close > ema200 and basis > basis[3] ? "UP ▲"   :
               close < ema200 and basis < basis[3] ? "DOWN ▼" : "SIDEWAYS ◆"
    trendCol = close > ema200 ? cGreen : close < ema200 ? cRed : cMut
    f_row(dash, 5, "Trend (EMA200)", trendTxt, trendCol, dashSz)

    // trade rows
    f_row(dash, 6,  "ENTRY", dir != 0 ? str.tostring(entryP, format.mintick) : "—", cAmber, dashSz)
    f_row(dash, 7,  "STOP LOSS" + (slHit ? "  ✖ HIT" : ""), dir != 0 ? str.tostring(slP, format.mintick) : "—", cRed, dashSz)
    f_row(dash, 8,  "TARGET 1" + (t1Hit ? "  ✔" : ""), dir != 0 ? str.tostring(t1P, format.mintick) : "—", cGreen, dashSz)
    f_row(dash, 9,  "TARGET 2" + (t2Hit ? "  ✔" : ""), dir != 0 ? str.tostring(t2P, format.mintick) : "—", cGreen, dashSz)
    f_row(dash, 10, "TARGET 3" + (t3Hit ? "  ✔" : ""), dir != 0 ? str.tostring(t3P, format.mintick) : "—", cTeal, dashSz)

    riskPts = dir != 0 ? math.abs(entryP - slP) : na
    rrT1    = dir != 0 ? math.abs(t1P - entryP) / riskPts : na
    rrT3    = dir != 0 ? math.abs(t3P - entryP) / riskPts : na
    rrTxt   = dir != 0 ? str.tostring(riskPts, format.mintick) + "  |  T1 1:" + str.tostring(rrT1, "#.#") + "  T3 1:" + str.tostring(rrT3, "#.#") : "—"
    f_row(dash, 11, "Risk / R:R", rrTxt, cTxt, dashSz)
    f_row(dash, 12, "yesstockmarket.com", "Educational only", cMut, dashSz)

// ─────────────────────────── ALERTS ───────────────────────────
alertcondition(buySignal,  "YES RSI-BB • LONG Setup",  "YES RSI-BB Sniper: LONG setup on {{ticker}} @ {{close}} — check dashboard for Entry/SL/Targets")
alertcondition(sellSignal, "YES RSI-BB • SHORT Setup", "YES RSI-BB Sniper: SHORT setup on {{ticker}} @ {{close}} — check dashboard for Entry/SL/Targets")
````
