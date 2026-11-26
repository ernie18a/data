Calculation: bar range = high - low
Calculation: body ratio = bar range > 0 ? abs(close - open) / bar range : 0
Calculation: elephant bar = bar range > ATR(ATR lookback) * ATR multiplier AND body ratio > minimum body percentage
Calculation: long-term SMA distance = abs(close - SMA(close, longer trend lookback)) / SMA(close, longer trend lookback)
Long: close > SMA(close, close-filter lookback)
Short: close <= SMA(close, close-filter lookback)
Long: SMA(close, shorter trend lookback) > SMA(close, shorter trend lookback)[1]
Short: SMA(close, shorter trend lookback) <= SMA(close, shorter trend lookback)[1]
Long: SMA(close, shorter trend lookback) > SMA(close, longer trend lookback) AND long-term SMA distance >= trend range threshold
Short: SMA(close, shorter trend lookback) < SMA(close, longer trend lookback) AND long-term SMA distance >= trend range threshold
Long: elephant bar AND close > open
Short: elephant bar AND close < open
Long: low > high[2]
Short: high < low[2]
Long: close crosses above EMA(source, EMA lookback, T1), calculated on T1 bars and mapped to chart bars using the last completed T1 bar historically and the forming T1 bar in real time
Short: close crosses below EMA(source, EMA lookback, T1), calculated on T1 bars and mapped to chart bars using the last completed T1 bar historically and the forming T1 bar in real time