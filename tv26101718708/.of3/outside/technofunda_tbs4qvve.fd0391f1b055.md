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