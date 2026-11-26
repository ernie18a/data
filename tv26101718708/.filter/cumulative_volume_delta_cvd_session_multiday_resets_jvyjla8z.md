# Cumulative Volume Delta (CVD) - Session & Multi-Day Resets

- url: https://www.tradingview.com/script/jvyJLA8Z-Cumulative-Volume-Delta-CVD-Session-Multi-Day-Resets/
- type: indicator
- pine_id: PUB;4e3ca4fef35d479aa655fad20b3a9bab
- version: 1.0

## Description

Overview
The Cumulative Volume Delta (CVD) is a powerful order flow tool designed to measure the net difference between buying and selling pressure. By aggregating intrabar volume data, this indicator provides a transparent view of market participation, helping traders identify whether aggressive buyers or aggressive sellers are in control of the tape.

Unlike standard volume bars that only show total activity, CVD reveals the directional intent behind the volume.

Key Features & Innovation
This script brings advanced reset mechanics to your CVD analysis, anchoring calculations specifically to Regular Trading Hours (RTH) to filter out low-liquidity overnight noise.

It features three customizable reset modes:

Daily Reset: Resets the cumulative delta back to zero at the exact open of the exchange's regular session every day.

Weekly Reset: Tracks cumulative delta throughout the week, resetting only on the first regular session bar of the new week.

N-Days Reset: Allows you to input a custom number of days (e.g., 2, 3, or 5 days). The indicator will accumulate delta for that duration and reset precisely on the RTH open of the Nth day.

How it Works (The Math Under the Hood)
Because true Bid/Ask volume data is not natively accessible via standard feeds, this script uses TradingView's request.security_lower_tf() function to approximate delta at the highest possible resolution.

Intrabar Polling: By default, it reaches down to the 1-second (1S) timeframe.

Tick Logic: It evaluates every 1-second bar. If the close is higher than the previous close, the volume is classified as "Buying Volume" (positive delta). If the close is lower, it is classified as "Selling Volume" (negative delta).

Aggregation: It collects all 1-second deltas that occurred inside your chart's current candle and sums them up.

Accumulation: It adds the current candle's total delta to the running total (CVD), resetting only when your chosen temporal condition (Daily, Weekly, N-Days) is met via the session.isfirstbar_regular function.

How to Use CVD in Your Trading
Trend Confirmation: During a healthy uptrend, price action should be accompanied by a rising, positive CVD. This confirms that aggressive buyers are supporting the move.

Spotting Divergences: If price makes a new Higher High, but the CVD makes a Lower High (or remains negative), this indicates buying exhaustion. The move upward is lacking aggressive volume support and may reverse.

Identifying Absorption: If price is stuck in a tight consolidation range while the CVD is aggressively dropping (heavy selling), it suggests passive buyers are using limit orders to absorb the selling pressure. This can often precede a sharp reversal upward.

Important Data Limitations (Please Read)
TradingView enforces a strict limit of 100,000 historical intrabars for the request.security_lower_tf() function.

Because this indicator uses the 1-Second timeframe by default to ensure maximum accuracy, historical CVD data will only render for roughly the last ~27 hours of active market time.

Need more history? If you are swing trading or viewing higher timeframes (like the 1H or 4H chart) and need days/weeks of historical data, simply open the indicator settings and change the Lower Timeframe input from 1S to 15S, 1 (1-minute), or 3 (3-minute). This reduces tick granularity but dramatically increases your historical lookback period.

Disclaimer: This script is provided for educational purposes only. Order flow and volume delta should be used in conjunction with price action and other forms of analysis. It is not a standalone trading system.

## Source Code

````pine
//@version=6
indicator('Cumulative Volume Delta (CVD)', overlay = false, max_bars_back = 5000)

// === INPUTS ===
ltf = input.timeframe('1S', title='Lower Timeframe (Delta Granularity)')
resetMode = input.string('Daily', title='Reset Frequency', options=['Daily', 'Weekly', 'N Days'])
nDaysInput = input.int(2, title='Number of Days (if N Days selected)', minval=1)

// === 1-SECOND DELTA LOGIC ===
// Calculate delta strictly for each lower timeframe bar
float vol1s = volume
float delta1s = 0.0

if close > close[1]
    delta1s := vol1s
else if close < close[1]
    delta1s := -vol1s

// === AGGREGATE TO CHART TIMEFRAME ===
// Pull all 1-second deltas that occurred inside the current chart timeframe
deltaArray = request.security_lower_tf(syminfo.tickerid, ltf, delta1s)

// Sum the array to get the total delta for the current chart bar
float delta = 0.0
if array.size(deltaArray) > 0
    delta := array.sum(deltaArray)

// === RESET LOGIC ===
// Variables to track sessions and weeks
var int daysPassed = 0
var bool weekChanged = false

// Detect if a new week has started using timeframe.change (Returns a strict boolean)
if timeframe.change("W")
    weekChanged := true

// Detect the first bar of Regular Trading Hours (RTH)
bool isRTHStart = session.isfirstbar_regular

// Determine if a reset should happen on the current bar
bool doReset = false

if isRTHStart
    if resetMode == 'Daily'
        doReset := true
        
    else if resetMode == 'Weekly'
        // Reset only on the first RTH bar of the new week
        if weekChanged
            doReset := true
            weekChanged := false // Reset the week tracker
            
    else if resetMode == 'N Days'
        // Increment day counter and reset if it hits the user's N limit
        daysPassed += 1
        if daysPassed >= nDaysInput
            doReset := true
            daysPassed := 0 // Reset the day tracker

// === CUMULATIVE DELTA CALCULATION ===
// Use 'var' to declare the variable so its state persists across bars
var float cumDelta = 0.0

if doReset or barstate.isfirst
    cumDelta := delta // Reset to current bar's delta
else
    cumDelta += delta // Add to existing cumulative delta

// === PLOTTING ===
// Determine the color based on whether the cumulative delta is positive or negative
plotColor = cumDelta >= 0 ? color.new(color.green, 30) : color.new(color.red, 30)

// Plot the Cumulative Delta
plot(cumDelta, title = 'CVD', color = plotColor, style = plot.style_columns)

// Optional: Plot a zero line for reference
hline(0, title = 'Zero Line', color = color.new(color.gray, 50), linestyle = hline.style_dashed)
````
