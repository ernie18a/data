Calculation: ATR range = highest ATR and lowest ATR over the lookback
Calculation: Step = sensitivity × (highest ATR + lowest ATR) ÷ 2
Calculation: Long threshold = max(raw long threshold, previous long threshold) in an uptrend; raw long threshold is low + 2 × Step when using highs/lows, or close − 2 × Step when using closes
Calculation: Short threshold = min(raw short threshold, previous short threshold) in a downtrend; raw short threshold is high − 2 × Step when using highs/lows, or close + 2 × Step when using closes
Calculation: Trend = up when close > previous short threshold; down when close < previous long threshold; otherwise retain the previous trend
Long: Previous trend is down AND current trend is up
Short: Previous trend is up AND current trend is down
Long: On the higher timeframe, the selected bar's trend is up AND the preceding bar's trend is down; the selected bar may still be forming
Short: On the higher timeframe, the selected bar's trend is down AND the preceding bar's trend is up; the selected bar may still be forming