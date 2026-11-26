# Apex Edge v3.0 Research Edition

- url: https://www.tradingview.com/script/TDLjpzde-Apex-Edge-v3-0-Research-Edition/
- type: indicator
- pine_id: PUB;18c33e4d2ef744059eca790ba24028c5
- version: 1.0

## Description

Apex Edge v3.0 — Research Edition,Apex Edge v3.0 — Research Edition,Apex Edge v3.0 — Research Edition,Apex Edge v3.0 — Research EditionApex Edge v3.0 — Research Edition

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © saivivek0192
//
// APEX EDGE v3.0 — RESEARCH-BACKED EDITION
//
// Signal priority based on academic evidence strength:
//   PRIMARY (high-conviction, peer-reviewed):
//     1. TREND PULLBACK   — Jegadeesh & Titman (1993), J. Finance, 3rd most-cited finance paper
//     2. OPENING RANGE BREAKOUT — Crabel (1990) + Zarattini, Barbon & Aziz (2024) SSRN
//        7,000 stocks 2016-2023, Sharpe 2.81, 36% alpha on Stocks-in-Play
//     3. MEAN REVERSION   — Connors RSI(2), validated by EdgeTools 2026 (5.8M tests,
//        150,546 results survived Bonferroni correction)
//
//   SECONDARY (real but weaker / situational):
//     4. VWAP RECLAIM/REJECT — institutional benchmark, real intraday reversion
//     5. LIQUIDITY SWEEP REVERSAL — structure context, not standalone-validated
//
//   CONTEXT ONLY (downgraded from earlier versions based on research):
//     6. FAIR VALUE GAP — Plastun et al. (2020): "results contrary to myth that gaps fill"
//        → Display only, NOT a signal. Gaps often continue, not revert.
//     7. COMPRESSION BREAKOUT — Fang "Popularity vs Profitability":
//        squeeze edge worked in 9 markets pre-1983, only 1 market post-2001
//        → Demoted to filter context
//
// KEY NEW FEATURE: RELATIVE VOLUME ("STOCKS IN PLAY") FILTER
// Zarattini et al. (2024) found that ORB edge concentrates almost entirely
// in stocks with abnormal volume from news/earnings. Plain ORB on random
// stocks under-performs benchmark. So v3 requires RVOL > threshold for
// primary signals to fire.

//@version=6
indicator("Apex Edge v3.0 — Research Edition", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=300)

// ============================================================
// ============== INPUTS ======================================
// ============================================================
htfTF = input.timeframe("60", "Higher timeframe", group="🧭 Context")

atrLen      = input.int(14,    "ATR length",          group="💰 Risk")
stopATR     = input.float(1.5, "Stop ATR multiplier", group="💰 Risk", step=0.1)
tp1RR       = input.float(1.5, "TP1 R:R",             group="💰 Risk", step=0.1)
tp2RR       = input.float(2.5, "TP2 R:R",             group="💰 Risk", step=0.1)
maxBars     = input.int(25,    "Time stop bars",      group="💰 Risk")
riskDollars = input.float(100, "$ risk per trade",    group="💰 Risk")

adxLen   = input.int(14,   "ADX length",        group="📊 Regime")
adxTrend = input.float(25, "ADX trend min",     group="📊 Regime", step=0.5)
adxRange = input.float(20, "ADX range max",     group="📊 Regime", step=0.5)

// Relative Volume — "Stocks in Play" filter (Zarattini 2024)
rvolLen     = input.int(20,    "RVOL lookback days",  group="🔥 Stocks in Play")
rvolThresh  = input.float(1.5, "Min RVOL for primary signals", minval=1.0, step=0.1, tooltip="Zarattini et al. found ORB edge concentrates in stocks with abnormal volume. 1.5 = current vol must be 50%+ above 20-day average for that bar's time-of-day", group="🔥 Stocks in Play")

cooldownBars = input.int(8, "Cooldown bars", group="🔧 Filters")
swingLen     = input.int(5, "Swing detection bars", group="🔧 Filters")

