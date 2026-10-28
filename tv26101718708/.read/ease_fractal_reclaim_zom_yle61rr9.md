# Ease Fractal Reclaim [ZOM]

- url: https://www.tradingview.com/script/YlE61RR9-Ease-Fractal-Reclaim-ZOM/
- type: indicator
- pine_id: PUB;48f27d94227045198b2d632c839cf012
- version: 1.0

## Description

Ease Fractal Reclaim [ZOM] is an open-source structure and reclaim tool built around Ease of Movement flow, recent fractal range context, CCI impulse, and ATR/body thrust confirmation.

The script is designed to show when price is attempting to reclaim or reject a recent structure zone while movement becomes easier and momentum begins to confirm. The visual style uses sparse fractal rails and price-anchored markers instead of a heavy cloud, with a compact mini dashboard for quick context.

Core components:
- Ease of Movement flow / resistance read
- Recent fractal range rails and reclaim/reject context
- CCI zero-line impulse filter
- ATR/body thrust confirmation
- Cooldown-aware watch and confirmed signals
- Compact mini dashboard with mode, EOM flow, fractal map, CCI impulse, bias, and quality score
- Alerts for bullish and bearish watch/confirmed conditions

The Quality Score is a compact confluence read, not a prediction. It summarizes whether flow, structure, impulse, thrust, and cooldown conditions are aligned enough to support the current signal context.

This is not financial advice or a standalone trading system. Use it with broader market structure, risk controls, and your own confirmation process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("Ease Fractal Reclaim [ZOM]", shorttitle="EFR [ZOM]", overlay=true)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Signal Settings"
sig_mode = input.string("Balanced", "Sensitivity Mode", options=["Early", "Balanced", "Strict"], group=grp_mode)
show_watch = input.bool(true, "Show Watch Markers", group=grp_mode)
show_signals = input.bool(true, "Show Confirmed Signals", group=grp_mode)
cooldown_bars = input.int(3, "Signal Cooldown (Bars)", minval=0, group=grp_mode)
atr_offset = input.float(0.5, "Marker ATR Offset", step=0.1, group=grp_mode)

grp_eom = "Ease of Movement (EOM)"
eom_len = input.int(14, "EOM Length", group=grp_eom)

grp_frac = "Fractal Context"
frac_len = input.int(2, "Fractal Lookback", group=grp_frac)

grp_cci = "Commodity Channel Index (CCI)"
cci_len = input.int(20, "CCI Length", group=grp_cci)

grp_thrust = "ATR Thrust"
atr_len = input.int(14, "ATR Length", group=grp_thrust)
thrust_mult = input.float(0.8, "Thrust Multiplier", step=0.1, group=grp_thrust)

grp_dash = "Mini Dashboard"
show_dash = input.bool(true, "Show Mini Dashboard", group=grp_dash)
dash_transp = input.int(85, "Dashboard Transparency", minval=0, maxval=100, group=grp_dash)

