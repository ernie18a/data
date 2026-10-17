# Dual RSI Differential - Strategy [presentTrading]

- url: https://www.tradingview.com/script/VHbRaeUe-Dual-RSI-Differential-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;c3227fe6f5c64310858a673ccbf81fe1
- version: 1.0

## Description

█ Introduction and How it is Different

The Dual RSI Differential Strategy introduces a nuanced approach to market analysis and trading decisions by utilizing two Relative Strength Index (RSI) indicators calculated over different time periods. Unlike traditional strategies that employ a single RSI and may signal premature or delayed entries, this method leverages the differential between a shorter and a longer RSI. This approach pinpoints more precise entry and exit points, providing a refined tool for traders to exploit market conditions effectively, particularly in overbought and oversold scenarios.

Most important: it is a good eductional code for swing trading.
For beginners, this Pine Script provides a complete function that includes crucial elements such as holding days and the option to configure take profit/stop loss settings:
- Hold Days: This feature ensures that trades are not exited too hastily, helping traders to ride out short-term market volatility. It's particularly valuable for swing trading where maintaining positions slightly longer can lead to capturing significant trends.
- TPSL Condition (None by default): This setting allows traders to focus solely on the strategy's robust entry and exit signals without being constrained by preset profit or loss limits. This flexibility is crucial for learning to adjust strategy settings based on personal risk tolerance and market observations.

BTCUSD 6h LS Performance
[image]https://www.tradingview.com/x/lpwnCnFy/[/image]

█ Strategy, How It Works: Detailed Explanation
🔶 RSI Calculation:
The RSI is a momentum oscillator that measures the speed and change of price movements. It is calculated using the formula:
RSI = 100 - (100 / (1 + RS))
Where RS (Relative Strength) = Average Gain of up periods / Average Loss of down periods.

🔶 Dual RSI Setup:
This strategy involves two RSI indicators:
RSI_Short (RSI_21): Calculated over a short period (21 days).
RSI_Long (RSI_42): Calculated over a longer period (42 days).

Differential Calculation:
The strategy focuses on the differential between these two RSIs:
RSI Differential = RSI_Long - RSI_Short
This differential helps to identify when the shorter-term sentiment diverges from longer-term trends, signaling potential trading opportunities.

BTCUSD Local picuture
[image]https://www.tradingview.com/x/m1hlL74G/[/image]

🔶 Signal Triggers:

Entry Signal: A buy (long) signal is triggered when the RSI Differential exceeds -5, suggesting strengthening short-term momentum. Conversely, a sell (short) signal occurs when the RSI Differential falls below +5, indicating weakening short-term momentum.
Exit Signal: Trades are generally exited when the RSI Differential reverses past these thresholds, indicating a potential momentum shift.

█ Trade Direction
This strategy accommodates various trading preferences by allowing selections among long, short, or both directions, thus enabling traders to capitalize on diverse market movements and volatility.

█ Usage
The Dual RSI Differential Strategy is particularly suited for:
Traders who prefer a systematic approach to capture market trends.
Those who seek to minimize risks associated with rapid and unexpected market movements.
Traders who value strategies that can be finely tuned to different market conditions.

█ Default Settings
- Trading Direction: Both — allows capturing of upward and downward market movements.
- Short RSI Period: 21 days — balances sensitivity to market movements.
- Long RSI Period: 42 days — smoothens out longer-term fluctuations to provide a clearer market trend.
- RSI Difference Level: 5 — minimizes false signals by setting a moderate threshold for action.
Use Hold Days: True — introduces a temporal element to trading strategy, holding positions to potentially enhance outcomes.
- Hold Days: 5 — ensures that trades are not exited too hastily, helping to ride out short-term volatility.
- TPSL Condition: None — enables traders to focus solely on the strategy's entry and exit signals without preset profit or loss limits.
- Take Profit Percentage: 15% — aims for significant market moves to lock in profits.
- Stop Loss Percentage: 10% — safeguards against large losses, essential for long-term capital preservation.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

// This strategy stands out by using two distinct RSI lengths, analyzing the differential between these to make precise trading decisions. 
// Unlike conventional single RSI strategies, this method provides a more nuanced view of market dynamics, allowing traders to exploit 
// both overbought and oversold conditions with greater accuracy.

