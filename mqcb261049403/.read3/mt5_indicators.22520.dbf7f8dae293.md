Calculation: Two-bar JMA displacement = ABS(JMA(close, lookback, phase, power) - JMA(close, lookback, phase, power)[2])
Long: RSI(close, RSI lookback) < lower threshold AND Two-bar JMA displacement > ATR(ATR lookback) / range divisor
Short: RSI(close, RSI lookback) > upper threshold AND Two-bar JMA displacement > ATR(ATR lookback) / range divisor
Long: on chart bars taking values from T1 current forming bar, RSI(close, RSI lookback) < lower threshold AND Two-bar JMA displacement > ATR(ATR lookback) / range divisor
Short: on chart bars taking values from T1 current forming bar, RSI(close, RSI lookback) > upper threshold AND Two-bar JMA displacement > ATR(ATR lookback) / range divisor