# Liquidity Divergence Oscillator

- url: https://www.tradingview.com/script/gjTzodGB-Liquidity-Divergence-Oscillator/
- type: indicator
- pine_id: PUB;25c761866d67425382d43c6713aba462
- version: 3.0

## Description

Overview

Liquidity Divergence Oscillator is a distribution / absorption detector. It estimates liquidity health from Kyle's lambda — the price impact per unit of signed volume — and reads it for divergence against price. When price grinds to a higher high while liquidity health makes a lower high, large participants are often unloading size into strength (a distribution footprint); the mirror — price lower low, health higher low — is absorption. A forward-calibration harness scores whether those price/liquidity divergences have actually followed through on your instrument. It is a flow-structure read, not a signal to trade alone.

Why it is different — not another CVD/volume oscillator

CVD, the A/D line and MFI all measure the direction and amount of flow — who is buying or selling. Kyle's lambda measures something orthogonal: how much price moves per unit of that flow — the depth and fragility of the book. Price pushing to new highs while lambda quietly rises (liquidity thinning) is the classic footprint of size being distributed into strength, and no direction-only flow tool sees it. That impact axis is what makes a liquidity divergence its own, independent read — and it's why this belongs alongside your CVD tools rather than duplicating them. It's also distinct from a liquidity map: this is a standalone divergence oscillator, built to surface the turn, not to chart the shelves.

How the parts work as one tool


Signed volume — sv = volume × sign(price change), a tick-rule aggressor proxy.
Kyle's lambda — Cov(ΔP, sv) / Var(sv) over a rolling window: the regression slope of price change on signed flow, the standard lambda estimator. High = thin/stressed book, low = deep/liquid.
Liquidity health — −z(lambda), smoothed and tanh-squashed to a soft ±100 pane so "liquid vs stressed" reads on a fixed, self-scaling axis (0 = balance, ±50 ≈ a 1.6σ stretch).
Divergence — regular and hidden, from confirmed price pivots against health at those pivots.
Calibration harness — each regular divergence is queued and resolved a fixed horizon later against the unconditional base rate, reporting Hit / Edge / sample and a Wilson-gated star. A divergence class that never beats the base rate here is adding no information — and the dashboard shows that instead of assuming it.


How to use it

Read the oscillator's side and slope — above 0 is liquidity firming, below 0 is liquidity stressed. Treat a divergence mark as context (a distribution or absorption warning), never a standalone entry. Before you weight it, check the dashboard: if the Bull/Bear Edge isn't clearly positive with an adequate sample and a star, that class isn't carrying an edge on this instrument. Signals are marked in the pane and, optionally, on the price chart. Combine with your own levels, trend and risk rules — it describes behaviour; it decides nothing.

Universal & non-repainting

High/Low/Price are inputs, so the divergence engine runs on any series; the lambda estimate needs real volume, so use the futures (a cash index reads "no volume"). Pivots confirm a fixed number of bars after the fact and don't move once printed, and the calibration harness logs and resolves only on confirmed bars, so its statistics never repaint intrabar. The live oscillator updates each bar like any oscillator. Edge figures are in-sample, forward-measured at a fixed horizon, with no costs — a study aid, not a backtest.

Originality

Kyle's lambda and price/oscillator divergence are public; the Wilson interval is Edwin B. Wilson's. What's original is the specific construction: the detrend → z-score → tanh-squash liquidity-health oscillator built off the lambda estimate, the combined regular+hidden divergence engine keyed to it, and the forward-calibration harness that scores each divergence class against its base rate. Clean-room implementation; no third-party Pine code reused.

Concept credits


Price impact / lambda — Albert S. Kyle (1985)
Tick-rule aggressor signing — after the classic trade-sign literature (Lee & Ready)
Wilson score confidence interval — Edwin B. Wilson
Price/oscillator divergence — standard public technical-analysis technique


Disclaimer

