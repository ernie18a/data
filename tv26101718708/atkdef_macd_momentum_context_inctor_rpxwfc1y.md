# ATK/DEF MACD Momentum Context  Inctor

- url: https://www.tradingview.com/script/RPxwfC1y/
- type: indicator
- pine_id: PUB;9c4ab23da26040cba3b6e9b92ac3506b
- version: 1.0

## Description

MACD Momentum Context is a momentum analysis indicator designed to help traders visualize MACD behavior, momentum changes, and market context through a structured dashboard.

This indicator focuses on analyzing the relationship between the MACD line, signal line, and histogram to provide a clearer view of momentum direction, momentum strength, and changes in market pressure.

Instead of displaying only traditional MACD values, this tool organizes multiple momentum conditions into an easy-to-read context view, allowing users to better understand how momentum is developing over time.

Features
📊 MACD Momentum Analysis

The indicator analyzes:

• MACD Line behavior
• Sign Line relationship
• Histogram direction
• Histogram expansion and contraction
• Momentum acceleration and slowdown

The histogram is evaluated based on its position and movement to help visualize whether momentum is increasing, weakening, or remaining balanced.

📈 Momentum Direction Context

The dashboard categorizes momentum conditions into different states:

• Bullish acceleration
• Bullish slowdown
• Bearish acceleration
• Bearish slowdown
• Sideways / balanced momentum

These states are based on MACD histogram behavior and are designed to help users quickly understand current momentum conditions.

🔥 Momentum Strength Measurement

The indicator compares current histogram strength with recent historical momentum range.

This helps visualize whether current momentum is:

• Moderate
• Strong
• Extreme

Strength classification is based on relative momentum expansion rather than fixed pric movement.

🔄 MACD Trend Context

The indicator evaluates the relationship between:

• MACD position above or below zero
• Histogram direction
• Sign line interaction

This creates a broader momentum context such as:

• Bullish momentum environment
• Bearish momentum environment
• Momentum transition area
• Neutral conditions

⚡ Momentum Change Tracking

The tool monitors changes in histogram behavior:

• Increasing momentum
• Decreasing momentum
• Stable momentum

This helps users observe whether current momentum is gaining strength or losing energy.

🔍 Divergence Observation

The indicator includes divergence detection based on price movement and MACD behavior.

It highlights situations where:

• Pric reaches a new high while MACD momentum does not confirm
• Pric reaches a new low while MACD momentum does not confirm

Divergence information is provided as a visual reference for studying momentum differences.

📋 Information Dashboard

The built-in table provides a structured overview of recent MACD conditions, including:

• Historical bar reference
• Momentum direction
• Momentum change
• Momentum strength
• MACD behavior
• Momentum edge
• MACD events and context

This allows users to review recent momentum development without manually interpreting multiple MACD components.

⚙️ Customization

Users can adjust:

• MACD fast length
• MACD slow length
• Sign length
• Number of bars displayed
• Table starting position

Different parameter settings can be used to study different market environments and timeframes.

Intended Use

MACD Momentum Context is designed as a market analysis and visualization tool.

It can be used to study:

• Momentum behavior
• Trend strength changes
• MACD structure
• Histogram development
• Potential momentum shifts

This indicator does not provide finan advice, trading recommendations, or guaranteed market outcomes. Users should combine this tool with their own analysis, risk management, and trading approach.

Notes

MACD Momentum Context is based on the traditional MACD concept with additional visualization and contextual analysis layers.

The indicator is intended to improve readability and understanding of momentum conditions by presenting multiple MACD measurements in a structured format.

## Source Code

````pine
//@version=6
indicator("MACD Momentum Context",overlay=false,precision=4,max_labels_count=100
)

// ========== 1. MACD Parameters ==========
fast_length = input.int(12, title="Fast Length", minval=1)
slow_length = input.int(26, title="Slow Length", minval=1)
signal_length = input.int(9, title="Signal Length", minval=1)

// ========== 1.5 Table Display Parameters ==========
table_rows = input.int(6, title="Bars to Show", minval=1, maxval=10, step=1)
table_offset = input.int(0, title="Start Offset", minval=0, maxval=10, step=1)

// ========== 2. Calculate MACD ==========
[macd_line, signal_line, hist_line] = ta.macd(close, fast_length, slow_length, signal_length)

// ========== 3. Zero Line Cross ==========
macd_cross_above_zero = ta.crossover(macd_line, 0)
macd_cross_below_zero = ta.crossunder(macd_line, 0)

// ========== 4. Golden/Death Cross ==========
macd_golden_cross = ta.crossover(macd_line, signal_line)
macd_death_cross = ta.crossunder(macd_line, signal_line)

