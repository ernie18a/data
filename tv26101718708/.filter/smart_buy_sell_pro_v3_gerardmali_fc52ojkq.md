# Smart Buy Sell PRO v3 GERARDMALI

- url: https://www.tradingview.com/script/fc52OJKq-Smart-Buy-Sell-PRO-v3-GERARDMALI/
- type: indicator
- pine_id: PUB;3be86167f4d54aef8da2124c791921bd
- version: 1.0

## Description

⚡ SMART BUY/SELL — PRO EDITION v3
//  Rebuilt by Claude as Expert Trader / Chartist
//
//  NEW IN v3 (on top of v2 gates):
//  ✅ DYNAMIC S/R — Pivot highs/lows drawn automatically on chart
//  ✅ CONSOLIDATION DETECTION — BB squeeze kills signals during ranges
//  ✅ BREAKOUT SIGNALS — alerts when price clears S/R with volume
//  ✅ BREAKDOWN SIGNALS — alerts when price loses S/R with volume
//  ✅ FALSE BREAKOUT VETO — price faked above resistance → now rejected
//  ✅ FALSE BREAKDOWN VETO — price faked below support → now rejected
//  ✅ RSI 50 CROSSOVER — used as precision trigger + bonus score
//  ✅ NEAR S/R BONUS — extra score when price is bouncing from a level
//  ✅ DASHBOARD shows S/R values, breakout status, consolidation state

## Source Code

````pine
//@version=6
indicator("⚡ Smart Buy/Sell PRO v3 — S/R + Breakouts | Claude",
          overlay          = true,
          max_labels_count = 500,
          max_lines_count  = 500)

// ════════════════════════════════════════════════════════════════════════
//  ⚡ SMART BUY/SELL — PRO EDITION v3
//  Rebuilt by Claude as Expert Trader / Chartist
//
//  NEW IN v3 (on top of v2 gates):
//  ✅ DYNAMIC S/R — Pivot highs/lows drawn automatically on chart
//  ✅ CONSOLIDATION DETECTION — BB squeeze kills signals during ranges
//  ✅ BREAKOUT SIGNALS — alerts when price clears S/R with volume
//  ✅ BREAKDOWN SIGNALS — alerts when price loses S/R with volume
//  ✅ FALSE BREAKOUT VETO — price faked above resistance → now rejected
//  ✅ FALSE BREAKDOWN VETO — price faked below support → now rejected
//  ✅ RSI 50 CROSSOVER — used as precision trigger + bonus score
//  ✅ NEAR S/R BONUS — extra score when price is bouncing from a level
//  ✅ DASHBOARD shows S/R values, breakout status, consolidation state
// ════════════════════════════════════════════════════════════════════════

// ── EMA SETTINGS ──────────────────────────────────────────────────────
var string GE = "📈 EMA Settings"
ema1_len  = input.int(9,   "EMA Fast (9)",    minval=1, group=GE)
ema2_len  = input.int(21,  "EMA Mid (21)",    minval=1, group=GE)
ema3_len  = input.int(50,  "EMA Slow (50)",   minval=1, group=GE)
ema4_len  = input.int(200, "EMA Trend (200)", minval=1, group=GE)
show_emas = input.bool(true, "Show EMAs",     group=GE)

// ── RSI SETTINGS ──────────────────────────────────────────────────────
var string GR = "📊 RSI Settings"
rsi_len   = input.int(14, "RSI Length", minval=1, group=GR)

// ── MACD SETTINGS ─────────────────────────────────────────────────────
var string GM = "〰️ MACD Settings"
macd_fast = input.int(12, "Fast",   minval=1, group=GM)
macd_slow = input.int(26, "Slow",   minval=1, group=GM)
macd_sig  = input.int(9,  "Signal", minval=1, group=GM)

