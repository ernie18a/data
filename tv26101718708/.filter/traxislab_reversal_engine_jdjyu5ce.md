# TraxisLab  Reversal Engine

- url: https://www.tradingview.com/script/jdJYu5ce/
- type: indicator
- pine_id: PUB;04605d6b244740a2a16abe851e7584c9
- version: 1.0

## Description

TraxisLab — Reversal Engine Pro is a multi-factor, score-based reversal indicator designed to identify high-probability turning points in the market. Built with an independent architecture, it combines trend analysis, momentum, structure breaks, candle quality, volatility, and volume into a unified scoring system to filter for stronger long and short reversal setups.

The indicator evaluates multiple confirmation layers, including EMA trend alignment, RSI and Stochastic momentum conditions, ADX strength, volume expansion, support and resistance proximity, and smart market structure events such as BOS (Break of Structure) and CHoCH (Change of Character). Each signal is converted into a score from 0 to 100, allowing traders to control sensitivity through Aggressive, Standard, or Conservative signal modes.

When the score reaches the required threshold, the script generates clear Long (L) or Short (S) labels directly on the chart. It also includes pending warnings (!) to highlight setups that are building momentum but have not yet fully confirmed. This helps traders prepare for possible entries before a full trigger occurs.

To support trade management, the indicator automatically calculates and displays:

Entry levels
ATR-based stop-loss
Up to three take-profit targets based on risk/reward multiples
A dynamic Smart Trail for trend-following and trailing stop guidance

Additional features include:

EMA trend filter
BOS / CHoCH structure labels
Liquidity pivot markers
Compact live statistics panel
Alert conditions for signals, strong signals, pending setups, structure changes, and trail flips

TraxisLab — Reversal Engine Pro is especially optimized for BTC on 5-minute and 15-minute charts, but can also be adapted to other volatile markets and timeframes.

Best suited for traders who want:

early reversal detection
confirmation-based entries
built-in risk management levels
structure-aware signal filtering
a clean visual decision framework

If you want, I can also turn this into:

a shorter Store-style TradingView description, or
a more premium/professional marketing version.

## Source Code

````pine
//@version=5
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  TRAXISLAB — REVERSAL ENGINE PRO                                         ║
// ║  Multi-Factor Score-Based Reversal System                                ║
// ║  Eigenständige Architektur · Keine LuxAlgo-Kopie                         ║
// ║  Optimiert für BTC 5m/15m                                                ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
indicator("TraxisLab — Reversal Engine", "TraxisLab REV", true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500,
     max_bars_back=5000)

// ═══════════════════════════════════════════════════════════════════════════
// │ 1  INPUTS                                                                │
// ═══════════════════════════════════════════════════════════════════════════

grp_sig = "⟐  Signal Engine"
i_mode = input.string("Standard", "Signalmodus", options=["Aggressiv", "Standard", "Konservativ"], group=grp_sig, tooltip="Aggressiv: Score≥25 · Standard: Score≥45 · Konservativ: Score≥65")
i_score_min = input.int(0, "Score-Override (0=Auto)", group=grp_sig, minval=0, maxval=90, step=5)
i_cooldown = input.int(8, "Cooldown (Bars)", group=grp_sig, minval=1, maxval=50)
i_pending = input.bool(true, "Pending-Warnungen anzeigen", group=grp_sig, tooltip="Zeigt ❗ wenn Score sich dem Schwellenwert nähert — möglicher Entry bald")
i_pend_pct = input.int(70, "Pending ab (% des Thresholds)", group=grp_sig, minval=50, maxval=95, step=5)

grp_trend = "⟐  Trend Filter"
i_ema_fast = input.int(21, "EMA schnell", group=grp_trend, minval=5, maxval=50)
i_ema_mid = input.int(50, "EMA mittel", group=grp_trend, minval=20, maxval=100)
i_ema_slow = input.int(200, "EMA langsam", group=grp_trend, minval=100, maxval=300)
i_trend_on = input.bool(true, "EMA-Filter aktiv", group=grp_trend)

grp_vol = "⟐  Volatilität"
i_atr_len = input.int(14, "ATR Länge", group=grp_vol, minval=5, maxval=50)
i_atr_mult = input.float(1.5, "ATR Multiplikator (Trail)", group=grp_vol, minval=0.5, maxval=4.0, step=0.1)

grp_struct = "⟐  Struktur"
i_pvt_len = input.int(5, "Pivot Lookback", group=grp_struct, minval=2, maxval=20)
i_struct_on = input.bool(true, "BOS/CHoCH-Signale", group=grp_struct)