// ========== 5. Histogram Color Change ==========
hist_turning_positive = hist_line > 0 and hist_line > hist_line[1]
hist_turning_negative = hist_line < 0 and hist_line < hist_line[1]
hist_reducing_positive = hist_line > 0 and hist_line < hist_line[1]
hist_reducing_negative = hist_line < 0 and hist_line > hist_line[1]

// ========== 6. MACD Divergence Detection (20 bars) ==========
price_new_high = high == ta.highest(high, 20)
macd_not_new_high = macd_line < ta.highest(macd_line[1], 20)
bearish_divergence = price_new_high and macd_not_new_high and macd_line > 0

price_new_low = low == ta.lowest(low, 20)
macd_not_new_low = macd_line > ta.lowest(macd_line[1], 20)
bullish_divergence = price_new_low and macd_not_new_low and macd_line < 0

// ========== 7. Plot MACD Lines ==========
plot(macd_line, color=color.new(color.blue, 0), linewidth=2, title="MACD Line")
plot(signal_line, color=color.new(color.orange, 0), linewidth=2, title="Signal Line")

hist_color_positive = color.from_gradient(hist_line, 0, ta.highest(hist_line, 50), color.new(color.green, 0), color.new(color.lime, 0))
hist_color_negative = color.from_gradient(hist_line, 0, ta.lowest(hist_line, 50), color.new(color.red, 0), color.new(color.fuchsia, 0))

plot(hist_line, 
     color=hist_line > 0 ? hist_color_positive : hist_color_negative, 
     style=plot.style_histogram, 
     linewidth=3,
     title="Histogram")

hline(0, color=color.new(color.white, 30), linestyle=hline.style_dashed, linewidth=1, title="Zero Line")

