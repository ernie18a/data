# Ari SPX Macro Risk Dashboard

- url: https://www.tradingview.com/script/rIwO7AEE-Ari-SPX-Macro-Risk-Dashboard/
- type: indicator
- pine_id: PUB;bb8d0f2d84254af9851a5f7d44c646ed
- version: 2.0

## Description

A tool to help characterize major risks in the market

## Source Code

````pine
//@version=5
indicator("SPX Macro Risk Dashboard", overlay=true)

// ============================================================
// DISPLAY INPUTS
// ============================================================
sizeOpt = input.string("Normal", "Table text size", options=["Tiny","Small","Normal","Large","Huge"])
posOpt  = input.string("Top Right", "Table position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Center"])
mode    = input.string("Continuous", "Daily scoring mode", options=["Continuous","Binary"], tooltip="Daily column only. Weekly is always continuous.")
showWk  = input.bool(true, "Show weekly confirmation column")
dirLook = input.int(5, "DIR lookback - coincident (trading days)", minval=1, tooltip="Coincident factors: score vs its value this many trading days ago. 5 = week-over-week.")
dirLookLead = input.int(21, "DIR lookback - leading (trading days)", minval=1, tooltip="Leading macro factors (curve, spread) change slowly; 21 ~ month-over-month.")

// ============================================================
// LEGEND / EDUCATIONAL NOTES  (settings-only; no effect on logic)
// Hover the (i) tooltip icon next to each item to read the explanation.
// ============================================================
gL = "Legend - how to read this (hover the i icons)"
ig0 = input.bool(false, "About this dashboard", group=gL, tooltip="A risk-condition monitor, NOT a predictor. It shows when stress is present across several dimensions. LEADING factors can deteriorate before price; COINCIDENT factors move with the market. The strongest early-warning signal is leading factors lighting up while coincident ones stay calm. Scores run 0 (calm) to 1 (stressed): under 0.25 Low, under 0.50 Moderate, under 0.75 Elevated, else High. DIR shows whether a score is rising (+), falling (-), or flat (=) versus an earlier bar. WKLY shows the same factor on the weekly timeframe; act with more conviction when daily and weekly agree.")
ig1 = input.bool(false, "Yield Curve (LEADING)", group=gL, tooltip="10y minus 2y Treasury yield. When short rates exceed long rates (an inverted/negative curve) it has historically preceded recessions, often by several quarters. It is one of the few genuinely leading macro signals, but it leads by months not days - read it by level, not by daily wiggles. Risk score rises as the spread falls below zero.")
ig2 = input.bool(false, "Credit Spread / HY OAS (LEADING)", group=gL, tooltip="Option-adjusted spread on US high-yield bonds: the extra yield investors demand to hold risky corporate debt over Treasuries. Widening spreads mean the market is pricing higher default/stress risk, and credit often moves before equities top. Cleaner than the HYG/LQD ratio because it isn't muddied by interest-rate duration. Risk rises as the spread widens above its base level.")
ig3 = input.bool(false, "Breadth - % above 200d (LEADING)", group=gL, tooltip="Percent of S&P 500 members trading above their 200-day moving average. Healthy advances are broad; when fewer stocks participate while the index still rises, that hidden deterioration often precedes a top. Captures under-the-surface weakness that an index-only trend measure misses. Risk rises as the percentage falls from healthy (high) toward weak (low).")
ig4 = input.bool(false, "Trend (COINCIDENT)", group=gL, tooltip="Price of SPX relative to its 50- and 200-period moving averages. Below both = downtrend. This confirms a move that is already underway rather than anticipating it; it is a condition check, not a forecast. Risk rises the further price sits below its moving averages.")
ig5 = input.bool(false, "Volatility regime (COINCIDENT)", group=gL, tooltip="VIX (1-month implied vol) divided by VIX3M (3-month). Normally the curve is upward sloping (ratio under 1). When near-term fear spikes above longer-term (ratio above ~1, called backwardation), it signals acute stress. Risk rises as the ratio climbs toward and past 1.")
ig6 = input.bool(false, "Credit (COINCIDENT)", group=gL, tooltip="HYG/LQD: price of high-yield bonds relative to investment-grade. A falling ratio means risky debt is underperforming safe debt - a flight to quality. Compared here to its own moving average; risk rises as the ratio drops below that average. A simpler, chart-native cousin of the HY OAS leading factor.")
ig7 = input.bool(false, "Exhaustion - RSI (COINCIDENT)", group=gL, tooltip="14-period RSI distance from neutral (50). Extreme readings in either direction suggest a move is overextended and prone to reversal. Note this is symmetric: both overbought and oversold register as elevated, because exhaustion cuts both ways. Risk rises as RSI moves far from 50.")
ig8 = input.bool(false, "Liquidity - VIX level (COINCIDENT)", group=gL, tooltip="Absolute level of VIX. High implied volatility tends to coincide with thinner liquidity, wider spreads, and forced selling. A blunt but reliable coincident stress gauge. Risk rises as VIX climbs above its floor toward extreme levels.")
ig9 = input.bool(false, "Important limitations", group=gL, tooltip="These thresholds are reasoned starting points, NOT values calibrated against historical drawdowns - test them against past episodes (e.g. 2018, 2020, 2022) before relying on them. Several factors are correlated and move together in a selloff, so multiple confirmations can be one signal in disguise. No factor-based tool catches shock events (geopolitical, sudden policy surprises) that have no technical precursor. This is an educational/monitoring tool and not investment advice.")

