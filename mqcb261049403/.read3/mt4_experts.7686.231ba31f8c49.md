Calculation: Fast moving average = LWMA(close, shorter fast-MA lookback × shared length multiplier)[configured chart-bar offset]
Calculation: Slow moving average = SMA(close, longer slow-MA lookback × shared length multiplier)[configured chart-bar offset]
Calculation: Stochastic main = Stochastic(close/close, %K lookback × shared length multiplier, %D lookback × shared length multiplier, slowing lookback × shared length multiplier, SMA, main line)[configured chart-bar offset]
Calculation: Previous stochastic main = Stochastic(close/close, %K lookback × shared length multiplier, %D lookback × shared length multiplier, slowing lookback × shared length multiplier, SMA, main line)[configured chart-bar offset + 1]
Calculation: RSI = RSI(close, RSI lookback × shared length multiplier)[configured chart-bar offset]
Calculation: MACD main = MACD(close, shorter MACD lookback × shared length multiplier, longer MACD lookback × shared length multiplier, main line)[configured chart-bar offset]
Long: Fast moving average > Slow moving average AND Stochastic main > Previous stochastic main AND RSI > long RSI cutoff AND MACD main > 0
Short: Fast moving average < Slow moving average AND Stochastic main < Previous stochastic main AND RSI < short RSI cutoff AND MACD main < 0
Exit: long, (Fast moving average <= Slow moving average OR Stochastic main <= Previous stochastic main OR RSI <= long RSI cutoff OR MACD main <= 0) AND (Fast moving average >= Slow moving average OR Stochastic main >= Previous stochastic main OR RSI >= short RSI cutoff OR MACD main >= 0) OR low <= entry price - stop-loss distance in points OR high >= entry price + take-profit distance in points
Exit: short, high >= entry price + stop-loss distance in points OR low <= entry price - take-profit distance in points