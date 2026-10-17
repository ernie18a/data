# Vesper Divergence Cascade [JOAT]

- url: https://www.tradingview.com/script/aPgFUt8O-Vesper-Divergence-Cascade-JOAT/
- type: indicator
- pine_id: PUB;3be443b8c9984517b34a1ed08545a114
- version: 1.0

## Description

[b]Vesper Divergence Cascade [JOAT][/b]

[b]Introduction[/b]

Vesper Divergence Cascade is an open-source divergence and response-structure overlay built around RSI pivots and a smoothed T3 ribbon. It detects regular and hidden bullish or bearish divergence, then maps the likely response area with projected zones, corridors, and target guides directly on the chart.

The problem this script solves is incomplete divergence analysis. Many divergence tools draw a line and stop there. That leaves the user without context about whether the move is aligned with local structure, whether the divergence developed in an overbought or oversold condition, and where price might respond if the divergence matters. Vesper Divergence Cascade adds that missing structure.

[b]Core Concepts[/b]

[b]1. Pivot-Based Divergence Detection[/b]
Confirmed price pivots are stored alongside the RSI value that existed at the pivot bar. This allows the script to compare current and prior pivot pairs without relying on unstable future references. Regular and hidden divergence types are evaluated independently on both highs and lows.

[b]2. Ribbon Context Filter[/b]
The T3 ribbon acts as a directional and location filter. Divergence can optionally require price to be extended beyond the ribbon in the direction of the stretch before the event is accepted.

[b]3. Response Zones And Corridors[/b]
When a divergence confirms, the script can project a response zone, midpoint line, reaction corridor, and target line forward from the pivot area. This turns divergence from a simple signal marker into a structured response map.

[b]4. Signal Quality Context[/b]
The script uses RSI delta, ATR-normalized price displacement, cooldown logic, and optional overbought or oversold context to grade whether a divergence is meaningful enough to display.

[b]Features[/b]

[list]
[*][b]Regular bullish and bearish divergence:[/b] Reversal-oriented pivot disagreement
[*][b]Hidden bullish and bearish divergence:[/b] Continuation-oriented pivot disagreement
[*][b]T3 ribbon filter:[/b] Smoothed directional context layer
[*][b]Reaction envelopes:[/b] Premium and discount response bands around ribbon center
[*][b]Response zones:[/b] Forward areas projected from the active divergence
[*][b]Reaction corridors:[/b] Larger projected path zones for follow-through context
[*][b]Target lines:[/b] Simple objective guides derived from ATR structure
[*][b]Signal labels:[/b] On-chart labels with response type and quality readout
[*][b]Pivot dots and reset markers:[/b] Optional event markers for visibility
[*][b]Dashboard:[/b] Displays RSI, zone state, ribbon state, cooldown, and active signal
[*][b]Confirmed pivots only:[/b] Divergence prints only after pivot confirmation
[/list]

[b]Input Parameters[/b]

[b]RSI Core And Divergence:[/b]
[list]
[*]RSI source and length
[*]Overbought and oversold levels
[*]Pivot length and divergence window
[*]Regular and hidden divergence toggles
[/list]

[b]Quality And Display:[/b]
[list]
[*]Signal cooldown
[*]Minimum RSI delta
[*]Minimum ATR move
[*]Extreme-condition requirement
[*]Ribbon-filter requirement
[*]Ribbon, pivot dots, dashboard, response zone, signal label, and reaction corridor toggles
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether the latest signal is regular or hidden, because they imply different response behavior.
[b]Step 2:[/b] Check whether the signal formed in overbought or oversold context and whether the ribbon was supportive.
[b]Step 3:[/b] Use the response zone and corridor as a framework for how price may react rather than as a guaranteed destination.
[b]Step 4:[/b] Use reset markers to track whether momentum is rebalancing after the divergence.
[b]Step 5:[/b] Prefer divergence that forms after visible extension, not in flat neutral conditions.

