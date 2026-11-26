# BB Squeeze Breakout

- url: https://www.tradingview.com/script/4fyLTL2I-BB-Squeeze-Breakout/
- type: indicator
- pine_id: PUB;01cdc2fb3806460ea04dda0cfff34358
- version: 1.0

## Description

BB Squeeze Breakout

Precision Breakout is a volatility compression and breakout indicator based on Bollinger Bands, Keltner Channels, momentum filters, volume confirmation, and ATR-based risk levels.

The goal of this tool is to help traders read when price is compressing, when volatility starts expanding again, and whether a breakout has enough confirmation to be considered stronger or weaker.

This indicator is not a trading system by itself. It is made to support chart reading and should be used together with market structure, support and resistance, liquidity zones, session context, and personal risk management.

────────────────────────────
MAIN IDEA
────────────────────────────

Markets often move through two phases:

1. Compression
Price contracts, Bollinger Bands become tighter, and the market prepares for a possible expansion.

2. Expansion
Price breaks outside the bands, volatility increases, and a directional move can start.

This script tracks those phases with:
- Bollinger Bands
- Keltner Channels
- Squeeze detection
- Bollinger Bandwidth
- %B position
- Candle quality
- RSI momentum
- Volume expansion
- OBV confirmation
- MFI confirmation
- A/D confirmation
- ADX trend strength
- MACD confirmation
- EMA trend filter
- ATR-based SL and TP levels
- A dashboard for quick reading

────────────────────────────
HOW THE SIGNALS WORK
────────────────────────────

A bullish breakout appears when price closes above the upper Bollinger Band for the required number of confirmation bars.

A bearish breakout appears when price closes below the lower Bollinger Band for the required number of confirmation bars.

The script then checks additional conditions such as candle body quality, momentum, volume, OBV slope, MACD behavior, ATR expansion, Bollinger Bandwidth expansion, and post-squeeze context.

The final signal depends on the confluence score and the selected filters.

A strong signal means that the breakout structure is present and the required confirmations are aligned.

A weak signal means that price broke outside the Bollinger Band, but the score or one of the active filters was not strong enough.

────────────────────────────
MINI TUTORIAL FOR BEGINNERS
────────────────────────────

1. Add the indicator to the chart.
2. Start with the default settings.
3. Look for a squeeze phase, where Bollinger Bands compress inside the Keltner Channel.
4. Wait for a squeeze release or a confirmed breakout outside the Bollinger Bands.
5. Check the dashboard:
   - Squeeze: shows if compression is active.
   - Post-SQ: shows if the market recently left a squeeze.
   - BandWidth: shows if volatility is low or expanding.
   - %B: shows where price is inside or outside the bands.
   - SNIPER: shows the current confluence score.
   - Signal: shows BUY, SELL, WEAK BUY, WEAK SELL, or WAIT.
6. If a signal appears, check if it agrees with the trend, support/resistance, and market structure.
7. Use the ATR-based Entry, SL, TP1, TP2, and TP3 levels as visual planning references.
8. Do not take a signal blindly. Always check the context before making a decision.

────────────────────────────
EXAMPLE CASES
────────────────────────────

Example 1: Bullish post-squeeze breakout
Price has been moving sideways, the Bollinger Bands are tight, and the squeeze is active. Then price closes above the upper Bollinger Band with a strong candle, rising volume, improving RSI, and expanding bandwidth. The dashboard shows a bullish score above the minimum threshold. A BUY label can appear, and the ATR risk levels show Entry, SL, TP1, TP2, and TP3.

Example 2: Bearish breakdown
Price loses support and closes below the lower Bollinger Band. RSI moves below 50, OBV weakens, MACD confirms downside pressure, and the candle closes near the low of its range. If the score and active filters agree, a SELL label can appear.

Example 3: Weak breakout
Price closes outside the Bollinger Band, but the candle is small, volume is not expanding, or momentum is weak. In this case, the script can show a WEAK signal instead of a confirmed one. This means the structure exists, but confirmation is not strong enough.

Example 4: Head fake
Price briefly breaks outside a band, then moves back inside the Bollinger structure. The script can mark this as a possible head fake. This helps identify failed breakouts, especially in choppy or low-volume markets.

Example 5: Band walk
During strong trends, price can continue moving along the upper or lower Bollinger Band. The script marks these band walk conditions to show possible trend continuation behavior.

────────────────────────────
INPUTS EXPLAINED
────────────────────────────

BOLLINGER BANDS

BB Length
Controls the moving average period used for the Bollinger Band basis. The default value is 20, which is the classic Bollinger setting.

BB StdDev
Controls the standard deviation multiplier used to build the upper and lower bands. The default value is 2.0, which is the common standard setting.

Neon Glow
Adds a visual glow effect around the Bollinger Bands.

Heat Zone
Colors the area between the Bollinger Bands depending on price position inside the band range.

────────────────────────────
KELTNER / SQUEEZE

Keltner Length
Controls the length used for the Keltner Channel calculation.

Keltner Mult
Controls the ATR multiplier used to build the Keltner Channel.

Show Keltner
Shows or hides the Keltner Channel on the chart.

Post-Squeeze Window
Defines how many bars after a squeeze release are still considered part of the post-squeeze phase.

Squeeze Ready Lookback
Looks back over a selected number of bars to detect when Bollinger Bandwidth is near a low-compression zone.

Show Squeeze Dots
Shows dots during squeeze conditions and squeeze release events.

────────────────────────────
BREAKOUT SIGNALS

Confirmation Bars
Defines how many consecutive closes outside the Bollinger Band are required before confirming a breakout.

Show BUY/SELL Labels
Shows or hides the main BUY and SELL labels.

Show Arrows
Shows or hides the arrow markers on the chart.

Show Tiny Info Labels
Shows or hides smaller labels such as weak signals and head fake warnings.

Head Fake Lookback
Controls how many bars are checked to detect a failed breakout after price moved outside a band.

Band Walk Bars
Controls how many bars are required to detect a band walk condition.

────────────────────────────
SNIPER ENGINE

Min Confluence Score
Sets the minimum score required for a confirmed signal. A higher value gives fewer signals but requires stronger confirmation.

Min Body/Range Ratio
Defines how large the candle body must be compared to the full candle range. This helps filter weak candles and dojis.

Close Must Be In Top/Bot %
For bullish candles, the close should be near the top of the range. For bearish candles, the close should be near the bottom of the range.

ATR Expansion Factor
Checks if current ATR is expanding compared to its average. This helps confirm volatility expansion.

Require Momentum Acceleration
Uses momentum behavior, mainly RSI acceleration, as part of the confirmation logic.

