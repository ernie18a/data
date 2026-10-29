Calculation: Bollinger Bands = EMA of close ± multiplier × standard deviation of close, calculated on the selected timeframe; use the latest available value (a higher-timeframe value may still be forming in real time)
Long: close < lower Bollinger Band OR (selected mode is BB Mean Reversion AND source crosses below lower Bollinger Band AND datetime is within the open and close dates) OR (selected mode is Monthly DCA AND this is the first bar of a month AND datetime is within the open and close dates) OR (selected mode is Combined BB and Monthly DCA AND (source crosses below lower Bollinger Band OR this is the first bar of a month) AND datetime is within the open and close dates)
Short: close > upper Bollinger Band
Exit: long, datetime >= close date
Exit: short, datetime >= close date