[b]Indicator Limitations[/b]

[list]
[*]Pivot confirmation introduces intentional delay because divergence is only known after the pivot is confirmed
[*]Divergence can persist or fail completely during strong trends
[*]Hidden divergence is continuation-oriented and should not be interpreted the same way as regular divergence
[*]Projected zones and targets are analytical guides, not forecasts
[/list]

[b]Originality Statement[/b]

Vesper Divergence Cascade is original in how it combines pivot-stored RSI divergence, a T3 ribbon context filter, response envelopes, projected zones, and reaction corridors inside one divergence workflow. The script is designed to explain what kind of divergence formed, where it formed, and how price may structurally respond afterward.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Divergence is a contextual tool and can fail repeatedly during persistent trends, so all use should include independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Vesper Divergence Cascade [JOAT]", shorttitle="VDC [JOAT]", overlay=true, max_lines_count=300, max_labels_count=260, max_boxes_count=120)

//==============================================================================
// INPUTS
//==============================================================================
grp_rsi = "RSI Core"
rsi_source = input.source(close, "RSI Source", group=grp_rsi)
rsi_length = input.int(21, "RSI Length", minval=5, group=grp_rsi)
ob_level = input.int(74, "Overbought", minval=50, maxval=95, group=grp_rsi)
os_level = input.int(26, "Oversold", minval=5, maxval=50, group=grp_rsi)

grp_div = "Divergence"
pivot_length = input.int(3, "Pivot Length", minval=2, maxval=10, group=grp_div)
divergence_window = input.int(80, "Max Pivot Distance", minval=10, maxval=200, group=grp_div)
show_regular = input.bool(true, "Show Regular Divergences", group=grp_div)
show_hidden = input.bool(true, "Show Hidden Divergences", group=grp_div)

grp_quality = "Quality Gates"
cooldown_bars = input.int(10, "Signal Cooldown", minval=0, maxval=100, group=grp_quality)
minimum_rsi_delta = input.float(5.0, "Minimum RSI Delta", minval=0.0, step=0.5, group=grp_quality)
minimum_move_atr = input.float(0.35, "Minimum Price Move (ATR)", minval=0.0, step=0.05, group=grp_quality)
require_extremes = input.bool(true, "Require OB/OS Context", group=grp_quality)
require_ribbon_filter = input.bool(true, "Require Ribbon Filter", group=grp_quality)

grp_ribbon = "Ribbon Filter"
ribbon_fast = input.int(13, "Fast T3 Length", minval=3, group=grp_ribbon)
ribbon_mid = input.int(21, "Mid T3 Length", minval=5, group=grp_ribbon)
ribbon_slow = input.int(34, "Slow T3 Length", minval=8, group=grp_ribbon)
ribbon_factor = input.float(0.62, "T3 Factor", minval=0.1, maxval=0.9, step=0.01, group=grp_ribbon)

grp_visual = "Visuals"
show_ribbon = input.bool(true, "Show Ribbon", group=grp_visual)
show_pivot_dots = input.bool(true, "Show Pivot Dots", group=grp_visual)
show_dashboard = input.bool(true, "Show Dashboard", group=grp_visual)
show_response_zones = input.bool(true, "Show Response Zones", group=grp_visual)
show_signal_labels = input.bool(true, "Show Signal Labels", group=grp_visual)
show_reaction_corridors = input.bool(true, "Show Reaction Corridors", group=grp_visual)

//==============================================================================
// PALETTE
//==============================================================================
panel_bg = color.rgb(10, 16, 24)
panel_header = color.rgb(21, 31, 42)
panel_cell = color.rgb(16, 24, 35)
panel_grid = color.rgb(40, 56, 74)
text_main = color.rgb(228, 234, 241)
text_dim = color.rgb(144, 160, 178)