// ============================================================
// SYMBOL INPUTS (override if a ticker does not resolve on your plan)
// ============================================================
gS = "Symbols"
symY10 = input.symbol("TVC:US10Y", "10Y yield", group=gS)
symY02 = input.symbol("TVC:US02Y", "2Y yield",  group=gS)
symOAS = input.symbol("FRED:BAMLH0A0HYM2", "HY OAS credit spread", group=gS, tooltip="BofA US High Yield OAS. FRED data; may not load on all plans.")
symBr  = input.symbol("INDEX:S5TH", "Breadth (% > 200d)", group=gS, tooltip="Percent of S&P 500 members above their 200-day MA.")

// ============================================================
// DAILY FACTOR PARAMETERS
// ============================================================
gD = "Daily factor parameters"
maFastD   = input.int(50,  "Daily Trend MA fast", minval=1, group=gD)
maSlowD   = input.int(200, "Daily Trend MA slow", minval=1, group=gD)
trendSensD= input.float(2.5, "Daily Trend sensitivity", step=0.1, group=gD)
volBaseD  = input.float(0.85, "Daily Vol base", step=0.01, group=gD)
volRangeD = input.float(0.30, "Daily Vol range", step=0.01, group=gD)
creditSmaD= input.int(50,  "Daily Credit SMA", minval=1, group=gD)
creditSensD=input.float(8.0, "Daily Credit sensitivity", step=0.5, group=gD)
rsiLenD   = input.int(14,  "Daily RSI length", minval=1, group=gD)
exhRangeD = input.float(35.0, "Daily Exhaustion range", step=1.0, group=gD)
vixFloorD = input.float(12.0, "Daily Liquidity VIX floor", step=0.5, group=gD)
vixRangeD = input.float(28.0, "Daily Liquidity VIX range", step=0.5, group=gD)
vixMaFastD= input.int(10,  "Daily Vol MA fast (Binary)", minval=1, group=gD)
vixMaSlowD= input.int(30,  "Daily Vol MA slow (Binary)", minval=1, group=gD)
curveInvD = input.float(0.0,  "Daily Curve inversion midpoint", step=0.1, group=gD)
curveRngD = input.float(1.5,  "Daily Curve range", step=0.1, group=gD)
oasBaseD  = input.float(3.0,  "Daily OAS base (pct)", step=0.25, group=gD)
oasRangeD = input.float(5.0,  "Daily OAS range (pct)", step=0.25, group=gD)
brFloorD  = input.float(80.0, "Daily Breadth high mark (pct)", step=1.0, group=gD)
brRangeD  = input.float(60.0, "Daily Breadth range (pct)", step=1.0, group=gD)

