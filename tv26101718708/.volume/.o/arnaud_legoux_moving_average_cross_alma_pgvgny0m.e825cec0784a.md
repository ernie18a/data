Calculation: Fast ALMA = Arnaud Legoux moving average of close with a shorter lookback than slow ALMA; both use the same offset and sigma.
Calculation: Slow ALMA = Arnaud Legoux moving average of close with a longer lookback than fast ALMA.
Calculation: Volume oscillator = 100 × (short-lookback EMA of volume − long-lookback EMA of volume) / long-lookback EMA of volume; the short lookback is shorter than the long lookback.
Long: Fast ALMA crosses above slow ALMA AND volume oscillator > 0 AND no open position.
Short: Fast ALMA crosses below slow ALMA AND volume oscillator > 0 AND no open position.
Exit: Long, high ≥ entry price × (1 + take-profit percentage) OR low ≤ entry price × (1 − stop-loss percentage).
Exit: Short, low ≤ entry price × (1 − take-profit percentage) OR high ≥ entry price × (1 + stop-loss percentage).