bull_core = color.rgb(0, 215, 147)
bear_core = color.rgb(255, 96, 129)
neutral_core = color.rgb(124, 152, 255)
hidden_bull = color.rgb(91, 221, 255)
hidden_bear = color.rgb(255, 179, 94)
accent_gold = color.rgb(228, 183, 84)

//==============================================================================
// HELPERS
//==============================================================================
f_t3(_source, _length, _factor) =>
    e1 = ta.ema(_source, _length)
    e2 = ta.ema(e1, _length)
    e3 = ta.ema(e2, _length)
    e4 = ta.ema(e3, _length)
    e5 = ta.ema(e4, _length)
    e6 = ta.ema(e5, _length)
    c1 = -_factor * _factor * _factor
    c2 = 3.0 * _factor * _factor + 3.0 * _factor * _factor * _factor
    c3 = -6.0 * _factor * _factor - 3.0 * _factor - 3.0 * _factor * _factor * _factor
    c4 = 1.0 + 3.0 * _factor + _factor * _factor * _factor + 3.0 * _factor * _factor
    c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3

f_prune(_lines, _labels) =>
    while array.size(_lines) > 80
        line old_line = array.shift(_lines)
        line.delete(old_line)
    while array.size(_labels) > 80
        label old_label = array.shift(_labels)
        label.delete(old_label)

f_draw_signal(_lines, _labels, _bar1, _price1, _bar2, _price2, _text, _line_color, _is_hidden) =>
    line_style = _is_hidden ? line.style_dashed : line.style_solid
    line shadow = line.new(_bar1, _price1, _bar2, _price2, color=color.new(color.black, 0), width=4, style=line_style)
    line core = line.new(_bar1, _price1, _bar2, _price2, color=_line_color, width=2, style=line_style)
    label lb = label.new(_bar2, _price2, _text, style=label.style_label_left, color=color.new(_line_color, 8), textcolor=color.black, size=size.tiny)
    array.push(_lines, shadow)
    array.push(_lines, core)
    array.push(_labels, lb)
    f_prune(_lines, _labels)

//==============================================================================
// CORE SERIES
//==============================================================================
rsi_value = ta.rsi(rsi_source, rsi_length)
atr_value = ta.atr(14)

t3_fast = f_t3(hlc3, ribbon_fast, ribbon_factor)
t3_mid = f_t3(hlc3, ribbon_mid, ribbon_factor)
t3_slow = f_t3(hlc3, ribbon_slow, ribbon_factor)
ribbon_upper = math.max(math.max(t3_fast, t3_mid), t3_slow)
ribbon_lower = math.min(math.min(t3_fast, t3_mid), t3_slow)
ribbon_center = (t3_fast + t3_mid + t3_slow) / 3.0
ribbon_state = ribbon_center > ribbon_center[2] ? 1 : ribbon_center < ribbon_center[2] ? -1 : 0
ribbon_color = ribbon_state == 1 ? bull_core : ribbon_state == -1 ? bear_core : neutral_core
response_upper = ribbon_center + atr_value * 0.40
response_lower = ribbon_center - atr_value * 0.40
response_premium = ribbon_center + atr_value * 0.85
response_discount = ribbon_center - atr_value * 0.85

p_upper = plot(show_ribbon ? ribbon_upper : na, "Ribbon Upper", color=color.new(ribbon_color, 72), linewidth=1)
p_lower = plot(show_ribbon ? ribbon_lower : na, "Ribbon Lower", color=color.new(ribbon_color, 72), linewidth=1)
p_response_upper = plot(show_ribbon ? response_upper : na, "Response Upper", color=color.new(bear_core, 88), linewidth=1)
p_response_lower = plot(show_ribbon ? response_lower : na, "Response Lower", color=color.new(bull_core, 88), linewidth=1)
p_response_premium = plot(show_ribbon ? response_premium : na, "Premium Envelope", color=color.new(hidden_bear, 92), linewidth=1)
p_response_discount = plot(show_ribbon ? response_discount : na, "Discount Envelope", color=color.new(hidden_bull, 92), linewidth=1)
fill(p_upper, p_lower, color.new(ribbon_color, 90), title="Ribbon Fill")
fill(p_upper, p_response_upper, color.new(bear_core, 94), title="Upper Reaction Fill")
fill(p_lower, p_response_lower, color.new(bull_core, 94), title="Lower Reaction Fill")
fill(p_response_upper, p_response_premium, color.new(hidden_bear, 96), title="Premium Fill")
fill(p_response_lower, p_response_discount, color.new(hidden_bull, 96), title="Discount Fill")
plot(show_ribbon ? ribbon_center : na, "Ribbon Center", color=ribbon_color, linewidth=2)

