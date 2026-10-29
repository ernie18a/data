Calculation: 20% price level = lowest low and highest high over the same lookback on a higher timeframe, using the bar still forming: lowest low + 20% of their difference
Calculation: 80% price level = lowest low and highest high over the same lookback on a higher timeframe, using the bar still forming: lowest low + 80% of their difference
Calculation: Bearish embed level = the lower of the current and prior 20% price levels
Calculation: Bullish embed level = the higher of the current and prior 80% price levels
Calculation: Scaled %K = Bearish embed level + (smoothed stochastic %K − 20) × (Bullish embed level − Bearish embed level) / 60; stochastic uses the selected timeframe's bar still forming
Long: Close > Bearish embed level AND Scaled %K > prior Scaled %K AND Scaled %K crosses above Bearish embed level
Short: Close < Bullish embed level AND Scaled %K < prior Scaled %K AND Scaled %K crosses below Bullish embed level