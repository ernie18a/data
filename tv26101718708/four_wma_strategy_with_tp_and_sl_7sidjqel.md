# Four WMA Strategy with TP and SL

- url: https://www.tradingview.com/script/7SIdJQEl-Four-WMA-Strategy-with-TP-and-SL/
- type: strategy
- pine_id: PUB;e0d7d8e8c78f4fed8098915d24e52560
- version: 2.0

## Description

Basically I read a research paper on how they used different moving averages for long entries and short entries, and it kind of dawned on me that I always used the same one for long entry or exit, or even swing trading. So I smashed this together to see what would happen.
The strategy combines the use of four different WMAs for identifying trade entry points, along with a predefined take profit (TP) and stop loss (SL) for risk management. Here's a detailed description of its features and how it operates:

Main Features

1. **WMAs as the Core Indicator**:
- The strategy uses four WMAs with different lengths. Two WMAs (`longM1` and `longM2`) are used for long entry signals, and the other two (`shortM1` and `shortM2`) for short entry signals.
- The lengths of these WMAs are adjustable through input parameters.

2. **Trade Entry Conditions**:
- A long entry is signaled when the shorter WMA crosses under the longer WMA .
- Conversely, a short entry is signaled when the shorter WMA crosses under the longer WMA.

3. **Take Profit and Stop Loss**:
- The strategy includes a take profit and stop loss mechanism.
- The TP and SL levels are set as a percentage of the entry price, with the percentage values being adjustable through input parameters.

4. **Visual Representation**:
- The WMAs are plotted on the chart for visual aid, each with a distinct color for easy identification.

How It Works

- The strategy continuously monitors the crossing of WMAs to detect potential entry points for long and short positions.
- Upon detecting a long or short condition, it automatically enters a trade and sets the corresponding TP and SL levels based on the current price and the specified percentages.
- The strategy then actively manages the trade, exiting the position when either the TP or SL level is reached.

Drawbacks

- **Overreliance on WMAs**: The strategy heavily relies on WMAs for trade signals. While WMAs are useful for identifying trends, they might not always provide timely entry and exit signals.
- **Market Conditions**: It may not perform well in highly volatile or sideways markets where WMA crossovers could lead to false signals.
- **Risk Management**: The fixed percentage for TP and SL might not be suitable for all market conditions. Traders might need to adjust these values frequently based on market volatility and their risk tolerance. 
Apparently I need to emphasize to use brains when using indicators and setting them up to achieve the results you can or want. Also risk of 12% is considered very high so I lowered the numbers to 5%, which tanked the profits, try adjusting them on your own. Check the properties settings for more info on comission and slippage. 

Conclusion

The "Four WMA Strategy with TP and SL" is suitable for traders who prefer a moving average-based approach to trading, combined with a straightforward mechanism for risk management through take profit and stop loss. However, like all strategies, it should be used with an understanding of its limitations and ideally tested thoroughly in various market conditions before applying it to live trading.

## Source Code

````pine
//@version=6
strategy('Four MA Strategy with TP and SL', shorttitle = '4MA TP/SL', overlay = true)

// Inputs for MA lengths
longM1 = input.int(10, title = 'Long MA1')
longM2 = input.int(20, title = 'Long MA2')
shortM1 = input.int(30, title = 'Short MA1')
shortM2 = input.int(40, title = 'Short MA2')

// Inputs for MA Type
maTypeInput = input.string('WMA', title = 'Moving Average Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA'])

// Inputs for TP and SL activation
tp_sl_active = input.bool(true, title = 'Enable TP and SL')

// Inputs for TP and SL
tp_percent = input.float(1.0, title = 'Take Profit %') / 100
sl_percent = input.float(1.0, title = 'Stop Loss %') / 100

// Direction Choice
direction = input.string('Both', title = 'Trade Direction', options = ['Long Only', 'Short Only', 'Both'])

// Alternate Exit Conditions
enable_alt_exit = input.bool(false, title = 'Enable Alternate Exit Condition')
alt_exit_ma_choice = input.string('Long MA1', title = 'MA for Alternate Exit', options = ['Long MA1', 'Long MA2', 'Short MA1', 'Short MA2'])

// Moving Average Calculation Function
ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)
        'RMA' => ta.rma(source, length)

// Calculating MAs
longMA1 = ma(close, longM1, maTypeInput)
longMA2 = ma(close, longM2, maTypeInput)
shortMA1 = ma(close, shortM1, maTypeInput)
shortMA2 = ma(close, shortM2, maTypeInput)

// Resolving Alternate Exit MA
alt_exit_ma = switch alt_exit_ma_choice
    'Long MA1' => longMA1
    'Long MA2' => longMA2
    'Short MA1' => shortMA1
    'Short MA2' => shortMA2

// Entry and Exit Conditions
longCondition = ta.crossover(longMA1, longMA2)
longExitCondition = ta.crossunder(longMA1, longMA2)
shortCondition = ta.crossunder(shortMA1, shortMA2)
shortExitCondition = ta.crossover(shortMA1, shortMA2)

// Alternate Exit Condition
priceCrossAltExit = close < alt_exit_ma

// Strategy Entry and Exit
if direction == 'Both' or direction == 'Long Only'
    if longCondition
        strategy.entry('Long', strategy.long, comment = '')
    if tp_sl_active
        strategy.exit('Long TP/SL', 'Long', limit = strategy.position_avg_price * (1 + tp_percent), stop = strategy.position_avg_price * (1 - sl_percent))
    if longExitCondition or (enable_alt_exit and priceCrossAltExit)
        strategy.close('Long', comment = '')

if direction == 'Both' or direction == 'Short Only'
    if shortCondition
        strategy.entry('Short', strategy.short, comment = 'Short entry')
    if tp_sl_active
        strategy.exit('Short TP/SL', 'Short', limit = strategy.position_avg_price * (1 - tp_percent), stop = strategy.position_avg_price * (1 + sl_percent))
    if shortExitCondition or (enable_alt_exit and priceCrossAltExit)
        strategy.close('Short', comment = 'Short Exit')

// Plotting MAs
plot(longMA1, color = color.blue, title = 'Long MA1')
plot(longMA2, color = color.orange, title = 'Long MA2')
plot(shortMA1, color = color.red, title = 'Short MA1')
plot(shortMA2, color = color.purple, title = 'Short MA2')
````
