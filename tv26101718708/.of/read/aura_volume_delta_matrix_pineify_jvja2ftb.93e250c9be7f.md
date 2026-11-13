Calculation: RawDelta = bar volume if close > open; negative bar volume if close < open; 0 if close == open
Calculation: SmoothDelta = EMA of RawDelta (first smoothing pass)
Calculation: SignalLine = EMA of SmoothDelta (second pass applied to SmoothDelta, not to RawDelta)
Long: SmoothDelta crosses above SignalLine (previous bar SmoothDelta <= SignalLine AND current bar SmoothDelta > SignalLine) AND SmoothDelta > 0
Short: SmoothDelta crosses below SignalLine (previous bar SmoothDelta >= SignalLine AND current bar SmoothDelta < SignalLine) AND SmoothDelta < 0