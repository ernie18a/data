Calculation: Lookback delta percentage = 100 × (0.6 × volume of up bars − 0.6 × volume of down bars) / total volume over the lookback bars; flat bars contribute zero delta.
Calculation: Intrabar delta percentage = 100 × (buy volume − sell volume) / total volume within the current chart bar; classify lower-timeframe bars as buy on close > open, sell on close < open, and split flat-bar volume equally.
Calculation: Period cumulative delta = buy volume − sell volume from the start of the selected daily or session period through the current chart bar; classify chart bars by close versus open and split flat-bar volume equally. Previous cumulative delta excludes the current chart bar.
Long: Lookback delta percentage > up threshold
Long: Intrabar delta percentage > up threshold AND Lookback delta percentage < down threshold
Long: Intrabar buy volume − sell volume ≥ 0
Long: Period cumulative delta > 0 AND (previous cumulative delta ≤ 0 OR (absolute period cumulative delta ≥ 0.97 × absolute previous cumulative delta AND period cumulative delta > previous cumulative delta))
Short: Lookback delta percentage < down threshold
Short: Intrabar delta percentage < down threshold AND Lookback delta percentage > up threshold
Short: Intrabar buy volume − sell volume < 0
Short: Period cumulative delta < 0 AND (previous cumulative delta ≥ 0 OR (absolute period cumulative delta ≥ 0.97 × absolute previous cumulative delta AND period cumulative delta < previous cumulative delta))