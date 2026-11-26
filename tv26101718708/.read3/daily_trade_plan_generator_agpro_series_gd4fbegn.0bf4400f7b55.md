Calculation: Bias score = round(50 * (1 + sum(weight(Ti) * (sign(EMA(close, fast lookback, Ti, current/forming Ti bar) > EMA(close, slow lookback, Ti, current/forming Ti bar)) + sign(close(Ti, current/forming bar) > EMA(close, fast lookback, Ti, current/forming Ti bar)) + sign(EMA(close, fast lookback, Ti, current/forming Ti bar) > its previous chart-bar sample)) / 3 for T1-T4)); sign(true)=1 and sign(false)=-1; values are read on chart bars with lookahead off, using the current/forming Ti bar in real time, and weights follow the selected weighting mode.
Long: bias score >= bullish bias threshold
Short: bias score <= bearish bias threshold
Long: confirmed chart bar AND crossover(close, high[1] of T5, last completed T5 bar)
Short: confirmed chart bar AND crossunder(close, low[1] of T5, last completed T5 bar)
Calculation: Projected high = session open + ATR(ATR lookback, T5, last completed bar) * range multiplier / 2
Calculation: Projected low = session open - ATR(ATR lookback, T5, last completed bar) * range multiplier / 2
Long: confirmed chart bar AND crossover(close, projected high)
Short: confirmed chart bar AND crossunder(close, projected low)