//==============================================================================
// PIVOT STORAGE
//==============================================================================
price_pivot_high = ta.pivothigh(high, pivot_length, pivot_length)
price_pivot_low = ta.pivotlow(low, pivot_length, pivot_length)

var float[] high_prices = array.new_float()
var int[] high_bars = array.new_int()
var float[] high_rsi_vals = array.new_float()
var float[] low_prices = array.new_float()
var int[] low_bars = array.new_int()
var float[] low_rsi_vals = array.new_float()

if not na(price_pivot_high)
    array.push(high_prices, price_pivot_high)
    array.push(high_bars, bar_index - pivot_length)
    array.push(high_rsi_vals, rsi_value[pivot_length])
    if array.size(high_prices) > 12
        array.shift(high_prices)
        array.shift(high_bars)
        array.shift(high_rsi_vals)

if not na(price_pivot_low)
    array.push(low_prices, price_pivot_low)
    array.push(low_bars, bar_index - pivot_length)
    array.push(low_rsi_vals, rsi_value[pivot_length])
    if array.size(low_prices) > 12
        array.shift(low_prices)
        array.shift(low_bars)
        array.shift(low_rsi_vals)

//==============================================================================
// DRAW STATE
//==============================================================================
var line[] drawn_lines = array.new_line()
var label[] drawn_labels = array.new_label()
var int last_signal_bar = na
var string last_signal = "None"
var color last_signal_color = text_dim
var box active_response_zone = na
var line active_response_mid = na
var box active_corridor = na
var line active_target_line = na
var label active_signal_label = na

cooldown_clear(_pivot_bar) =>
    na(last_signal_bar) or cooldown_bars == 0 or (_pivot_bar - last_signal_bar) >= cooldown_bars

//==============================================================================
// DIVERGENCE DETECTION
//==============================================================================
bool bear_div = false
bool bull_div = false
bool hidden_bear_div = false
bool hidden_bull_div = false
float active_quality = na

int bear_bar_1 = na
int bear_bar_2 = na
float bear_price_1 = na
float bear_price_2 = na

int bull_bar_1 = na
int bull_bar_2 = na
float bull_price_1 = na
float bull_price_2 = na

if not na(price_pivot_high) and array.size(high_prices) >= 2
    float current_high = array.get(high_prices, array.size(high_prices) - 1)
    int current_high_bar = array.get(high_bars, array.size(high_bars) - 1)
    float current_rsi = array.get(high_rsi_vals, array.size(high_rsi_vals) - 1)
    bool ribbon_ok = not require_ribbon_filter or close[pivot_length] < ribbon_lower[pivot_length]
    bool extreme_ok = not require_extremes or current_rsi >= ob_level - 3
    for i = array.size(high_prices) - 2 to 0
        float previous_high = array.get(high_prices, i)
        int previous_high_bar = array.get(high_bars, i)
        bool within_window = (current_high_bar - previous_high_bar) > 2 and (current_high_bar - previous_high_bar) <= divergence_window
        if within_window and cooldown_clear(current_high_bar)
            float previous_rsi = array.get(high_rsi_vals, i)
            bool rsi_delta_ok = math.abs(current_rsi - previous_rsi) >= minimum_rsi_delta
            bool move_ok = math.abs(current_high - previous_high) >= atr_value * minimum_move_atr
            if ribbon_ok and extreme_ok and rsi_delta_ok and move_ok
                if current_high > previous_high and current_rsi < previous_rsi
                    bear_div := true
                    bear_bar_1 := previous_high_bar
                    bear_bar_2 := current_high_bar
                    bear_price_1 := previous_high
                    bear_price_2 := current_high
                    break
                if current_high < previous_high and current_rsi > previous_rsi
                    hidden_bear_div := true
                    bear_bar_1 := previous_high_bar
                    bear_bar_2 := current_high_bar
                    bear_price_1 := previous_high
                    bear_price_2 := current_high
                    break

