# Cadence Reversion Cartography [JOAT]

- url: https://www.tradingview.com/script/Y0lTF7oF-Cadence-Reversion-Cartography-JOAT/
- type: indicator
- pine_id: PUB;a3970008c9ea4cfbb608884f6d2ee321
- version: 1.0

## Description

[b]Cadence Reversion Cartography [JOAT][/b]

[b]Introduction[/b]

Cadence Reversion Cartography is an open-source mean-reversion and exhaustion overlay designed to locate stretched conditions around an EMA envelope and anchored VWAP framework. It focuses on mapping where price has moved too far from local balance, then grades whether a return toward value has enough supporting evidence to matter.

The problem this script solves is selective reversal timing. Price can stay overextended for longer than expected, so simple band-touch logic is not enough. Cadence Reversion Cartography combines envelope stretch, VWAP stretch, RSI exhaustion, volume impulse, rejection-candle behavior, reclaim logic, and projected response boxes so the user can distinguish weak touches from stronger reversion candidates.

[b]Core Concepts[/b]

[b]1. Dual Stretch Model[/b]
Price is compared to both an EMA deviation envelope and an anchored VWAP deviation layer. A long-side exhaustion condition requires price to stretch below both lower references. A short-side exhaustion condition requires price to stretch above both upper references.

[b]2. Exhaustion Quality Filters[/b]
RSI can require oversold or overbought context, volume can require impulse relative to average participation, and candle structure can require a visible rejection profile.

[b]3. Reclaim And Signal Grading[/b]
A setup becomes actionable only after price closes back inside the envelope on a confirmed bar. The script then scores the setup by counting how many filters aligned and promotes stronger signals to a prime grade.

[b]4. Projection Mapping[/b]
When a setup forms, the script can draw a forward projection with a risk box, reward box, signal zone, and reclaim line. This is meant to show the structure of the reversion idea rather than acting as a promise of outcome.

[b]Features[/b]

[list]
[*][b]EMA reversion envelope:[/b] Basis plus statistical deviation bands
[*][b]Anchored VWAP stretch layer:[/b] Secondary value reference around VWAP
[*][b]RSI exhaustion filter:[/b] Optional momentum exhaustion gate
[*][b]Volume impulse filter:[/b] Optional participation confirmation
[*][b]Rejection-candle filter:[/b] Optional candle-structure confirmation
[*][b]Signal grading:[/b] Standard and prime long or short responses
[*][b]Signal zones and reclaim lines:[/b] On-chart response structure around the active setup
[*][b]Risk and reward projection boxes:[/b] Optional forward mapping of stop and target structure
[*][b]Context candle coloring:[/b] Candles can tint with stretch state
[*][b]Dashboard:[/b] Displays stretch, setup bias, and active context
[/list]

[b]Input Parameters[/b]

[b]Reversion Envelope:[/b]
[list]
[*]Channel Length
[*]Deviation Multiplier
[*]VWAP Stretch Multiplier
[/list]

[b]Filters And Display:[/b]
[list]
[*]RSI settings
[*]Volume average and impulse multiplier
[*]Rejection-candle requirement
[*]Projection-box toggle, stop percent, reward multiple, projection length, and signal cooldown
[*]Dashboard, background, candle-color, and signal-zone toggles
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Wait for price to stretch beyond both the EMA envelope and the VWAP stretch layer.
[b]Step 2:[/b] Check whether RSI, volume, and rejection filters support the move.
[b]Step 3:[/b] Wait for confirmed re-entry back inside the envelope instead of fading the first touch.
[b]Step 4:[/b] Use the signal grade and projection structure to judge whether the setup is marginal or stronger.
[b]Step 5:[/b] Use the basis and reclaim line as the first balance reference after entry.

[b]Indicator Limitations[/b]

[list]
[*]Strong directional trends can keep price stretched for extended periods and delay reversion
[*]Volume-based confirmation is less meaningful on symbols with irregular volume reporting
[*]Projection boxes are planning tools, not guaranteed outcomes
[*]This script is designed for reversion analysis and is not intended to replace broader trend context
[/list]

[b]Originality Statement[/b]

Cadence Reversion Cartography is original in how it coordinates envelope stretch, VWAP stretch, filter-based exhaustion grading, and forward projection structure inside one reversion workflow. The components are combined to answer one analytical problem: not just whether price is stretched, but whether the stretch is mature enough to support a structured return toward value.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Reversion setups can fail during strong trends or regime expansion, so all signals should be used with independent confirmation and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Cadence Reversion Cartography [JOAT]", shorttitle="CRC [JOAT]", overlay=true, max_boxes_count=250, max_labels_count=120, max_lines_count=120)

