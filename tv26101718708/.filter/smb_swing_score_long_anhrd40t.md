# SMB Swing Score Long

- url: https://www.tradingview.com/script/aNhrd40t-SMB-Swing-Score-Long/
- type: indicator
- pine_id: PUB;21ad54397d8946c989d49386a6f9fe59
- version: 1.0

## Description

Score indicator — screener ranker
The 0-100 score maps directly to the §2 checklist with weights that reflect their priority in the rulebook:
CriteriaWeightWhyRVOL ≥ threshold20The gate — no signal without volumeDaily trend + RS15 eachThe two stock-selection anchorsSetup signal20Price has confirmed the ideaCoil + near level + R:R10 eachQuality modifiers
To use it as a screener: load it on any chart once so TradingView registers it → open Screener → Filters → "Add indicator filter" → search "SMB Swing Score" → filter Composite Score > 70 → sort descending. That's your ranked watchlist every morning in under a minute.

## Source Code

````pine
//@version=6
// =============================================================================
//  SMB SWING SCORE  —  LONG SETUPS ONLY
//  Screener / Watchlist Ranker
//
//  Plots three values TradingView's Screener picks up as sortable columns:
//    • Long Score        (0-100)  — primary sort column
//    • RVOL              (float)  — volume gate value
//    • RS vs Bench       (float)  — relative strength % vs SPY
//
//  HOW TO USE IN THE SCREENER:
//    1. Add this indicator to any chart once (registers it in your account).
//    2. Open TradingView Screener → Filters → "Add indicator filter".
//    3. Search "SMB Swing Score Long" → select "Long Score".
//    4. Set filter: Long Score > 70 for quality candidates, > 80 for
//       high-conviction setups only.
//    5. Sort descending by Long Score to rank your watchlist.
//
//  SCORE GUIDE:
//    80-100  All major boxes ticked + signal present  — trade candidate
//    60-79   Most criteria met, no signal yet         — stalk / watchlist
//    40-59   Partial setup building                   — early watch
//    < 40    Not a setup                              — skip
//
//  SCORING WEIGHTS (maps directly to §2 rulebook checklist, long side):
//    RVOL ≥ threshold            20 pts  — the non-negotiable volume gate
//    Daily trend aligned (up)    15 pts  — SMA stack + price above SMA50
//    Relative strength > SPY     15 pts  — stock leading the market
//    Setup signal present        20 pts  — BO or PP confirmed by price
//    Rubber-band coil            10 pts  — energy contracting before expansion
//    Near breakout level         10 pts  — price close to the trigger zone
//    R:R feasible (≥ 3:1)        10 pts  — enough room above to justify risk
//    Total                      100 pts
// =============================================================================

indicator("SMB Swing Score Long", overlay = false)

// ─────────────────────────── INPUTS ──────────────────────────────────────────
grpVol  = "Relative Volume"
rvolLen = input.int(20,    "RVOL avg length", group = grpVol)
rvolMin = input.float(1.5, "RVOL minimum",    group = grpVol, step = 0.1)

grpRS   = "Relative Strength"
benchSym = input.symbol("AMEX:SPY", "Benchmark (default SPY)", group = grpRS)
rsLen    = input.int(20, "RS lookback (daily bars)",            group = grpRS)

grpCoil = "Rubber Band"
bbLen   = input.int(20,    "BB/Keltner length", group = grpCoil)
bbMult  = input.float(2.0, "BB mult",           group = grpCoil, step = 0.1)
kcMult  = input.float(1.5, "Keltner mult",      group = grpCoil, step = 0.1)
coilBars= input.int(6,     "Coil within N bars", group = grpCoil)

grpBO   = "Breakout Range"
donch   = input.int(20,   "Donchian lookback",       group = grpBO)
proxPct = input.float(3.0, "Near-level proximity %", group = grpBO, step = 0.5)

grpPP   = "Power Play (Setup C)"
ppMove  = input.float(8.0, "Day-1 range %",                     group = grpPP, step = 0.5)
ppClose = input.float(0.6, "Day-1 close fraction from extreme", group = grpPP, step = 0.05)

grpRR   = "R:R Gate"
atrLen  = input.int(14,   "ATR length",            group = grpRR)
rrMin   = input.float(3.0, "Min R for valid trade", group = grpRR, step = 0.5)

grpViz  = "Display"
showTbl = input.bool(true, "Show score breakdown table", group = grpViz)

// ─────────────────────────── SERIES ──────────────────────────────────────────
sma2  = ta.sma(close, 20)
atrV  = ta.atr(atrLen)
rvol  = volume / ta.sma(volume, rvolLen)
rvolOK = rvol >= rvolMin

