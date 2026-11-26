Calculation: ResistanceLevel = PivotHigh(high, pivot length, pivot length) on chart bars when zone source mode is not MTF, or PivotHigh(high, pivot length, pivot length, T1, last completed bar) when zone source mode is MTF
Calculation: SupportLevel = PivotLow(low, pivot length, pivot length) on chart bars when zone source mode is not MTF, or PivotLow(low, pivot length, pivot length, T1, last completed bar) when zone source mode is MTF
Calculation: ZoneSize = max(ATR(ATR length) * zone ATR factor, tick size * zone tick factor)
Calculation: Body = abs(close - open)
Calculation: BodyToRange = Body / max(high - low, tick size)
Long: ResistanceLevel > close AND (confirm on close is off OR bar is closed) AND strong body break is on AND close > ResistanceLevel + ZoneSize AND open > ResistanceLevel + ZoneSize AND close > open AND BodyToRange > doji max ratio AND BodyToRange >= min body ratio AND Body >= ATR(ATR length) * min body ATR factor
Long: ResistanceLevel > close AND (confirm on close is off OR bar is closed) AND strong body break is off AND close > ResistanceLevel
Short: SupportLevel < close AND (confirm on close is off OR bar is closed) AND strong body break is on AND close < SupportLevel - ZoneSize AND open < SupportLevel - ZoneSize AND close < open AND BodyToRange > doji max ratio AND BodyToRange >= min body ratio AND Body >= ATR(ATR length) * min body ATR factor
Short: SupportLevel < close AND (confirm on close is off OR bar is closed) AND strong body break is off AND close < SupportLevel