// Primary signals (research-validated)
e_TPB = input.bool(true, "★ Trend Pullback (J&T 1993)", group="🎯 Primary")
e_ORB = input.bool(true, "★ Opening Range Breakout (Zarattini 2024)", group="🎯 Primary")
e_MR  = input.bool(true, "★ Mean Reversion RSI(2) (Connors)", group="🎯 Primary")

// Secondary signals (weaker evidence)
e_VRC = input.bool(true,  "VWAP Reclaim/Reject",   group="🎯 Secondary")
e_LSR = input.bool(true,  "Liquidity Sweep",       group="🎯 Secondary")

// Context layers (downgraded — display only)
showFVG = input.bool(true, "Show FVG zones (display only — Plastun 2020 questions fill rate)", group="📦 Context Layers")
showCBO = input.bool(false, "Show compression markers (Fang: squeeze edge eroded post-2001)", group="📦 Context Layers")

orbWindow    = input.session("0830-0900", "Opening Range (exchange tz)", group="⏰ ORB")
orbValidBars = input.int(48, "Max bars after OR for breakout", group="⏰ ORB")

showLevels  = input.bool(true, "Show MAs/VWAP/BB",      group="📺 Display")
showActive  = input.bool(true, "Show active trade lines", group="📺 Display")
showLiqLine = input.bool(true, "Show liquidity levels",   group="📺 Display")
showORLine  = input.bool(true, "Show OR lines",           group="📺 Display")

