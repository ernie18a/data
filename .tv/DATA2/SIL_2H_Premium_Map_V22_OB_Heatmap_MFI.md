<!-- tradingview-pine-id: PUB;c64bbcd4efbf4b5c855ec612879c7afc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SIL 2H Premium Map V22 [OB + Heatmap + MFI]

Source: https://www.tradingview.com/script/yvpJO0CY/

## Description

WHAT THIS IS

This indicator is a higher-timeframe "regime map," designed for a 2-hour chart (defaults tuned for micro silver futures, but every symbol and driver is an input). It answers three questions on one screen: what regime is the market in (trend, premium/discount, money flow), where are the levels that matter (displacement order blocks, equilibrium, VWAP), and what does recent history suggest happens next (a probability fan over the next 8 hours, with a percentage on each path).

HOW THE PREDICTION IS FORMED

The engine is a Bernoulli Naive Bayes classifier fit by maximum likelihood on a rolling window (default 500 bars). Each bar, 14 binary features are recorded — 8 from price/volume (2H trend vs EMA20, 4H trend, discount vs equilibrium, VWAP side, structure, volume vs average, volume rising, MFI above 50) and 6 from cross-asset drivers (gold, DXY, gold/silver ratio, copper, 2Y yield, a volatility index — all symbol inputs). For each feature, the script counts how often it coincided with the market rising vs falling over the following N bars (default 4 = 8 hours). Those frequencies are the maximum-likelihood estimates of each feature's predictive weight: features that predicted well get large log-likelihood ratios, useless ones converge to zero. The weights are re-estimated every bar, so the model adapts to regime changes with no manual tuning. The result is P(up), shown as the triangle and its percentage.

THE PROBABILITY FAN

The fan extends five dotted rays from the current close to five targets one horizon ahead: ±2 ATR, ±1 ATR (ATR scaled by √horizon), and flat. Each ray's percentage is the empirical frequency of that size of move in the training window, tilted by the model's current directional odds, renormalized to 100%. Ray thickness encodes probability. Read the shape, not just the lean: a fat middle ray means "drift expected"; fat outer rays with a thin middle mean "big move brewing, direction uncertain."

ORDER BLOCKS