// Daily SMAs — correct on any chart timeframe
dS2  = request.security(syminfo.tickerid, "D", ta.sma(close, 20),  lookahead = barmerge.lookahead_off)
dS3  = request.security(syminfo.tickerid, "D", ta.sma(close, 50),  lookahead = barmerge.lookahead_off)
dS4  = request.security(syminfo.tickerid, "D", ta.sma(close, 200), lookahead = barmerge.lookahead_off)
dCl  = request.security(syminfo.tickerid, "D", close,               lookahead = barmerge.lookahead_off)
trendUp = dS2 > dS3 and dS3 > dS4 and dCl > dS3

// Relative strength vs benchmark
sPerfD = request.security(syminfo.tickerid, "D", (close - close[rsLen]) / close[rsLen] * 100, lookahead = barmerge.lookahead_off)
bPerfD = request.security(benchSym,         "D", (close - close[rsLen]) / close[rsLen] * 100, lookahead = barmerge.lookahead_off)
rs     = sPerfD - bPerfD
rsOK   = rs > 0

// Rubber-band squeeze
bbBasis = ta.sma(close, bbLen)
upBB    = bbBasis + bbMult * ta.stdev(close, bbLen)
loBB    = bbBasis - bbMult * ta.stdev(close, bbLen)
kcRng   = ta.sma(ta.tr(true), bbLen)
upKC    = bbBasis + kcMult * kcRng
loKC    = bbBasis - kcMult * kcRng
sqzOn   = loBB > loKC and upBB < upKC
coiled  = sqzOn or (ta.barssince(sqzOn) <= coilBars)

// Breakout levels
rangeHi = ta.highest(high[1], donch)
rangeLo = ta.lowest(low[1],  donch)

// Near breakout zone (within proxPct% of prior range high)
nearHi  = math.abs(close - rangeHi) / close * 100 <= proxPct

// Setup A — Consolidation Breakout Long
boLong  = close > rangeHi and rvolOK and coiled and trendUp

// Setup C — Power Play Day-2 Long
d1Rng   = high[1] - low[1]
d1Pct   = d1Rng / low[1] * 100
d1VolOK = rvol[1] >= rvolMin
bigUp   = d1Pct >= ppMove and (close[1] - low[1]) / d1Rng >= ppClose and close[1] > open[1] and d1VolOK
ppLong  = bigUp and low < close[1] and close > open and (close - low) / (high - low) > 0.5

anyLong = boLong or ppLong

// R:R feasibility — enough room above entry to hit rrMin target
// Uses prior range as a proxy: upside (rangeHi - close) vs downside risk (close - rangeLo)
rrOK = (rangeHi - close) / math.max(close - rangeLo, 0.001) >= rrMin

// ─────────────────────────── SCORE ───────────────────────────────────────────
pTrend = trendUp  ? 15 : 0
pRS    = rsOK     ? 15 : 0
pRvol  = rvolOK   ? 20 : 0
pCoil  = coiled   ? 10 : 0
pSetup = anyLong  ? 20 : 0
pNear  = nearHi   ? 10 : 0
pRR    = rrOK     ? 10 : 0

longScore = pTrend + pRS + pRvol + pCoil + pSetup + pNear + pRR

// ─────────────────────────── PLOTS (screener columns) ────────────────────────
plot(longScore, "Long Score", color.new(color.lime, 0), linewidth = 2)
plot(rvol,      "RVOL",       color.new(color.aqua, 0))
plot(rs,        "RS vs Bench",color.new(color.orange, 0))

// Threshold reference lines
hline(80, "High Conviction", color.new(color.lime,   0), linestyle = hline.style_dashed)
hline(60, "Watchlist",       color.new(color.orange, 0), linestyle = hline.style_dashed)
hline(40, "Partial",         color.new(color.gray,   0), linestyle = hline.style_dashed)

bgcolor(longScore >= 80 ? color.new(color.lime,   90) :
        longScore >= 60 ? color.new(color.orange,  90) :
        longScore >= 40 ? color.new(color.gray,    90) : na)

// ─────────────────────────── BREAKDOWN TABLE ─────────────────────────────────
f_row(bool b, int pts) => (b ? "✓  +" : "·   ") + str.tostring(pts) + " pts"
f_bg(bool b)           => b ? color.new(color.green, 20) : color.new(color.gray, 40)