Require Volume Expansion
Uses volume expansion as part of the breakout quality reading.

Require BB Width Expansion
Checks if Bollinger Bandwidth is expanding during the breakout.

Anti-Wick Rejection Filter
Helps reject breakouts when the previous candle shows a strong wick against the breakout direction.

────────────────────────────
FILTERS

Use RSI Filter
Activates or disables RSI confirmation.

RSI Length
Controls the RSI calculation period.

Use OBV Filter
Activates or disables OBV confirmation.

Use Volume Spike Filter
Activates or disables volume spike confirmation.

Volume MA Length
Controls the moving average length used to compare current volume.

Volume Min x MA
Defines how much current volume must exceed the volume average.

Use MFI Filter
Activates or disables Money Flow Index confirmation.

MFI Length
Controls the MFI calculation period.

Use A/D Filter
Activates or disables Accumulation/Distribution confirmation.

Use ADX Filter
Activates or disables ADX trend strength confirmation.

ADX Length
Controls the ADX calculation period.

ADX Min
Defines the minimum ADX value required when the ADX filter is active.

Use MACD Filter
Activates or disables MACD confirmation.

Use EMA Trend Filter
Activates or disables EMA trend confirmation.

EMA Fast
Controls the fast EMA length.

EMA Slow
Controls the slow EMA length.

────────────────────────────
RISK MANAGEMENT

Show SL / TP
Shows or hides Entry, Stop Loss, and Take Profit levels.

Show SL/TP Zones
Shows or hides the colored risk and target zones.

Show SL/TP Labels
Shows or hides the Entry, SL, TP1, TP2, and TP3 labels.

SL ATR x
Controls the ATR multiplier used to calculate the Stop Loss distance.

TP1 ATR x
Controls the ATR multiplier used to calculate the first Take Profit level.

TP2 ATR x
Controls the ATR multiplier used to calculate the second Take Profit level.

TP3 ATR x
Controls the ATR multiplier used to calculate the third Take Profit level.

Enable TP3
Shows or hides the third Take Profit level.

RM Label Offset Bars
Moves the risk management labels slightly to the right of the current price area. The labels and zones update automatically as new candles appear.

────────────────────────────
DASHBOARD

Show Dashboard
Shows or hides the dashboard panel.

Position
Moves the dashboard to the selected chart corner.

High Contrast Panel
Makes the dashboard easier to read with stronger background contrast.

────────────────────────────
VISUAL ELEMENTS
────────────────────────────

The indicator can display:
- Bollinger Bands
- Bollinger glow effect
- Heat zone between bands
- Keltner Channels
- Squeeze dots
- Squeeze release dots
- BUY and SELL labels
- Weak breakout labels
- Head fake labels
- Band walk markers
- ATR-based Entry, SL, TP1, TP2, TP3 levels
- Colored risk and target zones
- A dashboard with market state information

────────────────────────────
IMPORTANT NOTES
────────────────────────────

This script is an indicator, not a strategy.
It does not place trades.
It does not guarantee profitable results.
It does not predict the future.
Signals can fail in ranging, low-liquidity, high-spread, or news-driven market conditions.
Users should test the indicator on their own symbols, timeframes, and trading style before using it in live market decisions.
Risk management remains the responsibility of the user.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                 ⚡ WIZARD BB // MATRIX BREAKOUT ENGINE ⚡                  ║
// ║──────────────────────────────────────────────────────────────────────────────║
// ║  Volatility Compression • Bollinger Expansion • Squeeze Detection           ║
// ║  Breakout Confirmation • Confluence Score • ATR Risk Management             ║
// ║──────────────────────────────────────────────────────────────────────────────║
// ║  Built for structured chart reading: squeeze, release, breakout, weakness,  ║
// ║  head fake detection, band walk behavior, and visual SL / TP planning.      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator("BB Squeeze Breakout", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grp_bb = "━━━━━ BOLLINGER BANDS ━━━━━"
bb_len      = input.int(20, "BB Length", minval=5, group=grp_bb)
bb_mult     = input.float(2.0, "BB StdDev", minval=0.5, step=0.1, group=grp_bb)
show3D      = input.bool(true, "Neon Glow", group=grp_bb)
showHeat    = input.bool(true, "Heat Zone", group=grp_bb)

grp_kc = "━━━━━ KELTNER / SQUEEZE ━━━━━"
kc_len      = input.int(20, "Keltner Length", minval=5, group=grp_kc)
kc_mult     = input.float(1.5, "Keltner Mult", minval=0.5, step=0.1, group=grp_kc)
showKC      = input.bool(true, "Show Keltner", group=grp_kc)
sq_hold_max = input.int(10, "Post-Squeeze Window", minval=1, maxval=30, group=grp_kc)
sq_ready_lb = input.int(100, "Squeeze Ready Lookback", minval=20, maxval=300, group=grp_kc)
showSqDot   = input.bool(true, "Show Squeeze Dots", group=grp_kc)

grp_sig = "━━━━━ BREAKOUT SIGNALS ━━━━━"
head_fake_bars = input.int(2, "Confirmation Bars", minval=1, maxval=4, group=grp_sig)
showLabels     = input.bool(true, "Show BUY/SELL Labels", group=grp_sig)
showArrows     = input.bool(true, "Show Arrows", group=grp_sig)
showTinyInfo   = input.bool(false, "Show Tiny Info Labels", group=grp_sig)
headfakeLookbk = input.int(3, "Head Fake Lookback", minval=1, maxval=6, group=grp_sig)
bandwalkBars   = input.int(3, "Band Walk Bars", minval=2, maxval=6, group=grp_sig)

grp_sniper = "━━━━━ SNIPER ENGINE ━━━━━"
i_min_score    = input.int(60, "Min Confluence Score", minval=30, maxval=90, step=5, group=grp_sniper, tooltip="Minimum score out of 100 to fire a signal. Higher = fewer but more precise signals.")
i_candle_body  = input.float(0.45, "Min Body/Range Ratio", minval=0.2, maxval=0.8, step=0.05, group=grp_sniper, tooltip="Breakout candle body must be this % of its range. Filters dojis/wicks.")
i_close_zone   = input.float(0.30, "Close Must Be In Top/Bot %", minval=0.10, maxval=0.50, step=0.05, group=grp_sniper, tooltip="For bull: close in top 30% of range. For bear: bottom 30%.")
i_atr_expand   = input.float(1.1, "ATR Expansion Factor", minval=0.8, maxval=2.0, step=0.1, group=grp_sniper, tooltip="Current ATR must exceed ATR MA by this factor for volatility confirmation.")
i_mom_accel    = input.bool(true, "Require Momentum Acceleration", group=grp_sniper, tooltip="RSI must be accelerating in breakout direction.")
i_vol_expand   = input.bool(true, "Require Volume Expansion", group=grp_sniper, tooltip="Volume on breakout bars must be progressively higher.")
i_bw_expand    = input.bool(true, "Require BB Width Expansion", group=grp_sniper, tooltip="Bollinger bandwidth must be expanding (not contracting) on breakout.")
i_anti_wick    = input.bool(true, "Anti-Wick Rejection Filter", group=grp_sniper, tooltip="Reject signals where prior bar showed strong wick rejection in opposite direction.")

