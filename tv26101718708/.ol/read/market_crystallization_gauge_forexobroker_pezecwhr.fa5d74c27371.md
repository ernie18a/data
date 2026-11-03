Calculation: Return = close − previous close
Calculation: Return correlation = correlation of current and previous returns over a lookback
Calculation: ADX and DI+, DI− = directional movement indicators calculated over the same lookback
Calculation: ADX slope = current ADX − ADX from three bars earlier
Calculation: Return volatility ratio = standard deviation of returns over a short lookback ÷ simple moving average of that standard deviation over a longer baseline lookback
Calculation: Crystallization score = rounded sum of three components: clamp(60 × return correlation + 30, 0, 40); clamp(1.5 × (ADX − 15) + 3 × ADX slope, 0, 35); clamp(50 × (1.2 − return volatility ratio), 0, 25)
Calculation: Regime EMA = exponential moving average of close
Calculation: Volume average = simple moving average of volume
Long: Current crystallization score ≥ threshold AND previous bar's score < threshold AND DI+ > DI− AND close > regime EMA AND volume > volume average AND bars since the last long or short signal ≥ cooldown AND current bar is complete
Short: Current crystallization score ≥ threshold AND previous bar's score < threshold AND DI− > DI+ AND close < regime EMA AND volume > volume average AND bars since the last long or short signal ≥ cooldown AND current bar is complete