// ── STOCHASTIC SETTINGS ───────────────────────────────────────────────
var string GS = "📉 Stochastic"
stk_k     = input.int(14, "%K",     minval=1, group=GS)
stk_d_len = input.int(3,  "%D",     minval=1, group=GS)
stk_sm    = input.int(3,  "Smooth", minval=1, group=GS)

// ── ADX / DMI SETTINGS ────────────────────────────────────────────────
var string GD = "💪 ADX / DMI"
adx_len   = input.int(14, "ADX Length",           minval=1, group=GD)
adx_min   = input.int(20, "Min ADX (trend gate)", minval=5, maxval=50, group=GD)

// ── S/R PIVOT SETTINGS ────────────────────────────────────────────────
var string GSR = "🏔️ S/R Pivots"
piv_left  = input.int(5, "Pivot Left Bars",       minval=2, maxval=20, group=GSR)
piv_right = input.int(5, "Pivot Right Bars",      minval=2, maxval=20, group=GSR)
show_sr   = input.bool(true, "Show S/R Lines",    group=GSR)
show_srlb = input.bool(true, "Show S/R Labels",   group=GSR)
sr_zone   = input.float(1.5, "S/R proximity (ATR multiplier)", minval=0.5, step=0.1, group=GSR)

// ── BREAKOUT SETTINGS ─────────────────────────────────────────────────
var string GBO = "🚀 Breakout / Breakdown"
show_bo      = input.bool(true,  "Show Breakout Labels",     group=GBO)
vol_mult     = input.float(1.2,  "Volume surge multiplier",  minval=1.0, maxval=4.0, step=0.1, group=GBO)
false_bars   = input.int(3,      "False breakout lookback (bars)", minval=1, maxval=10, group=GBO)

// ── CONSOLIDATION SETTINGS ────────────────────────────────────────────
var string GC = "📦 Consolidation (BB Squeeze)"
bb_len       = input.int(20,   "BB Length",               minval=5, group=GC)
bb_mult_val  = input.float(2.0,"BB Std Dev",              minval=0.5, step=0.1, group=GC)
sq_thresh    = input.float(0.6,"Squeeze threshold (0–1)", minval=0.1, maxval=0.99, step=0.05, group=GC)
show_sq      = input.bool(true,"Shade consolidation zones",group=GC)

// ── GATE / SCORING SETTINGS ───────────────────────────────────────────
var string GG = "🚦 Gate Settings"
min_bonus    = input.int(3,   "Min bonus score (0–8)", minval=0, maxval=8, group=GG)
cooldown     = input.int(5,   "Signal cooldown bars",  minval=1, group=GG)
ext_pct      = input.float(3.0,"Max % from EMA200 (overextension)", minval=0.5, step=0.5, group=GG)

// ══════════════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════

// EMAs
float e1 = ta.ema(close, ema1_len)
float e2 = ta.ema(close, ema2_len)
float e3 = ta.ema(close, ema3_len)
float e4 = ta.ema(close, ema4_len)

// EMA slope (2-bar lag to reduce noise)
bool e1_rising  = e1 > e1[2]
bool e2_rising  = e2 > e2[2]
bool e1_falling = e1 < e1[2]
bool e2_falling = e2 < e2[2]

// RSI
float rsi_val        = ta.rsi(close, rsi_len)
bool  rsi_above50    = rsi_val > 50
bool  rsi_x50_up     = ta.crossover(rsi_val, 50)
bool  rsi_x50_down   = ta.crossunder(rsi_val, 50)

// MACD
[macd_line, sig_line, macd_hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)
bool hist_bull = macd_hist > macd_hist[1] and macd_hist > macd_hist[2]
bool hist_bear = macd_hist < macd_hist[1] and macd_hist < macd_hist[2]

// Stochastic
float stk_K = ta.sma(ta.stoch(close, high, low, stk_k), stk_sm)
float stk_D = ta.sma(stk_K, stk_d_len)

// ADX / DMI
[di_plus, di_minus, adx_val] = ta.dmi(adx_len, adx_len)

