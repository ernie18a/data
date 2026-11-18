Calculation: Volume delta = sum(volume on bars where close >= open, volume lookback) − sum(volume on bars where close < open, volume lookback)
Calculation: Buy-volume share = percentage of bullish-bar volume in total classified volume over volume lookback, or neutral percentage when total classified volume is zero
Calculation: Mean lower-wick percentage = SMA(if high > low then percentage of high − low formed by min(close, open) − low, else neutral percentage, volume lookback)
Calculation: Momentum score = clamp((percentage change from close[volume lookback] to close + momentum offset) × momentum scale, score lower bound, score upper bound)
Calculation: Buy pressure score = buy-volume share × volume-share weight + mean lower-wick percentage × wick weight + momentum score × momentum weight + (100 − RSI(close, RSI lookback)) × RSI weight
Calculation: Sell pressure score = 100 − buy pressure score
Long: Buy pressure score >= narrative score threshold AND RSI(close, RSI lookback) < RSI upper bound AND volume delta > 0
Short: Sell pressure score >= narrative score threshold AND RSI(close, RSI lookback) > RSI lower bound AND volume delta < 0
Long: EMA(close, short EMA lookback) crosses above EMA(close, long EMA lookback) AND RSI(close, RSI lookback) < RSI upper bound AND (pressure filter is disabled OR buy pressure score >= buy pressure threshold)
Short: EMA(close, short EMA lookback) crosses below EMA(close, long EMA lookback) AND RSI(close, RSI lookback) > RSI lower bound AND (pressure filter is disabled OR sell pressure score >= sell pressure threshold)
Long: buy pressure score >= buy pressure threshold
Short: sell pressure score >= sell pressure threshold
Long: EMA(close, short EMA lookback) > EMA(close, long EMA lookback)
Short: EMA(close, short EMA lookback) <= EMA(close, long EMA lookback)