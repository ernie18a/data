Calculation: Global M2 = sum of US, Eurozone, Japan, China, UK, and Canada M2, each converted to USD using its corresponding exchange rate
Calculation: Liquidity impulse z-score = z-score of the rate of change of smoothed Global M2 against its trailing lookback
Calculation: Confirmed liquidity regime = bullish after the impulse z-score exceeds the positive threshold for the confirmation period; bearish after it falls below the negative threshold for the confirmation period; retain the prior regime between thresholds
Calculation: Fast price average = Wilder-smoothed selected trend price with a shorter lookback
Calculation: Slow price average = Wilder-smoothed selected trend price with a longer lookback
Long: Confirmed liquidity regime is bullish OR fast price average > slow price average
Exit: Long, confirmed liquidity regime is bearish AND fast price average < slow price average, after the minimum hold period