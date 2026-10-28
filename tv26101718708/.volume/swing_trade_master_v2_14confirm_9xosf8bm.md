# Swing Trade Master v2 [14-Confirm]

- url: https://www.tradingview.com/script/9XosF8Bm-Swing-Trade-Master-v2-14-Confirm/
- type: indicator
- pine_id: PUB;f9fa5ce52d1448feb8e2f7d6959b86a7
- version: 1.0

## Description

Overview
Instead of relying on any single indicator, this script runs 14 indicators simultaneously on every bar and assigns each one a vote — bullish or bearish. Those votes are tallied into a score out of 14. A trade signal only fires when the score clears your chosen threshold and a momentum trigger fires at the exact same bar, ensuring both the broad market context and short-term timing agree. A Choppiness Index gate sits above everything and blocks all signals when the market is ranging rather than trending.
How a signal is generated — step by step

Choppiness gate check
The Choppiness Index is calculated first. If it reads above 61.8 (ranging/choppy market), all signals are suppressed for that bar and bars tint gray. This prevents entries during sideways price action where trend indicators give false signals.

Each indicator casts a vote
All 14 indicators evaluate the current bar. Each one produces a binary result — bullish (1) or bearish (0). Trend indicators look at alignment, momentum oscillators look at zones, and volume/flow indicators check buying vs selling pressure.

Scores are tallied
Bull votes are summed into a Bull Score (0–14) and bear votes into a Bear Score (0–14). Both are displayed live in the HUD table on the top-right of your chart. A score of 7 or above means at least half of all indicators agree on direction.

Score threshold check
The bull/bear score must reach your configured minimum (default 7/14). This filters out weak or ambiguous setups where indicators disagree. The higher you set this threshold, the fewer but stronger signals you receive.

Momentum trigger required
Even with a passing score, the signal won't fire unless a momentum-based crossover also occurs on the same bar — one of: MACD cross, RSI exiting oversold/overbought, Stochastic RSI cross, Williams %R exit, Super trend flip, or Parabolic SAR flip. This provides precise timing, so you don't enter mid-trend.

Opposing score tie-break
A final sanity check: if the opposing score is higher than the signal score, the signal is blocked. For example, a bull score of 8 is blocked if the bear score is 9 — the market is too mixed to take confidently.

De-duplication
Once a BUY or SELL fires, it is locked in. Subsequent bars that would trigger the same direction are suppressed until a signal in the opposite direction appears. This means you never see stacks of BUY labels on consecutive bars.

ATR stop loss and take profit drawn
On signal bars, horizontal SL and TP lines are drawn. Stop Loss = entry price minus (ATR × 1.5). Take Profit = entry price plus (ATR × 3.0). This gives a default 2:1 risk/reward ratio. Both multipliers are adjustable in settings.

Exit monitoring begins
After entry, the script monitors 10 exit conditions. A minimum of 3 bars must pass before any exit can fire. Then either a single strong exit (Super trend or PSAR flip) or 2+ standard exit conditions must agree simultaneously. Only one exit signal per trade is shown — never repeated.
Signal types on the chart
▲ BUY — green label below bar
All conditions met. Shows score, SL price, TP price in a detail label. Teal PSAR dots switch below price. Supertrend line turns green.
▼ SELL — red label above bar
All conditions met for short entry. Shows score, SL, TP. PSAR dots switch above price. Supertrend line turns red.
✕ Exit long — orange X above bar
Fired after 3+ bars when Supertrend/PSAR flips bearish, or 2+ of: RSI OB cross, MACD cross, Stoch, CCI, WPR, MFI, or VWAP cross.
✕ Exit short — cyan X below bar
Fired after 3+ bars when Supertrend/PSAR flips bullish, or 2+ of the same conditions reversed. One exit maximum per trade.
When the market is choppy (Choppiness Index > 61.8), bars tint gray and a ⚠ CHOP label appears on the last bar. No BUY or SELL signals will fire until trending conditions return.

Recommended settings by market type
Stocks (trending)
Score 7–8 · 4H or Daily · ATR SL 1.5 · TP 3.0
Crypto (volatile)
Score 8–9 · 4H or Daily · ATR SL 2.0 · TP 4.0
Forex (ranging)
Score 8+ · Daily only · Lower Chop to 55 · SL 1.2
Index ETFs
Score 6–7 · Daily · Default ATR · Standard Chop

## Source Code

