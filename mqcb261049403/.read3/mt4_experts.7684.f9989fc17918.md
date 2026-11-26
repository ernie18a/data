Calculation: MACD value = MACD(close, fast lookback, slow lookback, T1, last completed bar)
Calculation: OsMA value = OsMA(close, fast lookback, slow lookback, signal lookback, T1, last completed bar)
Calculation: Force Index value = Force Index(close, volume, lookback, EMA, T1, last completed bar)
Long: On each chart tick, MACD value > MACD value[1]
Short: On each chart tick, MACD value < MACD value[1]
Long: On each chart tick, OsMA value > OsMA value[1]
Short: On each chart tick, OsMA value < OsMA value[1]
Long: On each chart tick, Force Index value > 0
Short: On each chart tick, Force Index value < 0
Long: On each chart tick, OsMA value < OsMA value[1] AND Force Index value > 0
Short: On each chart tick, OsMA value > OsMA value[1] AND Force Index value < 0