// ATR
float atr_val = ta.atr(14)

// Volume
float vol_avg  = ta.sma(volume, 20)
bool  vol_high = volume > vol_avg * vol_mult

// ══════════════════════════════════════════════════════════════════════
//  BOLLINGER BAND SQUEEZE — CONSOLIDATION DETECTOR
// ══════════════════════════════════════════════════════════════════════

[bb_upper, bb_mid, bb_lower] = ta.bb(close, bb_len, bb_mult_val)
float bb_width     = (bb_upper - bb_lower) / bb_mid
float bb_width_avg = ta.sma(bb_width, 50)
bool  consolidating = bb_width < bb_width_avg * sq_thresh

// ══════════════════════════════════════════════════════════════════════
//  DYNAMIC S/R — PIVOT HIGHS & LOWS
//  Tracks the 3 most recent significant resistance and support levels.
//  Pivots have a built-in lag (piv_right bars) — this is unavoidable
//  but ensures only confirmed swing points are used.
// ══════════════════════════════════════════════════════════════════════

float ph = ta.pivothigh(high, piv_left, piv_right)
float pl = ta.pivotlow(low,   piv_left, piv_right)

var float res1 = na
var float res2 = na
var float res3 = na
var float sup1 = na
var float sup2 = na
var float sup3 = na

if not na(ph)
    res3 := res2
    res2 := res1
    res1 := ph

if not na(pl)
    sup3 := sup2
    sup2 := sup1
    sup1 := pl

float nearest_res = res1
float nearest_sup = sup1

// ── DRAW S/R LINES ────────────────────────────────────────────────────
var line l_r1 = na
var line l_r2 = na
var line l_r3 = na
var line l_s1 = na
var line l_s2 = na
var line l_s3 = na
var label lb_r1 = na
var label lb_s1 = na

if barstate.islast and show_sr
    line.delete(l_r1)
    line.delete(l_r2)
    line.delete(l_r3)
    line.delete(l_s1)
    line.delete(l_s2)
    line.delete(l_s3)
    label.delete(lb_r1)
    label.delete(lb_s1)

    int look = bar_index - 100
    int ext  = bar_index + 30

    if not na(res1)
        l_r1  := line.new(look, res1, ext, res1, color=color.new(color.red, 20),  width=2, style=line.style_dashed)
        if show_srlb
            lb_r1 := label.new(ext, res1, "RES  " + str.tostring(math.round(res1, 2)),
                               style=label.style_label_left, color=color.new(color.red, 20),
                               textcolor=color.white, size=size.tiny)
    if not na(res2)
        l_r2 := line.new(look, res2, ext, res2, color=color.new(color.red, 55),  width=1, style=line.style_dashed)
    if not na(res3)
        l_r3 := line.new(look, res3, ext, res3, color=color.new(color.red, 75),  width=1, style=line.style_dotted)
    if not na(sup1)
        l_s1  := line.new(look, sup1, ext, sup1, color=color.new(color.lime, 20), width=2, style=line.style_dashed)
        if show_srlb
            lb_s1 := label.new(ext, sup1, "SUP  " + str.tostring(math.round(sup1, 2)),
                               style=label.style_label_left, color=color.new(color.lime, 20),
                               textcolor=color.black, size=size.tiny)
    if not na(sup2)
        l_s2 := line.new(look, sup2, ext, sup2, color=color.new(color.lime, 55), width=1, style=line.style_dashed)
    if not na(sup3)
        l_s3 := line.new(look, sup3, ext, sup3, color=color.new(color.lime, 75), width=1, style=line.style_dotted)

// ══════════════════════════════════════════════════════════════════════
//  BREAKOUT & BREAKDOWN DETECTION
//  A real breakout requires: price crosses level + volume surge + momentum
//  Consolidation zones are excluded (breakouts from ranging are noise)
// ══════════════════════════════════════════════════════════════════════