grp_mom = "⟐  Momentum"
i_rsi_len = input.int(14, "RSI Länge", group=grp_mom, minval=5, maxval=30)
i_rsi_ob = input.int(70, "RSI Overbought", group=grp_mom, minval=60, maxval=90)
i_rsi_os = input.int(30, "RSI Oversold", group=grp_mom, minval=10, maxval=40)
i_adx_len = input.int(14, "ADX Länge", group=grp_mom, minval=5, maxval=30)
i_adx_min = input.int(20, "ADX Minimum", group=grp_mom, minval=10, maxval=40)
i_adx_on = input.bool(true, "ADX-Filter aktiv", group=grp_mom)
i_vol_on = input.bool(true, "Volumen-Filter aktiv", group=grp_mom)

grp_tp = "⟐  Targets & Stops"
i_tp_count = input.int(3, "Anzahl Take-Profits", group=grp_tp, minval=1, maxval=3)
i_tp1_mult = input.float(1.0, "TP1 (RR-x)", group=grp_tp, minval=0.5, maxval=5.0, step=0.25)
i_tp2_mult = input.float(2.0, "TP2 (RR-x)", group=grp_tp, minval=1.0, maxval=8.0, step=0.25)
i_tp3_mult = input.float(3.0, "TP3 (RR-x)", group=grp_tp, minval=1.5, maxval=12.0, step=0.25)
i_sl_atr = input.float(1.2, "SL-Puffer (ATR-x)", group=grp_tp, minval=0.3, maxval=3.0, step=0.1)

grp_vis = "⟐  Visuals"
i_show_trail = input.bool(true, "Smart Trail", group=grp_vis)
i_show_levels = input.bool(true, "Entry/SL/TP Levels", group=grp_vis)
i_show_struct = input.bool(true, "Struktur-Labels", group=grp_vis)
i_show_liq = input.bool(true, "Liquiditäts-Pivots", group=grp_vis)
i_show_stats = input.bool(true, "Statistik-Panel", group=grp_vis)
i_show_score = input.bool(false, "Score in Label", group=grp_vis)
i_max_levels = input.int(2, "Max. aktive Level-Sets", group=grp_vis, minval=1, maxval=5)

