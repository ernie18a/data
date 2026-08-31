<!-- tradingview-pine-id: PUB;92c898b237ff4c3e800b1ffc2d8e6e66 -->
<!-- tradingviewscripts-format: 1 -->
# First Passage Time - Distribution Analysis

Source: https://www.tradingview.com/script/NWJy3xPv-First-Passage-Time-Distribution-Analysis/

## Description

The First Passage Time (FPT) Distribution Analysis indicator is a sophisticated probabilistic tool that answers one of the most critical questions in trading: "How long will it take for price to reach my target, and what are the odds of getting there first?"

Unlike traditional technical indicators that focus on what might happen, this indicator tells you when it's likely to happen.

Mathematical Foundation: First Passage Time Theory
What is First Passage Time?
First Passage Time (FPT) is a concept in stochastic processes that measures the time it takes for a random process to reach a specific threshold for the first time. Originally developed in physics and mathematics, FPT has applications in:

[*]Quantitative Finance: Option pricing, risk management, and algorithmic trading
[*]Neuroscience: Modeling neural firing patterns
[*]Biology: Population dynamics and disease spread
[*]Engineering: Reliability analysis and failure prediction

The Mathematics Behind It
This indicator uses Geometric Brownian Motion (GBM), the same stochastic model used in the Black-Scholes option pricing formula:

dS = μS dt + σS dW

Where:
S = Asset price
μ = Drift (trend component)
σ = Volatility (uncertainty component)
dW = Wiener process (random walk)

Through Monte Carlo simulation, the indicator runs 1,000+ price path simulations to statistically determine:

[*]When each threshold (+X% or -X%) is likely to be hit
[*]Which threshold is hit first (directional bias)
[*]How often each scenario occurs (probability distribution)

🎯 How This Indicator Works
Core Algorithm Workflow: 

[*]Calculate Historical Statistics
[*]Measures recent price volatility (standard deviation of log returns)
[*]Calculates drift (average directional movement)
[*]Annualizes these metrics for meaningful comparison
[*]Run Monte Carlo Simulations
[*]Generates 1,000+ random price paths based on historical behavior
[*]Tracks when each path hits the upside (+X%) or downside (-X%) threshold
[*]Records which threshold was hit first in each simulation
[*]Aggregate Statistical Results
[*]Calculates percentile distributions (10th, 25th, 50th, 75th, 90th)
[*]Computes "first hit" probabilities (upside vs downside)
[*]Determines average and median time-to-target
[*]Visual Representation
[*]Displays thresholds as horizontal lines
[*]Shows gradient risk zones (purple-to-blue)
[*]Provides comprehensive statistics table

📈 Use Cases
1. Options Trading

[*]Selling Options: Determine if your strike price is likely to be hit before expiration
[*]Buying Options: Estimate probability of reaching profit targets within your time window
[*]Time Decay Management: Compare expected time-to-target vs theta decay
[*]Example: You're considering selling a 30-day call option 5% out of the money. The indicator shows there's a 72% chance price hits +5% within 12 days. This tells you the trade has high assignment risk.

2. Swing Trading

[*]Entry Timing: Wait for higher probability setups when directional bias is strong
[*]Target Setting: Use median time-to-target to set realistic profit expectations
[*]Stop Loss Placement: Understand probability of hitting your stop before target
[*]Example: The indicator shows 85% upside probability with median time of 3.2 days. You can confidently enter long positions with appropriate position sizing.

3. Risk Management

[*]Position Sizing: Larger positions when probability heavily favors one direction
[*]Portfolio Allocation: Reduce exposure when probabilities are near 50/50 (high uncertainty)
[*]Hedge Timing: Know when to add protective positions based on downside probability
[*]Example: Indicator shows 55% upside vs 45% downside—nearly neutral. This signals high uncertainty, suggesting reduced position size or wait for better setup.

4. Market Regime Detection

