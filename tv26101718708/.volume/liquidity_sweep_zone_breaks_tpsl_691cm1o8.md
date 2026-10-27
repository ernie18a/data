# Liquidity Sweep & Zone Breaks + TP/SL

- url: https://www.tradingview.com/script/691cM1o8-Liquidity-Sweep-Zone-Breaks-TP-SL/
- type: indicator
- pine_id: PUB;1b5f033aff6349b7bfe00298b0d3ba62
- version: 1.0

## Description

█ OVERVIEW
Liquidity Sweep & Zone Breaks + TP/SL is a price action indicator designed to detect liquidity sweeps based on market structure pivots, draw liquidity zones, and generate zone break signals along with a complete trade plan – Stop Loss and three Take Profit levels based on Risk-Reward ratios.
The indicator combines classic pivot-based market structure analysis with liquidity concepts. Signals appear when price briefly breaks significant highs or lows and then returns back inside the previous range, suggesting a liquidity grab or a failed breakout.
The system analyzes four independent pivot lengths simultaneously, allowing it to detect liquidity across different market horizons — from short-term intraday moves to major structural levels.
After a confirmed sweep and after a liquidity zone break, the indicator automatically creates a full position visualization:
• entry level,
• Stop Loss,
• TP1 / TP2 / TP3,
• risk and reward zones.

█ CONCEPTS
The indicator is based on the idea that markets often move by first taking liquidity before executing the real directional move. These behaviors typically occur around key swing highs and lows defined by pivot structure.
Instead of treating breakouts as continuation signals, the indicator focuses on failed breakouts that return back inside the range.

Liquidity Sweep Detection
A liquidity sweep occurs when price temporarily breaks a pivot level and then closes back inside the structure:
• sweep HIGH → price takes the previous high and closes back below it (SELL bias),
• sweep LOW → price takes the previous low and closes back above it (BUY bias).
Confirmation must occur within a defined Confirmation Window.

Confirmation Window
After a pivot is breached, price has a limited number of candles to confirm a return back inside the range.
If confirmation occurs within this window:
• a sweep signal is generated,
• a liquidity zone may be created.
If not confirmed in time, the setup is invalidated.

Multi-Pivot Structure
The indicator uses four pivot lengths:
• short pivots → local liquidity and minor swings,
• medium pivots → local structure,
• long pivots → major swing levels,
• extended pivots → macro liquidity zones.
This allows simultaneous tracking of liquidity across multiple structural timeframes.

Liquidity Zones
After a confirmed sweep, a zone is created between:
• pivot level,
• wick extreme formed during the sweep.
These zones often act as future price reaction areas.

Zone Break
Each zone remains active until it is broken.
A zone break occurs when price closes beyond the sweep extreme:
• break of BUY sweep zone → SELL signal,
• break of SELL sweep zone → BUY signal.
This creates a second layer of signals based on continuation after liquidity has been taken.

Volume Multiplier
Each signal includes a relative volume multiplier compared to a moving average of volume.
It indicates whether the move was supported by increased participation:
• 1.0x → normal volume,
• 2.0x → elevated volume,
• 3.0x+ → strong participation.

Unbroken Pivots
The indicator also tracks pivot levels that have not yet been swept by price.

These represent:
• unfilled liquidity,
• potential future price targets.
Once swept, they are automatically removed.

TP/SL and Risk-Reward
After each signal, the indicator automatically calculates:
• entry price,
• Stop Loss,
• TP1 / TP2 / TP3.

Stop Loss can be defined as:
• ATR multiplier,
or
• fixed percentage from entry.
Take Profit levels are based on predefined Risk-Reward ratios.

█ FEATURES
1. Multi-Pivot Liquidity Detection
Four independent pivot lengths:
• Pivot Length 1
• Pivot Length 2
• Pivot Length 3
• Pivot Length 4
Each represents a different level of market structure.

2. Confirmation Window
Defines how many candles are allowed for sweep confirmation.
• lower values → stricter and fewer signals,
• higher values → more flexible and more signals.

3. Sweep Signals
Optional visualization of sweep signals:
• BUY sweep
• SELL sweep
Signals may include pivot length and volume multiplier.

4. Liquidity Zones
Automatic drawing of zones between pivot level and wick extreme after a confirmed sweep.

5. Zone Break Signals
Signals generated when price breaks a previously formed liquidity zone.

6. Unbroken Pivot Levels
Displays levels that have not yet been taken by price.

7. Volume Analysis
Each signal includes a relative volume strength measurement.

8. TP/SL Settings
• ATR-based Stop Loss or percentage-based Stop Loss
• TP1 / TP2 / TP3 based on RR multipliers
• fully customizable risk-reward structure

9. Position Visualization
The indicator automatically draws:
• entry line,
• Stop Loss,
• Take Profit levels,
• risk/reward zones,
• price labels.
Once TP or SL is hit, all levels stop extending.

TP/SL TRIGGERS
TP/SL can be triggered by:
• sweep signals (P1–P4),
• zone break signals,
• depending on enabled signal source settings.

