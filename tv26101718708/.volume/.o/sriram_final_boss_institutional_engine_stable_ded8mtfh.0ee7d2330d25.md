Calculation: EMA spread = absolute difference between the shorter-period EMA and the longer-period EMA
Calculation: Volume average = simple moving average of volume over a longer lookback
Calculation: Spread average = simple moving average of EMA spread over a longer lookback
Long: close > VWAP AND shorter-period EMA > longer-period EMA AND EMA spread > fixed threshold AND EMA spread > Spread average * threshold AND volume > Volume average * threshold AND close > open AND close > previous bar high AND close > previous bar close
Short: close < VWAP AND shorter-period EMA < longer-period EMA AND EMA spread > fixed threshold AND EMA spread > Spread average * threshold AND volume > Volume average * threshold AND close < open AND close < previous bar low AND close < previous bar close
Exit: Long, close < shorter-period EMA OR close < VWAP
Exit: Short, close > shorter-period EMA OR close > VWAP