// ============================================================
// WEEKLY FACTOR PARAMETERS
// ============================================================
gW = "Weekly factor parameters"
maFastW   = input.int(10,  "Weekly Trend MA fast", minval=1, group=gW)
maSlowW   = input.int(40,  "Weekly Trend MA slow", minval=1, group=gW)
trendSensW= input.float(2.5, "Weekly Trend sensitivity", step=0.1, group=gW)
volBaseW  = input.float(0.85, "Weekly Vol base", step=0.01, group=gW)
volRangeW = input.float(0.30, "Weekly Vol range", step=0.01, group=gW)
creditSmaW= input.int(10,  "Weekly Credit SMA", minval=1, group=gW)
creditSensW=input.float(8.0, "Weekly Credit sensitivity", step=0.5, group=gW)
rsiLenW   = input.int(14,  "Weekly RSI length", minval=1, group=gW)
exhRangeW = input.float(40.0, "Weekly Exhaustion range", step=1.0, group=gW, tooltip="Larger than daily: weekly RSI is smoother and should saturate more slowly.")
vixFloorW = input.float(13.0, "Weekly Liquidity VIX floor", step=0.5, group=gW)
vixRangeW = input.float(25.0, "Weekly Liquidity VIX range", step=0.5, group=gW)
curveInvW = input.float(0.0,  "Weekly Curve inversion midpoint", step=0.1, group=gW)
curveRngW = input.float(1.5,  "Weekly Curve range", step=0.1, group=gW)
oasBaseW  = input.float(3.0,  "Weekly OAS base (pct)", step=0.25, group=gW)
oasRangeW = input.float(5.0,  "Weekly OAS range (pct)", step=0.25, group=gW)
brFloorW  = input.float(80.0, "Weekly Breadth high mark (pct)", step=1.0, group=gW)
brRangeW  = input.float(60.0, "Weekly Breadth range (pct)", step=1.0, group=gW)

txtSize = sizeOpt == "Tiny" ? size.tiny : sizeOpt == "Small" ? size.small : sizeOpt == "Normal" ? size.normal : sizeOpt == "Large" ? size.large : size.huge
tblPos  = posOpt == "Top Right" ? position.top_right : posOpt == "Top Left" ? position.top_left : posOpt == "Bottom Right" ? position.bottom_right : posOpt == "Bottom Left" ? position.bottom_left : position.middle_center

// ============================================================
// DAILY DATA
// ============================================================
spx   = request.security("SP:SPX",  "D", close, lookahead=barmerge.lookahead_off)
vix   = request.security("CBOE:VIX", "D", close, lookahead=barmerge.lookahead_off)
vix3m = request.security("CBOE:VIX3M","D", close, lookahead=barmerge.lookahead_off)
hyg   = request.security("AMEX:HYG", "D", close, lookahead=barmerge.lookahead_off)
lqd   = request.security("AMEX:LQD", "D", close, lookahead=barmerge.lookahead_off)
ma50  = request.security("SP:SPX", "D", ta.sma(close, maFastD),  lookahead=barmerge.lookahead_off)
ma200 = request.security("SP:SPX", "D", ta.sma(close, maSlowD),  lookahead=barmerge.lookahead_off)
rsiD  = request.security("SP:SPX", "D", ta.rsi(close, rsiLenD),  lookahead=barmerge.lookahead_off)
vix10 = request.security("CBOE:VIX", "D", ta.sma(close, vixMaFastD), lookahead=barmerge.lookahead_off)
vix30 = request.security("CBOE:VIX", "D", ta.sma(close, vixMaSlowD), lookahead=barmerge.lookahead_off)
hlAvg = request.security("AMEX:HYG", "D", ta.sma(close, creditSmaD), lookahead=barmerge.lookahead_off) / request.security("AMEX:LQD", "D", ta.sma(close, creditSmaD), lookahead=barmerge.lookahead_off)
y10D  = request.security(symY10, "D", close, lookahead=barmerge.lookahead_off)
y02D  = request.security(symY02, "D", close, lookahead=barmerge.lookahead_off)
oasD  = request.security(symOAS, "D", close, lookahead=barmerge.lookahead_off)
brD   = request.security(symBr,  "D", close, lookahead=barmerge.lookahead_off)

// ============================================================
// WEEKLY DATA
// ============================================================
spxW   = request.security("SP:SPX", "W", close, lookahead=barmerge.lookahead_off)
ma50W  = request.security("SP:SPX", "W", ta.sma(close, maFastW),  lookahead=barmerge.lookahead_off)
ma200W = request.security("SP:SPX", "W", ta.sma(close, maSlowW),  lookahead=barmerge.lookahead_off)
vixW   = request.security("CBOE:VIX", "W", close, lookahead=barmerge.lookahead_off)
vix3mW = request.security("CBOE:VIX3M","W", close, lookahead=barmerge.lookahead_off)
rsiW   = request.security("SP:SPX", "W", ta.rsi(close, rsiLenW), lookahead=barmerge.lookahead_off)
hygW   = request.security("AMEX:HYG", "W", close, lookahead=barmerge.lookahead_off)
lqdW   = request.security("AMEX:LQD", "W", close, lookahead=barmerge.lookahead_off)
hlAvgW = request.security("AMEX:HYG", "W", ta.sma(close, creditSmaW), lookahead=barmerge.lookahead_off) / request.security("AMEX:LQD", "W", ta.sma(close, creditSmaW), lookahead=barmerge.lookahead_off)
y10W  = request.security(symY10, "W", close, lookahead=barmerge.lookahead_off)
y02W  = request.security(symY02, "W", close, lookahead=barmerge.lookahead_off)
oasW  = request.security(symOAS, "W", close, lookahead=barmerge.lookahead_off)
brW   = request.security(symBr,  "W", close, lookahead=barmerge.lookahead_off)