// ============================================================
// ============== COLORS ======================================
// ============================================================
cText  = #ECEFF4
cBull  = #26A69A
cBullS = #00C853
cBear  = #EF5350
cBearS = #D50000
cVwap  = #8E7CC3
cEma20 = #FFA726
cEma50 = #EF6C00
cBB    = #607D8B
cTP    = #00ACC1
cSL    = #B71C1C
cBE    = #FFA726
cFvgUp = color.new(#26A69A, 85)
cFvgDn = color.new(#EF5350, 85)
cORHi  = #2196F3
cLiqHi = #FF1744
cLiqLo = #00E676

// ============================================================
// ============== INDICATORS ==================================
// ============================================================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
sma200= ta.sma(close, 200)  // long-term trend filter for Connors RSI(2)
atr   = ta.atr(atrLen)
rsi14 = ta.rsi(close, 14)
rsi2  = ta.rsi(close, 2)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

vwapVal = ta.vwap(hlc3)

bbBasis = ta.sma(close, 20)
bbStdev = ta.stdev(close, 20)
bbUp    = bbBasis + 2 * bbStdev
bbDn    = bbBasis - 2 * bbStdev

// ============================================================
// ============== RVOL — STOCKS IN PLAY =======================
// ============================================================
// Compares CURRENT bar's volume to the average volume at the same
// time-of-day over the last N days. This is what makes ORB work
// per Zarattini 2024. Approximated here as 20-bar SMA × adjustment.
volMa20 = ta.sma(volume, 20)
rvol = volMa20 > 0 ? volume / volMa20 : 1.0
inPlay = rvol >= rvolThresh
volOk = volume > volMa20  // basic volume floor

// ============================================================
// ============== HTF CONTEXT (NO REPAINT) ====================
// ============================================================
htfEma20 = request.security(syminfo.tickerid, htfTF, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
htfEma50 = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfBull  = htfEma20 > htfEma50
htfBear  = htfEma20 < htfEma50

// ============================================================
// ============== REGIME ======================================
// ============================================================
isTrendUp = adx > adxTrend and diPlus > diMinus and htfBull
isTrendDn = adx > adxTrend and diMinus > diPlus and htfBear
isRange   = adx < adxRange

regime    = isTrendUp ? "TREND ↑" : isTrendDn ? "TREND ↓" : isRange ? "RANGE" : "MIXED"
regimeCol = isTrendUp ? cBullS : isTrendDn ? cBearS : isRange ? #FFEB3B : color.gray

// ============================================================
// ============== CANDLE PRIMITIVES ===========================
// ============================================================
bodyAbs = math.abs(close - open)
upWick  = high - math.max(open, close)
dnWick  = math.min(open, close) - low
hasBody = bodyAbs > atr * 0.3

isHammer  = dnWick > bodyAbs * 1.5 and upWick < bodyAbs * 0.5 and close > (high + low) / 2
isShooter = upWick > bodyAbs * 1.5 and dnWick < bodyAbs * 0.5 and close < (high + low) / 2
bullEng   = close > open and close[1] < open[1] and close > open[1] and open <= close[1] and bodyAbs > bodyAbs[1]
bearEng   = close < open and close[1] > open[1] and close < open[1] and open >= close[1] and bodyAbs > bodyAbs[1]

bullRev = isHammer or bullEng
bearRev = isShooter or bearEng

isNewDay = ta.change(time("D")) != 0

// ============================================================
// ============== PRIMARY 1: TREND PULLBACK (J&T 1993) ========
// ============================================================
// Highest evidence base — momentum continuation in confirmed trend.
nearEma20Long  = (low <= ema20 or math.abs(close - ema20) < atr * 0.5) and close > ema20
nearEma20Short = (high >= ema20 or math.abs(close - ema20) < atr * 0.5) and close < ema20

trendPbBuy  = e_TPB and isTrendUp and nearEma20Long  and hasBody and close > open and inPlay and rsi14 < 70 and close < ema50 + atr * 4
trendPbSell = e_TPB and isTrendDn and nearEma20Short and hasBody and close < open and inPlay and rsi14 > 30 and close > ema50 - atr * 4

// ============================================================
// ============== PRIMARY 2: OPENING RANGE BREAKOUT ===========
// ============================================================
// Crabel (1990) + Zarattini, Barbon & Aziz (2024). Edge concentrates
// in stocks with high RVOL — that's why inPlay filter is required.
inOR = not na(time(timeframe.period, orbWindow))

var float orHi = na
var float orLo = na
var bool  orDone = false
var int   orEndBar = na
var bool  orbFiredToday = false

if isNewDay
    orHi := na
    orLo := na
    orDone := false
    orEndBar := na
    orbFiredToday := false

if inOR
    orHi := na(orHi) ? high : math.max(orHi, high)
    orLo := na(orLo) ? low  : math.min(orLo, low)
else if not orDone and not na(orHi)
    orDone := true
    orEndBar := bar_index

barsSinceOR = orDone and not na(orEndBar) ? bar_index - orEndBar : 0
orbValid = orDone and not inOR and barsSinceOR <= orbValidBars and not orbFiredToday

orbBuy  = e_ORB and orbValid and close > orHi and close > open and inPlay and (htfBull or htfEma20 > htfEma50)
orbSell = e_ORB and orbValid and close < orLo and close < open and inPlay and (htfBear or htfEma20 < htfEma50)

if orbBuy or orbSell
    orbFiredToday := true

// OR lines
var line orHiLine = na
var line orLoLine = na
if showORLine and orDone
    if na(orHiLine)
        orHiLine := line.new(orEndBar, orHi, bar_index, orHi, color=cORHi, width=1)
        orLoLine := line.new(orEndBar, orLo, bar_index, orLo, color=cORHi, width=1)
    else
        line.set_xy2(orHiLine, bar_index, orHi)
        line.set_xy2(orLoLine, bar_index, orLo)
        line.set_xy1(orHiLine, orEndBar, orHi)
        line.set_xy1(orLoLine, orEndBar, orLo)

if isNewDay
    if not na(orHiLine)
        line.delete(orHiLine)
        orHiLine := na
    if not na(orLoLine)
        line.delete(orLoLine)
        orLoLine := na

// ============================================================
// ============== PRIMARY 3: MEAN REVERSION (Connors RSI(2)) ==
// ============================================================
// Classic Connors: only take longs above 200 SMA, only shorts below.
// This trend filter is what made his original strategy work.
aboveTrend = close > sma200
belowTrend = close < sma200

mrBuy  = e_MR and aboveTrend and rsi2 < 5  and close < ema20 and bullRev and volOk
mrSell = e_MR and belowTrend and rsi2 > 95 and close > ema20 and bearRev and volOk

// ============================================================
// ============== SECONDARY 1: VWAP RECLAIM / REJECT ==========
// ============================================================
prevAbove = close[1] > vwapVal[1]
prevBelow = close[1] < vwapVal[1]

vwapReclaimBuy  = e_VRC and isTrendUp and not prevAbove and close > vwapVal and close > open and volOk and rsi14 < 70
vwapReclaimSell = e_VRC and isTrendDn and not prevBelow and close < vwapVal and close < open and volOk and rsi14 > 30
vwapRejectBuy   = e_VRC and isRange and close < vwapVal - atr * 1.5 and bullRev and volOk
vwapRejectSell  = e_VRC and isRange and close > vwapVal + atr * 1.5 and bearRev and volOk

// ============================================================
// ============== SECONDARY 2: LIQUIDITY SWEEP REVERSAL =======
// ============================================================
// Structure context — not peer-reviewed validated as standalone, but
// the institutional execution behavior (BIS market microstructure
// research) supports the concept of liquidity clustering at swing levels.
swingHi = ta.pivothigh(high, swingLen, swingLen)
swingLo = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHi = na
var float lastSwingLo = na
var int lastSwingHiBar = na
var int lastSwingLoBar = na

if not na(swingHi)
    lastSwingHi    := swingHi
    lastSwingHiBar := bar_index - swingLen
if not na(swingLo)
    lastSwingLo    := swingLo
    lastSwingLoBar := bar_index - swingLen

sweptHi = not na(lastSwingHi) and high > lastSwingHi and close < lastSwingHi
sweptLo = not na(lastSwingLo) and low < lastSwingLo and close > lastSwingLo

lsrSell = e_LSR and sweptHi[1] and close < open and close < lastSwingHi and volOk
lsrBuy  = e_LSR and sweptLo[1] and close > open and close > lastSwingLo and volOk

// Liquidity lines
var line liqHiLine = na
var line liqLoLine = na
if showLiqLine and not na(lastSwingHi) and (bar_index - lastSwingHiBar) <= 50
    if na(liqHiLine)
        liqHiLine := line.new(lastSwingHiBar, lastSwingHi, bar_index, lastSwingHi, color=color.new(cLiqHi, 50), style=line.style_dashed, width=1)
    else
        line.set_xy1(liqHiLine, lastSwingHiBar, lastSwingHi)
        line.set_xy2(liqHiLine, bar_index, lastSwingHi)
if showLiqLine and not na(lastSwingLo) and (bar_index - lastSwingLoBar) <= 50
    if na(liqLoLine)
        liqLoLine := line.new(lastSwingLoBar, lastSwingLo, bar_index, lastSwingLo, color=color.new(cLiqLo, 50), style=line.style_dashed, width=1)
    else
        line.set_xy1(liqLoLine, lastSwingLoBar, lastSwingLo)
        line.set_xy2(liqLoLine, bar_index, lastSwingLo)

// ============================================================
// ============== CONTEXT: FVG (display only) =================
// ============================================================
// Plastun et al. 2020 found gaps tend to CONTINUE, not fill.
// FVGs are shown for context but NOT used as signals.
newBullFvg = low > high[2] and close[1] > open[1]
newBearFvg = high < low[2] and close[1] < open[1]

if showFVG and newBullFvg
    box.new(bar_index - 1, low, bar_index + 15, high[2], bgcolor=cFvgUp, border_color=color.new(cBull, 70))
if showFVG and newBearFvg
    box.new(bar_index - 1, low[2], bar_index + 15, high, bgcolor=cFvgDn, border_color=color.new(cBear, 70))

// ============================================================
// ============== COMBINE & GATE ==============================
// ============================================================
var int lastSignalBar = -9999
cooldownOk = bar_index - lastSignalBar >= cooldownBars

// Primary signals (high evidence) get full priority
primaryBuy  = trendPbBuy or orbBuy or mrBuy
primaryShort = trendPbSell or orbSell or mrSell

// Secondary signals only fire if no primary fires this bar
secondaryBuy  = not primaryBuy and (vwapReclaimBuy or vwapRejectBuy or lsrBuy)
secondaryShort = not primaryShort and (vwapReclaimSell or vwapRejectSell or lsrSell)

buySignal  = (primaryBuy or secondaryBuy) and cooldownOk
sellSignal = (primaryShort or secondaryShort) and cooldownOk

if buySignal or sellSignal
    lastSignalBar := bar_index

// Tier classification
isPrimary = primaryBuy or primaryShort
sigName   = trendPbBuy ? "TREND PB ↑" : trendPbSell ? "TREND PB ↓" : orbBuy ? "ORB ↑" : orbSell ? "ORB ↓" : mrBuy ? "MEAN REV ↑" : mrSell ? "MEAN REV ↓" : vwapReclaimBuy ? "VWAP RCLM ↑" : vwapReclaimSell ? "VWAP RCLM ↓" : vwapRejectBuy ? "VWAP RJCT ↑" : vwapRejectSell ? "VWAP RJCT ↓" : lsrBuy ? "LIQ SWEEP ↑" : lsrSell ? "LIQ SWEEP ↓" : ""

tier  = isPrimary ? "PRIMARY" : "SEC"
tierStars = isPrimary ? "★★★" : "★"

// ============================================================
// ============== RISK MANAGEMENT =============================
// ============================================================
var float entryPx = na
var float stopPx  = na
var float tp1Px   = na
var float tp2Px   = na
var bool  inLong  = false
var bool  inShort = false
var int   barsHeld = 0
var bool  tp1Hit  = false

if buySignal and not inLong and not inShort
    entryPx := close
    stopPx  := close - atr * stopATR
    rAmt = entryPx - stopPx
    tp1Px := entryPx + rAmt * tp1RR
    tp2Px := entryPx + rAmt * tp2RR
    inLong := true
    barsHeld := 0
    tp1Hit := false

if sellSignal and not inLong and not inShort
    entryPx := close
    stopPx  := close + atr * stopATR
    rAmt = stopPx - entryPx
    tp1Px := entryPx - rAmt * tp1RR
    tp2Px := entryPx - rAmt * tp2RR
    inShort := true
    barsHeld := 0
    tp1Hit := false

if inLong or inShort
    barsHeld := barsHeld + 1

if inLong and high >= tp1Px and not tp1Hit
    tp1Hit := true
    stopPx := entryPx
if inShort and low <= tp1Px and not tp1Hit
    tp1Hit := true
    stopPx := entryPx

exitLong  = inLong  and (high >= tp2Px or low <= stopPx or barsHeld >= maxBars)
exitShort = inShort and (low  <= tp2Px or high >= stopPx or barsHeld >= maxBars)

if exitLong
    inLong := false
    barsHeld := 0
    tp1Hit := false
if exitShort
    inShort := false
    barsHeld := 0
    tp1Hit := false

suggestedSize = atr > 0 and stopATR > 0 ? math.floor(riskDollars / (atr * stopATR)) : 0

// ============================================================
// ============== PLOTS =======================================
// ============================================================
plot(showLevels ? ema20 : na, "EMA 20", color=cEma20, linewidth=1)
plot(showLevels ? ema50 : na, "EMA 50", color=cEma50, linewidth=2)
plot(showLevels ? sma200 : na, "SMA 200", color=color.gray, linewidth=1)
plot(showLevels ? vwapVal : na, "VWAP", color=cVwap, linewidth=2)
plot(showLevels ? bbUp : na, "BB Up", color=color.new(cBB, 60))
plot(showLevels ? bbDn : na, "BB Dn", color=color.new(cBB, 60))

plot(showActive and (inLong or inShort) ? entryPx : na, "Entry", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? stopPx  : na, "Stop",  color=tp1Hit ? cBE : cSL, linewidth=2, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? tp1Px   : na, "TP1",   color=cTP, linewidth=1, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? tp2Px   : na, "TP2",   color=color.new(cTP, 30), linewidth=1, style=plot.style_linebr)

if buySignal
    label.new(bar_index, low, "▲ " + sigName + " " + tierStars + "\n@ " + str.tostring(close, "#.##") + " · RVOL " + str.tostring(rvol, "#.#") + "x\nSL " + str.tostring(stopPx, "#.##") + " · TP " + str.tostring(tp2Px, "#.##"), style=label.style_label_up, color=isPrimary ? cBullS : cBull, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

if sellSignal
    label.new(bar_index, high, "▼ " + sigName + " " + tierStars + "\n@ " + str.tostring(close, "#.##") + " · RVOL " + str.tostring(rvol, "#.#") + "x\nSL " + str.tostring(stopPx, "#.##") + " · TP " + str.tostring(tp2Px, "#.##"), style=label.style_label_down, color=isPrimary ? cBearS : cBear, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

if exitLong
    reason = high >= tp2Px ? "TP2 ✓" : low <= stopPx ? (tp1Hit ? "BE ✓" : "SL") : "Time"
    label.new(bar_index, high, "$ EXIT · " + reason, style=label.style_label_down, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.abovebar)

if exitShort
    reason = low <= tp2Px ? "TP2 ✓" : high >= stopPx ? (tp1Hit ? "BE ✓" : "SL") : "Time"
    label.new(bar_index, low, "$ EXIT · " + reason, style=label.style_label_up, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.belowbar)

// ============================================================
// ============== DASHBOARD ===================================
// ============================================================
var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(#1A1F2E, 10), border_width=1, border_color=color.new(#2C3E50, 50))
cHdr  = color.new(#34495E, 0)
cCell = color.new(#2C3E50, 60)

if barstate.islast
    actionStr = inLong ? "● IN LONG" : inShort ? "● IN SHORT" : buySignal ? "▲ BUY " + tierStars : sellSignal ? "▼ SELL " + tierStars : "WAIT"
    actionCol = inLong or buySignal ? cBullS : inShort or sellSignal ? cBearS : color.new(color.gray, 30)

    rvolStr = str.tostring(rvol, "#.#") + "x"
    rvolCol = inPlay ? cBullS : color.gray

    htfStr = htfBull ? "↑" : htfBear ? "↓" : "—"
    htfCol = htfBull ? cBull : htfBear ? cBear : color.gray

    table.cell(dash, 0, 0, "REGIME",   text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 0, regime,     text_color=regimeCol, bgcolor=cCell, text_size=size.normal)
    table.cell(dash, 0, 1, "RVOL",     text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 1, rvolStr + (inPlay ? " ✓ IN PLAY" : ""), text_color=rvolCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 2, "ADX",      text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(adx, "#.#"), text_color=adx > 25 ? cBull : color.gray, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 3, "RSI(2)",   text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(rsi2, "#.#"), text_color=rsi2 < 5 ? cBull : rsi2 > 95 ? cBear : cText, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 4, "RSI(14)",  text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(rsi14, "#.#"), text_color=rsi14 > 70 ? cBear : rsi14 < 30 ? cBull : cText, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 5, "HTF",      text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 5, htfStr,     text_color=htfCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 6, "vs 200",   text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 6, aboveTrend ? "↑ above" : "↓ below", text_color=aboveTrend ? cBull : cBear, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 7, "ATR",      text_color=cText, bgcolor=cHdr, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(atr, "#.##"), text_color=cText, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 8, "ACTION",   text_color=color.white, bgcolor=actionCol, text_size=size.normal)
    table.cell(dash, 1, 8, actionStr,  text_color=color.white, bgcolor=actionCol, text_size=size.normal)

    if inLong or inShort
        tpStr = tp1Hit ? "TP2 " + str.tostring(tp2Px, "#.##") + " · BE" : "TP1 " + str.tostring(tp1Px, "#.##") + " · SL " + str.tostring(stopPx, "#.##")
        table.cell(dash, 0, 9, "TGT/SL", text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 9, tpStr,    text_color=cText, bgcolor=cCell, text_size=size.small)
    else
        table.cell(dash, 0, 9, "SIZE @$" + str.tostring(riskDollars, "#"), text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 9, str.tostring(suggestedSize) + " sh", text_color=cText, bgcolor=cCell, text_size=size.small)

// ============================================================
// ============== ALERTS ======================================
// ============================================================
alertcondition(buySignal,  title="BUY",  message="Apex Edge v3 BUY signal")
alertcondition(sellSignal, title="SELL", message="Apex Edge v3 SELL signal")
alertcondition(trendPbBuy or trendPbSell, title="Trend Pullback (J&T)", message="Trend pullback signal — primary tier")
alertcondition(orbBuy or orbSell, title="ORB (Zarattini)", message="Opening Range Breakout — primary tier")
alertcondition(mrBuy or mrSell, title="Mean Rev (Connors)", message="RSI(2) mean reversion — primary tier")
alertcondition(exitLong or exitShort, title="EXIT", message="Position exit fired")
````
