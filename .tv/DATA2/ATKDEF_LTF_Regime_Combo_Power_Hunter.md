<!-- tradingview-pine-id: PUB;960ff17563b04186b71d7aa48995d3a7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATK/DEF LTF Regime Combo — Power Hunter

Source: https://www.tradingview.com/script/9XWc4wO0/

## Description

# ATK/DEF LTF Regime Combo — Power Hunter

ATK/DEF LTF Regime Combo — Power Hunter is a multi-dimensional decision analysis indicator built around LTF (Lower Time Frame) market-state analysis**.

Its core concept is not simply combining EMA, RSI, ATR, Bollinger Bands, Volume, DMI, and other conventional calculations. Instead, these market inputs are processed into multiple analytical dimensions and evaluated through a unified scoring framework.

The resulting information is organized into **market states, scores, grades, and chart-based memory**, providing a structured view of the conditions observed on the LTF chart.

## Core Concept

The indicator combines:

**LTF + Regime + ATK/DEF + Decision System**

LTF provides the underlying market data environment.

Regime describes the current market state.

ATK/DEF represents changes between different market-force conditions.

The Decision System combines multiple dimensions into structured scores and state classifications.

Therefore, this is not simply an LTF indicator. It is a **decision-oriented market-state framework built from LTF data and multi-dimensional calculations**.

## Three Decision Combinations

### C1 — Direction / Momentum / Velocity / Behavior

C1 describes the primary price-state environment through four dimensions:

* Direction
* Momentum
* Velocity
* Behavior

The calculation incorporates EMA relationships, RSI conditions, price velocity, volume relationships, candle-body structure, and shadow behavior.

These components are combined into an independent C1 score and state classification.

### C2 — Battle / Hunting / Squeeze / Destruction

C2 focuses on market interaction and key-area behavior within the LTF environment:

* Battle — Alternating and consecutive candle behavior
* Hunting — Price behavior around key highs and lows
* Squeeze — Volatility compression
* Destruction — Structural and key-area changes

This combination evaluates how price behaves around local conditions, key areas, and changing volatility states.

### C3 — Absorption / Expansion / Impact / Decay

C3 focuses on changes in market activity and intensity:

* Absorption — The relationship between price, range, and volume
* Expansion — Volatility expansion
* Impact — Price impact and movement intensity
* Decay — Changes and decline in activity intensity

The calculations use price range, volume ratios, price movement, and sequential changes in market activity to produce an independent C3 state.

## Integrated Decision System

C1, C2, and C3 each calculate four internal dimensions and produce their own combination scores.

The three combinations are then aggregated into an overall score.

This creates a structured hierarchy:

**Individual Factors → Combination Scores → Overall Score → State → Grade**

The purpose is to consolidate multiple market dimensions into one decision-oriented observation framework rather than relying on a single calculation.

## Chart Memory

One of the key concepts of this indicator is **Chart Memory**.

The indicator does not only present the current calculated state. It also uses chart labels, structured tables, Swing High / Swing Low information, and structural connections to retain relevant recent market information visually.

The table presents:

* C1 factor scores
* C2 factor scores
* C3 factor scores
* C1 / C2 / C3 combination scores
* State
* Grade
* Overall Score

Swing High / Swing Low points, local support and resistance areas, and structural connections are also displayed within the same chart environment.

This creates a visual relationship between **market state, calculated information, and price structure**.

## ATK / DEF Regime

ATK/DEF in this framework is used to describe changes between different market-force conditions rather than simply classifying price direction.

The system evaluates multiple dimensions, including direction, momentum, velocity, behavior, market interaction, key-area reactions, compression, structural changes, absorption, expansion, impact, and decay.

The final output therefore represents a **multi-dimensional Regime State** generated from combined calculations rather than a single condition.

## LTF Market-State Framework

The indicator focuses on the following LTF market dimensions:

