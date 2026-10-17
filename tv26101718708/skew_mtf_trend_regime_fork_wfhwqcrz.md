# Skew MTF Trend + Regime (fork)

- url: https://www.tradingview.com/script/wFHwQCRZ-Skew-MTF-Trend-Regime-fork/
- type: indicator
- pine_id: PUB;17e774447822417387ae2a772e9a6387
- version: 1.0

## Description

Skew MTF Trend + Regime, a fork of "Skew MTF Trend" by Skew (@52kskew), used with credit. All original trend logic is his; this version adds one column.

What's added: a "Regime" dot next to each timeframe's direction arrow, describing the character of the move right now:
- green = ORDERLY (clean move)
- amber = CHOPPY (volatility expanding)
- red = WHIPSAW (volatility spiking, MA read noisy)

How: per timeframe, ratio of short- to long-window realized volatility: stdev(log returns, 5) / stdev(log returns, 30). Above 1.4 = amber, above 2.0 = red.

What it is / isn't: it describes how the trend is behaving, not where price goes next. It is not a buy/sell signal, and it has no predictive edge (tested on BTC daily, it does not call tops or bottoms). Treat it as situational awareness: orderly vs choppy.

Note: the table reflects the developing higher-timeframe bar, so the current cell updates until that bar closes (same behavior as the underlying trend arrows).

Original: https://www.tradingview.com/script/27QCHz8d-Skew-MTF-Trend/

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Skew MTF Trend + Regime (fork)
//
// Original: "Skew MTF Trend" by Skewstream (@52kskew) — open-source.
//   https://www.tradingview.com/script/27QCHz8d-Skew-MTF-Trend/
//
// What this fork adds (everything else is unchanged from the original):
//   A "Regime" column in the bottom-right table. The Trend column tells you the
//   DIRECTION per timeframe; the Regime column tells you the CHARACTER of that
//   move right now — orderly vs choppy. It describes how the trend is behaving,
//   NOT a forecast of where price goes next. It is not a buy/sell signal.
//   A green dot on a downtrend means the decline is clean, not that it continues.
//
//   Regime = ratio of short- to long-window realized volatility per TF:
//     fragRatio = stdev(logret, shortLen) / stdev(logret, longLen)
//     ● green   ratio < caution   → ORDERLY  (move is clean right now)
//     ● amber   caution ≤ ratio   → CHOPPY   (volatility is expanding)
//     ● red     ratio ≥ fragile   → WHIPSAW  (volatility spiking, MA read noisy)
//   Hover any Regime cell to see the raw ratio.
//
// Why: a moving-average trend read whipsaws most when short-term vol expands
// relative to its baseline. A direction-only table can't see that. This column
// is the regime/context layer. Tested on 2.7y BTC daily: it has NO predictive
// edge (it does not call tops/bottoms). Treat it as situational awareness only.
//
// Credit + meaningful change retained per TradingView House Rules for forks.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Skew MTF Trend + Regime (fork)", overlay=true, max_bars_back=5000)

// ─── Groups ───
GRP_MAIN  = "Main Timeframe"
GRP_HTF1  = "HTF 1"
GRP_HTF2  = "HTF 2"
GRP_DISP  = "Display"
GRP_FRAG  = "Trend Regime (fork add-on)"

// ─── Main Timeframe ───
showMain  = input.bool(true, "Show Main Averages",  group=GRP_MAIN)
htf       = input.timeframe("240", "Timeframe",     group=GRP_MAIN)
mainLen1  = input.int(21,  "EMA 21",                group=GRP_MAIN)
mainLen2  = input.int(50,  "EMA 50",                group=GRP_MAIN)
mainLen3  = input.int(100, "EMA 100",               group=GRP_MAIN)
mainLen4  = input.int(200, "EMA 200",               group=GRP_MAIN)

