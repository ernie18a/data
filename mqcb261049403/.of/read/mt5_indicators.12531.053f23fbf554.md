Calculation: Range Expansion Index (REI) = 100 times the sum of conditional changes over a lookback divided by the sum of absolute changes over the same lookback; return 0 if the denominator is 0. For each bar i, the absolute change is |high[i] - high[i-2]| + |low[i] - low[i-2]|. The conditional change is 0 if (high[i-2] < close[i-7] AND high[i-2] < close[i-8] AND high[i] < high[i-5] AND high[i] < high[i-6]) OR (low[i-2] > close[i-7] AND low[i-2] > close[i-8] AND low[i] > low[i-5] AND low[i] > low[i-6]); otherwise it is high[i] - high[i-2] + low[i] - low[i-2].
Calculation: Sampled higher-timeframe REI = REI of the higher-timeframe bar still forming, sampled at the first chart bar of that higher-timeframe bar; retain that sample until the next higher-timeframe bar. Compare it with the REI of the preceding completed higher-timeframe bar.
Long: chart-timeframe REI < 0 AND chart-timeframe REI > its previous bar's value
Long: previous chart-timeframe REI <= negative threshold AND current chart-timeframe REI > negative threshold
Long: sampled higher-timeframe REI > preceding completed higher-timeframe REI
Short: chart-timeframe REI > 0 AND chart-timeframe REI < its previous bar's value
Short: previous chart-timeframe REI >= positive threshold AND current chart-timeframe REI < positive threshold
Short: sampled higher-timeframe REI < preceding completed higher-timeframe REI