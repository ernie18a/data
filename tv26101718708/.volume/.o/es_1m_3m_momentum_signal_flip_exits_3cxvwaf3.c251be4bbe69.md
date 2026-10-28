Calculation: Smoothed RSI = RSI of close, smoothed with an EMA
Calculation: MACD line = shorter-lookback EMA of close minus longer-lookback EMA of close; use the fast and slow EMA lookbacks, respectively
Calculation: MACD signal line = EMA of the MACD line
Long: fast EMA crosses above slow EMA AND close > trend EMA AND smoothed RSI > 50 AND MACD line > MACD signal line AND volume > volume moving average × configured multiplier AND datetime is within the configured trading session
Short: fast EMA crosses below slow EMA AND close < trend EMA AND smoothed RSI < 50 AND MACD line < MACD signal line AND volume > volume moving average × configured multiplier AND datetime is within the configured trading session
Exit: Long, short-entry condition OR high >= entry price + configured take-profit distance OR datetime is at the configured session end
Exit: Short, long-entry condition OR low <= entry price - configured take-profit distance OR datetime is at the configured session end