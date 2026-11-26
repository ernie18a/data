# Aroon Wick Trap [ZOM]

- url: https://www.tradingview.com/script/Ps25wTGr-Aroon-Wick-Trap-ZOM/
- type: indicator
- pine_id: PUB;2d11c852e8ea4acabbfd8e598ada5fc0
- version: 1.0

## Description

Aroon Wick Trap [ZOM] is an open-source reversal and failed-breakout study built for traders who want a cleaner read on wick rejection, Aroon regime transitions, Donchian boundary sweeps, and Chaikin Money Flow absorption.

The script looks for failed extensions beyond recent Donchian boundaries, then checks whether rejection wicks, Aroon direction, and CMF pressure support a possible trap setup. Confirmed signals use price-anchored plot markers so they stay attached to the chart when panning, zooming, scaling, or changing timeframes.

Core components:
- Aroon Up/Down regime transition
- Donchian sweep / failed extension context
- Chaikin Money Flow absorption filter
- ATR-based wick rejection
- Price-locked watch and confirmed signal markers
- Alerts for bullish and bearish watch/confirmed conditions

This is designed as a lightweight confluence tool, not a standalone trading system. Use it with market structure, risk management, and your own confirmation process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("Aroon Wick Trap [ZOM]", shorttitle="AWT [ZOM]", overlay=true)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Signal Settings"
sig_mode = input.string("Balanced", "Sensitivity Mode", options=["Early", "Balanced", "Strict"], group=grp_mode)
show_watch = input.bool(true, "Show Watch Markers", group=grp_mode)
show_signals = input.bool(true, "Show Confirmed Signals", group=grp_mode)
cooldown_bars = input.int(3, "Signal Cooldown (Bars)", minval=0, group=grp_mode)
atr_offset = input.float(0.5, "Marker ATR Offset", step=0.1, group=grp_mode)

grp_aroon = "Aroon Regime"
aroon_len = input.int(14, "Aroon Length", group=grp_aroon)

grp_don = "Donchian Boundary"
don_len = input.int(20, "Donchian Lookback", group=grp_don)

grp_cmf = "Chaikin Money Flow (Absorption)"
cmf_len = input.int(20, "CMF Length", group=grp_cmf)

grp_wick = "Wick Rejection (ATR)"
atr_len = input.int(14, "ATR Length", group=grp_wick)
wick_mult = input.float(0.8, "Wick ATR Multiplier", step=0.1, group=grp_wick)

grp_style = "Aesthetics"
color_bull = input.color(#00FFFF, "Bullish (Ice)", group=grp_style) // Ice/Cyan
color_bear = input.color(#FF007F, "Bearish (Rose)", group=grp_style) // Rose
color_neut = input.color(#0047AB, "Neutral (Cobalt)", group=grp_style) // Cobalt

// ========================================================================= //
// --- Logic: Aroon ---
// ========================================================================= //
highest_bars = ta.highestbars(high, aroon_len)
lowest_bars = ta.lowestbars(low, aroon_len)

aroon_up = 100 * (aroon_len + highest_bars) / aroon_len
aroon_dn = 100 * (aroon_len + lowest_bars) / aroon_len

aroon_bull = aroon_up > aroon_dn
aroon_bear = aroon_dn > aroon_up
aroon_bull_turn = ta.crossover(aroon_up, aroon_dn)
aroon_bear_turn = ta.crossunder(aroon_up, aroon_dn)

// ========================================================================= //
// --- Logic: Donchian Boundary ---
// ========================================================================= //
upper_don = ta.highest(high, don_len)[1]
lower_don = ta.lowest(low, don_len)[1]

sweep_high = high > upper_don
sweep_low = low < lower_don

// ========================================================================= //
// --- Logic: Chaikin Money Flow ---
// ========================================================================= //
mf_mult = (high == low) ? 0.0 : ((close - low) - (high - close)) / (high - low)
mf_vol = mf_mult * volume
cmf = math.sum(mf_vol, cmf_len) / math.sum(volume, cmf_len)

cmf_bull = cmf > 0 or cmf > cmf[1]
cmf_bear = cmf < 0 or cmf < cmf[1]

// ========================================================================= //
// --- Logic: Wick Rejection ---
// ========================================================================= //
atr_val = ta.atr(atr_len)
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

rej_bear = upper_wick > atr_val * wick_mult
rej_bull = lower_wick > atr_val * wick_mult

// ========================================================================= //
// --- Scoring & Signals ---
// ========================================================================= //
bull_base = sweep_low and rej_bull
bear_base = sweep_high and rej_bear

bull_score = (aroon_bull or aroon_bull_turn ? 1 : 0) + (cmf_bull ? 1 : 0) + (bull_base ? 1 : 0)
bear_score = (aroon_bear or aroon_bear_turn ? 1 : 0) + (cmf_bear ? 1 : 0) + (bear_base ? 1 : 0)

thresh = sig_mode == "Early" ? 1 : sig_mode == "Balanced" ? 2 : 3

bull_watch = bull_base and bull_score >= (thresh - 1) and bull_score < thresh
bear_watch = bear_base and bear_score >= (thresh - 1) and bear_score < thresh

bull_sig = bull_base and bull_score >= thresh
bear_sig = bear_base and bear_score >= thresh

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
// Thin Donchian Ghost Boundaries
plot(upper_don, "Upper Ghost", color=color.new(color_neut, 70), style=plot.style_linebr)
plot(lower_don, "Lower Ghost", color=color.new(color_neut, 70), style=plot.style_linebr)

// Bias Dots based on Aroon
plot(hl2, "Aroon Bias", color=aroon_bull ? color.new(color_bull, 80) : aroon_bear ? color.new(color_bear, 80) : color.new(color_neut, 80), style=plot.style_circles, linewidth=1)

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
alertcondition(bull_watch, "AWT Bull Watch", "Aroon Wick Trap: Bullish Watch Setup [ZOM]")
alertcondition(bear_watch, "AWT Bear Watch", "Aroon Wick Trap: Bearish Watch Setup [ZOM]")
alertcondition(bull_valid, "AWT Bull Confirmed", "Aroon Wick Trap: Bullish Signal Confirmed [ZOM]")
alertcondition(bear_valid, "AWT Bear Confirmed", "Aroon Wick Trap: Bearish Signal Confirmed [ZOM]")
````
