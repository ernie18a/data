Long: close < lower Bollinger Band AND close < VWAP AND ATR < its longer-lookback simple moving average AND datetime is within the configured session
Short: close > upper Bollinger Band AND close > VWAP AND ATR < its longer-lookback simple moving average AND datetime is within the configured session
Exit: long, low <= entry price - stop distance OR high >= entry price + target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - target distance