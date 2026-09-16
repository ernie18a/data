<!-- tradingview-pine-id: PUB;4c60b5d6262140d2bccaa7812bdbe7c2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MGC 15m Hybrid [MLE + Macro + Fib Channel]

Source: https://www.tradingview.com/script/9lfVLhS7/

## Description

A 15m execution system with two entry types — liquidity sweeps of the prior 2H level and volume-backed trend continuation — gated by 2H+4H bias and a NY session filter, with a self-learning Naive Bayes probability, macro-driver consensus, Fibonacci prediction channel, and a color-coded status panel.

WHAT THIS IS

An intraday execution indicator for the 15-minute chart (defaults tuned for micro gold futures; every symbol and driver is an input, so it adapts to any liquid instrument). It combines a rule-based dual-entry system with a statistical engine that learns from the chart's own history, and compresses everything into one vertical status panel.

THE TWO ENTRY TYPES

SWEEP (liquidity grab): price wicks below the previous 2H low (or above the previous 2H high) but closes back inside, on at least average volume — the classic stop-run reversal. TREND (continuation): price holds beyond both VWAP and the 1H baseline with volume above threshold, in the direction of the candle. Both entries require the 2H and 4H trends to agree (close vs EMA20 plus candle direction on each), and both are restricted to the NY session window (8:20–13:30 ET, configurable) — no signals on thin overnight tape. Entries plot with labeled tags; stop-loss sits beyond the swept level plus an ATR buffer, take-profit at a configurable R multiple, with WIN/EXIT labels marking outcomes.

HOW THE PROBABILITY IS FORMED

The P↑ number is not a fixed formula — it's a Bernoulli Naive Bayes classifier fit by maximum likelihood on a rolling window (default 800 bars ≈ 8 days). Thirteen binary features are tracked: seven from price/volume (2H trend, 4H trend, prior-2H breakout, 1H baseline side, 1H momentum, 1H relative volume, VWAP side) and six cross-asset drivers (defaults for gold: DXY, 10Y nominal yield, 10Y REAL yield, 10Y breakevens, silver, and GVZ — the real-yield and breakeven series are FRED daily data, acting as a slow regime dial). Each bar, the script counts how often each feature historically coincided with the market rising vs falling over the next 8 bars (2 hours); those frequencies are the maximum-likelihood weights. Predictive features earn large log-odds; useless ones converge to zero — the model re-tunes itself continuously with no manual weighting.

THE FIB PREDICTION CHANNEL

The script auto-detects the active swing leg over the last 24 hours, draws the retracements (50%/61.8% emphasized) and extensions, and snaps a two-line channel to the nearest Fib level above and below price. Each wall shows a first-touch probability: the geometric first-passage odds (the nearer wall gets hit first more often) tilted by the model's directional odds — so the percentages respond both to where price sits between the walls and to what the learned model expects.

READING THE PANEL (top to bottom)

BIAS — 2H+4H trend agreement (hover shows session status).
P↑ — learned probability of higher price in 2 hours: green ≥ ~60, red ≤ ~40, gray = coin flip.
MAC — macro consensus, −5 to +5 (hover lists drivers; HI-VOL tag when the vol index is elevated).
SET — current structure: SWP (sweep forming), TRD (trend setup), BRK↑/↓ (2H breakout), IN (inside range).
VOL — relative volume vs 20-bar average; orange when above the entry threshold.
▲ / ▼ — channel walls: probability of touching the upper/lower Fib target first.
SIG — flashes BUY/SELL on the bar a signal fires; "—" otherwise.

KEY PARAMETERS

Risk:reward multiple, ATR stop buffer, RVOL threshold; session window; MLE horizon and training window; Fib swing lookback and channel projection; the six macro symbols (swap the whole set to repurpose for another market); display toggles for Fib levels, labels, and 2H boxes.

HONEST DISCLOSURES

The 2H data request uses lookahead with a 1-bar offset for the completed prior bar's high/low (the standard non-repainting idiom); the live 2H/4H trend states update while those bars form, so panel colors can change intrabar until the higher-timeframe bar closes — signals themselves evaluate on the 15m close. Probabilities are learned from recent history: they lag genuine regime changes by design and mean little on thin volume. The trade labels are illustrative sequential outcomes, not a backtest with slippage and fees. Nothing here is financial advice — forward-test before trusting any threshold.

---

## Source Code

