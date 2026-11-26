# Obsidian Regime Ribbon [JOAT]

- url: https://www.tradingview.com/script/9JMpYr17-Obsidian-Regime-Ribbon-JOAT/
- type: indicator
- pine_id: PUB;866760679be2411789b0267a7601e9c4
- version: 1.0

## Description

[b]Obsidian Regime Ribbon [JOAT][/b]

[b]Introduction[/b]

Obsidian Regime Ribbon is an open-source trend-state and execution-context overlay built to classify directional conditions before a trader applies any separate entry model. Instead of using a single moving average or one oscillator threshold, it combines an adaptive range filter, efficiency ratio, ADX strength, choppiness, momentum confirmation, higher-timeframe bias, and EMA alignment into one chart layer.

The problem this script solves is regime confusion. Traders often apply trend-continuation logic in compression or try fading price while directional participation is still strong. Obsidian Regime Ribbon provides a structured state model with a filtered regime line, layered expansion bands, reclaim signals, stretch tags, execution rails, and a compact dashboard so the user can read whether price is trending cleanly, overextending, or losing sponsorship.

[b]Core Concepts[/b]

[b]1. Adaptive Range Filter[/b]
The central filter line is not a static moving average. It uses ATR distance and an efficiency-ratio-driven multiplier so the filter widens during noisy conditions and tightens when price movement becomes more directional.

[b]2. Multi-Factor Regime Gate[/b]
ADX checks directional strength, choppiness checks compression, momentum confirms directional pressure, higher-timeframe EMA bias provides external context, and EMA spread measures local alignment. These conditions feed a scorecard so the user can separate weak drift from stronger directional structure.

[b]3. Expansion And Reclaim Framework[/b]
Four ATR-derived bands are projected above and below the regime filter. Confirmed regime shifts create labeled accumulation or distribution windows. Pullback reclaim signals print only after price revisits the regime line and closes back through it on a confirmed bar.

[b]4. Execution Rails[/b]
Confirmed shifts and reclaim events create forward execution rails and zones directly on the chart. In bullish conditions they behave as demand rails, and in bearish conditions they behave as supply rails.

[b]Features[/b]

[list]
[*][b]Adaptive regime filter:[/b] ATR-based directional filter with efficiency-ratio adaptation
[*][b]Layered regime bands:[/b] Four expansion bands above and below the filter
[*][b]EMA structure cloud:[/b] Fast and slow structure means with directional fill
[*][b]Confirmed regime shift labels:[/b] Bullish and bearish shifts print only after confirmation
[*][b]Reclaim signals:[/b] Diamond markers when price reclaims the regime line
[*][b]Execution rails:[/b] Demand and supply rails with right-edge price labels
[*][b]Stretch tags:[/b] Labels when price reaches extreme premium or discount relative to the filter
[*][b]Expansion markers:[/b] Additional markers when price pushes through secondary band thresholds
[*][b]State-based candle coloring:[/b] Candle tint changes with regime and score strength
[*][b]Dashboard:[/b] State, conviction, age, ER, ADX, chop, stretch, HTF alignment, and shift counts
[*][b]Confirmed-bar logic:[/b] Regime changes and reclaim signals are designed for confirmed bars only
[/list]

[b]Input Parameters[/b]

[b]Engine:[/b]
[list]
[*]Range Length and Range Multiplier control the core filter sensitivity
[*]Efficiency Length controls how quickly adaptation reacts to directional efficiency
[*]Base Confirm Bars controls how many bars are required before a regime shift is locked
[*]Stretch Threshold defines when a move is considered overextended in ATR terms
[/list]

[b]Filters And Display:[/b]
[list]
[*]ADX, choppiness, momentum, and higher-timeframe controls define the regime gate
[*]Regime band, filter line, candle color, dashboard, execution zone, and stretch tag toggles
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read the current regime from the dashboard and candle state first.
[b]Step 2:[/b] Use the conviction score to decide whether the trend is fully structured or transitional.
[b]Step 3:[/b] Watch regime shift labels to identify when directional control changes.
[b]Step 4:[/b] Use reclaim diamonds and execution rails as retracement reference instead of chasing outer-band extensions.
[b]Step 5:[/b] Treat stretch tags as caution zones where reward-to-risk may deteriorate.

[b]Indicator Limitations[/b]