if not na(price_pivot_low) and array.size(low_prices) >= 2
    float current_low = array.get(low_prices, array.size(low_prices) - 1)
    int current_low_bar = array.get(low_bars, array.size(low_bars) - 1)
    float current_rsi = array.get(low_rsi_vals, array.size(low_rsi_vals) - 1)
    bool ribbon_ok = not require_ribbon_filter or close[pivot_length] > ribbon_upper[pivot_length]
    bool extreme_ok = not require_extremes or current_rsi <= os_level + 3
    for i = array.size(low_prices) - 2 to 0
        float previous_low = array.get(low_prices, i)
        int previous_low_bar = array.get(low_bars, i)
        bool within_window = (current_low_bar - previous_low_bar) > 2 and (current_low_bar - previous_low_bar) <= divergence_window
        if within_window and cooldown_clear(current_low_bar)
            float previous_rsi = array.get(low_rsi_vals, i)
            bool rsi_delta_ok = math.abs(current_rsi - previous_rsi) >= minimum_rsi_delta
            bool move_ok = math.abs(current_low - previous_low) >= atr_value * minimum_move_atr
            if ribbon_ok and extreme_ok and rsi_delta_ok and move_ok
                if current_low < previous_low and current_rsi > previous_rsi
                    bull_div := true
                    bull_bar_1 := previous_low_bar
                    bull_bar_2 := current_low_bar
                    bull_price_1 := previous_low
                    bull_price_2 := current_low
                    break
                if current_low > previous_low and current_rsi < previous_rsi
                    hidden_bull_div := true
                    bull_bar_1 := previous_low_bar
                    bull_bar_2 := current_low_bar
                    bull_price_1 := previous_low
                    bull_price_2 := current_low
                    break

//==============================================================================
// DRAW SIGNALS
//==============================================================================
if show_regular and bear_div
    f_draw_signal(drawn_lines, drawn_labels, bear_bar_1, bear_price_1, bear_bar_2, bear_price_2, "Bear Div", bear_core, false)
    last_signal_bar := bear_bar_2
    last_signal := "Bear Div"
    last_signal_color := bear_core
    box.delete(active_response_zone)
    box.delete(active_corridor)
    line.delete(active_response_mid)
    line.delete(active_target_line)
    label.delete(active_signal_label)
    active_quality := math.abs(bear_price_2 - bear_price_1) / atr_value + math.abs(array.get(high_rsi_vals, array.size(high_rsi_vals) - 1) - array.get(high_rsi_vals, array.size(high_rsi_vals) - 2)) / 10.0
    if show_response_zones
        active_response_zone := box.new(bear_bar_2, bear_price_2 + atr_value * 0.45, bear_bar_2 + 20, bear_price_2 - atr_value * 0.15, bgcolor=color.new(bear_core, 88), border_color=color.new(bear_core, 30))
        active_response_mid := line.new(bear_bar_2, bear_price_2, bear_bar_2 + 20, bear_price_2, color=color.new(bear_core, 20), style=line.style_dotted)
    if show_reaction_corridors
        active_corridor := box.new(bear_bar_1, math.max(bear_price_1, bear_price_2) + atr_value * 0.25, bear_bar_2 + 24, bear_price_2 - atr_value * 0.95, bgcolor=color.new(bear_core, 94), border_color=color.new(bear_core, 65))
        active_target_line := line.new(bear_bar_2, bear_price_2 - atr_value * 0.60, bear_bar_2 + 24, bear_price_2 - atr_value * 0.60, color=color.new(accent_gold, 0), width=1)
    if show_signal_labels
        active_signal_label := label.new(bear_bar_2 + 1, bear_price_2 + atr_value * 0.48, "Distribution Response\nQ " + str.tostring(active_quality, "#.##") + "\n" + str.tostring(bear_price_2, format.mintick), style=label.style_label_left, color=color.new(bear_core, 6), textcolor=color.black, size=size.tiny)