//@version=5
strategy("Dual RSI Differential - Strategy [presentTrading]", overlay=false, precision=3, 
 commission_value=0.1, commission_type=strategy.commission.percent, slippage=1, 
 currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=10, initial_capital=10000)

// Input parameters for user customization
tradeDirection = input.string("Both", "Trading Direction", options=["Long", "Short", "Both"])
lengthShort = input(21, title="Short RSI Period")
lengthLong = input(42, title="Long RSI Period")
rsiDiffLevel = input(5, title="RSI Difference Level")
useHoldDays = input.bool(true, title="Use Hold Days")
holdDays = input.int(5, title="Hold Days", minval=1, maxval=20, step=1)
TPSLCondition = input.string("None", "TPSL Condition", options=["TP", "SL", "Both", "None"])

takeProfitPerc = input(15.0, title="Take Profit (%)")
stopLossPerc = input(10.0, title="Stop Loss (%)")
// Calculate RSIs
rsiShort = ta.rsi(close, lengthShort)
rsiLong = ta.rsi(close, lengthLong)

// Calculate RSI Difference
rsiDifference = rsiLong  - rsiShort

// Plotting
hline(rsiDiffLevel, "Level +20", color=color.green, linestyle=hline.style_dashed)
hline(-rsiDiffLevel, "Level -20", color=color.red, linestyle=hline.style_dashed)

// Variables to track entry times
var float longEntryTime = na
var float shortEntryTime = na

// Condition for significant RSI difference
combinedLongCondition = rsiDifference < -rsiDiffLevel
combinedExitLongCondition = rsiDifference > rsiDiffLevel
combinedShortCondition = rsiDifference > rsiDiffLevel
combinedExitShortCondition = rsiDifference < -rsiDiffLevel

// Strategy logic using conditions and direction selection
if (tradeDirection == "Long" or tradeDirection == "Both") 
    if (combinedLongCondition) 
        strategy.entry("Long", strategy.long)
        longEntryTime := time
    if (useHoldDays and (time - longEntryTime >= holdDays * 86400000 or combinedExitLongCondition))
        strategy.close("Long")
    else if (useHoldDays == false  and combinedExitLongCondition)
        strategy.close("Long")

if (tradeDirection == "Short" or tradeDirection == "Both") 
    if (combinedShortCondition) 
        strategy.entry("Short", strategy.short)
        shortEntryTime := time
    if (useHoldDays and (time - shortEntryTime >= holdDays * 86400000 or combinedExitShortCondition))
        strategy.close("Short")
    else if (useHoldDays == false and combinedExitShortCondition)
        strategy.close("Short")


// Conditional Profit and Loss Management
if (TPSLCondition == "TP" or TPSLCondition == "Both") 
    // Apply take profit conditions
    strategy.exit("TakeProfit_Long", "Long", profit=close * (1 + takeProfitPerc / 100), limit=close * (1 + takeProfitPerc / 100))
    strategy.exit("TakeProfit_Short", "Short", profit=close * (1 - takeProfitPerc / 100), limit=close * (1 - takeProfitPerc / 100))


if (TPSLCondition == "SL" or TPSLCondition == "Both") 
    // Apply stop loss conditions
    strategy.exit("StopLoss_Long", "Long", loss=close * (1 - stopLossPerc / 100), stop=close * (1 - stopLossPerc / 100))
    strategy.exit("StopLoss_Short", "Short", loss=close * (1 + stopLossPerc / 100), stop=close * (1 + stopLossPerc / 100))


bgcolor(combinedLongCondition ? color.new(color.green, 90) : na, title="Background Color for Significant Long RSI Diff")
bgcolor(combinedShortCondition ? color.new(color.red, 90) : na, title="Background Color for Significant Short RSI Diff")

// Plot RSIs and their difference
plot(rsiDifference, title="RSI Difference (35-7)", color=color.fuchsia)

// Alerts
alertcondition(combinedLongCondition, title="Significant Long RSI Difference Alert", message="RSI Difference is significant Long at {{close}} with RSI7 at {{rsiShort}} and RSI35 at {{rsiLong}}.")
alertcondition(combinedShortCondition, title="Significant Short RSI Difference Alert", message="RSI Difference is significant Short at {{close}} with RSI7 at {{rsiShort}} and RSI35 at {{rsiLong}}.")
````