var table tbl = table.new(position.top_left, 3, 12, border_width = 1)
if showTbl and barstate.islast
    // Header
    table.cell(tbl, 0, 0, "CRITERIA",              bgcolor = color.new(color.navy, 0), text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 0, "STATUS",                bgcolor = color.new(color.navy, 0), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 0, "WT",                    bgcolor = color.new(color.navy, 0), text_color = color.white, text_size = size.small)

    table.cell(tbl, 0, 1, "RVOL (" + str.tostring(rvol, "#.1") + "×)",  text_size = size.small)
    table.cell(tbl, 1, 1, f_row(rvolOK,  pRvol),  bgcolor = f_bg(rvolOK),  text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 1, "20",                    text_size = size.small)

    table.cell(tbl, 0, 2, "Daily trend up",        text_size = size.small)
    table.cell(tbl, 1, 2, f_row(trendUp, pTrend),  bgcolor = f_bg(trendUp), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 2, "15",                    text_size = size.small)

    table.cell(tbl, 0, 3, "RS > SPY (" + str.tostring(rs, "+#.1;-#.1") + "%)", text_size = size.small)
    table.cell(tbl, 1, 3, f_row(rsOK,    pRS),     bgcolor = f_bg(rsOK),    text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 3, "15",                    text_size = size.small)

    table.cell(tbl, 0, 4, "Setup signal (BO/PP)",  text_size = size.small)
    table.cell(tbl, 1, 4, f_row(anyLong, pSetup),  bgcolor = f_bg(anyLong), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 4, "20",                    text_size = size.small)

    table.cell(tbl, 0, 5, "Coiled (rubber band)",  text_size = size.small)
    table.cell(tbl, 1, 5, f_row(coiled,  pCoil),   bgcolor = f_bg(coiled),  text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 5, "10",                    text_size = size.small)

    table.cell(tbl, 0, 6, "Near range high",       text_size = size.small)
    table.cell(tbl, 1, 6, f_row(nearHi,  pNear),   bgcolor = f_bg(nearHi),  text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 6, "10",                    text_size = size.small)

    table.cell(tbl, 0, 7, "R:R feasible (≥" + str.tostring(rrMin, "#.0") + "R)", text_size = size.small)
    table.cell(tbl, 1, 7, f_row(rrOK,    pRR),     bgcolor = f_bg(rrOK),    text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 7, "10",                    text_size = size.small)

    // Divider + score total
    _scoreClr = longScore >= 80 ? color.new(color.lime, 0) : longScore >= 60 ? color.new(color.orange, 0) : color.new(color.gray, 20)
    _rating   = longScore >= 80 ? "HIGH CONVICTION" : longScore >= 60 ? "WATCHLIST" : longScore >= 40 ? "PARTIAL" : "SKIP"
    _signal   = boLong ? "▲ A  BREAKOUT" : ppLong ? "▲ C  POWER PLAY" : "— none"

    table.cell(tbl, 0, 8, "LONG SCORE",            bgcolor = color.new(color.navy, 0), text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 8, str.tostring(longScore) + " / 100", bgcolor = _scoreClr, text_color = color.white, text_size = size.normal)
    table.cell(tbl, 2, 8, _rating,                 bgcolor = _scoreClr, text_color = color.white, text_size = size.small)

    table.cell(tbl, 0,  9, "Signal",               text_size = size.small)
    table.cell(tbl, 1,  9, _signal,                bgcolor = anyLong ? color.new(color.green, 0) : color.new(color.gray, 30), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2,  9, "",                     text_size = size.small)

    table.cell(tbl, 0, 10, "ATR(" + str.tostring(atrLen) + ")", text_size = size.small)
    table.cell(tbl, 1, 10, str.tostring(atrV, "#.00"),          text_size = size.small)
    table.cell(tbl, 2, 10, "",                     text_size = size.small)

    table.cell(tbl, 0, 11, "Range Hi / Lo",        text_size = size.small)
    table.cell(tbl, 1, 11, str.tostring(rangeHi, "#.00") + " / " + str.tostring(rangeLo, "#.00"), text_size = size.small)
    table.cell(tbl, 2, 11, "",                     text_size = size.small)

// ─────────────────────────── ALERTS ──────────────────────────────────────────
alertcondition(longScore >= 80, "Long Score ≥ 80 (High Conviction)", "{{ticker}} SMB Long Score {{plot_0}} — high conviction long setup")
alertcondition(longScore >= 60, "Long Score ≥ 60 (Watchlist)",       "{{ticker}} SMB Long Score {{plot_0}} — watchlist candidate")
alertcondition(boLong,          "Breakout Long signal",               "{{ticker}} BO LONG signal — score {{plot_0}}")
alertcondition(ppLong,          "Power Play Long signal",             "{{ticker}} PP LONG signal — score {{plot_0}}")
````
