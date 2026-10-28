Calculation: Candle range = high − low
Calculation: Body fraction = abs(close − open) / candle range
Calculation: Upper wick fraction = (high − max(open, close)) / candle range
Calculation: Lower wick fraction = (min(open, close) − low) / candle range
Calculation: Close location = (close − low) / candle range
Calculation: Recent volume baseline = median and percentile values from prior lookback candles, excluding the current candle; matching-time mode uses prior completed candles at the same clock minute when sufficiently sampled
Calculation: Recent range baseline = median and percentile values from prior lookback candles, excluding the current candle
Calculation: High activity = volume exceeds the selected baseline's high percentile AND volume / baseline median >= high-volume multiple
Calculation: Low activity = volume is below the selected baseline's low percentile AND volume / baseline median <= low-volume multiple
Calculation: Large range = candle range >= prior-range high percentile AND candle range / prior-range median >= large-range multiple
Calculation: Opening gap = abs(open − prior close) / prior-range median
Long: High activity AND Large range AND Body fraction >= body threshold AND (Close location >= upper-edge boundary OR Close location <= lower-edge boundary) AND close > open AND Opening gap <= gap threshold
Long: High activity AND candle range >= prior-range median AND Lower wick fraction >= wick threshold AND Close location >= upper-recovery boundary AND Opening gap <= gap threshold
Long: Low activity AND Large range AND close > open AND Opening gap <= gap threshold
Short: High activity AND Large range AND Body fraction >= body threshold AND (Close location >= upper-edge boundary OR Close location <= lower-edge boundary) AND close < open AND Opening gap <= gap threshold
Short: High activity AND candle range >= prior-range median AND Upper wick fraction >= wick threshold AND Close location <= lower-recovery boundary AND Opening gap <= gap threshold
Short: Low activity AND Large range AND close < open AND Opening gap <= gap threshold