// ─── HTF 1 ───
showHTF1    = input.bool(true, "Show HTF 1 Averages", group=GRP_HTF1)
htf1        = input.timeframe("1D", "Timeframe",      group=GRP_HTF1)
htf1Len1    = input.int(50,  "EMA 50",                group=GRP_HTF1)
htf1Len2    = input.int(200, "EMA 200",               group=GRP_HTF1)

// ─── HTF 2 ───
showHTF2       = input.bool(true, "Show HTF 2 Averages", group=GRP_HTF2)
htf2           = input.timeframe("1W", "Timeframe",      group=GRP_HTF2)
htf2Len21      = input.int(21,  "EMA 21",                group=GRP_HTF2)
htf2Len50      = input.int(50,  "EMA 50",                group=GRP_HTF2)
htf2EmaLen     = input.int(200, "EMA 200",               group=GRP_HTF2)
htf2SmaLen     = input.int(200, "SMA 200",               group=GRP_HTF2)

// ─── Display ───
showMain21_100 = input.bool(false, "Main: EMA 21 & 100",  group=GRP_DISP)
showMain50     = input.bool(true,  "Main: EMA 50",         group=GRP_DISP)
showMain200    = input.bool(true,  "Main: EMA 200",        group=GRP_DISP)
showHTF1_50    = input.bool(true,  "HTF 1: EMA 50",        group=GRP_DISP)
showHTF1_200   = input.bool(true,  "HTF 1: EMA 200",       group=GRP_DISP)
showHTF2_21    = input.bool(true,  "HTF 2: EMA 21",        group=GRP_DISP)
showHTF2_50    = input.bool(true,  "HTF 2: EMA 50",        group=GRP_DISP)
showHTF2_Ema   = input.bool(true,  "HTF 2: EMA 200",       group=GRP_DISP)
showHTF2_Sma   = input.bool(true,  "HTF 2: SMA 200",       group=GRP_DISP)
showTable      = input.bool(true,  "Show Trend Table",     group=GRP_DISP)
strictBody     = input.bool(false, "Strict body check",    group=GRP_DISP)
src            = input.source(close, "Source",              group=GRP_DISP)

// ─── Regime / fragility (fork add-on) ───
showTrust    = input.bool(true,  "Show Regime column",                group=GRP_FRAG)
fragShortLen = input.int(5,   "Short vol lookback (bars)",            group=GRP_FRAG, minval=2)
fragLongLen  = input.int(30,  "Long vol lookback (bars)",             group=GRP_FRAG, minval=5)
fragMid      = input.float(1.4, "Caution ratio (amber dot)",         group=GRP_FRAG, step=0.1, minval=1.0)
fragHi       = input.float(2.0, "Fragile ratio (red dot)",           group=GRP_FRAG, step=0.1, minval=1.0)

// ─── Timeframe label helper ───
tfLabel(string tf) =>
    switch tf
        ""    => "Chart"
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "360" => "6H"
        "480" => "8H"
        "720" => "12H"
        "D"   => "1D"
        "1D"  => "1D"
        "W"   => "1W"
        "1W"  => "1W"
        "M"   => "1M"
        "1M"  => "1M"
        => tf

// ─── Visibility flags ───
_visM21  = showMain and showMain21_100
_visM50  = showMain and showMain50
_visM200 = showMain and showMain200
_vis1_50 = showHTF1 and showHTF1_50
_vis1200 = showHTF1 and showHTF1_200
_vis2_21 = showHTF2 and showHTF2_21
_vis2_50 = showHTF2 and showHTF2_50
_vis2E   = showHTF2 and showHTF2_Ema
_vis2S   = showHTF2 and showHTF2_Sma

