Calculation: Body-to-range ratio = abs(close − open) / (high − low), or 0 when high = low
Calculation: Volume spike = current volume > mean volume of the previous N bars × volume multiplier
Calculation: Mean candle range = mean(high − low) over the previous N bars
Calculation: Long absorption candle = body-to-range ratio < body-ratio threshold AND volume spike AND close < open
Calculation: Short absorption candle = body-to-range ratio < body-ratio threshold AND volume spike AND close > open
Calculation: Long absorption cluster = count of long absorption candles in the current and previous L−1 bars ≥ cluster threshold
Calculation: Short absorption cluster = count of short absorption candles in the current and previous L−1 bars ≥ cluster threshold
Calculation: Long entry setup = a long absorption candle occurred in the previous E bars; the most recent such candle has high H; previous close ≤ H; current close > open AND current close > H
Calculation: Short entry setup = a short absorption candle occurred in the previous E bars; the most recent such candle has low L; previous close ≥ L; current close < open AND current close < L
Calculation: Bullish impulse = body-to-range ratio > 0.7 AND volume spike AND current high − low > mean candle range × impulse-range multiplier AND close > open
Calculation: Bearish impulse = body-to-range ratio > 0.7 AND volume spike AND current high − low > mean candle range × impulse-range multiplier AND close < open
Long: Long entry setup OR bullish impulse OR (long absorption cluster AND bullish impulse)
Short: Short entry setup OR bearish impulse OR (short absorption cluster AND bearish impulse)
Exit: Long, low ≤ entry price × (1 + first target % / 100) OR low ≤ entry price × (1 + second target % / 100) OR high ≥ entry price × (1 + final target % / 100) OR low ≤ long stop price OR close-long signal OR (reversal mode AND sell signal)
Exit: Short, high ≥ entry price / (1 + first target % / 100) OR high ≥ entry price / (1 + second target % / 100) OR low ≤ entry price / (1 + final target % / 100) OR high ≥ short stop price OR close-short signal OR (reversal mode AND buy signal)