grp_style = "Aesthetics"
color_bull = input.color(#D4AF37, "Bullish Confirmed (Gold)", group=grp_style)
color_bear = input.color(#FFFFFF, "Bearish Confirmed (White)", group=grp_style)
color_watch_bull = input.color(#32CD32, "Bullish Watch (Lime)", group=grp_style)
color_watch_bear = input.color(#EE82EE, "Bearish Watch (Violet)", group=grp_style)
color_neut = input.color(#808080, "Fractal Rails (Graphite/Silver)", group=grp_style)

// ========================================================================= //
// --- Logic: Ease of Movement ---
// ========================================================================= //
hl_mid = hl2
box_ratio = (volume == 0 or (high - low) == 0) ? 1.0 : (volume / 10000) / (high - low)
eom_raw = box_ratio == 0 ? 0 : (hl_mid - hl_mid[1]) / box_ratio
eom_sma = ta.sma(eom_raw, eom_len)

eom_bull = eom_sma > 0 and eom_sma > eom_sma[1]
eom_bear = eom_sma < 0 and eom_sma < eom_sma[1]

// ========================================================================= //
// --- Logic: Fractals ---
// ========================================================================= //
is_frac_high = high[frac_len] == ta.highest(high, frac_len * 2 + 1)
is_frac_low = low[frac_len] == ta.lowest(low, frac_len * 2 + 1)

var float frac_high_val = na
var float frac_low_val = na

if is_frac_high
    frac_high_val := high[frac_len]
if is_frac_low
    frac_low_val := low[frac_len]

frac_mid = math.avg(frac_high_val, frac_low_val)

frac_bull_reclaim = close > frac_mid
frac_bear_reject = close < frac_mid

// ========================================================================= //
// --- Logic: CCI Impulse ---
// ========================================================================= //
cci = ta.cci(close, cci_len)
cci_bull = cci > 0
cci_bear = cci < 0

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
bull_score = (eom_bull ? 1 : 0) + (frac_bull_reclaim ? 1 : 0) + (cci_bull ? 1 : 0) + (thrust_bull ? 1 : 0)
bear_score = (eom_bear ? 1 : 0) + (frac_bear_reject ? 1 : 0) + (cci_bear ? 1 : 0) + (thrust_bear ? 1 : 0)

thresh = sig_mode == "Early" ? 2 : sig_mode == "Balanced" ? 3 : 4

bull_watch = bull_score >= (thresh - 1) and bull_score < thresh and frac_bull_reclaim
bear_watch = bear_score >= (thresh - 1) and bear_score < thresh and frac_bear_reject

bull_sig = bull_score >= thresh and frac_bull_reclaim
bear_sig = bear_score >= thresh and frac_bear_reject

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
plot(frac_high_val, "Fractal High", color=color.new(color_neut, 85), style=plot.style_stepline, linewidth=1)
plot(frac_low_val, "Fractal Low", color=color.new(color_neut, 85), style=plot.style_stepline, linewidth=1)
plot(frac_mid, "Fractal Mid", color=color.new(color_neut, 75), style=plot.style_stepline, linewidth=1)

longWatchPrice = low - atr_val * atr_offset * 0.5
shortWatchPrice = high + atr_val * atr_offset * 0.5
longSignalPrice = low - atr_val * atr_offset
shortSignalPrice = high + atr_val * atr_offset

plot(show_watch and bull_watch ? longWatchPrice : na, "Bull Watch", color=color.new(color_watch_bull, 20), style=plot.style_circles, linewidth=1)
plot(show_watch and bear_watch ? shortWatchPrice : na, "Bear Watch", color=color.new(color_watch_bear, 20), style=plot.style_circles, linewidth=1)

plot(show_signals and bull_valid ? longSignalPrice : na, "Bull Confirmed", color=color.new(color_bull, 0), style=plot.style_cross, linewidth=3)
plot(show_signals and bear_valid ? shortSignalPrice : na, "Bear Confirmed", color=color.new(color_bear, 0), style=plot.style_cross, linewidth=3)

barcolor(bull_valid ? color.new(color_bull, 80) : bear_valid ? color.new(color_bear, 80) : na)

// ========================================================================= //
// --- Dashboard ---
// ========================================================================= //
if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#1e1e24, dash_transp), border_width=1, border_color=color.new(color_neut, 80))
    
    // Header
    table.cell(dash, 0, 0, "EFR [ZOM]", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, sig_mode, text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_right)
    
    // EOM Flow
    eom_str = eom_bull ? "Bullish" : eom_bear ? "Bearish" : "Neutral"
    eom_col = eom_bull ? color_watch_bull : eom_bear ? color_watch_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 1, "EOM Flow", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, eom_str, text_color=eom_col, text_size=size.small, text_halign=text.align_right)
    
    // Fractal Map
    frac_str = frac_bull_reclaim ? "Reclaim" : frac_bear_reject ? "Reject" : "Inside"
    frac_col = frac_bull_reclaim ? color_bull : frac_bear_reject ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 2, "Fractal Map", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, frac_str, text_color=frac_col, text_size=size.small, text_halign=text.align_right)
    
    // CCI Impulse
    cci_str = cci_bull ? "Bullish" : cci_bear ? "Bearish" : "Neutral"
    cci_col = cci_bull ? color_watch_bull : cci_bear ? color_watch_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 3, "CCI Impulse", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, cci_str, text_color=cci_col, text_size=size.small, text_halign=text.align_right)
    
    // Signal Bias
    bias_str = bull_score > bear_score ? "Bullish Bias" : bear_score > bull_score ? "Bearish Bias" : "Neutral Bias"
    bias_col = bull_score > bear_score ? color_bull : bear_score > bull_score ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 4, "Signal Bias", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, bias_str, text_color=bias_col, text_size=size.small, text_halign=text.align_right)
    
    // Quality Score
    max_score = 4.0
    quality = math.round((math.max(bull_score, bear_score) / max_score) * 100)
    qual_col = quality >= 75 ? color_bull : quality >= 50 ? color.new(color_neut, 0) : color.new(color_bear, 20)
    table.cell(dash, 0, 5, "Quality Score", text_color=color.new(color_neut, 20), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(quality) + "%", text_color=qual_col, text_size=size.small, text_halign=text.align_right)

// ========================================================================= //
// --- Alerts ---
// ========================================================================= //
alertcondition(bull_watch, "EFR Bull Watch", "Ease Fractal Reclaim: Bullish Watch Setup [ZOM]")
alertcondition(bear_watch, "EFR Bear Watch", "Ease Fractal Reclaim: Bearish Watch Setup [ZOM]")
alertcondition(bull_valid, "EFR Bull Confirmed", "Ease Fractal Reclaim: Bullish Signal Confirmed [ZOM]")
alertcondition(bear_valid, "EFR Bear Confirmed", "Ease Fractal Reclaim: Bearish Signal Confirmed [ZOM]")
````