[list]
[*]Adaptive filters can still lag the first bar of a sharp reversal because confirmation is intentionally delayed
[*]Higher-timeframe alignment can temporarily disagree with local price rotation during early reversals
[*]Stretch conditions do not guarantee reversal; they only identify extended distance from the filter
[*]This script is a context overlay, not a complete trading system by itself
[/list]

[b]Originality Statement[/b]

Obsidian Regime Ribbon is original in the way it combines an adaptive range-state engine, multi-factor regime gate, expansion-band framework, reclaim signals, and forward execution rails into one integrated context overlay. The purpose is not to merge unrelated tools, but to build a single decision layer that explains trend state, extension, and pullback quality together.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Regime, reclaim, and stretch conditions are derived from historical price behavior and do not guarantee future outcomes. Always use independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Obsidian Regime Ribbon [JOAT]", shorttitle="ORR [JOAT]", overlay=true, max_labels_count=300, max_lines_count=200, max_boxes_count=80)

//==============================================================================
// INPUTS
//==============================================================================
grp_engine = "Engine"
engine_source = input.source(close, "Engine Source", group=grp_engine)
range_length = input.int(18, "Range Length", minval=5, group=grp_engine)
range_multiplier = input.float(1.35, "Range Multiplier", minval=0.2, step=0.05, group=grp_engine)
efficiency_length = input.int(14, "Efficiency Length", minval=5, group=grp_engine)
confirm_base = input.int(2, "Base Confirm Bars", minval=1, maxval=6, group=grp_engine)
stretch_atr = input.float(2.6, "Stretch Threshold (ATR)", minval=0.5, step=0.1, group=grp_engine)

grp_filter = "Filters"
use_adx_filter = input.bool(true, "Use ADX Strength Filter", group=grp_filter)
adx_length = input.int(14, "ADX Length", minval=5, group=grp_filter)
adx_floor = input.float(18.0, "ADX Floor", minval=5.0, step=0.5, group=grp_filter)
use_chop_filter = input.bool(true, "Use Choppiness Filter", group=grp_filter)
chop_length = input.int(14, "Choppiness Length", minval=5, group=grp_filter)
chop_ceiling = input.float(61.8, "Choppiness Ceiling", minval=35.0, maxval=80.0, step=0.5, group=grp_filter)
use_momentum_filter = input.bool(true, "Use Momentum Gate", group=grp_filter)
momentum_length = input.int(21, "Momentum Length", minval=5, group=grp_filter)

grp_htf = "Higher Timeframe"
use_htf_bias = input.bool(true, "Use Higher Timeframe Bias", group=grp_htf)
htf_timeframe = input.timeframe("240", "HTF Timeframe", group=grp_htf)
htf_ema_length = input.int(55, "HTF EMA Length", minval=5, group=grp_htf)

