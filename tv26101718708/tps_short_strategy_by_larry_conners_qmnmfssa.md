# TPS Short Strategy by Larry Conners

- url: https://www.tradingview.com/script/qMNMfsSa/
- type: strategy
- pine_id: PUB;5977a8c132e54fd891370d54124638b1
- version: 1.0

## Description

The TPS Short strategy aims to capitalize on extreme overbought conditions in an ETF by employing a scaling-in approach when certain technical indicators signal potential reversals. The strategy is designed to short the ETF when it is deemed overextended, based on the Relative Strength Index (RSI) and moving averages.
Components:

200-Day Simple Moving Average (SMA):
        
Purpose: Acts as a long-term trend filter. The ETF must be below its 200-day SMA to be eligible for shorting.
        
Rationale: The 200-day SMA is widely used to gauge the long-term trend of a security. When the price is below this moving average, it is often considered to be in a downtrend (Tushar S. Chande & Stanley Kroll, "The New Technical Trader: Boost Your Profit by Plugging Into the Latest Indicators").


2-Period RSI:
        
Purpose: Measures the speed and change of price movements to identify overbought conditions.
        
Criteria: Short 10% of the position when the 2-period RSI is above 75 for two consecutive days.
        
Rationale: A high RSI value (above 75) indicates that the ETF may be overbought, which could precede a price reversal (J. Welles Wilder, "New Concepts in Technical Trading Systems").

Scaling-In Mechanism:
        
Purpose: Gradually increase the short position as the ETF price rises beyond previous entry points.

Scaling Strategy:
            20% more when the price is higher than the first entry.
            30% more when the price is higher than the second entry.
            40% more when the price is higher than the third entry.
        
Rationale: This incremental approach allows for an increased position size in a worsening trend, potentially increasing profitability if the trend continues to align with the strategy’s premise (Marty Schwartz, "Pit Bull: Lessons from Wall Street's Champion Day Trader").

    
Exit Conditions:
        
Criteria: Close all positions when the 2-period RSI drops below 30 or the 10-day SMA crosses above the 30-day SMA.
        
Rationale: A low RSI value (below 30) suggests that the ETF may be oversold and could be poised for a rebound, while the SMA crossover indicates a potential change in the trend (Martin J. Pring, "Technical Analysis Explained").

Risks and Considerations:

Market Risk:
        
The strategy assumes that the ETF will continue to decline once shorted. However, markets can be unpredictable, and price movements might not align with the strategy's expectations, especially in a volatile market (Nassim Nicholas Taleb, "The Black Swan: The Impact of the Highly Improbable").

Scaling Risks:
        
Scaling into a position as the price increases may increase exposure to adverse price movements. This method can amplify losses if the market moves against the position significantly before any reversal occurs.

Liquidity Risk:
        
Depending on the ETF’s liquidity, executing large trades in increments might affect the price and increase trading costs. It is crucial to ensure that the ETF has sufficient liquidity to handle large trades without significant slippage (James Altucher, "Trade Like a Hedge Fund").

Execution Risk:
        
The strategy relies on timely execution of trades based on specific conditions. Delays or errors in order execution can impact performance, especially in fast-moving markets.

Technical Indicator Limitations:
        
Technical indicators like RSI and SMA are based on historical data and may not always predict future price movements accurately. They can sometimes produce false signals, leading to potential losses if used in isolation (John Murphy, "Technical Analysis of the Financial Markets").

Conclusion

The TPS Short strategy utilizes a combination of long-term trend filtering, overbought conditions, and incremental shorting to potentially profit from price reversals. While the strategy has a structured approach and leverages well-known technical indicators, it is essential to be aware of the inherent risks, including market volatility, liquidity issues, and potential limitations of technical indicators. As with any trading strategy, thorough backtesting and risk management are crucial to its successful implementation.

## Source Code

````pine
//@version=5
strategy("TPS Short Strategy by Larry Conners", overlay=true, default_qty_value=1, initial_capital=20000, commission_value = 0.05, slippage=1)

// Define parameters as inputs
sma_length_200 = input.int(200, title="200-Day SMA Length")
rsi_length_2 = input.int(2, title="2-Period RSI Length")
sma_length_10 = input.int(10, title="10-Day SMA Length")
sma_length_30 = input.int(30, title="30-Day SMA Length")

// Define colors as RGB values
color_sma_200 = input.color(color.rgb(0, 0, 255), title="200-Day SMA Color") // Blue
color_sma_10 = input.color(color.rgb(255, 0, 0), title="10-Day SMA Color") // Red
color_sma_30 = input.color(color.rgb(0, 255, 0), title="30-Day SMA Color") // Green

// Calculate indicators
sma_200 = ta.sma(close, sma_length_200)
rsi_2 = ta.rsi(close, rsi_length_2)
sma_10 = ta.sma(close, sma_length_10)
sma_30 = ta.sma(close, sma_length_30)

// Define conditions
below_sma_200 = close < sma_200
rsi_2_above_75_two_days = rsi_2[1] > 75 and rsi_2 > 75
price_higher_than_entry = na(strategy.opentrades.entry_price(0)) ? false : close > strategy.opentrades.entry_price(0)

// Entry conditions
if (below_sma_200 and rsi_2_above_75_two_days and na(strategy.opentrades.entry_price(0)))
    strategy.entry("Short", strategy.short, qty=10) // Short 10% of the position

// Scaling in conditions
if (price_higher_than_entry)
    strategy.entry("Short2", strategy.short, qty=20) // Short 20% more of the position

if (price_higher_than_entry)
    strategy.entry("Short3", strategy.short, qty=30) // Short 30% more of the position

if (price_higher_than_entry)
    strategy.entry("Short4", strategy.short, qty=40) // Short 40% more of the position

// Exit conditions
exit_condition_rsi_below_30 = rsi_2 < 30
exit_condition_sma_cross = ta.crossover(sma_10, sma_30)

if (exit_condition_rsi_below_30 or exit_condition_sma_cross)
    strategy.close_all() // Close all positions

// Plot indicators
plot(sma_200, color=color_sma_200, title="200-Day SMA")
plot(sma_10, color=color_sma_10, title="10-Day SMA")
plot(sma_30, color=color_sma_30, title="30-Day SMA")
````
