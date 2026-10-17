# Liquidity Probability DV Team

- url: https://www.tradingview.com/script/R356h39r-liquidity-probability-dv-team/
- type: indicator
- pine_id: PUB;aeee559ab0534880a79f2feb5f1b3733
- version: 1.0

## Description

The Liquidity Probability indicator is an advanced technical analysis tool designed for Smart Money Concepts (SMC), ICT, and price action traders. It automatically identifies key liquidity pools—Buy-Side Liquidity (BSL) and Sell-Side Liquidity (SSL)—and calculates the statistical probability of the price sweeping or reacting to these levels.

Instead of just drawing static support and resistance lines, this script evaluates the "strength" and "attraction" of liquidity zones in real-time, helping traders anticipate stop-hunts, liquidity grabs, and high-probability reversal setups.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// © DV Team — Liquidity Probability Map v2.0
// Enhanced visual: heatmap bars, bright % labels, sweep alerts

//@version=6
indicator("Liquidity Probability DV Team", shorttitle="LiqProb·DV", overlay=true, max_boxes_count=500, max_lines_count=300, max_labels_count=300)

// ══════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════

grp_main = "⚙️ Core Settings"
i_lookback      = input.int(50,   "Swing Lookback",         minval=5,  maxval=200, group=grp_main)
i_atr_len       = input.int(14,   "ATR Length",             minval=1,  maxval=50,  group=grp_main)
i_atr_mult      = input.float(1.5,"ATR Zone Multiplier",    minval=0.1,maxval=5.0, step=0.1, group=grp_main)
i_max_levels    = input.int(12,   "Max Levels Per Side",    minval=1,  maxval=20,  group=grp_main)

