Calculation: Fast EVWMA = ((sum of volume over the shorter lookback − current volume) × prior Fast EVWMA + current volume × close) ÷ sum of volume over the shorter lookback; initialize prior Fast EVWMA to prior close
Calculation: Slow EVWMA = ((sum of volume over the longer lookback − current volume) × prior Slow EVWMA + current volume × close) ÷ sum of volume over the longer lookback; initialize prior Slow EVWMA to prior close
Calculation: Long ATR stop = close − ATR × multiplier on a long signal; otherwise retain its prior value, and clear it on a short signal
Calculation: Short ATR stop = close + ATR × multiplier on a short signal; otherwise retain its prior value, and clear it on a long signal
Long: Fast EVWMA > Slow EVWMA
Short: Fast EVWMA < Slow EVWMA
Exit: Long, low ≤ entry price × (1 − stop-loss fraction) OR low ≤ Long ATR stop
Exit: Short, high ≥ entry price × (1 + stop-loss fraction) OR high ≥ Short ATR stop