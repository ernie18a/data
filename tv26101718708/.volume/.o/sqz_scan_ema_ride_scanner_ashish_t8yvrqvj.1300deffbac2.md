Calculation: Bollinger Bands = moving average of close ± a multiplier × close standard deviation over the Bollinger lookback
Calculation: Keltner Channels = moving average of close ± a multiplier × average true range over the Keltner lookback
Calculation: Squeeze = Bollinger Bands lie strictly inside Keltner Channels
Calculation: Normalized momentum = 100 × linear regression of close − average of (average of lookback highest high and lowest low, lookback average close), divided by close
Long: Squeeze AND squeeze-bar count ≥ minimum AND close > EMA
Long: Squeeze AND normalized momentum > 0 AND prior-bar normalized momentum ≤ 0 AND close > EMA
Long: squeeze ended on this or the prior bar AND prior squeeze-bar count ≥ minimum AND normalized momentum > 0 AND normalized momentum > prior-bar normalized momentum AND close > EMA AND volume > 20-bar average volume × surge multiplier