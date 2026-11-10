Calculation: Swing highs and lows = pivots confirmed using equal-length left and right lookbacks; the most recently confirmed pivot is available on its confirmation bar.
Calculation: Liquidity pools = confirmed swing highs for upside pools and confirmed swing lows for downside pools. Store each pool's pivot price, pivot bar, and pivot-bar volume divided by its volume SMA, using 1 if unavailable. Keep at most a parameterized number of pools per side, deleting the oldest when exceeded. A pool starts active with zero touches. On each bar, increment an active upside pool's touches if high >= pool price - ATR × touch-buffer parameter, and increment an active downside pool's touches if low <= pool price + ATR × touch-buffer parameter. After counting touches, deactivate an upside pool if close > pool price + ATR × touch-buffer parameter, or a downside pool if close < pool price - ATR × touch-buffer parameter; deactivate either if its age in bars exceeds twice the freshness-window parameter.
Calculation: Higher-timeframe trend = bullish if chart close > higher-timeframe EMA and that EMA > its value a parameterized number of higher-timeframe bars earlier; bearish if chart close < that EMA and that EMA < its earlier value; otherwise neutral. Use the last completed higher-timeframe bar for both EMA values.
Calculation: Pool score = 25 × max(0, 1 - abs(pool price - close) / max(ATR, minimum price increment parameter) / reach parameter) + 20 × min(pivot-bar volume ratio / volume-reference parameter, 1) + 15 × max(0, 1 - pool age / freshness-window parameter) + 15 × min(touches, 3) / 3 + 10 if an upside pool is above close or a downside pool is below close, otherwise 0 + 15 if the higher-timeframe trend agrees with the pool side, 7.5 if neutral, otherwise 0.
Calculation: Net liquidity pull = maximum score among active upside pools above close minus maximum score among active downside pools below close; use zero for a side with no qualifying pool. Score pools after the current bar's touch and deactivation updates.
Calculation: Structure state = initially neutral; set bullish when close > the latest confirmed swing high AND previous close <= that same swing high; set bearish when close < the latest confirmed swing low AND previous close >= that same swing low. If both occur on the same bar, bearish takes precedence. Retain the state until another break.
Long: low > high two bars ago
Short: high < low two bars ago
Long: close > the latest confirmed swing high AND previous close <= that same swing high
Short: close < the latest confirmed swing low AND previous close >= that same swing low
Long: net liquidity pull >= dominance-threshold parameter
Short: net liquidity pull <= -dominance-threshold parameter
Long: higher-timeframe trend = bullish
Short: higher-timeframe trend = bearish
Long: structure state = bullish
Short: structure state = bearish