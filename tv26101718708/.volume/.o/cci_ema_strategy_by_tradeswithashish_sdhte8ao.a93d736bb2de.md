Calculation: Candle close location = (close - low) / (high - low)
Calculation: Long stop = the greater of the shorter-lookback EMA and the long-entry EMA, ratcheted upward while long
Calculation: Short stop = the lesser of the shorter-lookback EMA and the long-entry EMA, ratcheted downward while short
Calculation: Long target = signal-bar OHLC4 × (1 + configurable return percentage)
Calculation: Short target = signal-bar OHLC4 × (1 − configurable return percentage)
Long: Flat AND close > EMA(EMA(close, longer lookback), same lookback) AND close > open AND volume > SMA(volume, configurable lookback) AND CCI(HLC3, longer lookback) > 0 AND CCI(HLC3, shorter lookback) > configurable positive threshold AND close > session VWAP AND Candle close location > configurable upper threshold AND volume > previous bar volume
Short: Flat AND close < EMA(EMA(close, longer lookback), same lookback) AND close < open AND volume > SMA(volume, configurable lookback) AND CCI(HLC3, longer lookback) < 0 AND CCI(HLC3, shorter lookback) < configurable negative threshold AND close < session VWAP AND Candle close location < configurable lower threshold AND volume > previous bar volume
Exit: long, CCI(HLC3, longer lookback) < 0 OR close < EMA(EMA(close, longer lookback), same lookback) OR close < shorter-lookback EMA OR low <= Long stop OR high >= Long target
Exit: short, CCI(HLC3, longer lookback) > 0 OR close > EMA(EMA(close, longer lookback), same lookback) OR close > shorter-lookback EMA OR high >= Short stop OR low <= Short target