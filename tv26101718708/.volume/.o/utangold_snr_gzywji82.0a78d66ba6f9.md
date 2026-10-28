Calculation: Resistance = most recent non-missing pivot high from the prior bar on the chart timeframe, using left and right pivot lookbacks
Calculation: Support = most recent non-missing pivot low from the prior bar on the chart timeframe, using left and right pivot lookbacks
Calculation: Volume oscillator = 100 × (short-lookback EMA of volume − long-lookback EMA of volume) ÷ long-lookback EMA of volume, where the short lookback is shorter than the long lookback
Long: Close crosses above Resistance AND (Volume oscillator exceeds the volume threshold OR Open − Low > Close − Open)
Short: Close crosses below Support AND (Volume oscillator exceeds the volume threshold OR Open − Close < High − Open)