Calculation: Close-to-close percentage move[n] = round(100 × abs(close[n] - close[n+1]) / mean(abs(close[i] - close[i+1]) for i from n+1 through n+4)), for n = 0 through 4
Calculation: MACD rising condition = MACD main(current chart bar) > MACD main(last completed chart bar) AND ((MACD main(current chart bar) ≠ 0 AND MACD main(last completed chart bar) ≠ 0) ≠ MACD signal(current chart bar))
Calculation: MACD falling condition = MACD main(current chart bar) < MACD main(last completed chart bar) AND ((MACD main(current chart bar) ≠ 0 AND MACD main(last completed chart bar) ≠ 0) ≠ MACD signal(current chart bar))
Long: EMA(close, lookback, T1, forming bar) > EMA(close, lookback, T1, last completed bar)
Long: EMA(close, lookback, T2, forming bar) > EMA(close, lookback, T2, last completed bar)
Long: EMA(close, lookback, T3, forming bar) > EMA(close, lookback, T3, last completed bar)
Long: EMA(close, lookback, T4, forming bar) > EMA(close, lookback, T4, last completed bar)
Long: EMA(close, lookback, T5, forming bar) > EMA(close, lookback, T5, last completed bar)
Long: EMA(close, lookback, T6, forming bar) > EMA(close, lookback, T6, last completed bar)
Long: EMA(close, lookback, T7, forming bar) > EMA(close, lookback, T7, last completed bar)
Short: EMA(close, lookback, T1, forming bar) < EMA(close, lookback, T1, last completed bar)
Short: EMA(close, lookback, T2, forming bar) < EMA(close, lookback, T2, last completed bar)
Short: EMA(close, lookback, T3, forming bar) < EMA(close, lookback, T3, last completed bar)
Short: EMA(close, lookback, T4, forming bar) < EMA(close, lookback, T4, last completed bar)
Short: EMA(close, lookback, T5, forming bar) < EMA(close, lookback, T5, last completed bar)
Short: EMA(close, lookback, T6, forming bar) < EMA(close, lookback, T6, last completed bar)
Short: EMA(close, lookback, T7, forming bar) < EMA(close, lookback, T7, last completed bar)
Long: Parabolic SAR(step, maximum, current chart bar) > Parabolic SAR(step, maximum, last completed chart bar)
Short: Parabolic SAR(step, maximum, current chart bar) < Parabolic SAR(step, maximum, last completed chart bar)
Long: MACD main crosses above zero OR ((MACD rising condition OR MACD main crosses above its signal line) AND NOT MACD main crosses below its signal line AND NOT MACD main crosses below zero)
Short: MACD main crosses below zero OR ((MACD falling condition OR MACD main crosses below its signal line) AND NOT MACD main crosses above its signal line AND NOT MACD main crosses above zero)
Long: LWMA(close, fast lookback, current chart bar) > SMA(close, slow lookback, current chart bar)
Short: LWMA(close, fast lookback, current chart bar) < SMA(close, slow lookback, current chart bar)
Long: Williams %R(lookback, current chart bar) > WPR directional threshold
Short: Williams %R(lookback, current chart bar) < WPR directional threshold
Long: (close[0] > close[1] AND Close-to-close percentage move[0] ≥ meter visibility threshold) OR (close[1] > close[2] AND Close-to-close percentage move[1] ≥ meter visibility threshold) OR (close[2] > close[3] AND Close-to-close percentage move[2] ≥ meter visibility threshold) OR (close[3] > close[4] AND Close-to-close percentage move[3] ≥ meter visibility threshold) OR (close[4] > close[5] AND Close-to-close percentage move[4] ≥ meter visibility threshold)
Short: (close[0] < close[1] AND Close-to-close percentage move[0] ≥ meter visibility threshold) OR (close[1] < close[2] AND Close-to-close percentage move[1] ≥ meter visibility threshold) OR (close[2] < close[3] AND Close-to-close percentage move[2] ≥ meter visibility threshold) OR (close[3] < close[4] AND Close-to-close percentage move[3] ≥ meter visibility threshold) OR (close[4] < close[5] AND Close-to-close percentage move[4] ≥ meter visibility threshold)
Long: ((MACD rising condition OR MACD main crosses above its signal line) AND NOT MACD main crosses below its signal line AND NOT (MACD main crosses above zero OR MACD main crosses below zero)) AND LWMA(close, fast lookback, current chart bar) > SMA(close, slow lookback, current chart bar) AND Williams %R(lookback, current chart bar) > WPR directional threshold AND EMA(close, lookback, current chart bar) > EMA(close, lookback, last completed chart bar) AND Stochastic %K(K lookback, D lookback, slowing, SMA, current chart bar) > Stochastic %K(K lookback, D lookback, slowing, SMA, last completed chart bar) AND close[0] > close[1]
Short: ((MACD falling condition OR MACD main crosses below its signal line) AND NOT MACD main crosses above its signal line AND NOT (MACD main crosses above zero OR MACD main crosses below zero)) AND LWMA(close, fast lookback, current chart bar) < SMA(close, slow lookback, current chart bar) AND Williams %R(lookback, current chart bar) < WPR directional threshold AND EMA(close, lookback, current chart bar) < EMA(close, lookback, last completed chart bar) AND Stochastic %K(K lookback, D lookback, slowing, SMA, current chart bar) < Stochastic %K(K lookback, D lookback, slowing, SMA, last completed chart bar) AND close[0] < close[1]