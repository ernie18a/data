<!-- tradingview-pine-id: PUB;52c3e8a98e9742ee8668b42e4c534473 -->
<!-- tradingviewscripts-format: 1 -->
# Reversal Engine M15 - Practical Early/Confirmed + Dual Exit

Source: https://www.tradingview.com/script/1USY49LM-reversal-engine-m15-practical-early-confirmed-dual-exit/

## Description

# Reversal Engine M15 – Practical Early/Confirmed + Dual Exit

## Overview

**Reversal Engine M15 – Practical Early/Confirmed + Dual Exit** is a non-repainting reversal indicator designed to detect high-probability bullish reversal zones while filtering out a large portion of market noise.

The indicator combines trend analysis, momentum oscillators, volatility measurements, candlestick confirmation, and optional volume confirmation to generate practical trading signals that can be used for discretionary trading or as a component of a systematic trading strategy.

Unlike many reversal indicators that rely solely on oscillators, Reversal Engine evaluates several independent market conditions before generating a signal.

---

# Main Features

### Early Reversal Detection

The indicator identifies potential reversals before full confirmation.

Early signals are intended to provide the earliest possible warning that bearish momentum may be weakening.

These signals use:

* Price reaction
* Momentum improvement
* RSI
* Stochastic
* ATR-based oversold condition

---

### Confirmed Reversal Signals

Confirmed signals require additional confirmation including:

* Pivot structure
* Bullish price confirmation
* Lower wick analysis
* Momentum confirmation
* Optional volume confirmation

These signals are designed to reduce false positives while remaining responsive.

---

### Crash Reversal Engine

The indicator includes a dedicated Crash Reversal module that detects unusually strong downward moves followed by recovery conditions.

The module evaluates:

* Percentage decline
* Recovery strength
* RSI
* Stochastic
* Lower wick quality

Crash Reversal signals are intentionally treated separately from normal reversal signals because market behavior after sharp declines often differs from ordinary pullbacks.

---

### Dual Exit Engine

The Exit Engine helps identify areas where bullish momentum may be becoming exhausted.

Two independent exit models are included:

**Exit 1**

Designed for normal overextended conditions.

**Exit 2**

Designed for stronger overbought situations requiring stricter confirmation.

Both exit models combine:

* ATR extension
* RSI
* Stochastic
* Bearish confirmation candle
* Upper wick analysis (Exit 2)

---

# Trend Context

The indicator can optionally filter signals using the long-term trend.

This helps traders focus on higher-probability reversal opportunities while reducing trades against the dominant market direction.

---

# Momentum Filters

Signals are confirmed using:

* RSI
* Stochastic crossover
* Price confirmation
* Candle structure

The combination helps reduce weak reversal setups.

---

# Volatility Filters

ATR is used to evaluate whether price has moved sufficiently away from its average value before a reversal signal is considered.

This prevents many low-quality signals occurring during low-volatility market conditions.

---

# Optional Volume Confirmation

Users may enable volume confirmation to require current volume to exceed its moving average before allowing a signal.

This provides an additional quality filter when volume data is available.

---

# Adjustable Parameters

The indicator provides extensive customization including:

* EMA visibility
* Trend filtering
* Countertrend mode
* Pivot sensitivity
* Reversal lookback windows
* ATR thresholds
* RSI thresholds
* Stochastic thresholds
* Wick ratio
* Volume confirmation
* Crash Reversal parameters
* Exit Engine parameters
* Signal cooldown periods

---

# Visual Signals

The indicator displays:

● Early Reversal

▲ Confirmed Reversal

◆ Crash Reversal

▼ Exit Signal 1

▼ Exit Signal 2

Background highlighting may also be enabled for reversal, crash, and exit zones.

---

# Designed For

The indicator was originally developed for intraday trading and performs best on lower timeframes such as:

* M15
* M30
* H1

It can also be adapted to other liquid markets after parameter optimization.

---

# Important Notes

This indicator does not predict market tops or bottoms with certainty.

Instead, it identifies areas where multiple technical factors align and where the probability of a bullish reversal is increased.

