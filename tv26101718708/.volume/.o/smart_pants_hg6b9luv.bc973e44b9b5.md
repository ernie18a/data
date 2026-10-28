Calculation: VWAP = session cumulative volume-weighted average of (high + low + close) / 3
Calculation: Fast EMA = shorter-lookback EMA of close than the Slow EMA
Long: (close > VWAP AND Fast EMA > Slow EMA) OR (close > VWAP AND RSI > 50) OR (Fast EMA > Slow EMA AND RSI > 50)
Long: ADX >= strength threshold AND ((close > VWAP AND Fast EMA > Slow EMA) OR (close > VWAP AND RSI > 50) OR (Fast EMA > Slow EMA AND RSI > 50))
Long: close > VWAP AND previous close <= previous VWAP
Long: Fast EMA > Slow EMA AND previous Fast EMA <= previous Slow EMA
Long: close > open AND previous close < previous open AND close > previous open AND open < previous close AND ADX >= strength threshold AND RSI > 30 AND RSI < 70 AND Fast EMA > Slow EMA
Short: (close <= VWAP AND Fast EMA <= Slow EMA) OR (close <= VWAP AND RSI <= 50) OR (Fast EMA <= Slow EMA AND RSI <= 50)
Short: ADX >= strength threshold AND ((close <= VWAP AND Fast EMA <= Slow EMA) OR (close <= VWAP AND RSI <= 50) OR (Fast EMA <= Slow EMA AND RSI <= 50))
Short: close < VWAP AND previous close >= previous VWAP
Short: Fast EMA < Slow EMA AND previous Fast EMA >= previous Slow EMA
Short: close < open AND previous close > previous open AND close < previous open AND open > previous close AND ADX >= strength threshold AND RSI > 30 AND RSI < 70 AND Fast EMA <= Slow EMA