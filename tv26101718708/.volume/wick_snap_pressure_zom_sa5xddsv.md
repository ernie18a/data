# Wick Snap Pressure [ZOM]

- url: https://www.tradingview.com/script/sa5xDdSV-Wick-Snap-Pressure-ZOM/
- type: indicator
- pine_id: PUB;c8ef146369fb424084f2af7889b6568e
- version: 1.0

## Description

Wick Snap Pressure [ZOM] is an overlay pressure marker designed to highlight meaningful wick rejections only when they are supported by candle pressure, volume impulse, and stress context. The goal is to avoid treating every long wick as a signal. Instead, the script looks for a rejection candle that also has supporting evidence from lesser-used pressure tools.

The calculation combines four parts. First, wick rejection ratio checks whether the upper or lower wick is large enough relative to the candle body and total range to represent a visible rejection. Second, QStick measures smoothed close-minus-open candle pressure, which helps show whether recent candle bodies are leaning bullish or bearish. Third, Elder Force Index measures whether price movement is being supported by volume impulse. Fourth, Ulcer Index stress is used as a context filter so the script can avoid confirming snaps while adverse stress is still expanding.

Bullish watch markers appear when lower-wick rejection and early QStick pressure align before full confirmation. Bullish snap markers require stronger agreement: lower wick rejection, improving bullish QStick behavior, positive Force Index, and non-expanding stress. Bearish watch and bearish snap signals mirror the same logic using upper-wick rejection, negative QStick pressure, negative Force Index, and suitable stress behavior.

The visual layout is intentionally lightweight. It uses subtle bar coloring, small above/below-bar markers, and a compact dashboard instead of projected zones or static drawings. Mint markers represent bullish snap pressure, crimson markers represent bearish snap pressure, and gold watch markers show earlier setups that have not fully confirmed. The dashboard summarizes QStick pressure, Force Index direction, Ulcer stress bias, the most recent snap, and the composite bias.

I use this as a tape-reading and reaction aid around pullbacks, failed pushes, VWAP tests, prior swing levels, and local reversal attempts. It is not a standalone buy/sell system. Strong trend days can produce countertrend wick signals that fail, so the best use is as a confirmation layer alongside market structure, trend, liquidity context, and risk controls.

Key inputs include QStick length, Force Index length, Ulcer Index length, wick/body threshold, signal cooldown, marker offset, dashboard visibility, and palette colors. Lower wick thresholds create more signals. Higher thresholds demand more obvious rejection and reduce signal frequency.

Open-source [ZOM] script for educational use only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenOutMan

//@version=6
indicator("Wick Snap Pressure [ZOM]", shorttitle="WSP [ZOM]", overlay=true)

// ========================================================================= //
// --- Inputs --- 
// ========================================================================= //
grp_mode = "Signal Settings"
show_watch = input.bool(true, "Show Watch Markers", group=grp_mode)
show_signals = input.bool(true, "Show Confirmed Snaps", group=grp_mode)
cooldown_bars = input.int(3, "Signal Cooldown (Bars)", minval=0, group=grp_mode)
atr_offset = input.float(0.5, "Marker ATR Offset", step=0.1, group=grp_mode)

grp_logic = "Core Logic Settings"
qstick_len = input.int(14, "QStick Length", group=grp_logic)
efi_len = input.int(13, "Force Index Length", group=grp_logic)
ui_len = input.int(14, "Ulcer Index Length", group=grp_logic)
wick_mult = input.float(1.5, "Wick/Body Ratio Threshold", step=0.1, group=grp_logic)

grp_dash = "Mini Dashboard"
show_dash = input.bool(true, "Show Dashboard", group=grp_dash)
dash_transp = input.int(85, "Dashboard Transparency", minval=0, maxval=100, group=grp_dash)

