Calculation: Volume-weighted price = sum(volume × selected bar price) / max(sum(volume), 1) over a rolling lookback.
Calculation: Normalized oscillator = 100 × (volume-weighted price − its rolling minimum) / max(its rolling maximum − its rolling minimum, price increment) − 50.
Calculation: First smoothed oscillator = moving average of the normalized oscillator; second smoothed oscillator = moving average of the first smoothed oscillator, using the same method and parameters.
Long: First smoothed oscillator > second smoothed oscillator on the chart timeframe OR on a higher timeframe using the bar still forming.
Short: First smoothed oscillator <= second smoothed oscillator on the chart timeframe OR on a higher timeframe using the bar still forming.