grp_filters = "━━━━━ FILTERS (SEPARATE) ━━━━━"
use_rsi_filter   = input.bool(true,  "Use RSI Filter", group=grp_filters)
rsi_len          = input.int(14, "RSI Length", minval=2, group=grp_filters)
use_obv_filter   = input.bool(true,  "Use OBV Filter", group=grp_filters)
use_vol_filter   = input.bool(true,  "Use Volume Spike Filter", group=grp_filters)
vol_len          = input.int(20, "Volume MA Length", minval=5, group=grp_filters)
vol_mult         = input.float(1.1, "Volume Min x MA", minval=0.8, step=0.1, group=grp_filters)
use_mfi_filter   = input.bool(false, "Use MFI Filter", group=grp_filters)
mfi_len          = input.int(14, "MFI Length", minval=2, group=grp_filters)
use_ad_filter    = input.bool(false, "Use A/D Filter", group=grp_filters)
use_adx_filter   = input.bool(false, "Use ADX Filter", group=grp_filters)
adx_len          = input.int(14, "ADX Length", minval=5, group=grp_filters)
adx_min          = input.float(18.0, "ADX Min", minval=5, step=0.5, group=grp_filters)
use_macd_filter  = input.bool(false, "Use MACD Filter", group=grp_filters)
use_ema_filter   = input.bool(false, "Use EMA Trend Filter", group=grp_filters)
ema_fast_len     = input.int(21, "EMA Fast", minval=2, group=grp_filters)
ema_slow_len     = input.int(55, "EMA Slow", minval=3, group=grp_filters)

grp_risk = "━━━━━ RISK MANAGEMENT ━━━━━"
showRisk     = input.bool(true,  "Show SL / TP", group=grp_risk)
showRiskBox  = input.bool(true,  "Show SL/TP Zones", group=grp_risk)
showRiskLbl  = input.bool(true,  "Show SL/TP Labels", group=grp_risk)
rm_lbl_offset = input.int(2, "RM Label Offset Bars", minval=1, maxval=50, group=grp_risk)
sl_mult      = input.float(1.5, "SL ATR x", minval=0.3, step=0.1, group=grp_risk)
tp1_mult     = input.float(2.0, "TP1 ATR x", minval=0.5, step=0.1, group=grp_risk)
tp2_mult     = input.float(3.5, "TP2 ATR x", minval=0.5, step=0.1, group=grp_risk)
tp3_mult     = input.float(5.5, "TP3 ATR x", minval=0.5, step=0.1, group=grp_risk)
showTP3      = input.bool(true, "Enable TP3", group=grp_risk)

grp_dash = "━━━━━ DASHBOARD ━━━━━"
showDash      = input.bool(true, "Show Dashboard", group=grp_dash)
dashPos       = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_dash)
panelStrong   = input.bool(true, "High Contrast Panel", group=grp_dash)

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════
f_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_state_txt(bool bull, bool bear) =>
    bull ? "BULL" : bear ? "BEAR" : "NEUTRAL"

