Calculation: Combined Z-score = arithmetic mean of Z-score(close, lookback, T1, current T1 bar) for each enabled selected volatility-index series, using T1 values on chart bars with lookahead off; unavailable if no scores are available
Long: Combined Z-score is available AND Combined Z-score < -threshold
Exit: Long, Combined Z-score is available AND Combined Z-score > -threshold
Calculation: combined volatility Z-score = average of enabled Z-scores of VIX, three-month VIX, nine-day VIX, and VVIX closing values on T1 over the lookback parameter
Long: combined volatility Z-score < -threshold parameter
Exit: long, combined volatility Z-score > -threshold parameter