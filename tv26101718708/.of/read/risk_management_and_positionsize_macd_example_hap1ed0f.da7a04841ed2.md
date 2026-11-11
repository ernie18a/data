Calculation: Timeframe conversion = 1440 for a timeframe string ending in D, 10080 for W, 43200 for M, the numeric prefix for H, and otherwise the numeric string after removing m.
Calculation: Smoothed higher-timeframe MACD and signal = calculate MACD as the shorter-lookback moving average of close minus the longer-lookback moving average of close, and its signal as a moving average of MACD, using the same selectable moving-average type for all three. Use the last completed higher-timeframe bar, carry its values forward onto chart bars, and apply a chart-timeframe SMA to each series with length equal to the rounded ratio of the higher-timeframe conversion to the chart-timeframe conversion. The selectable types are EMA, DEMA, TEMA, SMA, WMA, and HMA.
Calculation: Smoothed higher-timeframe trend average = calculate a selectable EMA, DEMA, TEMA, SMA, WMA, HMA, or McGinley Dynamic moving average of close on a higher timeframe. Use the last completed higher-timeframe bar, carry its value forward onto chart bars, and apply a chart-timeframe SMA with length equal to the rounded ratio of the trend timeframe conversion to the chart-timeframe conversion.
Long: Smoothed higher-timeframe MACD crosses above its smoothed signal AND smoothed higher-timeframe MACD < 0.
Short: Smoothed higher-timeframe MACD crosses below its smoothed signal AND smoothed higher-timeframe MACD > 0.
Long: Smoothed higher-timeframe trend average > its previous chart-bar value.
Short: Smoothed higher-timeframe trend average < its previous chart-bar value.
Long: Smoothed higher-timeframe MACD - its smoothed signal >= 0.
Short: Smoothed higher-timeframe MACD - its smoothed signal < 0.
Exit: long, smoothed higher-timeframe MACD crosses below its smoothed signal.
Exit: short, smoothed higher-timeframe MACD crosses above its smoothed signal.