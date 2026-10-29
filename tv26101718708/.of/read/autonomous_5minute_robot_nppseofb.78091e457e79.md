Calculation: Buy volume = volume × (close − low) / (high − low), or 0 when high = low
Calculation: Sell volume = volume × (high − close) / (high − low), or 0 when high = low
Long: close > 50-period simple moving average AND close > close 6 bars ago AND buy volume > sell volume
Short: close < 50-period simple moving average AND close < close 6 bars ago AND sell volume > buy volume
Exit: Long, low ≤ entry price × (1 − stop-loss percentage) OR high ≥ entry price × (1 + take-profit percentage)
Exit: Short, high ≥ entry price × (1 + stop-loss percentage) OR low ≤ entry price × (1 − take-profit percentage)