````pine
// ============================================================
//  SWING TRADE MASTER v2 — ENHANCED [14-Indicator Confirm]
//  TradingView Pine Script v5
//
//  SCORED INDICATORS (14 total):
//    1.  EMA Trend         (20 / 50 / 200 alignment)
//    2.  RSI               (momentum zone + OB/OS)
//    3.  MACD              (crossover + histogram)
//    4.  Stochastic RSI    (K/D cross + zones)
//    5.  ADX / DMI         (trend strength + direction)
//    6.  CCI               (commodity channel)
//    7.  Bollinger Bands   (price vs midline)
//    8.  Williams %R       (OB/OS exit timing)
//    9.  Volume            (above-average confirmation)
//   10.  Supertrend        (ATR-based trend direction)
//   11.  Rolling VWAP      (institutional price reference)
//   12.  Squeeze Momentum  (BB inside KC = breakout setup)
//   13.  Parabolic SAR     (adaptive trailing direction)
//   14.  Money Flow Index  (volume-weighted RSI)
//
//  GATE FILTER:
//    →  Choppiness Index   (suppresses signals in ranging markets)
// ============================================================

//@version=5
indicator("Swing Trade Master v2 [14-Confirm]", shorttitle="STMv2", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────
// SECTION 1 — USER INPUTS
// ─────────────────────────────────────────────

// ── EMA ──
grp_ema      = "📈 EMA Trend Settings"
ema_fast     = input.int(20,  "Fast EMA",  minval=5,  group=grp_ema)
ema_mid      = input.int(50,  "Mid EMA",   minval=10, group=grp_ema)
ema_slow     = input.int(200, "Slow EMA",  minval=50, group=grp_ema)

// ── RSI ──
grp_rsi      = "📊 RSI Settings"
rsi_len      = input.int(14, "RSI Length",      minval=2, group=grp_rsi)
rsi_ob       = input.int(70, "RSI Overbought",  minval=50,group=grp_rsi)
rsi_os       = input.int(30, "RSI Oversold",    minval=1, maxval=49, group=grp_rsi)

// ── MACD ──
grp_macd     = "📉 MACD Settings"
macd_fast    = input.int(12, "MACD Fast",   minval=2, group=grp_macd)
macd_slow    = input.int(26, "MACD Slow",   minval=5, group=grp_macd)
macd_signal  = input.int(9,  "MACD Signal", minval=2, group=grp_macd)

// ── Stochastic RSI ──
grp_stoch    = "🔀 Stochastic RSI Settings"
stoch_len    = input.int(14, "Stoch Length",    minval=2, group=grp_stoch)
stoch_k      = input.int(3,  "Stoch %K Smooth", minval=1, group=grp_stoch)
stoch_d      = input.int(3,  "Stoch %D Smooth", minval=1, group=grp_stoch)
stoch_ob     = input.int(80, "Stoch Overbought",minval=50,group=grp_stoch)
stoch_os     = input.int(20, "Stoch Oversold",  maxval=49,group=grp_stoch)

// ── ADX ──
grp_adx      = "💪 ADX Trend Strength"
adx_len      = input.int(14, "ADX Length",            minval=2, group=grp_adx)
adx_thresh   = input.int(20, "ADX Min Strength",      minval=5, group=grp_adx)

// ── CCI ──
grp_cci      = "🔵 CCI Settings"
cci_len      = input.int(20,   "CCI Length",    minval=2,   group=grp_cci)
cci_ob       = input.int(100,  "CCI Overbought",minval=50,  group=grp_cci)
cci_os       = input.int(-100, "CCI Oversold",  maxval=-50, group=grp_cci)

// ── Bollinger Bands ──
grp_bb       = "🎯 Bollinger Bands"
bb_len       = input.int(20,   "BB Length",  minval=2,   group=grp_bb)
bb_mult      = input.float(2.0,"BB Std Dev", minval=0.5, step=0.1, group=grp_bb)

// ── Williams %R ──
grp_wpr      = "🟣 Williams %R Settings"
wpr_len      = input.int(14,  "WPR Length",     minval=2,  group=grp_wpr)
wpr_ob       = input.int(-20, "WPR Overbought", maxval=-5, group=grp_wpr)
wpr_os       = input.int(-80, "WPR Oversold",   minval=-95,group=grp_wpr)

// ── ATR / Risk ──
grp_atr      = "📐 ATR / Risk Settings"
atr_len      = input.int(14,   "ATR Length",          minval=2,   group=grp_atr)
atr_mult_sl  = input.float(1.5,"ATR Stop Loss Mult",  minval=0.5, step=0.1, group=grp_atr)
atr_mult_tp  = input.float(3.0,"ATR Take Profit Mult",minval=0.5, step=0.1, group=grp_atr)

// ── Volume ──
grp_vol      = "📦 Volume Settings"
vol_ma_len   = input.int(20, "Volume MA Length", minval=2, group=grp_vol)

// ── Supertrend ──
grp_st       = "🚀 Supertrend Settings"
st_factor    = input.float(3.0,"Supertrend Factor",    minval=0.5, step=0.1, group=grp_st)
st_atr_len   = input.int(10,  "Supertrend ATR Period", minval=2,   group=grp_st)
show_st      = input.bool(true,"Show Supertrend Line",              group=grp_st)

// ── Rolling VWAP ──
grp_vwap     = "💠 Rolling VWAP Settings"
vwap_len     = input.int(20,  "VWAP Period (bars)",  minval=5,  group=grp_vwap)
show_vwap    = input.bool(true,"Show VWAP Line",                  group=grp_vwap)

// ── Squeeze Momentum ──
grp_sq       = "🌀 Squeeze Momentum Settings"
sq_len       = input.int(20,   "Squeeze Length",  minval=5,   group=grp_sq)
sq_bb_mult   = input.float(2.0,"Squeeze BB Mult", minval=0.5, step=0.1, group=grp_sq)
sq_kc_mult   = input.float(1.5,"Squeeze KC Mult", minval=0.5, step=0.1, group=grp_sq)

// ── Parabolic SAR ──
grp_psar     = "🔶 Parabolic SAR Settings"
psar_start   = input.float(0.02,"PSAR Start",    minval=0.001, step=0.001, group=grp_psar)
psar_inc     = input.float(0.02,"PSAR Increment",minval=0.001, step=0.001, group=grp_psar)
psar_max     = input.float(0.2, "PSAR Maximum",  minval=0.05,  step=0.01,  group=grp_psar)
show_psar    = input.bool(true, "Show PSAR Dots",                           group=grp_psar)

// ── Money Flow Index ──
grp_mfi      = "💰 Money Flow Index (MFI)"
mfi_len      = input.int(14, "MFI Length",    minval=2,  group=grp_mfi)
mfi_ob       = input.int(80, "MFI Overbought",minval=50, group=grp_mfi)
mfi_os       = input.int(20, "MFI Oversold",  maxval=49, group=grp_mfi)

// ── Choppiness Index (Gate Filter) ──
grp_chop     = "🚧 Choppiness Index (Market Filter)"
chop_len     = input.int(14,    "Choppiness Length",          minval=5,  group=grp_chop)
chop_thresh  = input.float(61.8,"Max Chop to Allow Signals",  minval=40, maxval=90, step=0.1, group=grp_chop,
     tooltip="Above 61.8 = choppy/ranging market. All signals suppressed. Lower = stricter trend filter.")
use_chop_filter = input.bool(true, "Enable Choppiness Filter", group=grp_chop)

// ── Signal Sensitivity ──
grp_sig      = "⚙️ Signal Sensitivity"
min_bull_score = input.int(7,  "Min Bullish Score (1-14)", minval=1, maxval=14, group=grp_sig,
     tooltip="7-9 recommended. Lower = more signals, more noise. Higher = fewer, higher conviction only.")
min_bear_score = input.int(7,  "Min Bearish Score (1-14)", minval=1, maxval=14, group=grp_sig,
     tooltip="7-9 recommended. Lower = more signals, more noise. Higher = fewer, higher conviction only.")
show_sl_tp   = input.bool(true, "Show Stop Loss / Take Profit Lines", group=grp_sig)
show_emas    = input.bool(true, "Show EMAs",                          group=grp_sig)
show_bb      = input.bool(true, "Show Bollinger Bands",               group=grp_sig)
show_labels  = input.bool(true, "Show Score Labels on Signals",       group=grp_sig)

// ─────────────────────────────────────────────
// SECTION 2 — CALCULATIONS: ORIGINAL 9
// ─────────────────────────────────────────────

// ── EMAs ──
ema_f = ta.ema(close, ema_fast)
ema_m = ta.ema(close, ema_mid)
ema_s = ta.ema(close, ema_slow)
ema_bull = ema_f > ema_m and ema_m > ema_s
ema_bear = ema_f < ema_m and ema_m < ema_s

// ── RSI ──
rsi          = ta.rsi(close, rsi_len)
rsi_bull     = rsi > 50 and rsi < rsi_ob
rsi_bear     = rsi < 50 and rsi > rsi_os
rsi_from_os  = ta.crossover(rsi,  rsi_os)
rsi_from_ob  = ta.crossunder(rsi, rsi_ob)

// ── MACD ──
[macd_line, signal_line, hist] = ta.macd(close, macd_fast, macd_slow, macd_signal)
macd_bull       = ta.crossover(macd_line, signal_line)  or (macd_line > signal_line and macd_line > 0)
macd_bear       = ta.crossunder(macd_line, signal_line) or (macd_line < signal_line and macd_line < 0)
macd_cross_bull = ta.crossover(macd_line,  signal_line)
macd_cross_bear = ta.crossunder(macd_line, signal_line)

// ── Stochastic RSI ──
rsi_raw         = ta.rsi(close, stoch_len)
stoch_raw       = ta.stoch(rsi_raw, rsi_raw, rsi_raw, stoch_len)
stoch_K         = ta.sma(stoch_raw, stoch_k)
stoch_D         = ta.sma(stoch_K, stoch_d)
stoch_bull      = ta.crossover(stoch_K, stoch_D)  and stoch_K < stoch_ob
stoch_bear      = ta.crossunder(stoch_K, stoch_D) and stoch_K > stoch_os
stoch_zone_bull = stoch_K < stoch_os
stoch_zone_bear = stoch_K > stoch_ob

// ── ADX / DMI ──
[dmi_plus, dmi_minus, adx_val] = ta.dmi(adx_len, adx_len)
adx_trending   = adx_val >= adx_thresh
adx_bull_trend = adx_trending and dmi_plus  > dmi_minus
adx_bear_trend = adx_trending and dmi_minus > dmi_plus

// ── CCI ──
cci_val  = ta.cci(close, cci_len)
cci_bull = ta.crossover(cci_val,  cci_os) or (cci_val > 0 and cci_val < cci_ob)
cci_bear = ta.crossunder(cci_val, cci_ob) or (cci_val < 0 and cci_val > cci_os)

// ── Bollinger Bands ──
[bb_mid, bb_upper, bb_lower] = ta.bb(close, bb_len, bb_mult)
bb_width     = bb_upper - bb_lower
bb_bull      = close > bb_mid and close <= bb_upper
bb_bear      = close < bb_mid and close >= bb_lower
bb_bounce_up = close <= bb_lower
bb_bounce_dn = close >= bb_upper

// ── Williams %R ──
wpr_val       = ta.wpr(wpr_len)
wpr_bull      = ta.crossover(wpr_val,  wpr_os)
wpr_bear      = ta.crossunder(wpr_val, wpr_ob)
wpr_zone_bull = wpr_val <= wpr_os
wpr_zone_bear = wpr_val >= wpr_ob

// ── ATR ──
atr_val = ta.atr(atr_len)

// ── Volume ──
vol_ma      = ta.sma(volume, vol_ma_len)
vol_surge   = volume > vol_ma * 1.5
vol_confirm = volume > vol_ma

// ─────────────────────────────────────────────
// SECTION 3 — CALCULATIONS: 5 NEW INDICATORS
// ─────────────────────────────────────────────

// ── 10. Supertrend ──
// Direction: -1 = uptrend (bullish), +1 = downtrend (bearish)
[st_line, st_dir_raw] = ta.supertrend(st_factor, st_atr_len)
st_bull      = st_dir_raw < 0        // uptrend
st_bear      = st_dir_raw > 0        // downtrend
st_flip_bull = st_bull and not st_bull[1]   // just turned bullish
st_flip_bear = st_bear and not st_bear[1]   // just turned bearish

// ── 11. Rolling VWAP (volume-weighted, works on all timeframes) ──
vwap_val     = math.sum(close * volume, vwap_len) / math.sum(volume, vwap_len)
vwap_bull    = close > vwap_val
vwap_bear    = close < vwap_val
vwap_cross_bull = ta.crossover(close,  vwap_val)
vwap_cross_bear = ta.crossunder(close, vwap_val)

// ── 12. Squeeze Momentum (TTM-style) ──
// Squeeze ON = BB inside KC (coiling, low volatility)
// Squeeze OFF = BB breaks outside KC (energy release = breakout)
sq_basis     = ta.sma(close, sq_len)
sq_dev       = sq_bb_mult * ta.stdev(close, sq_len)
sq_bb_upper  = sq_basis + sq_dev
sq_bb_lower  = sq_basis - sq_dev
sq_kc_atr    = ta.atr(sq_len)
sq_kc_upper  = sq_basis + sq_kc_mult * sq_kc_atr
sq_kc_lower  = sq_basis - sq_kc_mult * sq_kc_atr

sq_on        = sq_bb_upper < sq_kc_upper and sq_bb_lower > sq_kc_lower   // squeeze is active
sq_fired     = not sq_on and sq_on[1]                                     // squeeze just released

// Momentum oscillator: direction of energy in the squeeze
sq_hl_mid    = (ta.highest(high, sq_len) + ta.lowest(low, sq_len)) / 2
sq_delta     = close - (sq_hl_mid + sq_basis) / 2
sq_mom       = ta.linreg(sq_delta, sq_len, 0)

sq_bull      = sq_mom > 0 and (sq_mom > sq_mom[1] or sq_fired)    // positive & rising, or breakout up
sq_bear      = sq_mom < 0 and (sq_mom < sq_mom[1] or sq_fired)    // negative & falling, or breakout down

// ── 13. Parabolic SAR ──
psar_val     = ta.sar(psar_start, psar_inc, psar_max)
psar_bull    = close > psar_val      // price above SAR = bullish
psar_bear    = close < psar_val      // price below SAR = bearish
psar_flip_bull = psar_bull and not psar_bull[1]   // SAR just flipped bullish (strong exit signal for shorts)
psar_flip_bear = psar_bear and not psar_bear[1]   // SAR just flipped bearish (strong exit signal for longs)

// ── 14. Money Flow Index ──
mfi_val      = ta.mfi(hlc3, mfi_len)
mfi_bull     = mfi_val < mfi_os or ta.crossover(mfi_val, mfi_os)   // oversold or recovering
mfi_bear     = mfi_val > mfi_ob or ta.crossunder(mfi_val, mfi_ob)  // overbought or declining
mfi_from_os  = ta.crossover(mfi_val,  mfi_os)
mfi_from_ob  = ta.crossunder(mfi_val, mfi_ob)

// ── Choppiness Index (Gate Filter — not scored) ──
// Formula: 100 × log10(Σ ATR(1) / (Highest High − Lowest Low)) / log10(n)
// 38.2 = strong trend, 61.8 = choppy/ranging
chop_tr_sum  = math.sum(ta.tr(true), chop_len)
chop_hl      = ta.highest(high, chop_len) - ta.lowest(low, chop_len)
chop_val     = chop_hl > 0 ? 100 * math.log10(chop_tr_sum / chop_hl) / math.log10(chop_len) : 50
is_choppy    = use_chop_filter and chop_val > chop_thresh
is_trending  = not is_choppy

// ─────────────────────────────────────────────
// SECTION 4 — SCORING ENGINE (14 indicators)
// ─────────────────────────────────────────────

bull_score =
     (ema_bull       ? 1 : 0) +   //  1. EMA triple alignment
     (rsi_bull       ? 1 : 0) +   //  2. RSI bullish zone
     (macd_bull      ? 1 : 0) +   //  3. MACD bullish
     (stoch_bull     ? 1 : 0) +   //  4. Stoch RSI bullish cross
     (adx_bull_trend ? 1 : 0) +   //  5. ADX + DI+ > DI-
     (cci_bull       ? 1 : 0) +   //  6. CCI bullish
     (bb_bull        ? 1 : 0) +   //  7. Price above BB midline
     (wpr_bull       ? 1 : 0) +   //  8. Williams %R exiting OS
     (vol_confirm    ? 1 : 0) +   //  9. Volume above average
     (st_bull        ? 1 : 0) +   // 10. Supertrend bullish
     (vwap_bull      ? 1 : 0) +   // 11. Price above VWAP
     (sq_bull        ? 1 : 0) +   // 12. Squeeze momentum bullish
     (psar_bull      ? 1 : 0) +   // 13. Price above Parabolic SAR
     (mfi_bull       ? 1 : 0)     // 14. MFI in bullish zone

bear_score =
     (ema_bear       ? 1 : 0) +
     (rsi_bear       ? 1 : 0) +
     (macd_bear      ? 1 : 0) +
     (stoch_bear     ? 1 : 0) +
     (adx_bear_trend ? 1 : 0) +
     (cci_bear       ? 1 : 0) +
     (bb_bear        ? 1 : 0) +
     (wpr_bear       ? 1 : 0) +
     (vol_confirm    ? 1 : 0) +
     (st_bear        ? 1 : 0) +
     (vwap_bear      ? 1 : 0) +
     (sq_bear        ? 1 : 0) +
     (psar_bear      ? 1 : 0) +
     (mfi_bear       ? 1 : 0)

// ─────────────────────────────────────────────
// SECTION 5 — ENTRY SIGNALS
// ─────────────────────────────────────────────

// Choppiness gate: suppress all signals in ranging markets
buy_signal  = is_trending and bull_score >= min_bull_score and
              (macd_cross_bull or rsi_from_os or stoch_bull or wpr_bull or st_flip_bull or psar_flip_bull) and
              not (bear_score > bull_score)

sell_signal = is_trending and bear_score >= min_bear_score and
              (macd_cross_bear or rsi_from_ob or stoch_bear or wpr_bear or st_flip_bear or psar_flip_bear) and
              not (bull_score > bear_score)

// De-duplicate: only one signal per streak
var int last_signal = 0
buy_trigger  = buy_signal  and last_signal != 1
sell_trigger = sell_signal and last_signal != -1

if buy_trigger
    last_signal := 1
if sell_trigger
    last_signal := -1

// ─────────────────────────────────────────────
// SECTION 6 — EXIT SIGNALS (strict multi-confirm)
// ─────────────────────────────────────────────

// Bar counter since last entry
var int bars_since_entry = 0
if buy_trigger or sell_trigger
    bars_since_entry := 0
else
    bars_since_entry := bars_since_entry + 1

min_exit_bars = 3

// ── Exit Long conditions ──
exl_rsi     = rsi_from_ob                         // RSI drops from overbought
exl_macd    = macd_cross_bear                      // MACD bearish cross
exl_stoch   = stoch_zone_bear and stoch_bear       // Stoch OB + cross down
exl_bb      = bb_bounce_dn and bear_score >= 6     // BB upper + strong bear score
exl_cci     = ta.crossunder(cci_val, cci_ob)       // CCI drops out of OB
exl_wpr     = ta.crossunder(wpr_val, wpr_ob)       // WPR drops from OB
exl_st      = st_flip_bear                         // Supertrend flipped bearish ★ strong
exl_psar    = psar_flip_bear                       // Parabolic SAR flipped bearish ★ strong
exl_mfi     = mfi_from_ob                          // MFI drops from overbought
exl_vwap    = vwap_cross_bear                      // Price crossed below VWAP

// Any single "strong" exit or two regular exits required
exit_long_strong = exl_st or exl_psar              // high-conviction single exits
exit_long_count  =
     (exl_rsi  ? 1 : 0) + (exl_macd  ? 1 : 0) +
     (exl_stoch? 1 : 0) + (exl_bb    ? 1 : 0) +
     (exl_cci  ? 1 : 0) + (exl_wpr   ? 1 : 0) +
     (exl_mfi  ? 1 : 0) + (exl_vwap  ? 1 : 0)

// ── Exit Short conditions ──
exs_rsi     = rsi_from_os
exs_macd    = macd_cross_bull
exs_stoch   = stoch_zone_bull and stoch_bull
exs_bb      = bb_bounce_up and bull_score >= 6
exs_cci     = ta.crossover(cci_val, cci_os)
exs_wpr     = ta.crossover(wpr_val, wpr_os)
exs_st      = st_flip_bull
exs_psar    = psar_flip_bull
exs_mfi     = mfi_from_os
exs_vwap    = vwap_cross_bull

exit_short_strong = exs_st or exs_psar
exit_short_count  =
     (exs_rsi  ? 1 : 0) + (exs_macd  ? 1 : 0) +
     (exs_stoch? 1 : 0) + (exs_bb    ? 1 : 0) +
     (exs_cci  ? 1 : 0) + (exs_wpr   ? 1 : 0) +
     (exs_mfi  ? 1 : 0) + (exs_vwap  ? 1 : 0)

// ── Gate exits: strong single OR 2+ regular, with bar delay ──
exit_long_raw  = last_signal == 1  and bars_since_entry >= min_exit_bars and
                 (exit_long_strong or exit_long_count >= 2)

exit_short_raw = last_signal == -1 and bars_since_entry >= min_exit_bars and
                 (exit_short_strong or exit_short_count >= 2)

// De-duplicate exits: one per trade
var bool exit_long_fired  = false
var bool exit_short_fired = false

if buy_trigger
    exit_long_fired  := false
if sell_trigger
    exit_short_fired := false

exit_long  = exit_long_raw  and not exit_long_fired
exit_short = exit_short_raw and not exit_short_fired

if exit_long
    exit_long_fired  := true
if exit_short
    exit_short_fired := true

// ─────────────────────────────────────────────
// SECTION 7 — STOP LOSS & TAKE PROFIT
// ─────────────────────────────────────────────

var float sl_long  = na
var float tp_long  = na
var float sl_short = na
var float tp_short = na

if buy_trigger
    sl_long  := close - atr_val * atr_mult_sl
    tp_long  := close + atr_val * atr_mult_tp
    sl_short := na
    tp_short := na

if sell_trigger
    sl_short := close + atr_val * atr_mult_sl
    tp_short := close - atr_val * atr_mult_tp
    sl_long  := na
    tp_long  := na

if exit_long or exit_short
    sl_long  := na
    tp_long  := na
    sl_short := na
    tp_short := na

// ─────────────────────────────────────────────
// SECTION 8 — PLOTS
// ─────────────────────────────────────────────

// ── EMAs ──
plot(show_emas ? ema_f : na, "EMA Fast", color=color.new(color.yellow, 0),  linewidth=1)
plot(show_emas ? ema_m : na, "EMA Mid",  color=color.new(color.orange, 0),  linewidth=1)
plot(show_emas ? ema_s : na, "EMA Slow", color=color.new(color.red,    30), linewidth=2)

// ── Bollinger Bands ──
bb_upper_p = plot(show_bb ? bb_upper : na, "BB Upper", color=color.new(color.blue, 70), linewidth=1)
bb_lower_p = plot(show_bb ? bb_lower : na, "BB Lower", color=color.new(color.blue, 70), linewidth=1)
bb_mid_p   = plot(show_bb ? bb_mid   : na, "BB Mid",   color=color.new(color.blue, 50), linewidth=1, style=plot.style_circles)
fill(bb_upper_p, bb_lower_p, color=color.new(color.blue, 92))

// ── Supertrend ──
st_color = st_bull ? color.new(color.green, 40) : color.new(color.red, 40)
plot(show_st ? st_line : na, "Supertrend", color=st_color, linewidth=2, style=plot.style_linebr)

// ── Rolling VWAP ──
plot(show_vwap ? vwap_val : na, "Rolling VWAP", color=color.new(color.purple, 0), linewidth=1, style=plot.style_cross)

// ── Parabolic SAR ──
plotshape(show_psar ? psar_val : na, "PSAR", style=shape.circle, location=location.absolute,
     color=psar_bull ? color.new(color.teal, 30) : color.new(color.maroon, 30), size=size.tiny)

// ── SL / TP ──
plot(show_sl_tp ? sl_long  : na, "Long SL",  color=color.new(color.red,   0), linewidth=1, style=plot.style_linebr)
plot(show_sl_tp ? tp_long  : na, "Long TP",  color=color.new(color.green, 0), linewidth=1, style=plot.style_linebr)
plot(show_sl_tp ? sl_short : na, "Short SL", color=color.new(color.red,   0), linewidth=1, style=plot.style_linebr)
plot(show_sl_tp ? tp_short : na, "Short TP", color=color.new(color.lime,  0), linewidth=1, style=plot.style_linebr)

// ─────────────────────────────────────────────
// SECTION 9 — SIGNAL SHAPES & LABELS
// ─────────────────────────────────────────────

// ── BUY ──
plotshape(buy_trigger,
     title="BUY Signal", style=shape.labelup, location=location.belowbar,
     color=color.new(color.green, 0), textcolor=color.white,
     text="BUY", size=size.small)

// ── SELL ──
plotshape(sell_trigger,
     title="SELL Signal", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 0), textcolor=color.white,
     text="SELL", size=size.small)