f_state_col(bool bull, bool bear) =>
    bull ? color.new(#00E676, 0) : bear ? color.new(#FF1744, 0) : color.new(#B0BEC5, 0)

f_onoff(bool b) => b ? "ON" : "OFF"
f_yesno(bool b) => b ? "YES" : "NO"
f_yesno_col(bool b) => b ? color.new(#00E676, 0) : color.new(#FF1744, 0)
f_fmt(float v) => str.tostring(v, "#.##")
f_fmt_int(float v) => str.tostring(math.round(v))

f_sum_series(float src, int len) =>
    float acc = 0.0
    for i = 0 to len - 1
        acc += nz(src[i])
    acc

f_mfi(int len) =>
    float tp = (high + low + close) / 3.0
    float rmf = tp * volume
    float pos = tp > tp[1] ? rmf : 0.0
    float neg = tp < tp[1] ? rmf : 0.0
    float posSum = f_sum_series(pos, len)
    float negSum = f_sum_series(neg, len)
    float mr = negSum == 0 ? 999.0 : posSum / negSum
    100.0 - (100.0 / (1.0 + mr))

f_ad() =>
    float mfm = high != low ? ((close - low) - (high - close)) / (high - low) : 0.0
    ta.cum(mfm * volume)

// ══════════════════════════════════════════════════════════════════════════════
// BASE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════
atr    = ta.atr(14)
atr_ma = ta.sma(atr, 14)
rsi    = ta.rsi(close, rsi_len)
vol_ma = ta.sma(volume, vol_len)

bb_mid   = ta.sma(close, bb_len)
bb_dev   = ta.stdev(close, bb_len)
bb_upper = bb_mid + bb_dev * bb_mult
bb_lower = bb_mid - bb_dev * bb_mult
bb_bw    = bb_mid != 0 ? (bb_upper - bb_lower) / bb_mid : 0.0
bb_pct   = (close - bb_lower) / math.max(bb_upper - bb_lower, syminfo.mintick)

kc_mid   = ta.ema(close, kc_len)
kc_range = ta.atr(kc_len) * kc_mult
kc_upper = kc_mid + kc_range
kc_lower = kc_mid - kc_range

squeeze_on  = bb_upper < kc_upper and bb_lower > kc_lower
squeeze_off = not squeeze_on
sq_fired    = squeeze_on[1] and squeeze_off

var int bars_in_sq = 0
bars_in_sq := squeeze_on ? bars_in_sq + 1 : 0
sq_strength = bars_in_sq[1]

var int bars_since_sq = 0
bars_since_sq := sq_fired ? 1 : (bars_since_sq > 0 and bars_since_sq < sq_hold_max ? bars_since_sq + 1 : 0)
post_squeeze = bars_since_sq > 0

lowest_bw = ta.lowest(bb_bw, sq_ready_lb)
squeeze_ready = squeeze_on and bb_bw <= lowest_bw * 1.05

break_up   = close > bb_upper
break_down = close < bb_lower

var int streak_up = 0
var int streak_down = 0
streak_up   := break_up ? streak_up + 1 : 0
streak_down := break_down ? streak_down + 1 : 0

confirmed_bull_raw = streak_up == head_fake_bars
confirmed_bear_raw = streak_down == head_fake_bars

bandwalk_bull = ta.barssince(not break_up) >= bandwalkBars - 1 and break_up
bandwalk_bear = ta.barssince(not break_down) >= bandwalkBars - 1 and break_down

bull_headfake = ta.highest(break_up ? 1.0 : 0.0, headfakeLookbk) > 0 and close < bb_upper and close > bb_mid and not confirmed_bull_raw
bear_headfake = ta.highest(break_down ? 1.0 : 0.0, headfakeLookbk) > 0 and close > bb_lower and close < bb_mid and not confirmed_bear_raw

// ══════════════════════════════════════════════════════════════════════════════
// CONFIRMATION INDICATORS
// ══════════════════════════════════════════════════════════════════════════════
obv    = ta.cum(math.sign(ta.change(close)) * volume)
obv_ma = ta.sma(obv, 20)
obv_bull = obv > obv_ma
obv_bear = obv < obv_ma

mfi = f_mfi(mfi_len)
mfi_bull = mfi > 50
mfi_bear = mfi < 50

ad_line = f_ad()
ad_ma   = ta.sma(ad_line, 20)
ad_bull = ad_line > ad_ma
ad_bear = ad_line < ad_ma

[diPlus, diMinus, adx] = ta.dmi(adx_len, adx_len)
adx_bull = adx > adx_min and diPlus > diMinus
adx_bear = adx > adx_min and diMinus > diPlus

[macd_line, macd_signal, macd_hist] = ta.macd(close, 12, 26, 9)
macd_bull = macd_line > macd_signal and macd_hist >= 0
macd_bear = macd_line < macd_signal and macd_hist <= 0

ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
ema_bull = ema_fast > ema_slow and close > ema_fast
ema_bear = ema_fast < ema_slow and close < ema_fast

// ══════════════════════════════════════════════════════════════════════════════
// ★★★ SNIPER ENGINE ★★★
// ══════════════════════════════════════════════════════════════════════════════

// ——— 1. CANDLE QUALITY ANALYSIS ———
float candle_range = high - low
float candle_body  = math.abs(close - open)
float body_ratio   = candle_range > 0 ? candle_body / candle_range : 0.0
// For bull: close should be in top zone of range
float close_position = candle_range > 0 ? (close - low) / candle_range : 0.5
// For bear: close should be in bottom zone
bool bull_candle_quality = body_ratio >= i_candle_body and close_position >= (1.0 - i_close_zone) and close > open
bool bear_candle_quality = body_ratio >= i_candle_body and close_position <= i_close_zone and close < open
// Check across confirmation window — all bars should have decent quality
bool bull_candle_ok = bull_candle_quality
bool bear_candle_ok = bear_candle_quality
if head_fake_bars >= 2
    bull_candle_ok := bull_candle_quality and (close[1] > open[1])  // prior bar also green
    bear_candle_ok := bear_candle_quality and (close[1] < open[1])  // prior bar also red

// ——— 2. MOMENTUM ACCELERATION ———
bool rsi_accel_bull = rsi > rsi[1] and rsi[1] > rsi[2]              // RSI accelerating up
bool rsi_accel_bear = rsi < rsi[1] and rsi[1] < rsi[2]              // RSI accelerating down
bool macd_accel_bull = macd_hist > macd_hist[1] and macd_hist[1] > macd_hist[2]  // MACD hist growing
bool macd_accel_bear = macd_hist < macd_hist[1] and macd_hist[1] < macd_hist[2]

// ——— 3. VOLUME EXPANSION ———
bool vol_expanding_bull = volume > volume[1] and volume[1] > volume[2] * 0.9
bool vol_expanding_bear = volume > volume[1] and volume[1] > volume[2] * 0.9
bool vol_spike = volume > vol_ma * vol_mult

// ——— 4. BANDWIDTH EXPANSION ———
bool bw_expanding = bb_bw > bb_bw[1] and bb_bw[1] >= bb_bw[2] * 0.98

// ——— 5. ATR EXPANSION (volatility confirmation) ———
bool atr_expanding = atr > atr_ma * i_atr_expand

// ——— 6. ANTI-WICK REJECTION ———
// Reject if prior bar had a strong wick AGAINST the breakout direction
float prior_upper_wick = high[1] - math.max(open[1], close[1])
float prior_lower_wick = math.min(open[1], close[1]) - low[1]
float prior_range      = high[1] - low[1]
bool bull_wick_reject  = i_anti_wick and prior_range > 0 and (prior_upper_wick / prior_range) > 0.55
bool bear_wick_reject  = i_anti_wick and prior_range > 0 and (prior_lower_wick / prior_range) > 0.55

// ——— 7. OBV SLOPE (not just above/below MA — rate of change) ———
float obv_slope = obv - obv[3]
bool obv_slope_bull = obv_slope > 0
bool obv_slope_bear = obv_slope < 0

// ——— 8. TREND ALIGNMENT (price above/below BB mid as trend proxy) ———
bool mid_trend_bull = close > bb_mid and close[1] > bb_mid[1]
bool mid_trend_bear = close < bb_mid and close[1] < bb_mid[1]

// ══════════════════════════════════════════════════════════════════════════════
// ★★★ CONFLUENCE SCORING BULL ★★★
// ══════════════════════════════════════════════════════════════════════════════
float score_bull = 0.0

// Core: BB breakout confirmed (mandatory — 0 points but acts as gate)
// scored implicitly by confirmed_bull_raw

// Candle quality (0-15 pts)
score_bull += bull_candle_quality ? 15.0 : (close > open ? 5.0 : 0.0)

// RSI position & acceleration (0-15 pts)
score_bull += rsi > 55 ? 8.0 : rsi > 50 ? 5.0 : 0.0
score_bull += rsi_accel_bull ? 7.0 : (rsi > rsi[1] ? 3.0 : 0.0)

// Volume (0-15 pts)
score_bull += vol_spike ? 8.0 : (volume > vol_ma * 0.9 ? 3.0 : 0.0)
score_bull += vol_expanding_bull ? 7.0 : 0.0

// OBV slope (0-10 pts)
score_bull += obv_slope_bull ? 10.0 : (obv_bull ? 4.0 : 0.0)

// MACD acceleration (0-10 pts)
score_bull += macd_accel_bull ? 10.0 : (macd_bull ? 5.0 : 0.0)

// Bandwidth expansion (0-8 pts)
score_bull += bw_expanding ? 8.0 : 0.0

// ATR expansion (0-7 pts)
score_bull += atr_expanding ? 7.0 : 0.0

// Mid trend alignment (0-5 pts)
score_bull += mid_trend_bull ? 5.0 : 0.0

// Post-squeeze bonus (0-10 pts)
score_bull += post_squeeze ? 10.0 : 0.0

// Squeeze strength bonus (0-5 pts)
score_bull += sq_strength > 8 ? 5.0 : sq_strength > 4 ? 3.0 : 0.0

// Penalties
score_bull -= bull_wick_reject ? 15.0 : 0.0
score_bull -= bull_headfake ? 10.0 : 0.0

// Clamp
score_bull := math.max(0, math.min(score_bull, 100))

// ══════════════════════════════════════════════════════════════════════════════
// ★★★ CONFLUENCE SCORING BEAR ★★★
// ══════════════════════════════════════════════════════════════════════════════
float score_bear = 0.0

score_bear += bear_candle_quality ? 15.0 : (close < open ? 5.0 : 0.0)
score_bear += rsi < 45 ? 8.0 : rsi < 50 ? 5.0 : 0.0
score_bear += rsi_accel_bear ? 7.0 : (rsi < rsi[1] ? 3.0 : 0.0)
score_bear += vol_spike ? 8.0 : (volume > vol_ma * 0.9 ? 3.0 : 0.0)
score_bear += vol_expanding_bear ? 7.0 : 0.0
score_bear += obv_slope_bear ? 10.0 : (obv_bear ? 4.0 : 0.0)
score_bear += macd_accel_bear ? 10.0 : (macd_bear ? 5.0 : 0.0)
score_bear += bw_expanding ? 8.0 : 0.0
score_bear += atr_expanding ? 7.0 : 0.0
score_bear += mid_trend_bear ? 5.0 : 0.0
score_bear += post_squeeze ? 10.0 : 0.0
score_bear += sq_strength > 8 ? 5.0 : sq_strength > 4 ? 3.0 : 0.0
score_bear -= bear_wick_reject ? 15.0 : 0.0
score_bear -= bear_headfake ? 10.0 : 0.0
score_bear := math.max(0, math.min(score_bear, 100))

// ══════════════════════════════════════════════════════════════════════════════
// ★★★ LEGACY FILTER PASS ★★★
// ══════════════════════════════════════════════════════════════════════════════
vol_ok        = not use_vol_filter or volume > vol_ma * vol_mult
rsi_ok_bull   = not use_rsi_filter or rsi > 50
rsi_ok_bear   = not use_rsi_filter or rsi < 50
obv_ok_bull   = not use_obv_filter or obv_bull
obv_ok_bear   = not use_obv_filter or obv_bear
mfi_ok_bull   = not use_mfi_filter or mfi_bull
mfi_ok_bear   = not use_mfi_filter or mfi_bear
ad_ok_bull    = not use_ad_filter or ad_bull
ad_ok_bear    = not use_ad_filter or ad_bear
adx_ok_bull   = not use_adx_filter or adx_bull
adx_ok_bear   = not use_adx_filter or adx_bear
macd_ok_bull  = not use_macd_filter or macd_bull
macd_ok_bear  = not use_macd_filter or macd_bear
ema_ok_bull   = not use_ema_filter or ema_bull
ema_ok_bear   = not use_ema_filter or ema_bear

all_filters_bull = vol_ok and rsi_ok_bull and obv_ok_bull and mfi_ok_bull and ad_ok_bull and adx_ok_bull and macd_ok_bull and ema_ok_bull
all_filters_bear = vol_ok and rsi_ok_bear and obv_ok_bear and mfi_ok_bear and ad_ok_bear and adx_ok_bear and macd_ok_bear and ema_ok_bear

// ══════════════════════════════════════════════════════════════════════════════
// ★★★ FINAL SIGNAL LOGIC ★★★
// ══════════════════════════════════════════════════════════════════════════════

// CLOSE ONLY — confirmed bars only
confirmed_bull = confirmed_bull_raw and barstate.isconfirmed
confirmed_bear = confirmed_bear_raw and barstate.isconfirmed

// SNIPER signals: structural breakout + score meets threshold + legacy filters pass
buySignal  = confirmed_bull and score_bull >= i_min_score and all_filters_bull
sellSignal = confirmed_bear and score_bear >= i_min_score and all_filters_bear

buy_sq  = buySignal and post_squeeze
sell_sq = sellSignal and post_squeeze

raw_bull_breakout = confirmed_bull
raw_bear_breakout = confirmed_bear

// WEAK: structural breakout confirmed but either score too low OR filters failed
weak_bull_breakout = confirmed_bull and not buySignal
weak_bear_breakout = confirmed_bear and not sellSignal

// ══════════════════════════════════════════════════════════════════════════════
// RISK MANAGEMENT
// ══════════════════════════════════════════════════════════════════════════════
var float entryPrice  = na
var float stopLoss    = na
var float tp1         = na
var float tp2         = na
var float tp3         = na

if buySignal
    entryPrice := close
    stopLoss   := math.min(bb_lower, close - atr * sl_mult)
    tp1        := close + atr * tp1_mult
    tp2        := close + atr * tp2_mult
    tp3        := close + atr * tp3_mult

if sellSignal
    entryPrice := close
    stopLoss   := math.max(bb_upper, close + atr * sl_mult)
    tp1        := close - atr * tp1_mult
    tp2        := close - atr * tp2_mult
    tp3        := close - atr * tp3_mult

// ══════════════════════════════════════════════════════════════════════════════
// VISUALS
// ══════════════════════════════════════════════════════════════════════════════
band_col = squeeze_on ? color.new(#FFD600, 15) : color.new(#00E5FF, 15)

p_upper = plot(bb_upper, "BB Upper", color=band_col, linewidth=2)
p_lower = plot(bb_lower, "BB Lower", color=band_col, linewidth=2)
p_mid   = plot(bb_mid, "BB Mid", color=color.new(#7C5CFC, 45), linewidth=1, style=plot.style_circles)

plot(show3D ? bb_upper : na, "Glow Upper 1", color=color.new(squeeze_on ? #FFD600 : #00E5FF, 65), linewidth=4)
plot(show3D ? bb_upper : na, "Glow Upper 2", color=color.new(squeeze_on ? #FFD600 : #00E5FF, 82), linewidth=8)
plot(show3D ? bb_lower : na, "Glow Lower 1", color=color.new(squeeze_on ? #FFD600 : #00E5FF, 65), linewidth=4)
plot(show3D ? bb_lower : na, "Glow Lower 2", color=color.new(squeeze_on ? #FFD600 : #00E5FF, 82), linewidth=8)

heatCol = bb_pct > 0.90 ? color.new(#FF1744, 82) :
          bb_pct > 0.75 ? color.new(#FF6D00, 86) :
          bb_pct > 0.58 ? color.new(#FFD600, 91) :
          bb_pct < 0.10 ? color.new(#00E5FF, 82) :
          bb_pct < 0.25 ? color.new(#00B0FF, 86) :
          bb_pct < 0.42 ? color.new(#00E676, 91) :
          color.new(#37474F, 95)

fill(p_upper, p_lower, color=showHeat ? heatCol : na)

plot(showKC ? kc_upper : na, "KC Upper", color=color.new(#CE93D8, 55), linewidth=1, style=plot.style_stepline)
plot(showKC ? kc_lower : na, "KC Lower", color=color.new(#CE93D8, 55), linewidth=1, style=plot.style_stepline)

sqDotVal = showSqDot and squeeze_on ? bb_mid : na
plot(sqDotVal, "Squeeze Dot", style=plot.style_circles, color=color.new(#FF6D00, 0), linewidth=2)
sqRelVal = showSqDot and sq_fired ? bb_mid : na
plot(sqRelVal, "Squeeze Release Dot", style=plot.style_circles, color=color.new(#00E676, 0), linewidth=2)

// ══════════════════════════════════════════════════════════════════════════════
// LABELS / ARROWS
// ══════════════════════════════════════════════════════════════════════════════
if buySignal and showLabels
    string scrTxt = str.tostring(math.round(score_bull))
    string lblBuy = buy_sq ? "BUY\nPOST-SQ\n" + scrTxt : "BUY\n" + scrTxt
    label.new(bar_index, low - atr * 0.9, lblBuy, style=label.style_label_up, color=buy_sq ? color.new(#00E676, 0) : color.new(#00E676, 15), textcolor=color.white, size=size.tiny)

if sellSignal and showLabels
    string scrTxt = str.tostring(math.round(score_bear))
    string lblSell = sell_sq ? "SELL\nPOST-SQ\n" + scrTxt : "SELL\n" + scrTxt
    label.new(bar_index, high + atr * 0.9, lblSell, style=label.style_label_down, color=sell_sq ? color.new(#FF1744, 0) : color.new(#FF1744, 15), textcolor=color.white, size=size.tiny)

if weak_bull_breakout and showTinyInfo
    string wTxt = "WEAK " + str.tostring(math.round(score_bull))
    label.new(bar_index, low - atr * 0.45, wTxt, style=label.style_label_up, color=color.new(#FFD600, 10), textcolor=color.white, size=size.tiny)

if weak_bear_breakout and showTinyInfo
    string wTxt = "WEAK " + str.tostring(math.round(score_bear))
    label.new(bar_index, high + atr * 0.45, wTxt, style=label.style_label_down, color=color.new(#FF9100, 10), textcolor=color.white, size=size.tiny)

if bull_headfake and showTinyInfo and barstate.isconfirmed
    label.new(bar_index, high + atr * 0.55, "HEAD FAKE", style=label.style_label_down, color=color.new(#FF6D00, 10), textcolor=color.white, size=size.tiny)

if bear_headfake and showTinyInfo and barstate.isconfirmed
    label.new(bar_index, low - atr * 0.55, "HEAD FAKE", style=label.style_label_up, color=color.new(#00B0FF, 10), textcolor=color.white, size=size.tiny)

plotshape(showArrows and buySignal, "Arrow Buy", shape.triangleup, location.belowbar, color=color.new(#00E676, 0), size=size.tiny)
plotshape(showArrows and sellSignal, "Arrow Sell", shape.triangledown, location.abovebar, color=color.new(#FF1744, 0), size=size.tiny)
plotshape(showArrows and bandwalk_bull and barstate.isconfirmed, "Band Walk Bull", shape.circle, location.abovebar, color=color.new(#76FF03, 0), size=size.tiny)
plotshape(showArrows and bandwalk_bear and barstate.isconfirmed, "Band Walk Bear", shape.circle, location.belowbar, color=color.new(#FF9100, 0), size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// PERSISTENT RISK VISUALS
// ══════════════════════════════════════════════════════════════════════════════
var line  rm_entry   = na
var line  rm_sl      = na
var line  rm_tp1     = na
var line  rm_tp2     = na
var line  rm_tp3     = na
var label rm_lentry  = na
var label rm_lsl     = na
var label rm_ltp1    = na
var label rm_ltp2    = na
var label rm_ltp3    = na
var box   rm_box_sl  = na
var box   rm_box_tp1 = na
var box   rm_box_tp2 = na
var box   rm_box_tp3 = na

if (buySignal or sellSignal) and showRisk
    if not na(rm_entry)
        line.delete(rm_entry)
    if not na(rm_sl)
        line.delete(rm_sl)
    if not na(rm_tp1)
        line.delete(rm_tp1)
    if not na(rm_tp2)
        line.delete(rm_tp2)
    if not na(rm_tp3)
        line.delete(rm_tp3)
    if not na(rm_lentry)
        label.delete(rm_lentry)
    if not na(rm_lsl)
        label.delete(rm_lsl)
    if not na(rm_ltp1)
        label.delete(rm_ltp1)
    if not na(rm_ltp2)
        label.delete(rm_ltp2)
    if not na(rm_ltp3)
        label.delete(rm_ltp3)
    if not na(rm_box_sl)
        box.delete(rm_box_sl)
    if not na(rm_box_tp1)
        box.delete(rm_box_tp1)
    if not na(rm_box_tp2)
        box.delete(rm_box_tp2)
    if not na(rm_box_tp3)
        box.delete(rm_box_tp3)

    int rmLblX = bar_index + rm_lbl_offset

    rm_entry := line.new(bar_index, entryPrice, rmLblX, entryPrice, xloc=xloc.bar_index, color=color.new(#FFFFFF, 20), style=line.style_solid, width=1, extend=extend.none)
    rm_sl    := line.new(bar_index, stopLoss, rmLblX, stopLoss, xloc=xloc.bar_index, color=color.new(#FF1744, 10), style=line.style_dashed, width=2, extend=extend.none)
    rm_tp1   := line.new(bar_index, tp1, rmLblX, tp1, xloc=xloc.bar_index, color=color.new(#00E676, 10), style=line.style_dashed, width=1, extend=extend.none)
    rm_tp2   := line.new(bar_index, tp2, rmLblX, tp2, xloc=xloc.bar_index, color=color.new(#76FF03, 10), style=line.style_dotted, width=1, extend=extend.none)

    if showTP3
        rm_tp3 := line.new(bar_index, tp3, rmLblX, tp3, xloc=xloc.bar_index, color=color.new(#FFD600, 10), style=line.style_dotted, width=1, extend=extend.none)

    if showRiskLbl
        rm_lentry := label.new(rmLblX, entryPrice, "ENTRY " + str.tostring(entryPrice, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#FFFFFF, 30), textcolor=color.white, size=size.tiny)
        rm_lsl    := label.new(rmLblX, stopLoss, "SL " + str.tostring(stopLoss, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#FF1744, 20), textcolor=color.white, size=size.tiny)
        rm_ltp1   := label.new(rmLblX, tp1, "TP1 " + str.tostring(tp1, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#00E676, 20), textcolor=color.white, size=size.tiny)
        rm_ltp2   := label.new(rmLblX, tp2, "TP2 " + str.tostring(tp2, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#76FF03, 20), textcolor=color.white, size=size.tiny)
        if showTP3
            rm_ltp3 := label.new(rmLblX, tp3, "TP3 " + str.tostring(tp3, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(#FFD600, 20), textcolor=color.white, size=size.tiny)

    if showRiskBox
        rm_box_sl  := box.new(bar_index, math.max(entryPrice, stopLoss), rmLblX, math.min(entryPrice, stopLoss), xloc=xloc.bar_index, border_color=color.new(#FF1744, 70), bgcolor=color.new(#FF1744, 93))
        rm_box_tp1 := box.new(bar_index, math.max(entryPrice, tp1), rmLblX, math.min(entryPrice, tp1), xloc=xloc.bar_index, border_color=color.new(#00E676, 75), bgcolor=color.new(#00E676, 93))
        rm_box_tp2 := box.new(bar_index, math.max(tp1, tp2), rmLblX, math.min(tp1, tp2), xloc=xloc.bar_index, border_color=color.new(#76FF03, 78), bgcolor=color.new(#00E676, 94))
        if showTP3
            rm_box_tp3 := box.new(bar_index, math.max(tp2, tp3), rmLblX, math.min(tp2, tp3), xloc=xloc.bar_index, border_color=color.new(#FFD600, 78), bgcolor=color.new(#00E676, 95))

if showRisk
    int rmLiveX = bar_index + rm_lbl_offset
    if not na(rm_entry)
        line.set_x2(rm_entry, rmLiveX)
    if not na(rm_sl)
        line.set_x2(rm_sl, rmLiveX)
    if not na(rm_tp1)
        line.set_x2(rm_tp1, rmLiveX)
    if not na(rm_tp2)
        line.set_x2(rm_tp2, rmLiveX)
    if showTP3 and not na(rm_tp3)
        line.set_x2(rm_tp3, rmLiveX)
    if showRiskLbl
        if not na(rm_lentry)
            label.set_x(rm_lentry, rmLiveX)
        if not na(rm_lsl)
            label.set_x(rm_lsl, rmLiveX)
        if not na(rm_ltp1)
            label.set_x(rm_ltp1, rmLiveX)
        if not na(rm_ltp2)
            label.set_x(rm_ltp2, rmLiveX)
        if showTP3 and not na(rm_ltp3)
            label.set_x(rm_ltp3, rmLiveX)
    if showRiskBox
        if not na(rm_box_sl)
            box.set_right(rm_box_sl, rmLiveX)
        if not na(rm_box_tp1)
            box.set_right(rm_box_tp1, rmLiveX)
        if not na(rm_box_tp2)
            box.set_right(rm_box_tp2, rmLiveX)
        if showTP3 and not na(rm_box_tp3)
            box.set_right(rm_box_tp3, rmLiveX)

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
var table dash = na
if showDash and na(dash)
    dash := table.new(f_pos(dashPos), 2, 25, bgcolor=color.new(#050A14, 5), border_width=1, border_color=color.new(#00E5FF, 45), frame_width=2, frame_color=color.new(#00E5FF, 20))

if showDash and barstate.islast
    color bgHdr = panelStrong ? color.new(#001A2E, 0) : color.new(#001A2E, 20)
    color bgRow = panelStrong ? color.new(#0A1220, 0) : color.new(#050A14, 10)
    color dim   = color.new(#9FA8DA, 0)
    color acc   = color.new(#00E5FF, 0)

    float disp_score = score_bull >= score_bear ? score_bull : score_bear
    string disp_dir  = score_bull >= score_bear ? "BULL" : "BEAR"
    color  disp_col  = disp_score >= i_min_score ? (score_bull >= score_bear ? color.new(#00E676, 0) : color.new(#FF1744, 0)) : color.new(#78909C, 0)

    table.cell(dash, 0, 0, "BB SQUEEZE SNIPER", text_color=acc, text_size=size.tiny, bgcolor=bgHdr, text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " " + timeframe.period, text_color=color.new(#E1F5FE, 0), text_size=size.tiny, bgcolor=bgHdr, text_halign=text.align_center)

    table.cell(dash, 0, 1, "Squeeze", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 1, squeeze_on ? "ON " + str.tostring(bars_in_sq) + " bars" : "OFF", text_color=squeeze_on ? color.new(#FF6D00, 0) : color.new(#00E676, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 2, "Sq Ready", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 2, f_yesno(squeeze_ready), text_color=f_yesno_col(squeeze_ready), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 3, "Post-SQ", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 3, post_squeeze ? "YES " + str.tostring(bars_since_sq) : "NO", text_color=post_squeeze ? color.new(#FFD600, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 4, "BandWidth", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 4, f_fmt(bb_bw * 100) + "%", text_color=squeeze_on ? color.new(#FF6D00, 0) : color.new(#B0BEC5, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 5, "%B", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 5, f_fmt(bb_pct * 100) + "%", text_color=bb_pct > 1 ? color.new(#FF1744, 0) : bb_pct < 0 ? color.new(#00E5FF, 0) : color.new(#B0BEC5, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 6, "Breakout", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 6, break_up ? "UP " + str.tostring(streak_up) : break_down ? "DOWN " + str.tostring(streak_down) : "INSIDE", text_color=break_up ? color.new(#00E676, 0) : break_down ? color.new(#FF1744, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    // ★ Sniper Score row
    table.cell(dash, 0, 7, "SNIPER", text_color=color.new(#FFD600, 0), text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 7, disp_dir + " " + f_fmt_int(disp_score) + "/100 (min:" + str.tostring(i_min_score) + ")", text_color=disp_col, text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 8, "Signal", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 8, buySignal ? (buy_sq ? "BUY POST-SQ" : "BUY") : sellSignal ? (sell_sq ? "SELL POST-SQ" : "SELL") : weak_bull_breakout ? "WEAK BUY" : weak_bear_breakout ? "WEAK SELL" : "WAIT", text_color=buySignal ? color.new(#00E676, 0) : sellSignal ? color.new(#FF1744, 0) : weak_bull_breakout or weak_bear_breakout ? color.new(#FFD600, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 9, "RSI", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 9, f_fmt_int(rsi) + (rsi_accel_bull ? " ↑↑" : rsi_accel_bear ? " ↓↓" : ""), text_color=f_state_col(rsi > 50, rsi < 50), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 10, "OBV", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 10, f_state_txt(obv_bull, obv_bear) + (obv_slope_bull ? " ↑" : obv_slope_bear ? " ↓" : ""), text_color=f_state_col(obv_bull, obv_bear), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 11, "Volume", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 11, f_fmt(volume / math.max(vol_ma, 1)) + "x" + (vol_expanding_bull ? " EXP" : ""), text_color=volume > vol_ma * vol_mult ? color.new(#FFD600, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 12, "MFI", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 12, f_fmt_int(mfi), text_color=f_state_col(mfi > 50, mfi < 50), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 13, "A/D", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 13, f_state_txt(ad_bull, ad_bear), text_color=f_state_col(ad_bull, ad_bear), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 14, "ADX", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 14, f_fmt(adx) + " | " + f_state_txt(adx_bull, adx_bear), text_color=adx_bull ? color.new(#00E676, 0) : adx_bear ? color.new(#FF1744, 0) : color.new(#B0BEC5, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 15, "MACD", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 15, f_state_txt(macd_bull, macd_bear) + (macd_accel_bull ? " ↑↑" : macd_accel_bear ? " ↓↓" : ""), text_color=f_state_col(macd_bull, macd_bear), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 16, "EMA Trend", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 16, f_state_txt(ema_bull, ema_bear), text_color=f_state_col(ema_bull, ema_bear), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 17, "Candle Q", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 17, "Body:" + f_fmt(body_ratio*100) + "% Pos:" + f_fmt(close_position*100) + "%", text_color=bull_candle_quality or bear_candle_quality ? color.new(#00E676, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 18, "ATR Exp", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 18, f_yesno(atr_expanding) + " " + f_fmt(atr/math.max(atr_ma,syminfo.mintick)) + "x", text_color=f_yesno_col(atr_expanding), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 19, "BW Expand", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 19, f_yesno(bw_expanding), text_color=f_yesno_col(bw_expanding), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 20, "Head Fake", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 20, bull_headfake ? "BULL FAIL" : bear_headfake ? "BEAR FAIL" : "NO", text_color=bull_headfake or bear_headfake ? color.new(#FF9100, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 21, "Band Walk", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 21, bandwalk_bull ? "BULL" : bandwalk_bear ? "BEAR" : "NO", text_color=bandwalk_bull ? color.new(#00E676, 0) : bandwalk_bear ? color.new(#FF1744, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 22, "Filters", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 22, buySignal or sellSignal ? "PASS" : weak_bull_breakout or weak_bear_breakout ? "FAIL" : "WAIT", text_color=buySignal or sellSignal ? color.new(#00E676, 0) : weak_bull_breakout or weak_bear_breakout ? color.new(#FF1744, 0) : color.new(#78909C, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 23, "F: RSI/OBV", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 23, f_onoff(use_rsi_filter) + " / " + f_onoff(use_obv_filter), text_color=color.new(#FFD600, 0), text_size=size.tiny, bgcolor=bgRow)

    table.cell(dash, 0, 24, "F: VOL/MACD", text_color=dim, text_size=size.tiny, bgcolor=bgRow)
    table.cell(dash, 1, 24, f_onoff(use_vol_filter) + " / " + f_onoff(use_macd_filter), text_color=color.new(#FFD600, 0), text_size=size.tiny, bgcolor=bgRow)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(raw_bull_breakout, "Bull Breakout Raw", "Raw bullish breakout confirmed outside Bollinger Band")
alertcondition(raw_bear_breakout, "Bear Breakout Raw", "Raw bearish breakout confirmed outside Bollinger Band")

alertcondition(buySignal, "Bull Breakout Confirmed", "SNIPER bull breakout: score >= threshold + all filters pass")
alertcondition(sellSignal, "Bear Breakout Confirmed", "SNIPER bear breakout: score >= threshold + all filters pass")

alertcondition(buy_sq, "Bull Post-Squeeze Confirmed", "SNIPER bull breakout after squeeze release")
alertcondition(sell_sq, "Bear Post-Squeeze Confirmed", "SNIPER bear breakout after squeeze release")

alertcondition(weak_bull_breakout, "Weak Bull Breakout", "Bull breakout confirmed but score below threshold or filters failed")
alertcondition(weak_bear_breakout, "Weak Bear Breakout", "Bear breakout confirmed but score below threshold or filters failed")

alertcondition(squeeze_on and not squeeze_on[1] and barstate.isconfirmed, "Squeeze Start", "Squeeze started")
alertcondition(sq_fired and barstate.isconfirmed, "Squeeze Released", "Squeeze released")
alertcondition(squeeze_ready and barstate.isconfirmed, "Squeeze Ready", "Bandwidth compressed — squeeze ready")

alertcondition(bull_headfake and barstate.isconfirmed, "Bull Head Fake", "Upper BB breakout failed — head fake")
alertcondition(bear_headfake and barstate.isconfirmed, "Bear Head Fake", "Lower BB breakout failed — head fake")

alertcondition(bandwalk_bull and barstate.isconfirmed, "Bull Band Walk", "Price walking upper band")
alertcondition(bandwalk_bear and barstate.isconfirmed, "Bear Band Walk", "Price walking lower band")

alertcondition((buySignal or sellSignal), "Any Confirmed Signal", "Any SNIPER confirmed signal")
alertcondition((weak_bull_breakout or weak_bear_breakout), "Any Weak Signal", "Any weak BB breakout signal")
alertcondition((bull_headfake or bear_headfake) and barstate.isconfirmed, "Any Head Fake", "Any BB head fake detected")

// Hidden data plots
plot(bb_bw, "BandWidth", display=display.none)
plot(rsi, "RSI", display=display.none)
plot(obv, "OBV", display=display.none)
plot(mfi, "MFI", display=display.none)
plot(ad_line, "A/D", display=display.none)
plot(adx, "ADX", display=display.none)
plot(macd_hist, "MACD Hist", display=display.none)
plot(score_bull, "Score Bull", display=display.none)
plot(score_bear, "Score Bear", display=display.none)
````
