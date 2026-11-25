Calculation: prior signal direction = the direction of the most recent earlier long or short signal, or neutral if none
Long: close > close[lookback] AND +DI(ADX period) > -DI(ADX period) AND prior signal direction is not long
Short: close < close[lookback] AND +DI(ADX period) < -DI(ADX period) AND prior signal direction is not short
Long: close(T1, still-forming bar) > close[lookback](T1, still-forming bar) AND +DI(ADX period, T1, still-forming bar) > -DI(ADX period, T1, still-forming bar) AND prior signal direction is not long
Short: close(T1, still-forming bar) < close[lookback](T1, still-forming bar) AND +DI(ADX period, T1, still-forming bar) < -DI(ADX period, T1, still-forming bar) AND prior signal direction is not short