// ─── Main TF EMAs ───
e1 = request.security(syminfo.tickerid, htf, ta.ema(src, mainLen1), barmerge.gaps_off, barmerge.lookahead_off)
e2 = request.security(syminfo.tickerid, htf, ta.ema(src, mainLen2), barmerge.gaps_off, barmerge.lookahead_off)
e3 = request.security(syminfo.tickerid, htf, ta.ema(src, mainLen3), barmerge.gaps_off, barmerge.lookahead_off)
e4 = request.security(syminfo.tickerid, htf, ta.ema(src, mainLen4), barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 1 EMAs ───
e1_h1 = request.security(syminfo.tickerid, htf1, ta.ema(src, htf1Len1), barmerge.gaps_off, barmerge.lookahead_off)
e2_h1 = request.security(syminfo.tickerid, htf1, ta.ema(src, htf1Len2), barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 2 EMAs & SMA (computed inside security) ───
ema21_h2  = request.security(syminfo.tickerid, htf2, ta.ema(src, htf2Len21),  barmerge.gaps_off, barmerge.lookahead_off)
ema50_h2  = request.security(syminfo.tickerid, htf2, ta.ema(src, htf2Len50),  barmerge.gaps_off, barmerge.lookahead_off)
ema200_h2 = request.security(syminfo.tickerid, htf2, ta.ema(src, htf2EmaLen), barmerge.gaps_off, barmerge.lookahead_off)
sma200_h2 = request.security(syminfo.tickerid, htf2, ta.sma(src, htf2SmaLen), barmerge.gaps_off, barmerge.lookahead_off)

// ─── Main TF O/C ───
o_main = request.security(syminfo.tickerid, htf, open,  barmerge.gaps_off, barmerge.lookahead_off)
c_main = request.security(syminfo.tickerid, htf, close, barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 1 O/C ───
o_h1 = request.security(syminfo.tickerid, htf1, open,  barmerge.gaps_off, barmerge.lookahead_off)
c_h1 = request.security(syminfo.tickerid, htf1, close, barmerge.gaps_off, barmerge.lookahead_off)

// ─── HTF 2 O/C ───
o_h2 = request.security(syminfo.tickerid, htf2, open,  barmerge.gaps_off, barmerge.lookahead_off)
c_h2 = request.security(syminfo.tickerid, htf2, close, barmerge.gaps_off, barmerge.lookahead_off)

// ─── Fragility ratios per timeframe (fork add-on) ───
// ratio = stdev(log returns, short) / stdev(log returns, long), evaluated in each TF context.
// math.max(..., 1e-10) guards against divide-by-zero on flat history.
fragMain = request.security(syminfo.tickerid, htf,  ta.stdev(math.log(close / close[1]), fragShortLen) / math.max(ta.stdev(math.log(close / close[1]), fragLongLen), 1e-10), barmerge.gaps_off, barmerge.lookahead_off)
fragH1   = request.security(syminfo.tickerid, htf1, ta.stdev(math.log(close / close[1]), fragShortLen) / math.max(ta.stdev(math.log(close / close[1]), fragLongLen), 1e-10), barmerge.gaps_off, barmerge.lookahead_off)
fragH2   = request.security(syminfo.tickerid, htf2, ta.stdev(math.log(close / close[1]), fragShortLen) / math.max(ta.stdev(math.log(close / close[1]), fragLongLen), 1e-10), barmerge.gaps_off, barmerge.lookahead_off)

// Direction-neutral status dot — the COLOR carries the meaning, not the glyph,
// so it never reads as an endorsement of the trade direction.
fragSym(float r) => na(r) ? "·" : "●"
fragColr(float r) => na(r) ? color.gray : r >= fragHi ? color.red : r >= fragMid ? color.orange : color.lime
// Character, not forecast: every word describes how the move is BEHAVING now,
// nothing implies where price goes next.
fragTip(float r) => na(r) ? "no data" : "vol ratio " + str.tostring(r, "#.##") + (r >= fragHi ? "  ·  WHIPSAW (vol spiking, MA read noisy)" : r >= fragMid ? "  ·  CHOPPY (vol expanding)" : "  ·  ORDERLY (move is clean right now)")

// ─── Bias (main TF 21/50/100 stack) ───
bull = e1 > e2 and e2 > e3
bear = e1 < e2 and e2 < e3

// ─── Trend colors (Main TF) ───
trendBull50 = strictBody ? (o_main > e2 and c_main > e2) : (c_main > e2)
trendBear50 = strictBody ? (o_main < e2 and c_main < e2) : (c_main < e2)
trendCol50  = trendBull50 ? color.lime : trendBear50 ? color.red : color.new(color.gray, 40)

trendBull200 = strictBody ? (o_main > e4 and c_main > e4) : (c_main > e4)
trendBear200 = strictBody ? (o_main < e4 and c_main < e4) : (c_main < e4)
trendCol200  = trendBull200 ? color.lime : trendBear200 ? color.red : color.new(color.gray, 40)

// ─── Trend colors (HTF 1) ───
trendBull50_h1 = strictBody ? (o_h1 > e1_h1 and c_h1 > e1_h1) : (c_h1 > e1_h1)
trendBear50_h1 = strictBody ? (o_h1 < e1_h1 and c_h1 < e1_h1) : (c_h1 < e1_h1)
trendCol50_h1  = trendBull50_h1 ? color.lime : trendBear50_h1 ? color.red : color.new(color.gray, 40)

trendBull200_h1 = strictBody ? (o_h1 > e2_h1 and c_h1 > e2_h1) : (c_h1 > e2_h1)
trendBear200_h1 = strictBody ? (o_h1 < e2_h1 and c_h1 < e2_h1) : (c_h1 < e2_h1)
trendCol200_h1  = trendBull200_h1 ? color.lime : trendBear200_h1 ? color.red : color.new(color.gray, 40)

// ─── Trend colors (HTF 2) ───
trendBull21_h2 = strictBody ? (o_h2 > ema21_h2 and c_h2 > ema21_h2) : (c_h2 > ema21_h2)
trendBear21_h2 = strictBody ? (o_h2 < ema21_h2 and c_h2 < ema21_h2) : (c_h2 < ema21_h2)
trendCol21_h2  = trendBull21_h2 ? color.lime : trendBear21_h2 ? color.red : color.new(color.gray, 40)

trendBull50_h2 = strictBody ? (o_h2 > ema50_h2 and c_h2 > ema50_h2) : (c_h2 > ema50_h2)
trendBear50_h2 = strictBody ? (o_h2 < ema50_h2 and c_h2 < ema50_h2) : (c_h2 < ema50_h2)
trendCol50_h2  = trendBull50_h2 ? color.lime : trendBear50_h2 ? color.red : color.new(color.gray, 40)

trendBullEma_h2 = strictBody ? (o_h2 > ema200_h2 and c_h2 > ema200_h2) : (c_h2 > ema200_h2)
trendBearEma_h2 = strictBody ? (o_h2 < ema200_h2 and c_h2 < ema200_h2) : (c_h2 < ema200_h2)
trendColEma_h2  = trendBullEma_h2 ? color.lime : trendBearEma_h2 ? color.red : color.new(color.gray, 40)

trendBullSma_h2 = strictBody ? (o_h2 > sma200_h2 and c_h2 > sma200_h2) : (c_h2 > sma200_h2)
trendBearSma_h2 = strictBody ? (o_h2 < sma200_h2 and c_h2 < sma200_h2) : (c_h2 < sma200_h2)
trendColSma_h2  = trendBullSma_h2 ? color.lime : trendBearSma_h2 ? color.red : color.new(color.gray, 40)

// ─── Plots (Main TF) ───
p1 = plot(e1, color=color.new(#000000,  0), linewidth=1, title="Main EMA 21",  display=_visM21 ? display.all : display.none)
p2 = plot(e2, color=trendCol50,              linewidth=2, title="Main EMA 50",  display=_visM50 ? display.all : display.none)
p3 = plot(e3, color=color.new(#000000, 40),  linewidth=1, title="Main EMA 100", display=_visM21 ? display.all : display.none)
p4 = plot(e4, color=trendCol200,             linewidth=2, title="Main EMA 200", display=_visM200 ? display.all : display.none)

// ─── Plots (HTF 1) ───
plot(e1_h1, color=trendCol50_h1,  linewidth=3, title="HTF 1 EMA 50",  display=_vis1_50 ? display.all : display.none)
plot(e2_h1, color=trendCol200_h1, linewidth=3, title="HTF 1 EMA 200", display=_vis1200 ? display.all : display.none)

// ─── Plots (HTF 2) ───
plot(ema21_h2,  color=trendCol21_h2,  linewidth=4, title="HTF 2 EMA 21",  display=_vis2_21 ? display.all : display.none)
plot(ema50_h2,  color=trendCol50_h2,  linewidth=4, title="HTF 2 EMA 50",  display=_vis2_50 ? display.all : display.none)
plot(ema200_h2, color=trendColEma_h2, linewidth=4, title="HTF 2 EMA 200", display=_vis2E   ? display.all : display.none)
plot(sma200_h2, color=trendColSma_h2, linewidth=4, title="HTF 2 SMA 200", display=_vis2S   ? display.all : display.none)

// ─── Ribbon ───
colBull = color.new(color.lime, 80)
colBear = color.new(color.red,  80)
colNeu  = color.new(color.gray, 85)
ribbonCol = showMain ? (bull ? colBull : bear ? colBear : colNeu) : na
fill(p1, p2, color=ribbonCol, title="Ribbon 21-50")
fill(p2, p3, color=ribbonCol, title="Ribbon 50-100")

// ─── Trend Table (50 & 200 EMA only) + Trust column (fork) ───
mainUp   = trendBull50 and trendBull200
mainDown = trendBear50 and trendBear200
htf1Up   = trendBull50_h1 and trendBull200_h1
htf1Down = trendBear50_h1 and trendBear200_h1
htf2Up   = trendBull50_h2 and trendBullEma_h2
htf2Down = trendBear50_h2 and trendBearEma_h2

mainSym = mainUp ? "▲" : mainDown ? "▼" : "●"
htf1Sym = htf1Up ? "▲" : htf1Down ? "▼" : "●"
htf2Sym = htf2Up ? "▲" : htf2Down ? "▼" : "●"

mainCol = mainUp ? color.lime : mainDown ? color.red : #555555
htf1Col = htf1Up ? color.lime : htf1Down ? color.red : #555555
htf2Col = htf2Up ? color.lime : htf2Down ? color.red : #555555

var table tbl = table.new(position.bottom_right, 3, 4, bgcolor=color.new(#000000, 80), border_width=0)

if barstate.islast and showTable
    // header row
    table.cell(tbl, 0, 0, "",      text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, 0, "Trend", text_color=color.silver, text_size=size.small,  text_halign=text.align_center)
    // Main
    table.cell(tbl, 0, 1, tfLabel(htf),  text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 1, mainSym,       text_color=mainCol,      text_size=size.large,  text_halign=text.align_center)
    // HTF 1
    table.cell(tbl, 0, 2, tfLabel(htf1), text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 2, htf1Sym,       text_color=htf1Col,      text_size=size.large,  text_halign=text.align_center)
    // HTF 2
    table.cell(tbl, 0, 3, tfLabel(htf2), text_color=color.silver, text_size=size.normal, text_halign=text.align_left)
    table.cell(tbl, 1, 3, htf2Sym,       text_color=htf2Col,      text_size=size.large,  text_halign=text.align_center)
    // Trust column (fork add-on)
    if showTrust
        table.cell(tbl, 2, 0, "Regime",           text_color=color.silver,  text_size=size.small,  text_halign=text.align_center)
        table.cell(tbl, 2, 1, fragSym(fragMain),  text_color=fragColr(fragMain), text_size=size.large, text_halign=text.align_center, tooltip=fragTip(fragMain))
        table.cell(tbl, 2, 2, fragSym(fragH1),    text_color=fragColr(fragH1),   text_size=size.large, text_halign=text.align_center, tooltip=fragTip(fragH1))
        table.cell(tbl, 2, 3, fragSym(fragH2),    text_color=fragColr(fragH2),   text_size=size.large, text_halign=text.align_center, tooltip=fragTip(fragH2))
````
