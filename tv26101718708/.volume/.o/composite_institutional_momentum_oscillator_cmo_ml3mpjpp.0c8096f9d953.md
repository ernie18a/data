Calculation: CMO = EMA-smoothed normalized difference between dual-WMA momentum and a volume-weighted price average. Dual-WMA momentum uses a fast WMA and a longer WMA, then smooths their doubled-fast-minus-slow difference. The price average weights the selected price source by volume, absolute smoothed synthetic volume delta, and relative volume-per-range efficiency. CMO is calculated on the locked calculation-timeframe bars, including the bar still forming; the higher-timeframe filter uses the selected higher-timeframe bars, including the bar still forming.
Long: CMO > 1 AND selected higher-timeframe price source >= its macro-lookback volume-weighted average price
Long: low < the lowest low of prior macro-lookback calculation-timeframe bars AND selected price source > that lowest low AND CMO < 0
Long: CMO was previously < -1 AND CMO >= -1 AND CMO < 0.05
Short: CMO < -1 AND selected higher-timeframe price source < its macro-lookback volume-weighted average price
Short: high > the highest high of prior macro-lookback calculation-timeframe bars AND selected price source < that highest high AND CMO > 0
Short: CMO <= -0.05