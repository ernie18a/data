Calculation: Upper volatility component = 100 × (highest close over the lookback − low) ÷ highest close over the lookback
Calculation: Lower volatility component = 100 × (lowest close over the lookback − high) ÷ lowest close over the lookback
Calculation: WVF = upper volatility component + lower volatility component
Calculation: Upper WVF threshold = moving average of the upper volatility component × upper factor
Calculation: Lower WVF threshold = moving average of the lower volatility component × lower factor
Calculation: Entry price threshold = moving average of the selected price source × entry factor
Long: (WVF crosses above the upper WVF threshold AND lower-timeframe MACD line on the current, potentially forming bar < 0 OR WVF > upper WVF threshold AND WVF > 0 AND (WVF > its upper Bollinger Band OR WVF ≥ its lookback high × high percentile)) AND close < buy stop level AND close < entry price threshold
Short: (WVF crosses below the lower WVF threshold AND lower-timeframe MACD line on the current, potentially forming bar > 0 OR WVF < lower WVF threshold AND WVF < 0 AND (WVF < its lower Bollinger Band OR WVF ≤ its lookback low × low percentile)) AND close ≥ sell level
Exit: long, short condition
Exit: short, (WVF crosses above the upper WVF threshold AND lower-timeframe MACD line on the current, potentially forming bar < 0 OR WVF > upper WVF threshold AND WVF > 0 AND (WVF > its upper Bollinger Band OR WVF ≥ its lookback high × high percentile))
Exit: long, low ≤ current close × stop-loss factor
Exit: short, high ≥ current close × (2 − stop-loss factor)
Exit: long or short, bars since entry ≥ expiration holding period