Educational / informational only. Not financial advice, not a signal, not a recommendation. The lambda estimate uses tick-rule signed volume — a proxy, not the true tape — so liquidity health is an inference, not an order-book reading. Edge figures are in-sample, forward-measured with no costs. Past behaviour does not assure future behaviour. Markets carry risk. Do your own research and paper-trade before risking capital; you alone are responsible for your decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// LIQUIDITY DIVERGENCE OSCILLATOR                                                            v1.2
//  v1.2 (R1 · honest-stats standardization): robust-z via ml_robuststats/2 and the Wilson confidence math via
//    ml_calib/2 — both byte-identical to the prior local helpers, so the oscillator, the divergence marks and
//    every calibration number are UNCHANGED. Imports pinned to the exact published v2 versions.
// v1.1 — Three additive layers, all optional and reversible; the Kyle's-lambda engine, the
//   divergence detection and the forward-calibration base rate are otherwise unchanged:
//   • Robust MAD z-score + Ehlers UltimateSmoother (both default ON) via "Normalization" / "Smoother"
//     in the Engine group. Lambda spikes hard on stress bars; MAD ignores those outliers so the ±50
//     liquidity bands stay stable, and UltimateSmoother lags less. Set "Classic (mean/stdev)" / "SMA"
//     for the original v1.0 output.
//   • 3-window extreme consensus (opt-in, default off) — z as the MEDIAN of the z at half, one and
//     double the normalization window, so a reading is extreme only when short/medium/long agree.
//   • Walk-forward OUT-OF-SAMPLE reliability — the first N resolved divergences train, every one after
//     is scored out-of-sample and exported as EXP_OOSLongEdge / EXP_OOSShortEdge (the honest read).
//   The divergence detection is unchanged and no existing calibration output was altered.
// ────────────────────────────────────────────────────────────────────────────────────────────
// WHAT IT IS
//   A distribution / absorption detector. It estimates LIQUIDITY HEALTH from Kyle's lambda — the
//   price impact per unit of signed volume: a high lambda means price moves a lot per unit of flow
//   (a thin, stressed book); a low lambda means it absorbs flow with little movement (a deep, liquid
//   book). Detrended and bounded into a pane oscillator, then read for DIVERGENCE against price:
//   when price makes a higher high while liquidity health makes a LOWER high, large participants are
//   often unloading into strength (a distribution footprint); the mirror — price lower low, health
//   higher low — is absorption. A forward-calibration harness scores whether those price/liquidity
//   divergences have actually followed through. It is a flow-structure read, not a signal to trade alone.
//
// WHY IT IS DIFFERENT  (not another CVD / volume oscillator)
//   CVD, A/D and MFI all measure DIRECTION and amount of flow — who is buying or selling. Kyle's
//   lambda measures something orthogonal: how much price MOVES per unit of that flow — the depth /
//   fragility of the book. Price grinding to new highs while lambda quietly rises (liquidity thinning)
//   is the classic footprint of size being distributed into strength, and no direction-only flow tool
//   sees it. That impact axis is what makes a liquidity-divergence its own, independent read.
//
// HOW IT WORKS
//   • Signed volume: sv = volume × sign(price change)  (a tick-rule aggressor proxy).
//   • lambda = Cov(ΔP, sv) / Var(sv) over a rolling window — the regression slope of price change on
//     signed flow (the standard Kyle's-lambda estimator).
//   • LIQUIDITY HEALTH = −z(lambda), smoothed and tanh-squashed to a soft ±100 pane. 0 = balance;
//     the +50 band = notably liquid, the −50 band = notably stressed (~1.6σ).
//   • DIVERGENCE compares CONFIRMED price pivots against health at those pivots (regular + hidden).
//   • CALIBRATION queues each regular divergence and resolves it a fixed horizon later vs the
//     unconditional base rate, reporting Hit / Edge / sample and a Wilson-gated star.
//
// HOW TO USE
//   1. Read the oscillator side/slope: above 0 = liquidity firming, below 0 = liquidity stressed.
//   2. Treat a divergence as CONTEXT (distribution / absorption warning), never a standalone entry.
//   3. Check the dashboard: if the Bull/Bear Edge isn't clearly positive with an adequate sample and
//      a star, that class isn't carrying an edge on this instrument — weight it down.
//   4. Combine with your own levels, trend and risk rules. It describes behaviour; it decides nothing.
//
// UNIVERSAL ACROSS MARKETS
//   High / Low / Price are inputs, so the divergence engine runs on any series. The lambda estimate
//   needs REAL volume — use a futures contract (a cash index reports none and the dashboard reads
//   "no volume"). Defaults suit liquid index-futures intraday; change sources / lengths for any asset.
//
// NON-REPAINT
//   Pivots confirm pivLen bars after the fact and don't move once printed. The calibration harness
//   logs AND resolves only on barstate.isconfirmed, so its statistics never repaint intrabar. The
//   live oscillator value updates each bar (a current estimate), like any oscillator.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Health · EXP_Lambda · EXP_Div  (Div: +1 bull absorption, −1 bear distribution, 0 none)
//
// CONCEPT CREDIT
//   • Price impact / lambda — Albert S. Kyle (1985).
//   • Tick-rule aggressor signing — after the classic trade-sign literature (Lee & Ready).
//   • Wilson score confidence interval — Edwin B. Wilson.
//   • Price/oscillator divergence — standard public technical-analysis technique.
//   The detrend-and-squash liquidity-health construction, the divergence engine and the forward-
//   calibration harness are the author's original implementation. No third-party Pine code is reused.
//
// DISCLAIMER
//   EDUCATIONAL / INFORMATIONAL only. NOT financial advice, NOT a signal, NOT a recommendation. The
//   lambda estimate uses TICK-RULE signed volume — a proxy, not the true tape — so liquidity health is
//   an inference, not an order-book reading. Edge figures are in-sample, forward-measured at a fixed
//   horizon over overlapping windows, with no costs. Past behaviour does not assure future behaviour.
//   Markets carry risk. Do your own research and paper-trade before risking capital; you alone are
//   responsible for your decisions.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Liquidity Divergence Oscillator", "Liq Div", overlay = false, max_lines_count = 100, max_labels_count = 200)