[*]Trending Markets: High directional bias (70%+ one direction)
[*]Range-bound Markets: Balanced probabilities (45-55% both directions)
[*]Volatility Regimes: Compare actual vs theoretical minimum time
[*]Example: Consistent 90%+ bullish bias across multiple timeframes confirms strong uptrend—stay long and avoid counter-trend trades.

First Hit Rate (Most Important!)
Shows which threshold is likely to be hit FIRST:

[*]Upside %: Probability of hitting upside target before downside
[*]Downside %: Probability of hitting downside target before upside
[*]These always sum to 100%

⚠️ Warning: If you see "Low Hit Rate" warning, increase this parameter!

Advanced Parameters
Drift Mode
Allows you to explore different scenarios:

[*]Historical: Uses actual recent trend (default—most realistic)
[*]Zero (Neutral): Assumes no trend, only volatility (symmetric probabilities)
[*]50% Reduced: Dampens trend effect (conservative scenario)
[*]Use Case: Switch to "Zero (Neutral)" to see what happens in a pure volatility environment, useful for range-bound markets.

Distribution Type

[*]Percentile: Shows 10%, 25%, 50%, 75%, 90% levels (recommended for most users)
[*]Sigma: Shows standard deviation levels (1σ, 2σ)—useful for statistical analysis

⚠️ Important Limitations & Best Practices
Limitations

[*]Assumes GBM: Real markets have fat tails, jumps, and regime changes not captured by GBM
[*]Historical Parameters: Uses recent volatility/drift—may not predict regime shifts
[*]No Fundamental Events: Cannot predict earnings, news, or macro shocks
[*]Computational: Runs only on last bar—doesn't give historical signals

Remember: Probabilities are not certainties. Use this indicator as part of a comprehensive trading plan with proper risk management.

Created by: Henrique Centieiro. feedback is more than welcome!

---

## Source Code

````pine
//@version=5
// First Passage Time - Distribution Analysis
// Created by: Henrique Centieiro 
// October 2025
indicator("First Passage Time - Distribution Analysis", overlay=true)

// Input Parameters
threshold_pct = input.float(5.0, "Threshold %", minval=0.1, maxval=50.0, step=0.1)
volatility_period = input.int(60, "Volatility Lookback Period", minval=20, maxval=500)
num_simulations = input.int(1000, "Monte Carlo Simulations", minval=500, maxval=2000, step=100)
show_zones = input.bool(true, "Show Risk Zones")
show_labels = input.bool(true, "Show Chart Labels")
distribution_type = input.string("Percentile", "Distribution Type", options=["Percentile", "Sigma"])
max_periods = input.int(1000, "Maximum Periods to Simulate", minval=100, maxval=5000, step=50)
projection_bars = input.int(25, "Projection Bars", minval=10, maxval=100, step=5)
show_diagnostics = input.bool(false, "Show Diagnostics")
drift_mode = input.string("Historical", "Drift Mode", options=["Historical", "Zero (Neutral)", "50% Reduced"], tooltip="Adjust drift to explore different scenarios")

