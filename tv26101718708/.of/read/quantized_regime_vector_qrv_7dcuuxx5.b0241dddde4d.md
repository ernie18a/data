Calculation: Volume Z-score = (current volume − mean volume over a lookback) / standard deviation of volume over the same lookback
Calculation: Volatility gate = true range ≥ ATR × a multiplier
Calculation: Adaptive moving average = Kaufman adaptive moving average using an efficiency ratio from price movement over a lookback and recursive smoothing between fast and slow smoothing rates
Calculation: Bullish structural trend = close > shorter-lookback SMA AND shorter-lookback SMA > longer-lookback SMA
Calculation: Bearish structural trend = close < shorter-lookback SMA AND shorter-lookback SMA < longer-lookback SMA
Calculation: Bullish wick-adjusted pressure = (close > open ? close − open : 0) + min(open, close) − low
Calculation: Bearish wick-adjusted pressure = (close < open ? open − close : 0) + high − max(open, close)
Calculation: Bullish pivot divergence = a confirmed pivot low is lower than the preceding confirmed pivot low AND RSI at the new pivot is higher than RSI at the preceding pivot
Calculation: Bearish pivot divergence = a confirmed pivot high is higher than the preceding confirmed pivot high AND RSI at the new pivot is lower than RSI at the preceding pivot
Calculation: Upside exhaustion = RSI > its upper threshold AND current MACD histogram < prior MACD histogram AND prior MACD histogram > 0
Calculation: Downside exhaustion = RSI < its lower threshold AND current MACD histogram > prior MACD histogram AND prior MACD histogram < 0
Calculation: Higher-timeframe bullish alignment = close of the last completed higher-timeframe bar > its shorter-lookback SMA
Calculation: Higher-timeframe bearish alignment = close of the last completed higher-timeframe bar < its shorter-lookback SMA
Calculation: Long score = weighted sum of bullish structural trend, higher-timeframe bullish alignment, volume Z-score threshold, major volume Z-score threshold, volatility gate, close above adaptive moving average, bullish wick-adjusted pressure, and close > open
Calculation: Short score = weighted sum of bearish structural trend, higher-timeframe bearish alignment, volume Z-score threshold, major volume Z-score threshold, volatility gate, close below adaptive moving average, bearish wick-adjusted pressure, and close < open
Long: bullish pivot divergence OR (long score > short score AND long score ≥ activation threshold AND higher-timeframe bullish alignment AND volatility gate AND volume Z-score ≥ signal threshold AND close > adaptive moving average AND bullish structural trend AND no signal within the cooldown lookback)
Short: bearish pivot divergence OR (short score > long score AND short score ≥ activation threshold AND higher-timeframe bearish alignment AND volatility gate AND volume Z-score ≥ signal threshold AND close < adaptive moving average AND bearish structural trend AND no signal within the cooldown lookback)
Exit: long, bearish pivot divergence OR upside exhaustion
Exit: short, bullish pivot divergence OR downside exhaustion