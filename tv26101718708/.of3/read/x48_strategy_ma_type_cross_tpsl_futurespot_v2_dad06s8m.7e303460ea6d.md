Long: fast MA(source, fast lookback, fast MA type) crosses above slow MA(source, slow lookback, slow MA type)
Short: spot mode disabled AND fast MA(source, fast lookback, fast MA type) crosses below slow MA(source, slow lookback, slow MA type)
Exit: long, spot mode enabled AND fast MA(source, fast lookback, fast MA type) crosses below slow MA(source, slow lookback, slow MA type)
Exit: long, middle-MA mode enabled AND fast MA(source, fast lookback, fast MA type) crosses below middle MA(source, middle lookback, middle MA type)
Long: fast MA(source, fast lookback, fast MA type) > slow MA(source, slow lookback, slow MA type)
Short: fast MA(source, fast lookback, fast MA type) < slow MA(source, slow lookback, slow MA type)
Long: RSI(source, RSI lookback) crosses above overbought threshold
Short: RSI(source, RSI lookback) crosses below oversold threshold
Long: MACD histogram(close, fast lookback, slow lookback, signal lookback) crosses above zero
Short: MACD histogram(close, fast lookback, slow lookback, signal lookback) crosses below zero
Long: close crosses above EMA(close, surfing lookback)
Short: close crosses below EMA(close, surfing lookback)
Exit: long, automatic TP/SL enabled AND ((long take-profit parameter > 0 AND high >= entry price * (1 + long take-profit parameter / 100)) OR (stop-loss parameter > 0 AND low <= entry price * (1 - stop-loss parameter / 100)))
Exit: short, automatic TP/SL enabled AND ((short take-profit parameter > 0 AND low <= entry price * (1 - short take-profit parameter / 100)) OR (stop-loss parameter > 0 AND high >= entry price * (1 + stop-loss parameter / 100)))
Exit: long, callback trailing-stop mode enabled AND close < (highest high over callback lookback * (1 - callback percentage / 100))
Exit: short, callback trailing-stop mode enabled AND close > (lowest low over callback lookback * (1 + callback percentage / 100))