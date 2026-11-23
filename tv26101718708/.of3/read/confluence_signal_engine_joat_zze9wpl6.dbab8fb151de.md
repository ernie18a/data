Calculation: Standardized deviation = (close - EMA(close, baseline EMA lookback)) / STDEV(close, deviation window)
Calculation: Volume pressure = RSI(volume, volume RSI lookback) / RSI midpoint
Calculation: Smoothed RSI = EMA(RSI(close, RSI lookback), RSI smoothing lookback)
Calculation: Trend = +1 if EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback), -1 if EMA(close, shorter EMA lookback) < EMA(close, longer EMA lookback), otherwise 0
Calculation: Deviation = +1 if Standardized deviation < -deviation threshold, -1 if Standardized deviation > deviation threshold, otherwise 0
Calculation: Participation = +1 if Volume pressure > volume threshold AND close > open, -1 if Volume pressure > volume threshold AND close < open, otherwise 0
Calculation: Momentum = +1 if RSI(close, RSI lookback) > RSI midpoint AND Smoothed RSI > Smoothed RSI[1], -1 if RSI(close, RSI lookback) < RSI midpoint AND Smoothed RSI < Smoothed RSI[1], otherwise 0
Calculation: Position = +1 if close > Donchian midline(high, low, structure lookback), -1 if close < Donchian midline(high, low, structure lookback), otherwise 0
Calculation: Volatility = +1 if ATR(shorter ATR lookback) / ATR(longer ATR lookback) < low volatility threshold, -1 if ATR(shorter ATR lookback) / ATR(longer ATR lookback) > high volatility threshold, otherwise 0
Calculation: Composite = (Trend + Deviation + Participation + Momentum + Position + Volatility) / 6
Long: Composite crosses above buy threshold
Long: Composite > buy threshold
Long: EMA(close, shorter EMA lookback) > EMA(close, longer EMA lookback)
Short: Composite crosses below sell threshold
Short: Composite < sell threshold
Short: EMA(close, shorter EMA lookback) <= EMA(close, longer EMA lookback)