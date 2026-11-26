Calculation: normalized ATR = (ATR(ATR lookback) - LOWEST(ATR(ATR lookback), ATR lookback)) / (HIGHEST(ATR(ATR lookback), ATR lookback) - LOWEST(ATR(ATR lookback), ATR lookback))
Calculation: dynamic overbought = MIN(base overbought + normalized ATR * (100 - base overbought) * ATR scaling, 100)
Calculation: dynamic oversold = MAX(base oversold - normalized ATR * base oversold * ATR scaling, 0)
Long: RSI(close, RSI lookback) crosses below dynamic oversold AND (trend filter is disabled OR MA(close, shorter lookback, first MA type) >= MA(close, longer lookback, second MA type))
Short: RSI(close, RSI lookback) crosses above dynamic overbought AND (trend filter is disabled OR MA(close, shorter lookback, first MA type) <= MA(close, longer lookback, second MA type))
Exit: long, RSI(close, RSI lookback) crosses above RSI mean level
Exit: short, RSI(close, RSI lookback) crosses below RSI mean level