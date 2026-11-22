Calculation: Volatility Stop = initialize positive with stop at close; each chart bar use ATR(lookback) × multiplier, falling back to True Range while ATR is unavailable, and track the highest and lowest close since the last flip; in the positive state trail at max(previous stop, highest close − band), and in the negative state at min(previous stop, lowest close + band); the state is positive when close ≥ stop, and on a state change reset the stop to close − band if positive or close + band if negative
Long: close ≥ Volatility Stop(ATR lookback, multiplier) OR high ≥ Highest(high, lookback)
Short: close < Volatility Stop(ATR lookback, multiplier) OR low ≤ Lowest(low, same lookback)
Calculation: Benchmark-relative return = 100 × ((instrument close / benchmark close) / (instrument close P1 bars ago / benchmark close P1 bars ago) − 1)
Calculation: Mid-term moving average = EMA(instrument close, P2) on T1 chart timeframe; otherwise SMA(instrument close, P3)
Calculation: Long-term moving average = EMA(instrument close, P4) on T1 chart timeframe; otherwise SMA(instrument close, P5)
Long: benchmark-relative return > 0
Short: benchmark-relative return < 0
Long: instrument close > a moving average shown in the distance table
Short: instrument close < a moving average shown in the distance table
Long: instrument close ≥ Volatility Stop(instrument close, ATR length P6, multiplier P7) AND (benchmark-relative return unavailable OR (benchmark-relative return < P8 AND benchmark-relative return < P9))
Long: instrument close ≥ Volatility Stop(instrument close, ATR length P6, multiplier P7) AND benchmark-relative return ≥ P8 AND benchmark-relative return < P9
Long: instrument close ≥ Volatility Stop(instrument close, ATR length P6, multiplier P7) AND benchmark-relative return ≥ P9
Short: instrument close < Volatility Stop(instrument close, ATR length P6, multiplier P7) AND NOT (instrument close < mid-term moving average) AND NOT (instrument close < long-term moving average)
Short: instrument close < Volatility Stop(instrument close, ATR length P6, multiplier P7) AND instrument close < mid-term moving average AND NOT (instrument close < long-term moving average)
Short: instrument close < Volatility Stop(instrument close, ATR length P6, multiplier P7) AND instrument close < long-term moving average