█ APPLICATIONS
1. Liquidity Sweep Reversals
The main use of the indicator is identifying failed breakouts where price takes liquidity and quickly returns back into range.
These setups often precede short-term reversals or corrections.

2. Market Structure & Liquidity Mapping
Unbroken pivots and sweep zones highlight areas of remaining liquidity and potential future reaction zones.

3. Continuation After Sweep
Zone Break signals may indicate that price has absorbed liquidity and is continuing in the direction of the breakout.

4. Trade Management
The built-in TP/SL system provides immediate visualization of:
• risk,
• reward,
• target levels,
• trade structure.

█ NOTES
• Lower pivot lengths generate more signals and more noise.
• Higher pivot lengths generate fewer but more significant liquidity levels.
• Sweep and Zone Break signals represent different market behaviors and should be analyzed separately.
• Liquidity sweeps do not guarantee reversals and should always be evaluated within broader market structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator('Liquidity Sweep & Zone Breaks + TP/SL', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)
// PIVOT LENGTHS
pivot_length_1 = input.int(5,  title = 'Pivot Length 1', minval = 1, group = 'Pivot Lengths',
    tooltip = 'Bars left and right for the shortest-term pivot detection. Lower values (3–7) catch frequent minor sweeps. Recommended: 5')
pivot_length_2 = input.int(10, title = 'Pivot Length 2', minval = 1, group = 'Pivot Lengths',
    tooltip = 'Medium-term pivot length. Good balance between frequency and significance. Recommended: 8–15')
pivot_length_3 = input.int(20, title = 'Pivot Length 3', minval = 1, group = 'Pivot Lengths',
    tooltip = 'Longer-term pivots for major swing highs and lows. Recommended: 15–30')
pivot_length_4 = input.int(30, title = 'Pivot Length 4', minval = 1, group = 'Pivot Lengths',
    tooltip = 'Longest pivot length — major structural liquidity levels. Recommended: 25–50')
confirm_bars   = input.int(3,  title = 'Confirmation Window (bars)', minval = 1, maxval = 20, group = 'Pivot Lengths',
    tooltip = 'Bars after a pivot break in which a confirming close must occur. Higher values produce fewer but cleaner signals.')

// SWEEP SIGNALS
col_buy               = input.color(color.rgb(6, 162, 47),  title = 'Buy Color',         group = 'Sweep Signals')
col_sell              = input.color(color.rgb(207, 23, 23), title = 'Sell Color',         group = 'Sweep Signals')
label_text_col        = input.color(color.white,            title = 'Label Text Color',   group = 'Sweep Signals')
show_sweep_signals    = input.bool(false,                   title = 'Show Signals',       group = 'Sweep Signals',
    tooltip = 'Plot triangle shapes on confirmed liquidity sweep signals.')
sweep_signal_size_str = input.string('Tiny',                title = 'Signal Size',        group = 'Sweep Signals',
    options = ['Tiny', 'Small'])
show_signal_labels    = input.bool(true,                    title = 'Show Signal Labels', group = 'Sweep Signals',
    tooltip = 'Display text labels showing direction, pivot length and relative volume.')
signal_label_size     = input.string('Small',               title = 'Signal Label Size',  group = 'Sweep Signals',
    options = ['Tiny', 'Small', 'Normal'])

// ZONE BREAK SIGNALS
col_zone_break_buy  = input.color(color.rgb(6, 162, 47),  title = 'Buy Color',        group = 'Zone Break Signals')
col_zone_break_sell = input.color(color.rgb(207, 23, 23), title = 'Sell Color',       group = 'Zone Break Signals')
zb_label_text_col   = input.color(color.white,            title = 'Label Text Color', group = 'Zone Break Signals')
show_zone_breaks    = input.bool(false,                   title = 'Show Signals',     group = 'Zone Break Signals',
    tooltip = 'Plot signals when price breaks the extreme of a previously swept liquidity zone.')
zone_break_size_str = input.string('Tiny',                title = 'Signal Size',      group = 'Zone Break Signals',
    options = ['Tiny', 'Small'])
show_zb_labels      = input.bool(true,                    title = 'Show Labels',      group = 'Zone Break Signals',
    tooltip = 'Display text labels on zone-break signals including relative volume.')
zb_label_size       = input.string('Small',               title = 'Label Size',       group = 'Zone Break Signals',
    options = ['Tiny', 'Small', 'Normal'])

// VOLUME MULTIPLIER
vol_ma_length = input.int(20, title = 'Volume MA Length', minval = 1, group = 'Volume Multiplier',
    tooltip = 'SMA length used to compute the relative volume multiplier shown in labels (e.g. "2.34x vol").')

// LINES AND ZONES
show_lines   = input.bool(true,  title = 'Show Lines',                group = 'Lines and Zones',
    tooltip = 'Draw dashed lines from the original pivot to the sweep confirmation bar.')