// NEW: Label customization options
label_size_option = input.string("Normal", "Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
label_upside_color = input.color(color.new(color.green, 10), "Upside Label Color")
label_downside_color = input.color(color.new(color.red, 10), "Downside Label Color")
label_text_color = input.color(color.white, "Label Text Color")

// NEW: Table font size option
table_font_size = input.string("Normal", "Table Font Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])

// Get timeframe in minutes
tf_minutes = timeframe.in_seconds() / 60

// Calculate returns and volatility
returns = math.log(close / close[1])
volatility = ta.stdev(returns, volatility_period)
drift_raw = ta.sma(returns, volatility_period)

// Adjust drift based on mode
drift = drift_mode == "Zero (Neutral)" ? 0.0 : drift_mode == "50% Reduced" ? drift_raw * 0.5 : drift_raw

// Arrays to store first passage times
upside_fpt = array.new<float>()
downside_fpt = array.new<float>()

// Variables for results
var float up_median = na
var float down_median = na
var int up_first = 0
var int down_first = 0
var float up_mean = na
var float down_mean = na

// Helper function to convert string to label size
get_label_size(size_str) =>
    size_str == "Tiny" ? size.tiny : size_str == "Small" ? size.small : size_str == "Large" ? size.large : size_str == "Huge" ? size.huge : size.normal

// Helper function to convert string to table text size
get_table_size(size_str) =>
    size_str == "Tiny" ? size.tiny : size_str == "Small" ? size.small : size_str == "Large" ? size.large : size_str == "Huge" ? size.huge : size.normal

if barstate.islast
    array.clear(upside_fpt)
    array.clear(downside_fpt)
    
    current_price = close
    up_mult = 1 + threshold_pct / 100
    down_mult = 1 - threshold_pct / 100
    
    up_threshold = current_price * up_mult
    down_threshold = current_price * down_mult
    
    drift_component = drift - 0.5 * volatility * volatility
    
    if na(volatility) or volatility <= 0
        runtime.error("Invalid volatility - need more price history")
    
    // Run simulations
    for sim = 1 to num_simulations
        price = current_price
        up_hit = false
        down_hit = false
        up_time = float(na)
        down_time = float(na)
        first_hit = ""
        
        for period = 1 to max_periods
            u1 = math.random()
            u2 = math.random()
            
            if u1 < 0.0001
                u1 := 0.0001
            
            z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
            
            price := price * math.exp(drift_component + volatility * z)
            
            // Check which threshold is hit first
            if not up_hit and price >= up_threshold
                up_hit := true
                up_time := period
                if first_hit == ""
                    first_hit := "up"
            
            if not down_hit and price <= down_threshold
                down_hit := true
                down_time := period
                if first_hit == ""
                    first_hit := "down"
            
            // Early exit if both hit
            if up_hit and down_hit
                break
        
        // Store results
        array.push(upside_fpt, up_time)
        array.push(downside_fpt, down_time)
    
    // Calculate statistics - which was hit FIRST
    up_first := 0
    down_first := 0
    up_sum = 0.0
    down_sum = 0.0
    up_count = 0
    down_count = 0
    
    for i = 0 to array.size(upside_fpt) - 1
        val_up = array.get(upside_fpt, i)
        val_down = array.get(downside_fpt, i)
        
        // Count which was hit first
        if not na(val_up) and not na(val_down)
            if val_up < val_down
                up_first += 1
            else if val_down < val_up
                down_first += 1
            // If equal (rare), don't count either
        else if not na(val_up)
            up_first += 1
        else if not na(val_down)
            down_first += 1
        
        // Calculate average time when hit
        if not na(val_up)
            up_sum += val_up
            up_count += 1
        
        if not na(val_down)
            down_sum += val_down
            down_count += 1
    
    up_mean := up_count > 0 ? up_sum / up_count : na
    down_mean := down_count > 0 ? down_sum / down_count : na

percentile(arr, pct) =>
    if array.size(arr) == 0
        float(na)
    else
        valid_values = array.new<float>()
        for i = 0 to array.size(arr) - 1
            val = array.get(arr, i)
            if not na(val)
                array.push(valid_values, val)
        
        if array.size(valid_values) == 0
            float(na)
        else
            array.sort(valid_values, order.ascending)
            min_samples_needed = pct < 1 ? 10 : 5
            if array.size(valid_values) < min_samples_needed
                float(na)
            else
                idx = math.floor(array.size(valid_values) * pct / 100)
                idx := math.min(math.max(idx, 0), array.size(valid_values) - 1)
                array.get(valid_values, idx)

sigma_to_percentile_lower(sigma) =>
    if sigma == 1
        15.87
    else if sigma == 2
        2.28
    else
        50.0

format_time(periods) =>
    if na(periods)
        "N/A"
    else
        total_minutes = periods * tf_minutes
        
        if total_minutes < 120
            str.tostring(math.round(total_minutes, 0)) + "m"
        else if total_minutes < 5760
            hours = total_minutes / 60
            str.tostring(math.round(hours, 1)) + "h"
        else
            days = total_minutes / 1440
            str.tostring(math.round(days, 1)) + "d"

if barstate.islast
    up_median := percentile(upside_fpt, 50)
    down_median := percentile(downside_fpt, 50)

// Display results table
var table results_table = table.new(position.top_right, 3, 18, border_width=2, border_color=color.white, frame_width=2, frame_color=color.white)

if barstate.islast
    table.clear(results_table, 0, 0, 2, 17)
    
    level_header = distribution_type == "Percentile" ? "Percentile" : "Std Dev"
    
    table_size = get_table_size(table_font_size)
    table_size_small = table_font_size == "Tiny" ? size.tiny : table_font_size == "Small" ? size.tiny : table_font_size == "Large" ? size.normal : table_font_size == "Huge" ? size.large : size.small
    
    // Headers
    table.cell(results_table, 0, 0, level_header, bgcolor=color.new(color.blue, 0), text_color=color.white, text_size=table_size)
    table.cell(results_table, 1, 0, "Upside +" + str.tostring(threshold_pct, "#.#") + "%", bgcolor=color.new(color.green, 0), text_color=color.white, text_size=table_size)
    table.cell(results_table, 2, 0, "Downside -" + str.tostring(threshold_pct, "#.#") + "%", bgcolor=color.new(color.red, 0), text_color=color.white, text_size=table_size)
    
    row = 1
    
    if distribution_type == "Percentile"
        percentiles = array.from(10.0, 25.0, 50.0, 75.0, 90.0)
        
        for i = 0 to array.size(percentiles) - 1
            pct = array.get(percentiles, i)
            up_time = percentile(upside_fpt, pct)
            down_time = percentile(downside_fpt, pct)
            
            bg_color = i % 2 == 0 ? color.new(color.gray, 60) : color.new(color.gray, 75)
            
            up_text = format_time(up_time)
            down_text = format_time(down_time)
            
            table.cell(results_table, 0, row, str.tostring(pct, "#") + "%", bgcolor=bg_color, text_color=color.white, text_size=table_size)
            table.cell(results_table, 1, row, up_text, bgcolor=color.new(color.green, 60), text_color=color.white, text_size=table_size)
            table.cell(results_table, 2, row, down_text, bgcolor=color.new(color.red, 60), text_color=color.white, text_size=table_size)
            row += 1
    else
        sigmas_to_show = array.from(2, 1)
        
        for i = 0 to array.size(sigmas_to_show) - 1
            sigma = array.get(sigmas_to_show, i)
            pct = sigma_to_percentile_lower(sigma)
            up_time = percentile(upside_fpt, pct)
            down_time = percentile(downside_fpt, pct)
            
            bg_color = i % 2 == 0 ? color.new(color.gray, 60) : color.new(color.gray, 75)
            
            up_text = format_time(up_time)
            down_text = format_time(down_time)
            
            prob_text = str.tostring(pct, "#.##") + "%"
            
            table.cell(results_table, 0, row, str.tostring(sigma) + "σ (" + prob_text + ")", bgcolor=bg_color, text_color=color.white, text_size=table_size)
            table.cell(results_table, 1, row, up_text, bgcolor=color.new(color.green, 60), text_color=color.white, text_size=table_size)
            table.cell(results_table, 2, row, down_text, bgcolor=color.new(color.red, 60), text_color=color.white, text_size=table_size)
            row += 1
        
        row += 1
        table.cell(results_table, 0, row, "Theoretical Min", bgcolor=color.new(color.purple, 0), text_color=color.white, text_size=table_size_small)
        
        theoretical_up = (threshold_pct / 100) / (volatility * 3)
        theoretical_down = (threshold_pct / 100) / (volatility * 3)
        
        table.cell(results_table, 1, row, "~" + format_time(theoretical_up), bgcolor=color.new(color.purple, 60), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 2, row, "~" + format_time(theoretical_down), bgcolor=color.new(color.purple, 60), text_color=color.white, text_size=table_size_small)
    
    row += 1
    
    // Hit Rate - now shows which was hit FIRST
    row += 1
    total_first_hits = up_first + down_first
    up_hit_rate = total_first_hits > 0 ? (up_first / total_first_hits) * 100 : 0.0
    down_hit_rate = total_first_hits > 0 ? (down_first / total_first_hits) * 100 : 0.0
    
    hit_rate_label = "First Hit Rate\n(" + str.tostring(up_first) + " ↑  " + str.tostring(down_first) + " ↓)"
    
    table.cell(results_table, 0, row, hit_rate_label, bgcolor=color.new(color.orange, 0), text_color=color.white, text_size=table_size_small)
    table.cell(results_table, 1, row, str.tostring(up_hit_rate, "#.#") + "%", bgcolor=color.new(color.green, 60), text_color=color.white, text_size=table_size)
    table.cell(results_table, 2, row, str.tostring(down_hit_rate, "#.#") + "%", bgcolor=color.new(color.red, 60), text_color=color.white, text_size=table_size)
    
    // Warning if total hits are low
    if total_first_hits < num_simulations * 0.9
        row += 1
        table.cell(results_table, 0, row, "⚠️ Low Hit Rate", bgcolor=color.new(color.orange, 0), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 1, row, "Increase Max", bgcolor=color.new(color.orange, 60), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 2, row, "Periods!", bgcolor=color.new(color.orange, 60), text_color=color.white, text_size=table_size_small)
    
    // Average Time
    row += 1
    table.cell(results_table, 0, row, "Avg Time\n(if hit)", bgcolor=color.new(color.orange, 0), text_color=color.white, text_size=table_size_small)
    table.cell(results_table, 1, row, format_time(up_mean), bgcolor=color.new(color.green, 60), text_color=color.white, text_size=table_size)
    table.cell(results_table, 2, row, format_time(down_mean), bgcolor=color.new(color.red, 60), text_color=color.white, text_size=table_size)
    
    // Directional Bias
    row += 1
    bias = up_hit_rate > down_hit_rate ? "Bullish ↑" : down_hit_rate > up_hit_rate ? "Bearish ↓" : "Neutral ↔"
    bias_color = up_hit_rate > down_hit_rate ? color.green : down_hit_rate > up_hit_rate ? color.red : color.gray
    bias_strength = math.abs(up_hit_rate - down_hit_rate)
    
    table.cell(results_table, 0, row, "Directional Bias", bgcolor=color.new(color.orange, 0), text_color=color.white, text_size=table_size)
    table.cell(results_table, 1, row, bias, bgcolor=color.new(bias_color, 60), text_color=color.white, text_size=table_size)
    table.cell(results_table, 2, row, str.tostring(bias_strength, "#.#") + "%", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=table_size)
    
    // Diagnostics
    if show_diagnostics
        row += 1
        ann_drift = drift_raw * math.sqrt(525600 / tf_minutes) * 100
        table.cell(results_table, 0, row, "Ann. Drift", bgcolor=color.new(color.purple, 0), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 1, row, str.tostring(ann_drift, "#.##") + "%", bgcolor=color.new(color.purple, 60), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 2, row, "", bgcolor=color.new(color.purple, 60))
        
        row += 1
        table.cell(results_table, 0, row, "Drift Mode", bgcolor=color.new(color.purple, 0), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 1, row, drift_mode, bgcolor=color.new(color.purple, 60), text_color=color.white, text_size=table_size_small)
        table.cell(results_table, 2, row, "", bgcolor=color.new(color.purple, 60))
    
    // Volatility
    row += 1
    periods_per_year = 525600 / tf_minutes
    ann_vol = volatility * math.sqrt(periods_per_year)
    table.cell(results_table, 0, row, "Ann. Volatility", bgcolor=color.new(color.orange, 0), text_color=color.white, text_size=table_size)
    table.cell(results_table, 1, row, str.tostring(ann_vol * 100, "#.##") + "%", bgcolor=color.new(color.gray, 60), text_color=color.white, text_size=table_size)
    table.cell(results_table, 2, row, "", bgcolor=color.new(color.gray, 60))

// Risk Zones
up_threshold_price = close * (1 + threshold_pct / 100)
down_threshold_price = close * (1 - threshold_pct / 100)

var line up_line = na
var line down_line = na

if barstate.islast
    if not na(up_line)
        line.delete(up_line)
    if not na(down_line)
        line.delete(down_line)
    
    x1 = bar_index - 3
    x2 = bar_index + projection_bars
    
    up_line := line.new(x1, up_threshold_price, x2, up_threshold_price, color=color.new(color.green, 30), width=2, style=line.style_solid)
    down_line := line.new(x1, down_threshold_price, x2, down_threshold_price, color=color.new(color.red, 30), width=2, style=line.style_solid)

// Create even lighter gradient boxes
var array<box> up_gradient_boxes = array.new<box>()
var array<box> down_gradient_boxes = array.new<box>()

if barstate.islast and show_zones
    // Clear previous boxes
    if array.size(up_gradient_boxes) > 0
        for i = 0 to array.size(up_gradient_boxes) - 1
            box.delete(array.get(up_gradient_boxes, i))
        array.clear(up_gradient_boxes)
    
    if array.size(down_gradient_boxes) > 0
        for i = 0 to array.size(down_gradient_boxes) - 1
            box.delete(array.get(down_gradient_boxes, i))
        array.clear(down_gradient_boxes)
    
    x_start = bar_index
    x_end = bar_index + projection_bars
    
    // Create even lighter gradient with more layers
    num_layers = 10
    
    for i = 0 to num_layers - 1
        // Calculate gradient colors from very light purple to very light blue
        ratio = i / (num_layers - 1)
        
        // Very Light Purple RGB: ~220,190,255, Very Light Blue RGB: ~190,210,255
        r = math.round(220 * (1 - ratio) + 190 * ratio)
        g = math.round(190 * (1 - ratio) + 210 * ratio)
        b = 255
        
        // Very light transparency (90-97%)
        transparency = 90 + math.round(i * 0.7)
        gradient_color = color.rgb(r, g, b, transparency)
        
        // Calculate Y positions for layers
        layer_height = (up_threshold_price - close) / num_layers
        y1 = close + (layer_height * i)
        y2 = close + (layer_height * (i + 1))
        
        up_box = box.new(x_start, y1, x_end, y2, border_color=color.new(gradient_color, 100), bgcolor=gradient_color, border_width=0)
        array.push(up_gradient_boxes, up_box)
        
        // Downside gradient
        down_layer_height = (close - down_threshold_price) / num_layers
        down_y1 = close - (down_layer_height * i)
        down_y2 = close - (down_layer_height * (i + 1))
        
        down_box = box.new(x_start, down_y1, x_end, down_y2, border_color=color.new(gradient_color, 100), bgcolor=gradient_color, border_width=0)
        array.push(down_gradient_boxes, down_box)

var label up_label = na
var label down_label = na

if barstate.islast and show_labels
    if not na(up_label)
        label.delete(up_label)
    if not na(down_label)
        label.delete(down_label)
    
    total_first_hits = up_first + down_first
    up_prob = total_first_hits > 0 ? (up_first / total_first_hits) * 100 : 0.0
    down_prob = total_first_hits > 0 ? (down_first / total_first_hits) * 100 : 0.0
    
    up_median_text = format_time(up_median)
    down_median_text = format_time(down_median)
    
    label_x = bar_index + projection_bars
    label_size = get_label_size(label_size_option)
    
    up_label := label.new(label_x, up_threshold_price, "↑ " + str.tostring(threshold_pct, "#.#") + "%\n50%: " + up_median_text + "\nProb: " + str.tostring(up_prob, "#.#") + "%", style=label.style_label_left, color=label_upside_color, textcolor=label_text_color, size=label_size)
    
    down_label := label.new(label_x, down_threshold_price, "↓ " + str.tostring(threshold_pct, "#.#") + "%\n50%: " + down_median_text + "\nProb: " + str.tostring(down_prob, "#.#") + "%", style=label.style_label_left, color=label_downside_color, textcolor=label_text_color, size=label_size)
````
