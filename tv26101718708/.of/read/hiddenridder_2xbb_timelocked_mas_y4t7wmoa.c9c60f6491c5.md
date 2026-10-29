Calculation: Fast Bollinger upper/lower bands = higher-timeframe EMA of close with a shorter lookback, plus/minus 2 standard deviations of close over the same lookback; use the still-forming higher-timeframe bar
Calculation: Slow basis = higher-timeframe EMA of close with a longer lookback than the fast Bollinger bands; use the still-forming higher-timeframe bar
Calculation: Slow Bollinger upper/lower bands = slow basis plus/minus 2 standard deviations of close over the slow basis lookback; use the still-forming higher-timeframe bar
Long: close > slow Bollinger upper band AND close > slow basis
Short: close < slow Bollinger lower band AND close < slow basis
Exit: long, high >= slow basis OR close < fast Bollinger upper band
Exit: short, low <= slow basis OR close > fast Bollinger lower band