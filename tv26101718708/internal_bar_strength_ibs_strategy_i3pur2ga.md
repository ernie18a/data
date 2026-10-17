# Internal Bar Strength (IBS) Strategy

- url: https://www.tradingview.com/script/I3PUR2GA-Internal-Bar-Strength-IBS-Strategy/
- type: strategy
- pine_id: PUB;919d53f18836415fa6186d97f518a171
- version: 1.0

## Description

█ STRATEGY DESCRIPTION  
The "Internal Bar Strength (IBS) Strategy" is a mean-reversion strategy designed to identify trading opportunities based on the closing price's position within the daily price range. It enters a long position when the IBS indicates oversold conditions and exits when the IBS reaches overbought levels. This strategy was designed to be used on the daily timeframe.

█ WHAT IS INTERNAL BAR STRENGTH (IBS)?  
Internal Bar Strength (IBS) measures where the closing price falls within the high-low range of a bar. It is calculated as: 
[pine]IBS = (Close - Low) / (High - Low)[/pine]
- **Low IBS (≤ 0.2)**: Indicates the close is near the bar's low, suggesting oversold conditions.  
- **High IBS (≥ 0.8)**: Indicates the close is near the bar's high, suggesting overbought conditions.  

█ SIGNAL GENERATION  
1. LONG ENTRY  
A Buy Signal is triggered when:  
[list]
[*]The IBS value drops below the Lower Threshold (default: 0.2).  
[*]The signal occurs within the specified time window (between `Start Time` and `End Time`).  
[/list]  

2. EXIT CONDITION  
[list]
[*]A Sell Signal is generated when the IBS value rises to or above the Upper Threshold (default: 0.8). This prompts the strategy to exit the position.  
[/list]

█ ADDITIONAL SETTINGS  
[list]
[*]Upper Threshold: The IBS level at which the strategy exits trades. Default is 0.8.  
[*]Lower Threshold: The IBS level at which the strategy enters long positions. Default is 0.2.  
[*]Start Time and End Time: The time window during which the strategy is allowed to execute trades.  
[/list]

█ PERFORMANCE OVERVIEW  
[list]
[*]This strategy is designed for ranging markets and performs best when prices frequently revert to the mean.  
[*]It is sensitive to extreme IBS values, which help identify potential reversals.  
[*]Backtesting results should be analyzed to optimize the Upper/Lower Thresholds for specific instruments and market conditions.  
[/list]

## Source Code

````pine
//@version=6
strategy(title = 'Internal Bar Strength (IBS) Strategy', overlay = false, precision = 2, initial_capital = 1000000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, process_orders_on_close = true, margin_long = 5, margin_short = 5, calc_on_every_tick = true)

//#region INPUTS SECTION
// ============================================
// Inputs Section
// ============================================
//#region Time Settings
startTimeInput = input.time(timestamp('1 Jan 2014'), title = 'Start Time', group = 'Time Settings')
endTimeInput = input.time(timestamp('1 Jan 2099'), title = 'End Time', group = 'Time Settings')
isWithinTradingWindow = time >= startTimeInput and time <= endTimeInput
//#endregion

//#region IBS Thresholds
upperThresholdInput = input.float(defval = 0.8, title = 'Upper Threshold', step = 0.1, maxval=1, group = 'IBS Settings')
lowerThresholdInput = input.float(defval = 0.2, title = 'Lower Threshold', step = 0.1, minval=0, group = 'IBS Settings')
//#endregion
//#endregion

//#region IBS CALCULATION
// ============================================
// IBS Value Calculation
// ============================================
internalBarStrength = (close - low) / (high - low)
//#endregion

//#region TRADING CONDITIONS
// ============================================
// Entry/Exit Logic
// ============================================
shouldEnterLong = internalBarStrength < lowerThresholdInput and isWithinTradingWindow
shouldExitPosition = internalBarStrength >= upperThresholdInput
//#endregion

//#region STRATEGY EXECUTION
// ============================================
// Order Management
// ============================================
if shouldEnterLong
    strategy.entry('Long', strategy.long)
if shouldExitPosition
    strategy.close_all()
//#endregion

//#region PLOTTING
// ============================================
// Visual Components
// ============================================
plot(internalBarStrength, color = color.white, title = "IBS Value")
plot(upperThresholdInput, color = color.yellow, title = "Upper Threshold")
plot(lowerThresholdInput, color = color.yellow, title = "Lower Threshold")
//#endregion
````