Like all technical indicators, it should be used together with proper risk management and position sizing.

---

## Version Highlights

* Early and Confirmed Reversal Detection
* Crash Reversal Module
* Dual Exit Engine
* ATR-Based Volatility Filter
* RSI & Stochastic Confirmation
* Trend Context Filter
* Optional Volume Confirmation
* Non-Repainting Signal Logic
* Highly Configurable Inputs
* Suitable for discretionary and systematic trading

---

## Source Code

````pine
//@version=6
indicator("Reversal Engine M15 - Practical Early/Confirmed + Dual Exit", overlay=true)

// ================= BASE INDICATORS =================
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
atr = ta.atr(14)
rsi = ta.rsi(close, 14)
stoch_k = ta.stoch(close, high, low, 14)
stoch_d = ta.sma(stoch_k, 3)

// ================= INPUTS =================
show_ema20 = input.bool(true, "Show EMA20")
show_ema50 = input.bool(true, "Show EMA50")
show_ema200 = input.bool(false, "Show EMA200")

use_trend_context = input.bool(true, "Use Trend Context")
allow_countertrend = input.bool(true, "Allow Countertrend Reversals")

pivot_left = input.int(2, "Pivot Left", minval=1)
pivot_right = input.int(2, "Pivot Right", minval=1)
pivot_window = input.int(8, "Pivot Window", minval=1)

bottom_lookback = input.int(8, "Bottom Lookback", minval=2)
bottom_now_lookback = input.int(3, "Bottom Now Lookback", minval=2)

cooldown_up = input.int(8, "Confirmed UP Cooldown", minval=1)
cooldown_up_early = input.int(6, "Early UP Cooldown", minval=1)

overextended_atr = input.float(0.3, "Normal Overextended ATR", minval=0.1, step=0.1)
rsi_max = input.int(45, "Normal RSI Max", minval=1, maxval=100)
stoch_max = input.int(45, "Normal Stoch Max", minval=1, maxval=100)
wick_ratio_min = input.float(0.25, "Lower Wick Ratio Min", minval=0.05, maxval=0.95, step=0.05)

use_volume_confirm = input.bool(false, "Use Volume Confirmation")
show_bg_zone = input.bool(false, "Highlight Normal Reversal Zone")

// ================= CRASH REVERSAL INPUTS =================
enable_crash_reversal = input.bool(true, "Enable Crash Reversal")
drop_lookback = input.int(8, "Crash Drop Lookback", minval=2)
drop_pct_threshold = input.float(2.0, "Crash Drop % Threshold", minval=0.5, step=0.1)
crash_wick_ratio_min = input.float(0.25, "Crash Wick Ratio Min", minval=0.05, maxval=0.95, step=0.05)
crash_cooldown = input.int(12, "Confirmed Crash Cooldown", minval=1)
crash_early_cooldown = input.int(8, "Early Crash Cooldown", minval=1)
show_crash_bg = input.bool(false, "Highlight Crash Zone")

// ================= EXIT INPUTS =================
enable_exit_signal = input.bool(true, "Enable Exit Signals")
exit_top_lookback = input.int(6, "Exit Top Lookback", minval=2)
show_exit_bg = input.bool(false, "Highlight Exit Zone")

// EX1
ex1_overextended_atr = input.float(0.6, "EX1 Overextended ATR", minval=0.1, step=0.1)
ex1_rsi_min = input.int(58, "EX1 RSI Min", minval=1, maxval=100)
ex1_stoch_min = input.int(65, "EX1 Stoch Min", minval=1, maxval=100)

// EX2
ex2_overextended_atr = input.float(1.0, "EX2 Overextended ATR", minval=0.1, step=0.1)
ex2_rsi_min = input.int(68, "EX2 RSI Min", minval=1, maxval=100)
ex2_stoch_min = input.int(80, "EX2 Stoch Min", minval=1, maxval=100)

exit_cooldown = input.int(10, "Exit Cooldown", minval=1)

// ================= CONTEXT =================
trend_context_ok = true

if use_trend_context
    if allow_countertrend
        trend_context_ok := true
    else
        trend_context_ok := close > ema200 and ema50 > ema200