//==============================================================================
// INPUTS
//==============================================================================
grp_channel = "Reversion Envelope"
source_input = input.source(close, "Source", group=grp_channel)
channel_length = input.int(24, "Channel Length", minval=5, group=grp_channel)
channel_deviation = input.float(1.8, "Deviation Multiplier", minval=0.5, step=0.1, group=grp_channel)
vwap_deviation = input.float(1.2, "VWAP Stretch Multiplier", minval=0.2, step=0.1, group=grp_channel)

grp_filters = "Filters"
use_rsi_filter = input.bool(true, "Use RSI Exhaustion Filter", group=grp_filters)
rsi_length = input.int(14, "RSI Length", minval=5, group=grp_filters)
rsi_ob = input.int(68, "RSI Overbought", minval=50, maxval=95, group=grp_filters)
rsi_os = input.int(32, "RSI Oversold", minval=5, maxval=50, group=grp_filters)
use_volume_filter = input.bool(true, "Use Volume Impulse Filter", group=grp_filters)
volume_length = input.int(20, "Volume Average Length", minval=5, group=grp_filters)
volume_multiplier = input.float(1.15, "Volume Impulse Multiplier", minval=0.5, step=0.05, group=grp_filters)
require_rejection = input.bool(true, "Require Rejection Candle", group=grp_filters)

grp_trade = "Projection"
show_projection_boxes = input.bool(true, "Show Projection Boxes", group=grp_trade)
stop_percent = input.float(0.45, "Stop Percent", minval=0.1, step=0.05, group=grp_trade)
reward_multiple = input.float(1.8, "Reward Multiple", minval=0.5, step=0.1, group=grp_trade)
projection_bars = input.int(24, "Projection Length", minval=5, maxval=120, group=grp_trade)
signal_cooldown = input.int(8, "Signal Cooldown Bars", minval=0, maxval=80, group=grp_trade)

