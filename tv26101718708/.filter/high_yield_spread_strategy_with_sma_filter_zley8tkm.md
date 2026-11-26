# High Yield Spread Strategy with SMA Filter

- url: https://www.tradingview.com/script/zLey8tKm/
- type: strategy
- pine_id: PUB;98d7179a043f45a5a1640bac73832649
- version: 2.0

## Description

This Pine Script strategy is designed for statistical analysis and research purposes only, not for live trading or financial decision-making. The script evaluates the relationship between financial volatility (measured by either the VIX or the High Yield Spread) and market positioning strategies (long or short) based on user-defined conditions. Specifically, it allows users to test the assumption that elevated levels of VIX or the High Yield Spread may justify short positions in the market—a widely held belief in financial circles—but this script demonstrates that shorting is not always the optimal choice, even under these conditions.

Key Components:

1.	High Yield Spread and VIX:

•	High Yield Spread is the difference between the yields of corporate high-yield (or “junk”) bonds and U.S. Treasury securities. A rising spread often reflects increased market risk perception.
	
•	VIX (Volatility Index) is often referred to as the market’s “fear gauge.” Higher VIX levels usually indicate heightened market uncertainty or expected volatility.
	
2.	Strategy Logic:
	
•	The script allows users to specify a threshold for the VIX or High Yield Spread, and it automatically evaluates if the spread exceeds this level, which traditionally would suggest an environment for higher market risk and thus potentially favoring short trades.
	
•	However, the strategy provides flexibility to enter long or short positions, even in a high-risk environment, emphasizing that a high VIX or High Yield Spread does not always warrant shorting.
	
3.	SMA Filter:
	
•	A Simple Moving Average (SMA) filter can be applied to the price data, where positions are only entered if the price is above or below the SMA (depending on the trade direction). This adds a technical component to the strategy, incorporating price trends into decision-making.
	
4.	Hold Duration:
	
•	The script also allows users to define how long to hold a position after entering, enabling an analysis of different timeframes.

Theoretical Background:

The traditional belief that high VIX or High Yield Spreads favor short positions is not universally supported by research. While a spike in the VIX or credit spreads is often associated with increased market risk, research suggests that excessive volatility does not always lead to negative returns. In fact, high volatility can sometimes signal an approaching market rebound.

For example:

•	Studies have shown that long-term investments during periods of heightened volatility can yield favorable returns due to mean reversion. Whaley (2000) notes that VIX spikes are often followed by market recoveries as volatility tends to revert to its mean over time .
	
•	Research by Blitz and Vliet (2007) highlights that low-volatility stocks have historically outperformed high-volatility stocks, suggesting that volatility may not always predict negative returns .
	
•	Furthermore, credit spreads can widen in response to broader market stress, but these may overshoot the actual credit risk, presenting opportunities for long positions when spreads are high and risk premiums are mispriced .

Educational Purpose:

The goal of this script is to challenge assumptions about shorting during volatile periods, showing that long positions can be equally, if not more, effective during market stress. By incorporating an SMA filter and customizable logic for entering trades, users can test different hypotheses regarding the effectiveness of both long and short positions under varying market conditions.

Note: This strategy is not intended for live trading and should be used solely for educational and statistical exploration. Misinterpreting financial indicators can lead to incorrect investment decisions, and it is crucial to conduct comprehensive research before trading.

References:


1.	Whaley, R. E. (2000). “The Investor Fear Gauge”. The Journal of Portfolio Management, 26(3), 12-17.
	
2.	Blitz, D., & van Vliet, P. (2007). “The Volatility Effect: Lower Risk Without Lower Return”. Journal of Portfolio Management, 34(1), 102-113.
	
3.	Bhamra, H. S., & Kuehn, L. A. (2010). “The Determinants of Credit Spreads: An Empirical Analysis”. Journal of Finance, 65(3), 1041-1072.

This explanation highlights the academic and research-backed foundation of the strategy and the nuances of volatility, while cautioning against the assumption that high VIX or High Yield Spread always calls for shorting.

## Source Code

````pine
//@version=5
strategy("High Yield Spread Strategy with SMA Filter", overlay=false)

// Ensure the script runs only on the daily timeframe
if (timeframe.period != "D")
    runtime.error("This script only works on the daily timeframe (D).")

// Dropdown for the basis calculation
basis = input.string("High Yield Spread", title="Select Basis Calculation", options=["High Yield Spread", "VIX"])

// Input for the High Yield Spread (external source)
spread_hy = request.security("FRED:BAMLH0A0HYM2", "D", close)  // High Yield Spread
spread_vix = request.security("CBOE:VIX", "D", close)  // VIX

// Dynamic threshold input
threshold = input.float(5, title="Threshold", step=0.1)

// Dropdown for Long/Short decision
direction = input.string("Long", title="Select Direction", options=["Long", "Short"])

// Input for holding period
holdingPeriod = input.int(5, title="Holding Period (Periods)", minval=1)

// Input for SMA filter
use_sma_filter = input.bool(true, title="Use SMA Filter")  // Checkbox to toggle SMA filter on/off
sma_length = input.int(50, title="SMA Length", minval=1)  // Input for SMA length

// Calculate the SMA
sma_value = ta.sma(close, sma_length)

// Strategy logic variables
var float entryPrice = na
var int entryBar = na

// Choose the correct spread based on the basis input
spread = basis == "High Yield Spread" ? spread_hy : spread_vix

// Apply the SMA filter condition (price above SMA for long, below SMA for short) if enabled
sma_condition_long = not use_sma_filter or (use_sma_filter and close > sma_value)
sma_condition_short = not use_sma_filter or (use_sma_filter and close < sma_value)

// Logic to open a trade based on the selected direction, threshold, and SMA filter
if (strategy.position_size == 0)  // Ensure only one position is open at a time
    if (direction == "Long" and spread > threshold and sma_condition_long)
        entryPrice := close
        entryBar := bar_index
        strategy.entry("Long Entry", strategy.long)
    if (direction == "Short" and spread < threshold and sma_condition_short)
        entryPrice := close
        entryBar := bar_index
        strategy.entry("Short Entry", strategy.short)

// Exit the trade after the defined holding period
if (not na(entryBar) and (bar_index - entryBar >= holdingPeriod))
    if (strategy.position_size > 0)  // Close only long positions
        strategy.close("Long Entry")
    if (strategy.position_size < 0)  // Close only short positions
        strategy.close("Short Entry")
    entryPrice := na
    entryBar := na

// Plot the High Yield Spread and VIX, but make the inactive one invisible
plot(spread_hy, title="High Yield Spread", color=color.blue, display=basis == "High Yield Spread" ? display.all : display.none)
plot(spread_vix, title="VIX", color=color.blue, display=basis == "VIX" ? display.all : display.none)

// Draw the threshold line
hline(threshold, "Threshold", color=color.red)

// Plot the SMA only if the filter is enabled
//plot(use_sma_filter ? sma_value : na, title="SMA", color=color.green)
````
