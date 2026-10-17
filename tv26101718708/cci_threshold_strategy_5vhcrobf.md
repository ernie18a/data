# CCI Threshold Strategy

- url: https://www.tradingview.com/script/5VhcroBF/
- type: strategy
- pine_id: PUB;0a90990bf7714d3db6c53623677e064f
- version: 1.0

## Description

The CCI Threshold Strategy is a trading approach that utilizes the Commodity Channel Index (CCI) as a momentum indicator to identify potential buy and sell signals in financial markets. The CCI is particularly effective in detecting overbought and oversold conditions, providing traders with insights into possible price reversals. This strategy is designed for use in various financial instruments, including stocks, commodities, and forex, and aims to capitalize on price movements driven by market sentiment.

[b]Commodity Channel Index (CCI)[/b]

The CCI was developed by Donald Lambert in the 1980s and is primarily used to measure the deviation of a security's price from its average price over a specified period. 

The formula for CCI is as follows:

[i]CCI=(TypicalPrice−SMA)×0.015MeanDeviation
CCI=MeanDeviation(TypicalPrice−SMA)×0.015​[/i]

where:

[i]Typical Price = (High + Low + Close) / 3
    SMA = Simple Moving Average of the Typical Price
    Mean Deviation = Average of the absolute deviations from the SMA[/i]

The CCI oscillates around a zero line, with values above +100 indicating overbought conditions and values below -100 indicating oversold conditions (Lambert, 1980).

[b]Strategy Logic[/b]

The CCI Threshold Strategy operates on the following principles:

[b]Input Parameters:[/b]
        
Lookback Period: The number of periods used to calculate the CCI. A common choice is 9, as it balances responsiveness and noise.
        
Buy Threshold: Typically set at -90, indicating a potential oversold condition where a price reversal is likely.
        
Stop Loss and Take Profit: The strategy allows for risk management through customizable stop loss and take profit points.

[b]Entry Conditions:[/b]
        
A long position is initiated when the CCI falls below the buy threshold of -90, indicating potential oversold levels. This condition suggests that the asset may be undervalued and due for a price increase.

[b]Exit Conditions:[/b]
        
The long position is closed when the closing price exceeds the highest price of the previous day, indicating a bullish reversal. Additionally, if the stop loss or take profit thresholds are hit, the position will be exited accordingly.

[b]Risk Management:[/b]
        
The strategy incorporates optional stop loss and take profit mechanisms, which can be toggled on or off based on trader preference. This allows for flexibility in risk management, aligning with individual risk tolerances and trading styles.

[b]Benefits of the CCI Threshold Strategy[/b]

Flexibility: The CCI Threshold Strategy can be applied across different asset classes, making it versatile for various market conditions.
    
Objective Signals: The use of quantitative thresholds for entry and exit reduces emotional bias in trading decisions (Tversky & Kahneman, 1974).
    
Enhanced Risk Management: By allowing traders to set stop loss and take profit levels, the strategy aids in preserving capital and managing risk effectively.

[b]Limitations[/b]

Market Noise: The CCI can produce false signals, especially in highly volatile markets, leading to potential losses (Bollinger, 2001).
    
Lagging Indicator: As a lagging indicator, the CCI may not always capture rapid market movements, resulting in missed opportunities (Pring, 2002).

[b]Conclusion[/b]

The CCI Threshold Strategy offers a systematic approach to trading based on well-established momentum principles. By focusing on overbought and oversold conditions, traders can make informed decisions while managing risk effectively. As with any trading strategy, it is crucial to backtest the approach and adapt it to individual trading styles and market conditions.
References

Bollinger, J. (2001). Bollinger on Bollinger Bands. New York: McGraw-Hill.
    
Lambert, D. (1980). Commodity Channel Index. Technical Analysis of Stocks & Commodities, 2, 3-5.
    
Pring, M. J. (2002). Technical Analysis Explained. New York: McGraw-Hill.
    
Tversky, A., & Kahneman, D. (1974). Judgment under uncertainty: Heuristics and biases. Science, 185(4157), 1124-1131.

## Source Code

````pine
//@version=5
strategy("CCI Threshold Strategy", overlay=false, initial_capital=50000, pyramiding=0, commission_type=strategy.commission.cash_per_contract, commission_value=0.05, slippage=1)

// --- Input Parameters ---
// Lookback period for CCI calculation
lookbackPeriod = input.int(12, minval=1, title="CCI Lookback Period")
// Buy threshold for CCI; typically represents an oversold condition
buyThreshold = input.int(-90, title="CCI Buy Threshold")
// Stop loss and take profit settings
stopLoss = input.float(100.0, minval=0.0, title="Stop Loss in Points")
takeProfit = input.float(150.0, minval=0.0, title="Take Profit in Points")
// Checkboxes to enable/disable SL and TP
useStopLoss = input.bool(false, title="Enable Stop Loss")
useTakeProfit = input.bool(false, title="Enable Take Profit")

// --- Calculate CCI ---
// CCI (Commodity Channel Index) is used as a momentum indicator to identify oversold and overbought conditions
cci = ta.cci(close, length=lookbackPeriod)

// --- Define Buy and Sell Conditions ---
// Buy condition: CCI drops below -90, indicating potential oversold levels
longCondition = cci < buyThreshold

// Sell condition: Close price crosses above the previous day's high, signaling potential exit
sellCondition = close > ta.highest(close[1], 1)

// --- Strategy Execution ---
// Buy entry based on the long condition
if (longCondition)
    strategy.entry("Buy", strategy.long)

// Close the long position based on the sell condition
if (sellCondition)
    strategy.close("Buy")

// Optional: Add stop loss and take profit for risk management
if (longCondition)
    strategy.exit("Sell", from_entry="Buy", loss=useStopLoss ? stopLoss : na, profit=useTakeProfit ? takeProfit : na)

// --- Plotting for Visualization ---
// Plot CCI with threshold levels for better visualization
plot(cci, title="CCI", color=color.blue)
hline(buyThreshold, "Buy Threshold", color=color.red, linestyle=hline.style_dotted)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````
