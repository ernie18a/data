Calculation: RSIOMA = RSI of the smoothed applied price: smooth price with a short lookback, calculate its momentum, recursively smooth positive and negative momentum with the RSI lookback, then compute 100 − 100/(1 + positive/negative). Use the last completed indicator-timeframe bars for EA signals; that timeframe can be higher or lower than the chart timeframe. For indicator markings, use the current forming bar and its preceding bar.
Long: RSIOMA < oversold level AND RSIOMA > its preceding value
Short: RSIOMA > overbought level AND RSIOMA < its preceding value
Long: On the indicator timeframe, preceding completed RSIOMA <= upper trend level AND latest completed RSIOMA > upper trend level
Short: On the indicator timeframe, preceding completed RSIOMA >= lower trend level AND latest completed RSIOMA < lower trend level
Exit: short, latest completed RSIOMA > upper trend level
Exit: long, latest completed RSIOMA < lower trend level
Long: On the indicator timeframe, middle completed RSIOMA < latest completed RSIOMA AND oldest of the three completed RSIOMA values > middle completed RSIOMA
Short: On the indicator timeframe, middle completed RSIOMA > latest completed RSIOMA AND oldest of the three completed RSIOMA values < middle completed RSIOMA
Exit: short, latest completed RSIOMA > middle completed RSIOMA
Exit: long, latest completed RSIOMA < middle completed RSIOMA
Long: On the indicator timeframe, preceding completed RSIOMA <= upper trend level AND latest completed RSIOMA > upper trend level
Short: On the indicator timeframe, preceding completed RSIOMA >= lower trend level AND latest completed RSIOMA < lower trend level
Exit: short, latest completed RSIOMA > upper trend level
Exit: long, latest completed RSIOMA < lower trend level