grp_visual = "Visuals"
show_regime_bands = input.bool(true, "Show Regime Bands", group=grp_visual)
show_filter_line = input.bool(true, "Show Filter Line", group=grp_visual)
show_shift_labels = input.bool(true, "Show Regime Labels", group=grp_visual)
show_candle_state = input.bool(true, "Color Candles", group=grp_visual)
show_background = input.bool(false, "Show Background Tint", group=grp_visual)
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)
show_signal_blocks = input.bool(true, "Show Signal Blocks", group=grp_visual)
show_execution_zones = input.bool(true, "Show Execution Zones", group=grp_visual)
show_stretch_tags = input.bool(true, "Show Stretch Tags", group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
bg_panel = color.rgb(12, 17, 25)
bg_header = color.rgb(20, 29, 40)
bg_cell = color.rgb(16, 23, 33)
grid_col = color.rgb(42, 55, 74)
text_main = color.rgb(226, 232, 240)
text_dim = color.rgb(142, 158, 176)

bull_core = color.rgb(0, 214, 143)
bull_soft = color.rgb(0, 129, 105)
bear_core = color.rgb(255, 92, 126)
bear_soft = color.rgb(148, 63, 82)
neutral_core = color.rgb(109, 164, 255)
accent_gold = color.rgb(226, 179, 67)
accent_violet = color.rgb(125, 108, 255)

band_bull_1 = color.new(bull_core, 84)
band_bull_2 = color.new(bull_core, 90)
band_bull_3 = color.new(bull_core, 94)
band_bull_4 = color.new(bull_core, 97)

band_bear_1 = color.new(bear_core, 84)
band_bear_2 = color.new(bear_core, 90)
band_bear_3 = color.new(bear_core, 94)
band_bear_4 = color.new(bear_core, 97)

neutral_fill = color.new(accent_violet, 96)

//==============================================================================
// FUNCTIONS
//==============================================================================
f_efficiency_ratio(_source, _length) =>
    float net_move = math.abs(_source - _source[_length])
    float path = 0.0
    for i = 0 to _length - 1
        path += math.abs(_source[i] - _source[i + 1])
    path > 0 ? net_move / path : 0.0

f_manual_adx(_length) =>
    float up_move = high - high[1]
    float down_move = low[1] - low
    float plus_dm = up_move > down_move and up_move > 0 ? up_move : 0.0
    float minus_dm = down_move > up_move and down_move > 0 ? down_move : 0.0
    float tr = ta.atr(1)
    float plus_di = 100 * ta.rma(plus_dm, _length) / ta.rma(tr, _length)
    float minus_di = 100 * ta.rma(minus_dm, _length) / ta.rma(tr, _length)
    float dx = (plus_di + minus_di) > 0 ? math.abs(plus_di - minus_di) / (plus_di + minus_di) * 100 : 0.0
    float adx = ta.rma(dx, _length)
    [adx, plus_di, minus_di]

f_range_state(_source, _atr_length, _multiplier) =>
    float atr_value = ta.atr(_atr_length)
    float buffer = atr_value * _multiplier
    var float filtered = _source
    var int trend = 0
    filtered := _source > filtered + buffer ? _source - buffer : _source < filtered - buffer ? _source + buffer : filtered
    int prior_trend = trend[1]
    trend := filtered > filtered[1] ? 1 : filtered < filtered[1] ? -1 : trend[1]
    int shift = trend != prior_trend ? trend : 0
    [filtered, trend, shift, atr_value]

//==============================================================================
// CORE ENGINE
//==============================================================================
efficiency_raw = f_efficiency_ratio(engine_source, efficiency_length)
efficiency = ta.ema(efficiency_raw, 3)

adaptive_confirm = efficiency < 0.22 ? math.max(confirm_base + 2, 4) : efficiency < 0.42 ? confirm_base + 1 : efficiency < 0.68 ? confirm_base : math.max(confirm_base - 1, 1)
adaptive_range_mult = range_multiplier * (efficiency < 0.25 ? 1.15 : efficiency > 0.70 ? 0.85 : 1.0)

[regime_filter, raw_trend, raw_shift, atr_value] = f_range_state(engine_source, range_length, adaptive_range_mult)

float regime_distance_atr = atr_value > 0 ? math.abs(close - regime_filter) / atr_value : 0.0
bool regime_stretched = regime_distance_atr >= stretch_atr

//==============================================================================
// REGIME LOCKING
//==============================================================================
var int locked_trend = 0
var int trend_age = 0
var int candidate_count = 0
var int long_shift_count = 0
var int short_shift_count = 0
var box active_signal_block = na
var label active_status_label = na
var box active_execution_zone = na
var line active_execution_line = na
var label active_execution_label = na
var label active_stretch_label = na

if barstate.isfirst
    locked_trend := raw_trend == 0 ? 1 : raw_trend

candidate_count := raw_trend != locked_trend ? candidate_count + 1 : 0
bool confirmed_shift = candidate_count >= adaptive_confirm and raw_trend != locked_trend and raw_trend != 0 and barstate.isconfirmed

if confirmed_shift
    locked_trend := raw_trend
    trend_age := 0
    candidate_count := 0
    if locked_trend == 1
        long_shift_count += 1
    if locked_trend == -1
        short_shift_count += 1
else
    trend_age += 1

//==============================================================================
// FILTER STACK
//==============================================================================
[adx_value, plus_di, minus_di] = f_manual_adx(adx_length)
adx_clear = not use_adx_filter or adx_value >= adx_floor

chop_range = ta.highest(high, chop_length) - ta.lowest(low, chop_length)
chop_sum = math.sum(ta.atr(1), chop_length)
chop_value = chop_range > 0 ? 100 * math.log10(chop_sum / chop_range) / math.log10(chop_length) : 50.0
chop_clear = not use_chop_filter or chop_value <= chop_ceiling

momentum_line = ta.ema(close - close[momentum_length], int(math.max(3, math.floor(momentum_length / 3))))
momentum_bull = momentum_line > 0
momentum_bear = momentum_line < 0
momentum_clear = not use_momentum_filter or (locked_trend == 1 ? momentum_bull : momentum_bear)

htf_close = request.security(syminfo.tickerid, htf_timeframe, close[1], lookahead=barmerge.lookahead_on)
htf_ema = request.security(syminfo.tickerid, htf_timeframe, ta.ema(close, htf_ema_length)[1], lookahead=barmerge.lookahead_on)
htf_bias = htf_close > htf_ema ? 1 : -1
htf_clear = not use_htf_bias or htf_bias == locked_trend

gate_open = adx_clear and chop_clear and momentum_clear and htf_clear

//==============================================================================
// SCORECARD
//==============================================================================
ema_fast = ta.ema(close, 21)
ema_slow = ta.ema(close, 55)
ema_state = ema_fast > ema_slow ? 1 : -1
ema_alignment = ema_state == locked_trend
ema_spread = math.abs(ema_fast - ema_slow)

score = 0
score += gate_open ? 2 : 0
score += ema_alignment ? 1 : 0
score += (locked_trend == 1 and plus_di > minus_di) or (locked_trend == -1 and minus_di > plus_di) ? 1 : 0
score += regime_stretched ? 0 : 1
score += efficiency > 0.55 ? 1 : 0

score_text = score >= 5 ? "Institutional" : score >= 3 ? "Structured" : "Transitional"
score_color = score >= 5 ? bull_core : score >= 3 ? accent_gold : text_dim
if locked_trend == -1 and score >= 5
    score_color := bear_core

//==============================================================================
// VISUAL FRAMEWORK
//==============================================================================
filter_color = locked_trend == 1 ? bull_core : bear_core
filter_plot = plot(show_filter_line ? regime_filter : na, "Regime Filter", color=filter_color, linewidth=2)
p_fast = plot(show_regime_bands ? ema_fast : na, "Fast Structure Mean", color=color.new(locked_trend == 1 ? bull_core : bear_core, 35), linewidth=1)
p_slow = plot(show_regime_bands ? ema_slow : na, "Slow Structure Mean", color=color.new(accent_violet, 55), linewidth=1)
fill(p_fast, p_slow, color.new(locked_trend == 1 ? bull_core : bear_core, 90), title="Structure Mean Cloud")

band_width = atr_value * adaptive_range_mult
band_1_up = regime_filter + band_width * 0.25
band_2_up = regime_filter + band_width * 0.50
band_3_up = regime_filter + band_width * 0.75
band_4_up = regime_filter + band_width * 1.00

band_1_dn = regime_filter - band_width * 0.25
band_2_dn = regime_filter - band_width * 0.50
band_3_dn = regime_filter - band_width * 0.75
band_4_dn = regime_filter - band_width * 1.00

p_b1u = plot(show_regime_bands ? band_1_up : na, "Upper 1", color=color(na), display=display.none)
p_b2u = plot(show_regime_bands ? band_2_up : na, "Upper 2", color=color(na), display=display.none)
p_b3u = plot(show_regime_bands ? band_3_up : na, "Upper 3", color=color(na), display=display.none)
p_b4u = plot(show_regime_bands ? band_4_up : na, "Upper 4", color=color(na), display=display.none)
p_b1d = plot(show_regime_bands ? band_1_dn : na, "Lower 1", color=color(na), display=display.none)
p_b2d = plot(show_regime_bands ? band_2_dn : na, "Lower 2", color=color(na), display=display.none)
p_b3d = plot(show_regime_bands ? band_3_dn : na, "Lower 3", color=color(na), display=display.none)
p_b4d = plot(show_regime_bands ? band_4_dn : na, "Lower 4", color=color(na), display=display.none)

fill(filter_plot, p_b1u, locked_trend == 1 ? band_bull_1 : neutral_fill)
fill(p_b1u, p_b2u, locked_trend == 1 ? band_bull_2 : neutral_fill)
fill(p_b2u, p_b3u, locked_trend == 1 ? band_bull_3 : neutral_fill)
fill(p_b3u, p_b4u, locked_trend == 1 ? band_bull_4 : neutral_fill)

fill(filter_plot, p_b1d, locked_trend == -1 ? band_bear_1 : neutral_fill)
fill(p_b1d, p_b2d, locked_trend == -1 ? band_bear_2 : neutral_fill)
fill(p_b2d, p_b3d, locked_trend == -1 ? band_bear_3 : neutral_fill)
fill(p_b3d, p_b4d, locked_trend == -1 ? band_bear_4 : neutral_fill)

bar_tint = locked_trend == 1 ? color.new(bull_core, 62 - math.min(score * 8, 32)) : color.new(bear_core, 62 - math.min(score * 8, 32))
barcolor(show_candle_state ? bar_tint : na)

bgcolor(show_background ? (locked_trend == 1 ? color.new(bull_core, 95) : color.new(bear_core, 95)) : na)

//==============================================================================
// LABELS
//==============================================================================
var label shift_label = na

if confirmed_shift and show_shift_labels
    label.delete(shift_label)
    string shift_text = locked_trend == 1 ? "Regime Shift\nAccumulation Bias" : "Regime Shift\nDistribution Bias"
    float shift_y = locked_trend == 1 ? low : high
    shift_label := label.new(bar_index, shift_y, shift_text, style=locked_trend == 1 ? label.style_label_up : label.style_label_down, color=color.new(filter_color, 8), textcolor=color.black, size=size.small)
    box.delete(active_signal_block)
    label.delete(active_status_label)
    if show_signal_blocks
        float block_top = locked_trend == 1 ? math.max(high, regime_filter + atr_value * 0.35) : high + atr_value * 0.35
        float block_bottom = locked_trend == 1 ? low - atr_value * 0.35 : math.min(low, regime_filter - atr_value * 0.35)
        active_signal_block := box.new(bar_index - 1, block_top, bar_index + 10, block_bottom, bgcolor=color.new(filter_color, 88), border_color=color.new(filter_color, 30))
        active_status_label := label.new(bar_index + 10, locked_trend == 1 ? block_bottom : block_top, locked_trend == 1 ? "Accumulation Window" : "Distribution Window", style=label.style_label_left, color=color.new(filter_color, 8), textcolor=color.black, size=size.tiny)

pullback_long = barstate.isconfirmed and locked_trend == 1 and gate_open and low <= regime_filter and close > regime_filter and ema_alignment
pullback_short = barstate.isconfirmed and locked_trend == -1 and gate_open and high >= regime_filter and close < regime_filter and ema_alignment

plotshape(pullback_long, title="Bull Reclaim", style=shape.diamond, location=location.belowbar, color=color.new(bull_core, 0), size=size.tiny)
plotshape(pullback_short, title="Bear Reclaim", style=shape.diamond, location=location.abovebar, color=color.new(bear_core, 0), size=size.tiny)

if confirmed_shift and show_execution_zones
    box.delete(active_execution_zone)
    line.delete(active_execution_line)
    label.delete(active_execution_label)
    float zone_top = locked_trend == 1 ? regime_filter + atr_value * 0.90 : regime_filter + atr_value * 0.35
    float zone_bottom = locked_trend == 1 ? regime_filter - atr_value * 0.35 : regime_filter - atr_value * 0.90
    active_execution_zone := box.new(bar_index - 1, zone_top, bar_index + 14, zone_bottom, bgcolor=color.new(filter_color, 90), border_color=color.new(filter_color, 35))
    active_execution_line := line.new(bar_index - 1, regime_filter, bar_index + 14, regime_filter, color=color.new(filter_color, 15), width=2)
    active_execution_label := label.new(bar_index + 14, regime_filter, (locked_trend == 1 ? "Demand Rail  " : "Supply Rail  ") + str.tostring(regime_filter, format.mintick), style=label.style_label_left, color=color.new(filter_color, 6), textcolor=color.black, size=size.tiny)

if pullback_long and show_execution_zones
    box.delete(active_execution_zone)
    line.delete(active_execution_line)
    label.delete(active_execution_label)
    active_execution_zone := box.new(bar_index - 2, math.max(high, regime_filter + atr_value * 0.55), bar_index + 10, math.min(low, regime_filter - atr_value * 0.15), bgcolor=color.new(bull_core, 90), border_color=color.new(bull_core, 35))
    active_execution_line := line.new(bar_index - 2, regime_filter, bar_index + 10, regime_filter, color=color.new(bull_core, 12), width=2)
    active_execution_label := label.new(bar_index + 10, regime_filter, "Reclaim Rail  " + str.tostring(regime_filter, format.mintick), style=label.style_label_left, color=color.new(bull_core, 5), textcolor=color.black, size=size.tiny)

if pullback_short and show_execution_zones
    box.delete(active_execution_zone)
    line.delete(active_execution_line)
    label.delete(active_execution_label)
    active_execution_zone := box.new(bar_index - 2, math.max(high, regime_filter + atr_value * 0.15), bar_index + 10, math.min(low, regime_filter - atr_value * 0.55), bgcolor=color.new(bear_core, 90), border_color=color.new(bear_core, 35))
    active_execution_line := line.new(bar_index - 2, regime_filter, bar_index + 10, regime_filter, color=color.new(bear_core, 12), width=2)
    active_execution_label := label.new(bar_index + 10, regime_filter, "Reclaim Rail  " + str.tostring(regime_filter, format.mintick), style=label.style_label_left, color=color.new(bear_core, 5), textcolor=color.black, size=size.tiny)

stretch_long = show_stretch_tags and barstate.isconfirmed and locked_trend == 1 and regime_stretched and high >= band_4_up
stretch_short = show_stretch_tags and barstate.isconfirmed and locked_trend == -1 and regime_stretched and low <= band_4_dn

if stretch_long
    label.delete(active_stretch_label)
    active_stretch_label := label.new(bar_index, high, "Stretch Premium\n" + str.tostring(regime_distance_atr, "#.##") + " ATR", style=label.style_label_down, color=color.new(accent_gold, 8), textcolor=color.black, size=size.tiny)

if stretch_short
    label.delete(active_stretch_label)
    active_stretch_label := label.new(bar_index, low, "Stretch Discount\n" + str.tostring(regime_distance_atr, "#.##") + " ATR", style=label.style_label_up, color=color.new(accent_gold, 8), textcolor=color.black, size=size.tiny)

plotshape(gate_open and locked_trend == 1 and close > band_2_up and close[1] <= band_2_up, title="Bull Expansion", style=shape.square, location=location.abovebar, color=color.new(bull_core, 8), size=size.tiny)
plotshape(gate_open and locked_trend == -1 and close < band_2_dn and close[1] >= band_2_dn, title="Bear Expansion", style=shape.square, location=location.belowbar, color=color.new(bear_core, 8), size=size.tiny)

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 8, bgcolor=bg_panel, border_width=1, border_color=grid_col, frame_color=grid_col, frame_width=1)

