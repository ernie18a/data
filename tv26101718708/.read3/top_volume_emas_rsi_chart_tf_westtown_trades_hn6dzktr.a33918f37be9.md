Calculation: WaveTrend main line = EMA((hlc3 - EMA(hlc3, channel lookback)) / (normalization factor * EMA(abs(hlc3 - EMA(hlc3, channel lookback)), channel lookback)), average lookback)
Calculation: WaveTrend signal line = SMA(WaveTrend main line, signal lookback)
Long: close > EMA(close, shortest lookback)
Short: close <= EMA(close, shortest lookback)
Long: close > EMA(close, second-shortest lookback)
Short: close <= EMA(close, second-shortest lookback)
Long: close > EMA(close, second-longest lookback)
Short: close <= EMA(close, second-longest lookback)
Long: close > EMA(close, longest lookback)
Short: close <= EMA(close, longest lookback)
Long: RSI(close, RSI lookback) <= oversold threshold AND RSI(close, RSI lookback) < overbought threshold
Short: RSI(close, RSI lookback) >= overbought threshold
Long: WaveTrend main line crosses above WaveTrend signal line
Short: WaveTrend signal line crosses above WaveTrend main line
Long: WaveTrend main line crosses above WaveTrend signal line on the previous bar
Short: WaveTrend signal line crosses above WaveTrend main line on the previous bar
Long: close > highest(high[1], confluence breakout lookback) AND volume > SMA(volume, confluence volume-average lookback) * volume multiplier AND close > EMA(close, confluence EMA lookback)
Short: close < lowest(low[1], confluence breakout lookback) AND volume > SMA(volume, confluence volume-average lookback) * volume multiplier AND close < EMA(close, confluence EMA lookback)
Long: high > highest(high[1], longer CHoCH lookback) AND low[1] < lowest(low[1], shorter CHoCH lookback)
Short: low < lowest(low[1], longer CHoCH lookback) AND high[1] > highest(high[1], shorter CHoCH lookback)
Long: high > highest(high[1], BOS lookback)
Short: low < lowest(low[1], BOS lookback) AND NOT (high > highest(high[1], BOS lookback))