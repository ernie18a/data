Calculation: TopLabel = HH if the last confirmed PivotHigh(high, swing strength, swing strength) is above the confirmed PivotHigh before it, LH if it is not, none if fewer than two confirmed PivotHighs exist
Calculation: BottomLabel = HL if the last confirmed PivotLow(low, swing strength, swing strength) is above the confirmed PivotLow before it, LL if it is not, none if fewer than two confirmed PivotLows exist
Long: close > last confirmed PivotHigh(high, swing strength, swing strength) AND TopLabel is not HH
Short: close < last confirmed PivotLow(low, swing strength, swing strength) AND BottomLabel is not LL
Long: TopLabel is HH AND BottomLabel is HL
Short: TopLabel is LH AND BottomLabel is LL
Calculation: ImpulseBar = (high - low) > range multiple * Median(high - low, median lookback) AND abs(close - open) >= body fraction * (high - low)
Long: ImpulseBar AND close > open
Short: ImpulseBar AND close < open
Calculation: VAH = Volume Profile Value Area High(profile lookback, bin size, value-area share)
Calculation: VAL = Volume Profile Value Area Low(profile lookback, bin size, value-area share)
Long: close > VAH AND close[1] <= VAH
Short: close < VAL AND close[1] >= VAL
Calculation: OIRegime(span) = n/a if ROC(open interest, span) or ROC(close, span) is unavailable; otherwise new longs if ROC(open interest, span) > 0 AND ROC(close, span) > 0, new shorts if ROC(open interest, span) > 0 AND ROC(close, span) < 0, short squeeze if ROC(open interest, span) < 0 AND ROC(close, span) > 0, long flush otherwise; span is a timeframe counted in chart bars
Long: OIRegime(T1) = new longs
Long: OIRegime(T2) = new longs
Short: OIRegime(T1) = new shorts
Short: OIRegime(T2) = new shorts
Exit: long, OIRegime(T1) = long flush
Exit: long, OIRegime(T2) = long flush
Exit: short, OIRegime(T1) = short squeeze
Exit: short, OIRegime(T2) = short squeeze