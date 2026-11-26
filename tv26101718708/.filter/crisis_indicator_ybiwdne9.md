# Crisis indicator

- url: https://www.tradingview.com/script/ybIWdNe9-Crisis-indicator/
- type: indicator
- pine_id: PUB;ca2c82a800044914b03f9b7c112881b0
- version: 1.0

## Description

[b]What This Indicator Does[/b]
This indicator acts as an early warning system for potential market crises by tracking 5 of the most reliable financial danger signals that have predicted major market declines throughout history.

[b]The 5 Crisis Signals Monitored[/b]
1. Yield Curve Inversion
- What it measures: When short-term interest rates become higher than long-term rates
- Why it matters: This has predicted every US recession since 1955
- Trigger: Yield curve drops below your set threshold (default: 0.0)
2. Shiller CAPE Ratio
- What it measures: Stock market valuation adjusted for economic cycles
- Why it matters: Only exceeded 30 during major bubbles (1929, 2000, 2021) - all followed by crashes
- Trigger: CAPE ratio rises above your threshold (default: 30.0)
3. Buffett Indicator
- What it measures: Total stock market value compared to GDP
- Why it matters: Warren Buffett's favorite market valuation gauge
- Trigger: Ratio exceeds your threshold (default: 180%)
4. VIX Complacency
- What it measures: Market fear gauge (Volatility Index)
- Why it matters: Extremely low VIX indicates investor complacency before storms
- Trigger: VIX falls below your threshold (default: 15.0)
5. SPX Extreme Deviation
- What it measures: How far S&P 500 is above its 200-week moving average
- Why it matters: Major tops in 1929, 2000, 2021 all showed extreme deviations
- Trigger: Deviation exceeds your threshold (default: 2.8 standard deviations)

[b]How to Read the Results[/b]
The Yellow Line (0-5 Scale)
- Shows how many of the 5 danger signals are currently active
- 0-1: Normal market conditions
- 2: High Risk - Caution advised
- 3+: Crisis Cluster - High probability of market decline
The Information Table
- Shows exactly which signals are triggering
- Displays current values for each indicator
- Color-coded status (Green = Safe, Red = Danger)

[b]Historical Performance[/b]
When 3+ indicators flash simultaneously:
- 1999-2000: Preceded Dot-com crash (-49% SPX)
- 2007: Preceded Financial Crisis (-57% SPX)
- 2021: Preceded 2022 bear market (-25% SPX)

## Source Code

````pine
//@version=6
indicator("Crisis Cluster - Core Signals", shorttitle="CRISIS", overlay=false, max_lines_count=500, max_labels_count=500)

// ────────────────────── INPUT PARAMETERS ──────────────────────
// Yield Curve
yield_thr = input.float(0.0, "Yield Curve Inversion <", step=0.1)

// Valuation Indicators
cape_thr = input.float(30.0, "Shiller CAPE >", step=0.5)
buffett_thr = input.float(180.0, "Buffett Indicator >", step=5.0)

// Market Structure
vix_thr = input.float(15.0, "VIX Complacency <", step=0.5)
dev_thr = input.float(2.8, "SPX > σ above 200w MA", step=0.1)

// Risk Thresholds
high_risk = input.int(2, "High Risk ≥", minval=1, maxval=4)
crisis_level = input.int(3, "CRISIS ≥", minval=2, maxval=4)

// ────────────────────── DATA RETRIEVAL ──────────────────────
// Core Market Data - These are the most reliable sources
spx_daily = request.security("SPX", "D", close)
spx_weekly = request.security("SPX", "W", close)
vix_daily = request.security("CBOE:VIX", "D", close)
yield_daily = request.security("FRED:T10Y2Y", "D", close, ignore_invalid_symbol=true)

// Valuation Data - These work reliably
cape_daily = request.security("MULTPL:SHILLER_PE_RATIO_MONTH", "D", close, ignore_invalid_symbol=true)
buffett_daily = request.security("FRED:DDDM01USA156NWDB", "D", close, ignore_invalid_symbol=true)

// ────────────────────── CALCULATIONS ──────────────────────
// 1. Yield Curve Inversion (Most reliable single indicator)
yield_condition = not na(yield_daily) and yield_daily < yield_thr

// 2. Shiller CAPE Extreme (Very reliable - only >30 in major bubbles)
cape_condition = not na(cape_daily) and cape_daily > cape_thr

// 3. Buffett Indicator Extreme (Market Cap to GDP)
buffett_condition = not na(buffett_daily) and buffett_daily > buffett_thr

// 4. VIX Complacency (Low fear = complacency)
vix_condition = not na(vix_daily) and vix_daily < vix_thr

