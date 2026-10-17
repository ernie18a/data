# Gap Down Reversal Strategy

- url: https://www.tradingview.com/script/biloxPO9-Gap-Down-Reversal-Strategy/
- type: strategy
- pine_id: PUB;bfdece38807a4ae79b7cbc305f867e9a
- version: 1.0

## Description

█ STRATEGY OVERVIEW  
The "Gap Down Reversal Strategy" capitalizes on price recovery patterns following bearish gap-down openings. This mean-reversion approach enters long positions on confirmed intraday recoveries and exits when prices breach previous session highs. This strategy is NOT optimized.

█ What is a Gap Down Reversal?
A gap down reversal occurs when:  
[list]  
[*] An instrument opens significantly below its prior session's low (price gap)  
[*] Selling pressure exhausts itself during the session  
[*] Buyers regain control, pushing price back above the opening level  
[*] Creates a candlestick with:
 • Open < Prior Session Low (true gap)  
 • Close > Open (bullish reversal candle)  
[/list]

█ SIGNAL GENERATION  
1. LONG ENTRY CONDITION  
[list]  
[*] Previous candle closes BELOW its opening price (bearish candle)  
[*] Current session opens BELOW prior candle's low (gap down)  
[*] Current candle closes ABOVE its opening price (bullish reversal)  
[*] Executes market order at session close  
[/list]  

2. EXIT CONDITION  
[list]  
[*] A Sell Signal is generated when the current closing price exceeds the highest high of the previous seven bars (`close > _highest[1]`). This indicates that the price has shown strength, potentially confirming the reversal and prompting the strategy to exit the position.
[/list]  

█ PERFORMANCE OVERVIEW
[list]  
[*] Ideal Market: High volatility instruments with frequent gaps  
[*] Key Risk: False reversals in sustained downtrends
[*] Optimization Tip: Test varying gap thresholds (1-3% ranges)
[/list]

## Source Code

````pine
//@version=6
strategy("Gap Down Reversal Strategy", overlay=true, initial_capital = 1000000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, process_orders_on_close = true, margin_long = 5, margin_short = 5, calc_on_every_tick = true)

//#region INPUTS SECTION
// ============================================
// Time Settings
// ============================================
startTimeInput = input.time(timestamp("1 Jan 2014"), "Start Time", group = "Time Settings")
endTimeInput = input.time(timestamp("1 Jan 2099"), "End Time", group = "Time Settings")
isWithinTradingWindow = time >= startTimeInput and time <= endTimeInput
//#endregion

//#region TRADING CONDITIONS
// ============================================
// Entry/Exit Logic
// ============================================
gapDownReversal = close[1] < open[1] and open < low[1] and close > open
longCondition = isWithinTradingWindow and gapDownReversal
exitCondition = close > high[1]
//#endregion

//#region STRATEGY EXECUTION
// ============================================
// Order Management
// ============================================
if longCondition
    strategy.entry("Long", strategy.long)
    
if exitCondition
    strategy.close_all()
//#endregion
````
