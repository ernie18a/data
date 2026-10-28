Calculation: Supertrend = initialize at VWAP; thereafter, if close > previous Supertrend, max(VWAP − multiplier × ATR, previous Supertrend), otherwise min(VWAP + multiplier × ATR, previous Supertrend)
Calculation: ATR = average true range using the Supertrend ATR lookback
Long: close > Supertrend AND close > VWAP AND close > EMA AND EMA > SMA AND current-timeframe RSI < 40 AND daily RSI < 45 (daily bar still forming)
Short: close ≤ Supertrend AND close < VWAP AND close < EMA AND EMA < SMA AND current-timeframe RSI > 60 AND daily RSI > 55 (daily bar still forming)
Calculation: Long stop = max(entry price × (1 − stop-loss percentage), close × (1 − trailing percentage)); use entry price instead of the initial stop-loss level when close ≥ entry price × (1 + breakeven percentage)
Calculation: Short stop = min(entry price × (1 + stop-loss percentage), close × (1 + trailing percentage)); use entry price instead of the initial stop-loss level when close ≤ entry price × (1 − breakeven percentage)
Exit: long, low ≤ Long stop OR high ≥ entry price × (1 + take-profit percentage)
Exit: short, high ≥ Short stop OR low ≤ entry price × (1 − take-profit percentage)