line_transp  = input.int(20,     title = 'Line Transparency',         group = 'Lines and Zones', minval = 0, maxval = 100)
show_zones   = input.bool(true,  title = 'Show Sweep Zones',          group = 'Lines and Zones',
    tooltip = 'Draw colored boxes covering the swept liquidity range (pivot level to wick extreme).')
zone_transp  = input.int(70,     title = 'Zone Transparency',         group = 'Lines and Zones', minval = 0, maxval = 100)
max_bars_ext = input.int(2000,   title = 'Max Zone Extension (bars)', group = 'Lines and Zones', minval = 1, maxval = 5000,
    tooltip = 'Maximum number of bars an active (unbroken) zone extends to the right.')

// UNBROKEN PIVOTS
show_unbroken_pivots = input.bool(true,               title = 'Show Unbroken Pivot Levels', group = 'Unbroken Pivots',
    tooltip = 'Draw horizontal lines at pivot levels that have not yet been swept.')
unbroken_transp      = input.int(60,                  title = 'Lines Transparency',         group = 'Unbroken Pivots', minval = 0, maxval = 100)
unbroken_style       = input.string(line.style_solid, title = 'Lines Style',                group = 'Unbroken Pivots',
    options = [line.style_solid, line.style_dashed, line.style_dotted])
unbroken_width       = input.int(1,                   title = 'Lines Width',                group = 'Unbroken Pivots', minval = 1, maxval = 4)

// TP/SL
show_targets  = input.bool(true,  title = 'Show TP/SL Levels',       group = 'TP/SL',
    tooltip = 'Draw entry, stop-loss and take-profit levels after each confirmed signal (sweep or zone break).')
use_atr_sl    = input.bool(true,  title = 'SL = ATR × instead of %', group = 'TP/SL',
    tooltip = 'When enabled, stop-loss distance is ATR × multiplier. When disabled, a fixed percentage is used.')
tp_atr_period = input.int(14,     title = 'ATR Period for TP/SL',    group = 'TP/SL', minval = 1)
sl_atr_mult   = input.float(1.5,  title = 'ATR Multiplier for SL',   group = 'TP/SL', step = 0.1)
sl_percent    = input.float(1.0,  title = 'SL % from Entry',         group = 'TP/SL', step = 0.1)
rr_tp1        = input.float(1.0,  title = 'RR for TP1',              group = 'TP/SL', step = 0.1)
rr_tp2        = input.float(2.0,  title = 'RR for TP2',              group = 'TP/SL', step = 0.1)
rr_tp3        = input.float(3.0,  title = 'RR for TP3',              group = 'TP/SL', step = 0.1)

// TP/SL display toggles
show_sl_level  = input.bool(true, title = 'Show SL Level',  group = 'TP/SL Display')
show_tp1_level = input.bool(true, title = 'Show TP1 Level', group = 'TP/SL Display')
show_tp2_level = input.bool(true, title = 'Show TP2 Level', group = 'TP/SL Display')
show_tp3_level = input.bool(true, title = 'Show TP3 Level', group = 'TP/SL Display')

// Which signal types trigger TP/SL drawing
tpsl_on_sweep = input.bool(true, title = 'Sweep Signals Trigger TP/SL',      group = 'TP/SL Trigger',
    tooltip = 'Draw TP/SL levels on confirmed liquidity sweep signals.')
tpsl_on_p1    = input.bool(true, title = 'P1 Sweeps Trigger TP/SL',          group = 'TP/SL Trigger')
tpsl_on_p2    = input.bool(true, title = 'P2 Sweeps Trigger TP/SL',          group = 'TP/SL Trigger')
tpsl_on_p3    = input.bool(true, title = 'P3 Sweeps Trigger TP/SL',          group = 'TP/SL Trigger')
tpsl_on_p4    = input.bool(true, title = 'P4 Sweeps Trigger TP/SL',          group = 'TP/SL Trigger')
tpsl_on_break = input.bool(true, title = 'Zone Break Signals Trigger TP/SL', group = 'TP/SL Trigger',
    tooltip = 'Draw TP/SL levels on zone-break signals (requires "Show Signals" enabled in Zone Break Signals).')

// USER-DEFINED TYPE

// Represents an active swept liquidity zone tracked for zone-break detection.
type SweepZone
    box   bx
    float lvl
    float extreme
    bool  is_buy
    bool  broken
    int   born_bar

// PERSISTENT ARRAYS

var array<SweepZone> zones = array.new<SweepZone>()

// Arrays tracking unbroken pivot lines so they can be deleted when swept.
var array<line>  unbroken_high_lines  = array.new_line()
var array<float> unbroken_high_prices = array.new_float()
var array<color> unbroken_high_colors = array.new_color()
var array<line>  unbroken_low_lines   = array.new_line()
var array<float> unbroken_low_prices  = array.new_float()
var array<color> unbroken_low_colors  = array.new_color()

// TP/SL STATE