// 5. SPX Extreme Deviation (200-week MA deviation)
sma_200w = ta.sma(spx_weekly, 200)
stdev_200w = ta.stdev(spx_weekly, 200)
deviation = not na(sma_200w) and not na(stdev_200w) and stdev_200w != 0 ? (spx_weekly - sma_200w) / stdev_200w : 0
dev_condition = deviation > dev_thr

// ────────────────────── COMPOSITE SCORE ──────────────────────
// Only the 5 most reliable indicators
condition_array = array.new<bool>()
array.push(condition_array, yield_condition)      // 0: Yield Curve
array.push(condition_array, cape_condition)       // 1: Shiller CAPE  
array.push(condition_array, buffett_condition)    // 2: Buffett Indicator
array.push(condition_array, vix_condition)        // 3: VIX Complacency
array.push(condition_array, dev_condition)        // 4: SPX Deviation

condition_names = array.new<string>()
array.push(condition_names, "Yield Curve Inverted")
array.push(condition_names, "CAPE > " + str.tostring(cape_thr))
array.push(condition_names, "Buffett > " + str.tostring(buffett_thr))
array.push(condition_names, "VIX < " + str.tostring(vix_thr))
array.push(condition_names, "SPX > " + str.tostring(dev_thr) + "σ")

score = 0
for i = 0 to array.size(condition_array) - 1
    if array.get(condition_array, i)
        score += 1

// ────────────────────── VISUALIZATION ──────────────────────
// ONLY THE MAIN SCORE PLOT - Clean and simple
plot(score, "Crisis Score", color=#FFD700, linewidth=3)

// ────────────────────── DETAILED TABLE ──────────────────────
var table crisis_table = table.new(position.top_right, 3, 7, 
     bgcolor=color.new(#000000, 80), border_width=2, frame_color=color.gray)

if barstate.islast
    // Header
    table.cell(crisis_table, 0, 0, "CRISIS INDICATOR", 
         bgcolor=#404040, text_color=color.white, text_size=size.normal)
    table.cell(crisis_table, 1, 0, "VALUE", 
         bgcolor=#404040, text_color=color.white, text_size=size.normal)
    table.cell(crisis_table, 2, 0, "STATUS", 
         bgcolor=#404040, text_color=color.white, text_size=size.normal)
    
    // Individual indicators - Only the 5 reliable ones
    for i = 0 to array.size(condition_array) - 1
        bool cond = array.get(condition_array, i)
        string name = array.get(condition_names, i)
        
        // Get current value for display
        string current_val = "N/A"
        if i == 0
            current_val := not na(yield_daily) ? str.tostring(yield_daily) : "N/A"
        else if i == 1  
            current_val := not na(cape_daily) ? str.tostring(cape_daily) : "N/A"
        else if i == 2
            current_val := not na(buffett_daily) ? str.tostring(buffett_daily) : "N/A"
        else if i == 3
            current_val := not na(vix_daily) ? str.tostring(vix_daily) : "N/A"
        else if i == 4
            current_val := str.tostring(math.round(deviation, 2))
        
        table.cell(crisis_table, 0, i + 1, name, text_color=color.white)
        table.cell(crisis_table, 1, i + 1, current_val, text_color=color.white)
        table.cell(crisis_table, 2, i + 1, cond ? "🚨 YES" : "✅ no", 
             text_color=cond ? color.red : color.green, 
             bgcolor=cond ? color.new(color.red, 90) : color.new(color.green, 90))
    
    // Total Score row
    table.cell(crisis_table, 0, 6, "TOTAL SCORE", 
         bgcolor=color.yellow, text_color=color.black, text_size=size.normal)
    table.cell(crisis_table, 1, 6, str.tostring(score) + "/5", 
         bgcolor=color.yellow, text_color=color.black, text_size=size.normal)
    
    color score_color = score >= crisis_level ? color.red : score >= high_risk ? color.orange : color.green
    string score_status = score >= crisis_level ? "🚨 CRISIS" : score >= high_risk ? "⚠️ HIGH RISK" : "✅ NORMAL"
    table.cell(crisis_table, 2, 6, score_status, 
         bgcolor=score_color, text_color=color.white, text_size=size.normal)

// ────────────────────── ALERT CONDITIONS ──────────────────────
alertcondition(score >= high_risk, "High Risk Cluster", 
     "Multiple crisis indicators flashing - High Risk Level")
alertcondition(score >= crisis_level, "Crisis Cluster Detected", 
     "CRISIS CLUSTER DETECTED - Multiple reliable indicators signaling extreme risk")
````