// ============================================================
// DATA VALIDITY  (true only when every source the factor needs is present)
// ============================================================
okFloat(x) =>
    not na(x)

trendOK   = okFloat(spx)  and okFloat(ma50)  and okFloat(ma200) and okFloat(spxW) and okFloat(ma50W) and okFloat(ma200W)
volOK     = okFloat(vix)  and okFloat(vix3m) and okFloat(vixW)  and okFloat(vix3mW)
creditOK  = okFloat(hyg)  and okFloat(lqd)   and okFloat(hlAvg) and okFloat(hygW) and okFloat(lqdW) and okFloat(hlAvgW)
exhaustOK = okFloat(rsiD) and okFloat(rsiW)
liqOK     = okFloat(vix)  and okFloat(vixW)
curveOK   = okFloat(y10D) and okFloat(y02D)  and okFloat(y10W)  and okFloat(y02W)
spreadOK  = okFloat(oasD) and okFloat(oasW)
breadthOK = okFloat(brD)  and okFloat(brW)

// ============================================================
// HELPERS
// ============================================================
clamp01(x) =>
    math.max(0.0, math.min(1.0, x))

// ============================================================
// DAILY FACTOR SCORES
// ============================================================
d50  = (spx - ma50)  / ma50
d200 = (spx - ma200) / ma200
hl   = hyg / lqd

trendScore   = mode == "Binary" ? ((spx < ma50 ? 0.5 : 0.0) + (spx < ma200 ? 0.5 : 0.0)) : clamp01(0.5 - (d50 + d200) * trendSensD)
volScore     = mode == "Binary" ? (vix10 > vix30 ? 1.0 : 0.0) : clamp01((vix / vix3m - volBaseD) / volRangeD)
creditScore  = mode == "Binary" ? (hl < hlAvg ? 1.0 : 0.0)   : clamp01(((hlAvg - hl) / hlAvg) * creditSensD)
exhaustScore = mode == "Binary" ? (rsiD > 70 ? 1.0 : 0.0)    : clamp01(math.abs(rsiD - 50.0) / exhRangeD)
liqScore     = mode == "Binary" ? (vix > 20 ? 1.0 : 0.0)     : clamp01((vix - vixFloorD) / vixRangeD)
curveSpD     = y10D - y02D
curveScore   = clamp01(0.5 - (curveSpD - curveInvD) / curveRngD)
spreadScore  = clamp01((oasD - oasBaseD) / oasRangeD)
breadthScore = clamp01((brFloorD - brD) / brRangeD)

// ============================================================
// WEEKLY FACTOR SCORES (always continuous)
// ============================================================
d50W  = (spxW - ma50W)  / ma50W
d200W = (spxW - ma200W) / ma200W
hlWk  = hygW / lqdW

trendScoreW   = clamp01(0.5 - (d50W + d200W) * trendSensW)
volScoreW     = clamp01((vixW / vix3mW - volBaseW) / volRangeW)
creditScoreW  = clamp01(((hlAvgW - hlWk) / hlAvgW) * creditSensW)
exhaustScoreW = clamp01(math.abs(rsiW - 50.0) / exhRangeW)
liqScoreW     = clamp01((vixW - vixFloorW) / vixRangeW)
curveSpW      = y10W - y02W
curveScoreW   = clamp01(0.5 - (curveSpW - curveInvW) / curveRngW)
spreadScoreW  = clamp01((oasW - oasBaseW) / oasRangeW)
breadthScoreW = clamp01((brFloorW - brW) / brRangeW)

// ============================================================
// LABELS / COLORS
// ============================================================
riskOf(s) =>
    s < 0.25 ? "Low Risk" : s < 0.50 ? "Moderate Risk" : s < 0.75 ? "Elevated Risk" : "High Risk"