// R1 · honest-stats standardization — robust-z and the Wilson confidence math are now routed through the
// published calibration libraries (one engine across the divergence family). Both are byte-identical to the
// prior local f_robZ / f_wilson, so the oscillator, the divergence marks and every calibration number are
// UNCHANGED — only where the math is computed moves into the libraries. Pinned to the exact published v2
// versions so a later library update can't silently change this script.
import Market_Logic_India/ml_calib/2        as calib
import Market_Logic_India/ml_robuststats/2  as rstat


// ── INPUTS ────────────────────────────────────────────────────────────────────────────────────
gData    = "1 · Data source"
srcPrice = input.source(close, "Price source", group = gData, tooltip = "Series used for the price-impact regression. Default = close.")
srcHigh  = input.source(high,  "High source (bearish divergence)", group = gData)
srcLow   = input.source(low,   "Low source (bullish divergence)",  group = gData)

gEng     = "2 · Liquidity engine"
winLen   = input.int(20,  "Regression window", minval = 5, maxval = 200, group = gEng, tooltip = "Window for the Cov/Var estimate of Kyle's lambda (price impact per unit signed volume).")
smoothLen= input.int(3,   "Smoothing", minval = 1, maxval = 30, group = gEng)
smootherType = input.string("UltimateSmoother (Wave A)", "Smoother", options = ["UltimateSmoother (Wave A)","SMA"], group = gEng, tooltip = "How lambda is smoothed. UltimateSmoother (Ehlers) is lag-minimal; SMA reproduces the original.")
normLen  = input.int(100, "Normalization window", minval = 20, maxval = 500, group = gEng, tooltip = "Window for the z-score that puts lambda onto a portable σ axis.")
zMode    = input.string("Robust (MAD)", "Normalization", options = ["Robust (MAD)","Classic (mean/stdev)"], group = gEng, tooltip = "Robust (MAD) standardizes lambda with median / median-absolute-deviation (×1.4826) — it ignores stress-bar spikes so the bands stay stable. Classic reproduces the original.")
zWinMode = input.string("Single window", "Extreme normalization (Wave D · U8)", options = ["Single window","3-window consensus"], group = gEng, tooltip = "Single window = the one Normalization window above (original). 3-window consensus = z is the MEDIAN of the z at half, one and double that window, so a reading is extreme only when short, medium and long agree. Default Single so nothing changes unless you opt in.")

