# Trade Entry Detector, Wick to Body Ratio 

- url: https://www.tradingview.com/script/myGHorN2-Trade-Entry-Detector-Wick-to-Body-Ratio/
- type: strategy
- pine_id: PUB;5be138a2e4924c8d99e8fc064335e277
- version: 1.0

## Description

Trade Entry Detector: Wick-to-Body Ratio Strategy with Bollinger Bands

Overview The Trade Entry Detector is a custom strategy for TradingView that leverages the Bollinger Bands and a unique wick-to-body ratio approach to capture precise entry opportunities. This indicator is designed for traders who want to pinpoint high-probability reversal points when price interacts with Bollinger Bands, all while offering flexible entry fill options.

The strategy performs primary analysis on the daily time frame, regardless of your current chart setting, allowing you to view daily Bollinger Band levels and entry signals even on lower time frames. This approach is suitable for swing traders and short-term traders looking to align intraday moves with higher time frame signals.

How the Strategy Works
1. Bollinger Band Analysis on the Daily Time Frame Bollinger Bands are calculated using a 20-period simple moving average (SMA) and a standard deviation multiplier (default is 2). These bands dynamically expand and contract based on market volatility, making them ideal for identifying overbought and oversold conditions:
    * Upper Band: Indicates potential overbought levels.
    * Lower Band: Indicates potential oversold levels.
2. Wick-to-Body Ratio Condition This strategy places significant emphasis on candle wicks relative to the candle body. Here’s why:
    * A large upper wick relative to the body signals potential selling pressure after testing the upper Bollinger Band.
    * A large lower wick relative to the body indicates buying support after testing the lower Bollinger Band.
    * Ratio Threshold: You can set a minimum wick-to-body ratio (default is 1.0), meaning that the wick must be at least equal in size to the body. This ensures only candles with significant reversals are considered for entry.
3. Flexible Entry Timing To adapt to various trading styles, the indicator allows you to choose the entry fill timing:
    * Daily Close: Enter at the close of the daily candle.
    * Daily Open: Enter at the open of the following daily candle.
    * HOD (High of Day): Set entry at the daily high, for those who want confirmation of upward momentum.
    * LOD (Low of Day): Set entry at the daily low, ideal for confirming downward movement.
4. Position Sizing and Risk Management The strategy calculates position size based on a fixed risk percentage of your account balance (default is 1%). This approach dynamically adjusts position sizes based on stop-loss distance:
    * Stop Loss: Placed at the nearest swing high (for shorts) or swing low (for longs).
    * Take Profit: Exits are triggered when the price reaches the opposite Bollinger Band.
5. Order Expiration Each pending order (long or short) expires after two days if unfilled, allowing for new setups on subsequent candles if conditions are met again.

Using the Trade Entry Detector
Step-by-Step Guide
1. Set the Primary Time Frame The core calculations run on the daily time frame, but the strategy can be applied to intraday charts (e.g., 65-minute or 15-minute) for deeper insights.
2. Adjust Bollinger Band Settings
    * Length: Default is 20, which determines the period for calculating the moving average.
    * Standard Deviation Multiplier: Default is 2.0, which sets the width of the bands. Adjusting this can help you capture broader or tighter volatility ranges.
3. Define the Wick-to-Body Ratio Set the minimum ratio between wick and body (default 1.0). Higher values filter out candles with less wick-to-body contrast, focusing on stronger rejection moves.
4. Choose Entry Fill Timing Select your preferred fill condition:
    * Daily Close: Confirms the trade at the end of the daily session.
    * Daily Open: Executes the entry at the open of the next day.
    * HOD/LOD: Uses the daily high or low as an additional confirmation for upward or downward moves.
5. Position Sizing and Risk Management
    * Set your account balance and risk percentage. The strategy automatically calculates position sizes based on the stop distance to manage risk efficiently.
    * Stop Loss and Take Profit points are automatically set based on swing highs/lows and opposing Bollinger Bands, respectively.

Practical Example
Let’s say SPY (S&P 500 ETF) tests the lower Bollinger Band on the daily time frame, with a lower wick that is twice the size of the body (meeting the 1.0 ratio threshold). Here’s how the strategy might proceed:
1. Signal: The lower wick on SPY suggests buying interest at the lower Bollinger Band.
2. Entry Fill Timing: If you’ve selected "Daily Open," the entry order will be placed at the next day's open price.
3. Stop Loss: Positioned at the nearest daily swing low to minimize risk.
4. Take Profit: If SPY price moves up and reaches the upper Bollinger Band, the position is automatically closed.

Indicator Features and Benefits
* Multi-Time Frame Compatibility: Perform daily analysis while tracking signals on any intraday chart.
* Automatic Position Sizing: Tailor risk per trade based on account balance and desired risk percentage.
* Flexible Entry Options: Choose from close, open, HOD, or LOD for optimal timing.
* Effective Trend Reversal Identification: Uses wick-to-body ratio and Bollinger Band interaction to pinpoint potential reversals.
* Dynamic Visualization: Bollinger Bands are displayed on your chosen time frame, allowing seamless intraday tracking.

Summary
The Trade Entry Detector provides a unique, data-driven way to spot reversal points with customizable entry options. By combining Bollinger Bands with wick-to-body ratio conditions, it identifies potential trade setups where price has tested extremes and shown reversal signals. With its flexible entry timing, risk management features, and multi-time frame compatibility, this indicator is ideal for traders looking to blend daily market context with shorter-term execution.
Tips for Usage:
* For swing trading, consider the Daily Open or Close entry options.
* For momentum entries, HOD or LOD may offer better alignment with the direction of the wick.
* Backtest on different assets to find optimal Bollinger Band and wick-to-body settings for your market.
Use this indicator to enhance your understanding of price behavior at key levels and improve the precision of your entry points. Happy trading!