// ================= VOLUME =================
vol_ok = not use_volume_confirm or volume > ta.sma(volume, 20)

// ======================================================
// UP REVERSAL: EARLY + CONFIRMED
// ======================================================
pivL = ta.pivotlow(low, pivot_left, pivot_right)
pivot_low_happened = not na(pivL)
recent_pivot_low = ta.barssince(pivot_low_happened) <= pivot_window

is_bottom_zone = low <= ta.lowest(low, bottom_lookback)
bottom_now = low <= ta.lowest(low, bottom_now_lookback)

overextended_down = close < ema50 - atr * overextended_atr

bull_confirm = close > close[1]
early_reversal = close > low[1]

range_bar = high - low
lower_wick = math.min(open, close) - low
wick_ok = range_bar > 0 and lower_wick / range_bar >= wick_ratio_min

bull_osc_ok = rsi < rsi_max and stoch_k < stoch_max and ta.crossover(stoch_k, stoch_d)
bull_osc_early_ok = rsi < (rsi_max + 5) and (stoch_k < (stoch_max + 10) or stoch_k > stoch_k[1])

raw_up_early = trend_context_ok and is_bottom_zone and overextended_down and early_reversal and bull_osc_early_ok and vol_ok
raw_reversal_up = trend_context_ok and recent_pivot_low and is_bottom_zone and bottom_now and overextended_down and bull_confirm and early_reversal and wick_ok and bull_osc_ok and vol_ok

in_pullback = close < ema20

var bool early_up_fired_in_pullback = false
var bool confirmed_up_fired_in_pullback = false
var int last_up_early_bar = na
var int last_up_bar = na

if not in_pullback
    early_up_fired_in_pullback := false
    confirmed_up_fired_in_pullback := false

up_early = false
reversal_up = false

if raw_up_early and not early_up_fired_in_pullback and (na(last_up_early_bar) or bar_index - last_up_early_bar > cooldown_up_early)
    up_early := true
    early_up_fired_in_pullback := true
    last_up_early_bar := bar_index

if raw_reversal_up and not confirmed_up_fired_in_pullback and (na(last_up_bar) or bar_index - last_up_bar > cooldown_up)
    reversal_up := true
    confirmed_up_fired_in_pullback := true
    last_up_bar := bar_index

// ======================================================
// CRASH REVERSAL: EARLY + CONFIRMED
// ======================================================
recent_high = ta.highest(high, drop_lookback)
drop_pct = recent_high > 0 ? (recent_high - low) / recent_high * 100 : 0.0
crash_drop = drop_pct >= drop_pct_threshold

crash_range_bar = high - low
crash_lower_wick = math.min(open, close) - low
crash_wick_ok = crash_range_bar > 0 and crash_lower_wick / crash_range_bar >= crash_wick_ratio_min

crash_reclaim_ok = close > close[1] and close > low[1]
crash_reclaim_early_ok = close > open or close > low[1]

crash_osc_ok = ta.crossover(stoch_k, stoch_d) or rsi < 35
crash_osc_early_ok = rsi < 40 or stoch_k > stoch_k[1]

ema200_not_falling = true

raw_crash_early = enable_crash_reversal and crash_drop and crash_reclaim_early_ok and crash_osc_early_ok and ema200_not_falling
raw_crash_reversal = enable_crash_reversal and crash_drop and crash_wick_ok and crash_reclaim_ok and crash_osc_ok and ema200_not_falling

in_crash_drop = crash_drop

var bool early_crash_fired_in_drop = false
var bool confirmed_crash_fired_in_drop = false
var int last_crash_early_bar = na
var int last_crash_bar = na

crash_reset = not in_crash_drop or close > ema20 or rsi > 45

if crash_reset
    early_crash_fired_in_drop := false
    confirmed_crash_fired_in_drop := false

crash_early = false
crash_reversal_up = false

if raw_crash_early and not early_crash_fired_in_drop and (na(last_crash_early_bar) or bar_index - last_crash_early_bar > crash_early_cooldown)
    crash_early := true
    early_crash_fired_in_drop := true
    last_crash_early_bar := bar_index

