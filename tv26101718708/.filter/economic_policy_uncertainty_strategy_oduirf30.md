# Economic Policy Uncertainty Strategy

- url: https://www.tradingview.com/script/oduiRf30/
- type: strategy
- pine_id: PUB;909d35cc739b4e9ea31337c6489e615a
- version: 1.0

## Description

This Pine Script strategy is designed to make trading decisions based on the Economic Policy Uncertainty Index for the United States (USEPUINDXD) using a Simple Moving Average (SMA) and a dynamic threshold. The strategy identifies opportunities by entering long positions when the SMA of the Economic Policy Uncertainty Index crosses above a user-defined threshold. An exit is triggered after a set number of bars have passed since the trade was opened. Additionally, the background is highlighted in green when a position is open to visually indicate active trades.

This strategy is intended to be used in portfolio management and trading systems where economic policy uncertainty plays a critical role in decision-making. The index provides insight into macroeconomic conditions, which can affect asset prices and investment returns.

The Economic Policy Uncertainty (EPU) Index is a significant metric used to gauge uncertainty related to economic policies in the United States. This index reflects the frequency of newspaper articles discussing economic uncertainty, government policies, and their potential impact on the economy. It has become a popular indicator for both academics and practitioners to analyze the effects of policy uncertainty on various economic and financial outcomes.
Importance of the EPU Index for Portfolio Decisions:

    Economic Policy Uncertainty and Investment Decisions:
    Research by Baker, Bloom, and Davis (2016) introduced the Economic Policy Uncertainty Index and explored how increased uncertainty leads to delays in investment and hiring decisions. Their study shows that heightened uncertainty, as captured by the EPU index, is associated with a contraction in economic activity and lower stock market returns. Investors tend to shift their portfolios towards safer assets during periods of high policy uncertainty .

Impact on Asset Prices:

Gulen and Ion (2016) demonstrated that policy uncertainty adversely affects corporate investment, leading to lower stock market returns. The study emphasized that firms reduce investment during periods of high policy uncertainty, which can significantly impact the pricing of risky assets. Consequently, portfolio managers need to account for policy uncertainty when making asset allocation decisions .

Global Implications:
    
Policy uncertainty is not only a domestic issue. Brogaard and Detzel (2015) found that U.S. economic policy uncertainty has significant spillover effects on global financial markets, affecting equity returns, bond yields, and foreign exchange rates. This suggests that global investors should incorporate U.S. policy uncertainty into their risk management strategies .

These studies underscore the importance of the Economic Policy Uncertainty Index as a tool for understanding macroeconomic risks and making informed portfolio management decisions. Strategies that incorporate the EPU index, such as the one described above, can help investors navigate periods of uncertainty by adjusting their exposure to different asset classes based on economic conditions.

## Source Code

````pine
//@version=5
strategy("Economic Policy Uncertainty Strategy", overlay=false)

// Input parameters
threshold = input(187, title="Threshold")  // Dynamic Threshold
sma_length = input(2, title="SMA Length")  // SMA Length
exit_periods = input(10, title="Exit after x Periods")  // Exit after a certain number of periods

// Data series for the base asset "FRED: USEPUINDXD"
// We use the request.security function to retrieve data from "FRED:USEPUINDXD".
usepuindxd = request.security("FRED:USEPUINDXD", "D", close)

// Calculation of the Simple Moving Average (SMA) based on the retrieved base asset
sma_value = ta.sma(usepuindxd, sma_length)

// Long Entry Condition: SMA crosses above the threshold
long_condition = ta.crossover(sma_value, threshold)

// Variable to track the number of periods since a trade was opened
var int bars_in_trade = na

// Entry Signal (Long)
if (long_condition)
    strategy.entry("Long", strategy.long)
    bars_in_trade := 0  // Set the counting variable to 0 when a trade is opened

// If a trade is active, count the number of periods
if (strategy.opentrades > 0)
    bars_in_trade := nz(bars_in_trade) + 1

// Exit Condition: Exit after a certain number of periods
if (bars_in_trade >= exit_periods)
    strategy.close("Long")
    bars_in_trade := na  // Reset the counting variable when the position is closed

// Set background color when a position is open
bgcolor(strategy.opentrades > 0 ? color.new(color.green, 50) : na)

// Plot the base asset, SMA, and threshold
plot(usepuindxd, title="USEPUINDXD", color=color.blue, display=display.none)
plot(sma_value, title="SMA", color=color.white)
hline(threshold, "Threshold", color=color.gray)
````