bool bull_breakout  = not na(nearest_res) and
                      close  > nearest_res and
                      close[1] <= nearest_res and
                      vol_high and
                      macd_hist > 0 and
                      not consolidating

bool bear_breakdown = not na(nearest_sup) and
                      close  < nearest_sup and
                      close[1] >= nearest_sup and
                      vol_high and
                      macd_hist < 0 and
                      not consolidating

// ══════════════════════════════════════════════════════════════════════
//  FALSE BREAKOUT / FALSE BREAKDOWN DETECTION
//  False breakout: price closed above resistance in the last N bars
//  but has now closed back BELOW that resistance → trap / fakeout.
//  This is a veto gate AND generates its own label.
// ══════════════════════════════════════════════════════════════════════

bool false_bull_bo = false
bool false_bear_bd = false

if not na(nearest_res)
    for i = 1 to false_bars
        if close[i] > nearest_res and close < nearest_res
            false_bull_bo := true

if not na(nearest_sup)
    for i = 1 to false_bars
        if close[i] < nearest_sup and close > nearest_sup
            false_bear_bd := true

// ══════════════════════════════════════════════════════════════════════
//  DIVERGENCE DETECTION
//  Bearish: price makes HH but RSI makes LH → signal that momentum
//           is weakening despite price rise (veto buy signals)
//  Bullish: price makes LL but RSI makes HL → hidden strength
//           despite falling price (veto sell signals)
// ══════════════════════════════════════════════════════════════════════

bool bearish_div = close > close[14] and rsi_val < rsi_val[14] and rsi_val > 55
bool bullish_div = close < close[14] and rsi_val > rsi_val[14] and rsi_val < 45

// ══════════════════════════════════════════════════════════════════════
//  OVEREXTENSION
// ══════════════════════════════════════════════════════════════════════

bool over_up   = close > e4 * (1 + ext_pct / 100)
bool over_down = close < e4 * (1 - ext_pct / 100)

// ══════════════════════════════════════════════════════════════════════
//  LAYER 1 — REQUIRED GATES (ALL 8 must pass or signal is blocked)
// ══════════════════════════════════════════════════════════════════════

bool upper_close = close >= (low  + (high - low) * 0.45)  // bullish candle body
bool lower_close = close <= (high - (high - low) * 0.45)  // bearish candle body
bool rsi_bz      = rsi_val >= 38 and rsi_val <= 72         // RSI in bull zone
bool rsi_sz      = rsi_val >= 28 and rsi_val <= 62         // RSI in sell zone

// ── BUY GATES ─────────────────────────────────────────────────────────
bool G1b = adx_val > adx_min         // trend is active (not ranging)
bool G2b = e1_rising  and e2_rising  // EMA slope actively rising
bool G3b = rsi_bz                    // RSI in valid buy zone
bool G4b = hist_bull                 // MACD histogram accelerating up
bool G5b = upper_close               // candle closed bullishly
bool G6b = not over_up               // price not overextended above EMA200
bool G7b = not bearish_div           // no bearish RSI divergence
bool G8b = not false_bull_bo         // no false breakout veto
bool G9b = not consolidating         // no signals inside tight ranges

bool buy_gates = G1b and G2b and G3b and G4b and G5b and G6b and G7b and G8b and G9b

// ── SELL GATES ────────────────────────────────────────────────────────
bool G1s = adx_val > adx_min
bool G2s = e1_falling and e2_falling
bool G3s = rsi_sz
bool G4s = hist_bear
bool G5s = lower_close
bool G6s = not over_down
bool G7s = not bullish_div
bool G8s = not false_bear_bd
bool G9s = not consolidating

bool sell_gates = G1s and G2s and G3s and G4s and G5s and G6s and G7s and G8s and G9s

// ══════════════════════════════════════════════════════════════════════
//  LAYER 2 — BONUS SCORE  (0–8, need min_bonus to fire)
//  Points for additional confluence — more points = higher conviction
// ══════════════════════════════════════════════════════════════════════

