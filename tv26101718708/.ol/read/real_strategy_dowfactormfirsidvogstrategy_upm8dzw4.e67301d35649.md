Calculation: Selected index close = same-chart-timeframe close of the configured market index, negated for the USD/X market mode.
Calculation: Dow-adjusted coefficient = 1 − (1 − R²) × (n − 1)/(n − 3), where R² is the square of the multiple correlation of close against volume and selected index close; calculate pairwise Pearson correlations over the same n-bar lookback and use R² = (r_close,volume² + r_close,index² − 2 × r_close,volume × r_close,index × r_volume,index)/(1 − r_volume,index²).
Calculation: Bullish measure = selected close-based RSI or money-flow measure. The money-flow measure uses rolling sums of close × volume on up bars and down bars, then applies RSI to those two sums.
Calculation: Composite score = [bullish measure × (1 + 1 + Dow-adjusted coefficient)] / [bullish measure × (1 + 1 + Dow-adjusted coefficient) + (100 − bullish measure) × (1 + 1 − Dow-adjusted coefficient)] × 100.
Long: Composite score > 50
Short: Composite score < 50