var int      tpsl_dir         = 0   
var float    tpsl_sl          = na
var float    tpsl_extreme     = na  
var line     tpsl_entry_ln    = na
var label    tpsl_entry_lb    = na
var line     tpsl_sl_ln       = na
var label    tpsl_sl_lb       = na
var line     tpsl_tp1_ln      = na
var label    tpsl_tp1_lb      = na
var line     tpsl_tp2_ln      = na
var label    tpsl_tp2_lb      = na
var line     tpsl_tp3_ln      = na
var label    tpsl_tp3_lb      = na
var line     tpsl_ext_ln      = na  
var linefill tpsl_risk_fill   = na
var linefill tpsl_reward_fill = na
var int      tpsl_entry_bar   = na

// CALCULATIONS

vol_ma   = ta.sma(volume, vol_ma_length)
vol_mult = vol_ma > 0 ? volume / vol_ma : 1.0
atr_val  = ta.atr(tp_atr_period)

f_label_size(string s) =>
    s == 'Tiny' ? size.tiny : s == 'Small' ? size.small : size.normal


bool zone_break_buy_signal  = false
bool zone_break_sell_signal = false

i_z = array.size(zones) - 1
while i_z >= 0
    z = array.get(zones, i_z)
    if not z.broken
        if bar_index > z.born_bar
            bool broke = false
            if z.is_buy  and close < z.extreme
                broke := true
            if not z.is_buy and close > z.extreme
                broke := true
            if broke
                z.broken := true
                // A buy zone being broken by a downward close → sell bias.
                // A sell zone being broken by an upward close → buy bias.
                if z.is_buy
                    zone_break_sell_signal := true
                else
                    zone_break_buy_signal  := true
            else
                if bar_index - z.bx.get_left() <= max_bars_ext
                    z.bx.set_right(bar_index)
    i_z -= 1

// Zone-break labels
if show_zb_labels and zone_break_buy_signal
    label.new(bar_index, low,
         'BREAK BUY\nVol ' + str.tostring(vol_mult, '#.##') + 'x',
         style = label.style_label_up, color = color.new(col_zone_break_buy, 1),
         textcolor = zb_label_text_col, size = f_label_size(zb_label_size))

if show_zb_labels and zone_break_sell_signal
    label.new(bar_index, high,
         'BREAK SELL\nVol ' + str.tostring(vol_mult, '#.##') + 'x',
         style = label.style_label_down, color = color.new(col_zone_break_sell, 1),
         textcolor = zb_label_text_col, size = f_label_size(zb_label_size))

// UNBROKEN PIVOT MANAGEMENT

f_update_unbroken_pivots() =>
    if show_unbroken_pivots
        if array.size(unbroken_high_lines) > 0
            for i = array.size(unbroken_high_lines) - 1 to 0
                if close > array.get(unbroken_high_prices, i)
                    line.delete(array.get(unbroken_high_lines, i))
                    array.remove(unbroken_high_lines, i)
                    array.remove(unbroken_high_prices, i)
                    array.remove(unbroken_high_colors, i)
        if array.size(unbroken_low_lines) > 0
            for i = array.size(unbroken_low_lines) - 1 to 0
                if close < array.get(unbroken_low_prices, i)
                    line.delete(array.get(unbroken_low_lines, i))
                    array.remove(unbroken_low_lines, i)
                    array.remove(unbroken_low_prices, i)
                    array.remove(unbroken_low_colors, i)


f_add_unbroken_high(pivot_price, pivot_bar, col) =>
    if show_unbroken_pivots
        if not array.includes(unbroken_high_prices, pivot_price) and close <= pivot_price
            l = line.new(pivot_bar, pivot_price, bar_index + 500, pivot_price,
                 extend = extend.right,
                 color  = color.new(col, unbroken_transp),
                 style  = unbroken_style == line.style_dashed ? line.style_dashed :
                          unbroken_style == line.style_dotted  ? line.style_dotted : line.style_solid,
                 width  = unbroken_width)
            array.push(unbroken_high_lines,  l)
            array.push(unbroken_high_prices, pivot_price)
            array.push(unbroken_high_colors, col)


f_add_unbroken_low(pivot_price, pivot_bar, col) =>
    if show_unbroken_pivots
        if not array.includes(unbroken_low_prices, pivot_price) and close >= pivot_price
            l = line.new(pivot_bar, pivot_price, bar_index + 500, pivot_price,
                 extend = extend.right,
                 color  = color.new(col, unbroken_transp),
                 style  = unbroken_style == line.style_dashed ? line.style_dashed :
                          unbroken_style == line.style_dotted  ? line.style_dotted : line.style_solid,
                 width  = unbroken_width)
            array.push(unbroken_low_lines,  l)
            array.push(unbroken_low_prices, pivot_price)
            array.push(unbroken_low_colors, col)

// SWEEP DETECTION

