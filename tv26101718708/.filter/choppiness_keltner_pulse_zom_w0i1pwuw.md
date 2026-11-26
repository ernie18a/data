# Choppiness Keltner Pulse [ZOM]

- url: https://www.tradingview.com/script/W0i1PWuw-Choppiness-Keltner-Pulse-ZOM/
- type: indicator
- pine_id: PUB;c13ac7133193495fb55e86d4ca924376
- version: 1.0

## Description

Choppiness Keltner Pulse [ZOM] is an open-source regime and continuation tool built around Choppiness Index contraction, Keltner reclaim/flush behavior, OBV pressure, and ATR thrust confirmation.

The idea is to identify moments when price is leaving a compressed or choppy state and beginning to move with cleaner directional participation. The glass channel visual shows Keltner pulse context, while price-anchored watch and confirmed markers keep signals attached to the chart when panning, zooming, scaling, or changing timeframes.

Core components:
- Choppiness Index regime / compression state
- Keltner reclaim and flush trigger logic
- OBV pressure confirmation
- ATR thrust / range expansion filter
- Cooldown-aware watch and confirmed signals
- Compact mini dashboard with mode, chop state, OBV pressure, trigger state, bias, and quality score
- Alerts for bullish and bearish watch/confirmed conditions

The Quality Score is a confluence read, not a prediction. It summarizes whether the current bar has enough regime, trigger, participation, thrust, and cooldown alignment to support the signal context.

This is not financial advice or a standalone trading system. Use it with structure, risk controls, and your own confirmation process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("Choppiness Keltner Pulse [ZOM]", shorttitle="CKP [ZOM]", overlay=true)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Signal Settings"
sig_mode = input.string("Balanced", "Sensitivity Mode", options=["Early", "Balanced", "Strict"], group=grp_mode)
show_watch = input.bool(true, "Show Watch Markers", group=grp_mode)
show_signals = input.bool(true, "Show Confirmed Signals", group=grp_mode)
cooldown_bars = input.int(3, "Signal Cooldown (Bars)", minval=0, group=grp_mode)
atr_offset = input.float(0.5, "Marker ATR Offset", step=0.1, group=grp_mode)

grp_chop = "Choppiness Index"
chop_len = input.int(14, "Chop Length", group=grp_chop)
chop_thresh = input.float(50.0, "Chop Release Threshold", step=1.0, group=grp_chop)

grp_kc = "Keltner Channels"
kc_len = input.int(20, "KC Length", group=grp_kc)
kc_mult = input.float(1.5, "Outer KC Multiplier", step=0.1, group=grp_kc)

grp_obv = "On-Balance Volume (OBV)"
obv_len = input.int(10, "OBV Slope Length", group=grp_obv)

grp_thrust = "ATR Thrust"
atr_len = input.int(14, "ATR Length", group=grp_thrust)
thrust_mult = input.float(0.8, "Thrust Multiplier", step=0.1, group=grp_thrust)

grp_dash = "Mini Dashboard"
show_dash = input.bool(true, "Show Mini Dashboard", group=grp_dash)
dash_transp = input.int(80, "Dashboard Transparency", minval=0, maxval=100, group=grp_dash)