grp_visual = "Visuals"
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)
show_background = input.bool(false, "Show Context Background", group=grp_visual)
show_candle_coloring = input.bool(true, "Color Candles", group=grp_visual)
show_signal_zones = input.bool(true, "Show Signal Zones", group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
panel_bg = color.rgb(10, 15, 24)
panel_header = color.rgb(21, 30, 43)
panel_cell = color.rgb(16, 24, 35)
panel_grid = color.rgb(40, 55, 74)
text_main = color.rgb(228, 233, 241)
text_dim = color.rgb(143, 159, 178)

bull_core = color.rgb(0, 211, 146)
bear_core = color.rgb(255, 96, 130)
neutral_core = color.rgb(124, 150, 255)
zone_gold = color.rgb(230, 182, 79)

//==============================================================================
// TYPES
//==============================================================================
type ProjectionRecord
    box reward_box
    box risk_box
    label tag
    int dir
    float stop_level
    float target_level
    bool active

var array<ProjectionRecord> projections = array.new<ProjectionRecord>()
var box latest_signal_zone = na
var line latest_reclaim_line = na

//==============================================================================
// CORE SERIES
//==============================================================================
basis = ta.ema(source_input, channel_length)
deviation = ta.stdev(source_input, channel_length) * channel_deviation
upper_band = basis + deviation
lower_band = basis - deviation

anchored_vwap = ta.vwap(hlc3)
vwap_stretch = ta.stdev(close - anchored_vwap, channel_length) * vwap_deviation
vwap_upper = anchored_vwap + vwap_stretch
vwap_lower = anchored_vwap - vwap_stretch

rsi_value = ta.rsi(close, rsi_length)
volume_average = ta.sma(volume, volume_length)
volume_impulse = volume >= volume_average * volume_multiplier

body_size = math.abs(close - open)
upper_wick = high - math.max(close, open)
lower_wick = math.min(close, open) - low

bull_rejection = close > open and lower_wick > body_size * 1.4 and close > low + (high - low) * 0.55
bear_rejection = close < open and upper_wick > body_size * 1.4 and close < low + (high - low) * 0.45

long_exhausted = low < lower_band and low < vwap_lower
short_exhausted = high > upper_band and high > vwap_upper

rsi_long_ok = not use_rsi_filter or rsi_value <= rsi_os
rsi_short_ok = not use_rsi_filter or rsi_value >= rsi_ob
volume_ok = not use_volume_filter or volume_impulse
rejection_long_ok = not require_rejection or bull_rejection
rejection_short_ok = not require_rejection or bear_rejection

var int last_signal_bar = na
cooldown_clear = na(last_signal_bar) or signal_cooldown == 0 or (bar_index - last_signal_bar) > signal_cooldown

long_setup = barstate.isconfirmed and cooldown_clear and long_exhausted and rsi_long_ok and volume_ok and rejection_long_ok and close > lower_band
short_setup = barstate.isconfirmed and cooldown_clear and short_exhausted and rsi_short_ok and volume_ok and rejection_short_ok and close < upper_band

long_score = (long_exhausted ? 1 : 0) + (rsi_long_ok ? 1 : 0) + (volume_ok ? 1 : 0) + (rejection_long_ok ? 1 : 0) + (close > basis ? 1 : 0)
short_score = (short_exhausted ? 1 : 0) + (rsi_short_ok ? 1 : 0) + (volume_ok ? 1 : 0) + (rejection_short_ok ? 1 : 0) + (close < basis ? 1 : 0)
signal_grade = long_setup ? (long_score >= 5 ? "Prime Long" : "Long") : short_setup ? (short_score >= 5 ? "Prime Short" : "Short") : "None"

//==============================================================================
// VISUAL CONTEXT
//==============================================================================
p_upper = plot(upper_band, "Upper Envelope", color=color.new(bear_core, 62), linewidth=1)
p_lower = plot(lower_band, "Lower Envelope", color=color.new(bull_core, 62), linewidth=1)
p_vwap_upper = plot(vwap_upper, "VWAP Upper", color=color.new(zone_gold, 70), linewidth=1, style=plot.style_line)
p_vwap_lower = plot(vwap_lower, "VWAP Lower", color=color.new(zone_gold, 70), linewidth=1, style=plot.style_line)
plot(basis, "Envelope Basis", color=color.new(neutral_core, 0), linewidth=2)
plot(anchored_vwap, "Anchored VWAP", color=color.new(zone_gold, 0), linewidth=2)

fill(p_upper, p_vwap_upper, color.new(bear_core, 94), title="Upper Reversion Layer")
fill(p_lower, p_vwap_lower, color.new(bull_core, 94), title="Lower Reversion Layer")

context_state = long_exhausted ? 1 : short_exhausted ? -1 : 0
bar_color = context_state == 1 ? color.new(bull_core, 26) : context_state == -1 ? color.new(bear_core, 26) : na
barcolor(show_candle_coloring ? bar_color : na)
bgcolor(show_background ? (context_state == 1 ? color.new(bull_core, 95) : context_state == -1 ? color.new(bear_core, 95) : na) : na)

//==============================================================================
// SIGNAL LABELS
//==============================================================================
var label latest_long = na
var label latest_short = na

if long_setup
    label.delete(latest_long)
    latest_long := label.new(bar_index, low, signal_grade + "\nDemand Response", style=label.style_label_up, color=color.new(bull_core, 10), textcolor=color.black, size=size.small)
    box.delete(latest_signal_zone)
    line.delete(latest_reclaim_line)
    if show_signal_zones
        latest_signal_zone := box.new(bar_index - 1, math.max(high, basis), bar_index + projection_bars / 2, math.min(low, basis), bgcolor=color.new(bull_core, 90), border_color=color.new(bull_core, 35))
        latest_reclaim_line := line.new(bar_index - 1, basis, bar_index + projection_bars / 2, basis, color=color.new(zone_gold, 15), style=line.style_dotted)

if short_setup
    label.delete(latest_short)
    latest_short := label.new(bar_index, high, signal_grade + "\nSupply Response", style=label.style_label_down, color=color.new(bear_core, 10), textcolor=color.black, size=size.small)
    box.delete(latest_signal_zone)
    line.delete(latest_reclaim_line)
    if show_signal_zones
        latest_signal_zone := box.new(bar_index - 1, math.max(high, basis), bar_index + projection_bars / 2, math.min(low, basis), bgcolor=color.new(bear_core, 90), border_color=color.new(bear_core, 35))
        latest_reclaim_line := line.new(bar_index - 1, basis, bar_index + projection_bars / 2, basis, color=color.new(zone_gold, 15), style=line.style_dotted)

//==============================================================================
// PROJECTION BOX ENGINE
//==============================================================================
f_add_projection(_dir) =>
    float entry = close
    float stop = _dir == 1 ? entry * (1 - stop_percent / 100.0) : entry * (1 + stop_percent / 100.0)
    float risk = math.abs(entry - stop)
    float target = _dir == 1 ? entry + risk * reward_multiple : entry - risk * reward_multiple
    box reward_box = na
    box risk_box = na
    if show_projection_boxes
        reward_box := _dir == 1 ? box.new(bar_index, target, bar_index + projection_bars, entry, bgcolor=color.new(bull_core, 82), border_color=color.new(bull_core, 15)) : box.new(bar_index, entry, bar_index + projection_bars, target, bgcolor=color.new(bull_core, 82), border_color=color.new(bull_core, 15))
        risk_box := _dir == 1 ? box.new(bar_index, entry, bar_index + projection_bars, stop, bgcolor=color.new(bear_core, 84), border_color=color.new(bear_core, 15)) : box.new(bar_index, stop, bar_index + projection_bars, entry, bgcolor=color.new(bear_core, 84), border_color=color.new(bear_core, 15))
    label tag = na
    if show_projection_boxes
        tag := label.new(bar_index + 1, entry, _dir == 1 ? "Long Projection" : "Short Projection", style=label.style_label_left, color=color.new(_dir == 1 ? bull_core : bear_core, 8), textcolor=color.black, size=size.tiny)
    ProjectionRecord.new(reward_box, risk_box, tag, _dir, stop, target, true)

f_prune_projections() =>
    while array.size(projections) > 16
        ProjectionRecord record = array.shift(projections)
        if not na(record.reward_box)
            box.delete(record.reward_box)
        if not na(record.risk_box)
            box.delete(record.risk_box)
        if not na(record.tag)
            label.delete(record.tag)

if long_setup
    last_signal_bar := bar_index
    array.push(projections, f_add_projection(1))
    f_prune_projections()

if short_setup
    last_signal_bar := bar_index
    array.push(projections, f_add_projection(-1))
    f_prune_projections()

if array.size(projections) > 0
    for i = array.size(projections) - 1 to 0
        ProjectionRecord record = array.get(projections, i)
        if record.active
            if not na(record.reward_box)
                box.set_right(record.reward_box, bar_index + projection_bars)
            if not na(record.risk_box)
                box.set_right(record.risk_box, bar_index + projection_bars)
            bool done = false
            if record.dir == 1
                done := high >= record.target_level or low <= record.stop_level
            else
                done := low <= record.target_level or high >= record.stop_level
            if done
                record.active := false
                if not na(record.reward_box)
                    box.set_right(record.reward_box, bar_index)
                if not na(record.risk_box)
                    box.set_right(record.risk_box, bar_index)
                array.set(projections, i, record)

//==============================================================================
// METRICS
//==============================================================================
stretch_score = context_state == 1 ? (lower_band - low) + (vwap_lower - low) : context_state == -1 ? (high - upper_band) + (high - vwap_upper) : 0.0
setup_bias = long_setup ? "Long Base" : short_setup ? "Short Base" : context_state == 1 ? "Watching Long" : context_state == -1 ? "Watching Short" : "Balanced"
setup_color = long_setup ? bull_core : short_setup ? bear_core : context_state == 1 ? bull_core : context_state == -1 ? bear_core : neutral_core

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 7, bgcolor=panel_bg, border_width=1, border_color=panel_grid, frame_color=panel_grid, frame_width=1)