````pine
//@version=6
indicator("MGC 15m Hybrid [MLE + Macro + Fib Channel]", overlay=true, max_labels_count=500, max_boxes_count=100, max_lines_count=150)

// ==========================================
// INPUTS
// ==========================================
rewardRatio  = input.float(2.0, "Risk:Reward Ratio",          step=0.5, group="Signal")
volThreshold = input.float(1.3, "Trend-Entry RVOL Threshold", step=0.1, group="Signal")
atrBuf       = input.float(0.3, "ATR SL Buffer (multiplier)", step=0.1, group="Signal", tooltip="Gold default 0.3. Raise toward 0.5 if stopped by wick noise.")

use_session  = input.bool(true, "Filter by NY Session (8:20-13:30 ET)", group="Session")
ny_session   = input.session("0820-1330", "NY Session Window",          group="Session")

show_boxes    = input.bool(true, "Show 2H Trend Boxes",   group="Visual")
show_line_lbl = input.bool(true, "Show Line Name Labels", group="Visual")

show_fib      = input.bool(true,  "Show Fibonacci Levels",   group="Fib Prediction")
show_fib_lbl  = input.bool(false, "Show Fib Level Labels",   group="Fib Prediction")
show_chan     = input.bool(true,  "Show Prediction Channel", group="Fib Prediction")
fibLen        = input.int(96,  "Fib Swing Lookback (15m bars)",    minval=30, maxval=500, group="Fib Prediction", tooltip="96 x 15m = last 24 hours")
projBars      = input.int(16,  "Channel Projection Length (bars)", minval=5,  maxval=60,  group="Fib Prediction", tooltip="16 x 15m = 4 hours forward")

horizonN     = input.int(8,   "MLE: Outcome Horizon (bars)", minval=3,   maxval=32,   group="MLE Probability", tooltip="8 x 15m = predicts direction over next 2 hours")
trainLen     = input.int(800, "MLE: Training Window (bars)", minval=200, maxval=3000, group="MLE Probability", tooltip="800 x 15m ≈ 8 days")

use_macro = input.bool(true, "Use Macro Features", group="Macro MLE")
dxySym    = input.symbol("TVC:DXY",     "US Dollar Index",          group="Macro MLE")
us10Sym   = input.symbol("TVC:US10Y",   "10Y Nominal Yield",        group="Macro MLE")
realSym   = input.symbol("FRED:DFII10", "10Y REAL Yield (daily)",   group="Macro MLE", tooltip="FRED daily series - updates once per day; acts as a slow regime dial.")
beSym     = input.symbol("FRED:T10YIE", "10Y Breakeven (daily)",    group="Macro MLE", tooltip="FRED daily series - inflation expectations.")
silvSym   = input.symbol("COMEX:SI1!",  "Silver",                   group="Macro MLE")
gvzSym    = input.symbol("CBOE:GVZ",    "Gold Vol Index",           group="Macro MLE")

