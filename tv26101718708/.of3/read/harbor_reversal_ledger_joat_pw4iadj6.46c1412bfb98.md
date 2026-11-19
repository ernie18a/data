Calculation: Bullish T1 pattern = (engulfing enabled AND the last completed T1 candle closes above its open AND the preceding completed T1 candle closes below its open AND the last completed T1 close is at least the preceding T1 open AND the last completed T1 open is at most the preceding T1 close) OR (pin enabled AND the last completed T1 lower wick is greater than its range times the lower-wick proportion parameter AND its absolute body is less than its range times the body proportion parameter)
Calculation: Bearish T1 pattern = (engulfing enabled AND the last completed T1 candle closes below its open AND the preceding completed T1 candle closes above its open AND the last completed T1 close is at most the preceding T1 open AND the last completed T1 open is at least the preceding T1 close) OR (pin enabled AND the last completed T1 upper wick is greater than its range times the lower-wick proportion parameter AND its absolute body is less than its range times the body proportion parameter)
Calculation: Bullish RSI divergence = on a chart bar confirming a pivot low of RSI(close, RSI lookback) with separate left and right pivot lookbacks, low at the pivot bar (right pivot lookback bars ago) is below the corresponding low of the previous confirmed RSI pivot low, and RSI at the current pivot is above RSI at the previous pivot
Calculation: Bearish RSI divergence = on a chart bar confirming a pivot high of RSI(close, RSI lookback) with separate left and right pivot lookbacks, high at the pivot bar (right pivot lookback bars ago) is above the corresponding high of the previous confirmed RSI pivot high, and RSI at the current pivot is below RSI at the previous pivot
Calculation: Bullish confluence = (bullish T1 pattern ? pattern weight parameter : 0) + (bullish RSI divergence ? divergence weight parameter : 0) + max(distance floor parameter, distance baseline parameter - (low - lowest(low, distance lookback parameter)) / max(ATR(ATR lookback parameter) times ATR scale parameter, minimum tick)) times distance weight parameter
Calculation: Bearish confluence = (bearish T1 pattern ? pattern weight parameter : 0) + (bearish RSI divergence ? divergence weight parameter : 0) + max(distance floor parameter, distance baseline parameter - (highest(high, distance lookback parameter) - high) / max(ATR(ATR lookback parameter) times ATR scale parameter, minimum tick)) times distance weight parameter
Calculation: Net confluence = bullish confluence - bearish confluence
Long: Bullish T1 pattern in the last completed T1 candle
Short: Bearish T1 pattern in the last completed T1 candle
Long: On the first chart bar of a new T1 interval, bullish T1 pattern in the last completed T1 candle
Short: On the first chart bar of a new T1 interval, bearish T1 pattern in the last completed T1 candle
Long: Bullish RSI divergence
Short: Bearish RSI divergence
Long: Last completed T1 candle has a bullish T1 pattern OR (does not have a bearish T1 pattern AND its close is above its open)
Short: Last completed T1 candle does not have a bullish T1 pattern AND (has a bearish T1 pattern OR its close is below its open)
Long: Net confluence is greater than or equal to zero
Short: Net confluence is below zero
Long: Bullish RSI divergence AND bullish confluence is greater than or equal to bearish confluence
Short: Bearish RSI divergence AND bearish confluence is greater than or equal to bullish confluence