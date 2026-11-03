Calculation: EVWMA(N) = ((sum of volume over the last N bars − current volume) × previous EVWMA + current volume × close) / sum of volume over the last N bars; initialize to close.
Long: Fast EVWMA with a shorter lookback > slow EVWMA with a longer lookback
Short: Fast EVWMA with a shorter lookback < slow EVWMA with a longer lookback
Exit: long, fixed stop selected AND low ≤ entry price × (1 − stop percentage) OR ATR stop selected AND low ≤ the stop set to close − ATR × multiplier on the latest bullish crossover of fast EVWMA above slow EVWMA
Exit: short, fixed stop selected AND high ≥ entry price × (1 + stop percentage) OR ATR stop selected AND high ≥ the stop set to close + ATR × multiplier on the latest bearish crossover of fast EVWMA below slow EVWMA