f_sweep(length, col_b, col_s) =>
    pivot_high = ta.pivothigh(high, length, length)
    pivot_low  = ta.pivotlow (low,  length, length)

    var float last_high     = na
    var int   last_high_bar = na
    var float last_low      = na
    var int   last_low_bar  = na

    var array<float> broken_highs = array.new_float(0)
    var array<float> broken_lows  = array.new_float(0)

    var float pending_sell_lvl   = na
    var int   pending_sell_bar   = na
    var int   pending_sell_phbar = na
    var float pending_sell_wick  = na
    var float pending_buy_lvl    = na
    var int   pending_buy_bar    = na
    var int   pending_buy_plbar  = na
    var float pending_buy_wick   = na

    if not na(pivot_high)
        last_high     := pivot_high
        last_high_bar := bar_index[length]
        f_add_unbroken_high(pivot_high, bar_index[length], col_s)

    if not na(pivot_low)
        last_low     := pivot_low
        last_low_bar := bar_index[length]
        f_add_unbroken_low(pivot_low, bar_index[length], col_b)

    bool break_high = not na(last_high) and (high > last_high or close > last_high) and not array.includes(broken_highs, last_high)
    bool break_low  = not na(last_low)  and (low  < last_low  or close < last_low)  and not array.includes(broken_lows,  last_low)

    if break_high
        array.push(broken_highs, last_high)
        pending_sell_lvl   := last_high
        pending_sell_bar   := bar_index
        pending_sell_phbar := last_high_bar
        pending_sell_wick  := high
        pending_buy_lvl    := na
        pending_buy_bar    := na
        pending_buy_plbar  := na
        pending_buy_wick   := na

    if break_low
        array.push(broken_lows, last_low)
        pending_buy_lvl    := last_low
        pending_buy_bar    := bar_index
        pending_buy_plbar  := last_low_bar
        pending_buy_wick   := low
        pending_sell_lvl   := na
        pending_sell_bar   := na
        pending_sell_phbar := na
        pending_sell_wick  := na

    bool  sig_sell        = false
    float sig_sell_price  = na
    int   sig_sell_bar_   = na
    int   sig_sell_phbar_ = na
    float sig_sell_wick_  = na
    bool  sig_buy         = false
    float sig_buy_price   = na
    int   sig_buy_bar_    = na
    int   sig_buy_plbar_  = na
    float sig_buy_wick_   = na

    if not na(pending_sell_lvl) and not break_high
        elapsed = bar_index - pending_sell_bar
        if elapsed >= 1 and elapsed <= confirm_bars
            if close < pending_sell_lvl and close < open
                sig_sell        := true
                sig_sell_price  := pending_sell_lvl
                sig_sell_bar_   := pending_sell_bar
                sig_sell_phbar_ := pending_sell_phbar
                sig_sell_wick_  := pending_sell_wick
                pending_sell_lvl  := na
                pending_sell_bar  := na
                pending_sell_wick := na
        else if elapsed > confirm_bars
            pending_sell_lvl  := na
            pending_sell_bar  := na
            pending_sell_wick := na

    if not na(pending_buy_lvl) and not break_low
        elapsed = bar_index - pending_buy_bar
        if elapsed >= 1 and elapsed <= confirm_bars
            if close > pending_buy_lvl and close > open
                sig_buy        := true
                sig_buy_price  := pending_buy_lvl
                sig_buy_bar_   := pending_buy_bar
                sig_buy_plbar_ := pending_buy_plbar
                sig_buy_wick_  := pending_buy_wick
                pending_buy_lvl  := na
                pending_buy_bar  := na
                pending_buy_wick := na
        else if elapsed > confirm_bars
            pending_buy_lvl  := na
            pending_buy_bar  := na
            pending_buy_wick := na

    [sig_buy,  sig_buy_price,  sig_buy_bar_,  sig_buy_plbar_,  sig_buy_wick_,
     sig_sell, sig_sell_price, sig_sell_bar_, sig_sell_phbar_, sig_sell_wick_]

// SWEEP ZONE AND LINE DRAWING


f_draw(is_sig, lvl, cross_bar, pivot_bar, wick_extreme, col, is_buy) =>
    if is_sig and not na(lvl) and not na(cross_bar) and not na(pivot_bar) and not na(wick_extreme)
        confirm_bar  = bar_index
        bars_elapsed = confirm_bar - cross_bar
        bool skip_zone = false
        for i = 0 to bars_elapsed
            if not is_buy and close[i] > wick_extreme
                skip_zone := true
            if is_buy  and close[i] < wick_extreme
                skip_zone := true
        if show_lines
            line.new(pivot_bar, lvl, cross_bar, lvl,
                 color = color.new(col, line_transp), width = 1, style = line.style_dashed)
            line.new(cross_bar, lvl, confirm_bar, lvl,
                 color = color.new(col, line_transp), width = 2)
        if show_zones and not skip_zone
            top_    = is_buy ? lvl          : wick_extreme
            bottom_ = is_buy ? wick_extreme : lvl
            if top_ > bottom_
                bool dup = false
                if array.size(zones) > 0
                    for i = 0 to array.size(zones) - 1
                        z = array.get(zones, i)
                        if math.abs(z.lvl - lvl) < syminfo.mintick * 10 and z.is_buy == is_buy
                            dup := true
                            break
                if not dup
                    bx = box.new(cross_bar, top_, cross_bar, bottom_,
                         border_color = color.new(col, 100),
                         bgcolor      = color.new(col, zone_transp))
                    array.push(zones, SweepZone.new(bx, lvl, wick_extreme, is_buy, false, bar_index))

