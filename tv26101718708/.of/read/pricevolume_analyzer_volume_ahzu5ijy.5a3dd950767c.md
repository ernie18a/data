Calculation: spread = high - low
Calculation: NH = spread < SMA(spread, spread lookback, including current bar) / k AND volume > SMA(volume, volume lookback, including current bar) * k, where k > 1 is one multiplier used for both comparisons and all values come from the chart-timeframe bar just closed
Long: NH AND close > open
Short: NH AND close <= open