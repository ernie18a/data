Calculation: WaveTrend = EMA((typical price - EMA(typical price, channel length)) / (scaling factor × EMA(abs(typical price - EMA(typical price, channel length)), channel length)), longer average length), where typical price = (high + low + close) / 3
Calculation: WaveTrend signal = SMA(WaveTrend, signal length shorter than the channel length)
Long: close > EMA(close) for any of four distinct lengths ordered from shortest to longest
Short: close <= EMA(close) for any of four distinct lengths ordered from shortest to longest
Long: RSI(close) <= oversold threshold
Short: RSI(close) >= overbought threshold
Long: WaveTrend crosses above WaveTrend signal on the current or previous bar
Short: WaveTrend signal crosses above WaveTrend on the current or previous bar
Long: close > highest high of the preceding lookback bars AND volume > SMA(volume) × volume multiplier AND close > EMA(close)
Short: close < lowest low of the preceding lookback bars AND volume > SMA(volume) × volume multiplier AND close < EMA(close)
Long: high > highest high of the preceding longer lookback bars AND previous low < lowest low of the preceding shorter lookback bars
Short: low < lowest low of the preceding longer lookback bars AND previous high > highest high of the preceding shorter lookback bars
Long: high > highest high of the preceding lookback bars
Short: low < lowest low of the preceding lookback bars AND high <= highest high of the preceding lookback bars