grp_style = "Aesthetics"
color_bull = input.color(#00FFFF, "Bullish (Electric Cyan)", group=grp_style)
color_bear = input.color(#FF6B6B, "Bearish (Hot Coral)", group=grp_style)
color_neut = input.color(#E0FFFF, "Centerline (White/Blue)", group=grp_style)

// ========================================================================= //
// --- Logic: Choppiness Index ---
// ========================================================================= //
atr_sum = math.sum(ta.atr(1), chop_len)
high_range = ta.highest(high, chop_len)
low_range = ta.lowest(low, chop_len)
chop = high_range - low_range == 0 ? 0 : 100 * math.log10(atr_sum / (high_range - low_range)) / math.log10(chop_len)

chop_releasing = chop < chop_thresh and (chop[1] >= chop_thresh or chop < chop[1])

// ========================================================================= //
// --- Logic: Keltner Channels ---
// ========================================================================= //
kc_basis = ta.ema(close, kc_len)
kc_range = ta.atr(kc_len)
kc_upper = kc_basis + kc_range * kc_mult
kc_lower = kc_basis - kc_range * kc_mult

kc_bull_reclaim = ta.crossover(close, kc_basis) or close > kc_upper
kc_bear_flush = ta.crossunder(close, kc_basis) or close < kc_lower

// ========================================================================= //
// --- Logic: OBV Slope ---
// ========================================================================= //
obv = ta.cum(math.sign(ta.change(close)) * volume)
obv_sma = ta.sma(obv, obv_len)

obv_bull = obv > obv_sma and obv > obv[1]
obv_bear = obv < obv_sma and obv < obv[1]

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
bull_score_val = (chop_releasing ? 1 : 0) + (kc_bull_reclaim ? 1 : 0) + (obv_bull ? 1 : 0) + (thrust_bull ? 1 : 0)
bear_score_val = (chop_releasing ? 1 : 0) + (kc_bear_flush ? 1 : 0) + (obv_bear ? 1 : 0) + (thrust_bear ? 1 : 0)

thresh = sig_mode == "Early" ? 2 : sig_mode == "Balanced" ? 3 : 4

bull_watch = bull_score_val >= (thresh - 1) and bull_score_val < thresh and kc_bull_reclaim
bear_watch = bear_score_val >= (thresh - 1) and bear_score_val < thresh and kc_bear_flush

bull_sig = bull_score_val >= thresh and kc_bull_reclaim
bear_sig = bear_score_val >= thresh and kc_bear_flush

var int last_bull = 0
var int last_bear = 0
if bull_sig
    last_bull := bar_index
if bear_sig
    last_bear := bar_index

cooldown_ok_bull = (bar_index - nz(last_bull[1]) > cooldown_bars)
cooldown_ok_bear = (bar_index - nz(last_bear[1]) > cooldown_bars)

bull_valid = bull_sig and cooldown_ok_bull
bear_valid = bear_sig and cooldown_ok_bear

// ========================================================================= //
// --- Visuals ---
// ========================================================================= //
kc_inner_upper = kc_basis + kc_range * kc_mult * 0.5
kc_inner_lower = kc_basis - kc_range * kc_mult * 0.5

p_outer_up = plot(kc_upper, "Outer KC Upper", color=color.new(color_bull, 85), style=plot.style_line, linewidth=1)
p_inner_up = plot(kc_inner_upper, "Inner KC Upper", color=color.new(color_bull, 90), style=plot.style_line, linewidth=1)

p_outer_dn = plot(kc_lower, "Outer KC Lower", color=color.new(color_bear, 85), style=plot.style_line, linewidth=1)
p_inner_dn = plot(kc_inner_lower, "Inner KC Lower", color=color.new(color_bear, 90), style=plot.style_line, linewidth=1)

p_center = plot(kc_basis, "KC Centerline", color=color.new(color_neut, 30), style=plot.style_line, linewidth=1)

fill(p_center, p_inner_up, color=color.new(color_bull, 95), title="Inner Bull Cloud")
fill(p_center, p_inner_dn, color=color.new(color_bear, 95), title="Inner Bear Cloud")

fill(p_inner_up, p_outer_up, color=color.new(color_bull, 90), title="Outer Bull Pulse")
fill(p_inner_dn, p_outer_dn, color=color.new(color_bear, 90), title="Outer Bear Pulse")

longWatchPrice = low - atr_val * atr_offset * 0.5
shortWatchPrice = high + atr_val * atr_offset * 0.5
longSignalPrice = low - atr_val * atr_offset
shortSignalPrice = high + atr_val * atr_offset

plot(show_watch and bull_watch ? longWatchPrice : na, "Bull Watch", color=color.new(color_bull, 50), style=plot.style_circles, linewidth=1)
plot(show_watch and bear_watch ? shortWatchPrice : na, "Bear Watch", color=color.new(color_bear, 50), style=plot.style_circles, linewidth=1)

plot(show_signals and bull_valid ? longSignalPrice : na, "Bull Confirmed", color=color_bull, style=plot.style_cross, linewidth=2)
plot(show_signals and bear_valid ? shortSignalPrice : na, "Bear Confirmed", color=color_bear, style=plot.style_cross, linewidth=2)

// ========================================================================= //
// --- Dashboard ---
// ========================================================================= //
if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#131722, dash_transp), border_width=1, border_color=color.new(color_neut, 80))
    
    // Header
    table.cell(dash, 0, 0, "CKP [ZOM]", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, sig_mode, text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_right)
    
    // Chop State
    chop_str = chop_releasing ? "Releasing" : "Compressing"
    chop_col = chop_releasing ? color_bull : color.new(color_neut, 0)
    table.cell(dash, 0, 1, "Chop State", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, chop_str, text_color=chop_col, text_size=size.small, text_halign=text.align_right)
    
    // OBV Pressure
    obv_str = obv_bull ? "Bullish" : obv_bear ? "Bearish" : "Neutral"
    obv_col = obv_bull ? color_bull : obv_bear ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 2, "OBV Pressure", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, obv_str, text_color=obv_col, text_size=size.small, text_halign=text.align_right)
    
    // Keltner Trigger
    kc_str = kc_bull_reclaim ? "Reclaim" : kc_bear_flush ? "Flush" : "Neutral"
    kc_col = kc_bull_reclaim ? color_bull : kc_bear_flush ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 3, "Keltner Trigger", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, kc_str, text_color=kc_col, text_size=size.small, text_halign=text.align_right)
    
    // Signal Bias
    bias_str = bull_score_val > bear_score_val ? "Bullish Bias" : bear_score_val > bull_score_val ? "Bearish Bias" : "Neutral Bias"
    bias_col = bull_score_val > bear_score_val ? color_bull : bear_score_val > bull_score_val ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 4, "Signal Bias", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, bias_str, text_color=bias_col, text_size=size.small, text_halign=text.align_right)
    
    // Quality Score
    max_score = 4.0
    quality = math.round((math.max(bull_score_val, bear_score_val) / max_score) * 100)
    qual_col = quality >= 75 ? color_bull : quality >= 50 ? color.new(color_neut, 0) : color.new(color_bear, 20)
    table.cell(dash, 0, 5, "Quality Score", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(quality) + "%", text_color=qual_col, text_size=size.small, text_halign=text.align_right)

// ========================================================================= //
// --- Alerts ---
// ========================================================================= //
alertcondition(bull_watch, "CKP Bull Watch", "Choppiness Keltner Pulse: Bullish Watch Setup [ZOM]")
alertcondition(bear_watch, "CKP Bear Watch", "Choppiness Keltner Pulse: Bearish Watch Setup [ZOM]")
alertcondition(bull_valid, "CKP Bull Confirmed", "Choppiness Keltner Pulse: Bullish Signal Confirmed [ZOM]")
alertcondition(bear_valid, "CKP Bear Confirmed", "Choppiness Keltner Pulse: Bearish Signal Confirmed [ZOM]")
````
