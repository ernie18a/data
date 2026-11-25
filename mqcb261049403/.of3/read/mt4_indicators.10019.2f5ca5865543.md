Long: close > close[1]
Short: close < close[1]
Long: RSI(close, lookback) > RSI(close, lookback)[1]
Short: RSI(close, lookback) < RSI(close, lookback)[1]
Long: Stochastic main(K lookback, D lookback, slowing lookback) > Stochastic signal(K lookback, D lookback, slowing lookback)
Short: Stochastic main(K lookback, D lookback, slowing lookback) < Stochastic signal(K lookback, D lookback, slowing lookback)
Long: MACD main(close, fast lookback, slow lookback, signal lookback) > MACD signal(close, fast lookback, slow lookback, signal lookback)
Short: MACD main(close, fast lookback, slow lookback, signal lookback) < MACD signal(close, fast lookback, slow lookback, signal lookback)
Long: On chart bars using the T1 bar still forming, Parabolic SAR(step, maximum, T1) < close(T1) AND +DI(lookback, price source, T1) > -DI(lookback, price source, T1)
Short: On chart bars using the T1 bar still forming, Parabolic SAR(step, maximum, T1) > close(T1) AND -DI(lookback, price source, T1) > +DI(lookback, price source, T1)