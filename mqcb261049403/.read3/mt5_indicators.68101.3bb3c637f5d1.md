Calculation: candle range = high - low
Calculation: body percentage = abs(close - open) / candle range * 100
Calculation: upper wick percentage = (high - max(open, close)) / candle range * 100
Calculation: lower wick percentage = (min(open, close) - low) / candle range * 100
Long: On each scanned completed T1 bar, candle range > minimum range in normalized points AND candle range >= ATR(ATR lookback, T1, last completed bar) * ATR multiplier AND upper wick percentage < wick threshold AND lower wick percentage >= wick threshold AND body percentage >= minimum body percentage AND upper wick percentage <= maximum opposite wick percentage
Short: On each scanned completed T1 bar, candle range > minimum range in normalized points AND candle range >= ATR(ATR lookback, T1, last completed bar) * ATR multiplier AND upper wick percentage >= wick threshold AND body percentage >= minimum body percentage AND lower wick percentage <= maximum opposite wick percentage