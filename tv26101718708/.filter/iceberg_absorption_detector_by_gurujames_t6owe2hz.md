# Iceberg & Absorption Detector by Gurujames

- url: https://www.tradingview.com/script/t6oWe2hZ-Iceberg-Absorption-Detector-by-Gurujames/
- type: indicator
- pine_id: PUB;fa6c9ef6425344868eba88eb7c345d59
- version: 1.0

## Description

Chart Interval Configuration: The input.timeframe() function generates a dropdown menu in your dashboard. You can leave it on the default "Same as Chart" or lock the script's calculation to a specific interval (e.g., 5-minute or 1-hour), forcing the algorithm to detect macro-absorption zones regardless of what time-frame you are currently viewing.  

Price Stickiness Customization: The maxSpreadPct has been enhanced with a step = 0.01 input setting, allowing you to finely tune what you consider "sticky." By lowering this number (e.g., to 0.05%), you instruct the script to only mark areas where the invisible iceberg wall allowed virtually zero price slippage.

Visualizing Filled Areas via Bubbles: When the algorithm detects a massive volume-to-depth discrepancy pinned against a sticky price, it triggers two translucent shape.circle plots positioned precisely on the exact high and low boundaries of that specific price level. This creates a highly visible "bubble" over the exact area where the hidden liquidity was replenished and filled by incoming taker flow.

## Source Code

````pine
//@version=6
indicator("Iceberg & Absorption Detector (Proxy)", overlay = true)

// =====================================================================
// 1. DASHBOARD CONFIGURATION (CUSTOMIZABLE INPUTS)
// =====================================================================
string grp_tf = "Chart & Analysis Timeframe"
// Customizable chart interval input. Leaving it blank defaults to the current chart.
string calcTF = input.timeframe("", title="Calculation Timeframe", tooltip="Leave blank to use current chart timeframe, or specify a timeframe (e.g., '15' for 15m) to analyze higher timeframe order flow.", group=grp_tf)

string grp_vwap = "VWAP / TWAP Settings"
bool showVWAP = input.bool(true, "Show VWAP", group = grp_vwap)
bool showTWAP = input.bool(true, "Show TWAP", group = grp_vwap)
int twapLength = input.int(20, "TWAP Length", minval = 1, group = grp_vwap)
color colorVWAP = input.color(color.blue, "VWAP Color", group = grp_vwap)
color colorTWAP = input.color(color.fuchsia, "TWAP Color", group = grp_vwap)

string grp_iceberg = "Iceberg Detection (Proxy) Settings"
float volMultiplier = input.float(3.5, "Volume Spike Multiplier", tooltip = "Volume-to-Depth ratio. Volume must be X times the average to trigger detection.", group = grp_iceberg)
int volMA_Length = input.int(20, "Volume MA Length", minval = 1, group = grp_iceberg)
// Customization for detecting the area of Price Stickiness (Absorption)
float maxSpreadPct = input.float(0.15, "Max Price Stickiness Spread (%)", step = 0.01, tooltip = "Defines Absorption. Maximum percentage the price can move while volume is abnormally high. A lower number means tighter stickiness.", group = grp_iceberg)

// =====================================================================
// 2. TIMEFRAME & DATA REQUEST LOGIC
// =====================================================================
// Function to calculate iceberg proxy logic to pass into request.security for HTF polling
f_iceberg_logic() =>
    float avgVol = ta.sma(volume, volMA_Length)
    bool isHighVolume = volume > (avgVol * volMultiplier)
    
    // Price Stickiness: Percentage spread of the candle (High to Low)
    float priceSpreadPct = ((high - low) / low) * 100
    
    // Strict boolean evaluation for version 6 compatibility
    bool isStickyPrice = priceSpreadPct <= maxSpreadPct
    
    // Combined Detection: High volume but the price refused to move (Absorption)
    bool detect = isHighVolume and isStickyPrice
    
    // Return a tuple of the required values
    [detect, high, low, ta.vwap(hlc3), ta.sma(hlc3, twapLength)]

// Fetch the data based on the custom timeframe input
[htf_detectIceberg, htf_high, htf_low, htf_vwap, htf_twap] = request.security(syminfo.tickerid, calcTF, f_iceberg_logic())

// =====================================================================
// 3. PLOTTING VWAP & TWAP
// =====================================================================
plot(showVWAP ? htf_vwap : na, title = "VWAP", color = colorVWAP, linewidth = 2)
plot(showTWAP ? htf_twap : na, title = "TWAP", color = colorTWAP, linewidth = 2)

// =====================================================================
// 4. VISUAL BUBBLES FOR ICEBERG ABSORPTION
// =====================================================================
// Plotting 'bubbles' using translucent circles at the top and bottom of the sticky price action 
// The first parameter evaluates to the absolute price level if true, or 'na' if false
plotshape(htf_detectIceberg ? htf_high : na, title="Iceberg Bubble Top", style=shape.circle, location=location.absolute, color=color.new(color.red, 50), size=size.normal)
plotshape(htf_detectIceberg ? htf_low : na, title="Iceberg Bubble Bottom", style=shape.circle, location=location.absolute, color=color.new(color.green, 50), size=size.normal)

// Text label for clarity resting slightly above the top bubble
plotshape(htf_detectIceberg ? htf_high + (htf_high * 0.001) : na, title="Iceberg Label", style=shape.labeldown, location=location.absolute, color=color.red, text="ICEBERG\nABSORB", textcolor=color.white, size=size.small)

// Built-in alert for webhooks or external trade routing
alertcondition(htf_detectIceberg, title="Iceberg Order Detected", message="High Volume Absorption detected! Potential Iceberg replenishing liquidity.")
````