// BUY BONUS
bool b_ema_stack  = e1 > e2 and e2 > e3          // full EMA stack aligned
bool b_above200   = close > e4                    // price above trend EMA
bool b_rsi_rising = rsi_val > rsi_val[3]          // RSI gaining strength
bool b_stk_os     = ta.crossover(stk_K, stk_D) and stk_K[1] < 30  // stoch from oversold
bool b_di_bull    = di_plus > di_minus            // DI+ dominant
bool b_rsi50_up   = rsi_x50_up                   // RSI just crossed above 50
bool b_near_sup   = not na(sup1) and math.abs(close - sup1) < atr_val * sr_zone  // near support
bool b_breakout   = bull_breakout                 // confirmed breakout

int bull_bonus = (b_ema_stack ? 1 : 0) + (b_above200  ? 1 : 0) + (b_rsi_rising ? 1 : 0) +
                 (b_stk_os   ? 1 : 0) + (b_di_bull    ? 1 : 0) + (b_rsi50_up   ? 1 : 0) +
                 (b_near_sup ? 1 : 0) + (b_breakout   ? 1 : 0)

// SELL BONUS
bool s_ema_stack  = e1 < e2 and e2 < e3
bool s_below200   = close < e4
bool s_rsi_fall   = rsi_val < rsi_val[3]
bool s_stk_ob     = ta.crossunder(stk_K, stk_D) and stk_K[1] > 70
bool s_di_bear    = di_minus > di_plus
bool s_rsi50_dn   = rsi_x50_down
bool s_near_res   = not na(res1) and math.abs(close - res1) < atr_val * sr_zone  // near resistance
bool s_breakdown  = bear_breakdown

int bear_bonus = (s_ema_stack ? 1 : 0) + (s_below200  ? 1 : 0) + (s_rsi_fall  ? 1 : 0) +
                 (s_stk_ob   ? 1 : 0) + (s_di_bear    ? 1 : 0) + (s_rsi50_dn  ? 1 : 0) +
                 (s_near_res ? 1 : 0) + (s_breakdown  ? 1 : 0)

// ══════════════════════════════════════════════════════════════════════
//  LAYER 3 — PRECISION TRIGGERS
//  Signals fire ONLY from momentum crossovers inside valid price zones.
//  Pure momentum crosses from mid-range are blocked.
//  Confirmed breakouts count as their own trigger event.
// ══════════════════════════════════════════════════════════════════════

// BUY TRIGGERS
bool T1b = ta.crossover(macd_line, sig_line) and macd_hist[1] < 0           // MACD cross from below zero
bool T2b = ta.crossover(stk_K, stk_D)        and stk_K[1] < 35              // Stoch cross from oversold
bool T3b = rsi_x50_up                         and rsi_val[2] < 44            // RSI reclaims 50 from low base
bool T4b = ta.crossover(e1, e2)               and e2_rising and adx_val > 22 // EMA cross + rising slope
bool T5b = bull_breakout                                                       // confirmed S/R breakout

bool buy_trigger = T1b or T2b or T3b or T4b or T5b

// SELL TRIGGERS
bool T1s = ta.crossunder(macd_line, sig_line) and macd_hist[1] > 0
bool T2s = ta.crossunder(stk_K, stk_D)        and stk_K[1] > 65
bool T3s = rsi_x50_down                        and rsi_val[2] > 56
bool T4s = ta.crossunder(e1, e2)               and e2_falling and adx_val > 22
bool T5s = bear_breakdown

bool sell_trigger = T1s or T2s or T3s or T4s or T5s

// ══════════════════════════════════════════════════════════════════════
//  LAYER 4 — COOLDOWN
//  Prevents consecutive same-direction signals in the same move.
// ══════════════════════════════════════════════════════════════════════