grp_style = "Aesthetics"
color_bull = input.color(#00FA9A, "Bullish Snap (Mint)", group=grp_style)
color_bear = input.color(#DC143C, "Bearish Snap (Crimson)", group=grp_style)
color_watch = input.color(#D4AF37, "Watch Marker (Gold)", group=grp_style)
color_neut = input.color(#535C68, "Neutral (Graphite)", group=grp_style)

// ========================================================================= //
// --- Logic: QStick Pressure ---
// ========================================================================= //
qstick = ta.sma(close - open, qstick_len)
qstick_bull = qstick > 0 and qstick > nz(qstick[1])
qstick_bear = qstick < 0 and qstick < nz(qstick[1])

// ========================================================================= //
// --- Logic: Elder Force Index (EFI) ---
// ========================================================================= //
efi_raw = (close - nz(close[1])) * volume
efi = ta.ema(efi_raw, efi_len)
efi_bull = efi > 0
efi_bear = efi < 0

// ========================================================================= //
// --- Logic: Ulcer Index (Stress) ---
// ========================================================================= //
highest_c = ta.highest(close, ui_len)
lowest_c = ta.lowest(close, ui_len)

dd_down = highest_c == 0 ? 0 : 100 * (close - highest_c) / highest_c
dd_up = lowest_c == 0 ? 0 : 100 * (close - lowest_c) / lowest_c

ui_down = math.sqrt(ta.sma(dd_down * dd_down, ui_len))
ui_up = math.sqrt(ta.sma(dd_up * dd_up, ui_len))

ui_down_relax = ui_down <= nz(ui_down[1])
ui_up_relax = ui_up <= nz(ui_up[1])

// ========================================================================= //
// --- Logic: Wick Rejection ---
// ========================================================================= //
body = math.abs(close - open)
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low

// Use a tiny minimum body to prevent division by zero
eff_body = body == 0 ? syminfo.mintick : body

rej_bull = (lower_wick / eff_body) >= wick_mult
rej_bear = (upper_wick / eff_body) >= wick_mult

// ========================================================================= //
// --- Scoring & Signals ---
// ========================================================================= //
bull_watch_cond = rej_bull and qstick_bull
bear_watch_cond = rej_bear and qstick_bear

bull_snap = bull_watch_cond and efi_bull and ui_down_relax
bear_snap = bear_watch_cond and efi_bear and ui_up_relax

var int last_bull = 0
var int last_bear = 0
if bull_snap
    last_bull := bar_index
if bear_snap
    last_bear := bar_index

cooldown_ok_bull = (bar_index - nz(last_bull[1]) > cooldown_bars)
cooldown_ok_bear = (bar_index - nz(last_bear[1]) > cooldown_bars)

bull_valid = bull_snap and cooldown_ok_bull
bear_valid = bear_snap and cooldown_ok_bear

// ========================================================================= //
// --- Visuals ---
// ========================================================================= //
atr_val = ta.atr(14)
longWatchPrice = low - atr_val * atr_offset * 0.5
shortWatchPrice = high + atr_val * atr_offset * 0.5
longSignalPrice = low - atr_val * atr_offset
shortSignalPrice = high + atr_val * atr_offset

// Using native plot() to ensure strict price-scale locking
plot(show_watch and bull_watch_cond and not bull_valid ? longWatchPrice : na, "Bull Watch", color=color.new(color_watch, 20), style=plot.style_circles, linewidth=2)
plot(show_watch and bear_watch_cond and not bear_valid ? shortWatchPrice : na, "Bear Watch", color=color.new(color_watch, 20), style=plot.style_circles, linewidth=2)

plot(show_signals and bull_valid ? longSignalPrice : na, "Bull Snap", color=color.new(color_bull, 0), style=plot.style_cross, linewidth=3)
plot(show_signals and bear_valid ? shortSignalPrice : na, "Bear Snap", color=color.new(color_bear, 0), style=plot.style_cross, linewidth=3)

barcolor(bull_valid ? color.new(color_bull, 20) : bear_valid ? color.new(color_bear, 20) : na)

// ========================================================================= //
// --- Dashboard ---
// ========================================================================= //
var string last_snap_str = "None"
if bull_snap
    last_snap_str := "Bullish"
else if bear_snap
    last_snap_str := "Bearish"

if show_dash and barstate.islast
    var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(#111111, dash_transp), border_width=1, border_color=color.new(color_neut, 50))
    
    // Header
    table.cell(dash, 0, 0, "WSP [ZOM]", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "Status", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_right)
    
    // QStick
    qs_str = qstick > 0 ? "Positive" : "Negative"
    qs_col = qstick > 0 ? color_bull : color_bear
    table.cell(dash, 0, 1, "QStick Pressure", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, qs_str, text_color=qs_col, text_size=size.small, text_halign=text.align_right)
    
    // EFI Force
    efi_str = efi > 0 ? "Bullish" : "Bearish"
    efi_col = efi > 0 ? color_bull : color_bear
    table.cell(dash, 0, 2, "EFI Force", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, efi_str, text_color=efi_col, text_size=size.small, text_halign=text.align_right)
    
    // UI Stress
    stress_str = (ui_down > ui_up) ? "Downside" : "Upside"
    stress_col = (ui_down > ui_up) ? color_bear : color_bull
    table.cell(dash, 0, 3, "UI Stress Bias", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, stress_str, text_color=stress_col, text_size=size.small, text_halign=text.align_right)
    
    // Last Snap
    snap_col = last_snap_str == "Bullish" ? color_bull : last_snap_str == "Bearish" ? color_bear : color.new(color_neut, 0)
    table.cell(dash, 0, 4, "Recent Snap", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, last_snap_str, text_color=snap_col, text_size=size.small, text_halign=text.align_right)
    
    // Overall Bias
    bias_score = (qstick > 0 ? 1 : -1) + (efi > 0 ? 1 : -1) + (ui_down_relax ? 1 : -1)
    bias_str = bias_score >= 1 ? "Bullish" : bias_score <= -1 ? "Bearish" : "Neutral"
    bias_col2 = bias_score >= 1 ? color_bull : bias_score <= -1 ? color_bear : color_watch
    table.cell(dash, 0, 5, "Composite Bias", text_color=color.new(color_neut, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, bias_str, text_color=bias_col2, text_size=size.small, text_halign=text.align_right)

// ========================================================================= //
// --- Alerts ---
// ========================================================================= //
alertcondition(bull_watch_cond, "WSP Bull Watch", "Wick Snap Pressure: Bullish Watch Setup [ZOM]")
alertcondition(bear_watch_cond, "WSP Bear Watch", "Wick Snap Pressure: Bearish Watch Setup [ZOM]")
alertcondition(bull_valid, "WSP Bull Snap", "Wick Snap Pressure: Bullish Snap Confirmed [ZOM]")
alertcondition(bear_valid, "WSP Bear Snap", "Wick Snap Pressure: Bearish Snap Confirmed [ZOM]")
````