// SWEEP SIGNAL LABELS


f_signal_label(is_sig, is_buy, pivot_len, col) =>
    if is_sig and show_signal_labels
        _vm  = str.tostring(vol_mult, '#.##')
        _txt = (is_buy ? 'BUY P' : 'SELL P') + str.tostring(pivot_len) + '\nVol ' + _vm + 'x'
        label.new(bar_index, is_buy ? low : high, _txt,
             style     = is_buy ? label.style_label_up : label.style_label_down,
             color     = color.new(col, 1),
             textcolor = label_text_col,
             size      = f_label_size(signal_label_size))

// MAIN EXECUTION

f_update_unbroken_pivots()

[buy1,  buy1_p,  buy1_b,  buy1_pb,  buy1_w,  sell1, sell1_p, sell1_b, sell1_pb, sell1_w] = f_sweep(pivot_length_1, col_buy, col_sell)
[buy2,  buy2_p,  buy2_b,  buy2_pb,  buy2_w,  sell2, sell2_p, sell2_b, sell2_pb, sell2_w] = f_sweep(pivot_length_2, col_buy, col_sell)
[buy3,  buy3_p,  buy3_b,  buy3_pb,  buy3_w,  sell3, sell3_p, sell3_b, sell3_pb, sell3_w] = f_sweep(pivot_length_3, col_buy, col_sell)
[buy4,  buy4_p,  buy4_b,  buy4_pb,  buy4_w,  sell4, sell4_p, sell4_b, sell4_pb, sell4_w] = f_sweep(pivot_length_4, col_buy, col_sell)

f_draw(buy1,  buy1_p,  buy1_b,  buy1_pb,  buy1_w,  col_buy,  true)
f_draw(sell1, sell1_p, sell1_b, sell1_pb, sell1_w, col_sell, false)
f_draw(buy2,  buy2_p,  buy2_b,  buy2_pb,  buy2_w,  col_buy,  true)
f_draw(sell2, sell2_p, sell2_b, sell2_pb, sell2_w, col_sell, false)
f_draw(buy3,  buy3_p,  buy3_b,  buy3_pb,  buy3_w,  col_buy,  true)
f_draw(sell3, sell3_p, sell3_b, sell3_pb, sell3_w, col_sell, false)
f_draw(buy4,  buy4_p,  buy4_b,  buy4_pb,  buy4_w,  col_buy,  true)
f_draw(sell4, sell4_p, sell4_b, sell4_pb, sell4_w, col_sell, false)

f_signal_label(buy1,  true,  pivot_length_1, col_buy)
f_signal_label(sell1, false, pivot_length_1, col_sell)
f_signal_label(buy2,  true,  pivot_length_2, col_buy)
f_signal_label(sell2, false, pivot_length_2, col_sell)
f_signal_label(buy3,  true,  pivot_length_3, col_buy)
f_signal_label(sell3, false, pivot_length_3, col_sell)
f_signal_label(buy4,  true,  pivot_length_4, col_buy)
f_signal_label(sell4, false, pivot_length_4, col_sell)

// TP/SL TRIGGER LOGIC

bool sweep_buy_trigger  = (show_sweep_signals or show_signal_labels) and tpsl_on_sweep and
     ((buy1  and tpsl_on_p1) or (buy2  and tpsl_on_p2) or (buy3  and tpsl_on_p3) or (buy4  and tpsl_on_p4))
bool sweep_sell_trigger = (show_sweep_signals or show_signal_labels) and tpsl_on_sweep and
     ((sell1 and tpsl_on_p1) or (sell2 and tpsl_on_p2) or (sell3 and tpsl_on_p3) or (sell4 and tpsl_on_p4))

bool break_buy_trigger  = (show_zone_breaks or show_zb_labels) and tpsl_on_break and zone_break_buy_signal
bool break_sell_trigger = (show_zone_breaks or show_zb_labels) and tpsl_on_break and zone_break_sell_signal

bool tpsl_trigger_buy  = sweep_buy_trigger  or break_buy_trigger
bool tpsl_trigger_sell = sweep_sell_trigger or break_sell_trigger

// TP/SL DRAWING AND STATE MANAGEMENT