var int last_buy  = -999
var int last_sell = -999
bool buy_cooled  = (bar_index - last_buy)  > cooldown
bool sell_cooled = (bar_index - last_sell) > cooldown

// ══════════════════════════════════════════════════════════════════════
//  FINAL SIGNALS
// ══════════════════════════════════════════════════════════════════════

bool buy_signal  = buy_gates  and bull_bonus >= min_bonus and buy_trigger  and buy_cooled
bool sell_signal = sell_gates and bear_bonus >= min_bonus and sell_trigger and sell_cooled

if buy_signal
    last_buy  := bar_index
if sell_signal
    last_sell := bar_index

// ══════════════════════════════════════════════════════════════════════
//  PLOTS — EMAs
// ══════════════════════════════════════════════════════════════════════

plot(show_emas ? e1 : na, "EMA9",   color=color.new(color.yellow, 0), linewidth=1)
plot(show_emas ? e2 : na, "EMA21",  color=color.new(color.orange, 0), linewidth=1)
plot(show_emas ? e3 : na, "EMA50",  color=color.new(color.blue,   0), linewidth=1)
plot(show_emas ? e4 : na, "EMA200", color=color.new(color.white, 30), linewidth=2)

// ══════════════════════════════════════════════════════════════════════
//  SIGNAL LABELS — BUY / SELL
// ══════════════════════════════════════════════════════════════════════

if buy_signal
    string s = bull_bonus >= 6 ? "⚡ STRONG BUY\n" + str.tostring(bull_bonus) + "/8" :
                                  "▲ BUY  " + str.tostring(bull_bonus) + "/8"
    label.new(bar_index, low - atr_val * 1.5,
              s,
              style    = label.style_label_up,
              color    = bull_bonus >= 6 ? color.new(color.lime, 5) : color.new(color.green, 25),
              textcolor = color.black,
              size     = size.small)

if sell_signal
    string s = bear_bonus >= 6 ? "⚡ STRONG SELL\n" + str.tostring(bear_bonus) + "/8" :
                                  "▼ SELL  " + str.tostring(bear_bonus) + "/8"
    label.new(bar_index, high + atr_val * 1.5,
              s,
              style    = label.style_label_down,
              color    = bear_bonus >= 6 ? color.new(color.red, 5) : color.new(color.orange, 25),
              textcolor = color.white,
              size     = size.small)

// ══════════════════════════════════════════════════════════════════════
//  BREAKOUT / BREAKDOWN LABELS
// ══════════════════════════════════════════════════════════════════════

if bull_breakout and show_bo and not buy_signal
    label.new(bar_index, high + atr_val * 0.6,
              "🚀 BREAKOUT\n↑ Above Res",
              style=label.style_label_down,
              color=color.new(color.teal, 20), textcolor=color.white, size=size.tiny)

if bear_breakdown and show_bo and not sell_signal
    label.new(bar_index, low - atr_val * 0.6,
              "⬇️ BREAKDOWN\n↓ Below Sup",
              style=label.style_label_up,
              color=color.new(color.maroon, 20), textcolor=color.white, size=size.tiny)

if false_bull_bo and show_bo
    label.new(bar_index, high + atr_val * 0.4,
              "⚠️ FALSE BREAKOUT\nTrap — Bearish",
              style=label.style_label_down,
              color=color.new(color.red, 15), textcolor=color.white, size=size.tiny)

if false_bear_bd and show_bo
    label.new(bar_index, low - atr_val * 0.4,
              "⚠️ FALSE BREAKDOWN\nTrap — Bullish",
              style=label.style_label_up,
              color=color.new(color.green, 15), textcolor=color.white, size=size.tiny)

// ══════════════════════════════════════════════════════════════════════
//  CONSOLIDATION ZONE BACKGROUND
// ══════════════════════════════════════════════════════════════════════

bgcolor(consolidating and show_sq ? color.new(color.gray, 88) : na,
        title="Consolidation Zone")