if show_hidden and hidden_bear_div
    f_draw_signal(drawn_lines, drawn_labels, bear_bar_1, bear_price_1, bear_bar_2, bear_price_2, "Hid Bear", hidden_bear, true)
    last_signal_bar := bear_bar_2
    last_signal := "Hidden Bear"
    last_signal_color := hidden_bear
    box.delete(active_response_zone)
    box.delete(active_corridor)
    line.delete(active_response_mid)
    line.delete(active_target_line)
    label.delete(active_signal_label)
    active_quality := math.abs(bear_price_2 - bear_price_1) / atr_value + math.abs(array.get(high_rsi_vals, array.size(high_rsi_vals) - 1) - array.get(high_rsi_vals, array.size(high_rsi_vals) - 2)) / 10.0
    if show_response_zones
        active_response_zone := box.new(bear_bar_2, bear_price_2 + atr_value * 0.35, bear_bar_2 + 16, bear_price_2 - atr_value * 0.12, bgcolor=color.new(hidden_bear, 88), border_color=color.new(hidden_bear, 30))
        active_response_mid := line.new(bear_bar_2, bear_price_2, bear_bar_2 + 16, bear_price_2, color=color.new(hidden_bear, 20), style=line.style_dotted)
    if show_reaction_corridors
        active_corridor := box.new(bear_bar_1, math.max(bear_price_1, bear_price_2) + atr_value * 0.18, bear_bar_2 + 18, bear_price_2 - atr_value * 0.70, bgcolor=color.new(hidden_bear, 95), border_color=color.new(hidden_bear, 65))
        active_target_line := line.new(bear_bar_2, bear_price_2 - atr_value * 0.45, bear_bar_2 + 18, bear_price_2 - atr_value * 0.45, color=color.new(accent_gold, 0), width=1)
    if show_signal_labels
        active_signal_label := label.new(bear_bar_2 + 1, bear_price_2 + atr_value * 0.40, "Hidden Supply\nQ " + str.tostring(active_quality, "#.##") + "\n" + str.tostring(bear_price_2, format.mintick), style=label.style_label_left, color=color.new(hidden_bear, 6), textcolor=color.black, size=size.tiny)