* Price Direction
* Momentum
* Velocity
* Candle Behavior
* Market Battle
* Key-Level Reaction
* Volatility Compression
* Structural Change
* Absorption
* Expansion
* Impact
* Decay
* Swing High / Swing Low

These components are processed through a unified calculation framework and converted into structured market-state information.

The objective is to consolidate fragmented market information into a single framework that makes different dimensions easier to observe and compare on the LTF chart.

## Chart Components

The indicator includes:

* C1 / C2 / C3 multi-dimensional analysis
* Integrated scoring system
* State classification
* Grade classification
* Overall Score
* Chart status label
* LTF market-state analysis
* EMA12 / EMA26
* RSI
* ATR
* Bollinger Bands
* Volume Analysis
* DMI / ADX
* Swing High / Swing Low
* Local structural connections
* Support and resistance markers
* FIFO object management
* Adjustable parameter system

## Parameter Adaptation

The indicator provides adjustable parameters for EMA, RSI, ATR, Bollinger Bands, Volume MA, DMI, Velocity Lookback, Key Level Lookback, and Swing High / Swing Low sensitivity.

Different markets, instruments, volatility conditions, and chart settings can produce different calculated results.

Users should therefore **configure and adjust the parameters according to the market environment being observed**.

Parameter settings directly affect the calculations, Swing structure, and resulting state classifications.

## Indicator Positioning

**ATK/DEF LTF Regime Combo — Power Hunter** is centered around:

**LTF Market Observation

* Multi-Dimensional Calculation
* ATK/DEF Regime
* Decision Combinations
* Integrated Scoring
* State / Grade
* Chart Memory**

The concept is not to simply add more indicators to a chart.

Instead, multiple market dimensions are processed through a unified framework and converted into structured state information, allowing the user to organize market information and observe relationships between different LTF conditions more efficiently.

This indicator provides **market observation, state information, and calculated reference data**. The output should not be interpreted as a guaranteed conclusion.

Parameters should be configured and adjusted according to the market environment being observed.

---

## Source Code

