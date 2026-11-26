Calculation: Bull phase = EMA(close, shorter chart lookback) > EMA(close, longer chart lookback) AND close > VWAP(close) AND ADX(DI lookback, ADX smoothing) > minimum ADX AND +DI(DI lookback) > -DI(DI lookback)
Calculation: Bear phase = EMA(close, shorter chart lookback) < EMA(close, longer chart lookback) AND close < VWAP(close) AND ADX(DI lookback, ADX smoothing) > minimum ADX AND -DI(DI lookback) > +DI(DI lookback)
Calculation: Body percentage = IF(high > low, ABS(close - open) / (high - low) * 100, 0)
Calculation: Long pullback = Bull phase AND low <= EMA(close, shorter chart lookback) AND close > EMA(close, shorter chart lookback)
Calculation: Short pullback = Bear phase AND high >= EMA(close, shorter chart lookback) AND close < EMA(close, shorter chart lookback)
Long: close(T1 bar still forming, sampled on chart bars) > EMA(close, longer T1 lookback, on T1 bars, sampled on chart bars) AND EMA(close, shorter T1 lookback, on T1 bars, sampled on chart bars) > EMA(close, longer T1 lookback, on T1 bars, sampled on chart bars)
Short: close(T1 bar still forming, sampled on chart bars) < EMA(close, longer T1 lookback, on T1 bars, sampled on chart bars) AND EMA(close, shorter T1 lookback, on T1 bars, sampled on chart bars) < EMA(close, longer T1 lookback, on T1 bars, sampled on chart bars)
Long: Bull phase
Short: Bear phase
Long: Long pullback
Short: Short pullback
Long: Long pullback AND close > open AND Body percentage > body threshold AND (no prior exit OR chart bars since last exit > cooldown) AND position side is not long AND chart bar confirmed
Short: Short pullback AND close < open AND Body percentage > body threshold AND (no prior exit OR chart bars since last exit > cooldown) AND position side is not short AND chart bar confirmed
Exit: long, chart bar confirmed AND (close < EMA(close, shorter chart lookback) OR close < VWAP(close))
Exit: short, chart bar confirmed AND (close > EMA(close, shorter chart lookback) OR close > VWAP(close))