// ══════════════════════════════════════════════════════════════════════
//  ATR-BASED SL / TP LINES  (drawn on signal bars)
// ══════════════════════════════════════════════════════════════════════

float sl_m  = 1.5
float tp1_m = 2.0
float tp2_m = 3.5
int   fwd   = 30

if buy_signal
    line.new(bar_index, close - atr_val * sl_m,  bar_index + fwd, close - atr_val * sl_m,
             color=color.new(color.red,  35), width=1, style=line.style_dotted)
    line.new(bar_index, close + atr_val * tp1_m, bar_index + fwd, close + atr_val * tp1_m,
             color=color.new(color.lime, 45), width=1, style=line.style_dotted)
    line.new(bar_index, close + atr_val * tp2_m, bar_index + fwd, close + atr_val * tp2_m,
             color=color.new(color.lime, 60), width=1, style=line.style_dotted)

if sell_signal
    line.new(bar_index, close + atr_val * sl_m,  bar_index + fwd, close + atr_val * sl_m,
             color=color.new(color.red,  35), width=1, style=line.style_dotted)
    line.new(bar_index, close - atr_val * tp1_m, bar_index + fwd, close - atr_val * tp1_m,
             color=color.new(color.lime, 45), width=1, style=line.style_dotted)
    line.new(bar_index, close - atr_val * tp2_m, bar_index + fwd, close - atr_val * tp2_m,
             color=color.new(color.lime, 60), width=1, style=line.style_dotted)

// ══════════════════════════════════════════════════════════════════════
//  DASHBOARD TABLE
// ══════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 22,
                           border_width=1,
                           border_color=color.new(color.gray, 50),
                           bgcolor=color.new(color.black, 70))

