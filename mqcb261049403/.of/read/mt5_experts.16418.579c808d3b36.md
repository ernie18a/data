Calculation: Directional change score = on the configured indicator timeframe (which may be higher or lower than the chart timeframe), for each completed bar, 100 divided by the lookback length times the sum of +1 for each close-to-previous-close increase and −1 for each non-increase; use the last completed bar and the preceding completed bar.
Long: Directional change score on the last completed bar > 0 AND score on the preceding completed bar <= 0
Short: Directional change score on the last completed bar <= 0 AND score on the preceding completed bar > 0
Exit: long, Directional change score on the last completed bar <= 0 AND score on the preceding completed bar > 0
Exit: short, Directional change score on the last completed bar > 0 AND score on the preceding completed bar <= 0