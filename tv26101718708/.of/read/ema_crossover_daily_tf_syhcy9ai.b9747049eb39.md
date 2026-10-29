Calculation: Short-smoothed EMA = EMA(EMA(close, shorter lookback), shorter lookback)
Calculation: Long-smoothed EMA = EMA(EMA(close, longer lookback), longer lookback)
Calculation: Average volume = simple moving average of volume
Calculation: Candle body fraction = absolute(close − open) / (high − low)
Calculation: Long stop = max(min(current low, prior-bar low), long-smoothed EMA); when volume > average volume AND close > open AND close exceeds the configured profit threshold relative to entry price, raise the stop and entry price by their configured factors
Calculation: Short stop = min(max(current low, prior-bar low), long-smoothed EMA); when volume > average volume AND close < open AND close falls below the configured profit threshold relative to entry price, lower the stop and entry price by their configured factors
Long: position is flat AND close > short-smoothed EMA AND close > long-smoothed EMA AND close > open AND candle body fraction > configured threshold AND volume > average volume AND RSI > its midpoint AND short-smoothed EMA > long-smoothed EMA AND volume > prior-bar volume
Short: position is flat AND close < short-smoothed EMA AND close < long-smoothed EMA AND close < open AND candle body fraction > configured threshold AND volume > average volume AND RSI < its midpoint AND short-smoothed EMA > long-smoothed EMA AND volume > prior-bar volume
Exit: long, close < long stop
Exit: short, close > short stop