if barstate.islast
    color PASS = color.new(color.lime,   20)
    color FAIL = color.new(color.red,    20)
    color HEAD = color.new(color.navy,   30)
    color NEUT = color.new(color.gray,   55)
    color TEXT = color.white

    // ── Signal header ───────────────────────────────────────────────
    string hdr  = buy_signal  ? "🟢  BUY  " + str.tostring(bull_bonus) + "/8" :
                  sell_signal ? "🔴  SELL  " + str.tostring(bear_bonus) + "/8" :
                  consolidating ? "📦  CONSOLIDATION" : "⚪  NO SIGNAL"
    color  hcol = buy_signal  ? color.new(color.lime,20) :
                  sell_signal ? color.new(color.red, 20) :
                  consolidating ? color.new(color.gray,40) : color.new(color.gray,55)
    table.cell(dash,0,0, hdr,      bgcolor=hcol, text_color=TEXT, text_size=size.small)
    table.cell(dash,1,0, "STATUS", bgcolor=hcol, text_color=TEXT, text_size=size.small)

    // ── BUY GATES ───────────────────────────────────────────────────
    table.cell(dash,0, 1, "ADX Trend Gate",    bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 1, G1b?"✅ PASS":"❌ FAIL", bgcolor=G1b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 2, "EMA Slope (active)", bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 2, G2b?"✅ PASS":"❌ FAIL", bgcolor=G2b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 3, "RSI Zone",          bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 3, G3b?"✅ PASS":"❌ FAIL", bgcolor=G3b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 4, "MACD Momentum",     bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 4, G4b?"✅ PASS":"❌ FAIL", bgcolor=G4b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 5, "Candle Direction",  bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 5, G5b?"✅ PASS":"❌ FAIL", bgcolor=G5b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 6, "Not Overextended",  bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 6, G6b?"✅ PASS":"❌ FAIL", bgcolor=G6b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 7, "No RSI Divergence", bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 7, G7b?"✅ PASS":"❌ FAIL", bgcolor=G7b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 8, "No False Breakout", bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 8, G8b?"✅ PASS":"❌ FAIL", bgcolor=G8b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0, 9, "Not Consolidating", bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1, 9, G9b?"✅ PASS":"❌ FAIL", bgcolor=G9b?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    // ── Bonus ───────────────────────────────────────────────────────
    table.cell(dash,0,10, "Bonus Score",        bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,10, str.tostring(bull_bonus) + "/8  (min " + str.tostring(min_bonus) + ")",
               bgcolor=bull_bonus>=min_bonus?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    // ── Context ─────────────────────────────────────────────────────
    table.cell(dash,0,11, "Near Support",       bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,11, b_near_sup?"✅ YES":"— no", bgcolor=b_near_sup?PASS:NEUT, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,12, "Near Resistance",    bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,12, s_near_res?"⚠️ YES":"— no",
               bgcolor=s_near_res?color.new(color.orange,40):NEUT, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,13, "Breakout / Breakdown", bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,13, bull_breakout?"🚀 BREAKOUT":bear_breakdown?"⬇️ BREAKDOWN":"—",
               bgcolor=bull_breakout?PASS:bear_breakdown?FAIL:NEUT, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,14, "False BO / BD",      bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,14, false_bull_bo?"⚠️ FALSE BO":false_bear_bd?"⚠️ FALSE BD":"—",
               bgcolor=false_bull_bo or false_bear_bd?color.new(color.orange,25):NEUT,
               text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,15, "Consolidation",      bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,15, consolidating?"📦 YES":"— no",
               bgcolor=consolidating?color.new(color.gray,35):NEUT, text_color=TEXT, text_size=size.tiny)

    // ── S/R Levels ──────────────────────────────────────────────────
    table.cell(dash,0,16, "Resistance (R1)",    bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,16, not na(res1)?str.tostring(math.round(res1,2)):"—",
               bgcolor=color.new(color.red,65), text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,17, "Support (S1)",       bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,17, not na(sup1)?str.tostring(math.round(sup1,2)):"—",
               bgcolor=color.new(color.lime,65), text_color=TEXT, text_size=size.tiny)

    // ── Indicator readings ──────────────────────────────────────────
    table.cell(dash,0,18, "RSI",                bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,18, str.tostring(math.round(rsi_val,1)) + (rsi_above50?" ▲50":" ▼50"),
               bgcolor=rsi_above50?color.new(color.green,55):color.new(color.red,55),
               text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,19, "ADX",                bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,19, str.tostring(math.round(adx_val,1)),
               bgcolor=adx_val>adx_min?PASS:FAIL, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,20, "Stochastic K",       bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,20, str.tostring(math.round(stk_K,1)),
               bgcolor=stk_K<25?PASS:stk_K>75?FAIL:NEUT, text_color=TEXT, text_size=size.tiny)

    table.cell(dash,0,21, "MACD Histogram",     bgcolor=HEAD, text_color=TEXT, text_size=size.tiny)
    table.cell(dash,1,21, str.tostring(math.round(macd_hist,4)),
               bgcolor=macd_hist>0?color.new(color.green,50):color.new(color.red,50),
               text_color=TEXT, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════════
//  ALERT CONDITIONS
// ══════════════════════════════════════════════════════════════════════

alertcondition(buy_signal,      "🟢 BUY Signal",           "PRO v3 — BUY fired")
alertcondition(sell_signal,     "🔴 SELL Signal",          "PRO v3 — SELL fired")
alertcondition(bull_breakout,   "🚀 Breakout above Res",   "PRO v3 — Breakout above resistance")
alertcondition(bear_breakdown,  "⬇️ Breakdown below Sup",  "PRO v3 — Breakdown below support")
alertcondition(false_bull_bo,   "⚠️ False Breakout",       "PRO v3 — False Breakout (bearish trap)")
alertcondition(false_bear_bd,   "⚠️ False Breakdown",      "PRO v3 — False Breakdown (bullish trap)")
alertcondition(consolidating,   "📦 Consolidation",        "PRO v3 — Market entering consolidation zone")
````
