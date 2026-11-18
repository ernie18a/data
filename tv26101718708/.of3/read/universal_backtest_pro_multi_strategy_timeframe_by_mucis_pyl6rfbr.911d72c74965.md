Calculation: Requested close = close(T1, latest completed T1 bar historically and still-forming T1 bar in realtime), sampled on chart bars
Long: Selected strategy is EMA Crossover AND EMA(Requested close, shorter lookback) crosses above EMA(Requested close, longer lookback) AND Requested close > EMA(Requested close, separate regime lookback)
Short: Selected strategy is EMA Crossover AND EMA(Requested close, shorter lookback) crosses below EMA(Requested close, longer lookback) AND Requested close < EMA(Requested close, separate regime lookback)
Long: Selected strategy is RSI Strategy AND RSI(Requested close, lookback) crosses below the lower threshold
Short: Selected strategy is RSI Strategy AND RSI(Requested close, lookback) crosses above the upper threshold
Long: Selected strategy is MACD Strategy AND the MACD line of MACD(Requested close, shorter fast lookback, longer slow lookback, signal lookback) crosses above its signal line
Short: Selected strategy is MACD Strategy AND the MACD line of MACD(Requested close, shorter fast lookback, longer slow lookback, signal lookback) crosses below its signal line
Long: Selected strategy is Bollinger Bands Breakout AND Requested close crosses above the lower Bollinger Band(Requested close, lookback, standard-deviation multiplier)
Short: Selected strategy is Bollinger Bands Breakout AND Requested close crosses below the upper Bollinger Band(Requested close, lookback, standard-deviation multiplier)
Long: Selected strategy is SuperTrend AND Supertrend direction(high, low, close, ATR lookback, multiplier) changes from bearish to bullish on chart bars
Short: Selected strategy is SuperTrend AND Supertrend direction(high, low, close, ATR lookback, multiplier) changes from bullish to bearish on chart bars
Long: Selected strategy is Custom AND SMA(Requested close, shorter lookback) crosses above SMA(Requested close, longer lookback)
Short: Selected strategy is Custom AND SMA(Requested close, shorter lookback) crosses below SMA(Requested close, longer lookback)
Exit: Long, chart low <= entry price × (1 − stop-loss percentage) OR chart high >= entry price × (1 + take-profit percentage) OR trailing stop is enabled AND highest chart high since entry >= entry price × (1 + take-profit percentage / 2) AND chart low <= highest chart high since entry − entry price × stop-loss percentage / 2
Exit: Short, chart high >= entry price × (1 + stop-loss percentage) OR chart low <= entry price × (1 − take-profit percentage) OR trailing stop is enabled AND lowest chart low since entry <= entry price × (1 − take-profit percentage / 2) AND chart high >= lowest chart low since entry + entry price × stop-loss percentage / 2