if raw_crash_reversal and not confirmed_crash_fired_in_drop and (na(last_crash_bar) or bar_index - last_crash_bar > crash_cooldown)
    crash_reversal_up := true
    confirmed_crash_fired_in_drop := true
    last_crash_bar := bar_index

// ======================================================
// DUAL EXIT BLOCK
// ======================================================
top_now = high >= ta.highest(high, exit_top_lookback)

upper_wick = high - math.max(open, close)
exit_range_bar = high - low
upper_wick_ok = exit_range_bar > 0 and upper_wick / exit_range_bar >= 0.25

bear_confirm = close < close[1] and close < open

ex1_overextended = close > ema50 + atr * ex1_overextended_atr
ex1_osc_ok = rsi > ex1_rsi_min and stoch_k > ex1_stoch_min and ta.crossunder(stoch_k, stoch_d)
raw_exit_signal_1 = enable_exit_signal and top_now and ex1_overextended and bear_confirm and ex1_osc_ok

ex2_overextended = close > ema50 + atr * ex2_overextended_atr
ex2_osc_ok = rsi > ex2_rsi_min and stoch_k > ex2_stoch_min and ta.crossunder(stoch_k, stoch_d)
raw_exit_signal_2 = enable_exit_signal and top_now and ex2_overextended and upper_wick_ok and bear_confirm and ex2_osc_ok

in_up_impulse = close > ema20

var bool exit_fired_in_impulse = false
var int last_exit_bar = na

impulse_reset = close < ema20 or rsi < 50 or stoch_k < 50

if impulse_reset
    exit_fired_in_impulse := false

exit_signal_1 = false
exit_signal_2 = false

if not exit_fired_in_impulse and in_up_impulse and (na(last_exit_bar) or bar_index - last_exit_bar > exit_cooldown)
    if raw_exit_signal_2
        exit_signal_2 := true
        exit_fired_in_impulse := true
        last_exit_bar := bar_index
    else if raw_exit_signal_1
        exit_signal_1 := true
        exit_fired_in_impulse := true
        last_exit_bar := bar_index

// ================= VISUAL =================
plotshape(up_early, title="UP Early", location=location.belowbar, color=color.new(color.lime, 35), style=shape.circle, size=size.tiny)
plotshape(reversal_up, title="UP Confirmed", location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.small, text="UP")

plotshape(crash_early, title="Crash Early", location=location.belowbar, color=color.new(color.aqua, 35), style=shape.circle, size=size.tiny)
plotshape(crash_reversal_up, title="Crash Confirmed", location=location.belowbar, color=color.aqua, style=shape.diamond, size=size.small, text="CR")

plotshape(exit_signal_1, title="Exit Signal 1", location=location.abovebar, color=color.orange, style=shape.triangledown, size=size.small, text="EX1")
plotshape(exit_signal_2, title="Exit Signal 2", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small, text="EX2")

bgcolor(show_bg_zone and overextended_down ? color.new(color.green, 92) : na)
bgcolor(show_crash_bg and crash_drop ? color.new(color.aqua, 92) : na)
bgcolor(show_exit_bg and (ex1_overextended or ex2_overextended) ? color.new(color.orange, 92) : na)

plot(show_ema20 ? ema20 : na, title="EMA20", color=color.yellow)
plot(show_ema50 ? ema50 : na, title="EMA50", color=color.orange)
plot(show_ema200 ? ema200 : na, title="EMA200", color=color.blue)

alertcondition(up_early, title="UP Early", message="Early up reversal detected")
alertcondition(reversal_up, title="UP Confirmed", message="Confirmed up reversal detected")
alertcondition(crash_early, title="Crash Early", message="Early crash reversal detected")
alertcondition(crash_reversal_up, title="Crash Confirmed", message="Confirmed crash reversal detected")
alertcondition(exit_signal_1, title="Exit Signal 1", message="Soft exit signal detected")
alertcondition(exit_signal_2, title="Exit Signal 2", message="Strong exit signal detected")
````