// ==========================================
// COLORS (family palette)
// ==========================================
c_anchor_col = #923df4
c_1h_col     = #808080
c_2h_col     = color.rgb(208, 5, 113)
c_4h_col     = color.orange
c_vwap_col   = color.rgb(52, 232, 248)
c_bull_box   = color.new(#baf7bc, 90)
c_bear_box   = color.new(#f7bfbf, 90)
c_fib_dot    = color.new(color.blue, 55)
c_fib_key    = color.new(color.blue, 20)
c_fib_ext    = color.new(color.aqua, 60)
c_chan_up    = color.new(color.lime, 0)
c_chan_dn    = color.new(color.red, 0)
c_lbl_bg     = color.new(color.black, 40)

// ==========================================
// MTF DATA (ladder: 15m chart / 30m anchor / 1H base / 2H+4H bias)
// ==========================================
emaAnchor = request.security(syminfo.tickerid, "30", ta.ema(close, 12))

[v1h, v_avg1h, base1h, val1h] = request.security(syminfo.tickerid, "60", [volume, ta.sma(volume, 20), ta.ema(close, 20), ta.linreg(close - math.avg(math.avg(ta.highest(high, 20), ta.lowest(low, 20)), ta.sma(close, 20)), 20, 0)])
rvol1h = v1h / math.max(v_avg1h, 1)

[h_2h, l_2h, c_2h, o_2h, t_2h, ema2h] = request.security(syminfo.tickerid, "120", [high, low, close, open, time, ta.ema(close, 20)], lookahead=barmerge.lookahead_on)

[c_4h, o_4h, ema4h] = request.security(syminfo.tickerid, "240", [close, open, ta.ema(close, 20)])

// ==========================================
// MACRO DATA (cross-asset drivers for GOLD)
// FRED series are daily: their state changes once per day (regime dial).
// ==========================================
macro_above(string sym, string tf) =>
    [mc, me] = request.security(sym, tf, [close, ta.ema(close, 20)])
    fixnan(mc) > fixnan(me) ? 1.0 : 0.0

x8  = use_macro ? macro_above(dxySym,  "60") : 0.0   // dollar trending up
x9  = use_macro ? macro_above(us10Sym, "60") : 0.0   // 10Y nominal yield up
x10 = use_macro ? macro_above(realSym, "D")  : 0.0   // 10Y REAL yield up (strongest gold driver)
x11 = use_macro ? macro_above(beSym,   "D")  : 0.0   // breakevens up
x12 = use_macro ? macro_above(silvSym, "60") : 0.0   // silver trending up
x13 = use_macro ? macro_above(gvzSym,  "60") : 0.0   // gold vol elevated

// ==========================================
// SESSION / TREND / BASE (family-identical formulas)
// ==========================================
in_session = not use_session or not na(time(timeframe.period, ny_session, "America/New_York"))

trend2h_up = (c_2h > ema2h) and (c_2h > o_2h)
trend2h_dn = (c_2h < ema2h) and (c_2h < o_2h)
trend4h_up = (c_4h > ema4h) and (c_4h > o_4h)
trend4h_dn = (c_4h < ema4h) and (c_4h < o_4h)

htf_bullish = trend2h_up and trend4h_up
htf_bearish = trend2h_dn and trend4h_dn

vwap_val = ta.vwap(close)
atr15    = ta.atr(14)
p_h      = h_2h[1]
p_l      = l_2h[1]
mom_up   = val1h > 0

// ==========================================
// MLE PROBABILITY (Bernoulli Naive Bayes, 13 features) - 2hr horizon
// ==========================================
x1 = trend2h_up        ? 1.0 : 0.0
x2 = trend4h_up        ? 1.0 : 0.0
x3 = close > p_h       ? 1.0 : 0.0
x4 = close > base1h    ? 1.0 : 0.0
x5 = mom_up            ? 1.0 : 0.0
x6 = rvol1h > 1.3      ? 1.0 : 0.0
x7 = close > vwap_val  ? 1.0 : 0.0

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

llr = math.log((nUp + 1.0) / (nDn + 1.0))
llr += llr_term(c1u, c1d, x1 == 1.0)
llr += llr_term(c2u, c2d, x2 == 1.0)
llr += llr_term(c3u, c3d, x3 == 1.0)
llr += llr_term(c4u, c4d, x4 == 1.0)
llr += llr_term(c5u, c5d, x5 == 1.0)
llr += llr_term(c6u, c6d, x6 == 1.0)
llr += llr_term(c7u, c7d, x7 == 1.0)
if use_macro
    llr += llr_term(c8u,  c8d,  x8  == 1.0)
    llr += llr_term(c9u,  c9d,  x9  == 1.0)
    llr += llr_term(c10u, c10d, x10 == 1.0)
    llr += llr_term(c11u, c11d, x11 == 1.0)
    llr += llr_term(c12u, c12d, x12 == 1.0)
    llr += llr_term(c13u, c13d, x13 == 1.0)

mle_ready  = bar_index > trainLen + horizonN + 10
score_bull = mle_ready ? 100.0 / (1.0 + math.exp(-llr)) : 50.0
score_bear = 100.0 - score_bull

// ==========================================
// FIBONACCI ENGINE + PREDICTION CHANNEL
// ==========================================
swingHi = ta.highest(high, fibLen)
swingLo = ta.lowest(low,  fibLen)
hiOff   = ta.highestbars(high, fibLen)
loOff   = ta.lowestbars(low,  fibLen)
upleg   = hiOff > loOff
fibRng  = swingHi - swingLo

fib_price(float r) =>
    upleg ? swingHi - fibRng * r : swingLo + fibRng * r

var float[]  fib_r  = array.from(-0.618, -0.272, 0.0, 0.382, 0.5, 0.618, 0.786, 1.0)
var string[] fib_nm = array.from("161.8x", "127.2x", "0%", "38.2%", "50%", "61.8%", "78.6%", "100%")

float fibUp = na
float fibDn = na
for i = 0 to array.size(fib_r) - 1
    lv = fib_price(array.get(fib_r, i))
    if lv > close and (na(fibUp) or lv < fibUp)
        fibUp := lv
    if lv < close and (na(fibDn) or lv > fibDn)
        fibDn := lv
fibUp := na(fibUp) ? close + atr15 * 3 : fibUp
fibDn := na(fibDn) ? close - atr15 * 3 : fibDn

// Touch probabilities: first-passage prior x MLE drift odds
dU = fibUp - close
dL = close - fibDn
p_geo   = dL / (dU + dL)
odds_ml = score_bull / math.max(score_bear, 1.0)
p_up_ch = 100.0 * (p_geo * odds_ml) / (p_geo * odds_ml + (1.0 - p_geo))
p_dn_ch = 100.0 - p_up_ch

// --- Drawings ---
var line[]  fib_lines  = array.new<line>()
var label[] fib_labels = array.new<label>()
var line  ch_up_ln = na
var line  ch_dn_ln = na
var label ch_up_lb = na
var label ch_dn_lb = na
var linefill ch_fill = na

if barstate.islast
    for l in fib_lines
        line.delete(l)
    for lb in fib_labels
        label.delete(lb)
    array.clear(fib_lines)
    array.clear(fib_labels)
    line.delete(ch_up_ln)
    line.delete(ch_dn_ln)
    label.delete(ch_up_lb)
    label.delete(ch_dn_lb)
    linefill.delete(ch_fill)

    if show_fib
        start_x = bar_index - fibLen
        for i = 0 to array.size(fib_r) - 1
            r  = array.get(fib_r, i)
            lv = fib_price(r)
            is_key  = r == 0.5 or r == 0.618
            lnColor = r < 0 ? c_fib_ext : is_key ? c_fib_key : c_fib_dot
            lnStyle = is_key ? line.style_solid : line.style_dotted
            fl = line.new(start_x, lv, bar_index + projBars + 4, lv, xloc=xloc.bar_index, color=lnColor, style=lnStyle, width=is_key ? 2 : 1)
            array.push(fib_lines, fl)
            if show_fib_lbl and (is_key or r < 0)
                fibTxt = str.format("{0} {1,number,#.0}", array.get(fib_nm, i), lv)
                flb = label.new(bar_index + projBars + 5, lv, fibTxt, xloc=xloc.bar_index, textcolor=color.new(color.blue, 20), style=label.style_none, size=size.tiny)
                array.push(fib_labels, flb)

    if show_chan
        fillColor = p_up_ch >= 60 ? color.new(color.green, 93) : p_dn_ch >= 60 ? color.new(color.red, 93) : color.new(color.gray, 94)
        upTxt = str.format("▲ {0,number,#.0} · {1,number,#}%", fibUp, p_up_ch)
        dnTxt = str.format("▼ {0,number,#.0} · {1,number,#}%", fibDn, p_dn_ch)
        ch_up_ln := line.new(bar_index, fibUp, bar_index + projBars, fibUp, xloc=xloc.bar_index, color=c_chan_up, style=line.style_solid, width=3)
        ch_dn_ln := line.new(bar_index, fibDn, bar_index + projBars, fibDn, xloc=xloc.bar_index, color=c_chan_dn, style=line.style_solid, width=3)
        ch_fill  := linefill.new(ch_up_ln, ch_dn_ln, fillColor)
        ch_up_lb := label.new(bar_index + projBars, fibUp, upTxt, xloc=xloc.bar_index, textcolor=c_chan_up, style=label.style_label_left, color=c_lbl_bg, size=size.small)
        ch_dn_lb := label.new(bar_index + projBars, fibDn, dnTxt, xloc=xloc.bar_index, textcolor=c_chan_dn, style=label.style_label_left, color=c_lbl_bg, size=size.small)

// ==========================================
// SIGNALS - dual entry
// STRIKE: sweep of previous 2H low/high that closes back inside
// TREND:  volume-backed continuation above/below VWAP + 1H base
// ==========================================
rvol_chart = volume / math.max(ta.sma(volume, 20), 1)

is_sweep_bull = low  < p_l and close > p_l
is_sweep_bear = high > p_h and close < p_h

strike_long  = in_session and htf_bullish and is_sweep_bull and rvol_chart > 1.0
strike_short = in_session and htf_bearish and is_sweep_bear and rvol_chart > 1.0
trend_long   = in_session and htf_bullish and close > vwap_val and close > base1h and rvol_chart > volThreshold and close > open
trend_short  = in_session and htf_bearish and close < vwap_val and close < base1h and rvol_chart > volThreshold and close < open

buySignal  = strike_long or trend_long
sellSignal = strike_short or trend_short

// ==========================================
// PLOTS
// ==========================================
plot(vwap_val,  "VWAP",       color=c_vwap_col,   linewidth=2)
plot(emaAnchor, "30m Anchor", color=c_anchor_col, linewidth=1, style=plot.style_stepline)
plot(base1h,    "1H Base",    color=c_1h_col,     linewidth=2)
plot(ema2h,     "2H Base",    color=c_2h_col,     linewidth=2, style=plot.style_stepline)
plot(ema4h,     "4H Base",    color=c_4h_col,     linewidth=2, style=plot.style_stepline)

// ==========================================
// LINE NAME LABELS
// ==========================================
var label lbl_v  = na
var label lbl_a  = na
var label lbl_1h = na
var label lbl_2h = na
var label lbl_4h = na

if barstate.islast and show_line_lbl
    label.delete(lbl_v)
    label.delete(lbl_a)
    label.delete(lbl_1h)
    label.delete(lbl_2h)
    label.delete(lbl_4h)
    lbl_v  := label.new(bar_index + 2, vwap_val,  "VWAP",       xloc=xloc.bar_index, textcolor=c_vwap_col,   style=label.style_none, size=size.small)
    lbl_a  := label.new(bar_index + 2, emaAnchor, "30m Anchor", xloc=xloc.bar_index, textcolor=c_anchor_col, style=label.style_none, size=size.small)
    lbl_1h := label.new(bar_index + 2, base1h,    "1H Base",    xloc=xloc.bar_index, textcolor=c_1h_col,     style=label.style_none, size=size.small)
    lbl_2h := label.new(bar_index + 2, ema2h,     "2H Base",    xloc=xloc.bar_index, textcolor=c_2h_col,     style=label.style_none, size=size.small)
    lbl_4h := label.new(bar_index + 2, ema4h,     "4H Base",    xloc=xloc.bar_index, textcolor=c_4h_col,     style=label.style_none, size=size.small)

// ==========================================
// TRADE MANAGEMENT
// ==========================================
var float sl = na
var float tp = na
var bool inTrade = false

if (buySignal or sellSignal) and not inTrade
    inTrade := true
    if buySignal
        sl := math.min(low, p_l) - atr15 * atrBuf
        tp := close + (close - sl) * rewardRatio
        entryTag = strike_long ? "SWEEP LONG 🚀" : "TREND LONG 🚀"
        label.new(bar_index, low, entryTag, color=color.lime, style=label.style_label_up, size=size.small)
    else
        sl := math.max(high, p_h) + atr15 * atrBuf
        tp := close - (sl - close) * rewardRatio
        entryTag = strike_short ? "SWEEP SHORT 🐻" : "TREND SHORT 🐻"
        label.new(bar_index, high, entryTag, color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

if inTrade
    hit_tp = (high >= tp and tp > close[1]) or (low <= tp and tp < close[1])
    hit_sl = (low <= sl and sl < close[1]) or (high >= sl and sl > close[1])
    if hit_tp
        label.new(bar_index, close, "WIN 💰", color=color.green, style=label.style_label_center, textcolor=color.white, size=size.tiny)
        inTrade := false
    else if hit_sl
        label.new(bar_index, close, "EXIT ❌", color=color.red, style=label.style_label_center, textcolor=color.white, size=size.tiny)
        inTrade := false

plot(inTrade ? tp : na, "Target", color=color.new(color.green, 50), style=plot.style_linebr, linewidth=2)
plot(inTrade ? sl : na, "Stop",   color=color.new(color.red, 50),   style=plot.style_linebr, linewidth=2)

// ==========================================
// 2H TREND BOXES (leak-free)
// ==========================================
var box[] hr_boxes = array.new<box>()

if barstate.islast and show_boxes
    for b in hr_boxes
        box.delete(b)
    array.clear(hr_boxes)
    for i = 0 to 11
        box_col = c_2h[i] >= o_2h[i] ? c_bull_box : c_bear_box
        bx = box.new(t_2h[i], h_2h[i], t_2h[i] + 7200000, l_2h[i], xloc=xloc.bar_time, border_color=color.new(color.gray, 80), bgcolor=box_col)
        array.push(hr_boxes, bx)

/// ==========================================
// HEATMAP HUD - vertical, 8 rows, high-contrast
// ==========================================
var table hud = table.new(position.bottom_right, 2, 8, bgcolor=color.new(color.black, 10), border_width=2, border_color=color.new(color.black, 0))

c_hot_grn = #00c853
c_hot_red = #ff1744
grad(float v) =>
    v >= 50 ? color.from_gradient(v, 50, 65, color.new(color.gray, 30), c_hot_grn) : color.from_gradient(v, 35, 50, c_hot_red, color.new(color.gray, 30))

if barstate.islast
    float v_bias = htf_bullish ? 100 : htf_bearish ? 0 : 50

    // Gold-friendly macro consensus: DXY dn, 10Y dn, REAL yield dn, breakevens up, silver up
    int macroScore = 0
    macroScore += x8  == 0.0 ? 1 : -1
    macroScore += x9  == 0.0 ? 1 : -1
    macroScore += x10 == 0.0 ? 1 : -1
    macroScore += x11 == 1.0 ? 1 : -1
    macroScore += x12 == 1.0 ? 1 : -1
    float v_macro = 50 + macroScore * 12

    string setupTxt = strike_long or strike_short ? "SWP" : trend_long or trend_short ? "TRD" : close > p_h ? "BRK↑" : close < p_l ? "BRK↓" : "IN"
    color  setupCol = strike_long or strike_short ? color.purple : trend_long or trend_short ? #2962ff : color.new(color.gray, 30)

    color volCol = rvol_chart > volThreshold ? color.orange : color.new(color.gray, 30)
    color sigCol = buySignal ? c_hot_grn : sellSignal ? c_hot_red : color.new(color.gray, 30)
    string offTag = in_session ? "" : " (OFF-HRS)"

    // column 0 = labels, column 1 = heat cells
    table.cell(hud, 0, 0, "BIAS", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 0, htf_bullish ? "BULL" : htf_bearish ? "BEAR" : "MIX", bgcolor=grad(v_bias), text_color=color.white, text_size=size.normal, tooltip="2H+4H trend agreement" + offTag)

    table.cell(hud, 0, 1, "P↑", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 1, mle_ready ? str.format("{0,number,#}", score_bull) : "…", bgcolor=grad(score_bull), text_color=color.white, text_size=size.normal, tooltip="MLE P(Up), 2hr horizon")

    table.cell(hud, 0, 2, "MAC", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 2, str.format("{0}{1}", macroScore > 0 ? "+" : "", macroScore), bgcolor=grad(v_macro), text_color=color.white, text_size=size.normal, tooltip="Gold macro consensus -5..+5 (DXY / 10Y / REAL yield / breakevens / silver)" + (x13 == 1.0 ? " · HI-VOL (GVZ elevated)" : ""))

    table.cell(hud, 0, 3, "SET", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 3, setupTxt, bgcolor=setupCol, text_color=color.white, text_size=size.normal, tooltip="SWP=sweep of prev 2H level, TRD=trend continuation, BRK=2H breakout, IN=inside 2H range")

    table.cell(hud, 0, 4, "VOL", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 4, str.format("{0,number,#.#}x", rvol_chart), bgcolor=volCol, text_color=color.white, text_size=size.normal, tooltip="Relative volume vs 20-bar avg · " + (close > vwap_val ? "above VWAP" : "below VWAP"))

    table.cell(hud, 0, 5, "▲", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 5, str.format("{0,number,#}%", p_up_ch), bgcolor=grad(p_up_ch), text_color=color.white, text_size=size.normal, tooltip="Touch upper target first: " + str.tostring(fibUp, format.mintick))

    table.cell(hud, 0, 6, "▼", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 6, str.format("{0,number,#}%", p_dn_ch), bgcolor=grad(100 - p_dn_ch), text_color=color.white, text_size=size.normal, tooltip="Touch lower target first: " + str.tostring(fibDn, format.mintick))

    table.cell(hud, 0, 7, "SIG", text_color=color.silver, text_size=size.small)
    table.cell(hud, 1, 7, buySignal ? "BUY" : sellSignal ? "SELL" : "—", bgcolor=sigCol, text_color=color.white, text_size=size.normal, tooltip="Live signal state")
// ==========================================
// ALERTS (create once in TradingView: Alerts -> this indicator)
// ==========================================
alertcondition(buySignal,  "MGC 15m Long",  "MGC 15m LONG signal fired (sweep or trend)")
alertcondition(sellSignal, "MGC 15m Short", "MGC 15m SHORT signal fired (sweep or trend)")
````