## Source Code

````pine
//@version=5
strategy("Trade Entry Detector, based on Wick to Body Ratio when price tests Bollinger Bands", overlay=true, default_qty_type=strategy.fixed)

// Input for primary analysis time frame
timeFrame = "D"  // Daily time frame

// Bollinger Band settings
length = input.int(20, title="Bollinger Band Length", minval=1)
mult = input.float(2.0, title="Standard Deviation Multiplier", minval=0.1)
source = input(close, title="Source")

// Entry ratio settings
wickToBodyRatio = input.float(1.0, title="Minimum Wick-to-Body Ratio", minval=0)

// Order Fill Timing Option
fillOption = input.string("Daily Close", title="Order Fill Timing", options=["Daily Close", "Daily Open", "HOD", "LOD"])

// Account and risk settings
accountBalance = 100000  // Account balance in dollars
riskPercentage = 1.0     // Risk percentage per trade
riskAmount = (riskPercentage / 100) * accountBalance // Fixed 1% risk amount

// Request daily data for calculations
dailyHigh = request.security(syminfo.tickerid, timeFrame, high)
dailyLow = request.security(syminfo.tickerid, timeFrame, low)
dailyClose = request.security(syminfo.tickerid, timeFrame, close)
dailyOpen = request.security(syminfo.tickerid, timeFrame, open)

// Calculate Bollinger Bands on the daily time frame
dailyBasis = request.security(syminfo.tickerid, timeFrame, ta.sma(source, length))
dailyDev = mult * request.security(syminfo.tickerid, timeFrame, ta.stdev(source, length))
dailyUpperBand = dailyBasis + dailyDev
dailyLowerBand = dailyBasis - dailyDev

// Calculate the body and wick sizes on the daily time frame
dailyBodySize = math.abs(dailyOpen - dailyClose)
dailyUpperWickSize = dailyHigh - math.max(dailyOpen, dailyClose)
dailyLowerWickSize = math.min(dailyOpen, dailyClose) - dailyLow

// Conditions for a candle with an upper wick or lower wick that touches the Bollinger Bands
upperWickCondition = (dailyUpperWickSize / dailyBodySize >= wickToBodyRatio) and (dailyHigh > dailyUpperBand)
lowerWickCondition = (dailyLowerWickSize / dailyBodySize >= wickToBodyRatio) and (dailyLow < dailyLowerBand)

// Define the swing high and swing low for stop loss placement
var float swingLow = na
var float swingHigh = na

if (ta.pivothigh(dailyHigh, 5, 5))
    swingHigh := dailyHigh[5]

if (ta.pivotlow(dailyLow, 5, 5))
    swingLow := dailyLow[5]

// Determine entry price based on chosen fill option
var float longEntryPrice = na
var float shortEntryPrice = na

if lowerWickCondition
    longEntryPrice := fillOption == "Daily Close" ? dailyClose :
                      fillOption == "Daily Open" ? dailyOpen :
                      fillOption == "HOD" ? dailyHigh : dailyLow

if upperWickCondition
    shortEntryPrice := fillOption == "Daily Close" ? dailyClose :
                       fillOption == "Daily Open" ? dailyOpen :
                       fillOption == "HOD" ? dailyHigh : dailyLow

// Execute the long and short entries with expiration
var int longOrderExpiry = na
var int shortOrderExpiry = na

if not na(longEntryPrice)
    longOrderExpiry := bar_index + 2  // Order expires after 2 days

if not na(shortEntryPrice)
    shortOrderExpiry := bar_index + 2  // Order expires after 2 days

// Check expiration and execute orders
if (longEntryPrice and bar_index <= longOrderExpiry and high >= longEntryPrice)
    longStopDistance = close - nz(swingLow, close)
    longPositionSize = longStopDistance > 0 ? riskAmount / longStopDistance : na
    if (not na(longPositionSize))
        strategy.entry("Long", strategy.long, qty=longPositionSize)
    longEntryPrice := na  // Reset after entry

if (shortEntryPrice and bar_index <= shortOrderExpiry and low <= shortEntryPrice)
    shortStopDistance = nz(swingHigh, close) - close
    shortPositionSize = shortStopDistance > 0 ? riskAmount / shortStopDistance : na
    if (not na(shortPositionSize))
        strategy.entry("Short", strategy.short, qty=shortPositionSize)
    shortEntryPrice := na  // Reset after entry

// Exit logic: hit the opposing Bollinger Band
if (strategy.position_size > 0) // Long position
    strategy.exit("Exit Long", "Long", limit=dailyUpperBand)
else if (strategy.position_size < 0) // Short position
    strategy.exit("Exit Short", "Short", limit=dailyLowerBand)

if (strategy.position_size > 0) // Long position
    strategy.exit("Stop Loss Long", "Long", stop=swingLow)
else if (strategy.position_size < 0) // Short position
    strategy.exit("Stop Loss Short", "Short", stop=swingHigh)

// Plot daily Bollinger Bands and levels on the chosen time frame
plot(dailyUpperBand, color=color.blue, linewidth=1, title="Daily Upper Bollinger Band")
plot(dailyLowerBand, color=color.blue, linewidth=1, title="Daily Lower Bollinger Band")
plot(dailyBasis, color=color.gray, linewidth=1, title="Daily Middle Bollinger Band")
````
