Calculation: Smoothed VWMA = EMA(VWMA(price source, lookback), smoothing lookback)
Calculation: Volume-weighted standard deviation = sqrt(VWMA((price source - Smoothed VWMA)^2, lookback))
Long: Smoothed VWMA > Smoothed VWMA[1] AND close > Smoothed VWMA
Short: Smoothed VWMA < Smoothed VWMA[1] AND close < Smoothed VWMA
Long: close crosses above Smoothed VWMA + Volume-weighted standard deviation * width multiplier AND Smoothed VWMA > Smoothed VWMA[1]
Short: close crosses below Smoothed VWMA - Volume-weighted standard deviation * width multiplier AND Smoothed VWMA < Smoothed VWMA[1]