if show_regular and bull_div
    f_draw_signal(drawn_lines, drawn_labels, bull_bar_1, bull_price_1, bull_bar_2, bull_price_2, "Bull Div", bull_core, false)
    last_signal_bar := bull_bar_2
    last_signal := "Bull Div"
    last_signal_color := bull_core
    box.delete(active_response_zone)
    box.delete(active_corridor)
    line.delete(active_response_mid)
    line.delete(active_target_line)
    label.delete(active_signal_label)
    active_quality := math.abs(bull_price_2 - bull_price_1) / atr_value + math.abs(array.get(low_rsi_vals, array.size(low_rsi_vals) - 1) - array.get(low_rsi_vals, array.size(low_rsi_vals) - 2)) / 10.0
    if show_response_zones
        active_response_zone := box.new(bull_bar_2, bull_price_2 + atr_value * 0.15, bull_bar_2 + 20, bull_price_2 - atr_value * 0.45, bgcolor=color.new(bull_core, 88), border_color=color.new(bull_core, 30))
        active_response_mid := line.new(bull_bar_2, bull_price_2, bull_bar_2 + 20, bull_price_2, color=color.new(bull_core, 20), style=line.style_dotted)
    if show_reaction_corridors
        active_corridor := box.new(bull_bar_1, bull_price_2 + atr_value * 0.95, bull_bar_2 + 24, math.min(bull_price_1, bull_price_2) - atr_value * 0.25, bgcolor=color.new(bull_core, 94), border_color=color.new(bull_core, 65))
        active_target_line := line.new(bull_bar_2, bull_price_2 + atr_value * 0.60, bull_bar_2 + 24, bull_price_2 + atr_value * 0.60, color=color.new(accent_gold, 0), width=1)
    if show_signal_labels
        active_signal_label := label.new(bull_bar_2 + 1, bull_price_2 - atr_value * 0.48, "Accumulation Response\nQ " + str.tostring(active_quality, "#.##") + "\n" + str.tostring(bull_price_2, format.mintick), style=label.style_label_left, color=color.new(bull_core, 6), textcolor=color.black, size=size.tiny)

if show_hidden and hidden_bull_div
    f_draw_signal(drawn_lines, drawn_labels, bull_bar_1, bull_price_1, bull_bar_2, bull_price_2, "Hid Bull", hidden_bull, true)
    last_signal_bar := bull_bar_2
    last_signal := "Hidden Bull"
    last_signal_color := hidden_bull
    box.delete(active_response_zone)
    box.delete(active_corridor)
    line.delete(active_response_mid)
    line.delete(active_target_line)
    label.delete(active_signal_label)
    active_quality := math.abs(bull_price_2 - bull_price_1) / atr_value + math.abs(array.get(low_rsi_vals, array.size(low_rsi_vals) - 1) - array.get(low_rsi_vals, array.size(low_rsi_vals) - 2)) / 10.0
    if show_response_zones
        active_response_zone := box.new(bull_bar_2, bull_price_2 + atr_value * 0.12, bull_bar_2 + 16, bull_price_2 - atr_value * 0.35, bgcolor=color.new(hidden_bull, 88), border_color=color.new(hidden_bull, 30))
        active_response_mid := line.new(bull_bar_2, bull_price_2, bull_bar_2 + 16, bull_price_2, color=color.new(hidden_bull, 20), style=line.style_dotted)
    if show_reaction_corridors
        active_corridor := box.new(bull_bar_1, bull_price_2 + atr_value * 0.70, bull_bar_2 + 18, math.min(bull_price_1, bull_price_2) - atr_value * 0.18, bgcolor=color.new(hidden_bull, 95), border_color=color.new(hidden_bull, 65))
        active_target_line := line.new(bull_bar_2, bull_price_2 + atr_value * 0.45, bull_bar_2 + 18, bull_price_2 + atr_value * 0.45, color=color.new(accent_gold, 0), width=1)
    if show_signal_labels
        active_signal_label := label.new(bull_bar_2 + 1, bull_price_2 - atr_value * 0.40, "Hidden Demand\nQ " + str.tostring(active_quality, "#.##") + "\n" + str.tostring(bull_price_2, format.mintick), style=label.style_label_left, color=color.new(hidden_bull, 6), textcolor=color.black, size=size.tiny)