// ── Exit Long ──
plotshape(exit_long and not sell_trigger,
     title="Exit Long", style=shape.xcross, location=location.abovebar,
     color=color.new(color.orange, 0), size=size.small)

// ── Exit Short ──
plotshape(exit_short and not buy_trigger,
     title="Exit Short", style=shape.xcross, location=location.belowbar,
     color=color.new(color.aqua, 0), size=size.small)

// ── Score Label on BUY ──
if show_labels and buy_trigger
    label.new(bar_index, low - atr_val * 0.5,
         text="Score: " + str.tostring(bull_score) + "/14" +
              "\nChop: "  + str.tostring(math.round(chop_val, 1)) +
              "\nSL: "    + str.tostring(math.round(close - atr_val * atr_mult_sl, 2)) +
              "\nTP: "    + str.tostring(math.round(close + atr_val * atr_mult_tp, 2)),
         color=color.new(color.green, 10), textcolor=color.white,
         style=label.style_label_up, size=size.small)

// ── Score Label on SELL ──
if show_labels and sell_trigger
    label.new(bar_index, high + atr_val * 0.5,
         text="Score: " + str.tostring(bear_score) + "/14" +
              "\nChop: "  + str.tostring(math.round(chop_val, 1)) +
              "\nSL: "    + str.tostring(math.round(close + atr_val * atr_mult_sl, 2)) +
              "\nTP: "    + str.tostring(math.round(close - atr_val * atr_mult_tp, 2)),
         color=color.new(color.red, 10), textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ── Choppy Market Warning Label ──
if is_choppy and buy_trigger[1] == false and sell_trigger[1] == false and barstate.islast
    label.new(bar_index, high,
         text="⚠ CHOP " + str.tostring(math.round(chop_val, 1)),
         color=color.new(color.orange, 20), textcolor=color.white,
         style=label.style_label_down, size=size.tiny)

// ─────────────────────────────────────────────
// SECTION 10 — BACKGROUND BIAS COLORING
// ─────────────────────────────────────────────

barcolor(is_choppy                                                     ? color.new(color.gray,   92) : na)
barcolor(not is_choppy and bull_score >= min_bull_score and not sell_signal ? color.new(color.green, 88) : na)
barcolor(not is_choppy and bear_score >= min_bear_score and not buy_signal  ? color.new(color.red,   88) : na)

// ─────────────────────────────────────────────
// SECTION 11 — ALERT CONDITIONS
// ─────────────────────────────────────────────

alertcondition(buy_trigger,
     title="🟢 SWING BUY — STMv2",
     message="STMv2: BUY confirmed on {{ticker}} ({{interval}}) | Close: {{close}} | Check Choppiness Index on chart")

alertcondition(sell_trigger,
     title="🔴 SWING SELL — STMv2",
     message="STMv2: SELL confirmed on {{ticker}} ({{interval}}) | Close: {{close}} | Check Choppiness Index on chart")

alertcondition(exit_long,
     title="⚠️ EXIT Long — STMv2",
     message="STMv2: EXIT LONG on {{ticker}} ({{interval}}) — consider closing buy position | Check Supertrend and PSAR on chart")

alertcondition(exit_short,
     title="⚠️ EXIT Short — STMv2",
     message="STMv2: EXIT SHORT on {{ticker}} ({{interval}}) — consider closing sell position | Check Supertrend and PSAR on chart")

alertcondition(sq_fired and sq_bull,
     title="🌀 Squeeze Breakout UP",
     message="STMv2: Squeeze Momentum BULLISH breakout on {{ticker}}")

alertcondition(sq_fired and sq_bear,
     title="🌀 Squeeze Breakout DOWN",
     message="STMv2: Squeeze Momentum BEARISH breakout on {{ticker}}")

// ─────────────────────────────────────────────
// SECTION 12 — HUD TABLE (Top Right)
// ─────────────────────────────────────────────

var table hud = table.new(position.top_right, 2, 19,
     bgcolor=color.new(color.black, 70),
     border_color=color.new(color.gray, 50), border_width=1,
     frame_color=color.new(color.gray, 50), frame_width=1)

if barstate.islast
    // ── Header ──
    table.cell(hud, 0, 0, "INDICATOR",   text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 0, "STATUS",      text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small)

    // ── 1. EMA ──
    table.cell(hud, 0, 1, "EMA Trend",    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, ema_bull ? "▲ BULL" : ema_bear ? "▼ BEAR" : "─ MIXED",
         text_color=ema_bull ? color.green : ema_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 2. RSI ──
    table.cell(hud, 0, 2, "RSI",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 2, str.tostring(math.round(rsi, 1)),
         text_color=rsi_bull ? color.green : rsi_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 3. MACD ──
    table.cell(hud, 0, 3, "MACD",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 3, macd_cross_bull ? "▲ CROSS" : macd_cross_bear ? "▼ CROSS" : macd_bull ? "▲ BULL" : "▼ BEAR",
         text_color=macd_bull ? color.green : color.red, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 4. Stochastic RSI ──
    table.cell(hud, 0, 4, "Stoch RSI",    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, str.tostring(math.round(stoch_K, 1)),
         text_color=stoch_zone_bull ? color.green : stoch_zone_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 5. ADX ──
    table.cell(hud, 0, 5, "ADX / DMI",    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 5, str.tostring(math.round(adx_val, 1)) + (adx_bull_trend ? " ▲" : adx_bear_trend ? " ▼" : " ─"),
         text_color=adx_bull_trend ? color.green : adx_bear_trend ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 6. CCI ──
    table.cell(hud, 0, 6, "CCI",          text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 6, str.tostring(math.round(cci_val, 1)),
         text_color=cci_bull ? color.green : cci_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 7. Bollinger Bands ──
    table.cell(hud, 0, 7, "Boll. Bands",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 7, bb_bounce_up ? "▲ AT LOW" : bb_bounce_dn ? "▼ AT HIGH" : bb_bull ? "ABOVE MID" : "BELOW MID",
         text_color=bb_bull or bb_bounce_up ? color.green : color.red, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 8. Williams %R ──
    table.cell(hud, 0, 8, "Williams %R",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 8, str.tostring(math.round(wpr_val, 1)),
         text_color=wpr_zone_bull ? color.green : wpr_zone_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 9. Volume ──
    table.cell(hud, 0, 9, "Volume",       text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 9, vol_surge ? "SURGE ▲" : vol_confirm ? "ABOVE AVG" : "BELOW AVG",
         text_color=vol_surge ? color.lime : vol_confirm ? color.green : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 10. Supertrend ──
    table.cell(hud, 0, 10, "Supertrend",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 10, st_bull ? "▲ BULL" : "▼ BEAR",
         text_color=st_bull ? color.green : color.red, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 11. VWAP ──
    table.cell(hud, 0, 11, "VWAP",        text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 11, vwap_bull ? "▲ ABOVE" : "▼ BELOW",
         text_color=vwap_bull ? color.green : color.red, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 12. Squeeze Momentum ──
    table.cell(hud, 0, 12, "Squeeze Mom", text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 12, sq_on ? "COILING ●" : sq_bull ? "▲ BULLISH" : sq_bear ? "▼ BEARISH" : "─ NEUTRAL",
         text_color=sq_on ? color.yellow : sq_bull ? color.green : sq_bear ? color.red : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 13. Parabolic SAR ──
    table.cell(hud, 0, 13, "Parab. SAR",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 13, psar_bull ? "▲ BULL" : "▼ BEAR",
         text_color=psar_bull ? color.green : color.red, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── 14. MFI ──
    table.cell(hud, 0, 14, "MFI",         text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 14, str.tostring(math.round(mfi_val, 1)),
         text_color=mfi_val < mfi_os ? color.lime : mfi_val > mfi_ob ? color.red : mfi_bull ? color.green : color.gray, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── Choppiness Filter ──
    table.cell(hud, 0, 15, "Choppiness",  text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 15,
         str.tostring(math.round(chop_val, 1)) + (is_choppy ? " CHOP" : " TREND"),
         text_color=is_choppy ? color.orange : color.teal, text_size=size.small, bgcolor=color.new(color.black, 80))

    // ── Separator ──
    table.cell(hud, 0, 16, "──────────",  text_color=color.new(color.gray, 40), text_size=size.small)
    table.cell(hud, 1, 16, "──────────",  text_color=color.new(color.gray, 40), text_size=size.small)

    // ── Bull Score ──
    table.cell(hud, 0, 17, "BULL SCORE",  text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color.green, 50))
    table.cell(hud, 1, 17, str.tostring(bull_score) + " / 14",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.green, 50))

    // ── Bear Score ──
    table.cell(hud, 0, 18, "BEAR SCORE",  text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color.red, 50))
    table.cell(hud, 1, 18, str.tostring(bear_score) + " / 14",
         text_color=color.white, text_size=size.small, bgcolor=color.new(color.red, 50))
````