// ========== 8. Plot Event Labels ==========
if barstate.islast
    if macd_cross_above_zero
        label.new(bar_index, 10, text="↑Zero", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    if macd_cross_below_zero
        label.new(bar_index, -10, text="↓Zero", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if macd_golden_cross
        label.new(bar_index, 15, text="Golden", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    if macd_death_cross
        label.new(bar_index, -15, text="Death", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if bearish_divergence
        label.new(bar_index, 20, text="Bear Div", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)
    if bullish_divergence
        label.new(bar_index, -20, text="Bull Div", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)

// ========== 9. Table ==========
[macd_line_series, signal_line_series, hist_line_series] = ta.macd(close, fast_length, slow_length, signal_length)

var table myTable = table.new(position.bottom_right, 7, 7, border_color=color.gray, bgcolor=color.new(color.black, 0))

var headers = array.new_string(0)
var num_cols = 0

var bool headers_drawn = false

if not headers_drawn and barstate.islast
    headers := array.from(
        "Bar", 
        "Momentum Dir", 
        "Momentum Chg", 
        "Momentum Str", 
        "MACD Action", 
        "Momentum Edge",
        "MACD Signal"
    )
    num_cols := 7
    
    for col = 0 to num_cols - 1
        table.cell(myTable, col, 0, array.get(headers, col), text_color=color.white, text_size=size.small)
    headers_drawn := true

if barstate.islast
    rows = table_rows
    for i = 0 to rows - 1
        bar_idx = i + table_offset
        row = i + 1
        
        label_text = ""
        if i == 0 and table_offset == 0
            label_text := "Current 🔴"
        else
            label_text := "-" + str.tostring(i + table_offset) + ""
        
        macd_k = macd_line_series[bar_idx]
        signal_k = signal_line_series[bar_idx]
        hist_k = hist_line_series[bar_idx]
        
        var direction_text = ""
        var direction_color = color.white
        var change_text = ""
        var strength_text = ""
        var strength_color = color.white
        var macd_behavior = ""
        var macd_color = color.white
        var power_text = ""
        var power_color = color.white
        
        // ===== 1. Momentum Direction =====
        hist_rising_k = hist_k > hist_line_series[bar_idx + 1]
        hist_falling_k = hist_k < hist_line_series[bar_idx + 1]
        hist_positive_k = hist_k > 0
        hist_negative_k = hist_k < 0
        
        if hist_positive_k and hist_rising_k
            direction_text := "🟢 Bull Accel"
            direction_color := color.green
        else if hist_positive_k and hist_falling_k
            direction_text := "🟡 Bull Slow"
            direction_color := color.yellow
        else if hist_negative_k and hist_falling_k
            direction_text := "🔴 Bear Accel"
            direction_color := color.red
        else if hist_negative_k and hist_rising_k
            direction_text := "🟠 Bear Slow"
            direction_color := color.orange
        else
            direction_text := "⚪ Sideways"
            direction_color := color.gray
        
        // ===== 2. Momentum Change =====
        if hist_rising_k
            change_text := "📈 Increasing"
        else if hist_falling_k
            change_text := "📉 Decreasing"
        else
            change_text := "➡️ Flat"
        
        // ===== 3. Momentum Strength =====
        hist_max_50_k = ta.highest(math.abs(hist_line_series), 50)[bar_idx]
        if not na(hist_max_50_k) and hist_max_50_k > 0
            strength_k = math.abs(hist_k) / hist_max_50_k * 100
            if strength_k >= 60
                strength_text := "🔥 Extreme"
                strength_color := color.fuchsia
            else if strength_k >= 30
                strength_text := "💪 Strong"
                strength_color := color.lime
            else
                strength_text := "📊 Moderate"
                strength_color := color.yellow
        else
            strength_text := "📊 Moderate"
            strength_color := color.yellow
        
        // ===== 4. MACD Action =====
        if hist_positive_k and macd_k > 0
            macd_behavior := "🟢 Bull Trend"
            macd_color := color.green
        else if hist_negative_k and macd_k < 0
            macd_behavior := "🔴 Bear Trend"
            macd_color := color.red
        else if hist_positive_k and macd_k < 0
            macd_behavior := "🟠 Bear→Bull"
            macd_color := color.orange
        else if hist_negative_k and macd_k > 0
            macd_behavior := "🟠 Bull→Bear"
            macd_color := color.orange
        else
            macd_behavior := "⚪ Neutral"
            macd_color := color.gray
        
        // ===== 5. Momentum Edge =====
        if macd_k > 0 and hist_rising_k
            power_text := "🟢 Bull Dominant"
            power_color := color.green
        else if macd_k > 0 and hist_falling_k
            power_text := "🟡 Bull Fading"
            power_color := color.yellow
        else if macd_k < 0 and hist_falling_k
            power_text := "🔴 Bear Dominant"
            power_color := color.red
        else if macd_k < 0 and hist_rising_k
            power_text := "🟠 Bear Fading"
            power_color := color.orange
        else
            power_text := "⚪ Balanced"
            power_color := color.gray
        
        // ===== 6. MACD Signal =====
        event_text = ""
        meaning_text = ""
        
        if bar_idx < bar_index
            macd_next = macd_line_series[bar_idx + 1]
            signal_next = signal_line_series[bar_idx + 1]
            
            if macd_k > signal_k and macd_next <= signal_next
                event_text := "🔺 Golden Cross"
                meaning_text := "快线上穿慢线，多头启动"
            else if macd_k < signal_k and macd_next >= signal_next
                event_text := "🔻 Death Cross"
                meaning_text := "快线下穿慢线，空头启动"
            else if macd_k > 0 and macd_next <= 0
                event_text := "⬆️ Above Zero"
                meaning_text := "MACD由负转正，趋势转多"
            else if macd_k < 0 and macd_next >= 0
                event_text := "⬇️ Below Zero"
                meaning_text := "MACD由正转负，趋势转空"
            else if hist_positive_k and hist_rising_k and hist_line_series[bar_idx + 1] <= 0
                event_text := "🟢 Hist Bullish"
                meaning_text := "柱状线由负转正，多头启动"
            else if hist_negative_k and hist_falling_k and hist_line_series[bar_idx + 1] >= 0
                event_text := "🔴 Hist Bearish"
                meaning_text := "柱状线由正转负，空头启动"
        
        if event_text == "" and bar_idx == 0
            if bearish_divergence
                event_text := "🔻 Bear Divergence"
                meaning_text := "价格新高，MACD未新高"
            else if bullish_divergence
                event_text := "🔺 Bull Divergence"
                meaning_text := "价格新低，MACD未新低"
        
        if event_text == ""
            event_text := "-"
            meaning_text := "No Signal"
        
        signal_meaning = event_text + "：" + meaning_text
        
        // ===== Write Table =====
        table.cell(myTable, 0, row, label_text, text_color=color.white, text_size=size.small)
        table.cell(myTable, 1, row, direction_text, text_color=direction_color, text_size=size.small)
        table.cell(myTable, 2, row, change_text, text_color=color.white, text_size=size.small)
        table.cell(myTable, 3, row, strength_text, text_color=strength_color, text_size=size.small)
        table.cell(myTable, 4, row, macd_behavior, text_color=macd_color, text_size=size.small)
        table.cell(myTable, 5, row, power_text, text_color=power_color, text_size=size.small)
        table.cell(myTable, 6, row, signal_meaning, text_color=color.white, text_size=size.small)
````
