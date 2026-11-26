Calculation: EMA buffer = ATR(close, ATR lookback) × ATR buffer multiple in ATR mode OR EMA(close, EMA lookback) × buffer percentage / 100 in percent mode
Calculation: bullish EMA turn = minimum spacing since the prior entry is met AND ((anti-whipsaw enabled AND close stayed above EMA(close, EMA lookback) + EMA buffer for the confirmation bars AND the prior bar did not satisfy this confirmation) OR (anti-whipsaw disabled AND close crosses above EMA(close, EMA lookback)))
Calculation: bearish EMA turn = minimum spacing since the prior entry is met AND ((anti-whipsaw enabled AND close stayed below EMA(close, EMA lookback) - EMA buffer for the confirmation bars AND the prior bar did not satisfy this confirmation) OR (anti-whipsaw disabled AND close crosses below EMA(close, EMA lookback)))
Long: long entries enabled AND datetime is within the date window AND position is flat or short AND bullish EMA turn
Short: short entries enabled AND datetime is within the date window AND position is flat or long AND bearish EMA turn
Long: close > EMA(close, EMA lookback) AND MACD histogram(close, fast lookback, slow lookback, signal lookback) crosses above zero AND RSI(close, RSI lookback) > lower RSI threshold AND RSI(close, RSI lookback) < RSI midpoint threshold AND MFI((high + low + close) / 3, MFI lookback) < MFI threshold
Short: close < EMA(close, EMA lookback) AND MACD histogram(close, fast lookback, slow lookback, signal lookback) crosses below zero AND RSI(close, RSI lookback) > RSI midpoint threshold AND RSI(close, RSI lookback) < upper RSI threshold AND MFI((high + low + close) / 3, MFI lookback) > MFI threshold
Exit: long, bearish EMA turn
Exit: long, ATR stop enabled AND low <= entry price - ATR(close, ATR lookback) × stop ATR multiple
Exit: short, short take profits enabled AND low <= entry price - ATR(close, ATR lookback) × first short target ATR multiple
Exit: short, short take profits enabled AND low <= entry price - ATR(close, ATR lookback) × second short target ATR multiple
Exit: short, ATR stop enabled AND high >= entry price + ATR(close, ATR lookback) × stop ATR multiple
Exit: short, short capitulation exit enabled AND (entry price - close) / ATR(close, ATR lookback) >= capitulation ATR threshold AND (RSI(close, RSI lookback) <= short oversold RSI threshold OR smoothed Stochastic %K <= short oversold Stochastic threshold) AND smoothed Stochastic %K crosses above smoothed Stochastic %D, where %K = SMA(Stochastic %K(close, high, low, Stochastic lookback), Stochastic smoothing) AND %D = SMA(%K, Stochastic smoothing)
Exit: long, datetime is outside the date window
Exit: short, datetime is outside the date window