A displacement bar (body > 1.5 ATR closing beyond the prior bar's extreme) marks the previous opposite-colored candle as an order block — supply above, demand below. Blocks born on above-average volume are tagged OB+ with a solid border. Blocks expire after a set lifespan (default 24h) or immediately when price closes through them (mitigation).

READING THE PANEL (bottom-right, top to bottom)

4H·8H — higher-timeframe trend agreement (green BULL / red BEAR / gray MIX). Hover for the daily trend.
P↑ — the model's probability of the market being higher in 8 hours. Green ≥ ~60, red ≤ ~40, gray = coin flip.
MAC — macro consensus from the six drivers, −5 (all hostile) to +5 (all supportive). Hover shows the drivers and a HI-VOL tag when the volatility index is elevated.
LOC — PREM/DISC: price above or below the 50% equilibrium of the recent swing range.
MFI — money flow IN/OUT (volume-weighted RSI). Red price bars with MFI drifting green is a classic accumulation divergence.
V-6h / V-4h / V-2h — the last three 2H bars: cell color = that bar's price direction, text = its volume vs the bar before (UP 2.3 = expanding). Red+UP = heavy selling; red+DN = selling drying up.
PLAY — trend × location playbook: BUY (bull trend + discount), SELL (bear trend + premium), WAIT otherwise.

KEY PARAMETERS

MLE horizon (bars ahead to predict) and training window; order-block displacement multiple, lifespan, and volume-quality threshold; equilibrium swing lookback; the six macro symbols (swap them to repurpose for any market — e.g., for gold use DXY, 10Y yield, real yields, breakevens, silver, GVZ); toggles for the fan, labels, and macro features.

HONEST LIMITATIONS

Probabilities are learned from recent history — after a news shock they need time to re-adapt, and on thin overnight volume they mean little. The Naive Bayes independence assumption makes extreme readings somewhat overconfident; treat 65% as a lean, not a promise. Values on the live bar update until it closes. This is a decision-support map, not a signal service, and nothing here is financial advice.

---

## Source Code

````pine
//@version=6
indicator("SIL 2H Premium Map V22 [OB + Heatmap + MFI]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. INPUTS & THEME
// ==========================================
blocks_back  = input.int(20,  "Structure Blocks Lookback", minval=5, maxval=100)
eqLen        = input.int(30,  "Equilibrium Swing Lookback (2H bars)", minval=10, maxval=100)

show_line_lbl = input.bool(true, "Show Line Name Labels", group="Display")

obDispMult   = input.float(1.5, "OB: Displacement (ATR mult)", step=0.25, group="Order Blocks", tooltip="A bar whose body exceeds this many ATRs AND closes beyond the prior bar's extreme counts as displacement. The last opposite candle before it becomes the order block.")
obHours      = input.float(24,  "OB: Block Lifespan (hours)",  minval=2, maxval=96, step=2, group="Order Blocks")
maxZones     = input.int(6,     "OB: Max Blocks per Side",     minval=2, maxval=20, group="Order Blocks")
obVolMult    = input.float(1.2, "OB: High-Quality Volume Mult", step=0.1, group="Order Blocks", tooltip="Displacement on volume above this multiple of average marks the block OB+ (solid border).")

horizonN     = input.int(4,    "MLE: Outcome Horizon (bars)", minval=2,   maxval=20,   group="MLE Prediction", tooltip="On a 2H chart, 4 bars = next 8 hours")
trainLen     = input.int(500,  "MLE: Training Window (bars)", minval=100, maxval=2000, group="MLE Prediction")

use_macro = input.bool(true, "Use Macro Features", group="Macro MLE")
goldSym   = input.symbol("COMEX:GC1!",     "Gold",              group="Macro MLE")
dxySym    = input.symbol("TVC:DXY",        "US Dollar Index",   group="Macro MLE")
gsrSym    = input.symbol("TVC:GOLDSILVER", "Gold/Silver Ratio", group="Macro MLE")
copperSym = input.symbol("COMEX:HG1!",     "Copper",            group="Macro MLE")
us2ySym   = input.symbol("TVC:US02Y",      "2Y Yield",          group="Macro MLE")
vxslvSym  = input.symbol("CBOE:VXSLV",     "Silver Vol Index",  group="Macro MLE")

c_black   = #000000
c_gold    = #FFD700
c_silver  = #C0C0C0
c_2h_col  = color.rgb(208, 5, 113)
c_4h_col  = color.orange
c_bull_bg = color.new(#089981, 92)
c_bear_bg = color.new(#F23645, 92)
c_up_tri  = #089981
c_dn_tri  = #F23645
c_hot_grn = #00c853
c_hot_red = #ff1744

// ==========================================
// 2. HTF DATA - silver ladder: 2H chart / 4H + 8H bias / D context
// Daily and weekly move too slowly for silver's regime flips;
// 4H + 8H catch them within hours while still filtering 2H noise.
// ==========================================
ema2h = ta.ema(close, 20)   // chart IS 2H - no security call needed
trend2h_up = (close > ema2h) and (close > open)
trend2h_dn = (close < ema2h) and (close < open)

[c4, o4, ema4h] = request.security(syminfo.tickerid, "240", [close, open, ta.ema(close, 20)])
[c8, o8, ema8h] = request.security(syminfo.tickerid, "480", [close, open, ta.ema(close, 20)])
[cD, oD, emaD]  = request.security(syminfo.tickerid, "D",   [close, open, ta.ema(close, 20)])

trend4h_up = (c4 > ema4h) and (c4 > o4)
trend4h_dn = (c4 < ema4h) and (c4 < o4)
trend8h_up = (c8 > ema8h) and (c8 > o8)
trend8h_dn = (c8 < ema8h) and (c8 < o8)
trendD_up  = cD > emaD
trendD_dn  = cD < emaD

htf_bull = trend4h_up and trend8h_up
htf_bear = trend4h_dn and trend8h_dn

// ==========================================
// 3. VWAP + EQUILIBRIUM
// ==========================================
vwapValue = ta.vwap(close)
swingH    = ta.highest(high, eqLen)
swingL    = ta.lowest(low,  eqLen)
equil     = math.avg(swingH, swingL)

in_premium  = close > equil
in_discount = close < equil

plot(vwapValue, "VWAP (Value Line)", color=color.new(c_silver, 50), linewidth=2)
plot(ema2h,     "2H EMA20",          color=c_2h_col, linewidth=2)
plot(ema4h,     "4H EMA20",          color=c_4h_col, linewidth=2, style=plot.style_stepline)
plot(equil,     "Equilibrium 50%",   color=color.new(c_gold, 30), linewidth=2, style=plot.style_circles)

// ==========================================
// LINE NAME LABELS
// ==========================================
var label lbl_v  = na
var label lbl_2h = na
var label lbl_4h = na
var label lbl_eq = na

if barstate.islast and show_line_lbl
    label.delete(lbl_v)
    label.delete(lbl_2h)
    label.delete(lbl_4h)
    label.delete(lbl_eq)
    lbl_v  := label.new(bar_index + 2, vwapValue, "VWAP",   xloc=xloc.bar_index, textcolor=color.new(c_silver, 30), style=label.style_none, size=size.small)
    lbl_2h := label.new(bar_index + 2, ema2h,     "2H EMA", xloc=xloc.bar_index, textcolor=c_2h_col,               style=label.style_none, size=size.small)
    lbl_4h := label.new(bar_index + 2, ema4h,     "4H EMA", xloc=xloc.bar_index, textcolor=c_4h_col,               style=label.style_none, size=size.small)
    lbl_eq := label.new(bar_index + 2, equil,     "EQ 50%", xloc=xloc.bar_index, textcolor=c_gold,                 style=label.style_none, size=size.small)

// ==========================================
// 4. MACRO DATA
// ==========================================
macro_above(string sym) =>
    [mc, me] = request.security(sym, "120", [close, ta.ema(close, 20)])
    fixnan(mc) > fixnan(me) ? 1.0 : 0.0

x8  = use_macro ? macro_above(goldSym)   : 0.0
x9  = use_macro ? macro_above(dxySym)    : 0.0
x10 = use_macro ? macro_above(gsrSym)    : 0.0
x11 = use_macro ? macro_above(copperSym) : 0.0
x12 = use_macro ? macro_above(us2ySym)   : 0.0
x13 = use_macro ? macro_above(vxslvSym)  : 0.0

// ==========================================
// 5. MLE PREDICTION ENGINE (14 features: 8 price/volume + 6 macro)
// x2 = 4H trend (silver's true HTF), x7 = volume rising,
// x14 = money flow (MFI - the only DIRECTIONAL volume feature)
// ==========================================
volMA  = ta.sma(volume, 20)
mfiVal = ta.mfi(hlc3, 20)   // 20 x 2H ≈ 40 hours - matches the 8hr horizon

x1  = trend2h_up          ? 1.0 : 0.0
x2  = trend4h_up          ? 1.0 : 0.0
x3  = in_discount         ? 1.0 : 0.0
x4  = close > vwapValue   ? 1.0 : 0.0
x5  = high[1] > high[2]   ? 1.0 : 0.0     // structure: prior bar made higher high
x6  = volume > volMA      ? 1.0 : 0.0
x7  = volume > volume[1]  ? 1.0 : 0.0     // participation rising bar-over-bar
x14 = mfiVal > 50         ? 1.0 : 0.0     // money flowing in vs out

outUp = close > close[horizonN] ? 1.0 : 0.0
outDn = 1.0 - outUp

nUp = math.sum(outUp, trainLen)
nDn = math.sum(outDn, trainLen)

llr_term(float cU, float cD, bool xNow) =>
    pUp = (cU + 1.0) / (nUp + 2.0)
    pDn = (cD + 1.0) / (nDn + 2.0)
    xNow ? math.log(pUp / pDn) : math.log((1.0 - pUp) / (1.0 - pDn))

c1u  = math.sum(outUp * x1[horizonN],  trainLen)
c1d  = math.sum(outDn * x1[horizonN],  trainLen)
c2u  = math.sum(outUp * x2[horizonN],  trainLen)
c2d  = math.sum(outDn * x2[horizonN],  trainLen)
c3u  = math.sum(outUp * x3[horizonN],  trainLen)
c3d  = math.sum(outDn * x3[horizonN],  trainLen)
c4u  = math.sum(outUp * x4[horizonN],  trainLen)
c4d  = math.sum(outDn * x4[horizonN],  trainLen)
c5u  = math.sum(outUp * x5[horizonN],  trainLen)
c5d  = math.sum(outDn * x5[horizonN],  trainLen)
c6u  = math.sum(outUp * x6[horizonN],  trainLen)
c6d  = math.sum(outDn * x6[horizonN],  trainLen)
c7u  = math.sum(outUp * x7[horizonN],  trainLen)
c7d  = math.sum(outDn * x7[horizonN],  trainLen)
c8u  = math.sum(outUp * x8[horizonN],  trainLen)
c8d  = math.sum(outDn * x8[horizonN],  trainLen)
c9u  = math.sum(outUp * x9[horizonN],  trainLen)
c9d  = math.sum(outDn * x9[horizonN],  trainLen)
c10u = math.sum(outUp * x10[horizonN], trainLen)
c10d = math.sum(outDn * x10[horizonN], trainLen)
c11u = math.sum(outUp * x11[horizonN], trainLen)
c11d = math.sum(outDn * x11[horizonN], trainLen)
c12u = math.sum(outUp * x12[horizonN], trainLen)
c12d = math.sum(outDn * x12[horizonN], trainLen)
c13u = math.sum(outUp * x13[horizonN], trainLen)
c13d = math.sum(outDn * x13[horizonN], trainLen)
c14u = math.sum(outUp * x14[horizonN], trainLen)
c14d = math.sum(outDn * x14[horizonN], trainLen)

llr = math.log((nUp + 1.0) / (nDn + 1.0))
llr += llr_term(c1u, c1d, x1 == 1.0)
llr += llr_term(c2u, c2d, x2 == 1.0)
llr += llr_term(c3u, c3d, x3 == 1.0)
llr += llr_term(c4u, c4d, x4 == 1.0)
llr += llr_term(c5u, c5d, x5 == 1.0)
llr += llr_term(c6u, c6d, x6 == 1.0)
llr += llr_term(c7u, c7d, x7 == 1.0)
llr += llr_term(c14u, c14d, x14 == 1.0)
if use_macro
    llr += llr_term(c8u,  c8d,  x8  == 1.0)
    llr += llr_term(c9u,  c9d,  x9  == 1.0)
    llr += llr_term(c10u, c10d, x10 == 1.0)
    llr += llr_term(c11u, c11d, x11 == 1.0)
    llr += llr_term(c12u, c12d, x12 == 1.0)
    llr += llr_term(c13u, c13d, x13 == 1.0)

mle_ready = bar_index > trainLen + horizonN + 10
p_up = mle_ready ? 100.0 / (1.0 + math.exp(-llr)) : 50.0
p_dn = 100.0 - p_up
pred_up = p_up >= p_dn

// ==========================================
// 6. TRIANGLE PREDICTION ON PRICE MAP
// ==========================================
atr2 = ta.atr(14)

var label tri_lbl = na
var label pct_lbl = na
var label ctx_lbl = na

if barstate.islast
    label.delete(tri_lbl)
    label.delete(pct_lbl)
    label.delete(ctx_lbl)

    triColor = pred_up ? c_up_tri : c_dn_tri
    prob     = pred_up ? p_up : p_dn
    triFade  = prob >= 65 ? 0 : prob >= 55 ? 30 : 60
    triFinal = color.new(triColor, triFade)

    y_tri    = pred_up ? close - atr2 * 1.2 : close + atr2 * 1.2
    triStyle = pred_up ? label.style_triangleup : label.style_triangledown
    tri_lbl := label.new(bar_index + 2, y_tri, "", xloc=xloc.bar_index, color=triFinal, style=triStyle, size=size.normal)

    pctTxt = mle_ready ? str.format("{0,number,#}%", prob) : "…"
    y_pct = pred_up ? close - atr2 * 2.2 : close + atr2 * 2.2
    pct_lbl := label.new(bar_index + 2, y_pct, pctTxt, xloc=xloc.bar_index, textcolor=triColor, style=label.style_none, size=size.large)

    int mScore = 0
    mScore += x8  == 1.0 ? 1 : -1
    mScore += x9  == 0.0 ? 1 : -1
    mScore += x10 == 0.0 ? 1 : -1
    mScore += x11 == 1.0 ? 1 : -1
    mScore += x12 == 0.0 ? 1 : -1
    string mTag = use_macro ? str.format(" · M{0}{1}", mScore > 0 ? "+" : "", mScore) : ""
    ctxTxt = (trend2h_up ? "BULL" : trend2h_dn ? "BEAR" : "FLAT") + " · " + (in_premium ? "PREM" : "DISC") + mTag + (x13 == 1.0 ? " · HI-VOL" : "")
    y_ctx = pred_up ? close - atr2 * 3.0 : close + atr2 * 3.0
    ctx_lbl := label.new(bar_index + 2, y_ctx, ctxTxt, xloc=xloc.bar_index, textcolor=c_silver, style=label.style_none, size=size.small)

// ==========================================
// 7. ORDER BLOCKS (supply & demand, displacement-based)
// Bearish OB (supply): last UP candle before a bar whose body > k*ATR
// closing below the prior low. Bullish OB (demand): mirrored.
// High-volume displacement = OB+ (solid border). Blocks live obHours,
// die early if mitigated (close through the far side).
// ==========================================
bodySize = math.abs(close - open)
dispDn = bodySize > atr2 * obDispMult and close < low[1]  and close < open
dispUp = bodySize > atr2 * obDispMult and close > high[1] and close > open

var box[] supplyOB = array.new<box>()
var box[] demandOB = array.new<box>()

ob_ms = int(obHours * 3600 * 1000)

if dispDn and close[1] >= open[1]
    isHQ = volume > volMA * obVolMult
    b = box.new(time[1], high[1], time[1] + ob_ms, low[1], xloc=xloc.bar_time, bgcolor=color.new(#F23645, isHQ ? 75 : 85), border_color=color.new(#F23645, isHQ ? 0 : 50), border_width=isHQ ? 2 : 1, text=isHQ ? "OB+ SUPPLY" : "OB SUPPLY", text_size=size.tiny, text_color=color.white)
    array.push(supplyOB, b)
    if array.size(supplyOB) > maxZones
        box.delete(array.shift(supplyOB))

if dispUp and close[1] <= open[1]
    isHQ = volume > volMA * obVolMult
    b = box.new(time[1], high[1], time[1] + ob_ms, low[1], xloc=xloc.bar_time, bgcolor=color.new(#089981, isHQ ? 75 : 85), border_color=color.new(#089981, isHQ ? 0 : 50), border_width=isHQ ? 2 : 1, text=isHQ ? "OB+ DEMAND" : "OB DEMAND", text_size=size.tiny, text_color=color.white)
    array.push(demandOB, b)
    if array.size(demandOB) > maxZones
        box.delete(array.shift(demandOB))

if array.size(supplyOB) > 0
    for i = array.size(supplyOB) - 1 to 0
        b = array.get(supplyOB, i)
        if close > box.get_top(b)
            box.delete(b)
            array.remove(supplyOB, i)
if array.size(demandOB) > 0
    for i = array.size(demandOB) - 1 to 0
        b = array.get(demandOB, i)
        if close < box.get_bottom(b)
            box.delete(b)
            array.remove(demandOB, i)

// ==========================================
// 8. 2H STRUCTURE STAIRCASE (leak-free)
// ==========================================
var box[]  hist_boxes = array.new<box>()
var line[] hist_lines = array.new<line>()

if barstate.islast
    for b in hist_boxes
        box.delete(b)
    for l in hist_lines
        line.delete(l)
    array.clear(hist_boxes)
    array.clear(hist_lines)

    tf_ms = timeframe.in_seconds() * 1000
    for i = 0 to blocks_back - 1
        bg_col = close[i] >= open[i] ? c_bull_bg : c_bear_bg
        bx = box.new(time[i], high[i], time[i] + tf_ms, low[i], xloc=xloc.bar_time, border_color=color.new(c_silver, 85), bgcolor=bg_col)
        array.push(hist_boxes, bx)
        if i < blocks_back - 1
            ln = line.new(time[i] + tf_ms / 2, math.avg(high[i], low[i]), time[i + 1] + tf_ms / 2, math.avg(high[i + 1], low[i + 1]), xloc=xloc.bar_time, color=color.new(c_gold, 60), width=1)
            array.push(hist_lines, ln)

// ==========================================
// 9. HEATMAP HUD - vertical, 9 rows incl. volume tape + money flow
// ==========================================
var table hud = table.new(position.bottom_right, 2, 9, bgcolor=color.new(color.black, 10), border_width=2, border_color=color.new(color.black, 0))

grad(float v) =>
    v >= 50 ? color.from_gradient(v, 50, 65, color.new(color.gray, 30), c_hot_grn) : color.from_gradient(v, 35, 50, c_hot_red, color.new(color.gray, 30))

vol_cell_col(int i) =>
    up = close[i] >= open[i]
    color.new(up ? #089981 : #F23645, 15)

vol_cell_txt(int i) =>
    ratio = volume[i] / math.max(volume[i + 1], 1)
    (ratio >= 1.0 ? "UP " : "DN ") + str.tostring(ratio, "#.#")

if barstate.islast
    float v_bias = htf_bull ? 100 : htf_bear ? 0 : 50

    int macroScore = 0
    macroScore += x8  == 1.0 ? 1 : -1
    macroScore += x9  == 0.0 ? 1 : -1
    macroScore += x10 == 0.0 ? 1 : -1
    macroScore += x11 == 1.0 ? 1 : -1
    macroScore += x12 == 0.0 ? 1 : -1
    float v_macro = 50 + macroScore * 12

    string playTxt = trend2h_up and in_discount ? "BUY" : trend2h_dn and in_premium ? "SELL" : trend2h_up or trend2h_dn ? "WAIT" : "—"
    color  playCol = playTxt == "BUY" ? c_hot_grn : playTxt == "SELL" ? c_hot_red : color.new(color.gray, 30)

    string dTag = trendD_up ? "D:up" : trendD_dn ? "D:dn" : "D:flat"

    table.cell(hud, 0, 0, "4H·8H", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 0, htf_bull ? "BULL" : htf_bear ? "BEAR" : "MIX", bgcolor=grad(v_bias), text_color=color.white, text_size=size.normal, tooltip="4H+8H trend agreement (silver's true HTF - daily/weekly lag its regime flips) · Daily background: " + dTag)

    table.cell(hud, 0, 1, "P↑", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 1, mle_ready ? str.format("{0,number,#}", p_up) : "…", bgcolor=grad(p_up), text_color=color.white, text_size=size.normal, tooltip="MLE P(Up), 8hr horizon (14 features incl. money flow)")

    table.cell(hud, 0, 2, "MAC", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 2, str.format("{0}{1}", macroScore > 0 ? "+" : "", macroScore), bgcolor=grad(v_macro), text_color=color.white, text_size=size.normal, tooltip="Macro consensus -5..+5 (gold/DXY/ratio/copper/2Y)" + (x13 == 1.0 ? " · HI-VOL (VXSLV elevated)" : ""))

    table.cell(hud, 0, 3, "LOC", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 3, in_premium ? "PREM" : "DISC", bgcolor=in_premium ? color.new(#F23645, 40) : color.new(#089981, 40), text_color=color.white, text_size=size.normal, tooltip="Price vs 50% equilibrium of the " + str.tostring(eqLen) + "-bar 2H swing range")

    table.cell(hud, 0, 4, "MFI", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 4, mfiVal > 50 ? "IN" : "OUT", bgcolor=grad(mfiVal), text_color=color.white, text_size=size.normal, tooltip="Money flow (volume-weighted RSI, 20 bars): IN = buying pressure dominates, OUT = selling. Watch for divergence vs price - BEAR bias + money IN often precedes the bounce.")

    table.cell(hud, 0, 5, "V-6h", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 5, vol_cell_txt(2), bgcolor=vol_cell_col(2), text_color=color.white, text_size=size.normal, tooltip="2H bar 6h ago: color = price direction, text = volume vs the bar before it")

    table.cell(hud, 0, 6, "V-4h", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 6, vol_cell_txt(1), bgcolor=vol_cell_col(1), text_color=color.white, text_size=size.normal, tooltip="2H bar 4h ago: color = price direction, text = volume vs the bar before it")

    table.cell(hud, 0, 7, "V-2h", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 7, vol_cell_txt(0), bgcolor=vol_cell_col(0), text_color=color.white, text_size=size.normal, tooltip="Current 2H bar (live): color = price direction, text = volume vs prior bar")

    table.cell(hud, 0, 8, "PLAY", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 8, playTxt, bgcolor=playCol, text_color=color.white, text_size=size.normal, tooltip="2H trend x location playbook: BUY = bull+discount, SELL = bear+premium, WAIT = trend but wrong location")
    // ==========================================
// PROBABILITY FAN - five forward rays, one % each (sums to 100)
// Base odds = empirical frequency of 8hr moves in ATR buckets over
// the training window; tilted by the MLE's directional odds.
// ==========================================
show_fan = input.bool(true, "Show Probability Fan", group="Prediction Fan")

atrH = atr2 * math.sqrt(horizonN)   // expected 1-sigma move over the horizon

// realized horizon move in ATR units, at each historical bar
mvATR = (close - close[horizonN]) / math.max(atr2[horizonN] * math.sqrt(horizonN), syminfo.mintick)

b1 = mvATR >=  1.5 ? 1.0 : 0.0                    // strong up
b2 = mvATR >=  0.5 and mvATR <  1.5 ? 1.0 : 0.0   // up
b3 = mvATR >  -0.5 and mvATR <  0.5 ? 1.0 : 0.0   // flat
b4 = mvATR >  -1.5 and mvATR <= -0.5 ? 1.0 : 0.0  // down
b5 = mvATR <= -1.5 ? 1.0 : 0.0                    // strong down

q1 = math.sum(b1, trainLen)
q2 = math.sum(b2, trainLen)
q3 = math.sum(b3, trainLen)
q4 = math.sum(b4, trainLen)
q5 = math.sum(b5, trainLen)

// tilt by MLE directional odds, then renormalize to 100
oddsUp = p_up / math.max(p_dn, 1.0)
w1 = (q1 + 1) * oddsUp
w2 = (q2 + 1) * math.sqrt(oddsUp)
w3 = q3 + 1
w4 = (q4 + 1) / math.sqrt(oddsUp)
w5 = (q5 + 1) / oddsUp
wT = w1 + w2 + w3 + w4 + w5
f1 = 100.0 * w1 / wT
f2 = 100.0 * w2 / wT
f3 = 100.0 * w3 / wT
f4 = 100.0 * w4 / wT
f5 = 100.0 * w5 / wT

var line[]  fan_lines  = array.new<line>()
var label[] fan_labels = array.new<label>()

fan_ray(float tgt, float pct, color col) =>
    w = pct >= 30 ? 3 : pct >= 15 ? 2 : 1                      // ray thickness = probability
    fl = line.new(bar_index, close, bar_index + horizonN, tgt, xloc=xloc.bar_index, color=color.new(col, pct >= 15 ? 0 : 40), style=line.style_dotted, width=w)
    array.push(fan_lines, fl)
    tx = str.format("{0} · {1,number,#}%", str.tostring(tgt, format.mintick), pct)
    lb = label.new(bar_index + horizonN, tgt, tx, xloc=xloc.bar_index, textcolor=col, style=label.style_none, size=size.small)
    array.push(fan_labels, lb)

if barstate.islast
    for l in fan_lines
        line.delete(l)
    for lb in fan_labels
        label.delete(lb)
    array.clear(fan_lines)
    array.clear(fan_labels)

    if show_fan
        fan_ray(close + atrH * 2.0, f1, #00c853)
        fan_ray(close + atrH * 1.0, f2, color.new(#089981, 0))
        fan_ray(close,              f3, color.gray)
        fan_ray(close - atrH * 1.0, f4, color.new(#F23645, 0))
        fan_ray(close - atrH * 2.0, f5, #ff1744)
````
