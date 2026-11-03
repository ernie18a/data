Calculation: Smoothed stochastic = SMA of stochastic %K, where %K = 100 × (close − lowest low) ÷ (highest high − lowest low) over a lookback; the SMA uses a shorter lookback
Calculation: SMI angle = atan(current smoothed stochastic − prior bar’s smoothed stochastic), converted to degrees, using chart timeframe bars
Calculation: MACD angle = atan(current MACD line − prior MACD line), converted to degrees; MACD line = fast EMA minus slow EMA of the higher timeframe close, using the last completed higher timeframe bar, with the fast EMA lookback shorter than the slow EMA lookback
Long: close <= lower Bollinger Band AND SMI angle > 0 AND SMI angle <= 60 AND MACD angle > 0 AND MACD angle <= 50
Exit: long, close >= upper Bollinger Band