gDiv     = "3 · Divergence"
pivLen   = input.int(5,  "Pivot L/R", minval = 1, maxval = 50, group = gDiv, tooltip = "Bars of confirmation each side of a pivot. Larger = sturdier pivots, longer confirmation delay.")
divLook  = input.int(60, "Max bars between pivots", minval = 5, maxval = 300, group = gDiv)
showHid  = input.bool(true, "Hidden divergences", group = gDiv)
drawLines= input.bool(true, "Draw divergence lines", group = gDiv)

gCal     = "4 · Calibration (forward)"
calOn    = input.bool(true, "Run forward calibration", group = gCal)
calHor   = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 200, group = gCal)
calMinN  = input.int(15, "Min sample for stars", minval = 5, maxval = 500, group = gCal)
wfTrainN = input.int(30, "In-sample signals before out-of-sample (walk-forward)", minval = 5, group = gCal, tooltip = "Wave E honesty: the first N resolved signals TRAIN (in-sample); every signal after is scored OUT-OF-SAMPLE. The OOS win-rate is the trustworthy one — an in-sample edge can flatter because the settings were chosen on that same data.")

gUI      = "5 · Dashboard & theme"
showTbl  = input.bool(true, "Show dashboard", group = gUI)
showOvl  = input.bool(true, "Mark signals on price (overlay)", group = gUI, tooltip = "Draw the regular-divergence triangles on the price chart as well as in the pane.")
tblPos   = input.string("Top Right", "Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = gUI)
dashTheme= input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = gUI)
colUp    = input.color(#2ebd85, "Bull / Up",   inline = "c", group = gUI)
colDn    = input.color(#f6465d, "Bear / Down", inline = "c", group = gUI)

// ── HELPERS ─────────────────────────────────────────────────────────────────────────────────
f_pos(string s) => s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : position.top_right
f_zscore(float s, int len) =>
    sd = ta.stdev(s, len)
    mn = ta.sma(s, len)
    sd == 0 ? 0.0 : (s - mn) / sd
// Ehlers UltimateSmoother (Wave A) — lag-minimal; no ta.* inside, safe under a selector.
ml_ultimateSmoother(series float src, simple int period) =>
    float q  = math.exp(-1.414 * math.pi / period)
    float c1 = 2.0 * q * math.cos(1.414 * math.pi / period)
    float c2 = q * q
    float a0 = (1.0 + c1 + c2) / 4.0
    float us = src
    if bar_index >= 4
        us := (1.0 - a0) * src + (2.0 * a0 - c1) * nz(src[1]) + (c2 - a0) * nz(src[2]) + c1 * nz(us[1]) - c2 * nz(us[2])
    us
f_tanh(float x) =>
    float xc = math.max(-10.0, math.min(10.0, x))
    float e  = math.exp(2 * xc)
    (e - 1) / (e + 1)
f_squash(float x, simple float k) => 100.0 * f_tanh(x / k)
f_star(float wl, float base, int n) =>
    n < calMinN or na(wl) or na(base) ? "n/a" : wl > base+5 ? "★★★" : wl > base ? "★★" : wl > base-5 ? "★" : "—"

// ── ENGINE ──────────────────────────────────────────────────────────────────────────────────
hasVol = ta.cum(nz(volume)) > 0
dP  = srcPrice - srcPrice[1]
sgn = dP > 0 ? 1.0 : dP < 0 ? -1.0 : 0.0
sv  = nz(volume) * sgn
mDp = ta.sma(dP, winLen)
mSv = ta.sma(sv, winLen)
cov = ta.sma(dP * sv, winLen) - mDp * mSv
varSv = ta.variance(sv, winLen)
lambda = varSv > 0 ? cov / varSv : 0.0
// Wave A: compute both smoothers + both z-scores unconditionally, then select
lamSma = ta.sma(lambda, smoothLen)
lamUlt = ml_ultimateSmoother(lambda, math.max(smoothLen, 2))
lamS = smoothLen > 1 ? (smootherType == "SMA" ? lamSma : lamUlt) : lambda
// U8 (Wave D): z at three windows (unconditional), select by mode, optional median consensus.
int   _wS = math.max(5, int(normLen / 2))
int   _wL = int(normLen * 2)
float _zcS = f_zscore(lamS, _wS), _zcM = f_zscore(lamS, normLen), _zcL = f_zscore(lamS, _wL)
float _zrS = rstat.robZ(lamS, _wS),  _zrM = rstat.robZ(lamS, normLen),  _zrL = rstat.robZ(lamS, _wL)
bool  _uCl = zMode == "Classic (mean/stdev)"
float _zS = _uCl ? _zcS : _zrS
float _zM = _uCl ? _zcM : _zrM
float _zL = _uCl ? _zcL : _zrL
float _zMed = _zS + _zM + _zL - math.min(_zS, math.min(_zM, _zL)) - math.max(_zS, math.max(_zM, _zL))
impZ = zWinMode == "Single window" ? _zM : _zMed
osc  = f_squash(-impZ, 3)          // liquidity health: high = liquid, low = stressed (~±50 at 1.6σ)

// ── DIVERGENCE ENGINE ─────────────────────────────────────────────────────────────────────────
ph  = ta.pivothigh(srcHigh, pivLen, pivLen)
pl  = ta.pivotlow(srcLow, pivLen, pivLen)
phC = not na(ph)
plC = not na(pl)
curX = bar_index - pivLen

oH  = osc[pivLen]
pHh = srcHigh[pivLen]
poH = ta.valuewhen(phC, osc[pivLen], 1)
ppH = ta.valuewhen(phC, srcHigh[pivLen], 1)
pxH = ta.valuewhen(phC, bar_index - pivLen, 1)
bearReg = phC and pHh > ppH and oH < poH and (curX - pxH <= divLook)
bearHid = showHid and phC and pHh < ppH and oH > poH and (curX - pxH <= divLook)

oL  = osc[pivLen]
pLl = srcLow[pivLen]
poL = ta.valuewhen(plC, osc[pivLen], 1)
ppL = ta.valuewhen(plC, srcLow[pivLen], 1)
pxL = ta.valuewhen(plC, bar_index - pivLen, 1)
bullReg = plC and pLl < ppL and oL > poL and (curX - pxL <= divLook)
bullHid = showHid and plC and pLl > ppL and oL < poL and (curX - pxL <= divLook)

bullDiv = bullReg or bullHid
bearDiv = bearReg or bearHid

if drawLines and bearReg
    line.new(int(pxH), poH, curX, oH, color = color.new(colDn, 30), width = 2)
if drawLines and bullReg
    line.new(int(pxL), poL, curX, oL, color = color.new(colUp, 30), width = 2)

// regular divergences are the events the harness scores (hidden are shown but not scored)
bullEval = bullReg and hasVol
bearEval = bearReg and hasVol
stTxt = not hasVol ? "no volume" : osc >= 0 ? "Liquid" : "Stressed"
wCol  = osc >= 0 ? colUp : colDn

// ── CALIBRATION (forward, non-repainting) ───────────────────────────────────────────────────────
var int buyN  = 0
var int buyW  = 0
var int sellN = 0
var int sellW = 0
var int baseN = 0
var int baseW = 0
// Wave E — walk-forward out-of-sample split (trustworthy reliability, additive)
var int   wfResolved = 0
var float wfBuyOosW = 0.0, var float wfBuyOosN = 0.0
var float wfSellOosW = 0.0, var float wfSellOosN = 0.0
canEval = calOn and barstate.isconfirmed and not na(close[calHor])
if canEval
    if bullEval[calHor]
        buyN += 1
        bool _wB = close > close[calHor]
        buyW += _wB ? 1 : 0
        wfResolved += 1
        if wfResolved > wfTrainN
            wfBuyOosN += 1.0
            wfBuyOosW := wfBuyOosW + (_wB ? 1.0 : 0.0)
    if bearEval[calHor]
        sellN += 1
        bool _wS = close < close[calHor]
        sellW += _wS ? 1 : 0
        wfResolved += 1
        if wfResolved > wfTrainN
            wfSellOosN += 1.0
            wfSellOosW := wfSellOosW + (_wS ? 1.0 : 0.0)
    baseN += 1
    baseW += close > close[calHor] ? 1 : 0
buyHit  = buyN  > 0 ? buyW  / buyN  * 100.0 : na
sellHit = sellN > 0 ? sellW / sellN * 100.0 : na
baseUp  = baseN > 0 ? baseW / baseN * 100.0 : na
baseDn  = baseN > 0 ? 100.0 - baseUp : na
buyEdge  = (not na(buyHit)  and not na(baseUp)) ? buyHit  - baseUp : na
sellEdge = (not na(sellHit) and not na(baseDn)) ? sellHit - baseDn : na

// Wave E — out-of-sample (walk-forward) win rates: the trustworthy read
float wfBuyOosHit  = wfBuyOosN  > 0 ? wfBuyOosW  / wfBuyOosN  * 100.0 : na
float wfSellOosHit = wfSellOosN > 0 ? wfSellOosW / wfSellOosN * 100.0 : na
float wfBuyOosEdge  = (not na(wfBuyOosHit)  and not na(baseUp)) ? wfBuyOosHit  - baseUp : na
float wfSellOosEdge = (not na(wfSellOosHit) and not na(baseDn)) ? wfSellOosHit - baseDn : na
buyStar  = f_star(calib.wilsonLo(buyW, buyN, 1.96),   baseUp, buyN)
sellStar = f_star(calib.wilsonLo(sellW, sellN, 1.96), baseDn, sellN)

// ── PLOTS ─────────────────────────────────────────────────────────────────────────────────────
pObIn  = plot(50.0,  "Liquid edge", color.new(colUp, 35), 1)
pObOut = plot(100.0, "Liquid cap",  color.new(colUp, 100), display = display.none)
fill(pObIn, pObOut, 100.0, 50.0, color.new(colUp, 18), color.new(colUp, 92), title = "Liquid")
pOsIn  = plot(-50.0,  "Stress edge", color.new(colDn, 35), 1)
pOsOut = plot(-100.0, "Stress cap",  color.new(colDn, 100), display = display.none)
fill(pOsIn, pOsOut, -50.0, -100.0, color.new(colDn, 92), color.new(colDn, 18), title = "Stressed")
hline(0, "Zero", color.new(color.gray, 60))

plot(osc, "Liquidity glow", color.new(wCol, 70), 8)
plot(osc, "Liquidity",      color.new(wCol, 0),  2)

plotshape(bullDiv ? oL : na, "Bull div", shape.circle, location.absolute, color.new(colUp, 0), offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? oH : na, "Bear div", shape.circle, location.absolute, color.new(colDn, 0), offset = -pivLen, size = size.tiny)
plotshape(showOvl and bullReg, "Bull mark", shape.triangleup,   location.belowbar, color.new(colUp, 0), size = size.tiny, force_overlay = true)
plotshape(showOvl and bearReg, "Bear mark", shape.triangledown, location.abovebar, color.new(colDn, 0), size = size.tiny, force_overlay = true)

// ── DASHBOARD ───────────────────────────────────────────────────────────────────────────────
var table st = table.new(f_pos(tblPos), 2, 8, frame_width = 1, border_width = 1)
if showTbl and barstate.islast
    color bgc     = chart.bg_color
    float lumaV   = na(bgc) ? 0.0 : color.r(bgc)*0.299 + color.g(bgc)*0.587 + color.b(bgc)*0.114
    bool  darkUI  = dashTheme=="Dark" ? true : dashTheme=="Light" ? false : (na(bgc) or lumaV < 140)
    color panelBg = darkUI ? color.rgb(17,22,28)    : color.rgb(244,246,248)
    color rowAlt  = darkUI ? color.rgb(25,31,39)    : color.rgb(232,236,240)
    color txtMain = darkUI ? color.white            : color.rgb(16,20,24)
    color txtSub  = darkUI ? color.rgb(154,166,178) : color.rgb(74,82,91)
    color frameC  = darkUI ? color.rgb(58,70,84)    : color.rgb(196,204,212)
    color upC     = darkUI ? colUp : color.rgb(22,151,106)
    color dnC     = darkUI ? colDn : color.rgb(210,45,68)
    color flatC   = darkUI ? color.gray : color.rgb(122,130,139)
    color hdr     = color.new(colUp, 0)
    string divTxt = bullDiv ? "Absorption (bull)" : bearDiv ? "Distribution (bear)" : "—"
    color  divC   = bullDiv ? upC : bearDiv ? dnC : flatC
    table.set_bgcolor(st, panelBg)
    table.set_frame_color(st, frameC)
    table.set_border_color(st, frameC)
    table.cell(st, 0, 0, "Liquidity Div", text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 1, 0, str.upper(stTxt), text_color = color.white, bgcolor = hdr, text_size = size.tiny)
    table.cell(st, 0, 1, "Health", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 1, 1, str.tostring(osc,"#"), text_color = osc>=0?upC:dnC, bgcolor = rowAlt, text_size = size.tiny)
    table.cell(st, 0, 2, "Divergence", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
    table.cell(st, 1, 2, divTxt, text_color = divC, bgcolor = panelBg, text_size = size.tiny)
    if calOn
        string baseTxt = (na(baseUp) or na(baseDn)) ? "warming" : "up " + str.tostring(baseUp,"0") + "  dn " + str.tostring(baseDn,"0")
        string buyTxt  = buyN  < calMinN ? "warm " + str.tostring(buyN)  : "H" + str.tostring(buyHit,"0")  + "  E" + (nz(buyEdge)>=0?"+":"")  + str.tostring(buyEdge,"0")  + "  (" + str.tostring(buyN) + ")"
        string sellTxt = sellN < calMinN ? "warm " + str.tostring(sellN) : "H" + str.tostring(sellHit,"0") + "  E" + (nz(sellEdge)>=0?"+":"") + str.tostring(sellEdge,"0") + "  (" + str.tostring(sellN) + ")"
        table.cell(st, 0, 3, "Base " + str.tostring(calHor) + "b", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 3, baseTxt, text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 0, 4, "Bull " + buyStar, text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 4, buyTxt, text_color = buyN<calMinN?flatC:upC, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 0, 5, "Bear " + sellStar, text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 5, sellTxt, text_color = sellN<calMinN?flatC:dnC, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 0, 6, "Note", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 1, 6, "proxy flow · context only", text_color = txtSub, bgcolor = panelBg, text_size = size.tiny)
        table.cell(st, 0, 7, "OOS win (walk-fwd)", text_color = txtSub, bgcolor = rowAlt, text_size = size.tiny)
        table.cell(st, 1, 7, (wfBuyOosN < 1 and wfSellOosN < 1) ? "warming" : "L " + (na(wfBuyOosHit) ? "-" : str.tostring(wfBuyOosHit, "0") + "%") + "  S " + (na(wfSellOosHit) ? "-" : str.tostring(wfSellOosHit, "0") + "%"), text_color = txtMain, bgcolor = rowAlt, text_size = size.tiny)

// ── EXPORTS / ALERTS ──────────────────────────────────────────────────────────────────────────
plot(osc,    "EXP_Health", color.new(color.gray,100), display = display.data_window)
plot(lambda, "EXP_Lambda", color.new(color.gray,100), display = display.data_window)
plot(bullDiv ? 1 : bearDiv ? -1 : 0, "EXP_Div", color.new(color.gray,100), display = display.data_window)
plot(wfBuyOosEdge,  "EXP_OOSLongEdge",  color.new(color.gray,100), display = display.data_window)
plot(wfSellOosEdge, "EXP_OOSShortEdge", color.new(color.gray,100), display = display.data_window)
alertcondition(bullReg, "Bullish Absorption", "Liquidity Div: bullish absorption (price down, liquidity firming) — context")
alertcondition(bearReg, "Bearish Distribution", "Liquidity Div: bearish distribution (price up, liquidity deteriorating) — context")
alertcondition(ta.crossover(osc, 0),  "Liquidity Firming", "Liquidity Div: health crossed above zero (firming)")
alertcondition(ta.crossunder(osc, 0), "Liquidity Stressing", "Liquidity Div: health crossed below zero (stressing)")
````
