Calculation: Spearman rank correlation = 1 − 6 × sum of squared differences between each close’s average rank and its chronological rank, divided by (lookback³ − lookback); ranks are calculated over consecutive bars, oldest to newest, with average ranks for tied closes.
Long: Spearman rank correlation on the last completed indicator-timeframe bar > 0 AND on the preceding completed bar ≤ 0
Short: Spearman rank correlation on the last completed indicator-timeframe bar < 0 AND on the preceding completed bar ≥ 0
Exit: long, Spearman rank correlation on the last completed indicator-timeframe bar < 0 AND on the preceding completed bar ≥ 0
Exit: short, Spearman rank correlation on the last completed indicator-timeframe bar > 0 AND on the preceding completed bar ≤ 0