````pine
//@version=6
indicator("ATK/DEF LTF Regime Combo — Power Hunter", overlay=true, precision=0, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ============================================================================
// 1. INPUT PARAMETERS
// ============================================================================
length_ema12 = input.int(12, "EMA12 Period", minval=1)
length_ema26 = input.int(26, "EMA26 Period", minval=1)
length_rsi = input.int(14, "RSI Period", minval=1)
length_atr = input.int(14, "ATR Period", minval=1)
length_bb = input.int(20, "Bollinger Period", minval=1)
mult_bb = input.float(2.0, "Bollinger StdDev", minval=0.5, step=0.1)
length_vol_ma = input.int(12, "Volume MA Period", minval=1)
lookback_velocity = input.int(5, "Velocity Lookback", minval=2)
lookback_key = input.int(10, "Key Level Lookback", minval=3)
length_dmi = input.int(14, "DMI Length", minval=1)

// ===== Swing High/Low Parameters =====
leftBars = input.int(5, "Left Bars", minval=1, group="=== Swing Points ===")
rightBars = input.int(5, "Right Bars", minval=1, group="=== Swing Points ===")
showLabels = input.bool(true, "Show Pivot Labels", group="=== Swing Points ===")

// ===== Big Label Display =====
showBigLabel = input.bool(true, "Show Big Status Label", group="=== Big Label ===")

// ===== FIFO Management =====
max_objects = input.int(50, "Max Objects (FIFO)", minval=10, maxval=200, group="=== FIFO Management ===")

// ============================================================================
// 2. FIFO QUEUE MANAGEMENT
// ============================================================================
var int[] label_bars = array.new_int()
var label[] label_objects = array.new_label()
var int[] line_bars = array.new_int()
var line[] line_objects = array.new_line()
var int[] box_bars = array.new_int()
var box[] box_objects = array.new_box()

fifo_add_label(label_obj, bar_idx) =>
    array.push(label_objects, label_obj)
    array.push(label_bars, bar_idx)
    while array.size(label_objects) > max_objects
        old = array.shift(label_objects)
        array.shift(label_bars)
        label.delete(old)

fifo_add_line(line_obj, bar_idx) =>
    array.push(line_objects, line_obj)
    array.push(line_bars, bar_idx)
    while array.size(line_objects) > max_objects
        old = array.shift(line_objects)
        array.shift(line_bars)
        line.delete(old)

fifo_add_box(box_obj, bar_idx) =>
    array.push(box_objects, box_obj)
    array.push(box_bars, bar_idx)
    while array.size(box_objects) > max_objects
        old = array.shift(box_objects)
        array.shift(box_bars)
        box.delete(old)

fifo_cleanup() =>
    label_idx = array.size(label_bars) - 1
    while label_idx >= 0
        if array.get(label_bars, label_idx) < bar_index - max_objects
            lbl = array.remove(label_objects, label_idx)
            array.remove(label_bars, label_idx)
            label.delete(lbl)
        label_idx := label_idx - 1
    
    line_idx = array.size(line_bars) - 1
    while line_idx >= 0
        if array.get(line_bars, line_idx) < bar_index - max_objects
            ln = array.remove(line_objects, line_idx)
            array.remove(line_bars, line_idx)
            line.delete(ln)
        line_idx := line_idx - 1
    
    box_idx = array.size(box_bars) - 1
    while box_idx >= 0
        if array.get(box_bars, box_idx) < bar_index - max_objects
            bx = array.remove(box_objects, box_idx)
            array.remove(box_bars, box_idx)
            box.delete(bx)
        box_idx := box_idx - 1

// ============================================================================
// 3. BASE INDICATORS
// ============================================================================
ema12 = ta.ema(close, length_ema12)
ema26 = ta.ema(close, length_ema26)
rsi_val = ta.rsi(close, length_rsi)
atr_val = ta.atr(length_atr)
atr_ma = ta.sma(atr_val, length_vol_ma)

basis = ta.sma(close, length_bb)
dev = mult_bb * ta.stdev(close, length_bb)
bb_upper = basis + dev
bb_lower = basis - dev
bb_width = (bb_upper - bb_lower) / basis
bb_width_ma = ta.sma(bb_width, length_vol_ma)

vol_ma = ta.sma(volume, length_vol_ma)

[di_plus, di_minus, adx_val] = ta.dmi(length_dmi, length_dmi)

ema12_slope = ta.change(ema12, 1)
prev_rsi = rsi_val[1]
prev_close = close[1]
prev_bb_width = bb_width[1]

// ============================================================================
// 4. HELPER FUNCTIONS
// ============================================================================
get_percentile(src, length, pct) =>
    float[] values = array.new_float()
    for i = 0 to length - 1
        array.push(values, src[i])
    array.sort(values)
    int idx = math.floor(pct * (length - 1) / 100)
    float result = array.get(values, idx)
    array.clear(values)
    result

// ============================================================================
// 5. COMBO 1: Direction + Momentum + Velocity + Behavior
// ============================================================================
f_direction() =>
    float top_10 = high - (high - low) * 0.1
    float bot_10 = low + (high - low) * 0.1
    if close > ema12 and ema12 > ema26 and ema12_slope > 0 and close > top_10
        90
    else if close > ema12 and ema12 > ema26
        75
    else if close > ema12 and ema12 < ema26
        55
    else if close < ema12 and ema12 > ema26
        40
    else if close < ema12 and ema12 < ema26 and ema12_slope < 0 and close < bot_10
        15
    else if close < ema12 and ema12 < ema26
        25
    else
        50

f_momentum() =>
    float pct_change = (close - prev_close) / prev_close * 100
    if rsi_val >= 65 and rsi_val > prev_rsi and close > high[1]
        90
    else if rsi_val >= 55 and rsi_val < 65 and rsi_val > prev_rsi
        75
    else if rsi_val >= 45 and rsi_val <= 55 and math.abs(pct_change) < 0.3
        55
    else if rsi_val >= 35 and rsi_val < 45 and rsi_val < prev_rsi
        35
    else if rsi_val >= 20 and rsi_val < 35 and rsi_val < prev_rsi and close < low[1]
        20
    else if rsi_val < 20 or rsi_val > 80
        5
    else
        50

f_velocity() =>
    float pct_change = math.abs(close - prev_close) / prev_close * 100
    float avg_velocity = 0.0
    for i = 1 to lookback_velocity
        avg_velocity := avg_velocity + math.abs(close[i] - close[i+1]) / close[i+1] * 100
    avg_velocity := avg_velocity / lookback_velocity
    float vol_ratio = volume / vol_ma
    
    if pct_change > avg_velocity * 2.5 and vol_ratio > 2.0
        90
    else if pct_change > avg_velocity * 1.8 and vol_ratio > 1.5
        75
    else if pct_change >= avg_velocity * 0.6 and pct_change <= avg_velocity * 1.5
        55
    else if pct_change < avg_velocity * 0.6 and pct_change > avg_velocity * 0.3
        35
    else if pct_change < avg_velocity * 0.3 and vol_ratio < 0.8
        15
    else if pct_change < 0.05
        5
    else
        50

f_behavior() =>
    float body = math.abs(close - open)
    float shadow_upper = high - math.max(close, open)
    float shadow_lower = math.min(close, open) - low
    float total_shadow = shadow_upper + shadow_lower
    float body_ratio = body / (high - low)
    
    if body_ratio > 0.8 and total_shadow < body * 0.25
        90
    else if body_ratio > 0.7 and total_shadow < body * 0.5
        75
    else if body_ratio >= 0.5 and body_ratio <= 0.7
        55
    else if body_ratio >= 0.3 and body_ratio < 0.5
        35
    else if body_ratio >= 0.15 and body_ratio < 0.3
        15
    else if body_ratio < 0.15 and total_shadow > body * 3
        5
    else
        50

// ============================================================================
// 6. COMBO 2: Battle + Hunting + Squeeze + Destruction
// ============================================================================
f_game() =>
    bool alt_3 = (close > open and close[1] < open[1] and close[2] > open[2]) or
                 (close < open and close[1] > open[1] and close[2] < open[2])
    bool alt_2 = (close > open and close[1] < open[1]) or (close < open and close[1] > open[1])
    bool same_3 = close > open and close[1] > open[1] and close[2] > open[2]
    bool same_5 = same_3 and close[3] > open[3] and close[4] > open[4]
    bool strong_same = false
    if same_5
        strong_same := true
    
    if alt_3
        90
    else if alt_2
        75
    else if not alt_3 and not same_3
        55
    else if same_3 and not same_5
        30
    else if same_5 and not strong_same
        15
    else if strong_same
        5
    else
        50

f_hunting() =>
    float high_lookback = ta.highest(high, lookback_key)
    float low_lookback = ta.lowest(low, lookback_key)
    bool stop_hunt_high = high > high_lookback[1] and close <= high_lookback[1] and volume > vol_ma * 1.3
    bool stop_hunt_low = low < low_lookback[1] and close >= low_lookback[1] and volume > vol_ma * 1.3
    bool near_key_high = high > high_lookback[1] * 0.98 and high < high_lookback[1]
    bool near_key_low = low < low_lookback[1] * 1.02 and low > low_lookback[1]
    bool true_break_high = close > high_lookback[1] and volume > vol_ma * 1.5
    bool true_break_low = close < low_lookback[1] and volume > vol_ma * 1.5
    bool strong_trend = true_break_high or true_break_low
    
    if stop_hunt_high or stop_hunt_low
        90
    else if near_key_high or near_key_low
        55
    else if strong_trend
        10
    else if true_break_high or true_break_low
        25
    else
        40

f_squeeze() =>
    float bb_ratio = bb_width / bb_width_ma
    float atr_ratio = atr_val / atr_ma
    float bb_percentile = get_percentile(bb_width, 20, 90)
    
    if bb_width < bb_percentile * 0.1 and atr_ratio < 0.7
        90
    else if bb_width < bb_percentile * 0.25 and atr_ratio < 0.8
        75
    else if bb_width < bb_percentile * 0.5 and atr_ratio < 0.9
        55
    else if bb_width >= bb_percentile * 0.5 and bb_width <= bb_percentile * 0.8
        40
    else if bb_width > bb_percentile * 0.8 and bb_width < bb_percentile * 1.2
        25
    else if bb_width >= bb_percentile * 1.2
        10
    else
        50

f_destruction() =>
    float avg_body = 0.0
    for i = 1 to 10
        avg_body := avg_body + math.abs(close[i] - open[i])
    avg_body := avg_body / 10
    float body_ratio = math.abs(close - open) / avg_body
    
    float high_10 = ta.highest(high, lookback_key)
    float low_10 = ta.lowest(low, lookback_key)
    bool structure_break = close > high_10[1] or close < low_10[1]
    bool test_edge = close > high_10[1] * 0.98 or close < low_10[1] * 1.02
    bool fake_break = (high > high_10[1] or low < low_10[1]) and (close <= high_10[1] and close >= low_10[1])
    bool fake_reverse = fake_break and (close - open) * (close[1] - open[1]) < 0
    
    if structure_break and body_ratio > 1.8 and volume > vol_ma * 1.3
        90
    else if structure_break and body_ratio > 1.3
        75
    else if test_edge
        55
    else if fake_reverse
        10
    else if fake_break
        25
    else
        40

// ============================================================================
// 7. COMBO 3: Absorption + Expansion + Impact + Decay
// ============================================================================
f_absorption() =>
    float price_range = high - low
    float avg_range = ta.sma(high - low, length_vol_ma)
    float range_ratio = price_range / avg_range
    float vol_ratio = volume / vol_ma
    float price_change = math.abs(close - prev_close) / prev_close * 100
    
    if range_ratio > 1.2 and price_change < 0.15 and vol_ratio > 1.5
        90
    else if range_ratio > 1.0 and price_change < 0.2 and vol_ratio > 1.2
        75
    else if range_ratio > 0.8 and price_change < 0.3 and vol_ratio > 1.0
        55
    else if price_change > 0.5 and vol_ratio > 1.3
        25
    else if price_change > 1.0 and vol_ratio > 1.5
        10
    else
        40

f_expansion() =>
    float price_range = high - low
    float avg_range = ta.sma(high - low, length_vol_ma)
    float range_ratio = price_range / avg_range
    float vol_ratio = volume / vol_ma
    float range_percentile = get_percentile(high - low, 20, 90)
    
    if range_ratio > range_percentile * 1.8 and vol_ratio > 1.5
        90
    else if range_ratio > range_percentile * 1.4 and vol_ratio > 1.2
        75
    else if range_ratio > range_percentile * 1.1 and vol_ratio > 1.0
        55
    else if range_ratio >= range_percentile * 0.7 and range_ratio <= range_percentile * 1.1
        40
    else if range_ratio < range_percentile * 0.5
        20
    else if range_ratio < range_percentile * 0.3
        5
    else
        50

f_impact() =>
    float pct_change = math.abs(close - prev_close) / prev_close * 100
    float avg_pct_change = 0.0
    for i = 1 to 10
        avg_pct_change := avg_pct_change + math.abs(close[i] - close[i+1]) / close[i+1] * 100
    avg_pct_change := avg_pct_change / 10
    float vol_ratio = volume / vol_ma
    float high_10 = ta.highest(high, lookback_key)
    float low_10 = ta.lowest(low, lookback_key)
    bool hit_key = close > high_10[1] or close < low_10[1]
    
    if pct_change > avg_pct_change * 3.0 and vol_ratio > 1.8 and hit_key
        90
    else if pct_change > avg_pct_change * 2.0 and vol_ratio > 1.3
        75
    else if pct_change > avg_pct_change * 1.5 and vol_ratio > 1.0
        55
    else if pct_change < avg_pct_change * 0.5 and vol_ratio < 0.8
        20
    else if pct_change < avg_pct_change * 0.3 and vol_ratio < 0.6
        5
    else
        40

f_decay() =>
    float pct_change = math.abs(close - prev_close) / prev_close * 100
    float pct_change_1 = math.abs(close[1] - close[2]) / close[2] * 100
    float pct_change_2 = math.abs(close[2] - close[3]) / close[3] * 100
    float vol_ratio = volume / vol_ma
    float vol_ratio_1 = volume[1] / vol_ma[1]
    float vol_ratio_2 = volume[2] / vol_ma[2]
    
    bool decay_3 = pct_change < pct_change_1 and pct_change_1 < pct_change_2
    bool decay_3_vol = vol_ratio < vol_ratio_1 and vol_ratio_1 < vol_ratio_2
    bool accel_3 = pct_change > pct_change_1 and pct_change_1 > pct_change_2
    bool accel_3_vol = vol_ratio > vol_ratio_1 and vol_ratio_1 > vol_ratio_2
    
    if decay_3 and decay_3_vol
        90
    else if decay_3
        75
    else if pct_change < pct_change_1 and pct_change_1 > pct_change_2
        55
    else if not decay_3 and not accel_3
        40
    else if accel_3 and not accel_3_vol
        20
    else if accel_3 and accel_3_vol
        5
    else
        50

// ============================================================================
// 8. CALCULATE COMBO SCORES
// ============================================================================
c1_dir = f_direction()
c1_mom = f_momentum()
c1_vel = f_velocity()
c1_behavior = f_behavior()
c1_score = (c1_dir + c1_mom + c1_vel + c1_behavior) / 4

c2_game = f_game()
c2_hunting = f_hunting()
c2_squeeze = f_squeeze()
c2_destruction = f_destruction()
c2_score = (c2_game + c2_hunting + c2_squeeze + c2_destruction) / 4

c3_absorption = f_absorption()
c3_expansion = f_expansion()
c3_impact = f_impact()
c3_decay = f_decay()
c3_score = (c3_absorption + c3_expansion + c3_impact + c3_decay) / 4

total_score = (c1_score + c2_score + c3_score) / 3

// ============================================================================
// 9. STATE LABELS
// ============================================================================
get_c1_label(score) =>
    if score >= 80
        "Strong Bull"
    else if score >= 60
        "Weak Bull"
    else if score >= 40
        "Neutral"
    else if score >= 20
        "Weak Bear"
    else
        "Strong Bear"

get_c2_label(score) =>
    if score >= 80
        "Heavy Battle"
    else if score >= 60
        "Moderate Battle"
    else if score >= 40
        "Light Battle"
    else if score >= 20
        "Trend Dominant"
    else
        "Extreme Trend"

get_c3_label(score) =>
    if score >= 80
        "Strong Expansion"
    else if score >= 60
        "Moderate Expansion"
    else if score >= 40
        "Normal"
    else if score >= 20
        "Contraction"
    else
        "Strong Contraction"

get_grade(score) =>
    if score >= 80
        "Grade A"
    else if score >= 60
        "Grade B"
    else if score >= 40
        "Grade C"
    else if score >= 20
        "Grade D"
    else
        "Grade E"

get_grade_color(score) =>
    if score >= 80
        color.green
    else if score >= 60
        color.lime
    else if score >= 40
        color.yellow
    else if score >= 20
        color.orange
    else
        color.red

get_total_signal(c1, c2, c3) =>
    avg = (c1 + c2 + c3) / 3
    if avg >= 80
        ["🔥 Strong Buy", color.green]
    else if avg >= 60
        ["📈 Bullish", color.lime]
    else if avg >= 40
        ["⏸️ Wait & See", color.yellow]
    else if avg >= 20
        ["📉 Bearish", color.orange]
    else
        ["🔻 Strong Sell", color.red]

// ============================================================================
// 10. BIG LABEL DISPLAY
// ============================================================================
if showBigLabel and barstate.islast
    c1_label = get_c1_label(c1_score)
    c2_label = get_c2_label(c2_score)
    c3_label = get_c3_label(c3_score)
    
    [signal, signal_color] = get_total_signal(c1_score, c2_score, c3_score)
    
    label_text = "【ATK/DEF LTF Regime Combo — Power Hunter】\n" +
                 "C1: " + c1_label + " (" + str.tostring(c1_score, "#") + "%)  |  " +
                 "C2: " + c2_label + " (" + str.tostring(c2_score, "#") + "%)  |  " +
                 "C3: " + c3_label + " (" + str.tostring(c3_score, "#") + "%)\n" +
                 "Total: " + str.tostring(total_score, "#") + "%  |  " +
                 "Signal: " + signal
    
    label.new(bar_index, high + (high - low) * 8,
              text=label_text,
              color=color.rgb(0,0,0, 85),
              textcolor=signal_color,
              style=label.style_label_down,
              size=size.large,
              text_font_family=font.family_default)

// ============================================================================
// 11. TABLE (Bottom Right)
// ============================================================================
if barstate.islast
    sz = size.small
    var table tbl = table.new(position.bottom_right, columns=8, rows=6,
                              bgcolor=color.rgb(0,0,0, 92), border_color=color.gray, border_width=1)
    
    table.cell(tbl, 0, 0, " ATK/DEF LTF Regime Combo — Power Hunter", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 2, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 3, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 4, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 5, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 6, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    table.cell(tbl, 7, 0, "", text_color=color.yellow, bgcolor=color.rgb(40,20,0), text_size=sz)
    
    table.cell(tbl, 0, 1, "Module", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 1, "Factor 1", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 2, 1, "Factor 2", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 3, 1, "Factor 3", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 4, 1, "Factor 4", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 5, 1, "SCORE", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 6, 1, "State", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 7, 1, "Grade", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    
    c1_bg = color.from_gradient(c1_score, 0, 100, color.red, color.green)
    table.cell(tbl, 0, 2, "C1", text_color=color.orange, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 2, "Dir "+str.tostring(c1_dir, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c1_dir, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 2, 2, "Mom "+str.tostring(c1_mom, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c1_mom, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 3, 2, "Vel "+str.tostring(c1_vel, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c1_vel, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 4, 2, "Beh "+str.tostring(c1_behavior, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c1_behavior, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 5, 2, str.tostring(c1_score, "#")+"%", text_color=color.white, bgcolor=c1_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 6, 2, get_c1_label(c1_score), text_color=color.white, bgcolor=c1_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 7, 2, get_grade(c1_score), text_color=get_grade_color(c1_score), bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    
    c2_bg = color.from_gradient(c2_score, 0, 100, color.red, color.green)
    table.cell(tbl, 0, 3, "C2", text_color=color.aqua, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 3, "Battle "+str.tostring(c2_game, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c2_game, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 2, 3, "Hunt "+str.tostring(c2_hunting, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c2_hunting, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 3, 3, "Squeeze "+str.tostring(c2_squeeze, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c2_squeeze, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 4, 3, "Dest "+str.tostring(c2_destruction, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c2_destruction, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 5, 3, str.tostring(c2_score, "#")+"%", text_color=color.white, bgcolor=c2_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 6, 3, get_c2_label(c2_score), text_color=color.white, bgcolor=c2_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 7, 3, get_grade(c2_score), text_color=get_grade_color(c2_score), bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    
    c3_bg = color.from_gradient(c3_score, 0, 100, color.red, color.green)
    table.cell(tbl, 0, 4, "C3", text_color=color.yellow, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 4, "Absorb "+str.tostring(c3_absorption, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c3_absorption, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 2, 4, "Expand "+str.tostring(c3_expansion, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c3_expansion, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 3, 4, "Impact "+str.tostring(c3_impact, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c3_impact, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 4, 4, "Decay "+str.tostring(c3_decay, "#")+"%", text_color=color.white, bgcolor=color.from_gradient(c3_decay, 0, 100, color.red, color.green), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 5, 4, str.tostring(c3_score, "#")+"%", text_color=color.white, bgcolor=c3_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 6, 4, get_c3_label(c3_score), text_color=color.white, bgcolor=c3_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 7, 4, get_grade(c3_score), text_color=get_grade_color(c3_score), bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    
    total_bg = color.from_gradient(total_score, 0, 100, color.red, color.green)
    table.cell(tbl, 0, 5, "Total", text_color=color.yellow, bgcolor=color.rgb(30,30,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 1, 5, "C1:"+str.tostring(c1_score,"#")+"%", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 2, 5, "C2:"+str.tostring(c2_score,"#")+"%", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 3, 5, "C3:"+str.tostring(c3_score,"#")+"%", text_color=color.white, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 4, 5, "Total", text_color=color.yellow, bgcolor=color.rgb(20,20,30), text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 5, 5, str.tostring(total_score,"#")+"%", text_color=color.white, bgcolor=total_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 6, 5, get_grade(total_score), text_color=get_grade_color(total_score), bgcolor=total_bg, text_size=sz, text_halign=text.align_center)
    table.cell(tbl, 7, 5, "", text_color=color.gray, bgcolor=color.rgb(20,20,30), text_size=sz)

// ============================================================================
// 12. PLOT MOVING AVERAGES
// ============================================================================
plot(ema12, "EMA12", color=color.new(color.blue, 70), linewidth=1)
plot(ema26, "EMA26", color=color.new(color.red, 70), linewidth=1)

// ============================================================================
// 13. SWING HIGH/LOW LABELS (FIFO Managed)
// ============================================================================
swingHigh = ta.pivothigh(leftBars, rightBars)
swingLow = ta.pivotlow(leftBars, rightBars)

if showLabels
    if not na(swingHigh)
        lbl = label.new(bar_index[rightBars], swingHigh,
                  text="🔴 RES\n" + str.tostring(swingHigh, "#.##"),
                  color=color.rgb(200,0,0, 85), textcolor=color.white,
                  style=label.style_label_down, size=size.small)
        fifo_add_label(lbl, bar_index)
    
    if not na(swingLow)
        lbl = label.new(bar_index[rightBars], swingLow,
                  text="🟢 SUP\n" + str.tostring(swingLow, "#.##"),
                  color=color.rgb(0,150,0, 85), textcolor=color.white,
                  style=label.style_label_up, size=size.small)
        fifo_add_label(lbl, bar_index)

// ============================================================================
// 14. SWING HIGH/LOW LINES (FIFO Managed)
// ============================================================================
var float last_swing_high_price = na
var int last_swing_high_bar = na

if not na(swingHigh)
    if not na(last_swing_high_price)
        ln = line.new(last_swing_high_bar, last_swing_high_price, 
                      bar_index[rightBars], swingHigh,
                      color=color.new(color.red, 60), width=1, style=line.style_dashed)
        fifo_add_line(ln, bar_index)
    last_swing_high_price := swingHigh
    last_swing_high_bar := bar_index[rightBars]

var float last_swing_low_price = na
var int last_swing_low_bar = na

if not na(swingLow)
    if not na(last_swing_low_price)
        ln = line.new(last_swing_low_bar, last_swing_low_price,
                      bar_index[rightBars], swingLow,
                      color=color.new(color.green, 60), width=1, style=line.style_dashed)
        fifo_add_line(ln, bar_index)
    last_swing_low_price := swingLow
    last_swing_low_bar := bar_index[rightBars]

// ============================================================================
// 15. FIFO CLEANUP
// ============================================================================
fifo_cleanup()
````