f_dash_row(_row, _label, _value, _color, _bg) =>
    table.cell(dash, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, _row, _value, text_color=_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    string volume_state = volume_impulse ? "Impulse" : "Routine"
    string rejection_state = bull_rejection ? "Bull Wick" : bear_rejection ? "Bear Wick" : "None"
    table.cell(dash, 0, 0, "CADENCE REVERSION", text_color=text_main, bgcolor=panel_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, setup_bias, text_color=setup_color, bgcolor=panel_header, text_size=size.small, text_halign=text.align_right)
    f_dash_row(1, "RSI", str.tostring(rsi_value, "#.##"), rsi_value <= rsi_os ? bull_core : rsi_value >= rsi_ob ? bear_core : neutral_core, panel_cell)
    f_dash_row(2, "Volume", volume_state, volume_impulse ? zone_gold : text_dim, panel_bg)
    f_dash_row(3, "Rejection", rejection_state, rejection_state == "Bull Wick" ? bull_core : rejection_state == "Bear Wick" ? bear_core : text_dim, panel_cell)
    f_dash_row(4, "Envelope Width", str.tostring(upper_band - lower_band, format.mintick), neutral_core, panel_bg)
    f_dash_row(5, "Stretch / Grade", str.tostring(stretch_score, format.mintick) + " / " + signal_grade, setup_color, panel_cell)
    f_dash_row(6, "Active Maps", str.tostring(array.size(projections)), text_main, panel_bg)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(long_setup, "Long Reversion Base", "Cadence Reversion Cartography [JOAT] confirmed a long reversion base on {{ticker}} {{interval}}.")
alertcondition(short_setup, "Short Reversion Base", "Cadence Reversion Cartography [JOAT] confirmed a short reversion base on {{ticker}} {{interval}}.")
````
