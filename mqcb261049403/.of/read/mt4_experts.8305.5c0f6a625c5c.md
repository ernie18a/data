Calculation: Short- and long-lookback SMMA = smoothed moving average of median price on the configured MA timeframe, using its bar still forming; the short lookback is shorter than the long lookback.
Calculation: Aggregate MA difference = sum of the short-lookback SMMAs across the four traded markets minus the sum of their corresponding long-lookback SMMAs.
Calculation: Profit distance = capped fraction of the range of the last completed higher-timeframe bar.
Long: Flat in the market AND Aggregate MA difference > 0 AND that market’s short-lookback SMMA > its long-lookback SMMA
Short: Flat in the market AND Aggregate MA difference < 0 AND that market’s short-lookback SMMA < its long-lookback SMMA
Exit: Long, bar high > entry price + profit distance
Exit: Short, bar low < entry price − profit distance