grp_col = "⟐  Farben"
c_bull = input.color(#00e5ff, "Bullish", group=grp_col)
c_bear = input.color(#ff1744, "Bearish", group=grp_col)
c_neutral = input.color(#787b86, "Neutral", group=grp_col)
c_warn = input.color(#ffc107, "Warnung", group=grp_col)

// ═══════════════════════════════════════════════════════════════════════════
// │ 2  CORE CALCULATIONS                                                     │
// ═══════════════════════════════════════════════════════════════════════════

atr_val = ta.atr(i_atr_len)
sa = nz(atr_val, close * 0.01)

ema_f = ta.ema(close, i_ema_fast)
ema_m = ta.ema(close, i_ema_mid)
ema_s = ta.ema(close, i_ema_slow)

rsi_val = ta.rsi(close, i_rsi_len)

f_adx(int len) =>
    up = high - high[1]
    dn = low[1] - low
    pDM = up > dn and up > 0 ? up : 0.0
    nDM = dn > up and dn > 0 ? dn : 0.0
    tr_val = ta.tr(true)
    pDI = 100 * ta.rma(pDM, len) / ta.rma(tr_val, len)
    nDI = 100 * ta.rma(nDM, len) / ta.rma(tr_val, len)
    dx = math.abs(pDI - nDI) / (pDI + nDI) * 100
    adx_out = ta.rma(dx, len)
    [adx_out, pDI, nDI]

[adx_val, di_plus, di_minus] = f_adx(i_adx_len)

vol_ma = ta.sma(volume, 20)
vol_above = volume > vol_ma * 1.1

stoch_k = ta.stoch(close, high, low, 14)
stoch_d = ta.sma(stoch_k, 3)

// ═══════════════════════════════════════════════════════════════════════════
// │ 3  STRUCTURE ENGINE (BOS / CHoCH)                                        │
// ═══════════════════════════════════════════════════════════════════════════

var float str_hi = na
var float str_lo = na
var int   str_hi_bar = 0
var int   str_lo_bar = 0
var int   str_trend = 0

pvh = ta.pivothigh(high, i_pvt_len, 1)
pvl = ta.pivotlow(low, i_pvt_len, 1)

if not na(pvh)
    str_hi := pvh
    str_hi_bar := bar_index - 1

if not na(pvl)
    str_lo := pvl
    str_lo_bar := bar_index - 1

bos_bull = not na(str_hi) and close > str_hi and close[1] <= nz(str_hi)
bos_bear = not na(str_lo) and close < str_lo and close[1] >= nz(str_lo)

choch_bull = str_trend == -1 and bos_bull
choch_bear = str_trend == 1  and bos_bear

if bos_bull
    str_trend := 1
    str_hi := na
if bos_bear
    str_trend := -1
    str_lo := na

if i_show_struct and i_struct_on and choch_bull
    label.new(bar_index, low - sa * 0.4, "CHoCH", xloc.bar_index, yloc.price, color.new(c_bull, 20), label.style_label_up, color.white, size.tiny, text.align_center, tooltip="Change of Character → Bullish\nStrukturwechsel bestätigt")
else if i_show_struct and i_struct_on and bos_bull
    label.new(bar_index, low - sa * 0.3, "BOS", xloc.bar_index, yloc.price, color.new(c_bull, 50), label.style_label_up, c_bull, size.tiny, text.align_center, tooltip="Break of Structure → Bullish")

if i_show_struct and i_struct_on and choch_bear
    label.new(bar_index, high + sa * 0.4, "CHoCH", xloc.bar_index, yloc.price, color.new(c_bear, 20), label.style_label_down, color.white, size.tiny, text.align_center, tooltip="Change of Character → Bearish\nStrukturwechsel bestätigt")
else if i_show_struct and i_struct_on and bos_bear
    label.new(bar_index, high + sa * 0.3, "BOS", xloc.bar_index, yloc.price, color.new(c_bear, 50), label.style_label_down, c_bear, size.tiny, text.align_center, tooltip="Break of Structure → Bearish")

// ═══════════════════════════════════════════════════════════════════════════
// │ 4  CANDLE QUALITY                                                        │
// ═══════════════════════════════════════════════════════════════════════════

body = math.abs(close - open)
full_range = high - low
body_ratio = full_range > 0 ? body / full_range : 0

is_bull_candle = close > open
is_bear_candle = close < open

upper_wick = is_bull_candle ? high - close : high - open
lower_wick = is_bull_candle ? open - low : close - low

is_hammer = lower_wick > body * 2 and upper_wick < body * 0.5 and is_bull_candle
is_shooting_star = upper_wick > body * 2 and lower_wick < body * 0.5 and is_bear_candle
is_bull_engulf = is_bull_candle and is_bear_candle[1] and close > open[1] and open < close[1]
is_bear_engulf = is_bear_candle and is_bull_candle[1] and close < open[1] and open > close[1]

// ═══════════════════════════════════════════════════════════════════════════
// │ 5  SCORING ENGINE (0-100)                                                │
// ═══════════════════════════════════════════════════════════════════════════

recent_swing_lo = ta.lowest(low, i_pvt_len * 2)
recent_swing_hi = ta.highest(high, i_pvt_len * 2)
swing_rng = recent_swing_hi - recent_swing_lo
near_support = swing_rng > 0 ? (close - recent_swing_lo) / swing_rng < 0.2 : false
near_resist  = swing_rng > 0 ? (close - recent_swing_lo) / swing_rng > 0.8 : false

f_score_long() =>
    int sc = 0
    if i_trend_on
        if ema_f > ema_m
            sc += 8
        if close > ema_s
            sc += 7
    else
        sc += 8
    if rsi_val < i_rsi_os
        sc += 15
    else if rsi_val < 40
        sc += 5
    if stoch_k < 20
        sc += 10
    else if stoch_k < 35
        sc += 4
    if choch_bull
        sc += 20
    else if bos_bull
        sc += 12
    if is_bull_engulf
        sc += 15
    else if is_hammer
        sc += 12
    else if body_ratio > 0.6 and is_bull_candle
        sc += 6
    if i_vol_on and vol_above
        sc += 10
    else if not i_vol_on
        sc += 5
    if near_support
        sc += 10
    if i_adx_on and adx_val > i_adx_min
        sc += 5
    else if not i_adx_on
        sc += 3
    math.min(100, sc)

f_score_short() =>
    int sc = 0
    if i_trend_on
        if ema_f < ema_m
            sc += 8
        if close < ema_s
            sc += 7
    else
        sc += 8
    if rsi_val > i_rsi_ob
        sc += 15
    else if rsi_val > 60
        sc += 5
    if stoch_k > 80
        sc += 10
    else if stoch_k > 65
        sc += 4
    if choch_bear
        sc += 20
    else if bos_bear
        sc += 12
    if is_bear_engulf
        sc += 15
    else if is_shooting_star
        sc += 12
    else if body_ratio > 0.6 and is_bear_candle
        sc += 6
    if i_vol_on and vol_above
        sc += 10
    else if not i_vol_on
        sc += 5
    if near_resist
        sc += 10
    if i_adx_on and adx_val > i_adx_min
        sc += 5
    else if not i_adx_on
        sc += 3
    math.min(100, sc)

score_long = f_score_long()
score_short = f_score_short()

auto_thresh = i_mode == "Aggressiv" ? 25 : i_mode == "Standard" ? 45 : 65
thresh = i_score_min > 0 ? i_score_min : auto_thresh

sideways = i_adx_on and adx_val < i_adx_min

// ═══════════════════════════════════════════════════════════════════════════
// │ 6  SIGNAL + PENDING GENERATION                                           │
// ═══════════════════════════════════════════════════════════════════════════

var int last_long_bar = -9999
var int last_short_bar = -9999

cd_long = bar_index - last_long_bar > i_cooldown
cd_short = bar_index - last_short_bar > i_cooldown

sig_long = score_long >= thresh and cd_long and not sideways
sig_short = score_short >= thresh and cd_short and not sideways

is_strong_long = sig_long and score_long >= 65
is_strong_short = sig_short and score_short >= 65

if sig_long
    last_long_bar := bar_index
if sig_short
    last_short_bar := bar_index

// Pending-Erkennung: Score nähert sich dem Threshold
pend_thresh = math.round(float(thresh) * float(i_pend_pct) / 100.0)
pend_long = not sig_long and score_long >= pend_thresh and score_long < thresh and cd_long and not sideways
pend_short = not sig_short and score_short >= pend_thresh and score_short < thresh and cd_short and not sideways

// ═══════════════════════════════════════════════════════════════════════════
// │ 7  SMART TRAIL                                                           │
// ═══════════════════════════════════════════════════════════════════════════

var float trail_val = na
var int   trail_dir = 0

atr_trail = sa * i_atr_mult

if sig_long or (trail_dir == 1 and close > trail_val)
    float new_trail = close - atr_trail
    if trail_dir == 1 and not na(trail_val)
        trail_val := math.max(nz(trail_val), new_trail)
    else
        trail_val := new_trail
    trail_dir := 1

if sig_short or (trail_dir == -1 and close < trail_val)
    float new_trail2 = close + atr_trail
    if trail_dir == -1 and not na(trail_val)
        trail_val := math.min(nz(trail_val), new_trail2)
    else
        trail_val := new_trail2
    trail_dir := -1

if trail_dir == 1 and close < nz(trail_val, close)
    trail_val := close + atr_trail
    trail_dir := -1
if trail_dir == -1 and close > nz(trail_val, close)
    trail_val := close - atr_trail
    trail_dir := 1

color trail_col = trail_dir == 1 ? color.new(c_bull, 30) : color.new(c_bear, 30)
plot(i_show_trail and not na(trail_val) ? trail_val : na, "Smart Trail", trail_col, 2, plot.style_steplinebr)

// ═══════════════════════════════════════════════════════════════════════════
// │ 8  LEVEL MANAGER (Entry / SL / TP1-3)                                    │
// ═══════════════════════════════════════════════════════════════════════════

var array<float> sig_entry = array.new_float(0)
var array<float> sig_sl = array.new_float(0)
var array<float> sig_tp1 = array.new_float(0)
var array<float> sig_tp2 = array.new_float(0)
var array<float> sig_tp3 = array.new_float(0)
var array<bool>  sig_is_long = array.new_bool(0)
var array<int>   sig_bar = array.new_int(0)

var int stat_total = 0
var int stat_win_tp1 = 0
var int stat_win_tp2 = 0
var int stat_win_tp3 = 0
var int stat_loss = 0
var float stat_rr_sum = 0.0

f_cleanup_levels() =>
    while array.size(sig_entry) > i_max_levels
        array.shift(sig_entry)
        array.shift(sig_sl)
        array.shift(sig_tp1)
        array.shift(sig_tp2)
        array.shift(sig_tp3)
        array.shift(sig_is_long)
        array.shift(sig_bar)

if array.size(sig_entry) > 0
    for i = array.size(sig_entry) - 1 to 0
        if i >= array.size(sig_entry)
            break
        float en = array.get(sig_entry, i)
        float sl = array.get(sig_sl, i)
        float t1 = array.get(sig_tp1, i)
        float t3 = array.get(sig_tp3, i)
        bool is_l = array.get(sig_is_long, i)
        int sb = array.get(sig_bar, i)

        if bar_index - sb > 1
            bool sl_hit = is_l ? (low <= sl) : (high >= sl)
            bool tp1_hit = is_l ? (high >= t1) : (low <= t1)
            bool tp3_hit = is_l ? (high >= t3) : (low <= t3)

            if sl_hit or tp1_hit or bar_index - sb > 100
                stat_total += 1
                if tp1_hit and not sl_hit
                    stat_win_tp1 += 1
                    float t2 = array.get(sig_tp2, i)
                    if is_l ? (high >= t2) : (low <= t2)
                        stat_win_tp2 += 1
                    if tp3_hit
                        stat_win_tp3 += 1
                    risk = math.abs(en - sl)
                    reward = math.abs(t1 - en)
                    stat_rr_sum += risk > 0 ? reward / risk : 0
                else
                    stat_loss += 1

                array.remove(sig_entry, i)
                array.remove(sig_sl, i)
                array.remove(sig_tp1, i)
                array.remove(sig_tp2, i)
                array.remove(sig_tp3, i)
                array.remove(sig_is_long, i)
                array.remove(sig_bar, i)

// ═══════════════════════════════════════════════════════════════════════════
// │ 9  SIGNAL LABELS: L / S / ! (mit Tooltips)                              │
// ═══════════════════════════════════════════════════════════════════════════

if sig_long
    float en = close
    float risk = sa * i_sl_atr
    float sl = en - risk
    float tp1 = en + risk * i_tp1_mult
    float tp2 = en + risk * i_tp2_mult
    float tp3 = en + risk * i_tp3_mult

    // Level-Tracking
    if i_show_levels
        array.push(sig_entry, en)
        array.push(sig_sl, sl)
        array.push(sig_tp1, tp1)
        array.push(sig_tp2, tp2)
        array.push(sig_tp3, tp3)
        array.push(sig_is_long, true)
        array.push(sig_bar, bar_index)
        f_cleanup_levels()

    // L-Label mit Entry/SL/TP Tooltip
    string strength = is_strong_long ? "STRONG" : "Standard"
    string tt_l = "───────────────────\n"
    tt_l := tt_l + "   LONG SIGNAL  ·  " + strength + "\n"
    tt_l := tt_l + "───────────────────\n"
    tt_l := tt_l + "   Score          " + str.tostring(score_long) + "/100\n"
    tt_l := tt_l + "   Entry          " + str.tostring(en, format.mintick) + "\n"
    tt_l := tt_l + "   Stop-Loss    " + str.tostring(sl, format.mintick) + "\n"
    tt_l := tt_l + "───────────────────\n"
    tt_l := tt_l + "   TP1             " + str.tostring(tp1, format.mintick) + "  (" + str.tostring(i_tp1_mult, "#.0") + "R)\n"
    if i_tp_count >= 2
        tt_l := tt_l + "   TP2             " + str.tostring(tp2, format.mintick) + "  (" + str.tostring(i_tp2_mult, "#.0") + "R)\n"
    if i_tp_count >= 3
        tt_l := tt_l + "   TP3             " + str.tostring(tp3, format.mintick) + "  (" + str.tostring(i_tp3_mult, "#.0") + "R)\n"
    tt_l := tt_l + "───────────────────\n"
    tt_l := tt_l + "   RSI " + str.tostring(rsi_val, "#.0") + "  ·  ADX " + str.tostring(adx_val, "#.0") + "\n"
    tt_l := tt_l + "   Trend: " + (str_trend == 1 ? "Bullish ✓" : str_trend == -1 ? "Bearish ✗" : "Neutral")

    color lbl_col = is_strong_long ? color.new(c_bull, 0) : color.new(c_bull, 35)
    string lbl_sz = is_strong_long ? size.small : size.tiny
    label.new(bar_index, low - sa * 0.5, "L", xloc.bar_index, yloc.price, lbl_col, label.style_label_up, color.white, lbl_sz, text.align_center, tt_l)

if sig_short
    float en = close
    float risk = sa * i_sl_atr
    float sl = en + risk
    float tp1 = en - risk * i_tp1_mult
    float tp2 = en - risk * i_tp2_mult
    float tp3 = en - risk * i_tp3_mult

    if i_show_levels
        array.push(sig_entry, en)
        array.push(sig_sl, sl)
        array.push(sig_tp1, tp1)
        array.push(sig_tp2, tp2)
        array.push(sig_tp3, tp3)
        array.push(sig_is_long, false)
        array.push(sig_bar, bar_index)
        f_cleanup_levels()

    string strength2 = is_strong_short ? "STRONG" : "Standard"
    string tt_s = "───────────────────\n"
    tt_s := tt_s + "   SHORT SIGNAL  ·  " + strength2 + "\n"
    tt_s := tt_s + "───────────────────\n"
    tt_s := tt_s + "   Score          " + str.tostring(score_short) + "/100\n"
    tt_s := tt_s + "   Entry          " + str.tostring(en, format.mintick) + "\n"
    tt_s := tt_s + "   Stop-Loss    " + str.tostring(sl, format.mintick) + "\n"
    tt_s := tt_s + "───────────────────\n"
    tt_s := tt_s + "   TP1             " + str.tostring(tp1, format.mintick) + "  (" + str.tostring(i_tp1_mult, "#.0") + "R)\n"
    if i_tp_count >= 2
        tt_s := tt_s + "   TP2             " + str.tostring(tp2, format.mintick) + "  (" + str.tostring(i_tp2_mult, "#.0") + "R)\n"
    if i_tp_count >= 3
        tt_s := tt_s + "   TP3             " + str.tostring(tp3, format.mintick) + "  (" + str.tostring(i_tp3_mult, "#.0") + "R)\n"
    tt_s := tt_s + "───────────────────\n"
    tt_s := tt_s + "   RSI " + str.tostring(rsi_val, "#.0") + "  ·  ADX " + str.tostring(adx_val, "#.0") + "\n"
    tt_s := tt_s + "   Trend: " + (str_trend == -1 ? "Bearish ✓" : str_trend == 1 ? "Bullish ✗" : "Neutral")

    color lbl_col2 = is_strong_short ? color.new(c_bear, 0) : color.new(c_bear, 35)
    string lbl_sz2 = is_strong_short ? size.small : size.tiny
    label.new(bar_index, high + sa * 0.5, "S", xloc.bar_index, yloc.price, lbl_col2, label.style_label_down, color.white, lbl_sz2, text.align_center, tt_s)

// ─── PENDING WARNINGS: ! ────────────────────────────────────────────────
if i_pending and pend_long
    float pot_en = close
    float pot_risk = sa * i_sl_atr
    float pot_sl = pot_en - pot_risk
    float pot_tp1 = pot_en + pot_risk * i_tp1_mult

    string tt_p = "───────────────────\n"
    tt_p := tt_p + "   ⚠ PENDING LONG\n"
    tt_p := tt_p + "───────────────────\n"
    tt_p := tt_p + "   Score baut sich auf:\n"
    tt_p := tt_p + "   Aktuell   " + str.tostring(score_long) + " / " + str.tostring(thresh) + " nötig\n"
    tt_p := tt_p + "   Fehlend  " + str.tostring(thresh - score_long) + " Punkte\n"
    tt_p := tt_p + "───────────────────\n"
    tt_p := tt_p + "   Möglicher Entry:\n"
    tt_p := tt_p + "   ~Entry    " + str.tostring(pot_en, format.mintick) + "\n"
    tt_p := tt_p + "   ~SL         " + str.tostring(pot_sl, format.mintick) + "\n"
    tt_p := tt_p + "   ~TP1       " + str.tostring(pot_tp1, format.mintick) + "\n"
    tt_p := tt_p + "───────────────────\n"
    tt_p := tt_p + "   Noch kein Signal!\n"
    tt_p := tt_p + "   Warte auf Bestätigung."

    label.new(bar_index, low - sa * 0.3, "!", xloc.bar_index, yloc.price, color.new(c_warn, 30), label.style_label_up, c_warn, size.tiny, text.align_center, tt_p)

if i_pending and pend_short
    float pot_en2 = close
    float pot_risk2 = sa * i_sl_atr
    float pot_sl2 = pot_en2 + pot_risk2
    float pot_tp1b = pot_en2 - pot_risk2 * i_tp1_mult

    string tt_p2 = "───────────────────\n"
    tt_p2 := tt_p2 + "   ⚠ PENDING SHORT\n"
    tt_p2 := tt_p2 + "───────────────────\n"
    tt_p2 := tt_p2 + "   Score baut sich auf:\n"
    tt_p2 := tt_p2 + "   Aktuell   " + str.tostring(score_short) + " / " + str.tostring(thresh) + " nötig\n"
    tt_p2 := tt_p2 + "   Fehlend  " + str.tostring(thresh - score_short) + " Punkte\n"
    tt_p2 := tt_p2 + "───────────────────\n"
    tt_p2 := tt_p2 + "   Möglicher Entry:\n"
    tt_p2 := tt_p2 + "   ~Entry    " + str.tostring(pot_en2, format.mintick) + "\n"
    tt_p2 := tt_p2 + "   ~SL         " + str.tostring(pot_sl2, format.mintick) + "\n"
    tt_p2 := tt_p2 + "   ~TP1       " + str.tostring(pot_tp1b, format.mintick) + "\n"
    tt_p2 := tt_p2 + "───────────────────\n"
    tt_p2 := tt_p2 + "   Noch kein Signal!\n"
    tt_p2 := tt_p2 + "   Warte auf Bestätigung."

    label.new(bar_index, high + sa * 0.3, "!", xloc.bar_index, yloc.price, color.new(c_warn, 30), label.style_label_down, c_warn, size.tiny, text.align_center, tt_p2)

// ═══════════════════════════════════════════════════════════════════════════
// │ 10  LEVEL LINES (letzte aktive Sets)                                     │
// ═══════════════════════════════════════════════════════════════════════════

var array<line> active_lines = array.new_line(0)
var array<label> active_lvl_labels = array.new_label(0)

if barstate.islast
    if array.size(active_lines) > 0
        for i = 0 to array.size(active_lines) - 1
            line.delete(array.get(active_lines, i))
    array.clear(active_lines)
    if array.size(active_lvl_labels) > 0
        for i = 0 to array.size(active_lvl_labels) - 1
            label.delete(array.get(active_lvl_labels, i))
    array.clear(active_lvl_labels)

    if i_show_levels and array.size(sig_entry) > 0
        for i = 0 to array.size(sig_entry) - 1
            if i >= array.size(sig_entry)
                break
            float en = array.get(sig_entry, i)
            float sl = array.get(sig_sl, i)
            float t1 = array.get(sig_tp1, i)
            float t2 = array.get(sig_tp2, i)
            float t3 = array.get(sig_tp3, i)
            bool is_l = array.get(sig_is_long, i)
            int sb = array.get(sig_bar, i)
            string dir_txt = is_l ? "L" : "S"

            // Entry
            array.push(active_lines, line.new(sb, en, bar_index + 5, en, color=color.new(color.white, 30), width=1, style=line.style_dashed))
            array.push(active_lvl_labels, label.new(bar_index + 6, en, dir_txt + " EN", xloc.bar_index, yloc.price, color.new(color.white, 70), label.style_label_left, color.white, size.tiny))

            // SL
            array.push(active_lines, line.new(sb, sl, bar_index + 5, sl, color=color.new(c_bear, 20), width=1, style=line.style_dotted))
            array.push(active_lvl_labels, label.new(bar_index + 6, sl, "SL", xloc.bar_index, yloc.price, color.new(c_bear, 60), label.style_label_left, c_bear, size.tiny))

            // TP1
            color tp_col = is_l ? color.new(c_bull, 20) : color.new(c_bear, 20)
            array.push(active_lines, line.new(sb, t1, bar_index + 5, t1, color=tp_col, width=1, style=line.style_dotted))
            array.push(active_lvl_labels, label.new(bar_index + 6, t1, "TP1", xloc.bar_index, yloc.price, color.new(c_bull, 60), label.style_label_left, c_bull, size.tiny))

            if i_tp_count >= 2
                array.push(active_lines, line.new(sb, t2, bar_index + 5, t2, color=color.new(c_bull, 40), width=1, style=line.style_dotted))
                array.push(active_lvl_labels, label.new(bar_index + 6, t2, "TP2", xloc.bar_index, yloc.price, color.new(c_bull, 70), label.style_label_left, c_bull, size.tiny))

            if i_tp_count >= 3
                array.push(active_lines, line.new(sb, t3, bar_index + 5, t3, color=color.new(c_bull, 60), width=1, style=line.style_dotted))
                array.push(active_lvl_labels, label.new(bar_index + 6, t3, "TP3", xloc.bar_index, yloc.price, color.new(c_bull, 80), label.style_label_left, c_bull, size.tiny))

// ═══════════════════════════════════════════════════════════════════════════
// │ 11  LIQUIDITY PIVOTS + EMAs                                              │
// ═══════════════════════════════════════════════════════════════════════════

plotshape(i_show_liq and not na(pvh), "Liq High", shape.xcross, location.abovebar, color.new(c_bear, 60), size=size.auto)
plotshape(i_show_liq and not na(pvl), "Liq Low", shape.xcross, location.belowbar, color.new(c_bull, 60), size=size.auto)

plot(i_trend_on ? ema_f : na, "EMA Fast", color.new(c_bull, 70), 1)
plot(i_trend_on ? ema_m : na, "EMA Mid", color.new(c_warn, 70), 1)
plot(i_trend_on ? ema_s : na, "EMA Slow", color.new(c_neutral, 70), 1)

// ═══════════════════════════════════════════════════════════════════════════
// │ 12  STATISTIK-PANEL (kompakt, bottom_right)                              │
// ═══════════════════════════════════════════════════════════════════════════

var table stats = table.new(position.bottom_right, 2, 6,
     bgcolor=color.new(#0f1119, 10),
     border_color=color.new(#2a2d3a, 60),
     border_width=1,
     frame_color=color.new(#2a2d3a, 50),
     frame_width=1)

if i_show_stats and barstate.islast
    win_rate = stat_total > 0 ? math.round(float(stat_win_tp1) / float(stat_total) * 100) : 0
    avg_rr = stat_win_tp1 > 0 ? stat_rr_sum / float(stat_win_tp1) : 0
    color wr_col = win_rate >= 55 ? c_bull : win_rate >= 40 ? c_warn : c_bear

    table.cell(stats, 0, 0, "TraxisLab", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))
    table.cell(stats, 1, 0, i_mode, text_color=c_warn, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))

    table.cell(stats, 0, 1, "W/L", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 1, str.tostring(stat_win_tp1) + "/" + str.tostring(stat_loss), text_color=color.white, text_size=size.tiny)

    table.cell(stats, 0, 2, "Rate", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 2, str.tostring(win_rate) + "%", text_color=wr_col, text_size=size.tiny)

    table.cell(stats, 0, 3, "RR", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 3, str.tostring(avg_rr, "#.0") + "R", text_color=avg_rr >= 1.5 ? c_bull : c_warn, text_size=size.tiny)

    int cur_dom = score_long > score_short ? score_long : score_short
    string cur_dir = score_long > score_short ? "L" : "S"
    color cur_col = score_long > score_short ? c_bull : c_bear
    table.cell(stats, 0, 4, "Score", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 4, cur_dir + " " + str.tostring(cur_dom), text_color=cur_col, text_size=size.tiny)

    string adx_txt = sideways ? "FLAT" : str.tostring(adx_val, "#")
    color adx_col = sideways ? c_warn : c_neutral
    table.cell(stats, 0, 5, "ADX", text_color=#5a5e70, text_size=size.tiny)
    table.cell(stats, 1, 5, adx_txt, text_color=adx_col, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// │ 13  ALERTS                                                               │
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(sig_long, "Long Signal", "TraxisLab REV: Long Signal")
alertcondition(sig_short, "Short Signal", "TraxisLab REV: Short Signal")
alertcondition(is_strong_long, "Strong Long", "⭐ TraxisLab REV: STRONG LONG (Score ≥ 65)")
alertcondition(is_strong_short, "Strong Short", "⭐ TraxisLab REV: STRONG SHORT (Score ≥ 65)")
alertcondition(pend_long, "Pending Long", "⚠ TraxisLab REV: Möglicher Long-Entry baut sich auf")
alertcondition(pend_short, "Pending Short", "⚠ TraxisLab REV: Möglicher Short-Entry baut sich auf")
alertcondition(choch_bull, "CHoCH Bull", "TraxisLab REV: Bullish Change of Character")
alertcondition(choch_bear, "CHoCH Bear", "TraxisLab REV: Bearish Change of Character")
alertcondition(trail_dir == 1 and trail_dir[1] == -1, "Trail Flip Bull", "TraxisLab REV: Trail → Bullish")
alertcondition(trail_dir == -1 and trail_dir[1] == 1, "Trail Flip Bear", "TraxisLab REV: Trail → Bearish")
````