riskColor(s) =>
    s < 0.25 ? color.new(#1b873f, 0) : s < 0.50 ? color.new(#c9a227, 0) : s < 0.75 ? color.new(#d2691e, 0) : color.new(#c0392b, 0)

iconOf(curr, prev) =>
    curr > prev + 0.001 ? "[ + ]" : curr < prev - 0.001 ? "[ - ]" : "[ = ]"

iconColor(curr, prev) =>
    curr > prev + 0.001 ? color.new(#c0392b, 0) : curr < prev - 0.001 ? color.new(#1b873f, 0) : color.new(#7f8c8d, 0)

f(x) =>
    str.tostring(x, "0.00")

// ============================================================
// TABLE  (sections: LEADING then COINCIDENT)
// ============================================================
cols = showWk ? 5 : 4
var table dash = table.new(tblPos, cols, 11, border_width=2, border_color=color.new(color.black, 0), frame_width=2, frame_color=color.new(color.black, 0))
hdrBg  = color.new(#16202c, 0)
secBg  = color.new(#0b3d5c, 0)
rowBg  = color.new(#2c3e50, 0)

drawRow(r, name, s, prev, sw, ok) =>
    table.cell(dash, 0, r, name, text_size=txtSize, text_color=color.white, bgcolor=rowBg)
    naBg = color.new(#555555, 0)
    if ok
        table.cell(dash, 1, r, f(s),            text_size=txtSize, text_color=color.white, bgcolor=rowBg)
        table.cell(dash, 2, r, riskOf(s),       text_size=txtSize, text_color=color.white, bgcolor=riskColor(s))
        table.cell(dash, 3, r, iconOf(s, prev), text_size=txtSize, text_color=color.white, bgcolor=iconColor(s, prev))
        if showWk
            table.cell(dash, 4, r, riskOf(sw),  text_size=txtSize, text_color=color.white, bgcolor=riskColor(sw))
    else
        table.cell(dash, 1, r, "n/a",     text_size=txtSize, text_color=color.white, bgcolor=naBg)
        table.cell(dash, 2, r, "no data", text_size=txtSize, text_color=color.white, bgcolor=naBg)
        table.cell(dash, 3, r, "[ ? ]",   text_size=txtSize, text_color=color.white, bgcolor=naBg)
        if showWk
            table.cell(dash, 4, r, "n/a",  text_size=txtSize, text_color=color.white, bgcolor=naBg)

sectionRow(r, label) =>
    table.cell(dash, 0, r, label, text_size=txtSize, text_color=color.white, bgcolor=secBg)
    table.cell(dash, 1, r, "",    text_size=txtSize, text_color=color.white, bgcolor=secBg)
    table.cell(dash, 2, r, "",    text_size=txtSize, text_color=color.white, bgcolor=secBg)
    table.cell(dash, 3, r, "",    text_size=txtSize, text_color=color.white, bgcolor=secBg)
    if showWk
        table.cell(dash, 4, r, "", text_size=txtSize, text_color=color.white, bgcolor=secBg)

if barstate.islast
    table.cell(dash, 0, 0, "FACTOR", bgcolor=hdrBg, text_color=color.white, text_size=txtSize)
    table.cell(dash, 1, 0, "SCORE",  bgcolor=hdrBg, text_color=color.white, text_size=txtSize)
    table.cell(dash, 2, 0, "RISK",   bgcolor=hdrBg, text_color=color.white, text_size=txtSize)
    table.cell(dash, 3, 0, "DIR",    bgcolor=hdrBg, text_color=color.white, text_size=txtSize)
    if showWk
        table.cell(dash, 4, 0, "WKLY RISK", bgcolor=hdrBg, text_color=color.white, text_size=txtSize)

    sectionRow(1, "LEADING")
    drawRow(2, "Yield Curve",   curveScore,   curveScore[dirLookLead],   curveScoreW,   curveOK)
    drawRow(3, "Credit Spread", spreadScore,  spreadScore[dirLookLead],  spreadScoreW,  spreadOK)
    drawRow(4, "Breadth",       breadthScore, breadthScore[dirLook],     breadthScoreW, breadthOK)

    sectionRow(5, "COINCIDENT")
    drawRow(6,  "Trend",      trendScore,   trendScore[dirLook],   trendScoreW,   trendOK)
    drawRow(7,  "Volatility", volScore,     volScore[dirLook],     volScoreW,     volOK)
    drawRow(8,  "Credit",     creditScore,  creditScore[dirLook],  creditScoreW,  creditOK)
    drawRow(9,  "Exhaustion", exhaustScore, exhaustScore[dirLook], exhaustScoreW, exhaustOK)
    drawRow(10, "Liquidity",  liqScore,     liqScore[dirLook],     liqScoreW,     liqOK)
````
