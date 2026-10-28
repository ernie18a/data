Calculation: Bias imbalance (%) = 100 × (unswept sell-side weight − unswept buy-side weight) / total weight; include only levels formed within the bias lookback, weighting each by max(strength, 1), where strength is the selected volume-at-pivot, age, or touch count.
Long: Bias imbalance (%) < −bias threshold
Short: Bias imbalance (%) > bias threshold
Long: On a confirmed current-timeframe bar, low > high two bars earlier and gap size ≥ minimum ATR multiple
Short: On a confirmed current-timeframe bar, high < low two bars earlier and gap size ≥ minimum ATR multiple
Long: When enabled, on a new higher-timeframe bar, the last completed higher-timeframe low > the high three bars earlier and gap size ≥ minimum ATR multiple
Short: When enabled, on a new higher-timeframe bar, the last completed higher-timeframe high < the low three bars earlier and gap size ≥ minimum ATR multiple