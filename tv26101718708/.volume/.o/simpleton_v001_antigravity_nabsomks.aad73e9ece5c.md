Calculation: Z-score = (close − lookback SMA of close) / lookback standard deviation of close; if standard deviation is zero, use 0.
Calculation: Bollinger upper/lower bands = lookback SMA of close ± deviation multiplier × lookback standard deviation of close.
Calculation: Bollinger width = (upper band − lower band) / band basis.
Calculation: VWAP deviation bands = session VWAP of typical price ± deviation multiplier × 20-bar standard deviation of (close − session VWAP).
Long: RSI(close, short lookback) < entry threshold AND (trend filter disabled OR close > long-lookback SMA of close).
Short: RSI(close, short lookback) > 100 − entry threshold AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, RSI(close, short lookback) > exit threshold.
Exit: short, RSI(close, short lookback) < 100 − exit threshold.
Long: Z-score < −entry threshold AND (trend filter disabled OR close > long-lookback SMA of close).
Short: Z-score > entry threshold AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, Z-score > −exit threshold.
Exit: short, Z-score < exit threshold.
Long: fast EMA crosses above slow EMA AND RSI < overbought threshold AND (trend filter disabled OR close > long-lookback SMA of close).
Short: fast EMA crosses below slow EMA AND RSI > oversold threshold AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, fast EMA crosses below slow EMA OR RSI > 80.
Exit: short, fast EMA crosses above slow EMA OR RSI < 20.
Long: close < lower Bollinger band AND previous bar's Bollinger width < previous bar's width SMA divided by squeeze multiplier AND (trend filter disabled OR close > long-lookback SMA of close).
Short: close > upper Bollinger band AND previous bar's Bollinger width < previous bar's width SMA divided by squeeze multiplier AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, close > Bollinger basis.
Exit: short, close < Bollinger basis.
Long: MACD line crosses above signal line AND MACD histogram > previous bar's histogram AND RSI < 50 AND (trend filter disabled OR close > long-lookback SMA of close).
Short: MACD line crosses below signal line AND MACD histogram < previous bar's histogram AND RSI > 50 AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, MACD line crosses below signal line OR RSI > 80.
Exit: short, MACD line crosses above signal line OR RSI < 20.
Long: fast EMA > middle EMA AND middle EMA > slow EMA AND previous bar's fast EMA ≤ previous bar's middle EMA AND (trend filter disabled OR close > long-lookback SMA of close).
Short: fast EMA < middle EMA AND middle EMA < slow EMA AND previous bar's fast EMA ≥ previous bar's middle EMA AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, fast EMA < middle EMA.
Exit: short, fast EMA > middle EMA.
Long: close < lower VWAP deviation band AND (trend filter disabled OR close > long-lookback SMA of close).
Short: close > upper VWAP deviation band AND (trend filter disabled OR close < long-lookback SMA of close).
Exit: long, close > session VWAP.
Exit: short, close < session VWAP.
Long: at least the consensus threshold of these seven conditions is true: RSI(close, short lookback) < entry threshold; Z-score < −entry threshold; fast EMA crosses above slow EMA AND RSI < overbought threshold; close < lower Bollinger band AND previous bar's width < previous bar's width SMA divided by squeeze multiplier; MACD line crosses above signal line AND RSI < 50 AND MACD histogram > its previous value; fast EMA > middle EMA > slow EMA AND previous fast EMA ≤ previous middle EMA; close < lower VWAP deviation band. Apply the trend filter to each condition when enabled: close > long-lookback SMA of close.
Short: at least the consensus threshold of these seven conditions is true: RSI(close, short lookback) > 100 − entry threshold; Z-score > entry threshold; fast EMA crosses below slow EMA AND RSI > oversold threshold; close > upper Bollinger band AND previous bar's width < previous bar's width SMA divided by squeeze multiplier; MACD line crosses below signal line AND RSI > 50 AND MACD histogram < its previous value; fast EMA < middle EMA < slow EMA AND previous fast EMA ≥ previous middle EMA; close > upper VWAP deviation band. Apply the trend filter to each condition when enabled: close < long-lookback SMA of close.
Exit: long, all seven long-entry conditions used for consensus are false.
Exit: short, all seven short-entry conditions used for consensus are false.
Exit: long, close reaches take-profit price above entry price or stop-loss price below entry price; if trailing stop is enabled, close reaches the active trailing stop.
Exit: short, close reaches take-profit price below entry price or stop-loss price above entry price; if trailing stop is enabled, close reaches the active trailing stop.
Exit: long, bars held ≥ maximum bars in trade.
Exit: short, bars held ≥ maximum bars in trade.