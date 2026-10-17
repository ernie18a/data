# MMFunded Structure & Criteria Checklist

- url: https://www.tradingview.com/script/QiPil1Hw-MMFunded-Structure-Criteria-Checklist/
- type: indicator
- pine_id: PUB;e2187d5317dd424c9c4bfc5d9824093c
- version: 1.0

## Description

Structure and criteria.
Gives lows and highs in a box which makes it easy to see if liquidity has been swept.

## Source Code

````pine
//@version=6
indicator("MMFunded Structure & Criteria Checklist", overlay=true)

// --- Custom Trade Plan Checklist ---
label1 = "Structure"
label2 = "Strong High/Low Sweep"
label3 = "BOS"
label4 = "OB below 71 Fib"
label5 = "Volume (Imbalance)"
label6 = "Corrective or Sweeping Pullback"

// Custom criteria input section (enabled by default)
criteria1_condition = input.bool(false, title="Enable Structure")
criteria2_condition = input.bool(false, title="Enable Strong High/Low Sweep")
criteria3_condition = input.bool(false, title="Enable BOS")
criteria4_condition = input.bool(false, title="Enable OB below 71 Fib")
criteria5_condition = input.bool(false, title="Enable Volume (Imbalance)")
criteria6_condition = input.bool(false, title="Enable Corrective or Sweeping Pullback")

// Initialize counters for the number of conditions enabled
enabled_conditions = 0

// Check how many conditions are enabled
if criteria1_condition
    enabled_conditions := enabled_conditions + 1
if criteria2_condition
    enabled_conditions := enabled_conditions + 1
if criteria3_condition
    enabled_conditions := enabled_conditions + 1
if criteria4_condition
    enabled_conditions := enabled_conditions + 1
if criteria5_condition
    enabled_conditions := enabled_conditions + 1
if criteria6_condition
    enabled_conditions := enabled_conditions + 1

// Calculate trade score based on the number of enabled conditions
trade_score = enabled_conditions == 0 ? 0 : (enabled_conditions / 6) * 100

// Function to align checkmarks properly in their own box
align_checkmark(check_condition) =>
    checkmark = check_condition ? "✔️" : "❌"
    checkmark

// Create a table to display the checklist in the top-right corner with static black background
var my_table = table.new(position.top_right, 3, 7, border_color=color.white, border_width=1, bgcolor=color.black)

// Fill the table with checkmarks and custom condition information
table.cell(my_table, 0, 0, align_checkmark(criteria1_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 0, label1, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 0, "", text_color=color.white, bgcolor=color.black)

table.cell(my_table, 0, 1, align_checkmark(criteria2_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 1, label2, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 1, "", text_color=color.white, bgcolor=color.black)

table.cell(my_table, 0, 2, align_checkmark(criteria3_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 2, label3, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 2, "", text_color=color.white, bgcolor=color.black)

table.cell(my_table, 0, 3, align_checkmark(criteria4_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 3, label4, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 3, "", text_color=color.white, bgcolor=color.black)

table.cell(my_table, 0, 4, align_checkmark(criteria5_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 4, label5, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 4, "", text_color=color.white, bgcolor=color.black)

table.cell(my_table, 0, 5, align_checkmark(criteria6_condition), text_color=color.white, bgcolor=color.black)
table.cell(my_table, 1, 5, label6, text_color=color.white, bgcolor=color.black)
table.cell(my_table, 2, 5, "", text_color=color.white, bgcolor=color.black)

// Display Trade Score or Setup Type inside the table in the last row
setup_label = trade_score == 100 ? "A+ Setup" : "B Setup"
setup_color = trade_score == 100 ? color.green : color.red  // Set color for A+ Setup (green) or B Setup (red)

// Swap columns for setup label and trade score
table.cell(my_table, 0, 6, "Trade Score: " + str.tostring(trade_score, "#.##") + "%", text_color=color.white, bgcolor=color.black)  // Change background color to black for Trade Score
table.cell(my_table, 1, 6, setup_label, text_color=setup_color, bgcolor=color.black)  // Set background color to black for setup label
table.cell(my_table, 2, 6, "", text_color=color.white, bgcolor=color.black)

// --- MMFunded HTF Indicator ---
lineWidth = input.int(title="Line Weight", defval=1, minval=-10, maxval=10)
max_candles = input.int(title="Max Candles (High value may impact performance)", defval=250, minval=10, maxval=1000)  // Moved Max Candles input below Line Weight

bosHighColor = input.color(title="BOS High Line Color", defval=color.blue)  // Default Blue for BOS High
bosLowColor = input.color(title="BOS Low Line Color", defval=color.red)    // Default Red for BOS Low

// Initialize variables for MMFunded Structure
var float bosHigh = na
var float bosLow = na
var float prevBosHigh = na
var float prevBosLow = na
var bool isBullishMB = false
var bool isBearishMB = false

// Initialize arrays to store last MBs
var int mbCount = 0
var float[] mbArray = array.new_float(0)

// Initialize separate arrays to track sequences
var int[] bullishSequence = array.new_int(0)
var int[] bearishSequence = array.new_int(0)

// Set initial values for bosHigh and bosLow
if na(bosHigh)
    bosHigh := high
if na(bosLow)
    bosLow := low

// Logic for BOS High (Potential Bullish MB)
if close > bosHigh
    prevBosHigh := bosHigh
    prevBosLow := bosLow
    bosHigh := high
    bosLow := low
    isBullishMB := false
    int i = 1
    bool waveFound = true
    while waveFound and i < 2000
        if close[i] < open[i]
            if close[i] < low[i+1]
                waveFound := false
        if low[i] < bosLow
            bosLow := low[i]
            // Validate Bullish MB
            if bosLow != prevBosLow and not isBullishMB
                isBullishMB := true
                array.push(mbArray, 1.0)  // 1.0 for Bullish MB
                array.push(bullishSequence, 1)
                array.clear(bearishSequence)  // Clear Bearish sequence when Bullish MB is valid
        i += 1

// Logic for BOS Low (Potential Bearish MB)
if close < bosLow
    prevBosHigh := bosHigh
    prevBosLow := bosLow
    bosLow := low
    bosHigh := high
    isBearishMB := false
    int i = 1
    bool waveFound = true
    while waveFound and i < 2000
        if close[i] > open[i]
            if close[i] > high[i+1]
                waveFound := false
        if high[i] > bosHigh
            bosHigh := high[i]
            // Validate Bearish MB
            if bosHigh != prevBosHigh and not isBearishMB
                isBearishMB := true
                array.push(mbArray, -1.0)  // -1.0 for Bearish MB
                array.push(bearishSequence, 1)
                array.clear(bullishSequence)  // Clear Bullish sequence when Bearish MB is valid
        i += 1


if array.size(mbArray) > 8
    array.shift(mbArray)


plot_condition = (bar_index >= (last_bar_index - max_candles))

// Plotting BOS High and BOS Low with separate colors
plot(title='BOS High', series=plot_condition ? bosHigh : na, color=bosHighColor, linewidth=lineWidth, offset=0, style=plot.style_stepline)
plot(title='BOS Low', series=plot_condition ? bosLow : na, color=bosLowColor, linewidth=lineWidth, offset=0, style=plot.style_stepline)
````
