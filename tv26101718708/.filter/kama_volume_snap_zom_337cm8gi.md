# KAMA Volume Snap [ZOM]

- url: https://www.tradingview.com/script/337Cm8gI-KAMA-Volume-Snap-ZOM/
- type: indicator
- pine_id: PUB;88993ed41e564b0d9aa6cc48cdecaf49
- version: 1.0

## Description

KAMA Volume Snap [ZOM] is an open-source trend/reclaim indicator that combines Kaufman Adaptive Moving Average efficiency, volume-weighted RSI impulse, and ATR-normalized candle thrust.

The script is built to highlight moments where price begins to move cleanly again after noisy conditions. KAMA provides the adaptive trend spine, efficiency measures whether movement is becoming more directional, volume-weighted RSI adds participation/impulse context, and ATR thrust filters for meaningful candle expansion.

Core components:
- Kaufman Adaptive Moving Average trend spine
- Efficiency ratio expansion
- Volume-weighted RSI impulse filter
- ATR thrust confirmation
- Price-locked watch and confirmed signal markers
- Alerts for bullish and bearish watch/confirmed conditions

This is a lightweight confluence tool for continuation and reclaim context. It is not financial advice or a standalone trading system. Combine it with structure, risk controls, and your own review.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("KAMA Volume Snap [ZOM]", shorttitle="KVS [ZOM]", overlay=true)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Signal Settings"
sig_mode = input.string("Balanced", "Sensitivity Mode", options=["Early", "Balanced", "Strict"], group=grp_mode)
show_watch = input.bool(true, "Show Watch Markers", group=grp_mode)
show_signals = input.bool(true, "Show Confirmed Signals", group=grp_mode)
cooldown_bars = input.int(3, "Signal Cooldown (Bars)", minval=0, group=grp_mode)
atr_offset = input.float(0.5, "Marker ATR Offset", step=0.1, group=grp_mode)

grp_kama = "Kaufman Adaptive Moving Average (Efficiency)"
kama_len = input.int(10, "KAMA Length", group=grp_kama)
fast_end = input.int(2, "Fast EMA Length", group=grp_kama)
slow_end = input.int(30, "Slow EMA Length", group=grp_kama)

grp_vrsi = "Volume-Weighted RSI (Impulse)"
vrsi_len = input.int(14, "Volume RSI Length", group=grp_vrsi)
vrsi_ob = input.int(60, "RSI Bullish Threshold", group=grp_vrsi)
vrsi_os = input.int(40, "RSI Bearish Threshold", group=grp_vrsi)

grp_thrust = "ATR Thrust Confirmation"
atr_len = input.int(14, "ATR Length", group=grp_thrust)
thrust_mult = input.float(0.8, "Thrust ATR Multiplier", step=0.1, group=grp_thrust)

grp_style = "Aesthetics"
color_bull = input.color(#00FF9D, "Bullish (Mint)", group=grp_style)
color_bear = input.color(#FFB000, "Bearish (Amber)", group=grp_style)
color_neut = input.color(#535C68, "Neutral (Graphite)", group=grp_style)

// ========================================================================= //
// --- Logic: KAMA (Efficiency) ---
// ========================================================================= //
change_sum = math.sum(math.abs(close - close[1]), kama_len)
change_net = math.abs(close - close[kama_len])
er = change_sum == 0 ? 0 : change_net / change_sum
fast_sc = 2 / (fast_end + 1)
slow_sc = 2 / (slow_end + 1)
sc = math.pow((er * (fast_sc - slow_sc)) + slow_sc, 2)

var float kama = 0.0
kama := nz(kama[1]) + sc * (close - nz(kama[1]))

kama_bull = close > kama and kama > nz(kama[1])
kama_bear = close < kama and kama < nz(kama[1])
kama_eff_rising = er > nz(er[1])

// ========================================================================= //
// --- Logic: Volume-Weighted RSI ---
// ========================================================================= //
up_vol = close > close[1] ? (close - close[1]) * volume : 0
dn_vol = close < close[1] ? (close[1] - close) * volume : 0
up_avg = ta.sma(up_vol, vrsi_len)
dn_avg = ta.sma(dn_vol, vrsi_len)
rs = dn_avg == 0 ? 100 : up_avg / dn_avg
vrsi = 100 - (100 / (1 + rs))

vrsi_bull = vrsi > vrsi_ob
vrsi_bear = vrsi < vrsi_os

// ========================================================================= //
// --- Logic: ATR Thrust ---
// ========================================================================= //
atr_val = ta.atr(atr_len)
body = math.abs(close - open)

thrust_bull = close > open and body > atr_val * thrust_mult
thrust_bear = close < open and body > atr_val * thrust_mult

// ========================================================================= //
// --- Scoring & Signals ---
// ========================================================================= //
bull_score = (kama_bull ? 1 : 0) + (kama_eff_rising ? 1 : 0) + (vrsi_bull ? 1 : 0) + (thrust_bull ? 1 : 0)
bear_score = (kama_bear ? 1 : 0) + (kama_eff_rising ? 1 : 0) + (vrsi_bear ? 1 : 0) + (thrust_bear ? 1 : 0)

thresh = sig_mode == "Early" ? 2 : sig_mode == "Balanced" ? 3 : 4

bull_watch = bull_score >= (thresh - 1) and bull_score < thresh and kama_bull
bear_watch = bear_score >= (thresh - 1) and bear_score < thresh and kama_bear

bull_sig = bull_score >= thresh
bear_sig = bear_score >= thresh

var int last_bull = 0
var int last_bear = 0
if bull_sig
    last_bull := bar_index
if bear_sig
    last_bear := bar_index

bull_valid = bull_sig and (bar_index - nz(last_bull[1]) > cooldown_bars)
bear_valid = bear_sig and (bar_index - nz(last_bear[1]) > cooldown_bars)

// ========================================================================= //
// --- Visuals ---
// ========================================================================= //
kama_color = kama_bull ? color_bull : kama_bear ? color_bear : color_neut
plot(kama, "KAMA Spine", color=color.new(kama_color, 20), linewidth=2)

longWatchPrice = low - atr_val * atr_offset * 0.5
shortWatchPrice = high + atr_val * atr_offset * 0.5
longSignalPrice = low - atr_val * atr_offset
shortSignalPrice = high + atr_val * atr_offset

plot(show_watch and bull_watch ? longWatchPrice : na, "Bull Watch", color=color.new(color_bull, 40), style=plot.style_circles, linewidth=2)
plot(show_watch and bear_watch ? shortWatchPrice : na, "Bear Watch", color=color.new(color_bear, 40), style=plot.style_circles, linewidth=2)

plot(show_signals and bull_valid ? longSignalPrice : na, "Bull Confirmed", color=color_bull, style=plot.style_cross, linewidth=3)
plot(show_signals and bear_valid ? shortSignalPrice : na, "Bear Confirmed", color=color_bear, style=plot.style_cross, linewidth=3)

barcolor(bull_valid ? color_bull : bear_valid ? color_bear : na)

// ========================================================================= //
// --- Alerts ---
// ========================================================================= //
alertcondition(bull_watch, "KVS Bull Watch", "KAMA Volume Snap: Bullish Watch Setup [ZOM]")
alertcondition(bear_watch, "KVS Bear Watch", "KAMA Volume Snap: Bearish Watch Setup [ZOM]")
alertcondition(bull_valid, "KVS Bull Confirmed", "KAMA Volume Snap: Bullish Signal Confirmed [ZOM]")
alertcondition(bear_valid, "KVS Bear Confirmed", "KAMA Volume Snap: Bearish Signal Confirmed [ZOM]")
````
