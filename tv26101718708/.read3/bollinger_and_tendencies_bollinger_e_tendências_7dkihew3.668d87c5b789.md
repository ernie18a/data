Long: crosses above(close, Bollinger Bands(source, lookback, deviation multiplier).lower) AND StochRSI %K(close, RSI lookback, stochastic lookback, K smoothing) <= oversold threshold AND StochRSI %D(close, RSI lookback, stochastic lookback, K smoothing, D smoothing) <= oversold threshold AND EMA(close, entry filter lookback) > EMA(close, entry filter lookback)[1]
Short: crosses above(close, Bollinger Bands(source, lookback, deviation multiplier).upper)
Exit: long, crosses below(close, Bollinger Bands(source, lookback, deviation multiplier).upper)
Long: close > EMA(close, color EMA lookback)
Short: close <= EMA(close, color EMA lookback)
Long: on chart bars, close > Pivot Point(high, low, close, T1, last completed bar)
Short: on chart bars, close <= Pivot Point(high, low, close, T1, last completed bar)
Long: open[1] > close[1] AND close > open AND close <= open[1] AND close[1] <= open AND close - open < open[1] - close[1] AND open[trend lookback] > open
Long: open[1] > close[1] AND close > open AND close >= open[1] AND close[1] >= open AND close - open > open[1] - close[1] AND open[trend lookback] > open
Long: close[1] < open[1] AND open < low[1] AND close > close[1] + (open[1] - close[1]) / 2 AND close < open[1] AND open[trend lookback] > open
Long: low = open AND open < Lowest(low, belt lookback)[1] AND open < close AND close > midpoint(high[1], low[1]) AND open[trend lookback] > open
Long: open[1] > close[1] AND open >= open[1] AND close > open AND open[trend lookback] > open
Long: high - low > hammer ratio * (open - close) AND (close - low) / (hammer offset + high - low) > hammer wick threshold AND (open - low) / (hammer offset + high - low) > hammer wick threshold
Long: high - low > inverted hammer ratio * (open - close) AND (high - close) / (inverted hammer offset + high - low) > inverted hammer wick threshold AND (high - open) / (inverted hammer offset + high - low) > inverted hammer wick threshold
Long: close[2] < open[2] AND max(open[1], close[1]) < close[2] AND open > max(open[1], close[1]) AND close > open
Short: close[1] > open[1] AND open > close AND open <= close[1] AND open[1] <= close AND open - close < close[1] - open[1] AND open[trend lookback] < open
Short: close[1] > open[1] AND open > close AND open >= close[1] AND open[1] >= close AND open - close > close[1] - open[1] AND open[trend lookback] < open
Short: close[1] < open[1] AND open <= open[1] AND close <= open AND open[trend lookback] < open
Short: high - low > hanging man ratio * (open - close) AND (close - low) / (hanging man offset + high - low) >= hanging man wick threshold AND (open - low) / (hanging man offset + high - low) >= hanging man wick threshold AND open[trend lookback] < open AND high[1] < open AND high[2] < open
Short: close[2] > open[2] AND min(open[1], close[1]) > close[2] AND open < min(open[1], close[1]) AND close < open
Short: open[1] < close[1] AND open > close[1] AND high - max(open, close) >= abs(open - close) * shooting star ratio AND min(close, open) - low <= abs(open - close)