if show_targets and (tpsl_trigger_buy or tpsl_trigger_sell)
    
    bool is_buy_trade = not tpsl_trigger_sell

    line.delete(tpsl_entry_ln)
    label.delete(tpsl_entry_lb)
    line.delete(tpsl_sl_ln)
    label.delete(tpsl_sl_lb)
    line.delete(tpsl_tp1_ln)
    label.delete(tpsl_tp1_lb)
    line.delete(tpsl_tp2_ln)
    label.delete(tpsl_tp2_lb)
    line.delete(tpsl_tp3_ln)
    label.delete(tpsl_tp3_lb)
    line.delete(tpsl_ext_ln)
    linefill.delete(tpsl_risk_fill)
    linefill.delete(tpsl_reward_fill)

    tpsl_dir       := is_buy_trade ? 1 : -1
    tpsl_entry_bar := bar_index

    float entry_p   = close
    float risk_dist = use_atr_sl ? atr_val * sl_atr_mult : entry_p * (sl_percent / 100.0)

    color entry_col    = is_buy_trade ? col_buy  : col_sell
    color sl_col       = color.new(col_sell, 40)
    color tp_col       = color.new(col_buy,  40)
    color risk_fill_c  = color.new(col_sell, 70)
    color reward_fill_c= color.new(col_buy,  70)

    float sl_p  = is_buy_trade ? entry_p - risk_dist : entry_p + risk_dist
    float tp1_p = is_buy_trade ? entry_p + risk_dist * rr_tp1 : entry_p - risk_dist * rr_tp1
    float tp2_p = is_buy_trade ? entry_p + risk_dist * rr_tp2 : entry_p - risk_dist * rr_tp2
    float tp3_p = is_buy_trade ? entry_p + risk_dist * rr_tp3 : entry_p - risk_dist * rr_tp3

    tpsl_sl      := sl_p
    
    tpsl_extreme := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

    tpsl_entry_ln := line.new(bar_index, entry_p, bar_index + 1, entry_p,
         color = entry_col, width = 2, extend = extend.none)
    tpsl_entry_lb := label.new(bar_index, entry_p,
         (is_buy_trade ? 'BUY ' : 'SELL ') + str.tostring(entry_p, format.mintick),
         style = label.style_label_left, color = entry_col,
         textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_sl_ln := line.new(bar_index, sl_p, bar_index + 1, sl_p,
             color = sl_col, width = 1, style = line.style_dashed, extend = extend.none)
        tpsl_sl_lb := label.new(bar_index, sl_p,
             'SL ' + str.tostring(sl_p, format.mintick),
             style = label.style_label_left, color = sl_col,
             textcolor = color.white, size = size.small)

    if show_tp1_level
        tpsl_tp1_ln := line.new(bar_index, tp1_p, bar_index + 1, tp1_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp1_lb := label.new(bar_index, tp1_p,
             'TP1 ' + str.tostring(tp1_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp2_level
        tpsl_tp2_ln := line.new(bar_index, tp2_p, bar_index + 1, tp2_p,
             color = tp_col, width = 1, extend = extend.none)
        tpsl_tp2_lb := label.new(bar_index, tp2_p,
             'TP2 ' + str.tostring(tp2_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_tp3_level
        tpsl_tp3_ln := line.new(bar_index, tp3_p, bar_index + 1, tp3_p,
             color = tp_col, width = 1, style = line.style_dotted, extend = extend.none)
        tpsl_tp3_lb := label.new(bar_index, tp3_p,
             'TP3 ' + str.tostring(tp3_p, format.mintick),
             style = label.style_label_left, color = tp_col,
             textcolor = color.white, size = size.small)

    if show_sl_level
        tpsl_risk_fill := linefill.new(tpsl_entry_ln, tpsl_sl_ln, risk_fill_c)

    float fill_extreme = entry_p
    if is_buy_trade
        if show_tp1_level
            fill_extreme := math.max(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.max(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.max(fill_extreme, tp3_p)
        if fill_extreme > entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)
    else
        if show_tp1_level
            fill_extreme := math.min(fill_extreme, tp1_p)
        if show_tp2_level
            fill_extreme := math.min(fill_extreme, tp2_p)
        if show_tp3_level
            fill_extreme := math.min(fill_extreme, tp3_p)
        if fill_extreme < entry_p
            tpsl_ext_ln      := line.new(bar_index, fill_extreme, bar_index + 1, fill_extreme, color = na, extend = extend.none)
            tpsl_reward_fill := linefill.new(tpsl_entry_ln, tpsl_ext_ln, reward_fill_c)

// TP/SL POSITION UPDATE

if tpsl_dir != 0
    if not na(tpsl_entry_lb)
        label.set_x(tpsl_entry_lb, bar_index)
    if not na(tpsl_sl_lb)
        label.set_x(tpsl_sl_lb,    bar_index)
    if not na(tpsl_tp1_lb)
        label.set_x(tpsl_tp1_lb,   bar_index)
    if not na(tpsl_tp2_lb)
        label.set_x(tpsl_tp2_lb,   bar_index)
    if not na(tpsl_tp3_lb)
        label.set_x(tpsl_tp3_lb,   bar_index)

    if not na(tpsl_entry_ln)
        line.set_x2(tpsl_entry_ln, bar_index + 1)
    if not na(tpsl_sl_ln)
        line.set_x2(tpsl_sl_ln,    bar_index + 1)
    if not na(tpsl_tp1_ln)
        line.set_x2(tpsl_tp1_ln,   bar_index + 1)
    if not na(tpsl_tp2_ln)
        line.set_x2(tpsl_tp2_ln,   bar_index + 1)
    if not na(tpsl_tp3_ln)
        line.set_x2(tpsl_tp3_ln,   bar_index + 1)
    if not na(tpsl_ext_ln)
        line.set_x2(tpsl_ext_ln,   bar_index + 1)

    bool sl_hit = tpsl_dir == 1 ? low  <= tpsl_sl      : high >= tpsl_sl
    bool tp_hit = not na(tpsl_extreme) and
         (tpsl_dir == 1 ? high >= tpsl_extreme : low <= tpsl_extreme)

    if bar_index > tpsl_entry_bar and (sl_hit or tp_hit)
        if not na(tpsl_entry_ln)
            line.set_x2(tpsl_entry_ln, bar_index)
        if not na(tpsl_sl_ln)
            line.set_x2(tpsl_sl_ln,    bar_index)
        if not na(tpsl_tp1_ln)
            line.set_x2(tpsl_tp1_ln,   bar_index)
        if not na(tpsl_tp2_ln)
            line.set_x2(tpsl_tp2_ln,   bar_index)
        if not na(tpsl_tp3_ln)
            line.set_x2(tpsl_tp3_ln,   bar_index)
        if not na(tpsl_ext_ln)
            line.set_x2(tpsl_ext_ln,   bar_index)
        tpsl_dir := 0

// PLOT SHAPES — SWEEP SIGNALS

plotshape(show_sweep_signals and (buy1  or buy2  or buy3  or buy4)  and sweep_signal_size_str == 'Tiny',
     title = 'Sweep Buy Signal',  style = shape.triangleup,   location = location.belowbar, color = col_buy,  size = size.tiny)
plotshape(show_sweep_signals and (buy1  or buy2  or buy3  or buy4)  and sweep_signal_size_str == 'Small',
     title = 'Sweep Buy Signal',  style = shape.triangleup,   location = location.belowbar, color = col_buy,  size = size.small)
plotshape(show_sweep_signals and (sell1 or sell2 or sell3 or sell4) and sweep_signal_size_str == 'Tiny',
     title = 'Sweep Sell Signal', style = shape.triangledown, location = location.abovebar, color = col_sell, size = size.tiny)
plotshape(show_sweep_signals and (sell1 or sell2 or sell3 or sell4) and sweep_signal_size_str == 'Small',
     title = 'Sweep Sell Signal', style = shape.triangledown, location = location.abovebar, color = col_sell, size = size.small)

// PLOT SHAPES — ZONE BREAK SIGNALS

plotshape(show_zone_breaks and zone_break_size_str == 'Tiny'  and zone_break_sell_signal,
     title = 'Break Sell Signal', style = shape.circle, location = location.abovebar, color = col_zone_break_sell, size = size.tiny)
plotshape(show_zone_breaks and zone_break_size_str == 'Small' and zone_break_sell_signal,
     title = 'Break Sell Signal', style = shape.circle, location = location.abovebar, color = col_zone_break_sell, size = size.small)
plotshape(show_zone_breaks and zone_break_size_str == 'Tiny'  and zone_break_buy_signal,
     title = 'Break Buy Signal',  style = shape.circle, location = location.belowbar, color = col_zone_break_buy,  size = size.tiny)
plotshape(show_zone_breaks and zone_break_size_str == 'Small' and zone_break_buy_signal,
     title = 'Break Buy Signal',  style = shape.circle, location = location.belowbar, color = col_zone_break_buy,  size = size.small)

// ALERTS

alertcondition(buy1,  title = 'Sweep Buy  P1', message = 'Sweep BUY  P1 — {{close}}')
alertcondition(sell1, title = 'Sweep Sell P1', message = 'Sweep SELL P1 — {{close}}')
alertcondition(buy2,  title = 'Sweep Buy  P2', message = 'Sweep BUY  P2 — {{close}}')
alertcondition(sell2, title = 'Sweep Sell P2', message = 'Sweep SELL P2 — {{close}}')
alertcondition(buy3,  title = 'Sweep Buy  P3', message = 'Sweep BUY  P3 — {{close}}')
alertcondition(sell3, title = 'Sweep Sell P3', message = 'Sweep SELL P3 — {{close}}')
alertcondition(buy4,  title = 'Sweep Buy  P4', message = 'Sweep BUY  P4 — {{close}}')
alertcondition(sell4, title = 'Sweep Sell P4', message = 'Sweep SELL P4 — {{close}}')
alertcondition(buy1  or buy2  or buy3  or buy4,  title = 'Sweep Buy  ANY', message = 'Sweep BUY  — {{close}}')
alertcondition(sell1 or sell2 or sell3 or sell4, title = 'Sweep Sell ANY', message = 'Sweep SELL — {{close}}')
alertcondition(zone_break_buy_signal,  title = 'Zone Break BUY',  message = 'Zone Break BUY  — {{close}}')
alertcondition(zone_break_sell_signal, title = 'Zone Break SELL', message = 'Zone Break SELL — {{close}}')
````