f_row(_table, _row, _label, _value, _value_color, _bg) =>
    table.cell(_table, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(_table, 1, _row, _value, text_color=_value_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    table.cell(dash, 0, 0, "OBSIDIAN REGIME", text_color=text_main, bgcolor=bg_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, locked_trend == 1 ? "BULL" : "BEAR", text_color=filter_color, bgcolor=bg_header, text_size=size.small, text_halign=text.align_right)
    f_row(dash, 1, "State", gate_open ? "Open" : "Restricted", gate_open ? accent_gold : text_dim, bg_cell)
    f_row(dash, 2, "Conviction", score_text, score_color, bg_panel)
    f_row(dash, 3, "Age", str.tostring(trend_age) + " bars", text_main, bg_cell)
    f_row(dash, 4, "ER / ADX", str.tostring(efficiency, "#.##") + " / " + str.tostring(adx_value, "#.#"), efficiency > 0.55 ? accent_gold : text_dim, bg_panel)
    f_row(dash, 5, "Chop / Stretch", str.tostring(chop_value, "#.#") + " / " + str.tostring(regime_distance_atr, "#.##") + " ATR", regime_stretched ? bear_core : text_main, bg_cell)
    f_row(dash, 6, "HTF / EMA", (htf_clear ? "Aligned" : "Offside") + " / " + (ema_alignment ? "Aligned" : "Offside"), htf_clear and ema_alignment ? bull_core : accent_gold, bg_panel)
    f_row(dash, 7, "Shifts / Spread", str.tostring(long_shift_count) + " / " + str.tostring(short_shift_count) + "  " + str.tostring(ema_spread, format.mintick), text_main, bg_cell)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(confirmed_shift and locked_trend == 1, "Bullish Regime Shift", "Obsidian Regime Ribbon [JOAT] confirmed a bullish regime shift on {{ticker}} {{interval}}.")
alertcondition(confirmed_shift and locked_trend == -1, "Bearish Regime Shift", "Obsidian Regime Ribbon [JOAT] confirmed a bearish regime shift on {{ticker}} {{interval}}.")
alertcondition(confirmed_shift, "Any Regime Shift", "Obsidian Regime Ribbon [JOAT] confirmed a regime shift on {{ticker}} {{interval}}.")
alertcondition(pullback_long, "Bullish Reclaim", "Obsidian Regime Ribbon [JOAT] confirmed a bullish reclaim of the regime filter on {{ticker}} {{interval}}.")
alertcondition(pullback_short, "Bearish Reclaim", "Obsidian Regime Ribbon [JOAT] confirmed a bearish reclaim of the regime filter on {{ticker}} {{interval}}.")
````
