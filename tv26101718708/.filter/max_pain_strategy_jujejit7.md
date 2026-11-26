# Max Pain Strategy

- url: https://www.tradingview.com/script/JUJejit7/
- type: strategy
- pine_id: PUB;54e1fcfd470a484ba988f4069147d91f
- version: 2.0

## Description

The Max Pain Strategy uses a combination of volume and price movement thresholds to identify potential "pain zones" in the market. A "pain zone" is considered when the volume exceeds a certain multiple of its average over a defined lookback period, and the price movement exceeds a predefined percentage relative to the price at the beginning of the lookback period.

Here’s how the strategy functions step-by-step:

Inputs:
        
length: Defines the lookback period used to calculate the moving average of volume and the price change over that period.
        
volMultiplier: Sets a threshold multiplier for the volume; if the volume exceeds the average volume multiplied by this factor, it triggers the condition for a potential "pain zone."
        
priceMultiplier: Sets a threshold for the minimum percentage price change that is required for a "pain zone" condition.

Calculations:
        
averageVolume: The simple moving average (SMA) of volume over the specified lookback period.
        
priceChange: The absolute difference in price between the current bar's close and the close from the lookback period (length).

Pain Zone Condition:
        
The condition for entering a position is triggered if both the volume is higher than the average volume by the volMultiplier and the price change exceeds the price at the length-period ago by the priceMultiplier. This is an indication of significant market activity that could result in a price move.

Position Entry:
        
A long position is entered when the "pain zone" condition is met.

Exit Strategy:
        
The position is closed after the specified holdPeriods, which defines how many periods the position will be held after being entered.

Visualization:

A small triangle is plotted on the chart where the "pain zone" condition is met.
The background color changes to a semi-transparent red when the "pain zone" is active.

Scientific Explanation of the Components

Volume Analysis and Price Movement: These are two critical factors in trading strategies. Volume often serves as an indicator of market strength (or weakness), and price movement is a direct reflection of market sentiment. Higher volume with significant price movement may suggest that the market is entering a phase of increased volatility or trend formation, which the strategy aims to exploit.
        
Volume analysis: The study of volume as an indicator of market participation, with increased volume often signaling stronger trends (Murphy, J. J., Technical Analysis of the Financial Markets).
        
Price movement thresholds: A large price change over a short period may be interpreted as a breakout or a potential reversal point, aligning with volatility and liquidity analysis (Schwager, J. D., Market Wizards).

Repainting Check: This strategy does not involve any repainting because it is based on current and past data, and there is no reference to future values in the decision-making process. However, any strategy that uses lagging indicators or conditions based on historical bars, like close[length], is inherently a lagging strategy and might not predict real-time price action accurately until after the fact.

Risk Management: The position hold duration is predefined, which adds an element of time-based risk control. This duration ensures that the strategy does not hold a position indefinitely, which could expose it to unnecessary risk.

Potential Issues and Considerations

Repainting:
        
The strategy does not utilize future data or conditions that depend on future bars, so it does not inherently suffer from repainting issues.
        
However, since the strategy relies on volume and price change over a set lookback period, the decision to enter or exit a trade is only made after the data for the current bar is complete, meaning the trade decisions are somewhat delayed, which could be seen as a lagging feature rather than a repainting one.

Lagging Nature:
        
As with many technical analysis-based strategies, this one is based on past data (moving averages, price changes), meaning it reacts to market movements after they have already occurred, rather than predicting future price actions.

Overfitting Risk:
        
With parameters like the lookback period and multipliers being user-adjustable, there is a risk of overfitting to historical data. Adjusting parameters too much based on past performance can lead to poor out-of-sample results (Gauthier, P., Practical Quantitative Finance).

Conclusion

The Max Pain Strategy is a simple approach to identifying potential market entries based on volume spikes and significant price changes. It avoids repainting by relying solely on historical and current bar data, but it is inherently a lagging strategy that reacts to price and volume patterns after they have occurred. Therefore, the strategy can be effective in trending markets but may struggle in highly volatile, sideways markets.

## Source Code

````pine
//@version=5
strategy("YM Max Pain Strategy with Visualization", overlay=true, precision=1, initial_capital=25000, currency=currency.USD, slippage=1, commission_type=strategy.commission.cash_per_contract, commission_value=0.01)

// === Inputs ===
length = input.int(70, title="Lookback Period", minval=1, maxval=500, tooltip="Lookback period for volume analysis", step=1)  // Lookback period for volume analysis
volMultiplier = input.float(1.0, title="Volume Multiplier", minval=1.0, maxval=5.0, tooltip="Threshold multiplier for volume", step=0.1)  // Threshold multiplier for volume
priceMultiplier = input.float(0.029, title="Price Change Multiplier", minval=0.01, maxval=0.1, tooltip="Threshold for price movement", step=0.001)  // Threshold for price movement
stopLossMultiplier = input.float(2.4, title="Stop-Loss Multiplier", minval=1.0, tooltip="Multiplier for volatility-based stop-loss", step=0.1)
vixThreshold = input.float(44.0, title="VIX Threshold", minval=0.0, tooltip="VIX level below which trading is allowed")  // Volatility filter threshold

// === Volatility Data ===
// Request VIX data (TVC:VIX)
vixClose = request.security("TVC:VIX", "D", close, lookahead=barmerge.lookahead_off)

// === Calculations ===
// Average volume and price change
averageVolume = ta.sma(volume, length)  // Average volume over the period
priceChange = math.abs(close - close[length])  // Price change over the 'length' period

// Volatility calculation
volatility = ta.stdev(close, length)  // Standard deviation of close prices over the period
stopLossDistance = stopLossMultiplier * volatility  // Volatility-based stop-loss level

// Calculate the pain zone condition (potential delta-hedging areas)
painZoneCondition = (volume > averageVolume * volMultiplier) and (priceChange > close[length] * priceMultiplier)

// Volatility filter condition
volatilityCondition = vixClose < vixThreshold

// === Strategy ===
// Define the number of periods the position will be held
holdPeriods = input.int(8, title="Position Hold Duration (in periods)", minval=1)

// Long position condition
longCondition = painZoneCondition and volatilityCondition  // Add volatility filter to entry condition

// Position entry
if (longCondition)
    strategy.entry("Long", strategy.long)

// Volatility-based stop-loss
if (strategy.position_size > 0)
    stopPrice = strategy.position_avg_price - stopLossDistance
    strategy.exit("Volatility Stop", "Long", stop=stopPrice)

// Close position after the specified number of periods
if (strategy.opentrades > 0)
    if (bar_index >= strategy.opentrades.entry_bar_index(0) + holdPeriods)
        strategy.close("Long")

// === Visualization ===

// Max Pain Zone Highlight
plotshape(painZoneCondition and volatilityCondition, title="Max Pain Zone (Filtered)", style=shape.triangleup, location=location.bottom, color=color.rgb(40, 210, 90), size=size.tiny)  // Red triangle for max pain zone
bgcolor(painZoneCondition and volatilityCondition ? color.new(color.rgb(50, 80, 150), 30) : na)  // Red background for max pain zone
````