grp_visual = "🎨 Visual Settings"
i_sell_color    = input.color(color.new(#7B5EA7, 0),  "Sell-Side Color (Purple)", group=grp_visual)
i_buy_color     = input.color(color.new(#3DAA6A, 0),  "Buy-Side Color (Green)",   group=grp_visual)
i_bar_transp    = input.int(55,  "Bar Transparency",        minval=0,  maxval=90,  group=grp_visual)
i_show_labels   = input.bool(true,"Show % Labels",                                group=grp_visual)

grp_labels = "💡 % Label Brightness"
i_label_brightness = input.string("High", "Label Brightness", options=["Low", "Medium", "High", "Max"], group=grp_labels)
i_use_custom_label_color = input.bool(false, "Use Custom Label Colors", group=grp_labels)
i_sell_label_col = input.color(color.new(#C9B8FF, 0), "Sell Label Color Override", group=grp_labels)
i_buy_label_col  = input.color(color.new(#7FFFA8, 0), "Buy Label Color Override",  group=grp_labels)
i_label_size    = input.string("small", "Label Size", options=["tiny","small","normal","large","huge"], group=grp_labels)

grp_alerts = "🔔 Alerts"
i_alert_sweep   = input.bool(true,  "Alert on Sweep",  group=grp_alerts)
i_show_sweep_marker = input.bool(true, "Show Sweep Marker", group=grp_alerts)

// ══════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════

f_brightness_transp(b) =>
    switch b
        "Low"    => 88
        "Medium" => 70
        "High"   => 45
        "Max"    => 0
        => 60

f_label_alpha(b) =>
    switch b
        "Low"    => 60
        "Medium" => 30
        "High"   => 10
        "Max"    => 0
        => 20

f_label_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.small

sell_label_base = i_use_custom_label_color ? i_sell_label_col : color.new(#C9B8FF, f_label_alpha(i_label_brightness))
buy_label_base  = i_use_custom_label_color ? i_buy_label_col  : color.new(#7FFFA8, f_label_alpha(i_label_brightness))

lbl_bg_transp = f_brightness_transp(i_label_brightness)
sell_lbl_bg = color.new(#1A1030, lbl_bg_transp)
buy_lbl_bg  = color.new(#0A2018, lbl_bg_transp)

// ══════════════════════════════════════════════════════════════
//  DATA & ARRAYS
// ══════════════════════════════════════════════════════════════

atr_val = ta.atr(i_atr_len)
swing_hi = ta.pivothigh(high, i_lookback, i_lookback)
swing_lo = ta.pivotlow (low,  i_lookback, i_lookback)

var float[] sell_prices = array.new_float(0)
var float[] buy_prices  = array.new_float(0)
var box[]   sell_boxes  = array.new_box(0)
var box[]   buy_boxes   = array.new_box(0)
var label[] sell_labels = array.new_label(0)
var label[] buy_labels  = array.new_label(0)
var line[]  sell_lines  = array.new_line(0)
var line[]  buy_lines   = array.new_line(0)

// ══════════════════════════════════════════════════════════════
//  LOGIC
// ══════════════════════════════════════════════════════════════

if not na(swing_hi)
    array.push(sell_prices, swing_hi)
    if array.size(sell_prices) > i_max_levels
        array.shift(sell_prices)

if not na(swing_lo)
    array.push(buy_prices, swing_lo)
    if array.size(buy_prices) > i_max_levels
        array.shift(buy_prices)

// SWEEP DETECTION
if array.size(sell_prices) > 0
    for i = array.size(sell_prices) - 1 to 0
        p = array.get(sell_prices, i)
        if high >= p
            if i_alert_sweep
                alert("🟣 Sell-Side Swept: " + str.tostring(p, format.mintick), alert.freq_once_per_bar)
            if i_show_sweep_marker
                label.new(bar_index, p, "⚡", style=label.style_label_down, color=color.new(i_sell_color, 20), textcolor=color.white, size=size.small)
            array.remove(sell_prices, i)

if array.size(buy_prices) > 0
    for i = array.size(buy_prices) - 1 to 0
        p = array.get(buy_prices, i)
        if low <= p
            if i_alert_sweep
                alert("🟢 Buy-Side Swept: " + str.tostring(p, format.mintick), alert.freq_once_per_bar)
            if i_show_sweep_marker
                label.new(bar_index, p, "⚡", style=label.style_label_up, color=color.new(i_buy_color, 20), textcolor=color.white, size=size.small)
            array.remove(buy_prices, i)

// ══════════════════════════════════════════════════════════════
//  DRAWING (Fixed loops)
// ══════════════════════════════════════════════════════════════

if barstate.islast
    // Правильная очистка объектов
    for b in sell_boxes
        box.delete(b)
    for b in buy_boxes
        box.delete(b)
    for l in sell_labels
        label.delete(l)
    for l in buy_labels
        label.delete(l)
    for l in sell_lines
        line.delete(l)
    for l in buy_lines
        line.delete(l)

    array.clear(sell_boxes)
    array.clear(buy_boxes)
    array.clear(sell_labels)
    array.clear(buy_labels)
    array.clear(sell_lines)
    array.clear(buy_lines)

    // Расчет скоринга
    float sell_score_sum = 0.0
    for p in sell_prices
        sell_score_sum += 1.0 / (1.0 + (math.abs(close - p) / math.max(atr_val, 0.0001)))

    float buy_score_sum = 0.0
    for p in buy_prices
        buy_score_sum += 1.0 / (1.0 + (math.abs(close - p) / math.max(atr_val, 0.0001)))

    // Отрисовка Sell
    if array.size(sell_prices) > 0
        for p in sell_prices
            score = (1.0 / (1.0 + (math.abs(close - p) / math.max(atr_val, 0.0001)))) / sell_score_sum
            prob  = math.round(score * 100)
            box_w = math.max(1, math.round(score * 80))
            h_h   = atr_val * i_atr_mult * 0.35
            alpha = math.max(5, i_bar_transp - math.round(score * 35))
            
            array.push(sell_boxes, box.new(bar_index, p + h_h, bar_index + box_w, p - h_h, bgcolor=color.new(i_sell_color, alpha), border_color=color.new(i_sell_color, 80)))
            array.push(sell_lines, line.new(bar_index - 2, p, bar_index + box_w, p, color=color.new(i_sell_color, 60), style=line.style_dotted))
            if i_show_labels and prob > 0
                array.push(sell_labels, label.new(bar_index + box_w, p, str.tostring(prob) + "%", style=label.style_label_left, color=sell_lbl_bg, textcolor=sell_label_base, size=f_label_size(i_label_size)))

    // Отрисовка Buy
    if array.size(buy_prices) > 0
        for p in buy_prices
            score = (1.0 / (1.0 + (math.abs(close - p) / math.max(atr_val, 0.0001)))) / buy_score_sum
            prob  = math.round(score * 100)
            box_w = math.max(1, math.round(score * 80))
            h_h   = atr_val * i_atr_mult * 0.35
            alpha = math.max(5, i_bar_transp - math.round(score * 35))

            array.push(buy_boxes, box.new(bar_index, p + h_h, bar_index + box_w, p - h_h, bgcolor=color.new(i_buy_color, alpha), border_color=color.new(i_buy_color, 80)))
            array.push(buy_lines, line.new(bar_index - 2, p, bar_index + box_w, p, color=color.new(i_buy_color, 60), style=line.style_dotted))
            if i_show_labels and prob > 0
                array.push(buy_labels, label.new(bar_index + box_w, p, str.tostring(prob) + "%", style=label.style_label_left, color=buy_lbl_bg, textcolor=buy_label_base, size=f_label_size(i_label_size)))

// ══════════════════════════════════════════════════════════════
//  TABLE
// ══════════════════════════════════════════════════════════════

var table info_tbl = table.new(position.top_right, 2, 5, bgcolor=color.new(#0A0A12, 15), border_color=color.new(#2A2A3A, 60), border_width=1)

if barstate.islast
    table.cell(info_tbl, 0, 0, "LiqProb · DV", text_color=#8888AA, text_size=size.small)
    table.cell(info_tbl, 1, 0, "v2.0",           text_color=#555577, text_size=size.tiny)
    table.cell(info_tbl, 0, 1, "🟣 Sell Levels", text_color=i_sell_color, text_size=size.tiny)
    table.cell(info_tbl, 1, 1, str.tostring(array.size(sell_prices)), text_color=#CCBBFF, text_size=size.small)
    table.cell(info_tbl, 0, 2, "🟢 Buy Levels",  text_color=i_buy_color,  text_size=size.tiny)
    table.cell(info_tbl, 1, 2, str.tostring(array.size(buy_prices)),  text_color=#AAFFCC, text_size=size.small)
````