plotshape(show_pivot_dots and bull_div, title="Bull Div Dot", style=shape.circle, location=location.belowbar, color=bull_core, size=size.tiny, offset=-pivot_length)
plotshape(show_pivot_dots and bear_div, title="Bear Div Dot", style=shape.circle, location=location.abovebar, color=bear_core, size=size.tiny, offset=-pivot_length)
plotshape(show_pivot_dots and hidden_bull_div, title="Hidden Bull Dot", style=shape.circle, location=location.belowbar, color=hidden_bull, size=size.tiny, offset=-pivot_length)
plotshape(show_pivot_dots and hidden_bear_div, title="Hidden Bear Dot", style=shape.circle, location=location.abovebar, color=hidden_bear, size=size.tiny, offset=-pivot_length)
plotshape(ta.crossover(rsi_value, os_level) and close > response_lower, title="RSI Bull Reset", style=shape.square, location=location.belowbar, color=color.new(bull_core, 12), size=size.tiny)
plotshape(ta.crossunder(rsi_value, ob_level) and close < response_upper, title="RSI Bear Reset", style=shape.square, location=location.abovebar, color=color.new(bear_core, 12), size=size.tiny)

signal_bar_color = bear_div or hidden_bear_div ? color.new(bear_core, 45) : bull_div or hidden_bull_div ? color.new(bull_core, 45) : rsi_value >= ob_level ? color.new(bear_core, 75) : rsi_value <= os_level ? color.new(bull_core, 75) : na
barcolor(signal_bar_color)
bgcolor((bear_div or hidden_bear_div) ? color.new(bear_core, 94) : (bull_div or hidden_bull_div) ? color.new(bull_core, 94) : na)

//==============================================================================
// DASHBOARD
//==============================================================================
var table dash = table.new(position.top_right, 2, 7, bgcolor=panel_bg, border_width=1, border_color=panel_grid, frame_color=panel_grid, frame_width=1)

f_dash_row(_row, _label, _value, _color, _bg) =>
    table.cell(dash, 0, _row, _label, text_color=text_dim, bgcolor=_bg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, _row, _value, text_color=_color, bgcolor=_bg, text_size=size.small, text_halign=text.align_right)

if show_dashboard and barstate.islast
    string rsi_zone = rsi_value >= ob_level ? "Overbought" : rsi_value <= os_level ? "Oversold" : "Neutral"
    color rsi_zone_color = rsi_value >= ob_level ? bear_core : rsi_value <= os_level ? bull_core : neutral_core
    string ribbon_text = ribbon_state == 1 ? "Supportive" : ribbon_state == -1 ? "Restrictive" : "Flat"
    string bars_since = na(last_signal_bar) ? "n/a" : str.tostring(bar_index - last_signal_bar)
    table.cell(dash, 0, 0, "VESPER DIVERGENCE", text_color=text_main, bgcolor=panel_header, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, last_signal, text_color=last_signal_color, bgcolor=panel_header, text_size=size.small, text_halign=text.align_right)
    f_dash_row(1, "RSI", str.tostring(rsi_value, "#.##"), rsi_zone_color, panel_cell)
    f_dash_row(2, "Zone", rsi_zone, rsi_zone_color, panel_bg)
    f_dash_row(3, "Ribbon", ribbon_text, ribbon_color, panel_cell)
    f_dash_row(4, "Cooldown", na(last_signal_bar) ? "Ready" : bars_since + " bars", text_main, panel_bg)
    f_dash_row(5, "Window", str.tostring(divergence_window), neutral_core, panel_cell)
    f_dash_row(6, "ATR Filter", str.tostring(minimum_move_atr, "#.##") + "x", text_main, panel_bg)

//==============================================================================
// ALERTS
//==============================================================================
alertcondition(bear_div, "Bearish Divergence", "Vesper Divergence Cascade [JOAT] confirmed bearish divergence on {{ticker}} {{interval}}.")
alertcondition(bull_div, "Bullish Divergence", "Vesper Divergence Cascade [JOAT] confirmed bullish divergence on {{ticker}} {{interval}}.")
alertcondition(hidden_bear_div, "Hidden Bearish Divergence", "Vesper Divergence Cascade [JOAT] confirmed hidden bearish divergence on {{ticker}} {{interval}}.")
alertcondition(hidden_bull_div, "Hidden Bullish Divergence", "Vesper Divergence Cascade [JOAT] confirmed hidden bullish divergence on {{ticker}} {{interval}}.")
````
