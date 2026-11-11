Calculation: +DI = Wilder moving average of 100 × Wilder moving average of positive directional movement divided by Wilder moving average of true range; carry forward the last defined ratio before the outer smoothing. Positive directional movement is the increase in high when it is positive and greater than the decrease in low, otherwise zero. The directional movement and true range averages use the same lookback.
Calculation: -DI = 100 × Wilder moving average of negative directional movement divided by Wilder moving average of true range, carrying forward the last defined ratio. Negative directional movement is the decrease in low when it is positive and greater than the increase in high, otherwise zero. Use the same lookback as for +DI.
Calculation: ADX = 100 × exponential moving average of abs(+DI − -DI) / (+DI + -DI), using 1 as the denominator when the sum is zero.
Calculation: Smoothed -DI = simple moving average of -DI.
Calculation: Smoothed ADX = simple moving average of ADX.
Calculation: Bullish pattern = the most recent crossover between +DI and smoothed -DI was an upward crossover; false before the first upward crossover.
Calculation: Bullish-pattern age = 1 on an upward crossover of +DI above smoothed -DI, 0 on a downward crossover, and otherwise the previous age plus 1 while the previous age is positive.
Long: +DI crosses above smoothed -DI.
Short: +DI crosses below smoothed -DI.
Long: +DI > -DI.
Short: +DI < -DI.
Long: ADX crosses below smoothed ADX AND smoothed -DI > +DI.
Short: ADX crosses below smoothed ADX AND +DI > smoothed -DI.
Long: ADX crosses above +DI OR ADX crosses above smoothed -DI OR ADX crosses above smoothed ADX.
Long: Bullish pattern is true AND bullish-pattern age <= maximum age AND (price-below-average filter is disabled OR close < shorter-lookback close SMA) AND (price-above-average filter is disabled OR close > longer-lookback close SMA) AND (volume filter is disabled OR volume > volume SMA) AND ((enabled +DI threshold signal AND +DI crosses above its threshold) OR (enabled ADX threshold signal AND ADX crosses above its threshold) OR (enabled smoothed ADX signal AND smoothed ADX crosses above smoothed -DI) OR (enabled smoothed ADX signal AND smoothed ADX crosses above +DI) OR (enabled smoothed ADX threshold signal AND smoothed ADX crosses above its threshold) OR (enabled sustained-momentum signal AND bars since ADX crossed above smoothed -DI < bars since ADX crossed above smoothed ADX AND bars since ADX crossed above smoothed ADX < bullish-pattern age AND ADX crosses above +DI)).
Long: Bullish pattern is true on a higher timeframe using its last completed bar OR bullish pattern is true on a lower timeframe using its last completed bar within the chart bar.
Short: Bullish pattern is false on a higher timeframe using its last completed bar OR bullish pattern is false on a lower timeframe using its last completed bar within the chart bar.
Exit: long, enabled directional exit AND +DI crosses below smoothed -DI.
Exit: long, enabled trend-reversal exit AND ADX crosses below smoothed ADX AND ADX > minimum threshold.
Exit: long, enabled stop loss AND percentage change from average entry price to close < negative stop-loss threshold.
Exit: long, enabled take profit AND percentage change from average entry price to close >= take-profit threshold.