Calculation: AI confidence = capped weighted score of trend alignment (fast, medium, and slow EMAs), ADX, RSI, MACD, relative volume, MFI, CCI, and momentum alignment; each factor's score follows its directional alignment with the fast-versus-medium EMA trend.
Calculation: Multi-timeframe trend agreement = counts of configured timeframes whose fast EMA is above or below their medium EMA; use the bars still forming, with the same fast and medium EMA lengths as on the chart.
Calculation: Adaptive trail = initialize at close; while close is above the prior trail, set it to the greater of the prior trail and close minus ATR times a multiplier; otherwise set it to the lesser of the prior trail and close plus ATR times a multiplier. ATR uses a configurable lookback.
Calculation: Bollinger bands = 20-bar simple moving average of close plus/minus 2.2 times the 20-bar standard deviation of close.
Long: Fast EMA > medium EMA
Long: 8-bar EMA > 13-bar EMA AND 13-bar EMA > 21-bar EMA AND 21-bar EMA > 34-bar EMA AND 34-bar EMA > 55-bar EMA AND 55-bar EMA > 89-bar EMA
Long: Absolute candle body > 2 times its 20-bar average AND volume > 1.3 times its 20-bar average AND close > open
Long: A confirmed 5-left/5-right RSI pivot low is higher than the preceding RSI pivot low AND its corresponding price low is lower than the preceding price low AND pivot RSI < 45
Long: Fast EMA crosses above medium EMA AND fast EMA <= medium EMA on the prior bar AND strong trend is nonnegative (fast EMA > medium EMA > slow EMA, fast EMA < medium EMA < slow EMA, or neither) AND RSI > 45 AND close > adaptive trail AND AI confidence >= 70 AND the greater of bullish and bearish multi-timeframe trend counts >= 3
Long: Fast EMA crosses above medium EMA AND fast EMA <= medium EMA on the prior bar AND AI confidence >= minimum confidence AND the premium long condition is false
Long: Close <= lower Bollinger band AND close crosses above the lower Bollinger band AND AI confidence >= minimum confidence
Short: Fast EMA < medium EMA
Short: 8-bar EMA < 13-bar EMA AND 13-bar EMA < 21-bar EMA AND 21-bar EMA < 34-bar EMA AND 34-bar EMA < 55-bar EMA AND 55-bar EMA < 89-bar EMA
Short: Absolute candle body > 2 times its 20-bar average AND volume > 1.3 times its 20-bar average AND close < open
Short: A confirmed 5-left/5-right RSI pivot high is lower than the preceding RSI pivot high AND its corresponding price high is higher than the preceding price high AND pivot RSI > 55
Short: Fast EMA crosses below medium EMA AND fast EMA >= medium EMA on the prior bar AND strong trend is nonpositive (fast EMA > medium EMA > slow EMA, fast EMA < medium EMA < slow EMA, or neither) AND RSI < 55 AND close < adaptive trail AND AI confidence >= 70 AND the greater of bullish and bearish multi-timeframe trend counts >= 3
Short: Fast EMA crosses below medium EMA AND fast EMA >= medium EMA on the prior bar AND AI confidence >= minimum confidence AND the premium short condition is false
Short: Close >= upper Bollinger band AND close crosses below the upper Bollinger band AND AI confidence >= minimum confidence
Exit: Long, low <= entry price minus ATR at entry times the stop multiplier
Exit: Short, high >= entry price plus ATR at entry times the stop multiplier