# Traffic Light Strategy -Power of stocks

- url: https://www.tradingview.com/script/CzrYjKOp-Traffic-Light-Strategy-Power-of-stocks/
- type: strategy
- pine_id: PUB;98bd149464b34b7fac49194db51fdb5b
- version: 1.0

## Description

To publish the Traffic Light Strategy (based on the setup by Subasish Pani - Power of Stocks) on TradingView, your description must be clear, honest, and credit the original creator to comply with the "House Rules" regarding attribution and original content.

Here is a professional, compliant description you can use:

Traffic Light Strategy: Red-Green Candle Breakout (Power of Stocks)
Overview
This strategy is an automated version of the popular "Traffic Light" setup shared by Subasish Pani (Power of Stocks). It is designed specifically for intraday traders looking for momentum breakouts based on back-to-back contrasting candle colors (Red & Green).

Core Logic
The strategy searches for the first occurrence of a "contrasting pair" after the market settles:

The Setup: A Green candle followed by a Red candle, or a Red candle followed by a Green candle.

The Range: Once this pair is formed, the script identifies the Highest High and Lowest Low of those two specific candles.

The Trigger: A trade is entered when the price closes above the high (Long) or below the low (Short) of that range.

Key Features & Enhancements
1-Minute Filter: Per the original rules, the script can automatically ignore the initial 9:15 AM candle on 1-minute timeframes to avoid opening-bell noise.

Max SL Point Filter: Includes an optional toggle to skip trades if the "Traffic Light" range is too wide (e.g., > 100 points on Nifty), ensuring you only take trades with favorable risk profiles.

Risk Management:

Configurable R:R: Defaulted to 1:2, but fully adjustable.

Trade Limit: Limits the strategy to 3 trades per day to prevent overtrading in choppy markets.

Intraday Auto-Exit: Automatically flattens all positions at 15:20 (3:20 PM IST) to ensure no overnight carryover.

How to Use
Timeframe: Works best on 1-minute, 5-minute, or 15-minute charts.

Instruments: Highly effective on high-liquidity instruments like Nifty, BankNifty, and major Blue-chip stocks.

Settings: Ensure your chart timezone is set to UTC+5:30 (IST) for the time-based exit to function correctly.

House Rules & Attribution
This script is provided for educational and backtesting purposes. The original "Traffic Light" concept was developed by Subasish Pani of Power of Stocks. I have simply converted the manual logic into a Pine Script strategy for the community to verify performance.

## Source Code

````pine

//@version=5
strategy("Traffic Light Strategy -Power of stocks", overlay=true, initial_capital=100000, default_qty_type=strategy.cash, default_qty_value=100000)
// --- Inputs ---
rrRatio         = input.float(2.0, title="Risk to Reward Ratio", minval=0.1)
useMaxSLFilter  = input.bool(false, title="Enable Max SL Point Filter?")
maxSLPoints     = input.float(100.0, title="Max SL Filter (Index Points)")
exitHour        = input.int(15, title="Exit Hour (24hr)", minval=0, maxval=23)
exitMin         = input.int(20, title="Exit Minute", minval=0, maxval=59)
// --- Alert System Settings ---
entryAlertMsg = "69e11be679386f55e866a8cb"
// --- State Variables ---
var float hi = na
var float lo = na
var bool pairFound = false
var int tradeCount = 0
// Detect Timeframe
is1Minute = timeframe.isintraday and timeframe.multiplier == 1
// Reset variables at the start of a new day
isNewDay = ta.change(time("D")) != 0
if isNewDay
    pairFound := false
    hi := na
    lo := na
    tradeCount := 0
// --- Logic to Find the Pair ---
isGreen = close > open
isRed   = close < open
// Rule: Ignore the 9:15 candle ONLY if on 1-Minute chart
isFirstCandle = hour == 9 and minute == 15
canSearch = not (is1Minute and isFirstCandle)
if not pairFound and not isNewDay and canSearch
    // Check if the previous candle was not the ignored 9:15 candle either
    prevCanSearch = not (is1Minute and hour[1] == 9 and minute[1] == 15)
    
    if prevCanSearch and ((isGreen and isRed[1]) or (isRed and isGreen[1]))
        tempHi = math.max(high, high[1])
        tempLo = math.min(low, low[1])
        rangeSize = tempHi - tempLo
        
        bool isRangeValid = not useMaxSLFilter or (rangeSize <= maxSLPoints)
        
        if isRangeValid
            hi := tempHi
            lo := tempLo
            pairFound := true
// --- Strategy Execution ---
// Entries
longCondition  = pairFound and ta.crossover(close, hi) and strategy.position_size == 0 and tradeCount < 3
shortCondition = pairFound and ta.crossunder(close, lo) and strategy.position_size == 0 and tradeCount < 3
var float currentStop  = na
var float currentTarget = na
if longCondition
    currentStop := lo
    currentTarget := hi + ((hi - lo) * rrRatio)
    tradeCount += 1
    strategy.entry("Long", strategy.long, comment='entry', alert_message=entryAlertMsg)
if shortCondition
    currentStop := hi
    currentTarget := lo - ((hi - lo) * rrRatio)
    tradeCount += 1
    strategy.entry("Short", strategy.short, comment='entry', alert_message=entryAlertMsg)
// --- Exit Logic ---
if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", stop=currentStop, limit=currentTarget, comment='exit', alert_message=entryAlertMsg)
if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", stop=currentStop, limit=currentTarget, comment='exit', alert_message=entryAlertMsg)
// Time-based Exit
timeExit = hour == exitHour and minute >= exitMin
if timeExit and strategy.position_size != 0
    strategy.close_all(comment="Time Exit", alert_message=entryAlertMsg)
// --- Visualization ---
// Plot lines for the validated pair
plot(pairFound ? hi : na, color=color.new(color.green, 20), style=plot.style_linebr, linewidth=2, title="Pair High")
plot(pairFound ? lo : na, color=color.new(color.red, 20), style=plot.style_linebr, linewidth=2, title="Pair Low")
// Highlight the candles that triggered the setup
bgcolor(pairFound and not pairFound[1] ? color.new(color.yellow, 80) : na)
// Target and Stop Visuals
plot(strategy.position_size != 0 ? currentTarget : na, color=color.lime, style=plot.style_linebr, title="Active Target")
plot(strategy.position_size != 0 ? currentStop : na, color=color.red, style=plot.style_linebr, title="Active Stop")
````
