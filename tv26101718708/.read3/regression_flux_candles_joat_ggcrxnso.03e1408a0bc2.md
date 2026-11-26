Calculation: warmup duration = max(LR lookback × warmup multiplier, trend EMA lookback + warmup offset)
Calculation: bullish timeframe count = count of T1–T6 where LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on each timeframe’s current possibly forming bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback)
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback)
Long: LINREG(close, LR lookback) crosses above SMA(LINREG(close, LR lookback), signal SMA lookback) AND (volume filter disabled OR volume > SMA(volume, volume lookback)) AND (RSI filter disabled OR RSI(close, RSI lookback) < RSI upper block level) AND chart bar index >= warmup duration AND chart bar is confirmed
Short: LINREG(close, LR lookback) crosses below SMA(LINREG(close, LR lookback), signal SMA lookback) AND (volume filter disabled OR volume > SMA(volume, volume lookback)) AND (RSI filter disabled OR RSI(close, RSI lookback) > RSI lower block level) AND chart bar index >= warmup duration AND chart bar is confirmed
Long: PivotLow(low, pivot-left lookback, pivot-right lookback) exists on the confirmation bar
Short: PivotHigh(high, pivot-left lookback, pivot-right lookback) exists on the confirmation bar
Long: bullish timeframe count >= bullish alignment threshold
Short: bullish timeframe count <= bearish alignment threshold
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T1 bars using the current possibly forming T1 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T1 bars using the current possibly forming T1 bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T2 bars using the current possibly forming T2 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T2 bars using the current possibly forming T2 bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T3 bars using the current possibly forming T3 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T3 bars using the current possibly forming T3 bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T4 bars using the current possibly forming T4 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T4 bars using the current possibly forming T4 bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T5 bars using the current possibly forming T5 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T5 bars using the current possibly forming T5 bar and returned to chart bars with lookahead off
Long: LINREG(close, LR lookback) >= LINREG(open, LR lookback), calculated on T6 bars using the current possibly forming T6 bar and returned to chart bars with lookahead off
Short: LINREG(close, LR lookback) < LINREG(open, LR lookback), calculated on T6 bars using the current possibly forming T6 bar and returned to chart bars with lookahead off