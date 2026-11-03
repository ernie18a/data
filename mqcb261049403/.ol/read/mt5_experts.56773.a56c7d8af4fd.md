Calculation: Weibull probability = Weibull probability density evaluated for each close from the configured M1 timeframe, using the last lookback window including its still-forming bar; use the final output.
Calculation: Poisson probability = Poisson cumulative distribution of cumulative counts of consecutive M1 close changes whose absolute size exceeds a threshold; set the Poisson rate to the mean of those cumulative counts. Use the last output. Use the same M1 bars as for Weibull probability, including the still-forming bar.
Calculation: M1 close change = oldest close minus newest close in the lookback window on the configured M1 timeframe, including its still-forming bar.
Calculation: M15 close change = oldest close minus newest close in the lookback window on the configured M15 timeframe, including its still-forming bar.
Calculation: H1 close range = highest close minus lowest close in the lookback window on the configured H1 timeframe, including its still-forming bar.
Calculation: H1 close change = newest close minus oldest close in the lookback window on the configured H1 timeframe, including its still-forming bar.
Long: Poisson probability > breakout threshold AND Weibull probability > mean-reversion threshold AND M1 close change > 0 AND M15 close change > 0 AND H1 close range > minimum volatility threshold
Short: Weibull probability < mean-reversion threshold AND absolute H1 close change < maximum trend threshold
Calculation: ATR = average true range on the chart timeframe, using the bar still forming.
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance